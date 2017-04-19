#!/usr/bin/env python
# -*- coding: utf-8 -*-

from laser import shortcutTable

from PyQt5.QtWidgets import *

class laserShortCuts(QWidget, shortcutTable.Ui_Form):
    
    def __init__(self, parent=None):
        super(laserShortCuts, self).__init__(parent)
        self.setupUi(self)