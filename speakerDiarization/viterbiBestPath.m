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

function path = viterbiBestPath(priors, transMat, probEst)

% 
% path = viterbiBestPath(priors, transMat, probEst)
%
% This function finds the most-likely state sequence
% 
% ARGUMENTS:
% priors:       an array of initial (priors) probabilities for each state
% transMat:     a matrix of transition probabilities from state i to 
%               state j
% probEst:      a matrix of probability estimations P(observation|state)
%               of size [numOfStates x numOfObservations]
%
% RETURNS:
% path:         labels of the states that compose the most likely path
%


T = size(probEst, 2);
priors = priors(:);
Q = length(priors);

delta = zeros(Q,T);
psi = zeros(Q,T);
path = zeros(1,T);
scale = ones(1,T);


t=1;
delta(:,t) = priors .* probEst(:,t);
  %[delta(:,t), n] = normalise(delta(:,t));
  delta(:,t) = delta(:,t) / sum(delta(:,t));
  %scale(t) = 1/n;
psi(:,t) = 0; % arbitrary value, since there is no predecessor to t=1
for t=2:T
  for j=1:Q
    [delta(j,t), psi(j,t)] = max(delta(:,t-1) .* transMat(:,j));
    delta(j,t) = delta(j,t) * probEst(j,t);
  end
  delta(:,t) = delta(:,t) / sum(delta(:,t));
end
[p, path(T)] = max(delta(:,T));
for t=T-1:-1:1
  path(t) = psi(path(t+1),t+1);
end

