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


frames = SP(:,2);
            bboxes = SP(:,3);
            bboxes2track  = cell2mat(bboxes);
            bboxes2track = bboxes2track(1,:);
            frames = cell2mat(frames);
            OUTPUT = FaceMSTracking(image,target, idx1, idx2);
            
            
            % find start and end frames
            jpg_files = dir([folder filesep '*.jpg']);
            start_frame = frames(1);
            [~,jpg_file1, ~,~] = find_modality_files(folder,start,start_frame ,laser.time);
            fileindex1 = structfind(jpg_files,'name',jpg_file1);
            end_frame = frames(2);
            [~,jpg_file2, ~,~] = find_modality_files(folder,start,end_frame ,laser.time);
            fileindex2 = structfind(jpg_files,'name',jpg_file2);
            T = cell2mat(SP(1,4));