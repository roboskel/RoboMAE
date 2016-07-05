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

function [F] = generateDataForLDA(segments, MEAN, STD, W, S, labelsLDA_force) 

[numOfDims, numOfFrames] = size( segments{1} );

F = zeros( length(segments) * floor( ( numOfFrames - W) / S ), 2 * numOfDims + 1); 
count = 0;
for i = 1 : length(segments) % for each segment:
	segment = segments{i}; % current segment
    [numOfDims, numOfFrames] = size( segment );
    if ( numOfFrames - W <= S)
        continue;
    end
    for w1 = 1 : S : numOfFrames - W	
        w2 = w1 + W;
        count = count + 1;
        F(count, :) = [( [ mean( segment( :, w1 : w2 ), 2 ) ; std( segment( :, w1 : w2 ), 0, 2) ]' - MEAN ) ./ STD i];
        if (~isempty(labelsLDA_force))
            F(count,end) = labelsLDA_force(i);
        end
    end    
end
F( count + 1 : end, : ) = []; % remove extra rows
