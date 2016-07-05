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

function [F, dataLDA, labelsLDA ] = ldaData(fileName, X, W, S, C, SamplesToUse, numSegmentsToBeUsedForLDA, labelsLDA_force)

% function [F, F2] = ldaData(X, W, S, C, numSegmentsToBeUsedForLDA)
%
% This algorithm performs the lda method on the provided audio segments
%
% This function is used for clustering a set of audio segments. Number of speakers: 2
% ARGUMENTS:
%  - X:        a cell array, whose elements contain the feature sequences of the respective audio segments
%  - W:        the size of the mid-term window (needed for generation of the LDA-related data)
%  - S:        the step of the mid-term window
%  - C:        the proportion the total sum of the final eigenvalues, that need to be concentrated by the selected eigenvalues (e.g., 0.20)
% 
% RETURNS:
%  - eigvectors : the base of the subspace
%
% Theodoros Giannakopoulos



mfcc_from = 10;
mfcc_end = 21;

if ( mfcc_from > 1 )
    for i=1:length(X)
        X{i} = X{i}(mfcc_from:mfcc_end,:);
        
        % ALSO COMPUTE THE delta:
        %Xtemp = X{i};
        %Y{i} = [zeros(mfcc_end-mfcc_from+1, 1) Xtemp(:, 2:end) - Xtemp(:, 1:end-1)];
        %X{i} = [X{i};Y{i}];        
    end
end

% total number of segments:
numOfSegments = length(X); 

Xlda = {};            
if (~isempty(labelsLDA_force))
    labelsLDA_force = labelsLDA_force(SamplesToUse==1);
end

if (SamplesToUse==-1)
    Xlda = X;
else
    for i=1:length(SamplesToUse)
        if (SamplesToUse(i)==1)
            Xlda{end+1} = X{i};
        end
    end
end

Ind = randperm(length(Xlda));
Xlda2 = Xlda;
if (numSegmentsToBeUsedForLDA < length(Xlda))    
    for i=1:numSegmentsToBeUsedForLDA
        Xlda2{i} = Xlda{Ind(i)};        
    end
    if (~isempty(labelsLDA_force))
        labelsLDA_force = labelsLDA_force(Ind(1:numSegmentsToBeUsedForLDA));
    end
else
    for i=1:length(Xlda)
        Xlda2{i} = Xlda{Ind(i)};        
    end    
    if (~isempty(labelsLDA_force))
        labelsLDA_force = labelsLDA_force(Ind);
    end
end

Xlda = Xlda2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% F, MEAN AND STD CALCULATION:
numOfDims = size( Xlda{1} , 1 );
F = zeros(numOfSegments, 2*numOfDims);
for i=1:numOfSegments
	tempX = X{i};
	numOfDims = size(tempX, 1);

    for j=1:numOfDims
		F(i, j) = mean(tempX(j,:));
		F(i, numOfDims + j) = std(tempX(j,:));
    end
end
MEAN = mean(F(SamplesToUse, :) );
STD =  std( F(SamplesToUse, :) );

%%%%%%%%%%%%%%%%%% END OF MEAN AND STD CALCULATION

% generate data for LDA:
dataLDA = generateDataForLDA(Xlda, MEAN, STD, W, S, labelsLDA_force); % NORMALIZATION IS DONE HERE !!!!!
labelsLDA = dataLDA(:,end);
dataLDA = dataLDA(:,1:end-1);


