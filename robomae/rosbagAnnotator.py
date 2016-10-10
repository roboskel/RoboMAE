#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import csv
import yaml
import cv2
import os
import rosbag
import argparse
import textwrap
import rospy
import json
import random
import matplotlib
import math
import time

matplotlib.use("Qt5Agg")
import matplotlib.pyplot as plt

from sensor_msgs.msg import Image
from sensor_msgs.msg import CompressedImage
from cv_bridge import CvBridge, CvBridgeError

import sys
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtMultimedia import *
from PyQt5.QtMultimediaWidgets import *
import warnings
import itertools
from termcolor import colored
import numpy as np
from numpy import arange, sin, pi

import matplotlib.transforms as transforms
from matplotlib.widgets import Cursor
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from matplotlib.collections import LineCollection
from matplotlib.colors import ListedColormap, BoundaryNorm

#QT imports
from PyQt5 import QtCore, QtWidgets, QtGui
from PyQt5.QtGui import QFont, QPainter
from PyQt5.QtCore import Qt, QUrl, pyqtSignal, QFile, QIODevice, QObject, QRect
from PyQt5.QtMultimedia import (QMediaContent,
        QMediaMetaData, QMediaPlayer, QMediaPlaylist, QAudioOutput, QAudioFormat)
from PyQt5.QtWidgets import (QApplication, QComboBox, QHBoxLayout, QPushButton,
        QSizePolicy, QVBoxLayout, QWidget, QToolTip, QLabel, QFrame, QGridLayout, QMenu, qApp, QLineEdit)

#Module imports
from audio import rosbagAudio
from audio import visualizeAudio as vA
from audio import ganttChartAudio as gA
from audio import saveAudioSegments
from audio.audioGlobals import audioGlobals
from audio.graphicalInterfaceAudio import ApplicationWindow

from video import rosbagDepth
from video import rosbagRGB
from video import rosbagVideo
from video import videoGantChart

from laser import laserGlobals
from laser import rosbagLaser
from laser import graphicalInterfaceLaser as gL
''''''''''''''''''''''''''''''''''''

from gui import rosbagGui

global bagFile
global csvFile
global frameCounter
global boxInitialized
global annotationColors
global eventColors
global posSlider
global xBoxCoord
global BasicTopics
global classLabels
global highLabels

bagFile = None
csvFile = None
frameCounter = 0
boxInitialized = False
annotationColors = ['#00FF00', '#FF00FF','#FFFF00','#00FFFF','#FFA500','#C0C0C0','#000000','#EAEAEA']
eventColors = ['#9fbf1f','#087649','#0a5b75','#181a8d','#7969b0','#76a9ea','#bef36e','#edfa84','#f18ed2','#753e20']
posSlider = 0
xBoxCoord = []
classLabels = []
highLabels = []
#Declare the basic topics for the topic box


depthFileName = None
rgbFileName = None


def get_bag_metadata(bag):
    topics_list = []
    info_dict = yaml.load(bag._get_yaml_info())
    topics =  info_dict['topics']
    
    for top in topics:
        #print "\t- ", top["topic"], "\n\t\t-Type: ", top["type"],"\n\t\t-Fps: ", top["frequency"]
        topics_list.append(top["topic"])
    topics_list = sorted(set(topics_list))
    duration = info_dict['duration']
    return topics_list, duration
    

class VideoWidgetSurface(QAbstractVideoSurface):

    def __init__(self, widget, parent=None):
        super(VideoWidgetSurface, self).__init__(parent)
        self.widget = widget
        self.imageFormat = QImage.Format_Invalid

    def supportedPixelFormats(self, handleType=QAbstractVideoBuffer.NoHandle):
        formats = [QVideoFrame.PixelFormat()]
        if (handleType == QAbstractVideoBuffer.NoHandle):
            for f in [QVideoFrame.Format_RGB32, QVideoFrame.Format_ARGB32, QVideoFrame.Format_ARGB32_Premultiplied, QVideoFrame.Format_RGB565, QVideoFrame.Format_RGB555,QVideoFrame.Format_BGR24,QVideoFrame.Format_RGB24]:
                formats.append(f)
        return formats

    def isFormatSupported(self, _format):
        imageFormat = QVideoFrame.imageFormatFromPixelFormat(_format.pixelFormat())
        size = _format.frameSize()
        _bool = False
        if (imageFormat != QImage.Format_Invalid and not size.isEmpty() and _format.handleType() == QAbstractVideoBuffer.NoHandle):
            _bool = True
        return _bool

    def start(self, _format):
        imageFormat = QVideoFrame.imageFormatFromPixelFormat(_format.pixelFormat())
        size = _format.frameSize()
        #frameCounter = 0 #Frame Counter initialize
        if (imageFormat != QImage.Format_Invalid and not size.isEmpty()):
            self.imageFormat = imageFormat
            self.imageSize = size
            self.sourceRect = _format.viewport()
            QAbstractVideoSurface.start(self, _format)
            self.widget.updateGeometry()
            self.updateVideoRect()
            return True
        else:
            return False

    def stop(self):
        self.currentFrame = QVideoFrame()
        self.targetRect = QRect()
        QAbstractVideoSurface.stop(self)

        self.widget.update()

    def present(self, frame):
        global frameCounter
        global removeBool
        if (self.surfaceFormat().pixelFormat() != frame.pixelFormat() or self.surfaceFormat().frameSize() != frame.size()):
            self.setError(QAbstractVideoSurface.IncorrectFormatError)
            self.stop()
            return False
        else:
            
            frameCounter += 1
            self.currentFrame = frame
            removeBool = True #Removes the boxes on current frame
            self.widget.repaint(self.targetRect)
            return True

    def videoRect(self):
        return self.targetRect

    def updateVideoRect(self):
        size = self.surfaceFormat().sizeHint()
        size.scale(self.widget.size().boundedTo(size), Qt.KeepAspectRatio)
        self.targetRect = QRect(QPoint(0, 0), size);
        self.targetRect.moveCenter(self.widget.rect().center())
    
    def paint(self, painter):
        if (self.currentFrame.map(QAbstractVideoBuffer.ReadOnly)):
            oldTransform = painter.transform()
            if (self.surfaceFormat().scanLineDirection() == QVideoSurfaceFormat.BottomToTop):
                painter.scale(1, -1);
                painter.translate(0, -self.widget.height())

            image = QImage(self.currentFrame.bits(),
                    self.currentFrame.width(),
                    self.currentFrame.height(),
                    self.currentFrame.bytesPerLine(),
                    self.imageFormat
            )
            painter.drawImage(self.targetRect, image, self.sourceRect)
            painter.setTransform(oldTransform)
            self.currentFrame.unmap()
           
            
