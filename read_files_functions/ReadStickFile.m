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


function [ timestamp,userID,XYZstruct,XYZ] = ReadStickFile( stick_file )
%ReadStickFile gives the coordinates of the Kinect stick model
%   timestamp is the correspoding timestamp in msecs
%   userID is an integer for a user tracked by the stick model 
%   XYZstruct is a 1x45 array containing the coordinates of the stick model
%   described above. Each joint (head,hands etc) has 3 coordinates - x,y,z
%   Indexes of XYZ array correspond to :
%
%   1-3     : HEAD
%   4-6     : NECK
%   7-9     : TORSO
%   9-12    : R_SHOULDER
%   13-15   : R_ELBOW
%   16-18   : R_HAND
%   19-21   : R_HIP
%   22-24   : R_KNEE
%   25:27   : R_FOOT
%   28-30   : L_SHOULDER
%   31-33   : L_ELBOW
%   34-36   : L_HAND
%   37-39   : L_HIP
%   40-42   : L_KNEE
%   42-45   : L_FOOT

TEMP = importdata(stick_file);
timestamp = TEMP(:,1)/10^3;
userID = TEMP(:,2);
XYZ = TEMP(:,2:end);
XYZstruct.HEAD = XYZ(:,1:3);
XYZstruct.NECK = XYZ(:,4:6);
XYZstruct.TORSO = XYZ(:,7:9);
XYZstruct.R_SHOULDER = XYZ(:,10:12);
XYZstruct.R_ELBOW = XYZ(:,13:15);
XYZstruct.R_HAND = XYZ(:,16:18);
XYZstruct.R_HIP = XYZ(:,19:21);
XYZstruct.R_KNEE = XYZ(:,22:24);
XYZstruct.R_FOOT = XYZ(:,25:27);
XYZstruct.L_SHOULDER = XYZ(:,28:30);
XYZstruct.L_ELBOW = XYZ(:,31:33);
XYZstruct.L_HAND = XYZ(:,34:36);
XYZstruct.L_HIP = XYZ(:,37:39);
XYZstruct.L_KNEE = XYZ(:,40:42);
XYZstruct.L_FOOT = XYZ(:,43:45);



end

