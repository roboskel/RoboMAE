import json
import copy

"""
This class represents a bounding box (or rectangle) that the user marks on the screen,
in order to collect the data points for annotation, their condition and the respective user id.
"""
class BoundingBox(object):

    def __init__(self, rect):
        self.rectangle = rect       #the rectangle on the plot. Type <Rectange>
        self.extraPoints = []       #some extra points that are not included into the rectangle
        self.boxId = -1             #auto increment box identification number
        self.frameCount = -1        #the scan/frame where the box exists
        self.condition = "Clear"    #the condition of the box (e.x Walk, Stand etc)
        self.uId = -1               #the id of the user where this box belongs to
        self.pointColors = []       #array of colors set to the extra points depending on the uId
        self.data = []              #the data points included into the box, specified by the rectangle on the plot

        self.parseJson()            #loads some colors in order to set different colors to the extra points, depending on the id of the user


    def parseJson(self):
        with open("labels.json") as json_file:
            json_data = json.load(json_file)
            for i in json_data['pointColors']:
                self.pointColors.append(i)


    def getPointColor(self):
        cid = self.uId
        if self.uId < 0:
            cid = 0

        return self.pointColors[cid%len(self.pointColors)]

    #Sets a color to the rectangle and the extra points of the box, regarding the condition of the box
    def setColor(self, color):
        self.rectangle.set_edgecolor(color)

        for p in self.extraPoints:
            p.set_edgecolor(color)

    #Changes the user id of the box and the color of its points
    def changeUser(self, uid):
        self.uId = uid

        for p in self.extraPoints:
            p.set_facecolor(self.getPointColor())


    #Append an extra point and set the appropriate color
    def appendPoint(self, circle):
        circle.set_facecolor(self.getPointColor())
        circle.set_edgecolor(self.rectangle.get_edgecolor())
        self.extraPoints.append(circle)

    #Not used yet
    def setData(self, annot):
        self.data = annot[:]

        return self.outOfBounds()

    #Not used yet
    def outOfBounds(self):
        minX = self.rectangle.get_x()

        maxX = self.rectangle.get_x() + self.rectangle.get_width()
        minY = self.rectangle.get_y()
        maxY = self.rectangle.get_y() + self.rectangle.get_height()

        #(x,y) points that are located into each rectangle
        x_ = [i for i,v in enumerate(annotX) if v>=minX and v<=maxX]
        y_ = [i for i,v in enumerate(annotY) if v>=minY and v<=maxY]

        intersect = list(set(x_).intersection(y_))




"""
A handler of the rectangles-boxes.
It contains a set of <BoundingBox>
"""
class BBoxHandler(object):

    def __init__(self):
        self.boxes = []         #list of BoundingBox
        self.id_count = 0       #increment number - id of its BoundingBox


    def reset(self):
        self.boxes = []
        self.id_count = 0

    def append(self, box):
        box.boxId = self.id_count
        self.id_count = self.id_count + 1
        self.boxes.append(box)


    #Add a circle as a point to the last bounding box
    def addPoint(self, circle):
        box = self.boxes[len(self.boxes)-1]
        box.appendPoint(circle)

    #Check whether it is empty of boxes or not
    def empty(self):
        if len(self.boxes) == 0:
            return True

        return False

    #Returns all the boxes that belong to the same frame/scan
    def getByFrame(self, frameCounter):
        try:
            listOfBoxes = [rec for rec in self.boxes if rec.frameCount == frameCounter]
        except IndexError:
            return None

        if len(listOfBoxes) != 0:
            return listOfBoxes
        
        return None

    #Returns all the boxes that belong to the same user - have the same user id
    def getById(self, uid):
        try:
            listOfBoxes = [rec for rec in self.boxes if rec.uId == uid]
        except IndexError:
            return None

        if len(listOfBoxes) != 0:
            return listOfBoxes
        
        return None

    #Returns all the boxes that belong to the next scans and that they have the same user id
    def getByNextFrames(self, frameCounter, uid):
        try:
            listOfBoxes = [rec for rec in self.boxes if rec.frameCount > frameCounter and rec.uId == uid]
        except IndexError:
            return None

        if len(listOfBoxes) != 0:
            return listOfBoxes
        
        return None

    #Set the condition of the current box to the boxes that have the same user id and belong to the next scans 
    def updateNextStates(self, box, color):
        updated_condition = box.condition

        update_boxes = self.getByNextFrames(box.frameCount, box.uId)

        if not update_boxes == None:
            for b in update_boxes:
                b.condition = updated_condition
                b.setColor(color)


    #Set the user id of the current box to the boxes that had the same user id until now and belong to the next scans 
    def updateNextIds(self, box, new_id):
        update_boxes = self.getByNextFrames(box.frameCount, box.uId)

        if not update_boxes == None:
            for b in update_boxes:
                b.changeUser(new_id)

    #It creates the same boxes of the previous scan, to the current one
    def copyPrevious(self, frameCounter):
        prevBoxes = self.getByFrame(frameCounter)

        if not (prevBoxes == None):
            for pbox in prevBoxes:
                cpBox = copy.copy(pbox)
                cpBox.frameCount = frameCounter+1
                self.append(cpBox)

    #Returns the box that the user clicked on it. If there are more than one boxes (overlap situation), it returns the one with the minimum cover area.
    def getInvolvedBox(self, frameCounter, posX, posY):
        listOfBoxes = self.getByFrame(frameCounter)

        if (listOfBoxes == None):
            return None

        templist = []
        for box in listOfBoxes:
            x = box.rectangle.get_x()
            y = box.rectangle.get_y()
            w = box.rectangle.get_width()
            h = box.rectangle.get_height()


            if posX > x and posX < (x+w) and posY > y and posY < (y+h):
                templist.append(box)

        if len(templist) == 0:
            return None
        elif len(templist) == 1:
            return templist[0]
        else:
            return self.minArea(templist)

    #It computes the box where its rectangle covers the minimum area between the rest
    def minArea(self, boxList):
        minCover = float("inf")
        minBox = None

        for box in boxList:
            cover = box.rectangle.get_width() * box.rectangle.get_height()

            if cover < minCover:
                minBox = box

        return minBox

    #Removes a single box.
    def removeBox(self, box):
        try:
            self.boxes.remove(box)           
        except Exception:
            print 'Error in removing box'

    #Removes all the boxes of a specific scan
    def removeAllBoxes(self, frameCounter):
        listOfBoxes = self.getByFrame(frameCounter)

        if not (listOfBoxes == None):
            for box in listOfBoxes:
                self.boxes.remove(box)

    #Removes all the boxes in the list with a specific user id 
    def removeAllBoxesId(self, uid):
        listOfBoxes = self.getById(uid)

        if not (listOfBoxes == None):
            for box in listOfBoxes:
                self.boxes.remove(box)
