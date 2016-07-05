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

function [mtFeatures, shortFeaturesCell] = ...
    mtFeatureExtraction(stFeatures, mtWin, mtStep, listOfStatistics)

%
% This function is used for extracting mid-term statistics
%
% ARGUMENTS:
%  - stFeatures:        a matrix that contains all short-term feature vectors 
%                       (dimension: dFeatures x numOfShortTermWindows)
%  - mtWin:             mid-term window (as a ratio of short-term windows)
%  - mtSteP:            mid-term step (as a ratio of short-term windows)
%  - listOfStatistics:  a cell array that contains the names of the 
%                       statistics to be calculated
%
% RETURNS:
%  - mtFeatures:        an matrix whose collumns contains the mid-term
%                       feature statistics for each mid-term segment
%  - stFeaturesCell:    a cell array, whose, each element i is 
%                       a matrix that contains the feature vector sequences
%                       of the corresponding mid-term segment. 
%
% Theodoros Giannakopoulos
% tyiannak@gmail.com
%

[numOfFeatures, numOfStWins] = size(stFeatures);

curPos = 1;
% compute the total number of mid-term frames:
numOfMidFrames = ceil((numOfStWins)/mtStep);


mtFeatures = zeros(numOfFeatures * length(listOfStatistics), numOfMidFrames);
if (nargout==2)
    shortFeaturesCell = cell(1, numOfMidFrames);
end

for (i=1:numOfMidFrames) % for each mid-term frame
    % get current frame:
    N1 = curPos;
    N2 = curPos+mtWin-1;
    if (N2>size(stFeatures,2))
        N2 = size(stFeatures,2);
    end
    
    %if (N2-N1>2) % at least 3 short term segments needed:        
        CurStFeatures  = stFeatures(:, N1:N2);
        if (nargout==2)
            shortFeaturesCell{i} = CurStFeatures;
        end
        for (j=1:length(listOfStatistics))
            mtFeatures( (j-1)*numOfFeatures + 1: j*numOfFeatures, i) = ...
                computeStatistic(CurStFeatures', listOfStatistics{j});
        end
    curPos = curPos + mtStep;
end

    
function S = computeStatistic(seq, statistic)
    if strcmpi(statistic, 'mean')
        S = mean(seq);
        return;
    end
    if strcmpi(statistic, 'median')
        S = median(seq);
        return;
    end
    if strcmpi(statistic, 'std')
        S = std(seq);
        return;
    end
    if strcmpi(statistic, 'skewness')
        S = skewness(seq);
        return;
    end
    if strcmpi(statistic, 'kurtosis')
        S = kurtosis(seq);
        return;
    end    
    if strcmpi(statistic, 'stdbymean')
        S = std(seq) ./ (mean(seq)+eps);
        return;
    end
    if strcmpi(statistic, 'max')
        S = max(seq);
        return;
    end
    if strcmpi(statistic, 'min')
        S = min(seq);
        return;
    end    
    if strcmpi(statistic, 'spectralCentroid')
        for i=1:size(seq, 2) % for each feature dimension            
            ftemp = abs(fft(seq(:,i))); % get the fft
            ftemp = ftemp(1:round(end/2));
            ftemp = ftemp + 0.0000001;
            C(i) = sum(ftemp .* [1:length(ftemp)]') / sum(ftemp);
        end        
        S = C;
        return;
    end    
    if strcmpi(statistic, 'spectralMean')
        for i=1:size(seq, 2) % for each feature dimension                       
            ftemp = abs(fft(seq(:,i))); % get the fft
            ftemp = ftemp(1:round(end/2));
            if (length(find(isnan(ftemp))))>0
                fprintf('aaaaaa');
            end
            
            ftemp = ftemp + 0.0000001;
            S(i) = mean(ftemp);
        end                
        return;
    end    
    if strcmpi(statistic, 'spectralStd')
        for i=1:size(seq, 2) % for each feature dimension            
            ftemp = abs(fft(seq(:,i))); % get the fft
            ftemp = ftemp(1:round(end/2));
            ftemp = ftemp + 0.0000001;
            S(i) = std(ftemp);
        end                
        return;
    end        
    if strcmpi(statistic, 'spectralSkewness')
        for i=1:size(seq, 2) % for each feature dimension            
            ftemp = abs(fft(seq(:,i))); % get the fft
            ftemp = ftemp(1:round(end/2));
            ftemp = ftemp + 0.0000001;
            S(i) = skewness(ftemp);            
        end
        S(isnan(S)) = 0;
        return;
    end    

    