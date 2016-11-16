#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import picklist

from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtMultimedia import *
from PyQt5.QtMultimediaWidgets import *
from video.videoGlobals import videoGlobals

#Class for box id change
class textBox(QWidget):

    def __init__(self, videobox, index, frameCounter, framerate, gantChart):

        QWidget.__init__(self)
        self.box_Idx = None
        self.videobox = videobox
        self.index = index
        self.frameCounter = frameCounter
        self.framerate = framerate
        self.gantChart = gantChart
        
        self.cancel = QPushButton("Cancel", self)
        self.cancel.clicked.connect(self.closeTextBox)
        self.Ok = QPushButton("Ok", self)
        self.Ok.clicked.connect(self.pressedOk)
        
        self.boxId = QLineEdit(self)
        self.boxId.textChanged.connect(self.boxChanged)
        self.boxId.setPlaceholderText('Box Id:')
        self.boxId.setMinimumWidth(80)
        self.boxId.setEnabled(True)
        self.boxId.move(90, 15)

        flo = QFormLayout()
        flo.addRow(self.boxId)
        
        boxLayout = QHBoxLayout()
        boxLayout.addWidget(self.cancel)
        boxLayout.addWidget(self.Ok)
        
        verLayout = QVBoxLayout()
        verLayout.addLayout(flo)
        verLayout.addLayout(boxLayout)
        
        self.setLayout(verLayout)
        self.setWindowTitle('Set Box id')
        self.show()
       
    def boxChanged(self,text):
        self.box_Idx = text
        
    def closeTextBox(self,text):
        self.close()

    def pressedOk(self):
        try:
            self.box_Idx = int(self.box_Idx)
            #Check id
            if self.box_Idx in self.videobox[self.frameCounter].box_id:
                #Box Id already given
                msgBox = QMessageBox()
                msgBox.setText("Box Id already given")
                msgBox.setIcon(msgBox.Warning)
                msgBox.setWindowTitle("Error")
                msgBox.exec_()
            else:
                while self.frameCounter < len(self.videobox):
                    if(self.index < len(self.videobox[self.frameCounter].box_id)):
                        self.videobox[self.frameCounter].box_id[self.index] = self.box_Idx
                    self.frameCounter += 1
                self.gantChart.axes.clear()
                self.gantChart.drawChart(self.videobox, self.frameCounter, self.framerate)
                self.gantChart.draw()
                self.Ok.clicked.disconnect()
                self.close()
        except:
            msgBox = QMessageBox()
            msgBox.setText("Wrong type, integer expected")
            msgBox.setIcon(msgBox.Warning)
            msgBox.setWindowTitle("Error")
            msgBox.exec_()
            self.close()

        
#Class for Drop down boxes about topic selection
class TopicBox(QDialog):
    def __init__(self):
        super(TopicBox,self).__init__()
        self.setWindowTitle('Select Topics')
        self.setGeometry(280, 260, 440, 400)
        self.move(QApplication.desktop().screen().rect().center()- self.rect().center())
        self.okButton = QPushButton("Ok", self)
        self.okButton.move(180,360)
        self.okButton.clicked.connect(self.close_window)
        self.okButton.setEnabled(False)
        
        self.basic_topics = ['Audio', 'Depth', 'Video' , 'Laser']
        

    def show_topics(self, Topics):
        self.okButtonPush = False
        self.topic_options = []
        self.dropDownBox = []
        self.temp_topics = []
        
        x = 30
        y = 40
        for index,topic in enumerate(self.basic_topics):
            self.topic_options.append(QLabel(self))
            self.topic_options[index].move(x,y)
            self.topic_options[index].setText(self.basic_topics[index])
            self.dropDownBox.append(QComboBox(self))
            y += 60

        x = 120
        y = 35
        for key,option in enumerate(self.dropDownBox):
            self.dropDownBox[key].addItem('Choose Topic')
            self.dropDownBox[key].addItems(Topics)
            self.dropDownBox[key].move(x, y)
            self.dropDownBox[key].currentTextChanged.connect(self.selectionchange)
            y += 60

        #initialize list
        for index in range(len(self.basic_topics)) :
            self.temp_topics.append([index,'Choose Topic'])


        self.exec_()

    def selectionchange(self, text):
        topic_counter = 0
        for key,option in enumerate(self.dropDownBox):
            if self.dropDownBox[key].currentText() == 'Choose Topic':
                topic_counter += 1
        if topic_counter == len(self.basic_topics):
            self.okButton.setEnabled(False)
        else:
            self.okButton.setEnabled(True)

        for key,option in enumerate(self.dropDownBox):
            if text == self.dropDownBox[key].currentText():
                ddbox_index = key

        if len(self.temp_topics) > 0:
            for idx,value in enumerate(self.temp_topics):
                if value[0] == ddbox_index:
                    self.temp_topics.pop(idx)
                    self.temp_topics.append([ddbox_index,str(text)])
            if [ddbox_index,text] not in self.temp_topics:
                self.temp_topics.append([ddbox_index,str(text)])
        else:
            self.temp_topics.append([ddbox_index,str(text)])

    def close_window(self):
        #Sort by its first element
        self.temp_topics.sort(key=lambda x: x[0])
        self.okButtonPush = True
        self.close()


