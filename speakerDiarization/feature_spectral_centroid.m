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

function [C,S] = feature_spectral_centroid(window_FFT, fs)

% function C = feature_spectral_centroid(window_FFT, fs)
%
% Computes the spectral centroid and spread of a frame
%
% ARGUMENTS:
% - window_FFT: the abs(FFT) of an audio frame
%               (computed by getDFT() function)
% - fs:         the sampling freq of the input signal (in Hz)
% 
% RETURNS:
% - C:          the value of the spectral centroid
%               (normalized in the 0..1 range)
% - S:          the value of the spectral spread 
%               (normalized in the 0..1 range)
%

% number of DFT coefficients:
windowLength = length(window_FFT);
% sample range
m = ((fs/(2*windowLength))*[1:windowLength])';
% normalize the DFT coefs by the max value:
window_FFT = window_FFT / max(window_FFT);
% compute the spectral centroid:
C = sum(m.*window_FFT)/ (sum(window_FFT)+eps);
% compute the spectral spread
S = sqrt(sum(((m-C).^2).*window_FFT)/ (sum(window_FFT)+eps));

% normalize by fs/2 
% (so that 1 correponds to the maximum signal frequency, i.e. fs/2):
C = C / (fs/2);
S = S / (fs/2);

