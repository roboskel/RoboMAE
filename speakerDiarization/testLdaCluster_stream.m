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

function [SpeechPr, SpeechRe, numOfClustersReal, numOfClustersDetected, purityClusterMean, puritySpeakerMean, dJoint, dMax, CER, homogeneousSegmentsPerCent] = ...
    testLdaCluster_stream(fileName, timeResolution, knownNumOfSpeakers, HomoThres, nEigenVectors, fldCriterion, kNNRatio, methodFeatureSpace, methodClustering, PLOT)

% TODO: change time resolution !!!!
[Labels, Times, homogeneousSegmentsPerCent] = ldaCluster_stream(fileName, timeResolution, knownNumOfSpeakers, HomoThres, nEigenVectors, fldCriterion, kNNRatio, methodFeatureSpace, methodClustering);

trmf = 1; % this is the resize ratio (USE 1 for not changing the resolution)
timeResolution = timeResolution / trmf;
Labels2 = imresize(Labels, [1 trmf*length(Labels)],'nearest');
Times2 = imresize(Times, [1 trmf*length(Times)],'nearest');
Labels = Labels2;
Times = Times2;


fileNameTrs = fileName;
fileNameTrs(strfind(fileNameTrs, '.wav'):strfind(fileNameTrs,'.wav')+3) = ''; % remove the .wav extension
fileNameTrs = [fileNameTrs '_manual.trs'];

% find the number of detected clusters
% (get unique values and remove 0, because it means non-speech segments):
uLabels = unique(Labels); uLabels(find(uLabels==0)) = [];
numOfClustersDetected = length(uLabels);

fp = fopen(fileNameTrs,'r');
if (fp<0)
    SpeechPr = -1;
    SpeechRe = -1;
    numOfClustersReal = -1;    
    purityClusterMean = -1;
    puritySpeakerMean = -1;    
    Admax = -1;
    dJoint = -1;
    dMax = -1;
    CER = -1;
    return;    
end
fclose(fp);

% read ground truth:
[realTimes, realLabels] = readTrsFileSpeakers_Canal9(fileNameTrs, timeResolution);

% find the number of real clusters
uRealLabels = unique(cell2mat(realLabels));
uRealLabels(find(uRealLabels==0)) = [];
numOfClustersReal = length(uRealLabels);

MinLength = min([length(realLabels) length(Labels)]);
Labels = Labels(1:MinLength);
realLabels = realLabels(1:MinLength);

CMspeech = zeros(2);

LabelsOnlySpeechBoth = {};
realLabelsOnlySpeechBoth = {};

for i=1:length(Labels)
    if (Labels(i)>0) && (sum(realLabels{i})==0) % false alarm speech
        CMspeech(2,1) = CMspeech(2,1) + 1;
    end
    if (Labels(i)==0) && (sum(realLabels{i})>0) % false negative speech
        CMspeech(1,2) = CMspeech(1,2) + 1;
    end
    if (Labels(i)==0) && (sum(realLabels{i})==0) % true negative speech
        CMspeech(2,2) = CMspeech(2,2) + 1;
    end
    if (Labels(i)>0) && (sum(realLabels{i})>0) % true positive speech
        CMspeech(1,1) = CMspeech(1,1) + 1;
        LabelsOnlySpeechBoth{end+1} = Labels(i);
        realLabelsOnlySpeechBoth{end+1} = realLabels{i};
    end    
end

for (i=1:length(realLabelsOnlySpeechBoth))
    realLabelsOnlySpeechBoth{i}(find(realLabelsOnlySpeechBoth{i}==0)) = [];
end

% make labels sequenctial:
LabelsOnlySpeechBoth = makeLabelsSuccessive(LabelsOnlySpeechBoth);
realLabelsOnlySpeechBoth = makeLabelsSuccessive(realLabelsOnlySpeechBoth);


SpeechRe = CMspeech(1,1) / (CMspeech(1,1)+CMspeech(1,2));
SpeechPr = CMspeech(1,1) / (CMspeech(1,1)+CMspeech(2,1));

% performance measures:
n_table = contigencyTable(LabelsOnlySpeechBoth, realLabelsOnlySpeechBoth, 1);
[purityClusterMean, puritySpeakerMean, purityCluster, puritySpeaker] = computeErrorClusterPurityMatrix(n_table);
[dJoint, dMax] = computeInformationMeasuresForClustering(n_table);
[CM, LabelMapping] = computeCER(n_table);

if (size(CM,1)==1) || (size(CM,2)==1)
    CER = CM(1,1) /  sum(sum(CM));
else
    CER = sum(diag(CM)) / sum(sum(CM));
    % TODO: USE THIS TO ALSO INCLUDE THE OVERLAPPING SPEAKERS FROM GROUND
    % TRUTH
    %for i=1:length(realLabels) numOfRealLabels(i) = length(realLabels{i}); end
    %CER = (sum(diag(CM))+length(find(numOfRealLabels>1))) / (sum(sum(CM))+sum(numOfRealLabels(numOfRealLabels>1)));
end

if (PLOT==1)
    figure;
    LabelsTemp = zeros(size(Labels));
    for (i=1:length(Labels))
        if (Labels(i)>0)
            Labels(i) = LabelMapping(Labels(i));
        end
    end
    plot(Times, Labels);
    hold on;
    % realLabels can be of multiple speakers at the same time:
    for (i=1:length(realLabels))
        for (j=1:length(realLabels{i}))            
            plot(Times(i), realLabels{i}(j)+0.05,'*r')
        end
    end
end
