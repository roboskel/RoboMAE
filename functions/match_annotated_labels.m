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


function annotated = match_annotated_labels( annotated, diarization )
%match_annotated_labels matches output labels from diarization method to
%the given annotated speakers

%  annotated is the manually annotated sample
%  diarization is the output of the diarization method


% find the labels annotated by the diarization method
% 0 means no label
Labels = unique(diarization);
Labels = Labels(Labels > 0 );
%find the speakers by the manually annotation
speakers = unique((annotated(:,1)));
% check for non matching speakers
NoMatching = zeros(1,length(speakers));
speaker{length(speakers)} = [];
for S = 1 : length(speakers)
    correspondingLabels = [];
    new_matrix = [];
    %rounded segments of manual annotation
    idx = round(cell2mat(annotated(strcmp(annotated(:,1),speakers{S,1}),2:3)));
    % duration of the segment
    segm_duration = ceil(idx(:,2) - idx(:,1));
    % check the similarity of these segments
    % if not the same choose the major one
    seg_no = length(segm_duration);
    for k = 1 : seg_no 
        for D = 1 : segm_duration
            correspondingLabels = [correspondingLabels;diarization(idx(k,2) - D + 1)];
        end
    end
    same = unique(correspondingLabels(correspondingLabels > 0));
    if isempty(same)    % no label 
          NoMatching(S) = 1;
          continue;
    end
    if length(same) == 1 
        id(S) = same;
        while ~isempty(speaker{id(S)})
            rand_pos = randperm(length(speakers),1);
            id(S) = rand_pos;
        end
        speaker{id(S)} = speakers{S,1};
    else 
        id(S) = mode(correspondingLabels(correspondingLabels > 0)) ;
        while ~isempty(speaker{id(S)})
            rand_pos = randperm(length(speakers));
            id(S) = rand_pos;
        end
        speaker{id(S)} = speakers{S,1};
    end    
end

% check for NoMatching labels
% if there are speakers that are not matched
% match them to an empty position

NoMatch = find(NoMatching == 1);
for i = 1 : length(NoMatch)
    while ~isempty(speaker{NoMatch(i)})
            rand_pos = randperm(length(speakers),1);
            NoMatch(i) = rand_pos;
    end
    speaker{NoMatch(i)} = speakers{NoMatch(i),1};
end


for A = 1 : length(diarization)
    if(diarization(A) > 0)
        new_matrix = [new_matrix ; {speaker{diarization(A)} A-1 A } ];
    end

end
annotated = new_matrix;
end

