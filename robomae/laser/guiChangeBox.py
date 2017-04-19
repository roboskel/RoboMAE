#!/usr/bin/env python
# -*- coding: utf-8 -*-

from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtMultimedia import *
from PyQt5.QtMultimediaWidgets import *
from video.videoGlobals import videoGlobals

#Class for box (user id) change. Window where the user can change the id of a box.
class changeBoxId(QWidget):

    def __init__(self, box, frame_boxes, fig_plot, change_next):

        QWidget.__init__(self)
        self.box_Idx = None
        self.box = box
        self.frame_boxes = frame_boxes
        self.plot = fig_plot
        self.change_next = change_next  #defines whether to change the id in the next scans or not
        
        self.cancel = QPushButton("Cancel", self)
        self.cancel.clicked.connect(self.closeTextBox)
        self.Ok = QPushButton("Ok", self)
        self.Ok.clicked.connect(self.pressedOk)
        
        self.boxId = QLineEdit(self)
        self.boxId.textChanged.connect(self.boxChanged)
        self.boxId.setPlaceholderText('Box Id:')
        self.boxId.setMinimumWidth(80)
        self.boxId.setEnabled(True)
        self.boxId.move(190, 15)

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
       
    def boxChanged(self, text):
        self.box_Idx = text
        
    def closeTextBox(self, text):
        self.close()

    def pressedOk(self):
        try:
            self.box_Idx = int(self.box_Idx)
            
            alreadyIn = [b for b in self.frame_boxes if b.uId == self.box_Idx]

            #Checks whether this id exists in the current scan or not
            if len(alreadyIn) != 0:
                #Box Id already given
                msgBox = QMessageBox()
                msgBox.setText("Box Id already given")
                msgBox.setIcon(msgBox.Warning)
                msgBox.setWindowTitle("Error")
                msgBox.exec_()
            else:
                #Chencge the box id, update the Next one is it is chosen as an option and restore the canvas with the changes
                if self.change_next == True:
                    self.plot.rectangles.updateNextIds(self.box, self.box_Idx)
                self.box.changeUser(self.box_Idx)

                self.Ok.clicked.disconnect()
                self.close()
                
                self.plot.canvas.restore_region(self.plot.background)
                self.plot.drawRectangles()
                self.plot.canvas.blit(self.plot.axes.bbox)
        except:
            msgBox = QMessageBox()
            msgBox.setText("Wrong type, integer expected")
            msgBox.setIcon(msgBox.Warning)
            msgBox.setWindowTitle("Error")
            msgBox.exec_()
            self.close()
