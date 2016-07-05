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

function [Fh, Fnh] = getHomogeneousSegmentsFeatures_Canal9(wavFileName, LongTermWin)

% function [Fh, Fnh] = getHomogeneousSegmentsFeatures_Canal9(wavFileName, LongTermWin)
%
% This function computes tha features for the homogeneous vs
% non-homogeneous speech segment.
%

START_TURN_LENGTH = 1; % duration of the begininng of the TURN (secs)
END_TURN_LENGTH   = 1; % duration of the ending of the TURN (secs)
WIN_MID = 1.0;         % mid-term window (secs)
MINIMUM_DURATION_MID_TURN = 1;

fileNameTrs = wavFileName;
fileNameTrs(strfind(fileNameTrs, '.wav'):strfind(fileNameTrs,'.wav')+3) = ''; % remove the .wav extension
fileNameTrs = [fileNameTrs '_manual.trs'];

Fh = [];
Fnh = [];

fp = fopen(fileNameTrs);
if (fp<=0) % trs file not found!
    return;
else
    fclose(fp);
end

[Times, Labels] = readTrsFileSpeakers_Canal9(fileNameTrs, LongTermWin);
[a, fs] = wavread(wavFileName, 'size');
totalSignalLength = a(1) / fs;

for (i=1:length(Labels)) % for each mid-term segment:
    curLabels = Labels{i};
    numOfSpeakers = length(curLabels); % the number of speakers in the current mid-term segment    
    L1 = round(Times(i) * fs)+1;
    L2 = round((Times(i)+LongTermWin) * fs)+1;
    % feature extraction:
    if (totalSignalLength*fs<L2)
        L2 = totalSignalLength * fs - 1;
    end
    if (L1<1)
        L1 = 1;
    end
    if (L1+fs/5>L2)
        continue;
    end
    curSegment = wavread(wavFileName, [L1 L2]);
    
    % short - term feature extraction:
    Fshort = stFeatureExtraction(curSegment, fs, 0.020, 0.020);
    
    % mid - term feature extraction:   
    Fmid   = mtFeatureExtraction(Fshort, LongTermWin / 0.020, LongTermWin / 0.020, {'mean','std'})';
    
    if (numOfSpeakers==1)
        Fh = [Fh;Fmid];
    else
        Fnh = [Fnh;Fmid];
    end
    
end