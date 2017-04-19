import numpy as np 
import mytools as mt
import math
from laserBox import BoundingBox, BBoxHandler
from matplotlib.patches import Rectangle

"""
This class gets the laser scanner points for each scan , it clusters them regarding thir proximity on the plane and tracks them (track-of-clusters).
Depending on the clusters and their resulting tracks, it creates a set of <BoundingBox>es and initializes a <BBoxHandler>.
"""
class AutoScannerAnnotator(object):

    def __init__(self, points, radius):
        self.points = points        #the raw data points -> lisstOf<LaserAnnotation>
        self.myradius = radius

        self.clusters = BBoxHandler()
        self.clusterId = 0          #given id to each new track - increment
        
        self.prev_clusters = PreviousClusterHandler()

        #arguments for the clustering
        self.eps = 0.5              #the maximum distance between the points
        self.num_c = 3              #the minimum mum of points that a cluster can be composed
        
        
    #Applies a cluster technique (DBSCAN) for each scan
    def cluster_procedure(self):
        cl_array = []

        try:
            for i,scan in enumerate(self.points):
                if len(scan) < self.num_c:
                    continue

                Eps, cluster_labels= mt.dbscan(scan, self.num_c, eps=self.eps)
                max_label=int(np.amax(cluster_labels))      #(-1 is for outliers)

                #for every cluster/label (-> denotes a new cluster) 
                for k in range(1,max_label+1) :
                    filter = np.where(cluster_labels==k)

                    if len(filter) == 0:
                        continue

                    #get the x,y points of the specific cluster and create a <ScanCluster> instance
                    if (len(filter[0]) >= self.num_c):
                        x_ = zip(*scan)[0]
                        xCl = np.array(x_)[filter]

                        y_ = zip(*scan)[1]
                        yCl = np.array(y_)[filter]

                        cluster_ = ScanCluster(xCl, yCl, i)
                        cl_array.append(cluster_)

                if not (len(cl_array) == 0):
                    self.combine_clusters(cl_array)
                    cl_array = []

            print 'total number of clusters = ',len(self.clusters.boxes)

            return self.clusters
        except Exception as ex:
            print 'Exception in cluster procedure ',ex
            raise ex


    def combine_clusters(self, cluster_array):
        firstCluster = False

        try:
            if self.clusters.empty() == True:
                firstCluster = True

            for cl in cluster_array:
                bbox = self.define_rectangle(cl)    #define a <BoundingBox> for each cluster

                #If it is the first cluster of the bag file, specify an id. 
                if firstCluster == True:
                    bbox.uId = self.clusterId
                    self.clusterId = self.clusterId + 1

                self.clusters.append(bbox)

            #For the next times (otherwise), specify the track for each cluster
            if firstCluster == False:
                self.set_cluster_params()

        except Exception as ex:
            print 'Exception in combination of clusters ',ex
            raise ex

    #Make an <BoundingBox> instance by creating a <Rectangle>. The params of the Rectangle are specified from the laser pointsd that belong to this cluster
    def define_rectangle(self, cluster):

        try:
            xmin = np.amin(cluster.pointsX)
            xmax = np.amax(cluster.pointsX)
            ymin = np.amin(cluster.pointsY)
            ymax = np.amax(cluster.pointsY)

            w = abs(xmax-xmin)+2*self.myradius 
            h = abs(ymax-ymin)+2*self.myradius

            current_rect = Rectangle( (xmin-self.myradius , ymin-self.myradius), width=w, height=h, fill=True, edgecolor='black', facecolor=(0.7,0.7,0.7,0.2))

            bbox = BoundingBox(current_rect)


            bbox.frameCount = cluster.frameCount

            bbox.data = cluster.setOfPoints()

            return bbox
        except Exception as ex:
            print 'Exception in defining a rectangle ',ex
            raise ex

    #Decides in which track-of-clusters every new cluster will enter.
    def set_cluster_params(self):
        try:
            frameCount = self.clusters.boxes[len(self.clusters.boxes)-1].frameCount

            new_clusters = self.clusters.getByFrame(frameCount)
            old_clusters = self.clusters.getByFrame((frameCount-1))  

            if old_clusters == None:
                self.define_cid(new_clusters)
                return 

            rows = len(new_clusters)
            cols = len(old_clusters)


            dist_array = np.full((rows, cols), float("inf"))  #rows=num of new clusters, cols=num of old clusters, value=distance of the medians

            for i,newCl in enumerate(new_clusters):
                for j,oldCl in enumerate(old_clusters):
                    dist_array[i][j] = self.distance(newCl, oldCl)

            self.prev_clusters.add_scan()

            #foreach new cluster
            for r in range(0, rows):
                #situation where a new cluster-track appeared
                if (np.all(dist_array[:, :] == float("inf")) == True):
                    self.define_cid(new_clusters)
                    break

                #get the index of the minimum value along a 2D array
                i,j = np.unravel_index(dist_array.argmin(), dist_array.shape)

                new_clusters[i].uId = old_clusters[j].uId
                new_clusters[i].condition = old_clusters[j].condition

                #increased or equal number of clusters compared to the previous clusters
                if rows >= cols:
                    dist_array[i, :] = float("inf") #inf to the row
                
                dist_array[:, j] = float("inf") #inf to the column

            #there are less clusters in this round-scan than the previous one
            if cols > rows:
                for j in range(0, cols):
                    if (np.all(dist_array[: , j] == float("inf")) == False):
                        self.prev_clusters.update(old_clusters[j])
           

        except Exception as ex:
            print 'Exception in setting cluster params ',ex
            raise ex

    #Gives a track id to a new cluster. It checks if it belongs to a track-of-clusters of a previous scan
    def define_cid(self, new_clusters):
        for cl in new_clusters:
            if cl.uId == -1:
                cid = self.prev_clusters.find_cluster(cl)

                if cid == -1:
                    cl.uId = self.clusterId
                    self.clusterId = self.clusterId + 1
                else:
                    cl.uId = cid

    #Computes the distance of two clusters
    #Use of Euclidean Distance between the median point of each cluster
    def distance(self, newCluster, oldCluster):
        try:
            #sort the lists of points first by x-coord and then by y-coord
            newCl = sorted(newCluster.data, key=lambda k: (k[0], k[1])) 
            oldCl = sorted(oldCluster.data, key=lambda k: (k[0], k[1]))

            #get the median point as a numpy array and comoute their euclidean distance
            newMedian = np.array(newCl[int(len(newCl)/2)])
            oldMedian = np.array(oldCl[int(len(oldCl)/2)])

            euclidean_dist = np.linalg.norm(newMedian-oldMedian)
            
            return euclidean_dist
            
        except Exception as ex:
            print 'Exception in the computation of the euclidean distance ',ex
            raise ex

