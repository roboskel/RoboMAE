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

function testLdaCluster_streamDir_script(dirName)

% These are the optimal paramters:
HomoThres = 0.025;
nEigenVectors = 4;
kNNRatio = 0.15;
% 

method1 = [0 1]; % feature extraction method
%method1 = [1]; % feature extraction method
method1Names{1} = 'Init. Space';
method1Names{2} = 'LDA Space';
method2 = [0 1]; % clustering - post processing method
%method2 = [1]; % clustering - post processing method
method2Names{1} = 'Cluster'; 
method2Names{2} = 'Cluster, hmm smooth';
fldCriterion = 1;


CERA  = zeros(length(method1), length(method2)); CERB  = zeros(length(method1), length(method2)); 
cPurA = zeros(length(method1), length(method2)); cPurB = zeros(length(method1), length(method2));
cSpeA = zeros(length(method1), length(method2)); cSpeB = zeros(length(method1), length(method2));
dJointA = zeros(length(method1), length(method2)); dJointB = zeros(length(method1), length(method2));
dMaxA = zeros(length(method1), length(method2)); dMaxB = zeros(length(method1), length(method2));
homogeneousSegmentsPerCentA = zeros(length(method1), length(method2)); homogeneousSegmentsPerCentB = zeros(length(method1), length(method2));

for (i=1:length(method1))
	for (j=1:length(method2))
		[cPurAT, cSpeAT, dJointAT, dMaxAT, CERAT, homogeneousSegmentsPerCentAT, ...
         cPurBT, cSpeBT, dJointBT, dMaxBT, CERBT, homogeneousSegmentsPerCentBT] = ...
                testLdaCluster_streamDir(dirName, 1, HomoThres, nEigenVectors, fldCriterion, kNNRatio, method1(i), method2(j));
        cPurA(i,j)      = mean(cPurAT);
        cSpeA(i,j)      = mean(cSpeAT);
        dJointA(i,j)    = mean(dJointAT);
        dMaxA(i,j)      = mean(dMaxAT);
        homogeneousSegmentsPerCentA(i,j) = mean(homogeneousSegmentsPerCentAT);
        CERA(i,j)       = mean(CERAT);
        cPurB(i,j)      = mean(cPurBT);
        cSpeB(i,j)      = mean(cSpeBT);
        dJointB(i,j)    = mean(dJointBT);
        dMaxB(i,j)      = mean(dMaxBT);
        CERB(i,j)       = mean(CERBT);
        homogeneousSegmentsPerCentB(i,j) = mean(homogeneousSegmentsPerCentBT);
	end; 
end;

fprintf('%15s%20s%10s%10s%10s%10s%10s%10s%15s%10s%10s%10s%10s%10s\n', ...
    'Feature Meth.', 'Cl. Meth.', 'CER', 'Cl. Pur', 'Sp. Pur', '1- Joint', '1-dMax', 'Hom', ....
                                  'CER', 'Cl. Pur', 'Sp. Pur', '1-dJoint', '1-dMax', 'Hom');

for (i=1:length(method1))
    for (j=1:length(method2))
        fprintf('%15s%20s%10.2f%10.2f%10.2f%10.2f%10.2f%10.2f%15.2f%10.2f%10.2f%10.2f%10.2f%10.2f\n', ...
            method1Names{i}, method2Names{j}, ...
            100*CERA(i,j), 100*cPurA(i,j), 100*cSpeA(i,j), 100 - 100*dJointA(i,j), 100 - 100*dMaxA(i,j), homogeneousSegmentsPerCentA(i,j), ...
            100*CERB(i,j), 100*cPurB(i,j), 100*cSpeB(i,j), 100 - 100*dJointB(i,j), 100 - 100*dMaxB(i,j), homogeneousSegmentsPerCentB(i,j));
    end
end

