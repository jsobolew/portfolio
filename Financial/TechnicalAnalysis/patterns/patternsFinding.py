import numpy as np
import pandas as pd
import plotly.graph_objects as go
from scipy.stats import linregress
import matplotlib.pyplot as plt
import warnings

# Pivot finding
def pivotid(df1, l, n1, n2): #n1 n2 before and after candle l
    if l-n1 < 0 or l+n2 >= len(df1):
        return 0
    
    pividlow=1
    pividhigh=1
    for i in range(l-n1, l+n2+1):
        if(df1.Low[l]>df1.Low[i]):
            pividlow=0
        if(df1.High[l]<df1.High[i]):
            pividhigh=0
    if pividlow and pividhigh:
        return 3
    elif pividlow:
        return 1
    elif pividhigh:
        return 2
    else:
        return 0

def pointpos(x):
    if x['pivot']==1:
        return x['Low']-1e-3
    elif x['pivot']==2:
        return x['High']+1e-3
    else:
        return np.nan

# Patterns finding
def fitTrianglesForCandle(df, candleid, backcandles=20):
    idx = df.iloc[candleid-backcandles:candleid+1]['pivot']==1
    idx = idx.index[idx]
    minim = df.loc[idx, 'Low'].values
    xxmin = idx.values

    idx = df.iloc[candleid-backcandles:candleid+1]['pivot']==2
    idx = idx.index[idx]
    maxim = df.loc[idx, 'High'].values
    xxmax = idx.values

    slmin, intercmin, rmin, pmin, semin = linregress(xxmin, minim)
    slmax, intercmax, rmax, pmax, semax = linregress(xxmax, maxim)
    return slmin, intercmin, rmin, pmin, semin, slmax, intercmax, rmax, pmax, semax, xxmin, minim, xxmax, maxim

def searchForValidCandles(df, backcandles=20, minNoPoints=3, fitThreshold=0.9):
    validCandles = []
    for candleid in range(1, len(df)):
        maxim = np.array([])
        minim = np.array([])
        xxmin = np.array([])
        xxmax = np.array([])
        for i in range(candleid-backcandles, candleid+1):
            if df.iloc[i].pivot == 1:
                minim = np.append(minim, df.iloc[i].Low)
                xxmin = np.append(xxmin, i)
            if df.iloc[i].pivot == 2:
                maxim = np.append(maxim, df.iloc[i].High)
                xxmax = np.append(xxmax, i)

        if (xxmax.size <minNoPoints and xxmin.size <minNoPoints) or xxmax.size==0 or xxmin.size==0:
            continue

        slmin, intercmin, rmin, pmin, semin = linregress(xxmin, minim)
        slmax, intercmax, rmax, pmax, semax = linregress(xxmax, maxim)
            
        if abs(rmax)>=fitThreshold and abs(rmin)>=fitThreshold and slmin>=0.0001 and slmax<=-0.0001:
            validCandles.append(candleid)
    return validCandles

def searchForPatterns(df, backcandles=20, minPts=3):
    warnings.filterwarnings("ignore")
    validCandles = pd.DataFrame(columns=['candleid','rmax','rmin','slmin','slmax','xxmax_size','xxmin_size'])
    prev = 0
    for candleid in range(1, len(df)):
        idx = df.iloc[candleid-backcandles:candleid+1]['pivot']==1
        idx = idx.index[idx]
        minim = df.loc[idx, 'Low'].values
        xxmin = idx.values

        idx = df.iloc[candleid-backcandles:candleid+1]['pivot']==2
        idx = idx.index[idx]
        maxim = df.loc[idx, 'High'].values
        xxmax = idx.values

        if (xxmax.size < minPts and xxmin.size <minPts and np.abs(xxmax.size-xxmin.size) > 1) or xxmax.size==0 or xxmin.size==0:
            continue

        slmin, intercmin, rmin, pmin, semin = linregress(xxmin, minim)
        slmax, intercmax, rmax, pmax, semax = linregress(xxmax, maxim)

        if slmin*candleid + intercmin > slmax*candleid + intercmax:
            continue
        
        if candleid - prev > 1:
            validCandles = pd.concat([validCandles, pd.DataFrame({'candleid':[candleid],
            'rmax':[np.abs(rmax)],
            'rmin':[np.abs(rmin)],
            'slmin':[slmin],
            'slmax':[slmax],
            'xxmax_size':[xxmax.size],
            'xxmin_size':[xxmin.size]
            })])
        prev = candleid

    validCandles = validCandles.dropna().reset_index().drop(columns='index')
    validCandles['pattern_type'] = ''
    for i in range(len(validCandles)):
        validCandles.loc[i,'pattern_type'] = categorizePattern(validCandles.iloc[i])
    warnings.filterwarnings("default")
    return validCandles

