#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import itertools
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from PyQt5.QtWidgets import QSizePolicy

annotationColors = ['#00FF00', '#FF00FF','#FFFF00','#00FFFF','#FFA500','#C0C0C0','#000000','#EAEAEA']
global classLabels
global highLabels

def parseJson():
    json_basicLabel = []
    json_highLabel = []

    with open("labels.json") as json_file:
            json_data = json.load(json_file)
            json_label = []
            for i in json_data['basiclabels'] :
                json_basicLabel.append(i)
            for j in json_data['highlevellabels']:
                json_highLabel.append(j)
    return json_basicLabel,json_highLabel

class videoGantChart(FigureCanvas):
    def __init__(self, parent=None,width=15,height=1,dpi=100):
        global classLabels
        global highLabels
        gantChart = Figure(figsize=(width, height), dpi=dpi)
        self.axes = gantChart.add_subplot(111)

        self.drawChart([], None)
        classLabels, highLabels = parseJson()
        
        FigureCanvas.__init__(self, gantChart)
        self.setParent(parent)

        FigureCanvas.setSizePolicy(self, QSizePolicy.Expanding, QSizePolicy.Expanding)
        FigureCanvas.updateGeometry(self)

    def drawChart(self):
        pass

#Class for the gantChart
class gantShow(videoGantChart):
    #Plot the chart
    def drawChart(self, videobox, framerate):
        global classLabels
        global highLabels
        temp_action = []
        self.timeWithId = []
        self.tickY = []
        self.tickX = []
        self.boxAtYaxes = []
        self.axes.hlines(0,0,0)

        for frame_index in videobox:
            for boxIdx in frame_index.box_Id:
                if boxIdx > frame_index.box_Id[-1]:
                    break
                for allactions in frame_index.annotation[boxIdx]:
                    if isinstance(allactions, list):
                        for action in allactions:
                            self.boxAtYaxes.append([boxIdx,action])
                            self.timeWithId.append([boxIdx,frame_index.timestamp[frame_index.box_Id.index(boxIdx)],action])
                    else:
                        self.boxAtYaxes.append([boxIdx,allactions])
                        self.timeWithId.append([boxIdx,frame_index.timestamp[frame_index.box_Id.index(boxIdx)],frame_index.annotation[frame_index.box_Id.index(boxIdx)]])
        #Remove duplicates and sort the Y axes
        self.boxAtYaxes.sort()
        self.boxAtYaxes = list(k for k,_ in itertools.groupby(self.boxAtYaxes))

        for key in range(len(self.boxAtYaxes)):
            self.tickY.append(key)
        for index in range(len(self.timeWithId)):
            for action in self.timeWithId[index][2]:
                self.startTime,self.endTime = self.timeCalc(self.timeWithId,index,action)
                if self.timeWithId[index][1] == self.endTime:
                    self.color = self.getColor(action)
                    self.axes.hlines(self.boxAtYaxes.index([self.timeWithId[index][0],action]), self.startTime,self.endTime+(1/framerate),linewidth=8,color=self.color)
                else:
                    self.color = self.getColor(action)
                    self.axes.hlines(self.boxAtYaxes.index([self.timeWithId[index][0],action]), self.startTime,self.endTime,linewidth=8,color=self.color)

        for tick in self.axes.yaxis.get_major_ticks():
            tick.label.set_fontsize(9)

        self.axes.set_xticklabels([])
        self.axes.set_yticks(self.tickY)
        self.axes.set_ylim([-1,len(self.boxAtYaxes)])
        self.axes.set_yticklabels(['<'+str(index[0])+'>::'+index[1] for index in self.boxAtYaxes])
        self.axes.grid(True)

    #Calculates the end time for each annotation to plot
    def timeCalc(self,time,curr,activity):
        temp_id = time[curr][0]
        startTime = time[curr][1]
        endTime = time[curr][1]
        while activity in time[curr][2] and temp_id in time[curr]:
            endTime = time[curr][1]
            curr += 1
            if curr > len(time)-1:
                break
        return startTime,endTime

    #Calculates the color for the gantChart and bound Boxes
    def getColor(self, label):
        global classLabels
        global highLabels
        if label == 'Clear':
                #color = 'Clear'
            return '#0000FF'
        elif label in classLabels:
                #color = label
            return annotationColors[classLabels.index(label) % len(classLabels)]
        elif label in highLabels:
            return eventColors[highLabels.index(label) % len(highLabels)]
