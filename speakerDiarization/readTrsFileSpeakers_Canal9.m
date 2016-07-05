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

function [Times, Labels] = readTrsFileSpeakers_Canal9(trsFileName, timeResolution)

[tree, RootName, DOMnode] = xml_read(trsFileName);

numOfSpeakers = length(tree.Speakers.Speaker);
% unique Speakers IDs:
uSpeakerIDs = [];
for (i=1:numOfSpeakers)
    if (isempty(strfind(lower(tree.Speakers.Speaker(i).ATTRIBUTE.name), 'musique'))) % NOT - MUSIC --> Then use as a unique speaker ID
        uSpeakerIDs(end+1) = sscanf(tree.Speakers.Speaker(i).ATTRIBUTE.id, 'spk%d');
    end
end

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

% +1 is done because some times music is 0 (or even some speaker) and we
% dont want to confuse it with the non-speech label! 
uSpeakerIDs = uSpeakerIDs + 1;

speakersID = {};
for i=1:length(speakers)
    if ((~isempty(strfind(speakers{i}, 'spk'))))
        
        Tokens = textscan(speakers{i}, '%s');
        Tokens = Tokens{1};
        
        if (length(Tokens)==1)             
            speakersID{i} = [sscanf(speakers{i},'spk%d') + 1];  % .... same reason here as in line 35...
            if (isempty(find(uSpeakerIDs==speakersID{i})))      % i.e., if the current segment's speakerID is not in the list with the NON-MUSIC speaker IDs --> then it is music --> remove it
                speakersID{i} = [0];
            end
        else
            if (length(Tokens)>1)
                speakersID{i} = [];
                for (j=1:length(Tokens))
                    speakersID{i}(end+1) = sscanf(Tokens{j},'spk%d') + 1;
                end
            end
        end
    else
        speakersID{i} = [0];
    end   
end

Times = 0:timeResolution:End(end);
for (i=1:length(Times))
    Labels{i} = [];
end

for i=1:length(Times)
    [~, IMIN] = min(abs(Times(i) - Start));
    indStart = (Times(i) >= Start);
    indEnd   = (Times(i) < End);
    I = find(indStart & indEnd == 1);
    if (length(I)>0)
        ToAdd = speakersID{I(1)};
        Labels{i}(end+1:end+length(ToAdd)) = ToAdd;
    end
end


%for (i=1:numOfSegments)
%    L1 = floor(Start(i) / timeResolution)+1;
%    L2 = floor(End(i) / timeResolution)+1;    
%    for (j=L1:L2)        
%        if (isempty(Labels{j}))
%            Labels{j}(end+1:end+length(speakersID{i})) = speakersID{i}; 
%        end
%    end
%end

% Time = 0;
% count = 0;
% while (Time+timeResolution<End(end))
%     count2 = 0;
%     count = count + 1;
%     Labels{count} = [];
%     Times(count) = Time;
%     for i=1:numOfSegments
%         if (Time+timeResolution/2>=Start(i)) && (Time+timeResolution/2<=End(i))
%             count2 = count2 + 1;
%             Labels{count}(end+1:end+length(speakersID{i})) = speakersID{i};            
%         end
%     end
%     Time = Time + timeResolution;
% end

% Post-process realLabels (to remove non existing internal values)
uRealLabels = unique(cell2mat(Labels));
if (min(uRealLabels)==0)
    for (i=1:length(uRealLabels))
        for (j=1:length(Labels))            
            Labels{j}(find(Labels{j}==uRealLabels(i))) = i - 1;
        end
    end
end

    for (i=1:length(Labels))
        Labels{i} = unique(Labels{i});
    end