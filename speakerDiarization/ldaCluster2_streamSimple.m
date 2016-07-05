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

function [Labels, Times, homogeneousSegmentsPerCent, FeaturesFinal, ToUse] = ldaCluster2_streamSimple(fileName, knownNumOfSpeakers, manualKnowledgeMatFile)

addpath('clustTool/');
timeResolution = 1;
HomoThres = 0.025;
nEigenVectors = 3;
fldCriterion = 1;
kNNRatio = 0.15;
methodFeatureSpace = 1;
methodClustering = 1;


% SPEECH DETECTION:

[a,fs] = wavread(fileName, 'size');
SignalLength = a(1);
totalWavLength = a(1) / fs;

speechThres = 0.50; ToUse = -1;

[segs, FeatureMatrix, Centers, Ps, stFeaturesPerSegment, speechSegmentsIndeces] = detectSpeech(fileName, 'speech', speechThres);
homogeneousSegmentsPerCent = 1;

% HOMOGENEOUS SEGMENT CLASSIFIER:
ToUse = get_homogeneous_segments( fileName, stFeaturesPerSegment, 'tempHomo', HomoThres );
% UNCOMMENT THIS CODE TO DISABLE THE NONHOMOGENEOUS SEGMENT REMOVAL:
ToUse(ToUse==0) = 1;                                   
[FF, dataLDA, labelsLDA ] = ldaData(fileName, stFeaturesPerSegment, 50, 1, nEigenVectors, ToUse, 2500, []);
if exist(manualKnowledgeMatFile)
    labelsLDA2 = updateLabels(fileName, manualKnowledgeMatFile, labelsLDA, speechSegmentsIndeces, timeResolution);
    labelsLDA = labelsLDA2;
end

[ eigvectors, eigvalueSum ] = fld( dataLDA, labelsLDA, nEigenVectors, fldCriterion );            
FeaturesFinal = FF * eigvectors;                                                                       
            
            if (knownNumOfSpeakers>0)
                [results] = clusterSegments(FeaturesFinal, knownNumOfSpeakers);                
                [Times, Labels] = clusteResults2LabelsAndTimes(results, speechSegmentsIndeces, totalWavLength, timeResolution);
                %for sm=1:7
                sm = 0;
                while (1)
                    disp( 'smoothing')
                    sm = sm + 1;
                    LabelsT = Labels;
                    [Labels] = clusterSmooth(Labels, FeaturesFinal, speechSegmentsIndeces, kNNRatio);
                    percentLabelsChanged = 100*sum(Labels~=LabelsT) / length(LabelsT);
                    if percentLabelsChanged<0.1
                        fprintf('         smoothing stoped at %5d (%10.2f)\n', sm, percentLabelsChanged);
                        break;
                    end
                end                                                                             
                %untitled
            else                
                MIN_sp = 3;
                MAX_sp = 5;
                for (i=MIN_sp:MAX_sp)
                    [results, Sil(i)] = clusterSegments(FeaturesFinal, i);           
                    [Times{i}, Labels{i}] = clusteResults2LabelsAndTimes(results, speechSegmentsIndeces, totalWavLength, timeResolution);
                    sm = 0;
                    %for sm=1:7
                    while (1)
                        sm = sm + 1;
                        LabelsT = Labels{i};
                        [Labels{i}] = clusterSmooth(Labels{i}, FeaturesFinal, speechSegmentsIndeces, kNNRatio);
                        percentLabelsChanged = 100*sum(Labels{i}~=LabelsT) / length(LabelsT);
                        if percentLabelsChanged<0.1
                            fprintf('         smoothing stoped at %5d (%10.2f)\n', sm, percentLabelsChanged);
                            break;
                        end

                    end
                    SilFeatures(i) = computeClusteringStatistics_audioFeatures(Labels{i}, Times{i}, FeaturesFinal, speechSegmentsIndeces);
                end
                SilFeatures = SilFeatures(MIN_sp:end) .* ([MIN_sp:MAX_sp].^(1/4));                
                Sil = Sil(MIN_sp:end);
                
                P_silF = SilFeatures; 
                P_silF = P_silF / sum(P_silF);
                P = P_silF;
                [MAX, IMAX] = max(P);
                nSpeakers = MIN_sp + IMAX - 1;
                Labels = Labels{nSpeakers};
                Times = Times{nSpeakers};               
            end    


% Post process labels so that their values are successive (1,2,3 etc)
Labels = makeLabelsSuccessive(Labels) - 1; % (zero is needed for non speech segments!!!)



function labelsLDA2 = updateLabels(wavFileName, matFileName, labelsLDA, speechSegmentsIndeces, timeResolution)


[x,fs] = wavread(wavFileName);
load(matFileName)
[nSegments, ~] = size(audio_rgb);
SegsManual = [];
for i=1:nSegments
    [x,fs] = wavread(wavFileName, round(fs * [audio_rgb{i,2} audio_rgb{i,3}]) + 1);
    SegsManual(i, :) = [audio_rgb{i,2} audio_rgb{i,3}];
    LabelsManual{i} = audio_rgb{i,1};
end
uLabelsManual = unique(LabelsManual);
for i=1:length(LabelsManual)
    LabelsManual2(i) = find(not(cellfun('isempty', strfind(uLabelsManual,LabelsManual{i}))));
end

SegsManual = round(SegsManual);
labelsLDA2 = labelsLDA;
MAXLDALABELS = max(labelsLDA);
for i=1:size(SegsManual, 1)
    curLimtis = SegsManual(i,:);    
    for c=curLimtis(1):curLimtis(2)
        SpeechIndecesToChange = (find(c==speechSegmentsIndeces * timeResolution));
        if ~isempty(SpeechIndecesToChange)            
            labelsLDA2((SpeechIndecesToChange-1) * 50 + 1 : (SpeechIndecesToChange) * 50) = LabelsManual2(i) + MAXLDALABELS;
            LabelsManual2(i) + MAXLDALABELS;
        end
    end
end
%plot(labelsLDA)
%hold on
%plot(labelsLDA2,'r')