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

function [Labels, Times, homogeneousSegmentsPerCent, FeaturesFinal, ToUse, ProbsSmooth] = ldaCluster2_stream(fileName, timeResolution, knownNumOfSpeakers, HomoThres, nEigenVectors, fldCriterion, kNNRatio, methodFeatureSpace, methodClustering)


%
% function [Labels, Times, homogeneousSegmentsPerCent, FeaturesFinal, ToUse] = ldaCluster2_stream(fileName, timeResolution, knownNumOfSpeakers, HomoThres, methodFeatureSpace, methodClustering)
%
% This is the core function for the LDA clustering method.
% 
% ARGUMENTS:
% - fileName:           the path of the wav file to be processed
% - timeResolution:     the size of the analysis window (in seconds)
% - knownNumOfSpeakers: the number of speakers (-1 if not known)
% - HomoThres:          the threshold for the binary classification task Homogeneous segments vs NonHomogeneous segments
% - methodFeatureSpace: the method for feature space to be used for clustering
% - methodClustering:   the clustering (and preprocessing) method to be used
%
%

[a,fs] = wavread(fileName, 'size');
SignalLength = a(1);
totalWavLength = a(1) / fs;

speechThres = 0.50;
speechMidWin = 2.0;
speechMidStep = timeResolution;
stWin = 0.020;
stStep = 0.020;
ToUse = -1;

[segs, FeatureMatrix, Centers, Ps, stFeaturesPerSegment, speechSegmentsIndeces] = detectSpeech(fileName, 'speech', speechThres);
homogeneousSegmentsPerCent = 1;


% run LDA & clustering algorithm:
if (isempty(stFeaturesPerSegment))
    results = [];
else 
        
    switch (methodFeatureSpace)
        case 0
            % methodFeatureSpace 0: direct clustering (on the initial
            % feature space)
            % NORMALIZATION:           
            
            numOfSegments = length(stFeaturesPerSegment);
            [numOfDims, numOfFrames] = size(stFeaturesPerSegment{1}(10:21,:));
            F = zeros(numOfSegments, 2*numOfDims);
            for i=1:numOfSegments
                tempX = stFeaturesPerSegment{i}(10:21,:);
                [numOfDims, numOfFrames] = size(tempX);

                for (j=1:numOfDims)
                    F(i, j) = mean(tempX(j,:));
                end


                for (j=1:numOfDims)
                    F(i, numOfDims + j) = std(tempX(j,:));
                end
            end
            MEAN = mean(F);
            STD =  std(F);        
            FeaturesFinal = F;
            
            for (i=1:size(F, 1))
                FeaturesFinal(i,:) = (FeaturesFinal(i,:) - MEAN) ./ STD;
            end                        
        case 1
            % methodFeatureSpace 1: single lda:

            % % % R E M O V E    N O N  H O M O G E N E O U S   S E G M E N T S % % %
            %ToUse = get_homogeneous_segments( fileName, stFeaturesPerSegment, 'homogeneousClassifier', HomoThres );
            
            % HOMOGENEOUS SEGMENT CLASSIFIER:
            ToUse = get_homogeneous_segments( fileName, stFeaturesPerSegment, 'tempHomo', HomoThres );

            % UNCOMMENT THIS CODE TO DISABLE THE NONHOMOGENEOUS SEGMENT REMOVAL:
            ToUse(ToUse==0) = 1;
            
            % UNCIMMENT THE FOLLOWING LINES TO ENABLE THE OPTIMAL HOMOGENEOUS SEGMENT REMOVAL (IE ALL REAL NONHOMOGENEOUS SEGMENTS ARE REMOVED):
            %              trsFileName = fileName;
            %              Iwav = strfind(trsFileName,'.wav');
            %              trsFileName(Iwav:Iwav+10) = '_manual.trs';
            %              [TimesR, LabelsR] = readTrsFileSpeakers_Canal9(trsFileName, 1);
            %              LabelsR2 = makeLabelsSuccessive(LabelsR); 
            %              LabelsR2 = LabelsR2(speechSegmentsIndeces);             
            %              numOfSpeakersR = zeros(length(LabelsR2), 1);
            %              for (i=1:length(LabelsR2))
            %                 numOfSpeakersR(i) = length(LabelsR2{i});
            %              end
            %              ToUseR = (numOfSpeakersR==1);
            %              ToUse = ToUseR;

            homogeneousSegmentsPerCent = length(find(ToUse==1)) / length(ToUse);            
             
            % END OF NON HOMOGENEOUS SEGMENT REMOVAL
            
            
            % LDA: 
            
            % UNCOMMENT THE FOLLOWING CODE FOR OPTIMAL LDA LABEL ESTIMATION %             
