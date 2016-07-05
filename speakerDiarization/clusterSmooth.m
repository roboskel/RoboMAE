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

function [Labels2, obslik] = clusterSmooth(Labels, Features, speechSegmentsIndeces, kNNRatio, useL1distance)

% function [Labels2] = clusterSmooth(Labels, Features, speechSegmentsIndeces, kNNRatio, useL1distance)
%
% This function smooths the clustering labels of a sequence, based on HMM
%
% Also returns the LAST observation likelihood sequence ( to be used for
% further smoothing or for fusion)
% 

error( nargchk(4,5,nargin) )

if ( nargin < 5 )
    useL1distance = false;
end

%warning off;

uLabels = unique(Labels);
uLabels(uLabels==0) = [];
nonZeroLabels = Labels(Labels>0);
%Centers = {};

%F = cell( length(uLabels), 1 );
for i=1:length(uLabels)
    F{i} = Features(nonZeroLabels == uLabels(i), :)';
%    Centers{i} = mean(Features(nonZeroLabels == uLabels(i), :));
%    Stds{i} = std(Features(nonZeroLabels == uLabels(i), :));
%    Std(i) = sum(Stds{i});
%    S{i} = cov(Features(nonZeroLabels == uLabels(i), :));
end

% initialize HMM-related parameters
obslik = zeros(length(unique(Labels)), length(Labels)); 

[transmat, prior] = computeTransitionMatrixFromLabels((Labels));
%prior = prior / sum(prior);

prior = [1 zeros(1, length(unique(Labels))-1)]; % always start with music or pause
for i=1:size(transmat, 1)
    transmat(i,:) = transmat(i,:) ./ sum(transmat(i,:)); 
end

k = round(size(Features, 1) * kNNRatio);
if (k<3)
    k = 3;
end
%display( k );

for t=1:length(Labels)     % for each label
    % get the index of the t-th label:
    i = (find(speechSegmentsIndeces==t-1));
    if (isempty(i)) | (Labels(t)==0)                
        obslik(:, t) = [1;zeros(length(unique(Labels))-1, 1)];
    else                                                    
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        % TODO:
        % 
        % ENABLE MID-TURN-BASED PROBABILITY ESTIMATION:
        %
        curF   = Features(i, :);        
        
        % Estimate the probability P(Cluster | Observation)
        %for (c=1:length(Centers))
            %D(c) = sqrt( sum( (curF - Centers{c}).^2 )) / Std(c);
            %D(c) = sqrt( sum( (curF - Centers{c}).^2 ));
            %D(c) = (1 / ( ((2*pi).^(length(curF)/2)) * sqrt(det(S{c})) )) * ...
            %    exp( (-1/2) * (curF - Centers{c}) * S{c}^(-1) * (curF - Centers{c})' );                        
        %end        
        %Pclusters = 1./(D+eps);
        %Pclusters = D;
        Pclusters = classifyKNN_D_Multi(F, curF, k, 1, useL1distance)';
        %Pclusters = Pclusters / sum(Pclusters);
        obslik(:, t) = [0 Pclusters]'; % 0 is for the non-speech class
    end
end
%Labels2 = viterbi_path(prior, transmat, obslik) - 1;
Labels2 = viterbiBestPath(prior, transmat, obslik) - 1;


