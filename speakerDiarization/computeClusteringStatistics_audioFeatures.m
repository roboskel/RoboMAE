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

function S = computeClusteringStatistics_audioFeatures(Labels, Time, FeaturesFinal, speechSegmentsIndeces)

% function [Da, Db] = computeClusteringStatistics_duration(Labels, Time, oDur)
% 
% This function computes a particular clustering's statistics, related to
% the average speaker percentage (Da) and the duration of the segments (Db) 
% 
% 

step = Time(2)-Time(1);

[numOfSegments, segs, classes] = flags2segsANDclasses(Labels, step);

segsDur = [];
F_segments = []; % average (per speaker segment) features
Classes = []; % non-speech is not included
for (i=1:size(segs,1))
    if (classes(i)>0) && (segs(i,2)-segs(i,1))>2
        segsDur(end+1) = segs(i,2)-segs(i,1);
        L1 = round(segs(i,1)/step)+1;
        L2 = round(segs(i,2)/step);
        I1 = find(speechSegmentsIndeces==L1);
        I2 = find(speechSegmentsIndeces==L2);
        if isempty(I1) continue; end
        if isempty(I2) continue; end
        
        Ftemp = FeaturesFinal( I1:I2  , :);
        
        F_segments = [F_segments;mean(Ftemp,1)];
        Classes(end+1) = classes(i);
        
    end
end
%figure;
%hold on;
%Colors = {'r','g','b','k','c','y','m'};
%for (i=1:size(F_segments,1))
%    plot(F_segments(i,1), F_segments(i,2), [Colors{Classes(i)} '*']);
%end

[S, Sall] = silhouette(Classes, F_segments);
