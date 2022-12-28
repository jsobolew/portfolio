import numpy as np

def predictive_LMS_1D(x, N = 5, alpha = 0.0001):
    ff = np.zeros(shape=(len(x),5),dtype=float)
    y = np.zeros(shape=(len(x)-N), dtype=float)
    loss = np.zeros(shape=(len(x)-N), dtype=float)
    d_loss = np.zeros(shape=(len(x)-N), dtype=float)

    for i in range(len(x)-N-1):
        curr_x = x[i:i+N]
        y[i] = np.matmul(ff[i],curr_x)
        loss[i] = np.sqrt((y[i]-x[i+N+1])**2)
        d_loss[i] = y[i] - x[i+N+1]
        ff[i+1] = ff[i] - alpha*d_loss[i]*curr_x
    return y, loss, d_loss, ff