class VideoWidget(QWidget):

    def __init__(self, parent=None):
        global classLabels
        global highLabels
        super(VideoWidget, self).__init__(parent)
        self.setAutoFillBackground(False)
        self.setAttribute(Qt.WA_NoSystemBackground, True)
        self.setAttribute(Qt.WA_OpaquePaintEvent)
        palette = self.palette()
        palette.setColor(QPalette.Background, Qt.black)
        self.setPalette(palette)
        self.setSizePolicy(QSizePolicy.MinimumExpanding ,
        QSizePolicy.MinimumExpanding)
        self.surface = VideoWidgetSurface(self)
        self.vanishBox = False
        self.context_menu = False
        self.enableWriteBox = False
        self.annotEnabled = False
        self.annotClass = 'Clear'
        self.deleteEnabled = False
        self.buttonLabels = []
        self.addEventLabels = []
        self.stopEventLabels = []
        self.start_point = False
        self.end_point = False
        self.drag_start = None
        self.index = None
        self.moved = False
        

    def videoSurface(self):
        return self.surface

    #Shows the right click menu
    def contextMenuEvent(self, event):
        global classLabels
        global gantChart
        global highLabels
        global frameCounter
        global framerate
        
        self.stopEventEnabled = False
        self.addEventEnabled = False
        box_id = None
        if event.reason() == QContextMenuEvent.Mouse:
            self.context_menu = True
            posX = event.pos().x()
            posY = event.pos().y()
            
            menu = QMenu(self)
            clear = menu.addAction('Clear')

            for i in classLabels:
                self.buttonLabels.append(menu.addAction(i))

            deleteBox = menu.addAction('Delete Box')
            deleteAllBoxes = menu.addAction('Delete All Boxes')
            addEvent = menu.addMenu('Add Event')
            stopEvent = menu.addMenu('Stop Event')
            #Initiate add Event menu
            for label in highLabels:
                self.addEventLabels.append(addEvent.addAction(label))
            changeId = menu.addAction('Change Id')
            
            index = -1
            stopEvent.setEnabled(False)
            for i in range(len(player.videobox[frameCounter].box_id)):
                self.addEventLabels = []
                self.stopEventLabels = []
                self.checkStopEventMenu = []
                self.stopEventEnabled = False
                x,y,w,h = player.videobox[frameCounter].box_Param[i]
                if posX > x and posX < (x+w) and posY > y and posY < (y+h):
                    index = i
                    
            if index != -1:             
                box_id = player.videobox[frameCounter].box_id.index(index)
                #Show only annotated high classes of the box
                if len(player.videobox[frameCounter].annotation) > 0:
                    for annot in player.videobox[frameCounter].annotation[box_id]:
                        if annot in highLabels and annot not in self.checkStopEventMenu:
                            self.checkStopEventMenu.append(annot)
                            self.stopEventLabels.append(stopEvent.addAction(annot))
                            stopEvent.setEnabled(True)
                action = menu.exec_(self.mapToGlobal(event.pos()))

                #Check which submenu clicked
                if action is not None:
                    if action.parent() == addEvent:
                        self.addEventEnabled = True
                    elif action.parent() == stopEvent:
                        self.stopEventEnabled = True

                if self.addEventEnabled:
                    for i, key in enumerate(self.addEventLabels):
                        if action == key:
                            self.annotClass = highLabels[i]
                            self.annotEnabled = True
                            self.addEventEnabled = False

                elif self.stopEventEnabled:
                    for i, key in enumerate(self.stopEventLabels):
                        if action == key:
                            player.videobox[frameCounter].removeEvent(box_id,self.stopEventLabels[i].text() )
                            self.stopEventEnabled = False

                for i,key in enumerate(self.buttonLabels):
                    if action == key:
                        self.annotClass = classLabels[i]
                        self.annotEnabled = True
                if action == deleteBox:
                    player.videobox[frameCounter].removeSpecBox(player.videobox[frameCounter].box_id[index])
                elif action ==  deleteAllBoxes:
                    player.videobox[frameCounter].removeAllBox()
                elif action == changeId:
                    #Call the textbox
                    self.newBoxId = rosbagGui.textBox(player.videobox, posX, posY, frameCounter, gantChart, framerate)
                    self.newBoxId.setGeometry(QRect(500, 100, 300, 100))
                    self.newBoxId.show()
                elif action == clear:
                    self.annotClass = 'Clear'
                    self.annotEnabled = True
                
                if self.annotEnabled:
                    for counter in range(frameCounter, len(player.videobox)):
                        if box_id in player.videobox[counter].box_id:
                            player.videobox[counter].changeClass(box_id, str(self.annotClass))
                        counter += 1
                    self.annotEnabled = False
                        
                self.repaint()
                gantChart.axes.clear()
                gantChart.drawChart(player.videobox, framerate)
                gantChart.draw()
            
            self.buttonLabels = []
            self.context_menu = False
            
    def sizeHint(self):
        return self.surface.surfaceFormat().sizeHint()

    #Shows the video and bound boxes on it
    def paintEvent(self, event):
        global frameCounter
        global timeId

        painter = QPainter(self)
        rectPainter = QPainter(self)
        boxIdPainter = QPainter()

        if not rectPainter.isActive():
            rectPainter.begin(self)

        if (self.surface.isActive()):
            videoRect = QRegion(self.surface.videoRect())
            if not videoRect.contains(event.rect()):
                region = event.region()
                region.subtracted(videoRect)
                brush = self.palette().background()
                for rect in region.rects():
                    painter.fillRect(rect, brush)
            self.surface.paint(painter)
        else:
            painter.fillRect(event.rect(), self.palette().window())
        
        
        if len(player.videobox) > 0 and frameCounter < len(player.time_buff):
            for i in range(len(player.videobox[frameCounter].box_id)):
                if player.videobox[frameCounter].box_id != -1:
                    x,y,w,h = player.videobox[frameCounter].box_Param[i]
                    if not rectPainter.isActive():
                        rectPainter.begin(self)    
                    rectPainter.setRenderHint(QPainter.Antialiasing)    
                    rectPainter.setPen(QColor(self.getColorBox(player.videobox[frameCounter].annotation[i])))
                    rectPainter.drawRect(x,y,w,h)
                    rectPainter.end()

                    if not boxIdPainter.isActive():
                        boxIdPainter.begin(self)
                    boxIdPainter.setPen(QColor(255,0,0))
                    boxIdPainter.drawText(QRectF(x+2,y,w,h),Qt.AlignLeft,str(player.videobox[frameCounter].box_id[i]))
                    boxIdPainter.end()

        if rectPainter.isActive():
            rectPainter.end()
        
    #Mouse callback handling Boxes
    def mousePressEvent(self,event):
        
        if QMouseEvent.button(event) == Qt.LeftButton and self.context_menu is False:
			#Check the mouse event is inside a box to initiate drag n drop
            for i in range(len(player.videobox[frameCounter].box_id)):
                x,y,w,h = player.videobox[frameCounter].box_Param[i]
                if (event.pos().x() >= x) and (event.pos().x() <= x + w) and (event.pos().y() >= y) and (event.pos().y() <= y + h):
                    self.index = i
                    self.drag_start = (event.pos().x(), event.pos().y())
                    break
            if self.start_point is False:
                QPoint.pos1 = QMouseEvent.pos(event)
                self.start_point = True
            elif self.end_point is False:
                QPoint.pos2 = QMouseEvent.pos(event)
                rect = QRect(QPoint.pos1, QPoint.pos2)
                self.end_point = True
                if len(player.videobox[frameCounter].timestamp) > 0:
                    timeId = player.videobox[frameCounter].timestamp[0]
                else:
                    timeId = player.time_buff[frameCounter]
                x = QPoint.pos1.x()
                y = QPoint.pos1.y()
                w = QPoint.pos2.x() - QPoint.pos1.x()
                h = QPoint.pos2.y() - QPoint.pos1.y()
                boxNumber = -1
                #If id already in the list then give the next id
                for i in range(len(player.videobox[frameCounter].box_id)):
                    if(i != player.videobox[frameCounter].box_id[i]):
                        boxNumber = i

                if boxNumber == -1:
                    boxNumber = len(player.videobox[frameCounter].box_id)
                player.videobox[frameCounter].addBox(timeId, [boxNumber,x,y,w,h], ['Clear'])
                self.repaint()
                
                self.start_point = False
                self.end_point = False
    
    def mouseMoveEvent(self, event):
		if event.buttons() == QtCore.Qt.LeftButton:
			rect = QRect(QPoint.pos1, QMouseEvent.pos(event))
			self.repaint(rect)
			self.moved = True
		self.start_point = False
		self.end_point = False
        
    def mouseReleaseEvent(self, event):
		if QMouseEvent.button(event) == Qt.LeftButton:
			if self.moved and self.index is not None:
				x,y,w,h =  player.videobox[frameCounter].box_Param[self.index]
				st_x, st_y = self.drag_start
				player.videobox[frameCounter].box_Param[self.index] =  event.pos().x() - (st_x - x), event.pos().y() - (st_y - y), w, h
				self.repaint()
		self.moved = False
		self.drag_start = None
		self.index = None
        
    def resizeEvent(self, event):
        QWidget.resizeEvent(self, event)
        self.surface.updateVideoRect()

    def getColorBox(self,action):
        global classLabels
        global highLabels
        for label in action:
            if label in classLabels:
                color = label
                return annotationColors[classLabels.index(label) % len(annotationColors)]
            elif label == 'Clear':
                color = 'Clear'
                return '#0000FF'
            elif label in highLabels:
                pass

        if action in classLabels:
            for index,key in enumerate(classLabels):
                if action == key:
                    return annotationColors[index % len(annotationColors)]
                elif action == 'Clear':
                    return '#0000FF'
        else:
            for index,key in enumerate(player.videobox[frameCounter].annotation):
                if key in classLabels:
                    return annotationColors[classLabels.index(key) % len(annotationColors)]
                elif key == 'Clear':
                    return '#0000FF'


