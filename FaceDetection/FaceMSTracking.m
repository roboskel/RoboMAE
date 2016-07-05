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


function [speakers, laser] = FaceMSTracking( I,target,frame_seq,speakers,laser,ratio,angles,objects )

%   FaceMSTracking uses Mean-Shift Tracking for Face tracking for a
%   series of images
%   Inputs: image is the current image
%   target is the face we want to track (cropped face image from bbox)
%   idx1 is the frame index of the first image
%   idx2 is the frame index of the last image


init_frame = cell2mat(frame_seq(1));
color = target.clr;
name = target.name;
T = target.fImage;
x0 = target.bbox(1);
y0= target.bbox(2);
W= target.bbox(3);
H = target.bbox(4);
ID = target.ID;
[height,width,~] = size(I);
Length = size(frame_seq,1) ;

% speaker's properties
speaker.name = name;
speaker.color = color;
speaker.bbox = target.bbox;
SPEAKER{1} = speaker;

%% Variables 
index_start = 1;
% Similarity Threshold
f_thresh = 0.16;
% Number max of iterations to converge
max_it = 5;
% Parzen window parameters
kernel_type = 'Gaussian';
radius = 1;
e = 0.001;
no_laser = 1;

%% Run the Mean-Shift algorithm
% Calculation of the Parzen Kernel window
[k,gx,gy] = Parzen_window(H,W,radius,kernel_type,0);
% Conversion from RGB to Indexed colours
% to compute the colour probability functions (PDFs)
[I,map] = rgb2ind(I,65536);
Lmap = length(map)+1;
T = rgb2ind(T,map);
% Estimation of the target PDF
q = Density_estim(T,Lmap,k,H,W,0);
% Flag for target loss
loss = 0;
% Similarity evolution along tracking
f = zeros(1,(Length-1)*max_it);
% Sum of iterations along tracking and index of f
f_indx = 1;

%%%% TRACKING
mesg = ['Tracking ' name  ', be patient...'];
WaitBar = waitbar(0,mesg);
% From 1st frame to last one
for t=2:Length-1 
    % Next frame
    I2 = cell2mat(frame_seq(t+1,:));
    I2 = imread(I2);
    I2 = rgb2ind(I2,map);
    % Apply the Mean-Shift algorithm to move (x,y)
    % to the target location in the next frame.
    [x,y,loss,f,f_indx] = MeanShift_Tracking(q,I2,Lmap,...
        height,width,f_thresh,max_it,x0,y0,H,W,k,gx,...
        gy,f,f_indx,loss);
    % Check for target loss. If true, end the tracking
    if loss == 1
        break;
    else
        
        curr_frame = t-1+init_frame;
        try 
            LASER = laser{curr_frame};
        catch
            no_laser = 0;
            LASER = [];
        end
       
        if strcmp(objects,'Laser') | strcmp(objects,'Both')
            %track the laser
            laser_tmp = laser{curr_frame};
            laser_tmp = laser_tmp(laser_tmp(:,6) == ID,:);
            diff_lasertrack = x0-x;
            for i = 1 : size(laser_tmp,1)
                point1 = find(angles < laser_tmp(:,1) + e & angles >  laser_tmp(:,1) - e );
                point2 = find(angles < laser_tmp(:,2) + e & angles >  laser_tmp(:,2) - e );
                laser_mapping = floor(diff_lasertrack/ratio);
                if point1 - laser_mapping <= 0
                    diff_1 = 0;
                elseif point2 - laser_mapping > length(angles)
                    diff_2 = length(angles);
                else
                    diff_1 = point1 - laser_mapping;
                    diff_2 = point2 - laser_mapping;
                end
                laser{curr_frame} = [LASER;angles(diff_1) angles(diff_2) color ID];
            end
        end
        if strcmp(objects,'Faces') | strcmp(objects,'Both')
            % Next frame becomes current frame
            y0 = y;
            x0 = x;
            speaker.name = name;
            speaker.color = color;
            speaker.bbox = [x,y,W,H];
            speaker.ID = ID;
        end
        % Updating the waitbar
        waitbar(t/(Length-1));
       
        
        eval(['speakers{' num2str(curr_frame) '}.' name '= speaker;']);
        
         
    end
end
close(WaitBar);
%%%% End of TRACKING



end

