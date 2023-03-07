import sys
sys.path.insert(0, '../')
import myTA

import talib as ta
import numpy as np
import yfinance as yf
import pandas as pd
import matplotlib.pyplot as plt
import datetime as dt
import pandas as pd


def predictLinear(currData):
    meanDiff = np.mean(np.diff(currData))
    return currData[-1]+meanDiff

def downloadAndMakeAnalysis(strategy):
    data = yf.download(strategy.ticker, start=strategy.start, end=strategy.end, interval=strategy.interval, progress=False)
    data['RSI'] = ta.RSI(data['Close'])
    data['macd'], data['macd_signal'], data['macd_hist'] = ta.MACD(data['Close'], fastperiod = strategy.fastperiod, slowperiod = strategy.slowperiod, signalperiod = strategy.signalperiod)
    data['SMA200'], data['SMA100'] = ta.SMA(data['Close'], 200), ta.SMA(data['Close'], 100)
    return data   

def makeAnalysis(strategy, data):
    data['RSI'] = ta.RSI(data['Close'])
    data['macd'], data['macd_signal'], data['macd_hist'] = ta.MACD(data['Close'], fastperiod = strategy.fastperiod, slowperiod = strategy.slowperiod, signalperiod = strategy.signalperiod)
    data['SMA200'], data['SMA100'] = ta.SMA(data['Close'], 200), ta.SMA(data['Close'], 100)
    return data   

class MACDZeroHistPrediction:
    def __init__(self, linerPredictionWindow, ticker, start, end, interval, fastperiod = 12, slowperiod = 26, signalperiod = 9) -> None:
        # asset and timeframe
        self.start = start
        self.end = end
        self.ticker = ticker
        self.interval = interval

        # strategy parameters
        self.linerPredictionWindow = linerPredictionWindow
        self.fastperiod = fastperiod
        self.slowperiod = slowperiod
        self.signalperiod = signalperiod

        # outputs
        self.signals = []
        self.trades = []
        self.timestamps = []
        self.tradetimestamps = []

    def getBackTestSignals(self, data, visualize_signals = False):
        for i in range(-len(data)+20, -1):
            currdata = data.iloc[:i]
            predtimestamp = data.index[i]
            signal, prediction = self.getSignal(currdata)

            if self.signals != [] and (self.signals[-1] == signal and (signal == -1 or signal == 1)):
                self.signals.append(0)
                continue

            if signal == -1:
                self.trades.append(myTA.Trade(predtimestamp, "sell", data['Open'][i]))
                self.tradetimestamps.append(predtimestamp)
            elif signal == 1:
                self.trades.append(myTA.Trade(predtimestamp, "buy", data['Open'][i]))
                self.tradetimestamps.append(predtimestamp)

            if visualize_signals and (signal == 1 or signal == -1):
                plt.plot(currdata['macd_hist'][-self.linerPredictionWindow:])
                plt.plot(predtimestamp, prediction, "*")
                plt.title(signal)
                plt.show()

            self.signals.append(signal)
            self.timestamps.append(predtimestamp)

    def getSignal(self, data):
        prediction = predictLinear(data['macd_hist'][-self.linerPredictionWindow:].values)

        if prediction > 0 and data['macd_hist'][-1] < 0 or data['macd_hist'][-1] > 0 and data['macd_hist'][-2] < 0:
            return 1, prediction
        elif prediction < 0 and data['macd_hist'][-1] > 0 or data['macd_hist'][-1] < 0 and data['macd_hist'][-2] > 0:
            return -1, prediction
        else:
            return 0, prediction

class MACDZeroHistPredictionAndSMA(MACDZeroHistPrediction):
    def getSignal(self, data):
        prediction = predictLinear(data['macd_hist'][-self.linerPredictionWindow:].values)

        if prediction > 0 and data['macd_hist'][-1] < 0 or data['macd_hist'][-1] > 0 and data['macd_hist'][-2] < 0 and data['Close'][-1] > data['SMA100'][-1]:
            return 1, prediction
        elif prediction < 0 and data['macd_hist'][-1] > 0 or data['macd_hist'][-1] < 0 and data['macd_hist'][-2] > 0:
            return -1, prediction
        else:
            return 0, prediction
        