class VideoPlayer(QWidget):
    
    def __init__(self, parent=None):
        global gantChart
        global Topics
        global classLabels
        global highLabels
        super(VideoPlayer, self).__init__(parent)
        self.mediaPlayer = QMediaPlayer(None, QMediaPlayer.VideoSurface)
        
        #Parse json file
        classLabels, highLabels = self.parseJson()
        
        Topics              = None
        self.time_          = 0
        self.duration       = 0
        self.message_count  = 0
        self.videobox       = []
        self.box_buffer     = []
        self.metric_buffer  = []
        self.time_buff      = []

        self.topic_window = rosbagGui.TopicBox()
        
        # >> DEFINE WIDGETS OCJECTS
        # >> VIDEO - DEPTH - AUDIO - LASER - GANTT CHART
        #----------------------
        self.videoWidget = VideoWidget()
        self.laserScan = gL.LS()

        #Set Fix Size at Video Widget and LaserScan
        self.laserScan.setFixedSize(640, 480)
        self.videoWidget.setFixedSize(640, 480)

        #Video buttons
        videoLayout = self.createVideoButtons()
        
        #Video Gantt Chart
        self.gantt = videoGantChart.gantShow()
        gantChart = self.gantt
        gantChart.axes.get_xaxis().set_visible(False)
        gantChart.setFixedSize(1300, 90)
        
        #Create Slider
        self.createSlider()
        
        #Laser buttons
        scanLayout = QHBoxLayout()
        scanLayout.addWidget(self.laserScan)
        layoutLaser = self.createLaserButtons(scanLayout)
        
        self.controlEnabled = False

        #Specify video-laser layout align
        laserAndVideoLayout = QHBoxLayout()
        laserAndVideoLayout.addLayout(videoLayout)
        laserAndVideoLayout.addLayout(layoutLaser)

        #Audio Player buttons
        buttonLayoutAudio = self.createAudioButtons()
        waveLayout = self.createAudio()
        
        
        self.mainLayout = QVBoxLayout()
        self.mainLayout.addLayout(laserAndVideoLayout)
        self.mainLayout.addWidget(self.positionSlider)
        self.mainLayout.addWidget(self.gantt)
        self.mainLayout.addLayout(waveLayout)
        self.mainLayout.addLayout(buttonLayoutAudio)

        self.setLayout(self.mainLayout)

        self.mediaPlayer.setVideoOutput(self.videoWidget.videoSurface())
        self.mediaPlayer.stateChanged.connect(self.mediaStateChanged)
        self.mediaPlayer.positionChanged.connect(self.positionChanged)
        self.mediaPlayer.durationChanged.connect(self.durationChanged)

    def createSlider(self):
        self.positionSlider = QSlider(Qt.Horizontal)
        self.positionSlider.setMinimum(0)
        self.positionSlider.setMaximum(audioGlobals.duration)
        self.positionSlider.setTickInterval(1)
        self.positionSlider.sliderMoved.connect(self.setPosition)

        #add label to slider about elapsed time
        self.label_tmp = '<b><FONT SIZE=3>{}</b>'
        self.timelabel = QLabel(self.label_tmp.format('Time: ' + str(audioGlobals.duration)))


        self.label = QHBoxLayout()
        self.label.addWidget(self.timelabel)
        self.label.setAlignment(Qt.AlignRight)
        
    def createVideoButtons(self):
        
        verticalLine 	=  QFrame()
        verticalLine.setFrameStyle(QFrame.VLine)
        verticalLine.setSizePolicy(QSizePolicy.Minimum,QSizePolicy.Expanding)
        
        self.playButton = QPushButton()
        self.playButton.setEnabled(False)
        self.playButton.setIcon(self.style().standardIcon(QStyle.SP_MediaPlay))
        self.playButton.clicked.connect(self.play)

        # >> radio button for Depth or RGB
        #----------------------
        self.rgbButton = QRadioButton("RGB")
        self.rgbButton.setChecked(True)
        self.rgbButton.toggled.connect(self.rgbVideo)
        self.rgbButton.setEnabled(False)

        self.depthButton = QRadioButton("Depth")
        self.depthButton.toggled.connect(self.depth)
        self.depthButton.setEnabled(False)
        
        self.previousButton = QPushButton()
        self.previousButton.setIcon(self.style().standardIcon(QStyle.SP_MediaSeekBackward))
        self.previousButton.clicked.connect(self.previousFrame)
        self.nextButton = QPushButton()
        self.nextButton.setIcon(self.style().standardIcon(QStyle.SP_MediaSeekForward))
        self.nextButton.clicked.connect(self.nextFrame)
        
        
        
        
        
        self.controlLayout = QHBoxLayout()
        self.controlLayout.addWidget(self.playButton)
        self.controlLayout.addWidget(self.previousButton)
        self.controlLayout.addWidget(self.nextButton)
        self.controlLayout.addWidget(self.rgbButton)
        self.controlLayout.addWidget(self.depthButton)
        self.controlLayout.setAlignment(Qt.AlignLeft)
        videoLayout = QVBoxLayout()
        videoLayout.addWidget(self.videoWidget)
        videoLayout.addLayout(self.controlLayout)
        
        return videoLayout
        
    def pauseMedia(self):
        self.mediaPlayer.pause()
        self.Pause()

    #VIDEO SWITCH RGB <-> Depth
    def rgbVideo(self, enabled):
        global rgbFileName
        global frameCounter
        if enabled:
            self. depthEnable = False
            self.rgbEnable = True
            position = self.mediaPlayer.position()
            self.mediaPlayer.setMedia(QMediaContent(QUrl.fromLocalFile(os.path.abspath(rgbFileName))))
            self.mediaPlayer.setPosition(position)
            self.mediaPlayer.play()
            if self.topic_window.temp_topics[0][1] != 'Choose Topic':
                self.player.setPosition(position)
                self.audioPlay()
            if self.topic_window.temp_topics[3][1] != 'Choose Topic':
                self.laserPlay()
            self.playButton.setEnabled(True)

    def depth(self, enabled):
        global depthFileName
        global frameCounter

        if enabled:
            self.rgbEnable = False
            self.depthEnable = True
            position = self.mediaPlayer.position()
            if self.topic_window.temp_topics[1][1] != 'Choose Topic':
                self.mediaPlayer.setMedia(QMediaContent(QUrl.fromLocalFile(os.path.abspath(depthFileName))))
                self.mediaPlayer.setPosition(position)
                self.mediaPlayer.play()
            if self.topic_window.temp_topics[0][1] != 'Choose Topic':
                self.player.setPosition(position)
                self.audioPlay()
            if self.topic_window.temp_topics[3][1] != 'Choose Topic':
                self.laserPlay()
            self.playButton.setEnabled(True)
    
    def previousFrame(self):
        global frameCounter
        if frameCounter > 0:
            frameCounter -= 2
            pos = round(((frameCounter ) * (self.duration * 1000)) / self.message_count)
            self.mediaPlayer.setPosition(pos) 
        
    def nextFrame(self):
        global frameCounter
        if frameCounter < self.message_count:
            pos = round(((frameCounter ) * (self.duration * 1000)) / self.message_count)
            self.mediaPlayer.setPosition(pos) 
        
    # AUDIO PLAYER BUTTON FUNCTIONS
    def createAudio(self):
        #Define Audio annotations and gantt chart
        self.wave = vA.Waveform()
        audioGlobals.fig = self.wave
        self.wave.axes.get_xaxis().set_visible(False)
        self.wave.draw()
        self.wave.setFixedSize(1300, 175)
        
        self.chart = gA.Chart()
        audioGlobals.chartFig = self.chart
        self.chart.setFixedSize(1300, 90)
        
        #Audio layouts
        waveLayout = QVBoxLayout()
        waveLayout.addWidget(self.wave)
        waveLayout.addWidget(self.chart)
        
        return waveLayout
        
    def createAudioButtons(self):
        playButtonAudio = QPushButton("Play")
        pauseButtonAudio = QPushButton("Pause")
        stopButtonAudio = QPushButton("Stop")

        playButtonAudio.clicked.connect(self.audioPlay)
        pauseButtonAudio.clicked.connect(self.audioPause)
        stopButtonAudio.clicked.connect(self.audioStop)
        
        playButtonAudio.setIcon(self.style().standardIcon(QStyle.SP_MediaPlay))
        pauseButtonAudio.setIcon(self.style().standardIcon(QStyle.SP_MediaPause))
        stopButtonAudio.setIcon(self.style().standardIcon(QStyle.SP_MediaStop))
        
        buttonLayoutAudio = QHBoxLayout()
        buttonLayoutAudio.addWidget(playButtonAudio)
        buttonLayoutAudio.addWidget(pauseButtonAudio)
        buttonLayoutAudio.addWidget(stopButtonAudio)
        buttonLayoutAudio.setAlignment(Qt.AlignLeft)
        
        return buttonLayoutAudio
       
    #Play audio (whole signal or segment)
    def audioPlay(self):

        #GET CLICKS FROM WAVEFORM
        #Initialize connection-position ONCE
        if not audioGlobals.playerStarted:
            #10ms for changePosition -> Not Delaying
            self.player.positionChanged.connect(self.checkPositionToStop)
            self.player.setNotifyInterval(10)
            if audioGlobals.durationFlag==0:
                audioGlobals.playerStarted = True
                audioGlobals.startTimeToPlay = 0
                self.start = audioGlobals.startTimeToPlay
                self.end = audioGlobals.duration*1000 - 10
                audioGlobals.endTimeToPlay = self.end
                audioGlobals.counterClick = 3
            elif audioGlobals.durationFlag==1:
                audioGlobals.playerStarted = True
                self.start = audioGlobals.startTimeToPlay
                self.end = audioGlobals.duration*1000 - 10
                audioGlobals.endTimeToPlay = self.end
                audioGlobals.counterClick = 3
            elif audioGlobals.durationFlag==2:
                audioGlobals.playerStarted = True
                self.start = audioGlobals.startTimeToPlay
                self.end = audioGlobals.endTimeToPlay
            self.player.setPosition(self.start)

        playFlag = True
        self.player.play()

    #Pause audio playing
    def audioPause(self):
        #Not begging from self.start
        audioGlobals.playerStarted = True
        self.player.setPosition(self.time_)
        self.player.pause()

    #Stop audio playing
    def audioStop(self):
        self.player.stop()
        #Begin again segment
        self.start = audioGlobals.startTimeToPlay
        self.player.setPosition(self.start)

    #Check ms in audio to stop play
    def checkPositionToStop(self):
        self.time_ = self.player.position()
        #self.positionSlider.setValue(self.time_/1000)
        if self.time_ >= self.end:
            self.audioStop()
            self.player.setPosition(self.start)
            #self.positionSlider.setValue(self.start)

    #LASER BUTTON FUNCTIONS
    def createLaserButtons(self, scanLayout):
        
        playButtonLaser      = QPushButton()
        stopButtonLaser      = QPushButton()
        pauseButtonLaser     = QPushButton()
        prevFrameButtonLaser = QPushButton()
        nextFrameButtonLaser = QPushButton()
        
        playButtonLaser.setIcon(self.style().standardIcon(QStyle.SP_MediaPlay))
        stopButtonLaser.setIcon(self.style().standardIcon(QStyle.SP_MediaStop))
        pauseButtonLaser.setIcon(self.style().standardIcon(QStyle.SP_MediaPause))
        prevFrameButtonLaser.setIcon(self.style().standardIcon(QStyle.SP_MediaSeekBackward))
        nextFrameButtonLaser.setIcon(self.style().standardIcon(QStyle.SP_MediaSeekForward))

        buttonLayoutLaser = QHBoxLayout()
        buttonLayoutLaser.addWidget(playButtonLaser)
        buttonLayoutLaser.addWidget(pauseButtonLaser)
        buttonLayoutLaser.addWidget(prevFrameButtonLaser)
        buttonLayoutLaser.addWidget(nextFrameButtonLaser)
        buttonLayoutLaser.addWidget(stopButtonLaser)
        buttonLayoutLaser.setAlignment(Qt.AlignLeft)


        #Define Connections
        playButtonLaser.clicked.connect(self.laserPlay)
        pauseButtonLaser.clicked.connect(self.laserPause)
        prevFrameButtonLaser.clicked.connect(self.laserPrevious)
        nextFrameButtonLaser.clicked.connect(self.laserNext)
        stopButtonLaser.clicked.connect(self.laserStop)
        
        self.controlLaser = QHBoxLayout()
        self.controlLaser.addLayout(buttonLayoutLaser)
        self.controlLaser.addLayout(self.label)
        
        
        laserClass = QHBoxLayout()
        laserClass.addLayout(scanLayout)

        layoutLaser = QVBoxLayout()
        layoutLaser.addLayout(laserClass)
        layoutLaser.addLayout(self.controlLaser)
        
        return layoutLaser
    
    def laserPlay(self):
        self.laserScan.ptime()
        laserGlobals.scan_widget = self.laserScan

    def laserPause(self):
        laserGlobals.timer.stop()

    def laserPrevious(self):
        if (laserGlobals.cnt>0):
            laserGlobals.cnt = laserGlobals.cnt-1
            laserGlobals.ok = 'Yes'
            laserGlobals.scan_widget.drawLaserScan()
        else:
            laserGlobals.ok = 'No'
            laserGlobals.scan_widget.drawLaserScan()

    def laserNext(self):
        colour_index = 0
        if (laserGlobals.cnt<len(laserGlobals.annot)):
            laserGlobals.cnt = laserGlobals.cnt+1
            laserGlobals.ok = 'Yes'
            laserGlobals.scan_widget.drawLaserScan()
        else:
            laserGlobals.ok = 'No'
            laserGlobals.scan_widget.drawLaserScan()

    def laserStop(self):
        laserGlobals.cnt = 0
        laserGlobals.timer.stop()
        self.laserScan.axes.clear()
        self.laserScan.draw()

    def videoPosition(self):
        self.videoTime = self.mediaPlayer.position()

    def openFile(self):
        global framerate
        global bagFile
        global depthFileName
        global rgbFileName
        global Topics
        global classLabels
        global highLabels
        start_time = None
               
        fileName, _ = QFileDialog.getOpenFileName(self, "Open Bag", QDir.currentPath(),"(*.bag)")
     
        
        # create a messsage box for get or load data info
        if fileName:
			bagFile = fileName
			try:
				bag = rosbag.Bag(fileName)
				Topics, self.duration = get_bag_metadata(bag)
				#Show window to select topics
				self.topic_window.show_topics(Topics)
			except:
				self.errorMessages(0)
			
			#Audio Handling
			if self.topic_window.temp_topics[0][1] != 'Choose Topic':
				try:
					audioGlobals.annotations = []
					rosbagAudio.runMain(bag, str(fileName))
				except:
					self.errorMessages(6)
			
			#Depth Handling
			if self.topic_window.temp_topics[1][1] != 'Choose Topic':
				depthFileName = fileName.replace(".bag","_DEPTH.avi")
				
				try:
					(self.message_count, compressed, framerate) = rosbagVideo.buffer_video_metadata(bag, self.topic_window.temp_topics[1][1])
					rosbagDepth.write_depth_video(bag, depthFileName, self.topic_window.temp_topics[1][1])
				except:
					self.errorMessages(7)
			
			#RGB Handling
			if self.topic_window.temp_topics[2][1] != 'Choose Topic':
				try:
					rgbFileName = fileName.replace(".bag","_RGB.avi")
					(self.message_count, compressed, framerate) = rosbagVideo.buffer_video_metadata(bag, self.topic_window.temp_topics[2][1])
					
						
					if os.path.isfile(rgbFileName):
						print colored('Loaded RGB video', 'yellow')
			
						# just fill time buffer in case that video exists
						for topic, msg, t in bag.read_messages(topics=[self.topic_window.temp_topics[2][1]]):
							if start_time is None:
								start_time = t
							self.time_buff.append(t.to_sec() - start_time.to_sec())
					else:
						#Get bag video metadata
						print colored('Get rgb data from ROS', 'green')
						(image_buffer, self.time_buff) = rosbagRGB.buffer_rgb_data(bag, self.topic_window.temp_topics[2][1], compressed)
						if not image_buffer:
							raise Exception(8)

						result  = rosbagRGB.write_rgb_video(rgbFileName, image_buffer, framerate)
						if not result:
							raise Exception(2)
						
					(framerate, self.message_count, self.duration) = rosbagRGB.video_metadata(rgbFileName)
					
					#Initialize objects which are equal to frames
					self.videobox = [boundBox(count) for count in range(int(self.message_count))]    
					
				except Exception as e:
					print e
					self.errorMessages(e[0])
				
			
			
			#Laser Topic selection
			if self.topic_window.temp_topics[3][1] != 'Choose Topic':
				try:
					rosbagLaser.runMain(bag, str(fileName),self.topic_window.temp_topics[3][1])
					pass
				except:
					self.errorMessages(9)

        self.wave.axes.clear()
        self.chart.axes.clear()
        self.rgbButton.setEnabled(True)
        self.depthButton.setEnabled(True)
        try:
            if self.rgbButton:
                self.mediaPlayer.setMedia(QMediaContent(QUrl.fromLocalFile(os.path.abspath(rgbFileName))))
                self.playButton.setEnabled(True)
            elif self.depthButton:
                self.mediaPlayer.setMedia(QMediaContent(QUrl.fromLocalFile(os.path.abspath(depthFileName))))
                self.playButton.setEnabled(True)

            #DEFINE PLAYER-PLAYLIST
            #----------------------
            self.source = QtCore.QUrl.fromLocalFile(os.path.abspath(audioGlobals.wavFileName))
            self.content = QMediaContent(self.source)
            self.player = QMediaPlayer()
            self.playlist = QMediaPlaylist(self)
            self.playlist.addMedia(self.content)
            self.player.setPlaylist(self.playlist)


            self.wave.drawWave()
            self.wave.drawAnnotations()
            self.wave.draw()

            self.chart.drawChart(self.videobox, framerate)
            self.chart.draw()

            self.setWindowTitle(fileName + ' -> Annotation')
        except:
            pass

    #Open CSV file
    def openCsv(self):
        global framerate
        global bagFile
        self.box_buffer = []
        self.metric_buffer = []
        
        if bagFile is not None:
            # OPEN VIDEO - DEPTH - AUDIO
            fileName,_ =  QFileDialog.getOpenFileName(self, "Open Csv ", os.path.dirname(os.path.abspath(bagFile)),"(*.csv)")
            box_buff, metrics_buff, box_action = rosbagRGB.buffer_video_csv(fileName)
            
            if not (box_buff or metrics_buff):
                self.errorMessages(1)
            else:
                self.box_buffer = [list(elem) for elem in box_buff]
                self.metric_buffer = [list(key) for key in metrics_buff]
                #Frame counter initialize
                counter = 0
                if len(box_action) > 0:
                    self.box_actionBuffer = [key for key in box_action]
                    for idx, key in enumerate(self.box_buffer):
                        if key[0] == 0:
                            counter += 1
                            self.videobox[counter].addBox(self.time_buff[counter], key, self.box_actionBuffer[idx])
                        else:
                            self.videobox[counter].addBox(self.time_buff[counter], key, self.box_actionBuffer[idx])
                else:
                    for idx, key in enumerate(self.box_buffer):
                        if key[0] == 0:
                            counter += 1
                            self.videobox[counter].addBox(self.time_buff[counter], key, ['Clear'])
                        else:
                            self.videobox[counter].addBox(self.time_buff[counter], key, ['Clear'])
                
                gantChart.axes.clear()
                gantChart.drawChart(self.videobox, framerate)
                gantChart.draw()
            print len(self.videobox)
        else:
            self.errorMessages(10)
		
    def errorMessages(self, index):
        msgBox = QMessageBox()
        msgBox.setIcon(msgBox.Warning)
        if index == 0:
            msgBox.setWindowTitle("Open rosbag")
            msgBox.setText("Could not open rosbag")
        elif index == 1:
            msgBox.setWindowTitle("Open CSV")
            msgBox.setText("Could not process CSV file")
        elif index == 2:
            msgBox.setWindowTitle("Open rosbag")
            msgBox.setIcon(msgBox.Critical)
            msgBox.setText("Could not write video")
        elif index == 3:
            msgBox.setText("Error: Json file path error")
        elif index == 4:
            msgBox.setText("Not integer type")
        elif index == 5:
            msgBox.setText("Box id already given")
        elif index == 6:
            msgBox.setWindowTitle("Open rosbag")
            msgBox.setText("Incorrect Audio Topic")
        elif index == 7:
            msgBox.setWindowTitle("Open rosbag")
            msgBox.setText("Incorrect Depth Topic")
        elif index == 8:
            msgBox.setWindowTitle("Open rosbag")
            msgBox.setText("Incorrect RGB Topic")
        elif index == 9:
            msgBox.setWindowTitle("Open rosbag")
            msgBox.setText("Incorrect Laser Topic")
        elif index == 10:
            msgBox.setWindowTitle("Open CSV")
            msgBox.setText("You must select a rosbag first")

        msgBox.resize(100,40)
        msgBox.exec_()

    def play(self):
        global frameCounter
        global posSlider
        global durationSlider
        if self.mediaPlayer.state() == QMediaPlayer.PlayingState:
            self.videoPosition()
            self.mediaPlayer.pause()
            if self.topic_window.temp_topics[0][1] != 'Choose Topic':
                self.audioPause()
            if self.topic_window.temp_topics[3][1] != 'Choose Topic':
                self.laserPause()
            self.time_ = self.positionSlider

        else:
            self.time_ = self.mediaPlayer.position()
            if self.topic_window.temp_topics[0][1] != 'Choose Topic':
                self.player.setPosition(self.time_)
                self.end = audioGlobals.duration*1000 - 10
                self.audioPlay()
            if self.topic_window.temp_topics[2][1] != 'Choose Topic':
                self.mediaPlayer.play()
            if self.topic_window.temp_topics[3][1] != 'Choose Topic':
                self.laserPlay()

        # >> Get slider position for bound box
        posSlider = self.positionSlider.value()
        #self.tickLabel.setAlignment(posSlider)
        frameCounter = int(round((self.message_count * posSlider)/(self.duration * 1000)))

    def mediaStateChanged(self, state):
        if state == QMediaPlayer.PlayingState:
            self.playButton.setIcon(self.style().standardIcon(QStyle.SP_MediaPause))
        else:
            self.playButton.setIcon(self.style().standardIcon(QStyle.SP_MediaPlay))

    def positionChanged(self, position):
        time = "{0:.2f}".format(float(position)/1000)
        self.positionSlider.setValue(position)
        self.positionSlider.setToolTip(str(time) + ' sec')
        self.timelabel.setText(self.label_tmp.format('Time: ' + str(time) + '/ ' + str("{0:.2f}".format(self.duration)) + ' sec'))
        laserGlobals.cnt = position/100

    def keyPressEvent(self,event):
        if event.key() == Qt.Key_Control:
            self.controlEnabled = True

    def keyReleaseEvent(self,event):
        if event.key() == Qt.Key_Control:
            self.controlEnabled = False

    def durationChanged(self, duration):
        global durationSlider
        durationSlider = duration
        self.positionSlider.setRange(0, duration)

    def setPosition(self, position):
        global frameCounter
        global posSlider
        frameCounter = int(round(self.message_count * position/(self.duration * 1000)))
        posSlider = position
        if (self.topic_window.temp_topics[2][1] != 'Choose Topic') or (self.topic_window.temp_topics[1][1] != 'Choose Topic'):
            self.mediaPlayer.setPosition(position)
        if self.topic_window.temp_topics[0][1] != 'Choose Topic':
            self.player.setPosition(position)

    #Writes the boxes to csv
    def writeCSV(self):
        global bagFile
        list_insert_time = []
        list_insert_box = []
        list_insert_class = []
        list_insert_param_1 = []
        list_insert_param_2 = []
        list_insert_param_3 = []
        list_insert_param_4 = []
        list_metr_param_1 = []
        list_metr_param_2 = []
        list_metr_param_3 = []
        list_metr_param_4 = []
        list_metr_param_5 = []
        list_metr_param_6 = []

        for i in self.videobox:
            for j in i.timestamp:
                list_insert_time.append(j)
            for k in i.box_id:
                list_insert_box.append(k)
            for l in i.box_Param:
                list_insert_param_1.append(l[0])
                list_insert_param_2.append(l[1])
                list_insert_param_3.append(l[2])
                list_insert_param_4.append(l[3])
            for key in i.annotation:
                list_insert_class.append(key)

        if len(self.metric_buffer) > 0:
            for metr in self.metric_buffer:
                list_metr_param_1.append(metr[0])
                list_metr_param_2.append(metr[1])
                list_metr_param_3.append(metr[2])
                list_metr_param_4.append(metr[3])
                list_metr_param_5.append(metr[4])
                list_metr_param_6.append(metr[5])
        
        csvFileName = bagFile.replace(".bag","_out.csv")
        with open(csvFileName, 'w') as file:
            csv_writer = csv.writer(file, delimiter='\t')
            headlines = ['Timestamp','Rect_id', 'Rect_x','Rect_y','Rect_W','Rect_H','Class','Meter_X','Meter_Y','Meter_Z','Top','Height' ,'Distance']
            csv_writer.writerow(headlines)
            rows = zip(list_insert_time,list_insert_box,list_insert_param_1,list_insert_param_2,list_insert_param_3,list_insert_param_4,list_insert_class,list_metr_param_1,list_metr_param_2,list_metr_param_3,list_metr_param_4,list_metr_param_5,list_metr_param_6)
            csv_writer.writerows(rows)
        print "Csv written at: ", csvFileName
   
    def closeEvent(self, event):
        self.writeCSV()
    
    def parseJson(self):
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
    

