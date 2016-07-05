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

function n = contigencyTable(results, realLabels, ignoreMultiLabels)

% ARGUMENTS:
%  - Uclustering: the 1st clustering. This is a 1-D vector that contains the cluster labels of all samples.
%  - Vclustering: the 2nd clustering. 
%


Nc = length(sort(unique(cell2mat(results))));    % the total number of clusters
Ns = length(sort(unique(cell2mat(realLabels)))); % the total number of speakers
N1 = length(results);
N2 = length(realLabels);

if (N1~=N2) % invalid argument sizes
	purityCluster = [];
	puritySpeaker = [];
	fprintf('Invalid argument sizes!\n');
	return;
end

N = N1; % number of samples;

N_c = zeros(Nc, 1);
N_s = zeros(Ns, 1);
n   = zeros(Nc, Ns);

for (i=1:N) % for each sample position:
    if (~ignoreMultiLabels)
        for (k1=1:length(results{i})) % for all labels of sample i
            for (k2=1:length(realLabels{i})) % for all real labels of sample j
                n(results{i}(k1), realLabels{i}(k2)) = n(results{i}(k1), realLabels{i}(k2)) + 1;            
            end
        end
    else
        if ((length(results{i})==1) && (length(realLabels{i})==1))
            n(results{i}(1), realLabels{i}(1)) = n(results{i}(1), realLabels{i}(1)) + 1;
        end
    end
    
end
