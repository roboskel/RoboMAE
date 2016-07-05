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


function [ recall , precise ] = visual_evaluation( manual_annotation, automatic_annotation)
%visual_evaluation evaluates the semi-automatic annotation as far as the
%face tracking is concerned
%   [ recall , precise ] = visual_evaluation( manual_annotation, automatic_annotation)
%   INPUT:
%   manual_annotation : a .mat file (struct) that contains the manual face
%                       annotations 
%   automatic_annotation : a .mat file (struct) that contains the semi-automatic
%                          face annotations
%
%   OUTPUT:
%   recall : the intersection of the bboxes area of the automatic/manual 
%            annotations divided by the bboxes area of the manual
%            annotation
%   precise :  the intersection of the bboxes area of the automated/manual 
%            annotations divided by the bboxes area of the automatic
%            annotation  


manual_annotation = load(manual_annotation);
automatic_annotation = load(automatic_annotation);
A = length(manual_annotation.frame);
B = length(automatic_annotation.frame);

%get the number of the frames annotated
if A ~= B
    NoOfFrames = min(A,B);
else
    NoOfFrames = A;
end

intersection = 0 ;
manual_bbox_area = 0;
automatic_bbox_area = 0;

for i = 1 : NoOfFrames
    current_frame1 = manual_annotation.frame{i};
    current_frame2 = automatic_annotation.frame{i};
    if isempty(current_frame1) | isempty(current_frame2)
        continue;
    end
    s = fieldnames(current_frame1);
    numOfSpeakers = length(s);
    for j = 1 : numOfSpeakers
        sp = cell2mat(s(j));
        try
            bbox1 = eval(['current_frame1.' sp '.bbox';]);
        catch
            disp('empty')
            bbox1 = [0,0,0,0];
        end
        try
            bbox2 = eval(['current_frame2.' sp '.bbox';]);
        catch
            disp('empty')
            bbox2 = [0,0,0,0];
        end
        if isempty(bbox1)
            bbox1 = [0,0,0,0];
        end
        if isempty(bbox2)
            bbox2 = [0,0,0,0];
        end
        intersection = intersection  + rectint(bbox1,bbox2);
        manual_bbox_area = manual_bbox_area + bbox1(3) * bbox1(4);
        automatic_bbox_area = manual_bbox_area + bbox2(3) * bbox2(4);
       
    end 
end

recall = intersection / manual_bbox_area;
precise = intersection / automatic_bbox_area;

end

