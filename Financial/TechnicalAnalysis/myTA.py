import talib as ta
import numpy as np
import matplotlib.pyplot as plt
import yfinance as yf


class Trade:
    def __init__(self, date, kind, price) -> None:
        self.date = date
        self.kind = kind
        self.price = price

class Portfolio:
    def __init__(self, code) -> None:
        self.positions = dict()
        self.positions[code] = 0

    def buy(self, code):
        self.positions[code] +=1

    def sell(self, code):
        if self.positions[code] > 0:
            sold = self.positions[code]
            self.positions[code] = 0
            return sold, code
        else:
            print("No position open")
            return 0, 0

def calculateProfit(TradesList, commision):
    if TradesList == []:
        return 0
    result = 0
    if TradesList[0].kind == "sell":
        TradesList.pop(0)
    if TradesList[-1].kind == "buy":
        TradesList.pop(len(TradesList)-1)
    for t in TradesList:
        if t.kind == "buy":
            result -= (t.price + t.price*commision)
        elif t.kind == "sell":
            result += (t.price - t.price*commision)
        else:
            raise Exception("Wrong Trade kind")
    return result

def makeAnalysis(data):
    data['RSI'] = ta.RSI(data['Close'])
    data['macd'], data['macd_signal'], data['macd_hist'] = ta.MACD(data['Close'])
    data['SMA200'], data['SMA100'] = ta.SMA(data['Close'], 200), ta.SMA(data['Close'], 100)
    return data

def downloadAndMakeAnalysis(ticker_code, start, end, interval='1d'):
    data = yf.download(ticker_code, start=start, end=end, interval=interval, progress=False)
    data['RSI'] = ta.RSI(data['Close'])
    data['macd'], data['macd_signal'], data['macd_hist'] = ta.MACD(data['Close'])
    data['SMA200'], data['SMA100'] = ta.SMA(data['Close'], 200), ta.SMA(data['Close'], 100)
    return data