#Holds the bound box parameters
class boundBox(object):
    def __init__(self, parent=None):
        global xBoxCoord

        super(boundBox, self).__init__()
        self.timestamp = []
        self.box_id = []
        self.box_Param = []
        self.annotation = []

    def addBox(self, time, key, classify):
        self.timestamp.append(time)
        self.box_id.append(key[0])
        self.box_Param.append(key[1:])
        self.annotation.append(classify)

        self.calcAngle()

    def removeAllBox(self):
        self.timestamp[:] = []
        self.box_id[:] = []
        self.box_Param[:] = []
        self.annotation[:] = []

    def removeSpecBox(self, boxid):
        self.timestamp.pop(boxid)
        self.box_id.pop(boxid)
        self.box_Param.pop(boxid)
        self.annotation.pop(boxid)

    #Handles the annotation for basic and high level classes
    def changeClass(self, boxid, classify):
        global classLabels
        global highLabels
        if boxid in self.box_id:
            if classify in classLabels:
                self.annotation[self.box_id.index(boxid)][0] = classify
            elif classify in highLabels:
                if classify not in self.annotation[boxid]:
                    self.annotation[boxid].append(classify)

    #Remove high level events
    def removeEvent(self,boxid,action):
        global frameCounter
        #boxid is the index of boxes
        for key in self.annotation[boxid]:
            if action == key:
                self.annotation[boxid].remove(key)
        frameNumber = frameCounter + 1
        #Annotate the box at remaining frames
        while frameNumber < len(player.time_buff):
            if boxid >= len(player.videobox[frameNumber].box_id):
                break
            if action in player.videobox[frameNumber].annotation[boxid]:
                player.videobox[frameNumber].annotation[boxid].remove(action)
            frameNumber += 1

    def calcAngle(self):
        # let's say that camera angle is 58 degrees..
        camAngle = 58
        camAngleRadians = math.radians(camAngle)
        imWidth = 640 #pixels

        for index in range(len(self.box_Param)):
            # CENTRALIZE camera and laser
            # xCamera, yCamera, zCamera <--> xLaser, yLaser, zLaser IN METERS
            # zCamera and zLaser doesn't matter

            xCamera = 0
            xLaser = 0

            # Convert meters to pixels
            # 1m = 3779.527559px ; 1px = 0.000265m
            xCamera = xCamera * 3779.527559
            xLaser = xLaser * 3779.527559
            diff = xLaser - xCamera

            z = (imWidth/2)/ sin(camAngleRadians/2)
            #Construct the axis of triangle
            MK = math.sqrt(pow(z,2) - pow(imWidth/2,2))
            x1 = self.box_Param[index][0] + diff
            x2 = self.box_Param[index][0] + self.box_Param[index][2] + diff

            startPoint = abs(x1 - (imWidth/2))
            x1Angle = math.atan(startPoint/MK)
            if x1-(imWidth/2) > 0:
                x1Angle = x1Angle + (camAngleRadians/2)
            else:
                x1Angle = (camAngleRadians/2) - x1Angle

            endPoint = abs(x2 - (imWidth/2))
            x2Angle = math.atan(endPoint/MK)
            if x2-(imWidth/2) > 0:
                x2Angle = x2Angle + (camAngleRadians/2)
            else:
                x2Angle = (camAngleRadians/2) - x2Angle


            #angle = abs(math.degrees(x2Angle - x1Angle))

            # angle to laser 270 degrees
            x1 = x1 + math.radians(105)
            x2 = x2 + math.radians(105)


