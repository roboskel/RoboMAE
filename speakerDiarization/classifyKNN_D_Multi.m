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

function [Ps, winnerClass] = classifyKNN_D_Multi(F, testSample, k, NORMALIZE, useL1distance )

% function [Ps, winnerClass] = classifyKNN_D_Multi(F, testSample, k, NORMALIZE, useL1distance);
% 
% This function is used for classifying an uknown sample using the kNN
% algorithm, in its multi-class form.
%
% ARGUMENTS:
% - F: an CELL array that contains the feature values for each class. I.e.,
%      F{1} is a matrix of size numOfDimensions x numofSamples FOR THE FIRST
%      CLASS, etc.
%
% - testSample: the input sample to be classified
% - k: the kNN parameter
% - NORMALIZE: use class priors to weight results
% - useL1distance: use L1 instead of L2 distance
%
% RETURNS:
% - Ps: an array that contains the classification probabilities for each class
% - winnerClass: the label of the winner class

error( nargchk(4,5,nargin) )

if ( nargin < 5 )
    useL1distance = false;
end

numOfClasses = length(F);
if (size(testSample, 2)==1)
    testSample = testSample';
end

% initilization of distance vectors:
numOfDims = zeros( 1, numOfClasses );
numOfTrainSamples = zeros( 1, numOfClasses );

d = cell(numOfClasses,1);
% d{i} is a vector, whose elements represent the distance of the testing
% sample from all the samples of i-th class
for i=1:numOfClasses
    [ numOfDims(i), numOfTrainSamples(i) ] = size( F{i} );
    d{i} = inf*ones(max(numOfTrainSamples), 1); % we fill it with inf values
end

if (length(testSample)>1)
    for i=1:numOfClasses % for each class:
        if (numOfTrainSamples(i)>0)
            if ( useL1distance )
                d{i} = sum( abs(repmat(testSample, [numOfTrainSamples(i) 1]) - F{i}'),2); % L1
            else
                d{i} = sum( ((repmat(testSample, [numOfTrainSamples(i) 1]) - F{i}').^2 ),2); % L2
            end
            d{i} = sort(d{i});
            d{i}(end+1:max(numOfTrainSamples)) = inf;
        else
            d{i} = inf;
        end
    end
else % single dimension (NO SUM required!!!)
    for i=1:numOfClasses
        if (numOfTrainSamples(i)>0)
            d{i}   = (abs(repmat(testSample, [numOfTrainSamples(i) 1]) - F{i}')'); 
            d{i} = sort(d{i});
            d{i}(end+1:max(numOfTrainSamples)) = inf;
        else
            d{i} = inf;
        end
    end    
end

kAll = zeros(numOfClasses, 1);

for j=1:k
    curArray = zeros(numOfClasses, 1);
    for i=1:numOfClasses
        curArray(i) = d{i}(kAll(i)+1);
    end
    [MIN, IMIN] = min(curArray);
    kAll(IMIN) = kAll(IMIN) + 1;
end

if ( NORMALIZE == 0 )
    Ps = (kAll ./ k);
else
    Ps = kAll ./ numOfTrainSamples';
    Ps = Ps / sum(Ps);
end

[MAX, IMAX] = max(Ps);
winnerClass = IMAX;

