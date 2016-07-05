% RoboMAE, The Roboskel Multimodal Annotation Environment,
% is developed as part of Roboskel, the robotics activity
% of the Institute of Informatics and Telecommunications,
% National Centre for Scientific Research "Demokritos",
% Ag. Paraskevi, Greece
% Please see http://roboskel.iit.demokritos.gr
% or contact us at roboskel@iit.demokritos.gr
% 
% Copyright (C) 2012-2013, NCSR "Demokritos", Ag. Paraskevi, Greece
% Copyright (C) 2013, Konstantinos Tsiakas
% 
% Authors:
% Sergios Petridis, 2012
% Theodore Giannakopoulos, 2012-2013
% Konstantinos Tsiakas, 2013
% 
% This file is part of RoboMAE.
% 
% RoboMAE is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 2 of the License, or
% (at your option) any later version.
% 
% RoboMAE is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with RoboMAE.  If not, see <http://www.gnu.org/licenses/>.




%dirctory of the saved jpg images
jpgFiles = dir([folder filesep '*.png']);

%create video object file
aviobj = avifile('Reconstucted_Image_video.avi'); %creatting a movie object and save it

for i=1:1:length(jpgFiles)%length(bmpFiles) %number of images to be read
% filename = bmpFiles(i).name;
% [a, map] = imread(filename);
    [a, map] = imread(jpgFiles(i).name);%reading %the 5 images named Reconstucted_Image1.jpg, Reconstucted_Image2.jpg, Reconstucted_Image3.jpg,Reconstucted_Image4.jpg,Reconstucted_Image5.jpg
                      %strcat: string concatinate to concatinate the image
                      %number with the '.bmp'
                      %file, int2str: convert from integer to string, a map
                      %is required since this type of image is a 2D logical
                      %image, therfore it is required to provide it's map
                      %with it so it can be converted into frames to be
                      %able to be attached to the avi file to be played.
 
    a = uint8(a);%convert the images into unit8 type

    M = im2frame(a, map);%convert the images into frames with the associated map since it's not a 3D matrix
    aviobj = addframe(aviobj,M);%add the frames to the avi object created previously
    %fprintf('adding frame = %i\n', i);
end

%save the video file as a '.avi' file
%avi = avifile('Threshold_frame_video.avi');

%close the avi file
disp('Closing movie file...')
aviobj = close(aviobj);

% avi = close(avi);

%play the movie
disp('Playing movie file...')
implay('Reconstucted_Image_video.avi');
%%%%%%%%%%End of code%%%%%%%%%%%%%%%