class Backtesting:
    def __init__(self, budget_start, strategy) -> None:
        self.strategy = strategy

        self.budget_start = budget_start # usd
        self.position = 0
        self.result = 0

        self.timestamp = []
        self.budget = []
        self.portfolio_value = []
        self.cost_of_investment = []
        self.return_on_investment = []
        self.ROI = []

        self.resturnsdf = pd.DataFrame()

    def runEndAnalitics(self):
        self.resturnsdf = pd.concat([self.resturnsdf, pd.DataFrame({"timestamp": self.timestamp,
                                                                    "date" : [self.timestamp[i].date() for i in range(len(self.timestamp))],
                                                                    "budget": self.budget,
                                                                    "portfolio_value": self.portfolio_value,
                                                                    "cost_of_investment": self.cost_of_investment,
                                                                    "return_on_investment" : self.return_on_investment,
                                                                    "ROI": self.ROI
                                                                    })
                                                                    ])
        self.resturnsdf['ROI_change'] = self.resturnsdf['ROI'].diff().fillna(0)
        # self.resturnsdf['return%'] = self.resturnsdf['return_on_investment'].pct_change().fillna(0)
        self.resturnsdfDaily = self.resturnsdf.groupby('date').sum()[['ROI_change']]
        self.resturnsdfDaily.index = pd.to_datetime(self.resturnsdfDaily.index)

        self.result = np.round(self.return_on_investment[-1])

    def calculateCurrentValues(self, tmp_budget, trade):
        tmp_position = self.position
        while tmp_position > 0:
            tmp_budget += trade.price
            tmp_position -= 1

        self.timestamp.append(trade.date)

        self.portfolio_value.append(tmp_budget)
        self.cost_of_investment.append(self.budget_start - self.budget[-1])
        self.return_on_investment.append(self.portfolio_value[-1] - self.budget_start)
        self.ROI.append(self.return_on_investment[-1]/self.budget_start*100)

    def calculateProfit(self):
        budget = self.budget_start

        for trade in self.strategy.trades:
            if trade.kind == "buy" and budget > trade.price:
                self.position += 1
                budget -= trade.price
            elif trade.kind =="sell" and self.position > 0:
                self.position -= 1
                budget += trade.price
            self.budget.append(budget)
            self.calculateCurrentValues(budget, trade)
            # print(trade.kind, trade.date, trade.price)

        self.runEndAnalitics()


class SharpeRatio:
    def __init__(self) -> None:
        self.risk_free_rate = yf.download("^TNX", progress=False)[['Close']].reset_index()
        self.risk_free_rate['daily_risk_free_rate'] = (1 + self.risk_free_rate['Close']) ** (1/252) - 1
        self.risk_free_rate.set_index("Date", inplace=True)
        # https://quant.stackexchange.com/questions/22123/how-to-calculate-daily-risk-free-interest-rates

    def calculate(self, daily_return):
        # rf_daily = (1 + rf_yearly) ** (1/252) - 1
        # rf_daily = np.mean(self.risk_free_rate.loc[daily_return.index]['daily_risk_free_rate'])
        indexes = np.logical_and(self.risk_free_rate.index > daily_return.index[0], self.risk_free_rate.index < daily_return.index[-1])
        rf_daily = np.mean(self.risk_free_rate.loc[indexes]['daily_risk_free_rate'])

        mean_daily_return = np.mean(daily_return)
        if mean_daily_return == 0:
            return 0

        s = np.std(daily_return)

        daily_sharpe_ratio = (mean_daily_return - rf_daily) / s

        sharpe_ratio = np.sqrt(252) * daily_sharpe_ratio

        # print(f"""mean deali return: {mean_daily_return} % \nstd: {s} %""")
        
        return np.round(sharpe_ratio, 2)
    
def get_df(df, bt, sharpe_ratio):
    df = pd.concat([df, pd.DataFrame({"interval": [bt.strategy.interval],
                                                    "start": [bt.strategy.start],
                                                    "end": [bt.strategy.end], 
                                                    "ticker": [bt.strategy.ticker],
                                                    "linerPredictionWindow": [bt.strategy.linerPredictionWindow],
                                                    "fastperiod": [bt.strategy.fastperiod], 
                                                    "slowperiod": [bt.strategy.slowperiod], 
                                                    "signalperiod": [bt.strategy.signalperiod], 
                                                    "budget_start": [bt.budget_start], 
                                                    "result": [bt.result],
                                                    "sharpe_ratio": [sharpe_ratio.calculate(bt.resturnsdfDaily['ROI_change'])],
                                                    "ROI": [bt.result/bt.budget_start*100]})])
    return df

def init_backtesting_results_file(file_name):
    df = pd.DataFrame(columns=['interval', 'start', 'end', 'ticker', 'linerPredictionWindow', 'fastperiod', 'slowperiod', 'signalperiod', 'budget_start', 'result', 'sharpe_ratio', 'ROI'])
    df.to_csv(file_name, index=False)

def get_allowedIntervals():
    intervals = ['1m', '2m', '5m', '15m', '30m', '1h', '90m', '1d']
    back_allowed = [dt.timedelta(6-1), dt.timedelta(60-1), dt.timedelta(60-1), dt.timedelta(60-1), dt.timedelta(60-1), dt.timedelta(730-1), dt.timedelta(60-1), dt.timedelta(365*(dt.datetime.now().year-1971))]

    allowedIntervals = pd.DataFrame({'intervals': intervals, 'back_allowed': back_allowed})
    return allowedIntervals

def get_parameter_combination_number(tickers, linerPredictionWindows, fastperiods, slowperiods, signalperiods, allowedIntervals):
    print(f"backtest will run for: {len(tickers)*len(linerPredictionWindows)*len(fastperiods)*len(slowperiods)*len(signalperiods)*len(allowedIntervals)} pameters combination")