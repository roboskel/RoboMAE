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

function [CM, LabelMap] = computeCER(n_table)

% 
% function [CM, LabelMap] = computeCER(n_table)
%
% Computes confusion matrix from contigency table.
% Optimal mapping is achieved through hungarian distance.
%
% ARGUMENTS:
%  - n_table:   contigency table
%
% RETURNS:
%  - CM:        confusion matrix
%  - LabelMap:  mappings from estimated labels to real labels
%


n_table = n_table';

[nReal, nCl] = size(n_table);
[Matching, Cost] = Hungarian(-n_table);
cntNotMatched = 0;
for (i=1:nCl)
    if (sum(Matching(:,i))>0) 
        [MAX, IMAX] = max(Matching(:,i));
        LabelMap(i) = IMAX;
    else
        cntNotMatched = cntNotMatched + 1;
        LabelMap(i) = cntNotMatched + nReal;        
    end
end

CM = zeros(nReal, nCl);
for (i=1:nCl)    
    CM(:,LabelMap(i)) = n_table(:,i);
end
% CM = CM';
