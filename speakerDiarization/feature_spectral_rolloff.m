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

function mC = feature_spectral_rolloff(windowFFT, c)

% function mC = feature_spectral_rolloff(windowFFT, c)
% 
% Computes the spectral rolloff feature. 
% ARGUMENTS:
% - windowFFT:             the abs(FFT) of the current audio frame
%                          (computed by getDFT() function)
% - c:                     the spectral rolloff parameter
%
% RETURNS:
% - mC:                    the spectral rolloff value for the input frame
%


% compute total spectral energy:
totalEnergy = sum(windowFFT.^2);
curEnergy = 0.0;
countFFT = 1;
fftLength = length(windowFFT);

% find the spectral rolloff as the frequency position where the 
% respective spectral energy is equal to c*totalEnergy
while ((curEnergy<=c*totalEnergy) && (countFFT<=fftLength))
    curEnergy = curEnergy + windowFFT(countFFT).^2;
    countFFT = countFFT + 1;
end
countFFT = countFFT - 1;

% normalization:
mC = ((countFFT-1))/(fftLength);
