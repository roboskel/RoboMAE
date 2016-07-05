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

function [Fh, Fnh, F_lda, Labels_lda, F2, eigvectors] = getHomogeneousSegmentsFeatures_Canal9_DIR(dirName, MID_WIN, homoClassifierFile)

%
% function [Fh, Fnh, F_lda, Labels_lda, F2, eigvectors] = getHomogeneousSegmentsFeatures_Canal9_DIR(dirName, MID_WIN)
%
% This function is used for training the Homogeneous vs Non-homogeneous classifier.
%
% [Fh, Fnh, F_lda, Labels_lda, F2, eigvectors] = getHomogeneousSegmentsFeatures_Canal9_DIR('/media/DISK80_RESE/canal9Small/completeNonMusic/', 1);
%
% MODEL IS SAVED IN homoClassifierFile 
%

D = dir([dirName '*.wav']);

Fh = [];
Fnh = [];

for (i=1:length(D))
    fprintf('processing file %s...\n', D(i).name);
    [Fht, Fnht] = getHomogeneousSegmentsFeatures_Canal9([dirName D(i).name], MID_WIN);
    if (isempty(Fht))
        continue; % trs file was not found or there was a problem reading it...
    end
    Fh = [Fh; Fht];
    Fnh = [Fnh; Fnht];
end

C = 1;
Fh2 = Fh;
Fnh2 = Fnh;

RP = randperm(size(Fnh2, 1));
Fh2 = Fh2(RP(1:size(Fnh2,1)), :);
F_lda = [Fh2; Fnh2];
Labels_lda = [ones(size(Fh2, 1), 1); 2 * ones(size(Fnh2, 1), 1)];
[eigvectors, eigvalues] = fld(F_lda, Labels_lda, C);
eigvectors = eigvectors(:, 1:C);
eigvalues  = eigvalues(1:C);
size(eigvectors)
F2 = F_lda * eigvectors;

Fa = F2(1:size(Fh2,1));
Fb = F2(size(Fh2,1)+1:end);

Ma = mean(Fa);
Mb = mean(Fb);

MIN = min([Fa; Fb]);
MAX = max([Fa; Fb]);
numOfBins = 100;
range = MIN: (MAX-MIN) / (numOfBins - 1): MAX;

Ha = hist(Fa, range);
Hb = hist(Fb, range);

if (Ma>Mb)
    HomoLeft = 0;
    for (i=1:length(Ha))
        lostHomo(i) = sum( Ha(1:i) ) / sum(Ha);
        foundNHomo(i) = sum( Hb(1:i) )  / sum(Hb);        
    end
else
    HomoLeft = 1;
    for (i=1:length(Ha))
        lostHomo(i) = sum( Ha(i:end) ) / sum(Ha);
        foundNHomo(i) = sum( Hb(i:end) )  / sum(Hb);        
    end    
end

subplot(2,1,1);
plot(range, Ha);
hold on;
plot(range, Hb,'r');
subplot(2,1,2);
plot(range, lostHomo);
hold on;
plot(range, foundNHomo, 'r');
legend('Lost Homogenous', 'Found NON Homogeneous');

homoEigenVector = eigvectors;
save(homoClassifierFile, 'homoEigenVector','HomoLeft');