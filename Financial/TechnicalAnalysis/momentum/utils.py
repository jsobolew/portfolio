import talib as ta
import numpy as np
import yfinance as yf
import pandas as pd
import matplotlib.pyplot as plt
import datetime as dt
import pandas as pd

def downloadAndMakeAnalysis(strategy, start, end):
    data = yf.download(strategy.ticker, start=start, end=end, interval=strategy.interval, progress=False)
    data['RSI'] = ta.RSI(data['Close'])
    data['macd'], data['macd_signal'], data['macd_hist'] = ta.MACD(data['Close'], fastperiod = strategy.fastperiod, slowperiod = strategy.slowperiod, signalperiod = strategy.signalperiod)
    data['SMA200'], data['SMA100'] = ta.SMA(data['Close'], 200), ta.SMA(data['Close'], 100)
    return data   

def makeAnalysis(strategy, data):
    data['RSI'] = ta.RSI(data['Close'])
    data['macd'], data['macd_signal'], data['macd_hist'] = ta.MACD(data['Close'], fastperiod = strategy.fastperiod, slowperiod = strategy.slowperiod, signalperiod = strategy.signalperiod)
    data['SMA200'], data['SMA100'] = ta.SMA(data['Close'], 200), ta.SMA(data['Close'], 100)
    return data   

# class Backtesting:
#     def __init__(self, budget_start, strategy, start, end,) -> None:
#         self.strategy = strategy

#         self.start = start
#         self.end = end

#         self.budget_start = budget_start # usd
#         self.position = 0
#         self.result = 0

#         self.timestamp = []
#         self.budget = []
#         self.portfolio_value = []
#         self.cost_of_investment = []
#         self.return_on_investment = []
#         self.ROI = []

#         self.resturnsdf = pd.DataFrame()

#     def runEndAnalitics(self):
#         self.resturnsdf = pd.concat([self.resturnsdf, pd.DataFrame({"timestamp": self.timestamp,
#                                                                     "date" : [self.timestamp[i].date() for i in range(len(self.timestamp))],
#                                                                     "budget": self.budget,
#                                                                     "portfolio_value": self.portfolio_value,
#                                                                     "cost_of_investment": self.cost_of_investment,
#                                                                     "return_on_investment" : self.return_on_investment,
#                                                                     "ROI": self.ROI
#                                                                     })
#                                                                     ])
#         self.resturnsdf['ROI_change'] = self.resturnsdf['ROI'].diff().fillna(0)
#         # self.resturnsdf['return%'] = self.resturnsdf['return_on_investment'].pct_change().fillna(0)
#         self.resturnsdfDaily = self.resturnsdf.groupby('date').sum()[['ROI_change']]
#         self.resturnsdfDaily.index = pd.to_datetime(self.resturnsdfDaily.index)

#         self.result = np.round(self.return_on_investment[-1])

#     def calculateCurrentValues(self, tmp_budget, trade):
#         tmp_position = self.position
#         while tmp_position > 0:
#             tmp_budget += trade.price
#             tmp_position -= 1

#         self.timestamp.append(trade.date)

#         self.portfolio_value.append(tmp_budget)
#         self.cost_of_investment.append(self.budget_start - self.budget[-1])
#         self.return_on_investment.append(self.portfolio_value[-1] - self.budget_start)
#         self.ROI.append(self.return_on_investment[-1]/self.budget_start*100)

#     def calculateProfit(self):
#         budget = self.budget_start

#         for trade in self.strategy.trades:
#             if trade.kind == "buy" and budget > trade.price:
#                 self.position += 1
#                 budget -= trade.price
#             elif trade.kind =="sell" and self.position > 0:
#                 self.position -= 1
#                 budget += trade.price
#             self.budget.append(budget)
#             self.calculateCurrentValues(budget, trade)
#             # print(trade.kind, trade.date, trade.price)

#         self.runEndAnalitics()


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
                                                    "start": [bt.start],
                                                    "end": [bt.end], 
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

