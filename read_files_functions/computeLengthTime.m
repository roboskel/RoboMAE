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


function [t0,step,time] = computeLengthTime(directory,laser_times)
%% computeLengthTime 
... computes basic parameters as the first timestamp, the length 
... of the data. It normalizes timestamps. The minimum timestamp is t0 = 0
... It takes the folder files as input and sets the minimum timestamp as t0

%% find begin and end timestamp of wav files
wav_folder = [directory filesep '*.wav'];
sound_files = dir(wav_folder);
[~,begin_s_time,~] = fileparts(sound_files(1).name);
[~,end_s_time,~] = fileparts(sound_files(length(sound_files)-1).name);
wav_time = str2double(end_s_time) - str2double(begin_s_time) + 1 ; % 1-second lenght

%% find begin and end timestamp of jpg files
image_folder = [directory '/*.png'];
image_files = dir(image_folder);
[~,begin_i_time,~] = fileparts(image_files(1).name);
[~,end_i_time,~] = fileparts(image_files(length(image_files)).name);
image_time = ((str2double(end_i_time(7:end)))/10^3) - ((str2double(begin_i_time(7:end)))/10^3);
for i = 2 : length(image_files)
    [~,time1,~] = fileparts(image_files(i).name);
    [~,time2,~] = fileparts(image_files(i-1).name);
    image_step(i-1) = ((str2double(time1(7:end)))/10^3) - ((str2double(time2(7:end)))/10^3);
end
jpg_step = min(image_step);


%% find begin and end timestamp of npy files

npy_folder = [directory '/*.npy'];
npy_files = dir(npy_folder);
[~,begin_d_time,~] = fileparts(npy_files(1).name);
[~,end_d_time,~] = fileparts(npy_files(length(npy_files)).name);
npy_time = ((str2double(end_d_time(7:end-4)))/10^3) - ((str2double(begin_d_time(7:end-4))/10^3)) ;
for i = 2 : length(npy_files)
    [~,time1,~] = fileparts(npy_files(i).name);
    [~,time2,~] = fileparts(npy_files(i-1).name);
    depth_step(i-1) = ((str2double(time1(7:end-4)))/10^3) - ((str2double(time2(7:end-4))/10^3)) ;
end
npy_step = min(depth_step);

%% find begin and end timestamp of laser scan file

%laser_time = max(laser_times) - min(laser_times);
for i = 2 :length(laser_times)
   laser_step = laser_times(i) - laser_times(i-1);
end

laser_step = min(laser_step);

%% find minimum timestamp, t0 and length of data

% time = max([image_time,npy_time]);
% step = min([jpg_step, npy_step,laser_step]);
%t0 = min([((str2double(begin_d_time(7:end-4))/10^3)),((str2double(begin_i_time(7:end)))/10^3)]);
time = wav_time;
step = min([jpg_step, npy_step,laser_step]);
t0 = str2double(begin_s_time);
end