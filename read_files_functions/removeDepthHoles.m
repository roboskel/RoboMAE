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


function meterDepthImage2 = removeDepthHoles(meterDepthImage)

%meterDepthImage = imresize(meterDepthImage, 1/resizeFactor);
meterDepthImage2 = meterDepthImage;
myEPS = 0.10;
[M, N] = size(meterDepthImage);
[I, J] = find(meterDepthImage<myEPS);

Window = [round(M / 200.0):5:round(M / 2.0)];

for i=1:length(I)
    curWindow = 1;
    while (1)
        Hs = max(1, I(i)-Window(curWindow)); He = min(M, I(i)+Window(curWindow));
        Ws = max(1, J(i)-Window(curWindow)); We = min(N, J(i)+Window(curWindow));
        curArray = meterDepthImage(Hs:He, Ws:We); curArray = curArray(:);
        curArray = curArray(curArray>0.10);
        if ~isempty(curArray)            
            break;            
        else
            curWindow = curWindow + 1;
            if (curWindow>length(Window))
                curArray = mean2(meterDepthImage);
                break;
            end
        end
    end  
    meterDepthImage2(I(i), J(i)) = mean(curArray);    
end

%meterDepthImage2 = imresize(meterDepthImage2, resizeFactor);