class Portfolio:
    def __init__(self, budget_start, ticker_data_dict, ticker_strategy_dict):
        self.budget_start = budget_start
        self.ticker_data_dict = ticker_data_dict
        self.ticker_strategy_dict = ticker_strategy_dict

        self.run_assertions()

        self.signals = []
        self.trades = []

        self.timestamp = []
        self.portfolio_value = []
        self.cost_of_investment = []
        self.return_on_investment = []
        self.ROI = []
        self.resturnsdf = pd.DataFrame()

        self.budget = self.budget_start
        self.curr_budget = []
        self.curr_budget.append(self.budget_start)


        self.positions = dict()
        for ticker in self.ticker_data_dict.keys():
            self.positions[ticker] = 0
        
    def run_assertions(self):
        data_len = []
        for ticker in self.ticker_strategy_dict:
            data_len.append(len(self.ticker_data_dict[ticker]))
        
        data_len = np.array(data_len)

        assert np.all(data_len == data_len[0]), "data must be same length"
        self.data_len = data_len[0]

        # todo asser ticker are in the same order in ticker_data_dict and ticker_strategy_dict
        # asset that .index is same - same dates

    def run_backtest(self):
        for i in range(-self.data_len+20, -1):
            for ticker in self.ticker_data_dict:
                currdata = self.ticker_data_dict[ticker].iloc[:i]
                predtimestamp = self.ticker_data_dict[ticker].index[i]
                signal, prediction = self.ticker_strategy_dict[ticker].getSignal(currdata)

                if self.signals != [] and (self.signals[-1] == signal and (signal == -1 or signal == 1)):
                    self.signals.append(0)
                    continue
                
                if signal == -1 and self.positions[ticker] > 0:
                    self.trades.append(
                        {'time': predtimestamp, 'ticker': ticker, 'signal': -self.positions[ticker], 'price': self.ticker_data_dict[ticker]['Open'][i]})
                    
                    self.budget += self.positions[ticker]*self.ticker_data_dict[ticker]['Open'][i]
                    self.positions[ticker] -= self.positions[ticker]
                    # self.calculateCurrentValues(i, ticker, predtimestamp)

                elif signal == 1 and self.positions[ticker] < 1 and self.budget - self.ticker_data_dict[ticker]['Open'][i] > 0:
                    self.trades.append(
                        {'time': predtimestamp, 'ticker': ticker, 'signal': signal, 'price': self.ticker_data_dict[ticker]['Open'][i]})
                    
                    self.budget -= signal*self.ticker_data_dict[ticker]['Open'][i]
                    self.positions[ticker] += signal
                    # self.calculateCurrentValues(i, ticker, predtimestamp)

                self.signals.append(signal)
            self.calculateCurrentValues(i, predtimestamp)
        self.sell_everything_at_the_end()
        self.runEndAnalitics()

    def calculateCurrentValues(self, i, predtimestamp):
        self.curr_budget.append(self.budget)
        self.timestamp.append(predtimestamp)
        portfolio_value = self.budget
        for ticker in self.ticker_data_dict.keys():
            portfolio_value += self.positions[ticker]*self.ticker_data_dict[ticker]['Open'][i]

        self.portfolio_value.append(portfolio_value)


        self.cost_of_investment.append(self.budget_start - self.budget)
        self.return_on_investment.append(self.portfolio_value[-1] - self.budget_start)
        self.ROI.append(self.return_on_investment[-1]/self.budget_start*100)

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
    
    def sell_everything_at_the_end(self):
        for ticker in self.positions.keys():
            if self.positions[ticker] > 0:
                self.trades.append({'time': self.ticker_data_dict[ticker].index[-1], 'ticker': ticker, 'signal': -self.positions[ticker], 'price': self.ticker_data_dict[ticker]['Open'][-1]})
                self.budget += self.positions[ticker]*self.ticker_data_dict[ticker]['Open'][-1]
                self.positions[ticker] -= self.positions[ticker]
                self.calculateCurrentValues(len(self.ticker_data_dict[ticker])-1, self.ticker_data_dict[ticker].index[-1])

def filter_inconsistent_data(initial_ticker_data_dict, initial_ticker_strategy_dict, tickers):
    # using data with same length (should be same but it sometimes is not :( - that is problematic))
    tickers_df = pd.DataFrame()
    for ticker in tickers:
        tickers_df = pd.concat([tickers_df, pd.DataFrame({'ticker': [ticker], 'len': [len(initial_ticker_data_dict[ticker])]})])


    tickers = tickers_df[tickers_df['len'] == tickers_df['len'].mode()[0]]['ticker']

    # final ticker data dict
    ticker_data_dict = dict()
    ticker_strategy_dict = dict()

    for ticker in tickers:
        ticker_data_dict[ticker] = initial_ticker_data_dict[ticker]
        ticker_strategy_dict[ticker] = initial_ticker_strategy_dict[ticker]
    return ticker_data_dict, ticker_strategy_dict, tickers
