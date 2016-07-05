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


function [image_file, laser_time ,npy_file,stick_time] = find_modality_files(folder,start_timestamp,slider_position,lasertime,stickmodel)
    
    % start_time is the first timestamp of the files (CPU clock)
    % current_time is the 
    current_timestamp = start_timestamp + slider_position;
    
    %% find .stick file
    if stickmodel ~=0
        stick_begin = stickmodel(1);
        d0 = abs(stick_begin - current_timestamp );
        for i = 2 : length(stickmodel)
            d1 = abs(stickmodel(i) - current_timestamp);
            if d1 > d0
                stick_time = i-1;
                break;
            end
            d0 = d1;
            stick_time = i;
        end
    else
        stick_time = 0;
    end
    
    
    %% find.jpg file
    file_name = [folder filesep '*.png'];
    jpg_files = dir(file_name);
    [~,tms_jpg_1,~] = fileparts(jpg_files(1).name(7:end));
    tms_jpg_1 = str2double(tms_jpg_1)/10^3;
    d0 =  abs(current_timestamp - tms_jpg_1);
    for i = 2 : length(jpg_files)
        [~,tms_jpg_i,~] = fileparts(jpg_files(i).name(7:end));
        jpg_tmp =  str2double(tms_jpg_i)/10^3;
        d1 = abs(current_timestamp - jpg_tmp );
        if d1 > d0
            image_file = jpg_files(i-1).name;
            break;
        end
        d0 = d1;
        image_file = jpg_files(i).name;
    end
    
    %% find laser data
    
    laser_begin = lasertime(1);
    d0 = abs(laser_begin - current_timestamp );
    for i = 2 : length(lasertime)
        d1 = abs(lasertime(i) - current_timestamp);
        if d1 > d0
            laser_time = i-1;
            break;
        end
        d0 = d1;
        laser_time = i;
    end
    
   
    %% find depth data file
    
    file_name = [folder filesep '*.npy'];
    npy_files = dir(file_name);
    [~,tms_npy_1,~] = fileparts(npy_files(1).name(7:end-4));
    tms_npy_1 = str2double(tms_npy_1)/10^3;
    d0 =  abs(current_timestamp - tms_npy_1);
    for i = 2 : length(npy_files)
        [~,tms_npy_i,~] = fileparts(npy_files(i).name(7:end-4));
        tmp_npy = str2double(tms_npy_i)/10^3;
        d1 = abs(current_timestamp - tmp_npy);
        if d1 > d0
            npy_file = npy_files(i-1).name;
            break;
        end
        d0 = d1;
        npy_file = npy_files(i).name;
    end
    
    
end