def plotAnalysis(data, ticker_code, trades = []):
    inedxes = np.arange(0,len(data), len(data) // 9)

    # data['RSI'] = ta.RSI(data['Close'])
    # data['macd'], data['macd_signal'], data['macd_hist'] = ta.MACD(data['Close'])
    # data['SMA200'], data['SMA100'] = ta.SMA(data['Close'], 200), ta.SMA(data['Close'], 100)
    fig, ax = plt.subplots(4, 1, gridspec_kw={"height_ratios": [3, 1, 1, 1]}, figsize=(20,15))

    ax[0].plot(data['Close'].values)
    ax[0].plot(data['SMA200'].values)
    ax[0].plot(data['SMA100'].values)
    ax[0].set_title(ticker_code)

    plt.sca(ax[0])
    plt.xticks(inedxes, [str(data.index[i].date())+ " "+str(data.index[i].hour)+":"+str("%02d" % data.index[i].minute) for i in inedxes])

    if trades != []:
        for t in trades:
            ax[0].axvline([i for i, x in enumerate(data.index == t.date) if x][0], c="r" if t.kind == "sell" else "g")
            ax[3].axvline([i for i, x in enumerate(data.index == t.date) if x][0], c="r" if t.kind == "sell" else "g")
            
    ax[1].axhline(y=70, color='r', linestyle='--')
    ax[1].axhline(y=50, color='b', linestyle='--')
    ax[1].axhline(y=30, color='g', linestyle='--')
    ax[1].plot(data['RSI'].values)
    plt.sca(ax[1])
    plt.xticks(inedxes, [str(data.index[i].date())+ " "+str(data.index[i].hour)+":"+str("%02d" % data.index[i].minute) for i in inedxes])


    c = ['red' if cl < 0 else 'green' for cl in data['macd_hist']]
    ax[2].plot(data['macd'].values, 'b-')
    ax[2].plot(data['macd_signal'].values, '--', color='orange')
    ax[2].legend(['macd', 'signal'])
    plt.sca(ax[2])
    plt.xticks(inedxes, [str(data.index[i].date())+ " "+str(data.index[i].hour)+":"+str("%02d" % data.index[i].minute) for i in inedxes])

    ax[3].bar(np.arange(len(data)),data['macd_hist'].values, color=c)
    ax[3].plot(data['macd_hist'].values)
    plt.sca(ax[3])
    plt.xticks(inedxes, [str(data.index[i].date())+ " "+str(data.index[i].hour)+":"+str("%02d" % data.index[i].minute) for i in inedxes])

def predictLinear(currData):
    meanDiff = np.mean(np.diff(currData))
    return currData[-1]+meanDiff

class TradingStrategies:
    def bestPossible(data):
        # best possible - finding top of macdhist LOOKAHED
        arr = data['macd_hist']
        binary = arr > 0
        ind = np.where(np.diff(binary))[0]

        trades = []

        for i in range(len(ind)-1):
            if binary[int((ind[i]+ind[i+1])/2)] == 0:
                curr_time_frame = [ind[i], ind[i+1]]
                best_trade_index = np.argmin(data['macd_hist'][curr_time_frame[0]:curr_time_frame[1]])
                best_trade_time = data.index[curr_time_frame[0]:curr_time_frame[1]][best_trade_index]
                trades.append(Trade(best_trade_time, "buy", data['Close'][best_trade_time]))
            else:
                curr_time_frame = [ind[i], ind[i+1]]
                best_trade_index = np.argmax(data['macd_hist'][curr_time_frame[0]:curr_time_frame[1]])
                best_trade_time = data.index[curr_time_frame[0]:curr_time_frame[1]][best_trade_index]
                trades.append(Trade(best_trade_time, "sell", data['Close'][best_trade_time]))
        return trades

    def buyAndHold(data):
        trades = []
        trades.append(Trade(data.index[1], "buy", data['Open'][1]))
        trades.append(Trade(data.index[-1], "sell", data['Close'][-1]))
        return trades
        
    def sillyStrategyOriginal(data, ticker_code):
        portfolio = Portfolio(ticker_code)
        # stupid one, no lookahead
        arr = data['macd_hist']
        binary = arr > 0
        ind = np.where(np.diff(binary))[0]

        trades = []

        for i in range(len(ind)-1):
            if ind[i+1] - ind[i] > 5:
                if (binary[int((ind[i]+ind[i+1])/2)]) == 0:
                    curr_time_frame = [ind[i], ind[i+1]]
                    analyzed_part = data['macd_hist'][curr_time_frame[0]:curr_time_frame[1]]
                    analyzed_diff = np.diff(analyzed_part)
                    if len(analyzed_part[1:][[analyzed_diff > 0][0]]) >  1:
                        best_trade_time = analyzed_part[1:][[analyzed_diff > 0][0]].index[0]
                    else:
                        best_trade_time = analyzed_part[1:][[analyzed_diff > 0][0]].index[0]
                    trades.append(Trade(best_trade_time, "buy", data['Close'][best_trade_time]))
                    portfolio.buy(ticker_code)
                elif (portfolio.positions[ticker_code] > 0):
                    curr_time_frame = [ind[i], ind[i+1]]
                    analyzed_part = data['macd_hist'][curr_time_frame[0]:curr_time_frame[1]]
                    analyzed_diff = np.diff(analyzed_part)
                    if len(analyzed_part[1:][[analyzed_diff < 0][0]]) >  1:
                        best_trade_time = analyzed_part[1:][[analyzed_diff < 0][0]].index[0]
                    else:
                        best_trade_time = analyzed_part[1:][[analyzed_diff < 0][0]].index[0]
                    if trades[-1].price < data['Close'][best_trade_time]:
                        sold, code = portfolio.sell(ticker_code)
                        trades.append(Trade(best_trade_time, "sell", data['Close'][best_trade_time]*sold))
        return trades, portfolio

    def simpleMACDLookahed(data):
        data.loc[data['macd_hist'] > 0, 'macd_hist_greaterThanZero'] = 1
        data.loc[data['macd_hist'] <= 0, 'macd_hist_greaterThanZero'] = 0
        data['buySell'] = np.diff(np.concatenate([data['macd_hist_greaterThanZero'],[0]]))

        trades = []
        position = 0

        for i in range(len(data)):
            if data['buySell'][i] == 1:
                trades.append(Trade(data.index[i], "buy", data['High'][i]))
                position += 1
            elif data['buySell'][i] == -1 and position > 0:
                trades.append(Trade(data.index[i], "sell", data['Low'][i]))
                position -= 1
        return trades

    def simpleMACD(data):
        data.loc[data['macd_hist'] > 0, 'macd_hist_greaterThanZero'] = 1
        data.loc[data['macd_hist'] <= 0, 'macd_hist_greaterThanZero'] = 0
        data['buySell'] = np.diff(np.concatenate([[0],data['macd_hist_greaterThanZero']]))

        trades = []
        position = 0

        for i in range(len(data)):
            if data['buySell'][i] == 1:
                trades.append(Trade(data.index[i], "buy", data['High'][i]))
                position += 1
            elif data['buySell'][i] == -1 and position > 0:
                trades.append(Trade(data.index[i], "sell", data['Low'][i]))
                position -= 1
        return trades

    def simpleMACDOpenClose(data):
        data['macd'], data['macd_signal'], data['macd_hist'] = ta.MACD(data['Open'])
        data.loc[data['macd_hist'] > 0, 'macd_hist_greaterThanZero'] = 1
        data.loc[data['macd_hist'] <= 0, 'macd_hist_greaterThanZero'] = 0
        data['buySell'] = np.diff(np.concatenate([data['macd_hist_greaterThanZero'],[0]]))

        trades = []
        position = 0

        for i in range(len(data)):
            if data['buySell'][i] == 1:
                trades.append(Trade(data.index[i], "buy", data['High'][i]))
                position += 1
            elif data['buySell'][i] == -1 and position > 0:
                trades.append(Trade(data.index[i], "sell", data['Close'][i]))
                position -= 1
        return trades

    def simpleMACDZeroHistPrediction(data):
        coef = np.array([1,  0.06866184, -0.65870416,  1.58685211])
        window = 4

        trades = []
        position = 0

        for i in range(33, len(data)-4):
            # prediction = np.matmul(data['macd_hist'][i-4:i].values, coef)
            prediction = predictLinear(data['macd_hist'][i-window:i].values)
            if prediction > 0 and data['macd_hist'][i-1] < 0 and position < 1:
                trades.append(Trade(data.index[i], "buy", data['Open'][i]))
                position += 1
            elif prediction > 0 and data['macd_hist'][i-1] < 0 and position > 0:
                trades.append(Trade(data.index[i], "sell", data['Open'][i]))
                position -= 1
        return trades

    def simpleMACDZeroHistPredictionNoLoss(data):
        coef = np.array([1,  0.06866184, -0.65870416,  1.58685211])

        trades = []
        position = 0

        for i in range(33, len(data)-4):
            # prediction = np.matmul(data['macd_hist'][i-4:i].values, coef)
            prediction = predictLinear(data['macd_hist'][i-4:i].values)
            if prediction > 0 and data['macd_hist'][i-1] < 0 and position < 1:
                trades.append(Trade(data.index[i], "buy", data['High'][i]))
                position += 1
            elif prediction > 0 and data['macd_hist'][i-1] < 0 and position > 0 and trades[-1].price < data['Low'][i]:
                trades.append(Trade(data.index[i], "sell", data['Low'][i]))
                position -= 1
        return trades

    def simpleMACDNoLossOnTrade(data):
        data.loc[data['macd_hist'] > 0, 'macd_hist_greaterThanZero'] = 1
        data.loc[data['macd_hist'] <= 0, 'macd_hist_greaterThanZero'] = 0
        data['buySell'] = np.diff(np.concatenate([[0], data['macd_hist_greaterThanZero']]))

        trades = []
        position = 0

        for i in range(len(data)):
            if data['buySell'][i] == 1 and position < 1:
                trades.append(Trade(data.index[i], "buy", data['High'][i]))
                position += 1
            elif data['buySell'][i] == -1 and position > 0 and trades[-1].price < data['Low'][i]:
                trades.append(Trade(data.index[i], "sell", data['Low'][i]))
                position -= 1
        return trades

    def macdMomentumLoss(data):
        operations = []
        diffmacd = np.diff(data['macd_hist'])

        for i in range(1,len(diffmacd)):
            if diffmacd[i-1] < 0 and diffmacd[i] > 0:
                operations.append(1)
            elif diffmacd[i-1] > 0 and diffmacd[i] < 0:
                operations.append(-1)
            else:
                operations.append(0)
                
        data['buySell'] = np.concatenate([[0,0],operations])

        tradesList = []
        position = 0

        for i in range(len(data)):
            if data['buySell'][i] == 1 and position < 1:
                tradesList.append(Trade(data.index[i], "buy", data['High'][i]))
                position += 1
            elif data['buySell'][i] == -1 and position > 0:
                tradesList.append(Trade(data.index[i], "sell", data['Low'][i]))
                position -= 1
        return tradesList