%             trsFileName = fileName;
%             Iwav = strfind(trsFileName,'.wav');
%             trsFileName(Iwav:Iwav+10) = '_manual.trs';
%             [TimesR, LabelsR] = readTrsFileSpeakers_Canal9(trsFileName, 1);
%             LabelsR2 = makeLabelsSuccessive(LabelsR); 
% 
%             LabelsR2Mat = zeros(length(LabelsR2), 1);
%             for (i=1:length(LabelsR2))
%             if (length(LabelsR2{i})>0)
%                     LabelsR2Mat(i) = LabelsR2{i}(1);
%                 end
%             end
%             LabelsR2Mat = LabelsR2Mat - 1;
%             
%             LabelsR2Mat = LabelsR2Mat(speechSegmentsIndeces);
%             stFeaturesPerSegment = stFeaturesPerSegment(find(LabelsR2Mat>0));
%             ToUse = ToUse(find(LabelsR2Mat>0));
%             speechSegmentsIndeces = speechSegmentsIndeces(LabelsR2Mat>0);
%             LabelsR2Mat = LabelsR2Mat(LabelsR2Mat>0);
%             [eigvectors, FF] = ldaData(stFeaturesPerSegment, 50, 1, nEigenVectors, ToUse, 2500, LabelsR2Mat);            
            % % % % 
            
            
            [FF, dataLDA, labelsLDA ] = ldaData(fileName, stFeaturesPerSegment, 50, 1, nEigenVectors, ToUse, 2500, []);
            [ eigvectors, eigvalueSum ] = fld( dataLDA, labelsLDA, nEigenVectors, fldCriterion );
            %load modelCanal9_part
            %load german10
            %load chains_retell
            %load umich
            %eigvectors = eigvectors(:, 1:nEigenVectors);
            
            
            %[eigvectors, FF] = ldaData_GT(stFeaturesPerSegment, fileName, speechSegmentsIndeces, nEigenVectors);
            
            FeaturesFinal = FF * eigvectors;    
            
            % USE THIS FOR RCA:
            % FeaturesFinal = FeaturesFinal * WW;
            
    end    
        
    % CLUSTERING:
    switch (methodClustering)
        case 0 %  clustering:
            
            if (knownNumOfSpeakers>0)
                results = clusterSegments(FeaturesFinal, knownNumOfSpeakers);
                [Times, Labels] = clusteResults2LabelsAndTimes(results, speechSegmentsIndeces, totalWavLength, timeResolution);
            else
                % load durationData.mat; for (i=1:length(oDurs)) oDurM{i} = mean(oDurs{i}); end
                MIN_sp = 3;
                MAX_sp = 5;
                for (i=MIN_sp:MAX_sp)
                    [results, Sil(i)] = clusterSegments(FeaturesFinal, i);                
                    [Times{i}, Labels{i}] = clusteResults2LabelsAndTimes(results, speechSegmentsIndeces, totalWavLength, timeResolution);                    
                    SilFeatures(i) = computeClusteringStatistics_audioFeatures(Labels{i}, Times{i}, FeaturesFinal, speechSegmentsIndeces);
                end
                SilFeatures = SilFeatures(MIN_sp:end) .* ([MIN_sp:MAX_sp].^(1/4));                
                Sil = Sil(MIN_sp:end);
                
                P_silF = SilFeatures; P_silF = P_silF / sum(P_silF);
                P = P_silF;
                [MAX, IMAX] = max(P);
                nSpeakers = MIN_sp + IMAX - 1;                
                Labels = Labels{nSpeakers};
                Times = Times{nSpeakers};                                
            end
            ProbsSmooth = []; % TODO: 
                                    
        case 1 % clustering and smoothing
            
            if (knownNumOfSpeakers>0)
                [results] = clusterSegments(FeaturesFinal, knownNumOfSpeakers);                
                [Times, Labels] = clusteResults2LabelsAndTimes(results, speechSegmentsIndeces, totalWavLength, timeResolution);
                %for sm=1:7
                sm = 0;
                while (1)
                    disp( 'smoothing')
                    sm = sm + 1;
                    LabelsT = Labels;
                    [Labels, ProbsSmooth] = clusterSmooth(Labels, FeaturesFinal, speechSegmentsIndeces, kNNRatio);
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
                        [Labels{i}, ProbsSmooth{i}] = clusterSmooth(Labels{i}, FeaturesFinal, speechSegmentsIndeces, kNNRatio);
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
                ProbsSmooth = ProbsSmooth{nSpeakers};
                Times = Times{nSpeakers};               
            end
    end    
end


% Post process labels so that their values are successive (1,2,3 etc)
Labels = makeLabelsSuccessive(Labels) - 1; % (zero is needed for non speech segments!!!)
