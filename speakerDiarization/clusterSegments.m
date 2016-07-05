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

function [results, Sil] = clusterSegments(F2, knownNumOfSpeakers)

%
% function [results, Sil] = clusterSegments(F2, knownNumOfSpeakers)
% 
% This function clusters a feature vector sequence.
% 
% ARGUMENTS:
% - F2:                 [numOfFSamples x numOfDims] feature matrix 
%                       (rows represent feature vectors)
% - knownNumOfSpeakers  number of clusters
%
% RETURNS:
% - results             [numOfSamples x 1] array that contains cluster labels
% - Sil                 Silhouette measure for the resulting clustering
%

% y = myKmeansCluster(F2, knownNumOfSpeakers);
% results = y(:,end);

param.c = knownNumOfSpeakers;
param.vis = 0;
data.X = F2;
result = GKclust(data,param);%result = kmedoid(data, param);

results = result.data.f;
resultsNew = zeros(size(results,1),1);
for (i=1:size(results,1))
    tempR = results(i,:);
    [MAX, resultsNew(i)] = max(tempR);
end
results = resultsNew;

[Sil, Sall] = silhouette(results, F2);
