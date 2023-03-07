import numpy as np
from dataclasses import dataclass
import matplotlib.pyplot as plt
from sklearn import metrics

# Assumptions:
# label = 0 -> undefined
# label = -1 -> noise

@dataclass
class Point:
    location: np.array
    label: int

def evaluate(labels, labels_true, X, visualize):
    # Number of clusters in labels, ignoring noise if present.
    n_clusters_ = len(set(labels)) - (1 if -1 in labels else 0)
    n_noise_ = list(labels).count(-1)

    print("Estimated number of clusters: %d" % n_clusters_)
    print("Estimated number of noise points: %d" % n_noise_)
    print("Homogeneity: %0.3f" % metrics.homogeneity_score(labels_true, labels))
    print("Completeness: %0.3f" % metrics.completeness_score(labels_true, labels))
    print("V-measure: %0.3f" % metrics.v_measure_score(labels_true, labels))
    print("Adjusted Rand Index: %0.3f" % metrics.adjusted_rand_score(labels_true, labels))
    print(
        "Adjusted Mutual Information: %0.3f"
        % metrics.adjusted_mutual_info_score(labels_true, labels)
    )
    print("Silhouette Coefficient: %0.3f" % metrics.silhouette_score(X, labels))

    if visualize:
        unique_labels = np.unique(labels)
        for ul in unique_labels:
            plt.plot(X[labels==ul,0],X[labels==ul,1],'.')

def numpyToPoints(X):
    Points = []
    for i in range(len(X)):
        Points.append(Point(X[i], 0))
    return Points

class DBSCAN:
    def __init__(self, eps, minPts) -> None:
        self.eps = eps
        self.minPts = minPts
        self.distFunc = self.euclideanDist
        self.labels = []

    def RangeQuery(self, Points, p):
        inRange = []
        for point in Points:
            if self.distFunc(p, point) < self.eps:
                inRange.append(point)
        return inRange

    def euclideanDist(self, p1:Point, p2:Point):
        return np.sqrt(np.sum(np.power(p1.location-p2.location,2)))#np.sqrt((p1.x - p2.x)**2 + (p1.y - p2.y)**2)

    def fit(self, Points):
        C = 0
        for i, p in enumerate(Points):
            if p.label != 0:
                continue
            neighbors = self.RangeQuery(Points, p)
            if len(neighbors) < self.minPts:
                p.label = -1
                continue
            C += 1
            p.label = C
            for n in neighbors:
                if n.label == -1:
                    n.label = C
                if n.label != 0:
                    continue
                n.label = C
                newNeighbors = self.RangeQuery(Points, n)
                if len(newNeighbors) > self.minPts:
                    neighbors.extend(newNeighbors)
        for _, p in enumerate(Points):
            self.labels.append(p.label)

def HDBSCAN(X, threshold):
    xydists = np.array([np.array([x for _ in range(len(X))]) - X for x in X])
    dists = np.sqrt(xydists[:,:,0]**2 + xydists[:,:,1]**2)
    Npoints = len(dists)
    max_dist = np.max(dists)
    dists[np.triu_indices(Npoints)] = max_dist

    mindist = [0]
    mindistPts = []

    plt.plot(X[:,0],X[:,1],'o')

    i = 0
    while mindist[-1] < threshold and i<dists.size:
        minidx = np.argmin(dists)
        row = minidx // Npoints
        col = minidx % Npoints
        mindist.append(dists[row,col])
        mindistPts.append([row, col])
        dists[row,col] = max_dist
        plt.plot(X[row,0],X[row,1],'or')
        plt.plot(X[col,0],X[col,1],'or')
        plt.plot([X[row,0],X[col,0]],[X[row,1],X[col,1]], 'b')
        i += 1
    plt.show()