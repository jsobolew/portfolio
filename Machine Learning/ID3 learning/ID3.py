import pandas as pd
import numpy as np
from statistics import mode

class ID3:
    def __init__(self, max_depth = 100):
        self.max_depth = max_depth

    def predict(self, X):
        pred = []
        X = X.reset_index(drop=True)
        for i in range(len(X)):
            pred.append(self.node.classify(X.iloc[i]))
        return pred

    def fit(self, U, y):
        assert len(U) == len(y), f"X and y must be same length X: {len(U)}, y: {len(y)}"
        self.node = self.__id3(U, y, self.max_depth)

    def __id3(self, U, y, max_depth):
        if len(np.unique(y)) == 1:
            return Leaf(np.unique(y)[0])
        if len(U.columns) == 0 or max_depth == 0:
            return Leaf(mode(y))

        dfInfGain = pd.DataFrame(columns=["column", "InfGain"])
        for col in U.columns:
            dfInfGain = pd.concat([dfInfGain, pd.DataFrame(data={"column": [col], "InfGain": [self.__InfGain(col, U, y)]})])
            
        d = dfInfGain['column'].iloc[np.argmax(dfInfGain['InfGain'])]
        return Node(d,{unique_val: self.__id3(U.drop(columns=d)[U[d] == unique_val].copy(), y[U[d] == unique_val], max_depth - 1) for unique_val in U[d].unique()})

    def __I(self, U):
        U = U.tolist()
        freq_list = []
        I = 0

        for c in set(U):
            freq_list.append(U.count(c)/len(U))

        for i in range(len(freq_list)):
            I -= freq_list[i]*np.log(freq_list[i])
        return I

    def __Inf(self, d, U, y):
        inf = 0

        
        for i in range(len(U[d].unique())):
            inf += U[d].value_counts().values[i]/len(U) * self.__I(y[U[d] == U[d].unique()[i]])

        return inf

    def __InfGain(self, d, U, y):
        return self.__I(y) - self.__Inf(d,U, y)

class Leaf:
    def __init__(self, class_):
        self.class_ = class_

    def classify(self, sample):
        return self.class_

class Node:
    def __init__(self, attribute, children):
        self.attribute = attribute
        self.children = children

    def classify(self, sample):
        if sample[self.attribute] in self.children:
            return self.children[sample[self.attribute]].classify(sample)
        else:
            classes = [child.classify(sample)
                       for child in self.children.values()]
            return mode(classes)