#Class for class addition
class addLabel(QWidget):

    def __init__(self):

        QWidget.__init__(self)
        self.label = None
        self.isHighLevel = False
        self.cancel = QPushButton("Cancel", self)
        self.cancel.clicked.connect(self.closeBox)
        self.Ok = QPushButton("Ok", self)
        self.Ok.clicked.connect(self.okPressed)
        self.cb = QCheckBox('High level event', self)
        self.cb.stateChanged.connect(self.checkBox)
        
        self.boxId = QLineEdit(self)
        self.boxId.textChanged.connect(self.boxChanged)
        self.boxId.setPlaceholderText('Class Label:')
        self.boxId.setMinimumWidth(80)
        self.boxId.setEnabled(True)
        self.boxId.move(90, 15)

        flo = QFormLayout()
        flo.addRow(self.boxId)
        flo.addRow(self.cb)
        boxLayout = QHBoxLayout()
        boxLayout.addWidget(self.cancel)
        boxLayout.addWidget(self.Ok)
        
        verLayout = QVBoxLayout()
        verLayout.addLayout(flo)
        verLayout.addLayout(boxLayout)
        
        self.setLayout(verLayout)
        self.setWindowTitle('Set Class Label')
        self.show()
       
    def checkBox(self, state):
         if state == Qt.Checked:
            self.isHighLevel = True
        
    def boxChanged(self, text):
        self.label = text
        
    def closeBox(self):
        self.close()

    def okPressed(self):
        self.label = self.label
        #Check id
        if self.label in videoGlobals.classLabels or self.label in videoGlobals.highLabels:
            #Box Id already given
            msgBox = QMessageBox()
            msgBox.setText("Class label already exists")
            msgBox.setIcon(msgBox.Warning)
            msgBox.setWindowTitle("Error")
            msgBox.exec_()
        else:
           videoGlobals.classLabels.append(self.label)
           self.Ok.clicked.disconnect()
           self.close()
           color = QColorDialog.getColor()
           json_data = None
           with open("labels.json", 'r+') as json_file:
               json_data = json.load(json_file)
               if self.isHighLevel:
                    json_data['highlevellabels'].append(self.label)
                    json_data['eventColors'].append(color.name())
               else:
                    json_data['basiclabels'].append(self.label)
                    json_data['annotationColors'].append(color.name())
           with open("labels.json", 'w+') as json_file:    
               json.dump(json_data, json_file)
        
        videoGlobals.classLabels, videoGlobals.highLabels, videoGlobals.annotationColors, videoGlobals.eventColors = self.parseJson()
        
    def parseJson(self):
        json_basicLabel = []
        json_highLabel = []
        json_annotationColors = []
        json_eventColors = []

        with open("labels.json") as json_file:
                json_data = json.load(json_file)
                json_label = []
                for i in json_data['basiclabels'] :
                    json_basicLabel.append(i)
                for i in json_data['highlevellabels']:
                    json_highLabel.append(i)
                for i in json_data['annotationColors'] :
                    json_annotationColors.append(i)
                for i in json_data['eventColors']:
                    json_eventColors.append(i)
        return json_basicLabel,json_highLabel, json_annotationColors, json_eventColors

class removeLabel(QWidget, picklist.Ui_Form):
    
    def __init__(self, parent=None):
        super(removeLabel, self).__init__(parent)
        self.setupUi(self)
        for label in videoGlobals.classLabels:
            self.listWidget_3.addItem(label)
        
        self.pushButton.clicked.connect(self.moveRight)
        self.pushButton_2.clicked.connect(self.moveLeft)
        self.pushButton_3.clicked.connect(self.done)
        
        
        for label in videoGlobals.highLabels:
            self.listWidget_5.addItem(label)
    
        self.pushButton_6.clicked.connect(self.moveRightHigh)
        self.pushButton_4.clicked.connect(self.moveLeftHigh)
        self.pushButton_5.clicked.connect(self.done)
        
    def moveRight(self):
        selection = self.listWidget_3.takeItem(self.listWidget_3.currentRow())
        self.listWidget_4.addItem(selection)
        
    def moveLeft(self):
        selection = self.listWidget_4.takeItem(self.listWidget_4.currentRow())
        self.listWidget_3.addItem(selection)
        
    def moveRightHigh(self):
        selection = self.listWidget_5.takeItem(self.listWidget_5.currentRow())
        self.listWidget_6.addItem(selection)
        
    def moveLeftHigh(self):
        selection = self.listWidget_6.takeItem(self.listWidget_6.currentRow())
        self.listWidget_5.addItem(selection)
        
    def done(self):
        json_data = {"basiclabels":[],"annotationColors":[], "highlevellabels":[], "eventColors":[]}
        
        colors = []
        basicLabel = []
        for i in range(self.listWidget_3.count()):
            item = self.listWidget_3.item(i)
            basicLabel.append(item.text())
            colors.append(videoGlobals.annotationColors[i])
        json_data['basiclabels'] = basicLabel
        json_data['annotationColors'] = colors
        
        colors = []
        highLabel = []
        for i in range(self.listWidget_5.count()):
            item = self.listWidget_5.item(i)
            highLabel.append(item.text())
            colors.append(videoGlobals.eventColors[i])
        json_data['highlevellabels']= highLabel
        json_data['eventColors'] = colors
        
        with open("labels.json", 'w+') as json_file:    
               json.dump(json_data, json_file)
        videoGlobals.classLabels, videoGlobals.highLabels, videoGlobals.annotationColors, videoGlobals.eventColors = self.parseJson()
        self.close()
        
    def parseJson(self):
        json_basicLabel = []
        json_highLabel = []
        json_annotationColors = []
        json_eventColors = []

        with open("labels.json") as json_file:
                json_data = json.load(json_file)
                json_label = []
                for i in json_data['basiclabels'] :
                    json_basicLabel.append(i)
                for i in json_data['highlevellabels']:
                    json_highLabel.append(i)
                for i in json_data['annotationColors'] :
                    json_annotationColors.append(i)
                for i in json_data['eventColors']:
                    json_eventColors.append(i)
        return json_basicLabel,json_highLabel, json_annotationColors, json_eventColors
        
    
    