#Representation of the points that belong to a cluster
class ScanCluster:
    def __init__(self, pointsX_=None, pointsY_=None, frameCount=0):
        if pointsX_ is None:
            self.pointsX = []
        else:
            self.pointsX = pointsX_

        if pointsY_ is None:
            self.pointsY = pointsY_

        else:
            self.pointsY = pointsY_

        self.frameCount = frameCount

    def setOfPoints(self):
        myset = zip( (x for x in self.pointsX),(y for y in self.pointsY) )

        return myset


#######################################################
"""
This class represents the clusters of some previous scans, that are not displayed in a few scans later.
If a new cluster is appeared a few scans later, it may belong to the same track-of-clusters.
Main Idea: Avoid of losing some scans or points in a scan or an object which is hidden for some scans.
"""
class PreviousClusterHandler:
    
    def __init__(self, ):
        self.clusters = []
        self.num_times = 50

    
    #Check if the cluster with the specific id exists already. If it exists update it, otherwise add it to the list
    # - cluster: <BoundingBox>
    def update(self, cluster):
        if (len(self.clusters) == 0) or (self.cluster_exists(cluster.uId) == False):
            prev_cl = PreviousCluster(cluster.uId)
            prev_cl.median = self.compute_median(cluster.data)

            self.clusters.append(prev_cl)
        else:
            prev_cl = self.get_cluster(cluster.uId)
            prev_cl.times = prev_cl.times + 1

    #Add a single scan each time. The track-of-clusters is not remained until num_times<>
    def add_scan(self):
        for cl in self.clusters:
            if cl.times > self.num_times:
                self.clusters.remove(cl)
            else:
                cl.times = cl.times + 1

    def cluster_exists(self, cid):
        for cl in self.clusters:
            if cl.id == cid:
                return True

        return False

    #Return the track-of-cluster
    def get_cluster(self, cid):
        for cl in self.clusters:
            if cl.id == cid:
                return cl

        return None

    #Define the track-of-clusters where the current cluster belong to. 
    def find_cluster(self, cluster):
        med = self.compute_median(cluster.data)
        minDist = float("inf")
        index = -1

        for i, cl in enumerate(self.clusters):
            curDistance = self.compute_distance(med, cl.median)

            if minDist > curDistance:
                minDist = curDistance
                index = i

        if index == -1:
            return -1

        minCluster = self.clusters[index]
        del self.clusters[index]

        return minCluster.id


    def compute_median(self, points):
        data = sorted(points, key=lambda k: (k[0], k[1])) 
        median = np.array(data[int(len(data)/2)])

        return median

    #euclidean distance
    def compute_distance(self, median1, median2):
        return np.linalg.norm(median1-median2)

#Just a class for storage and better representation
class PreviousCluster:
    def __init__(self, id_):
        self.id = id_
        self.times = 0
        self.median = None

   

