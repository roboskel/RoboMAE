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

function En = feature_spectral_entropy(windowFFT, numOfShortBlocks)

% function En = feature_spectral_entropy(windowFFT, numOfShortBlocks)
% 
% This function computes the spectral entropy of the given audio frame
%
% ARGUMENTS:
% - windowFFT:       the abs(FFT) of an audio frame
%                    (computed by getDFT() function)
% - numOfShortBins   the number of bins in which the spectral 
%                    energy is divided
%
% RETURNS:
% - En:              the value of the spectral entropy
%

% number of frame samples:
fftLength = length(windowFFT);

% total frame (spectral) energy 
Eol = sum(windowFFT.^2);

% length of sub-frame:
subWinLength = round(fftLength / numOfShortBlocks);
if length(windowFFT)>subWinLength* numOfShortBlocks
    windowFFT = windowFFT(1:subWinLength* numOfShortBlocks);
end

% define sub-frames:
subWindows = reshape(windowFFT, subWinLength, numOfShortBlocks);

% compute spectral sub-energies:
s = sum(subWindows.^2) / (Eol+eps);

% compute spectral entropy:
En = -sum(s.*log2(s+eps));