def visualizeValidCandle(df, candleid, backcandles=20, visualize=False):
    warnings.filterwarnings("ignore")
    slmin, intercmin, rmin, pmin, semin, slmax, intercmax, rmax, pmax, semax, xxmin, minim, xxmax, maxim = fitTrianglesForCandle(df, candleid, backcandles)
    dfpl = df[np.max([candleid-backcandles-30, 0]):candleid+backcandles+30]

    xxmin = np.append(xxmin, np.max([xxmin[-1], xxmax[-1]]))
    xxmax = np.append(xxmax, np.max([xxmin[-1], xxmax[-1]]))


    triangle = pd.DataFrame(columns=['x', 'ymin', 'ymax', 'min', 'max'])
    x = candleid - backcandles
    ymin = slmin*x + intercmin
    ymax = slmax*x + intercmax

    while ymin < ymax and x < candleid+10:
        ymin = slmin*x + intercmin
        ymax = slmax*x + intercmax
        triangle = pd.concat([triangle, pd.DataFrame({'x':[x], 'ymin':[ymin], 'ymax':[ymax], 'min':[df.iloc[x].Low], 'max':[df.iloc[x].High]})])
        x += 1
        if x > len(df)-1:
            break
    triangle.set_index('x', inplace=True)

    if visualize:
        fig = go.Figure(data=[go.Candlestick(x=dfpl.index,
                        open=dfpl['Open'],
                        high=dfpl['High'],
                        low=dfpl['Low'],
                        close=dfpl['Close'])])
        fig.add_scatter(x=dfpl.index, y=dfpl['pointpos'], mode="markers",
                        marker=dict(size=4, color="MediumPurple"),
                        name="pivot")
        fig.add_scatter(x=[candleid], y=[df.iloc[candleid].Close-2e-3], mode="markers",
                        marker=dict(size=6, color="Blue"),
                        name="pattern till")
        fig.add_trace(go.Scatter(x=xxmin, y=slmin*xxmin + intercmin, mode='lines', name='min slope'))
        fig.add_trace(go.Scatter(x=xxmax, y=slmax*xxmax + intercmax, mode='lines', name='max slope'))
        fig.update_layout(xaxis_rangeslider_visible=False)
        fig.show()

        # triangle.plot(figsize=(25,7))
        # plt.vlines(candleid, triangle['ymin'].min(), triangle['ymin'][candleid], linestyles='--', colors='orange')
        # plt.show()
    warnings.filterwarnings("default")
    return triangle

