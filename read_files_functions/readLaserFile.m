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


function [Time, Angles, LaserScans] = readLaserFile(fileName)

% function [Time, LaserScans] = readLaserFile(fileName)
% 
% This function reads a laser scan file
% 
% ARGUMENTS:
%  - fileName:      the full path of the laser scan file
%
% RETURNS:
%  - Time:          a 1-D array that contains the timestams (seconds) of
%                   each time frame
%  - Angles:        1-D array that contains the angles of the laser scan
%  - LaserScan:     a matrix whose rows represent the laser scans (columns
%                   represent the 0..180 degres range 
%

% get all lines of filename
file = textread(fileName,'%s','delimiter','\n','whitespace','', 'bufsize', 15000);
Time = zeros(length(file), 1);
temp = textscan(file{1}(6:end),'%f'); 
temp = temp{1};
LaserScans = zeros(length(file), length(temp)-2);
for i=1:length(file) % for each line in the file            
    temp = textscan(file{i}(6:end),'%f');
    temp = temp{1};
    Time(i) = (temp(1))  / 10^3;
    LaserScans(i, :) = temp(3:end);
end

Step = 180 / (size(LaserScans, 2)-1);
Angles = 0:Step:180;