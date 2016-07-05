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

function [Times, Labels] = readTrsFileSpeakers(trsFileName, timeResolution)

[tree, RootName, DOMnode] = xml_read(trsFileName);

numOfSegments = length(tree.Episode.Section.Turn);

for i=1:numOfSegments
    if (isfield(tree.Episode.Section.Turn(i).ATTRIBUTE, 'speaker'))
        speakers{i} = tree.Episode.Section.Turn(i).ATTRIBUTE.speaker;
    else
        speakers{i} = 'none';
    end
    Start(i) = tree.Episode.Section.Turn(i).ATTRIBUTE.startTime;
    End(i) =   tree.Episode.Section.Turn(i).ATTRIBUTE.endTime;    
    if isfield(tree.Episode.Section.Turn(i), 'Comment')        
        if (length(tree.Episode.Section.Turn(i).Comment)>1) % more than two labels in the same segment (TODO: use multi-label annotation...)
            audioClass{i} = tree.Episode.Section.Turn(i).Comment(2).ATTRIBUTE.desc;
        else
            audioClass{i} = tree.Episode.Section.Turn(i).Comment.ATTRIBUTE.desc;
        end
    else
        audioClass{i} = '';
    end    
    
end

speakersID = zeros(length(speakers), 1);
for i=1:length(speakers)
    if (~isempty(strfind(speakers{i}, 'spk')))
        speakersID(i) = sscanf(speakers{i},'spk%d');
    end
end

%for i=1:numOfSegments
%    fprintf('%8.2f f%8.2f%30s(%3d)%30s\n', Start(i), End(i), speakers{i}, speakersID(i), audioClass{i});
%end

Time = 0;
count = 0;
while (Time+timeResolution<End(end))
    for i=1:numOfSegments
        if (Time>=Start(i)) && (Time<End(i))
            count = count + 1;
            Labels(count) = speakersID(i);
            Times(count) = Time;
            break;
        end
    end
    Time = Time + timeResolution;
end
% plot(Times, Label);