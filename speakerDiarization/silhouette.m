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

function [S, Sall] = silhouette(ClusterLabels, Features)

%
% function [S, Sall] = silhouette(ClusterLabels, Features)
%
% This function computes the silhouette measure for a given clustering
%
% ARGUMENTS:
% - ClusterLabels:      [numOfSamples x 1] array that contains the cluster
%                       labels
% - Features:           [numOfSamples x numOfDims] matrix whose rows
%                       correspond to Feature vectors of the respective
%                       samples
%
% RETURNS:
% - S:                  average silhouette measure
% - Sall:               individual silhouette measures (one for each 
%                       cluster)
%
% EXAMPLE:
% % generate 2D gaussian distributions (5 clusters):
% x = [randn(100,1) randn(100,1); randn(100,1) - 3.5 randn(100,1) - 3.5;  randn(100,1) + 3.5 randn(100,1) + 3.5;  randn(100,1) - 3.5 randn(100,1) + 3.5;   randn(100,1) + 3.5 randn(100,1) - 3.5];
% % kmeans clustering for different number of clusters:
% nClusters = [2:10]; 
% for c=1:length(nClusters) clusterLabels = kmeans(x, nClusters(c)); S(c) = silhouette(clusterLabels, x); end
% plot(nClusters, S); xlabel('nClusters'); ylabel('Silhouette');
% [~, optimalNCluster] = max(S); optimalNCluster = nClusters(optimalNCluster);
%

L1 = length(ClusterLabels);
[L2, numOfFeatures] = size(Features);
if (L1~=L2) 
	fprintf('Wrong Arguments!\n');
    return;
else
	% number of samples:
	numOfSamples = L1;
    
    if (numOfSamples==0)
        S = -1;
        Sall = [-1];
        return
    end
    
	uniqueClusters = sort(unique(ClusterLabels));
    
    if (length(uniqueClusters)==1)
        S = 0.5;
        Sall = [0.5];
        return;
    end

	% COMPUTE SILHOUETTE:
	a = zeros(numOfSamples,1);
	for (i=1:numOfSamples) % for each sample:
    	% compute a:
		% find the samples from the same cluster:
		IndecesCluster = find(ClusterLabels==ClusterLabels(i));
		IndecesCluster(find(IndecesCluster==i)) = [];
		d = zeros(length(IndecesCluster),1);
        d = pdist2(Features(i,:), Features(IndecesCluster, :));            
        a(i) = mean(d);

        % compute b:
		% list of other clusters:
		otherClusters = uniqueClusters;
		otherClusters(otherClusters==ClusterLabels(i)) = [];
        for (c=1:length(otherClusters)) % for each of the other clusters:
    		curCluster = otherClusters(c);
			IndecesClusterN = find(ClusterLabels==curCluster);
            Find = Features(IndecesClusterN,:);
            d = pdist2(Features(i,:), Find);
			allBs(c) = mean(d);
		end
		b(i) = min(allBs);

        % compute s:
		MAX = max([a(i) b(i)]);
		s(i) = (b(i)-a(i)) / MAX;
		% weight(i) = length(IndecesCluster);
       weight(i) = 1;
	end
end

S = median(s);
for (i=1:length(uniqueClusters))
	ClusterSize(i,1) = length(find(ClusterLabels==i));
	Sall(i,1) = median( s( find(ClusterLabels==i) ) );
end
S2 = mean(Sall);
S = S2;

