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

function [HR, f0] = feature_harmonic(window, Fs, M, m0)

%
% function [HR, f0, Gamma] = feature_harmonic(window, Fs, M, m0)
% This function computes the harmonic ratio and fundamental frequency of a
% window
%
% ARGUMENTS
% - window: the samples of the window
% - Fs:     the sampling frequency
% - M:      the maximum T0 (optional)
% - m0:     the minimum T0 (optional)
%
% RETURNS:
% - HR:     harmonic ratio
% - f0:     fundamental frequency
%

if nargin<3
    M=round(0.016*Fs);
end

% compute autocorrelation:
R=xcorr(window);
g=R(length(window));

R=R(length(window)+1:end);
i=2;
if nargin<4
    % estimate m0 (as the first zero crossing of R)
    m0=length(R)+1;
    while i<=length(R)
        if R(i)<0 & R(i-1)>=0
            m0=i;
            break;
        end
        i=i+1;
    end
end

if M>length(R) M = length(R); end
% compute normalized autocorrelation:
Gamma = zeros(M, 1);
CSum = cumsum(window.^2);

Gamma(m0:M) = R(m0:M) ./ (sqrt((g*CSum(end-m0:-1:end-M)))+eps);
Z = feature_zcr(Gamma);
if Z > 0.15
    HR = 0;
    f0 = 0;
else
    % compute T0 and harmonic ratio:
    if isempty(Gamma)
        HR=1;
        blag=0;
        Gamma=zeros(M,1);
    else
        [HR, blag] = max(Gamma);
    end
    % get fundamental frequency:
    f0 = Fs / blag;
    if f0>5000 f0 = 0; end
    if HR<0.1 f0 = 0; end;    
end
