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

function [numOfSegments, segs, classes] = flags2segsANDclasses(Flags, win );

% This function is used for transposing a Flags array into segs + classes %

preFlag = 1;
curFlag = 1;
numOfSegments = 0;

curVal = Flags(curFlag);
segs = [];
classes = [];
while (curFlag<length(Flags))
    stop = 0;
    preFlag = curFlag;
    preVal = curVal;
    while (stop==0)
        curFlag = curFlag + 1;
        tempVal = Flags(curFlag);
        if ((tempVal~=curVal) | (curFlag==length(Flags))) % stop
            numOfSegments = numOfSegments + 1;
            stop = 1;
            curSegment = curVal;
            curVal = Flags(curFlag);
        end            
    end
        
    segs(numOfSegments, 1) = ((preFlag-1)*win);
    segs(numOfSegments, 2) = ((curFlag-1)*win);
    classes(numOfSegments) = preVal;                            
    
end
