#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import csv
import cv2
import yaml
from termcolor import colored
from sensor_msgs.msg import Image
from sensor_msgs.msg import CompressedImage
from cv_bridge import CvBridge, CvBridgeError
import rosbagVideo

"""
Buffers image and time data from rosbag

Input: 
        -bag        : rosbag
        -input_topic: the image topic of the rosbag
        -compressed : if the topic is compressed

Output:
        -image_buff : list of image frames
        -time_buff  : list of time frames corresponding to each image
"""
def buffer_rgb_data(bag, input_topic, compressed):
    image_buff = []
    time_buff  = []
    start_time = None
    bridge     = CvBridge()
    
    #Buffer the images, timestamps from the rosbag
    for topic, msg, t in bag.read_messages(topics=[input_topic]):
        if start_time is None:
            start_time = t

        #Get the image
        if not compressed:
            try:
                cv_image = bridge.imgmsg_to_cv2(msg, "bgr8")
            except CvBridgeError as e:
                print e
        else:
            nparr = np.fromstring(msg.data, np.uint8)
            cv_image = cv2.imdecode(nparr, cv2.CV_LOAD_IMAGE_COLOR)

        image_buff.append(cv_image)
        time_buff.append(t.to_sec() - start_time.to_sec())

    return image_buff, time_buff
  
"""
Buffers csv data for the video module, a.k.a. bounded boxes and 
their metrics

Input: 
        -csv_file : the path of the csv

Output:
        -box_buff       : list of image frames
        -metrics        : list of time frames corresponding to each image
        -box_buff_action: list of time frames corresponding to each image
"""
def buffer_video_csv(csv_file):
    box_buff   = []
    metrics = []
    box_buff_action = []

    if csv_file is not None and os.path.exists(csv_file):
        with open(csv_file, 'r') as file_obj:
            csv_reader = csv.reader(file_obj, delimiter = '\t')
            row_1 = next(csv_reader)
            try:
                index = [x.strip() for x in row_1].index('Rect_id')
                if 'Class' not in row_1:
                    for row in csv_reader:
                        (rec_id,x, y, width, height) = map(int, row[index:index + 5])
                        (meter_X, meter_Y, meter_Z, top,meter_h, distance) = map(float, row[(index+5)::])
                        box_buff.append((rec_id, x, y, width, height))
                        metrics.append((meter_X, meter_Y, meter_Z, top, meter_h, distance))
                else:
                    for row in csv_reader:
                        (rec_id, x, y, width, height) = map(int, row[index:index + 5])
                        (meter_X, meter_Y, meter_Z, top, meter_h, distance) = map(float, row[(index+6)::])
                        box_buff.append((timestamp, rec_id, x, y, width, height))
                        if  isinstance(row[index+5], str):
                            string = row[index+5]
                            if string.startswith('[') and string.endswith(']'):
                                #Transform a string of list to list
                                string = ast.literal_eval(string)
                                box_buff_action.append(string)
                            else:
                                box_buff_action.append(string)
                        else:
                            box_buff_action.append(row[index+5])
                        metrics.append((meter_X,meter_Y,meter_Z,top,meter_h,distance))
            except:
                print("Error processing video csv")
    return box_buff, metrics, box_buff_action

"""
Writes rgb video from buffer to selected path

Input: 
        -rgbFileName : path to write the video
        -image_buffer: buffer containing video frames

Output: --
"""
def write_rgb_video(rgbFileName, image_buffer, framerate):
    print  colored('Writing rgb video at: ', 'yellow'),rgbFileName 
    #Check opencv version
    major = cv2.__version__.split(".")[0]
    if major == '3':
        fourcc = cv2.VideoWriter_fourcc('X', 'V' ,'I', 'D')
    else:
        fourcc = cv2.cv.CV_FOURCC('X', 'V' ,'I', 'D')

    height, width, bytesPerComponent = image_buffer[0].shape
    video_writer = cv2.VideoWriter(rgbFileName, fourcc, framerate, (width,height), cv2.IMREAD_COLOR)

    if not video_writer.isOpened():
        self.errorMessages(2)
    else:
        #print("Video initialized")
        for frame in image_buffer:
            video_writer.write(frame)
        video_writer.release()
    print colored('Video writen successfully', 'yellow')
    
    
def video_metadata(rgbFileName):
    cap = cv2.VideoCapture(rgbFileName)
    fps = round(cap.get(cv2.cv.CV_CAP_PROP_FPS))
    count = round(cap.get(cv2.cv.CV_CAP_PROP_FRAME_COUNT))
    duration = count/fps
       
    return fps, count, duration
