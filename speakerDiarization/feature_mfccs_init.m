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

function mfccParams = feature_mfccs_init(windowLength, fs)

% function mfccParams = feature_mfccs_init(windowLength, fs)
% 
% This function is used to initalize the common mfcc quantities 
% used in the MFCC calculation
%
% ARGUMENTS:
% - windowLength: the length of the window analysis (in number of samples)
% - fs:         : the sampling frequency (in Hz)
%
% RETURNS:
% - mfccParams  : returns a structure with the mfcc params:
%

% number of ceptral coefficients:
mfccParams.cepstralCoefficients = 13;

% fft resolution:
mfccParams.fftSize = round(windowLength / 2);
% filter parameters:
mfccParams.lowestFrequency = 133.3333;
mfccParams.linearFilters = 13;
mfccParams.linearSpacing = 66.66666666;
mfccParams.logFilters = 27;
mfccParams.logSpacing = 1.0711703;
mfccParams.totalFilters = mfccParams.linearFilters + ...
    mfccParams.logFilters;
mfccParams.freqs = mfccParams.lowestFrequency + ...
    (0:mfccParams.linearFilters-1)*mfccParams.linearSpacing;
mfccParams.freqs(mfccParams.linearFilters+1:mfccParams.totalFilters+2) = ...
    mfccParams.freqs(mfccParams.linearFilters) * ...
    mfccParams.logSpacing.^(1:mfccParams.logFilters+2);
mfccParams.lower = mfccParams.freqs(1:mfccParams.totalFilters);
mfccParams.center = mfccParams.freqs(2:mfccParams.totalFilters+1);
mfccParams.upper = mfccParams.freqs(3:mfccParams.totalFilters+2);
mfccParams.mfccFilterWeights = zeros(mfccParams.totalFilters,mfccParams.fftSize);
mfccParams.triangleHeight = 2./(mfccParams.upper-mfccParams.lower);
mfccParams.fftFreqs = (0:mfccParams.fftSize-1)/mfccParams.fftSize*fs;

for chan=1:mfccParams.totalFilters % for each filter:
    % compute the respective filter weights:
	mfccParams.mfccFilterWeights(chan,:) = (mfccParams.fftFreqs > ...
        mfccParams.lower(chan) & mfccParams.fftFreqs <= mfccParams.center(chan)).* ...
        mfccParams.triangleHeight(chan).*...
        (mfccParams.fftFreqs-mfccParams.lower(chan))/...
        (mfccParams.center(chan)-mfccParams.lower(chan)) + ...
        (mfccParams.fftFreqs > mfccParams.center(chan) & ...
        mfccParams.fftFreqs < mfccParams.upper(chan)).* ...
          mfccParams.triangleHeight(chan).*...
          (mfccParams.upper(chan)-mfccParams.fftFreqs)/...
          (mfccParams.upper(chan)-mfccParams.center(chan));
end

% matrix used in the DCT calculation:
mfccParams.mfccDCTMatrix = 1/sqrt(mfccParams.totalFilters/2)*...
    cos((0:(mfccParams.cepstralCoefficients-1))' * ...
    (2*(0:(mfccParams.totalFilters-1))+1) * pi/2/mfccParams.totalFilters);
mfccParams.mfccDCTMatrix(1,:) = mfccParams.mfccDCTMatrix(1,:) * sqrt(2)/2;
