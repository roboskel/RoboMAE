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

function [F1, F2, MEAN, STD] = trainSpeech(dir1, dir2, mtWin, mtStep, listOfStatistics, modelName)

%
% this function calculates all features and saves speech model to modelName
% 
% This function can be used for feature extraction of audio files stored in
% two directories.
%

win = 0.020;
D1 = dir([dir1 filesep '*.wav']);
D2 = dir([dir2 filesep '*.wav']);
%W = waitbar(0,str);
F1 = [];
F2 = [];
for (i=1:length(D1))  
    fileName = [dir1 filesep D1(i).name];    
    midFeatures = featureExtractionFile(fileName, win, win, mtWin, mtStep, listOfStatistics);
    % long-term averaging of feature statistics:
    midFeatures = mean(midFeatures, 2);    
    if length(find(isnan(midFeatures)))>0
        disp('a');
    end
    F1 = [F1 midFeatures];
end

for (i=1:length(D2))  
    fileName = [dir2 filesep D2(i).name];    
    midFeatures = featureExtractionFile(fileName, win, win, mtWin, mtStep, listOfStatistics);
    % long-term averaging of feature statistics:
    midFeatures = mean(midFeatures, 2);
    F2 = [F2 midFeatures];
end

% cut if two classes have different size:
numOfSamples1 = size(F1, 2);
numOfSamples2 = size(F2, 2);
numOfSamples = min([numOfSamples1;numOfSamples2]);
F1 = F1(:,1:numOfSamples);
F2 = F2(:,1:numOfSamples);

% dimensionality reduction:
nDim = 1;
X = [F1'; F2']; L = [zeros(size(F1, 2),1); ones(size(F2, 2),1)];
[eigV, eigvalueSum] = fld(X, L, nDim);
F1fld = eigV' * F1;
F2fld = eigV' * F2;
save(modelName, 'F1', 'F2', 'listOfStatistics','eigV','F1fld','F2fld');

