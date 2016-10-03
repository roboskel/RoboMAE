#!/usr/bin/env python
# -*- coding: utf-8 -*-

from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtMultimedia import *
from PyQt5.QtMultimediaWidgets import *

#Class for box id change
class textBox(QWidget):

    def __init__(self, videobox, posX, posY, frameCounter, gantChart, framerate):

        QWidget.__init__(self)
        self.videobox = videobox
        self.posX = posX
        self.posY = posY
        self.frameCounter = frameCounter
        self.framerate = framerate
        self.gantChart = gantChart
        self.setWindowTitle('Set Box id')
        self.main_widget = QWidget(self)
        self.boxId = QLineEdit(self)
        self.Ok = QPushButton("Ok", self)
        self.boxId.textChanged.connect(self.boxChanged)
        self.Ok.clicked.connect(self.closeTextBox)
        self.boxId.setPlaceholderText('Box Id:')
        self.boxId.setMinimumWidth(100)
        self.boxId.setEnabled(True)

        self.boxId.move(90, 15)
        self.Ok.move(115, 60)
        self.Ok.show()
        self.boxId.show()

    def boxChanged(self,text):
        self.box_Idx = text

    def closeTextBox(self):
        try:
            self.box_Idx = int(self.box_Idx)
        except:
            msgBox = QMessageBox()
            msgBox.setText("Wrong type, integer expected")
            msgBox.resize(100,40)
            msgBox.exec_()

        #Check id
        for i in range(len(self.videobox[self.frameCounter].box_Id)):
            if self.box_Idx == self.videobox[self.frameCounter].box_Id[i]:
                #Box Id already given
                msgBox = QMessageBox()
                msgBox.setText("Box Id already given")
                msgBox.resize(100,40)
                msgBox.exec_()

        for i in range(len(self.videobox[self.frameCounter].box_Id)):
            x,y,w,h = self.videobox[self.frameCounter].box_Param[i]
            if self.posX > x and self.posX  < (x+w) and self.posY > y and self.posY < (y+h):
                old_value = self.videobox[self.frameCounter].box_Id[i]
                self.videobox[self.frameCounter].box_Id[i] = self.box_Idx
                self.writeEnable = True
                self.frameNumber = self.frameCounter
                old_index = i
                break

        if self.writeEnable:
            while self.frameNumber < len(self.videobox):
                if old_value in self.videobox[self.frameNumber].box_Id:
                    self.videobox[self.frameNumber].box_Id[old_index] = self.box_Idx
                self.frameNumber += 1
            self.writeEnable = False
            
        self.gantChart.axes.clear()
        self.gantChart.drawChart(self.videobox, self.framerate)
        self.gantChart.draw()
        self.Ok.clicked.disconnect()
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
        self.okButtonPush = False
        self.topic_options = []
        self.dropDownBox = []
        self.temp_topics = []

    def show_topics(self, Topics):
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

