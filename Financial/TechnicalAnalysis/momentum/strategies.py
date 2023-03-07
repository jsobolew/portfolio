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

class MACDZeroHistPrediction:
    def __init__(self, linerPredictionWindow, ticker, interval, fastperiod = 12, slowperiod = 26, signalperiod = 9) -> None:
        # asset and timeframe
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
        # self.timestamps = []
        # self.tradetimestamps = []

    def getBackTestSignals(self, data, visualize_signals = False):
        for i in range(-len(data)+20, -1):
            currdata = data.iloc[:i]
            predtimestamp = data.index[i]
            signal, prediction = self.getSignal(currdata)

            if self.signals != [] and (self.signals[-1] == signal and (signal == -1 or signal == 1)):
                self.signals.append(0)
                continue
            
            if signal == -1 or signal == 1:
                self.trades.append({'time': predtimestamp, 'ticker':self.ticker, 'signal': signal, 'price': data['Open'][i]})

            # if signal == -1:
            #     self.trades.append(myTA.Trade(predtimestamp, "sell", data['Open'][i]))
            #     self.tradetimestamps.append(predtimestamp)
            # elif signal == 1:
            #     self.trades.append(myTA.Trade(predtimestamp, "buy", data['Open'][i]))
            #     self.tradetimestamps.append(predtimestamp)

            if visualize_signals and (signal == 1 or signal == -1):
                plt.plot(currdata['macd_hist'][-self.linerPredictionWindow:])
                plt.plot(predtimestamp, prediction, "*")
                plt.title(signal)
                plt.show()

            self.signals.append(signal)
            # self.timestamps.append(predtimestamp)

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
        
