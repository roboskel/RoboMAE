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

function [transMatrix, Priors] = computeTransitionMatrixFromLabels(Labels)

if (~iscell(Labels))
    Labels2 = cell(size(Labels));
    for (i=1:length(Labels))
        Labels2{i} = Labels(i);
    end
    Labels = Labels2;
end

% get number of speakers:
unLabels = unique(cell2mat(Labels));
% unLabels(unLabels==0) = [];
numOfSpeakers = length(unLabels);
transMatrix = zeros(numOfSpeakers);

for (j=1:length(Labels)-1) % for each window:        
    for (k1=1:length(Labels{j})) % for each label in the CURRENT window (i.e., multi-labels are allowed...)
            for (k2=1:length(Labels{j+1})) % for each label in the NEXT window
                    K1 = find(unLabels==Labels{j}(k1));
                    K2 = find(unLabels==Labels{j+1}(k2));
                    transMatrix(K1, K2) = transMatrix(K1, K2) + 1;
            end
    end
end

%----------sergios: normalise to get probabilities. TODO: is this needed ? 
%for i = 1:length( unLabels )
%    b = sum( transMatrix( i, : ) );
%    transMatrix( i, : ) = transMatrix( i, : ) / b;
%end
%----------sergios

Priors = sum(transMatrix);
