# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'picklist.ui'
#
# Created by: PyQt5 UI code generator 5.7
#
# WARNING! All changes made in this file will be lost!

from PyQt5 import QtCore, QtGui, QtWidgets

class Ui_Form(object):
    def setupUi(self, Form):
        Form.setObjectName("Form")
        Form.resize(378, 348)
        self.tab_widget = QtWidgets.QTabWidget(Form)
        self.tab_widget.setGeometry(QtCore.QRect(0, 0, 381, 351))
        self.tab_widget.setObjectName("tab_widget")
        self.tab = QtWidgets.QWidget()
        self.tab.setObjectName("basic")
        self.pushButton_3 = QtWidgets.QPushButton(self.tab)
        self.pushButton_3.setGeometry(QtCore.QRect(290, 280, 71, 31))
        self.pushButton_3.setObjectName("pushButton_3")
        self.listWidget_3 = QtWidgets.QListWidget(self.tab)
        self.listWidget_3.setGeometry(QtCore.QRect(10, 10, 151, 261))
        self.listWidget_3.setObjectName("listWidget_3")
        self.pushButton_2 = QtWidgets.QPushButton(self.tab)
        self.pushButton_2.setGeometry(QtCore.QRect(170, 130, 31, 31))
        self.pushButton_2.setObjectName("pushButton_2")
        self.pushButton = QtWidgets.QPushButton(self.tab)
        self.pushButton.setGeometry(QtCore.QRect(170, 80, 31, 31))
        self.pushButton.setObjectName("pushButton")
        self.listWidget_4 = QtWidgets.QListWidget(self.tab)
        self.listWidget_4.setGeometry(QtCore.QRect(210, 10, 151, 261))
        self.listWidget_4.setObjectName("listWidget_4")
        self.tab_widget.addTab(self.tab, "")
        self.tab_2 = QtWidgets.QWidget()
        self.tab_2.setObjectName("high")
        self.listWidget_5 = QtWidgets.QListWidget(self.tab_2)
        self.listWidget_5.setGeometry(QtCore.QRect(10, 10, 151, 261))
        self.listWidget_5.setObjectName("listWidget_5")
        self.pushButton_4 = QtWidgets.QPushButton(self.tab_2)
        self.pushButton_4.setGeometry(QtCore.QRect(170, 130, 31, 31))
        self.pushButton_4.setObjectName("pushButton_4")
        self.pushButton_5 = QtWidgets.QPushButton(self.tab_2)
        self.pushButton_5.setGeometry(QtCore.QRect(290, 280, 71, 31))
        self.pushButton_5.setObjectName("pushButton_5")
        self.listWidget_6 = QtWidgets.QListWidget(self.tab_2)
        self.listWidget_6.setGeometry(QtCore.QRect(210, 10, 151, 261))
        self.listWidget_6.setObjectName("listWidget_6")
        self.pushButton_6 = QtWidgets.QPushButton(self.tab_2)
        self.pushButton_6.setGeometry(QtCore.QRect(170, 80, 31, 31))
        self.pushButton_6.setObjectName("pushButton_6")
        self.tab_widget.addTab(self.tab_2, "")

        self.retranslateUi(Form)
        self.tab_widget.setCurrentIndex(0)
        QtCore.QMetaObject.connectSlotsByName(Form)

    def retranslateUi(self, Form):
        _translate = QtCore.QCoreApplication.translate
        Form.setWindowTitle(_translate("Remove Labels", "Form"))
        self.pushButton_3.setText(_translate("Form", "Done"))
        self.pushButton_2.setText(_translate("Form", "<<"))
        self.pushButton.setText(_translate("Form", ">>"))
        self.tab_widget.setTabText(self.tab_widget.indexOf(self.tab), _translate("Form", "Basic"))
        self.pushButton_4.setText(_translate("Form", "<<"))
        self.pushButton_5.setText(_translate("Form", "Done"))
        self.pushButton_6.setText(_translate("Form", ">>"))
        self.tab_widget.setTabText(self.tab_widget.indexOf(self.tab_2), _translate("Form", "High"))

