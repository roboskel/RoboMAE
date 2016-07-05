RoboMAE is a multimodal annotation environment for robot sensor
data. RoboMAE allows human annotators to concentrate on high-level
decisions regarding the interpretation of a scene, while at the same
time producing full frame-by-frame annotations with cross-linking of
the same object's recognition across the different modalities.

Our approach exploits existing recognition methods and spatio-temporal
co-occurence to "transfer" annotations across modalities, and on
automatically interpolating annotations between explicitly annotated
frames. The backend automations interact with the visual environment
in real time, providing annotators with immediate feedback for their
actions.

Our approach is demonstrated and evaluated on a dataset collected for
the recognition and localization of conversing humans, an important
task in human-robot interaction applications. The conversation
datasets are publicly available at
http://roboskel.iit.demokritos.gr/downloads/RoboMAE

Instructions:

> Run AnnotationTool.m
  It selects the modality files for a certain timestamp(second) and plots
  the data for each slider position

> user
  
  (Bounding boxes are selectable (click on boundaries). When a bbox is selected the line style of the bbox changes.)

Add: draw a bounding box on speaker. Initially you can choose Speaker1... Speaker8
as valid names. If user have added another name as possible speaker
(Insert Speaker), user can use this name.

SpeakerList: Shows the list of available speaker names

Remove: User can select a bbox and then press Remove to remove this box.
If there is an annotation on Projected depth image, it is removed too.

Select Speaker: User can select a bbox and then choose another Speaker's name

Insert Speaker: User can select a bbox and then write a new name (i.e. his/her name)

Play: play the specific wav file whis is plotted

speech: User can select a bbox and associate the segment with the
person by pushing speech. User can use the zoom in / zoom out button
upon audio signal plot to zoom in/out and (hear the specific sound
and) and select this region to be associated with the selected person.

FaceDetection: User can start with a face detection for
initialiazation. Otherwise uses the Add button.

ImageProjection: Projects depth image to the x-axis in order to
associate it with the laser scan. User can click on two associated
points (i.e. the curves that indicate speaker's legs) of the plot and
are colored with the specific bbox color

Export: User can export .mat files containing the structs for each
speaker (bboxes, colors, names) and the speech array (id,
start_segment,end_segment)

Import: User can import existing annotations for dataset. They may
import speech, face tracking, laser annotations or all

Clear Data: User can clear all existing data (struct that contains
speakernames, bboxes, etc) and reset the speakerlist to initial
setting (Speaker1....Speaker8). All bboxes and names are cleared if
selected.