# Opportunity Class
class Opportunity:
    def __init__(self, df, triangle, candleid, backcandles) -> None:
        self.df = df
        self.triangle = triangle
        self.candleid = candleid
        self.backcandles = backcandles

        priorDataTimeWindow = 30
        priorData = self.df.iloc[np.max([candleid-priorDataTimeWindow, 0]):candleid]
        self.priorData = priorData
        self.priorTrend = {
            'min': priorData['Low'].min(),
            'max': priorData['High'].max(),
            'volatility%': (priorData['High'].max()-priorData['Low'].min())/priorData.iloc[-1].Close*100,
            'change': priorData.iloc[-1].Close-priorData.iloc[0].Open,
            'change%': (priorData.iloc[-1].Close-priorData.iloc[0].Open)/priorData.iloc[-1].Close*100
        }
        self.momentum = 'bullish' if self.priorTrend['change'] > 0 else 'bearish'

        self.enterIndex, self.breakOutSignal = Opportunity.whenToEnterAndSignal(self.triangle, self.candleid, self.backcandles)
        self.enterIndex += 1 # one day delay, this is in times (days, h...) after candleid

        self.enterPrice = self.df.loc[self.candleid+self.enterIndex, 'Open'] # assume we buy at open

        self.kind = 'long' # 'long' 'short'  # for now I'' only do Long as we don't determin optimal kind of trade so far
        returnsTimeFrame = 50
        self.returns = self.df.loc[self.candleid+self.enterIndex:self.candleid+self.enterIndex+returnsTimeFrame]['Close'] - self.enterPrice
        self.returns = np.concatenate([self.returns, [0 for _ in range(returnsTimeFrame+1-len(self.returns))]])
        self.returnsPercent = (self.df.loc[self.candleid+self.enterIndex:self.candleid+self.enterIndex+returnsTimeFrame]['Close'] - self.enterPrice)/self.enterPrice*100
        self.returnsPercent = np.concatenate([self.returnsPercent, [0 for _ in range(returnsTimeFrame+1-len(self.returnsPercent))]])
        if self.enterPrice == 0:
            self.returnsPercent = [0 for _ in range(returnsTimeFrame+1)]

        # TODO
        # determine optimal kind of trade
    # def determineContinuation(self):
    #     self.enterIndex, self.breakOutSignal = Opportunity.whenToEnterAndSignal(self.triangle, self.candleid, self.backcandles)

    def plotEverything(self):
        dfpl = self.df[np.max([self.candleid-self.backcandles-30, 0]):self.candleid+self.backcandles+30]
        fig = go.Figure(data=[go.Candlestick(x=dfpl.index,
                        open=dfpl['Open'],
                        high=dfpl['High'],
                        low=dfpl['Low'],
                        close=dfpl['Close'])])
        fig.add_scatter(x=dfpl.index, y=dfpl['pointpos'], mode="markers",
                        marker=dict(size=4, color="MediumPurple"),
                        name="pivot")
        fig.add_scatter(x=[self.candleid], y=[self.df.iloc[self.candleid].Close-2e-3], mode="markers",
                        marker=dict(size=6, color="Blue"),
                        name="pattern till")

        fig.add_trace(go.Scatter(x=self.triangle.index.values, y=self.triangle['ymin'].values, mode='lines', name='min slope'))
        fig.add_trace(go.Scatter(x=self.triangle.index.values, y=self.triangle['ymax'].values, mode='lines', name='max slope'))
        fig.update_layout(xaxis_rangeslider_visible=False)
        fig.show()

        self.triangle.plot(figsize=(25,7))
        try: # sometimes triangle can end before candleid
            plt.vlines(self.candleid, self.triangle['ymin'].min(), self.triangle['ymin'][self.candleid], linestyles='--', colors='orange')
        except:
            pass
        plt.title(f"momentum: {self.momentum} breakout signal: {self.breakOutSignal}")
        plt.show()

        self.returns.plot(figsize=(25,7))
        plt.title(f"momentum: {self.momentum}           breakout signal: {self.breakOutSignal}")
        plt.show()

    def whenToEnterAndSignal(triangle, candleid, backcandles):
        val = 0
        for i in range(backcandles, len(triangle)):
            if triangle.iloc[i]['max'] > triangle.iloc[i]['ymax']:
                val += triangle.iloc[i]['max'] - triangle.iloc[i]['ymax']
            if triangle.iloc[i]['min'] < triangle.iloc[i]['ymin']:
                val -= triangle.iloc[i]['ymin'] - triangle.iloc[i]['min']
            if val/((triangle.loc[candleid, 'min']+triangle.loc[candleid, 'max'])/2) < -0.1:
                return i-backcandles , 'bearish'
            if val/((triangle.loc[candleid, 'min']+triangle.loc[candleid, 'max'])/2) > 0.1:
                return i-backcandles , 'bullish'
        return 0, 'bullish' if val > 0 else 'bearish'

