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

function [FFT, Freq] = getDFT(signal, Fs, PLOT)

%
% function [FFT, Freq] = getDFT(signal, Fs, PLOT)
%
% This function returns the DFT of a discrete signal and the 
% respective frequency range.
% 
% ARGUMENTS:
% - signal: vector containing the signal's samples
% - Fs:     the sampling frequency of the signal
% - PLOT:   use this argument if the FFT (and the respective 
%           frequency vaules) need to be returned in the whole 
%           -fs/2..fs/2 range. Otherwise, the first part of 
%           the spectrum is returned.
%
% RETURNS:
% - FFT:    the amplitude of the computed DFT coefficients
% - Freq:   the corresponding frequencies (in Hz)
%

% signal's length:
N = length(signal);

% compute the amplitude spectrum
% (and normalize by the number of samples):

FFT = abs(fft(signal)) / N;

if nargin==2 % get the first side of the spectrum:
    FFT = FFT(1:ceil(N/2));
    % get the frequency axis:
    Freq = (Fs/2) * (1:ceil(N/2)) / ceil(N/2);
else
    if (nargin==3) 
        % ... or retunrd the complete symmetric spectrum 
        %     (in the range -fs/2 to fs/2)
        FFT = fftshift(FFT);
        % get the frequency axis:
        if mod(N,2)==0
            Freq = -N/2:N/2-1;       % if N is even
        else
            Freq = -(N-1)/2:(N-1)/2; % if N is odd
        end
        Freq = (Fs/2) * Freq ./ ceil(N/2);
    end
end
