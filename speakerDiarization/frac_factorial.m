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

function result = frac_factorial(num, denum)

maxNum = max(num);
maxDen = max(denum);

matrixNum = zeros(1, maxNum);
matrixDen = zeros(1, maxDen);

for (i=1:length(num))
    matrixNum(1:num(i)) = matrixNum(1:num(i)) + 1;
end

for (i=1:length(denum))
    matrixDen(1:denum(i)) = matrixDen(1:denum(i)) + 1;
end

if (length(matrixNum)>length(matrixDen))
    matrixDen(end+1:length(matrixNum)) = 0;
else
    matrixNum(end+1:length(matrixDen)) = 0;
end

matrixFinal = matrixNum - matrixDen;
Ind = 1:length(matrixFinal);
result = prod(Ind.^matrixFinal);