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

function Entropy = feature_energy_entropy(window, numOfShortBlocks)

% function Entropy = feature_energy_entropy(window, numOfShortBlocks)
%
% This function computes the energy entropy of the given frame
%
% ARGUMENTS:
% - window: 	an array that contains the audio samples of the input frame
% - numOfShortBlocks:     number of sub-frames
%                         (used in the entropy computation)
%
% RETURNS:
% - Entropy:    the energy entropy value
%

% total frame energy:
Eol = sum(window.^2);
winLength = length(window);
subWinLength = round(winLength / numOfShortBlocks);

if length(window)>subWinLength* numOfShortBlocks
    window = window(1:subWinLength* numOfShortBlocks);
end
% get sub-windows:
subWindows = reshape(window, subWinLength, numOfShortBlocks);

% compute normalized sub-frame energies:
s = sum(subWindows.^2) / (Eol+eps);

% compute entropy of the normalized sub-frame energies:
Entropy = -sum(s.*log2(s+eps));