class MainWindow(QMainWindow):
    global csvFile
    global classLabels
    global highLabels
    
    def __init__(self, player):
        super(MainWindow, self).__init__()
        self.setCentralWidget(player)
        self.createActions()
        self.fileMenu = self.menuBar().addMenu("&File")
        self.fileMenu.addAction(self.openBagAct)
        self.fileMenu.addAction(self.openCsvAct)
        self.fileMenu.addAction(self.saveCsvAct)
        self.fileMenu.addAction(self.quitAct)
        
        
    def createActions(self):
        self.openBagAct = QAction("&Open rosbag", self, shortcut="Ctrl+B",
            statusTip="Open rosbag", triggered=self.openBag)
        self.openCsvAct = QAction("&Open video csv", self, shortcut="Ctrl+V",
            statusTip="Open csv", triggered=self.openCSV)
        self.saveCsvAct = QAction("&Save video csv", self, shortcut="Ctrl+S",
            statusTip="Save csv", triggered=self.saveCSV)
        self.quitAct = QAction("&Quit", self, shortcut="Ctrl+Q",
            statusTip="Quit", triggered=self.close)
        
    def openBag(self):
        player.openFile()
        
    def openCSV(self):
        player.openCsv()
        
    def saveCSV(self):
        player.writeCSV()
     
    def close(self):
        player.closeEvent(self)
        sys.exit(app)
    
if __name__ == '__main__':
    os.system('cls' if os.name == 'nt' else 'clear')
    app = QApplication(sys.argv)
    
    player = VideoPlayer()
    main = MainWindow(player)
    main.show()

    app.exec_()
    try:
        csvFileName = audioGlobals.bagFile.replace(".bag","_audio.csv")
        if audioGlobals.saveAudio == False:
            saveAudioSegments.save(csvFileName, audioGlobals.wavFileName)
    except:
        pass
