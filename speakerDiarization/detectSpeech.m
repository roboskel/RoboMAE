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

function [segs, FeatureMatrix, Centers, Ps, stFeaturesPerSegment, speechSegmentsIndeces] = detectSpeech(fileName, modelName, Pthres)


win = 0.020;
step = 0.020;
winMid = 2.0;
stepMid = 1.0;


% function [segs] = detectSpeech(fileName, winMid, stepMid, F1, F2, MEAN, STD, Pthres)
%
% This function detects speech segments in a wav file
% 
% ARGUMENTS:
%  - fileName: the path of the WAV file to be analysed
%  - modelName: the path of the speech vs non-speech model
%  - Pthres: the threshold of the speech probability, used in the speech
%  detection stepMid
%
% RETURNS:
%  - segs: a [Nx2] matrix. Each line of segs contains the boundaries of the
%  respective speech segment. E.g., segs(2,1) is the begining of the 2nd
%  segment, while segs(2,2) is the end point of the 2nd segment.
%  - FeatureMatrix: a matrix that contains the feature vectors of each
%  audio segment
%  - Centers: the time positions of the centers of the mid-term segments
%
% Theodoros Giannakopoulos
% (c) 2012
% http://www.di.uoa.gr/~tyiannak
%

% LOAD the speech tracking classifier:
load(modelName)
% compute MEAN and STD of the two classes (SPEECH vs NON-SPEECH)
M1 = mean(F1fld); S1 = std(F1fld);
M2 = mean(F2fld); S2 = std(F2fld);

% get file info (length, sampling rate etc)
[a,fs] = wavread(fileName, 'size'); SignalLength = a(1);

% mid-term feature extraction:
[midFeatures, Centers, stFeaturesPerSegment] = featureExtractionFile(fileName, win, step, winMid, stepMid, listOfStatistics);
% dimensionality reduction (used in speech tracking):
FeatureMatrix = midFeatures' * eigV;
Ps = zeros(size(FeatureMatrix,1),1);
for (i=1:size(FeatureMatrix,1))
    FF = FeatureMatrix(i, :);
    % use the GAUSSIAN 1-D classifier to compute the speech probability (based on the fld features):
    P1 = (1/(S1*sqrt(2*pi))) * exp((-1/2) * ((FF-M1)/S1).^2);
    P2 = (1/(S2*sqrt(2*pi))) * exp((-1/2) * ((FF-M2)/S2).^2);    
    Ps(i) = P1 / (P1 + P2);
end

% smoothing:
medFiltWin = 2; % Window size for smoothing (seconds):
medFiltWin = round(medFiltWin / (stepMid)); % convert to number of mid-term wins
Ps = medfilt1(double(Ps), medFiltWin);

% get speech flags by thresholding:
FlagsSpeech = (Ps>Pthres);

% flags to segments:
[numOfSegments, segs, classes] = flags2segsANDclasses(FlagsSpeech, round(stepMid*fs));
count = 0;
segs2 = [];
for (i=1:numOfSegments)
    if (classes(i)==1)
        count = count + 1;
        segs2(count,:) = segs(i,:);
    end
end

% delete very small segments:
count = 0;
segs = segs2;
segs2 = [];
for (i=1:size(segs,1))
    if ((segs(i,2)-segs(i,1)) / fs >= 1)
        count = count + 1;
        segs2(count, :) = segs(i,:);
    end
end

segs = segs2;
segs = segs  / fs;


% COMPUTE speechSegmentsIndeces
numOfSpeechSegments = size(segs, 1); % total number of speech segments
count = 0;
speechSegmentsIndeces = [];
midWin = round(winMid*fs);
midStep = round(stepMid*fs);

for i=1:numOfSpeechSegments % for each speech segment
    L1 = round(segs(i,1)  * fs);
    L2 = round(segs(i,2)  * fs);
 
    if (L1<=0) L1 = 1; end
    if (L1>=SignalLength) continue; end
    if (L2>=SignalLength); L2 = SignalLength; end
    if (L2<=1) continue; end
    
    curLength = L2 - L1 + 1;
    curPos = 1;
    while (curPos + midWin <= curLength) % for each midWindow:      
        count = count + 1;
        speechSegmentsIndeces(count) = ((L1 + curPos - 1) / fs);
        curPos = curPos + midStep;
    end    
end

for (i=1:length(speechSegmentsIndeces))
    stFeaturesPerSegmentn{i} = stFeaturesPerSegment{speechSegmentsIndeces(i)};
end
stFeaturesPerSegment = stFeaturesPerSegmentn;


