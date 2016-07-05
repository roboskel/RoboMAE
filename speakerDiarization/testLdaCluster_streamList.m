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
    testLdaCluster_streamList(fileNames, numOfKnownSpeakers, timeResolution, HomoThres, nEigenVectors, fldCriterion, kNNRatio, methodFeatureSpace, methodClustering)

fprintf('%70s%8s%8s%8s%8s%8s%8s%8s%8s%8s%8s\n', 'FileName', 'Sp.Pr', 'Sp.Re', 'Real#', '#','CER','Cl.Pu','Sp.Pu','1-Dj','1-Dm','NonHom');
for i=1:length(fileNames) % for each file in the list:
    [SpeechPr(i), SpeechRe(i), numOfClustersReal(i), numOfClustersDetected(i), purityClusterMean(i), puritySpeakerMean(i),  dJoint(i), dMax(i), CER(i), homogeneousSegmentsPerCent(i)] = ...
        testLdaCluster_stream(fileNames{i}, timeResolution, numOfKnownSpeakers(i), HomoThres, nEigenVectors, fldCriterion, kNNRatio, methodFeatureSpace, methodClustering, 0);
    fprintf('%70s%8.2f%8.2f%8d%8d%8.2f%8.2f%8.2f%8.2f%8.2f%8.2f\n', ...
        fileNames{i}, 100*SpeechPr(i), 100*SpeechRe(i), numOfClustersReal(i), numOfClustersDetected(i), ...
        100*CER(i), 100*purityClusterMean(i), 100*puritySpeakerMean(i), 100 - 100*dJoint(i), 100 - 100*dMax(i), 100*homogeneousSegmentsPerCent(i));
end