def categorizePattern(row): # to be validated
    # Triangles
    if row.slmax < 0.1 and row.slmin > 0.1:
        return 'Symmetrical Triangle'
    elif row.slmax < 0.1 and row.slmin < 0.1 and row.slmin - row.slmax > 0.05:
        return 'Falling Wedge'
    elif row.slmax < 0.1 and row.slmax > -0.1 and row.slmin > 0.1:
        return 'Ascending Triangle'
    elif row.slmin < 0.1 and row.slmin > -0.1 and row.slmax < 0:
        return 'Descending Triangle'
    elif row.slmin < 0.1 and row.slmin > -0.1 and row.slmax < 0:
        return 'Rising Wedge'
    # Rectangles
    elif row.slmax < 0.1 and row.slmax > -0.1 and row.slmin < 0.1 and row.slmin > -0.1:
        return 'Rectangle'
    # Flag
    elif row.slmax > 0.1 and row.slmax < -0.1 and np.abs(row.slmin - row.slmax) < 0.1:
        return 'Flag'

def queryPatterns(validCandles, pattern_name, rlevel):
    return validCandles[(validCandles['pattern_type']==pattern_name) & (validCandles['rmax'] > rlevel) & (validCandles['rmin'] > rlevel)]

def plotStock(df):
    dfpl = df
    fig = go.Figure(data=[go.Candlestick(x=dfpl.index,
                    open=dfpl['Open'],
                    high=dfpl['High'],
                    low=dfpl['Low'],
                    close=dfpl['Close'])])

    fig.add_scatter(x=dfpl.index, y=dfpl['pointpos'], mode="markers",
                    marker=dict(size=5, color="MediumPurple"),
                    name="pivot")
    fig.show()
# automated analysis
# def showPatterns(df, backcandles, minNoPoints=3, fitThreshold=0.5):
#     df['pivot'] = df.apply(lambda x: pivotid(df, x.name,3,3), axis=1)
#     df['pointpos'] = df.apply(lambda row: pointpos(row), axis=1)
#     print("data analyzed")

#     warnings.filterwarnings("ignore")
#     validCandles = searchForValidCandles(df, backcandles=backcandles, minNoPoints=minNoPoints, fitThreshold=fitThreshold)
#     validCandles = np.array(validCandles)[np.diff(np.concatenate([[0], validCandles]))>1]
#     print(f"{len(validCandles)} valid candles found, printing plots...")
#     for validCandle in validCandles:
#         print(f"------------------------ validCandle: {validCandle} ------------------------")
#         triangle = visualizeValidCandle(df, validCandle, backcandles=backcandles)
#         opportunity = Opportunity(df, triangle, validCandle, backcandles)
#         opportunity.plotEverything()
#     warnings.filterwarnings("default")

def getPatterns(df, code, backcandles, minNoPoints=3):
    patterns = pd.DataFrame(columns=['code','momentum','momentumChange%','breakOutSignal','returnsPercent'])
    df['pivot'] = df.apply(lambda x: pivotid(df, x.name,3,3), axis=1)
    df['pointpos'] = df.apply(lambda row: pointpos(row), axis=1)
    print("data analyzed")

    warnings.filterwarnings("ignore")
    validCandles = searchForPatterns(df, backcandles=backcandles, minPts=minNoPoints)
    validCandlesList = validCandles['candleid']
    print(f"{len(validCandles)} valid candles found, printing plots...")
    for validCandle in validCandlesList:
        triangle = visualizeValidCandle(df, validCandle, backcandles=backcandles)
        opportunity = Opportunity(df, triangle, validCandle, backcandles)
        patterns = pd.concat([patterns, pd.DataFrame({'code':[code],'momentum':[opportunity.momentum], 'momentumChange%':[opportunity.priorTrend['change%']], 'breakOutSignal':[opportunity.breakOutSignal],'returnsPercent':[opportunity.returnsPercent]})])
    warnings.filterwarnings("default")
    return pd.merge(left=patterns.reset_index().drop(columns='index').reset_index(), right=validCandles.reset_index()).drop(columns='index')