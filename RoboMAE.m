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


function AnnotationTool

  
   close all;clc;
   addpath(genpath(pwd));
   %  Create and then hide the GUI as it is being constructed.
   f = figure('Visible','off','Position',[100,100,1200,550]);
   hsound = axes('Units','Pixels','Position',[25,300,350,200],...
       'ButtonDownFcn', @zoomin); 
   hrgb = axes('Units','Pixels','Position',[450,300,350,200]); 
   hdepth = axes('Units','Pixels','Position',[450,50,350,200]); 
   hlaser = axes('Units','Pixels','Position',[25,50,350,200]);
   modelist = {'Interpolation','Tracking'};
   colors = {[0,1,1];[1,0,0];[1,0,1];[0,1,0];[0.5,0.5,0.5];[0,0,0.5];[1,1,0];[1,1,1]} ;
   a = struct(); basic_struct = a;frame = {}; speechlist = 'No speech'; 
   for init = 1:length(colors)
       eval(['basic_struct.Speaker' num2str(init) '.color = colors{' num2str(init) '};']);
       eval(['basic_struct.Speaker' num2str(init) '.bbox = [];']);
       eval(['basic_struct.Speaker' num2str(init) '.ID = ' num2str(init) ';']);
   end
   default_struct = basic_struct;
   objects2track = 'Faces';
   laser_annotation = {};
   audio_timestamps = [];
   
   %  Construct the components.
   speaker_panel = uipanel('Title','Speakers','Position',[0.7 0.64 0.1 0.29],'Parent',f);
   info = uicontrol('Style','pushbutton','String','SpeakerList',...
          'Position',[850,460,70,25],...
          'Callback',{@infos});
   add = uicontrol('Style','pushbutton','String','Add',...
          'Position',[850,430,70,25],...
          'Callback',{@add_button});
   remove = uicontrol('Style','pushbutton','String','Remove',...
          'Position',[850,400,70,25],...
          'Callback',{@remove_button});
   insert_speaker = uicontrol('Style','edit',...
          'String','New Speaker',...
          'Position',[850,370,95,25],...
          'Callback',{@insert_spkr});   
      
   audio_panel = uipanel('Title','Audio','Position',[0.8 0.64 0.1 0.29],'Parent',f);  
   speaker_speech= uicontrol('Style','pushbutton',...
          'String','Annotate speech',...
          'Position',[970,465,90,30],...
          'Callback',{@sp_speech});
   annotation_summary = uicontrol('Style','pushbutton',...
          'String','Plot Annotation',...
          'Position',[970,430,90,30],...
          'Callback',{@annotated_segment});
   diariazation = uicontrol('Style','pushbutton',...
          'String','Diariazation',...
          'Position',[980,390,70,30],...
          'Callback',{@diarization_method});
   play_sound = uicontrol('Style','pushbutton',...
          'String','Play',...
          'Position',[980,360,70,30],...
          'Callback',{@play_wav});  
      
   mode_panel = uipanel('Title','Face Annotation','Position',[0.7 0.35 0.2 0.29],'Parent',f);   
   select_mode = uicontrol('Style','popupmenu',...
          'String','Select speaker',...
          'Position',[850,295,95,25],...
          'Callback',{@select_md},...
          'String',modelist);
   interpolation_points = uicontrol('Style','pushbutton',...
          'String','Interpolation points',...
          'Position',[960,295,100,30],...
          'Callback',{@intrpl_points});  
   fill_bboxes= uicontrol('Style','pushbutton',...
          'String','Execute',...
          'Position',[960,265,100,30],...
          'Callback',{@fill_bbox});   
   cancel_method= uicontrol('Style','pushbutton',...
          'String','Cancel method',...
          'Position',[850,265,100,30],...
          'Callback',{@cancel});       
   buttongroup = uibuttongroup('Position',[0.71 0.37 .17 0.09]);
   % Create three radio buttons in the button group.
    u0 = uicontrol('Style','radiobutton','String','Faces',...
    'pos',[15 5 50 30],'parent',buttongroup,'HandleVisibility','off');
    u1 = uicontrol('Style','radiobutton','String','Laser',...
    'pos',[75 5 50 30],'parent',buttongroup,'HandleVisibility','off');
    u2 = uicontrol('Style','radiobutton','String','Both',...
    'pos',[135 5 50 30],'parent',buttongroup,'HandleVisibility','off');
    % Initialize some button group properties. 
    set(buttongroup,'SelectionChangeFcn',@selcbk);
    set(buttongroup,'SelectedObject',[]);  % No selection
    set(buttongroup,'Visible','on');
      
   other_panel = uipanel('Title','General Tools','Position',[0.7 0.09 0.2 0.25],'Parent',f);  
   face_detector = uicontrol('Style','pushbutton',...
          'String','FaceDetection',...
          'Position',[870,120,80,40],...
          'Callback',{@fd});  
   rgb_projection= uicontrol('Style','pushbutton',...
          'String','ImageProjection',...
          'Position',[970,120,80,40],...
          'Callback',{@rgb_proj});
   export_data= uicontrol('Style','pushbutton',...
          'String','Export',...
          'Position',[870,60,40,40],...
          'Callback',{@exportdata});   
   import_data= uicontrol('Style','pushbutton',...
          'String','Import',...
          'Position',[910,60,40,40],...
          'Callback',{@importdata});  
   clear_data= uicontrol('Style','pushbutton',...
          'String','Clear Data',...
          'Position',[970,60,80,40],...
          'Callback',{@cleardata});    
      
 
   zoom_out= uicontrol('Style','pushbutton',...
          'String','Undo zoom',...
          'Position',[20,510,60,20],...
          'Callback',{@zoomout}); 
   time_disp = uicontrol('Style','text',...
          'String','0',...
          'Position',[810,0,50,20]);      
   frame_disp = uicontrol('Style','text',...
          'String','0',...
          'Position',[860,0,50,20]);        
   toggle_laser = uicontrol('Style','pushbutton',...
          'String','Toggle',...
          'Position',[25,260,50,20],...
          'Callback',{@toggle}); 
   LaserEdit = uicontrol('Style','pushbutton',...
          'String','Edit',...
          'Position',[80,260,50,20],...
          'Callback',{@laser_edit}); 
   Speech_disp = uicontrol('Style','text',...
          'String',speechlist,...
          'Position',[410,420,50,80],'Visible','off'); 
      
   %% synchornise modality files based on timestamps
   % open data folder
   folder = uigetdir ;
   addpath(folder);

   % initialization 
   image = '';y = '';fs = 0;item = 0;tmp = 0; laser_spots = [];
   previous_image = zeros(480,640,3); depth_data ='';y_temp = 0;
   time_temp = 0; color = 0; audio_rgb = {}; X = 0; laser_range = 0;
   bbox = '';sp = 0; y_new = zeros(48000,10); time_now = 0; y_now = 0;
   t_new = zeros(48000,10); laser_time = 0; p = [];laser_angles = []; ID =0 ;
   new_scan_area = []; depth_projection = 0; proj_axis = 0;SP = [];
   laserToggle = 'laser_scan'; mode = 'Interpolation'; ratio = 0; click = [];
   
   % load the single wav file (merge all wav files)
   [~, dirName,~] = fileparts(folder);
   mergedfile = [dirName '.wav'];
   mergeWavs(folder, mergedfile);
   sound_file = [dirName '.wav'];
   [y,fs] = wavread(sound_file);
   full_time =  (1:length(y))/fs ;
   
   % load the single laser scan file
   laserfile = [folder filesep 'range_data.txt'];
   LaserFile = dir(laserfile);
   LaserFile = LaserFile.name;
   [laser.time, laser.angles, laser.scan] = readLaserFile(LaserFile);
   
   %% load the stick model file 
   try
        stickfile = [folder filesep 'stick_model.txt'];
        [stick_timestamp,trackID,stick_model, stickmodel] = ReadStickFile(stickfile);
   catch 
        stick_timestamp =  0;
        stickmodel = 0;
   end
   % for future use
   
   %%
   [start, ~, total_length] = computeLengthTime(folder,laser.time);
   s_step = 0.3;
   step = s_step/total_length;

   % compute slider properties based on modality files
   slider = uicontrol('Style','slider',...
          'Position',[0,0,810,20],...
          'Callback',{@Slider},'Max',total_length,...
          'SliderStep',[step step]); 
   
    set([f,hsound,hrgb,hlaser,hdepth,slider,add,remove,...
       select_mode,insert_speaker,speaker_panel,audio_panel,play_sound,face_detector,...
       speaker_speech,rgb_projection,export_data,info,zoom_out,...
       time_disp,frame_disp,clear_data,interpolation_points,fill_bboxes...
       ,toggle_laser,mode_panel,other_panel,Speech_disp,...
       LaserEdit,cancel_method,buttongroup,u0,u1,u2,diariazation,...
       annotation_summary,import_data],'Units','normalized');

   % Assign the GUI a name to appear in the window title.
   set(f,'Name',dirName);
   % Move the GUI to the center of the screen.
   movegui(f,'center')
   % Make the GUI visible.
   set(f,'Visible','on');

%% In every slider step load the specific modality files 

   function Slider(hObject,handles) 
       sp = get(hObject,'Value');
       sp = sp - mod(sp,s_step);
       set(time_disp,'String',sp);
       tmp = round(sp/s_step ) + 1;
       set(frame_disp,'String',tmp);
       set(Speech_disp,'String','No speech');
       [jpg_file ,laser_time ,depth_file,stick_idx] = ...
           find_modality_files(folder,start,sp ,laser.time,stick_timestamp);
       
       
       % edit depth data file
       depth_F = [folder filesep depth_file];
       depth_raw_data = readNPYdepth(depth_F);
       depth_data_in_meters = depth_raw_data / 1000;
       depth_data = depth_data_in_meters;
       
       % get stick model for future use
       if stickmodel ~= 0 
            stick = find(stick_timestamp == stick_timestamp(stick_idx));
            stick_now = stickmodel(stick,:);
       end
        
        %% WAV file
        set(Speech_disp,'Visible','on');
        e = 10e-05;
        speechlist = [];
        
        timestamp = find(full_time < sp + e & full_time > sp -e );
        if timestamp(end) <= fs
            time_now = full_time(1:2*fs);
            y_now = y(1:2*fs);
        elseif timestamp(end) >= length(full_time) - fs
            time_now = full_time(end-2*fs:end);
            y_now = y(end-2*fs:end);
        else
            time_now = full_time(timestamp(end)-fs:timestamp(end)+fs);
            y_now = y(timestamp(end)-fs:timestamp(end)+fs);
        end
        y_temp = y_now;
        time_temp = time_now;
        splot = plot(hsound,time_now,y_now);
        set(splot,'ButtonDownFcn', @zoomin);
        title(hsound,'Audio signal (.wav files)');
        % 'seconds' vertical time line
        line([sp sp],[-2,2],'Color','r','Parent',hsound);
        axis(hsound,[sp-1,sp+1,-1,1]);
        
 
        %% DEPTH DATAFILE
        
        depth = imshow(depth_data,[],'Parent',hdepth);
        set(depth,'ButtonDownFcn', @OnClickAxes); 
        title(hdepth,'Depth Data');
        
        %% LASER SCAN FILE
        
        e = 0.5;
        angle1 = find(laser.angles <  60.0834 + e & laser.angles >  60.0834  -e );
        angle2 = find(laser.angles <  119.9166 + e & laser.angles >  119.9166  -e );
        laser_angles = laser.angles(angle1:angle2);
        laser_range = length(laser_angles);
        scan = flipdim(laser.scan ,2);
        new_scan_area = scan(laser_time,angle1:angle2);
        switch laserToggle 
            case '2D-scan'
                laser_flip = flipdim(new_scan_area,2);
                XX = cos(deg2rad(laser_angles)).*laser_flip;
                YY = sin(deg2rad(laser_angles)).*laser_flip;
                lplot = plot(hlaser,XX,YY,'*');
                set(lplot,'ButtonDownFc',@select);
                title(hlaser, 'laser scan data - 2D');    
            case 'laser_scan'
                lplot = plot(hlaser,laser_angles,new_scan_area,'*');
                set(lplot,'ButtonDownFc',@select);
                title(hlaser, 'laser scan data');     
        end
        laser_ann();
        guidata(hObject,handles);
       
        
       %% RGB (.JPG) file
       k = 0;
       image_file = [folder filesep jpg_file]; % choose image file
       
       image = imread(image_file);
       if image == previous_image
           save_data();
           return;
       end
       ii = 1;
       
       try 
           a = frame{tmp};
       catch no_struct
           k = no_struct;
       end 
       
       % if an rgb image is annotated load the annotations
       if k == 0 & ~isempty(a)
          speakers = fieldnames(a);
          for i = 1 : length(speakers) 
              s = speakers{i};
              speaker_i_bbox = ['a.' s '.bbox'];
              bbox_i = eval(speaker_i_bbox);
              if isempty(bbox_i)
                  continue;
              end
              
          end
              % show images and bboxes 
              imshow(image,'Parent',hrgb);
              title(hrgb,'RGB image');
              names = fieldnames(a);
              NoOfSpeakers = length(fieldnames(a));
              for j = 1 : NoOfSpeakers
                s = names{j};
                eval(['bbox = a.' s '.bbox;']);
                if ~isempty(bbox)
                    if iscell(color)
                        color = cell2mat(color);
                    end
                    eval(['color = a.' s '.color;']);
                    eval(['ID = a.' s '.ID;']);
                    h = rectangle('Position',[bbox(1),bbox(2),bbox(3),bbox(4)], ...
                              'edgecolor',color,'Tag',s,'Parent',hrgb);
                    speaker = text(bbox(1),bbox(2),s,'Color',color,'Parent',hrgb);
                    set(h,'ButtonDownFcn', @select);set(speaker,'ButtonDownFcn', @select);
                end    
              end
              save_data(); 
              sound_ann(jpg_file);
              previous_image = image;
       else
           previous_image = image;
           a = [];
           imshow(image,'Parent',hrgb);
           title(hrgb,'RGB image');
           sound_ann(jpg_file);
           save_data();
           return;
       end
       
       
  end
% end of slider callback

    function sound_ann(image_filename)
        e = 0.005;
        if isempty(audio_rgb)
            return; 
        end
        % rgb
        audio_timestamps = cell2mat(audio_rgb(:,2:3));
        image_filename = eval(image_filename((7:end-4)) );
        image_tmp = image_filename/10^3 - start;
        for sa = 1 : size(audio_timestamps,1)
            if image_tmp > audio_timestamps(sa,1) & image_tmp < audio_timestamps(sa,2)
               speechlist = [speechlist; audio_rgb(sa,1)]; 
            end
        end
        if isempty(speechlist)
            speechlist = 'No speech';
        end
        set(Speech_disp,'String',speechlist);
        %wav
        
    end

    function diarization_method(hObject, handles)
       
        speakers = unique((audio_rgb(:,1)));
        NoOfSpeakers = length(speakers);
        save('speech_annotation','audio_rgb');
        
        % semi-supervised speaker diariazation method based on audio
        % Theodoros Giannakopoulos 
        infos = msgbox('Diarization method in procedure','Info');
        [Labels2, ~, ~, ~] = ldaCluster2_streamSimple(sound_file, NoOfSpeakers, 'speech_annotation.mat');
        % after the method we fill up the speech annotation matrix
        % first we have to match the manually annotated speakers with the
        % diariazation method output speakers
        
        % Problem if diarization method returns 0 (No speaker) for a segment 
        % while have been manually annotated as speaker by user
        audio_rgb = match_annotated_labels(audio_rgb,Labels2);
       
    end

    function annotated_segment(~,~)
        e = 0.5;
        SA = figure;
        hsl = uicontrol('Style','slider','Min',full_time(1),'Max',full_time(end)-5 ,...
                'SliderStep',[1 1]./(full_time(end)-full_time(1)),'Value',1,...
                'Position',[0 0 560 20],'Parent',SA,'Callback',{@move_slider});
        set([SA,hsl],'Units','normalized');
        plot(full_time(1:2*fs),y(1:2*fs));  
        if ~isempty(audio_timestamps)
            audio_timestamps = cell2mat(audio_rgb(:,2:3));
        end
        function move_slider(hObject,~) 
            slider_position = round(get(hObject,'Value'));
            if slider_position < 2
                slider_position = 2;
            end
            time2 = full_time((slider_position-1)*fs: (slider_position+5)*fs);
            y2 = y((slider_position-1)*fs  :  (slider_position+5)*fs);
            plot(time2,y2);
            if ~isempty(audio_timestamps)
                hold on;
                for sa = 1 : size(audio_timestamps,1)
                    w = find(time2 >= audio_timestamps(sa,1) & time2 <= audio_timestamps(sa,2));
                    if ~isempty(w)
                        speaker = cell2mat(audio_rgb(sa,1));
                        color = eval(['basic_struct.' speaker '.color';]);
                        pl = plot(time2(w),y2(w));
                        set(pl,'Color',color);
                    end   
                end
            end
            hold off;
        end


    end


    function laser_ann()
        % check for laser annotations
        l = 0 ;
        e = 0.5;
        try 
            laser_spots = laser_annotation{tmp};
        catch no_struct 
            l = no_struct;
            laser_spots = [];
        end
        hold(hlaser,'on');
        if l == 0

                for i = 1 : size(laser_spots,1)
                    angle1 = find(laser_angles <  laser_spots(i,1) + e & laser_angles >  laser_spots(i,1)  -e );
                    angle2 = find(laser_angles <  laser_spots(i,2) + e & laser_angles >  laser_spots(i,2)  -e );
                    angle1 = angle1(1);angle2 = angle2(1);
                    clr = laser_spots(i,3:5);
                    switch laserToggle 
                        case '2D-scan'
                            laser_flip = flipdim(new_scan_area,2);
                            XX = cos(deg2rad(laser_angles)).*laser_flip;
                            YY = sin(deg2rad(laser_angles)).*laser_flip;
                            spot1 = length(laser_angles) - angle2;
                            spot2 = length(laser_angles)- angle1;
                            ann_plot = plot(hlaser,XX(spot1:spot2),YY(spot1:spot2),'*');
                            set(ann_plot,'Color',clr,'Tag','LASER','ButtonDownFc',@select);
                        case 'laser_scan'
                            ann_plot = plot(hlaser,laser_angles(angle1:angle2),new_scan_area(angle1:angle2),'*');
                            set(ann_plot,'Color',clr,'Tag','LASER','ButtonDownFc',@select);
                    end
                end
            
        end
        hold(hlaser,'off');  
    end

   function toggle(hObject, handles)
      switch laserToggle
           case 'laser_scan' 
                laser_flip = flipdim(new_scan_area,2);
                XX = cos(deg2rad(laser_angles)).*laser_flip;
                YY = sin(deg2rad(laser_angles)).*laser_flip;
                lplot = plot(hlaser,XX,YY,'*');
                set(lplot,'ButtonDownFc',@select);
                title(hlaser, 'laser scan data - 2D');
                laserToggle = '2D-scan'; 
           case '2D-scan'
                YY = new_scan_area;
                XX = laser_angles;
                lplot = plot(hlaser,XX,YY,'*');
                set(lplot,'ButtonDownFc',@select);
                title(hlaser, 'laser scan data');
                laserToggle = 'laser_scan';
      end
      laser_ann();
   end
   function add_button(hObject,handles)
        [x1,x2] = ginput(2);
        x1 = floor(x1);
        x2 = floor(x2);
        answer = speaker_dlgbox;
       
        % check if speaker name is available
        if ~isfield(basic_struct,answer)
            warndlg('No available speaker ID','Invalid speaker ID');
            return;
        end
        % check if speaker already exists
        if isfield(a,answer)
            warndlg('Speaker Name Exists','Choose another speaker name');
            return;
        end
        eval(['a. ' cell2mat(answer)  '  = basic_struct.' cell2mat(answer) ';']);
        eval(['color = a. ' cell2mat(answer)  '.color;']);
        if iscell(color)
            color = cell2mat(color);
        end
        h = rectangle('Position',[x1(1),x2(1),x1(2) - x1(1),x2(2)-x2(1)], ...
            'edgecolor',color,'Tag',cell2mat(answer));
        bbox = [x1(1),x2(1),x1(2) - x1(1),x2(2)-x2(1)];
        speaker = text(x1(1),x2(1),answer,'Color',color);
        name = answer{1};
        eval(['a.' cell2mat(answer) '.bbox = bbox;']); 
        set(speaker,'ButtonDownFcn', @select);
        set(h,'ButtonDownFcn', @select);
        set(h,'Tag',name);
        save_data();
        guidata(hObject,handles);
   end

   function remove_button(hObject,handles)
       if gca == hlaser | gca == hdepth
           x_data = get(item,'XData');  
           d = find(laser_spots(:,1)== x_data(1));
           laser_spots(d,:) = [];
           delete(item);
           save_data();
           return;
       end
       button = questdlg('Delete item???');
       if strcmp(button,'Yes')
           tag = get(item,'Position');
           tag_color = get(item,'EdgeColor');
           % change speaker's properties
           d1 = findall(hrgb,'Position',[tag(1),tag(2)]);
           d2 = findall(hrgb,'Position',[tag(1)+tag(3),tag(2)+tag(4)]);
           d3 = findall(hdepth,'Color',tag_color);
           d4 = findall(hlaser,'Color',tag_color);
           d5 = findall(hrgb,'Position',tag_color);
           s = get(d1,'String');
           if iscell(s)
               s = s{1};
           end
           eval(['a.' s  '.bbox = [];']);
           delete(d1);delete(d2); delete(item);
           delete(d3);delete(d4);delete(d5);
           a = rmfield(a,s);
       elseif strcmp(button,'No')
           refresh;
       end
       save_data();
       refresh;
       guidata(hObject,handles);
   end

   function select_md(hObject,handles)
       value = get(hObject,'Value');
       mode = modelist(value);
       
       if iscell(mode)
           mode = cell2mat(mode);
           switch mode 
               case 'Interpolation'
                   set(interpolation_points,'String','Interpolation points');
               case 'Tracking'
                   set(interpolation_points,'String','Tracking frames');
          end
       end
   end

   function insert_spkr(hObject,handles)
        speaker = get(hObject,'String');
        previous_tag = get(item,'Tag');
        % change speaker's properties
        eval(['a.' speaker ' = a.' previous_tag ';']);
        eval(['basic_struct.' speaker ' = basic_struct.' previous_tag ';']);
        find_string = {previous_tag};
        a = rmfield(a,previous_tag);
        basic_struct = rmfield(basic_struct,previous_tag);
        d = findall(hrgb,'String',find_string);
        if isempty(d)
            d = findall(hrgb,'String',previous_tag);
            if isempty(d)
                return;
            end
        end
        set(item,'Tag',speaker,'LineStyle','-');
        set(d,'String',speaker);
        frame = update_data(previous_tag,speaker,frame);
        for i = 1 : size(audio_rgb,1)
            if strcmp(audio_rgb{i,1},previous_tag)
                audio_rgb{i,1} = speaker;
            end
        end
        guidata(hObject,handles);
   end

   function play_wav(hObject,handles)
       soundsc(y_temp,fs);
       guidata(hObject,handles);
   end

   function sp_speech(hObject,handles)
       p = get(item,'Position');
       c = get(item,'edgecolor');
       speech_pos = [p(1),p(2)+p(4)];
       s = text(speech_pos(1),speech_pos(2),'(S)','Color',c,...
                 'LineWidth',0.5,'Parent',hrgb);
       set(item,'LineStyle','-');
       audio_rgb = [audio_rgb ; {get(item,'Tag'),time_temp(1),time_temp(end)}];
       speechlist = [{get(item,'Tag')} ];
       set(Speech_disp,'String',speechlist);
       save_data();
       guidata(hObject,handles);
   end

   function fd(hObject,handles)
       bbox = face_detect(image);
       if isempty(bbox)
           msgbox('No faces detected'); 
       end
       for i = 1 :size(bbox,1)
            color = colors{i};
            name = ['Speaker' num2str(i)];
            % keep the info for this speaker
            eval(['a.Speaker' num2str(i) '.bbox = bbox(1,:);']);
            eval(['a.Speaker' num2str(i) '.ID =' num2str(i) ';']);
            rectangle('Parent',hrgb,'Position',[bbox(i,1),bbox(i,2),...
                bbox(i,3),bbox(i,4)],'edgecolor',color,...
                'Tag',name,'ButtonDownFcn', @select);
            text(bbox(i,1),bbox(i,2),name,'Color',color,...
                'Parent',hrgb,'ButtonDownFcn', @select);
       end
       save_data(); 
       guidata(hObject,handles);
   end

   function rgb_proj(hObject,handles)
     
      figure('WindowStyle','normal');
      dimage = subplot('Position',[0.13,0.3,0.7,0.7]);depth_image = imshow(depth_data,[]);title('depth image');
      bottom_image = depth_data(9*(size(depth_data,1)/10):end,:);
      bottom_image = removeDepthHoles(bottom_image);
      X = sum(bottom_image);
      proj_axis = subplot(4,1,4);depth_projection = plot(X);title('projected depth image');
      set([proj_axis,dimage],'Units','normalized');
       
      set(depth_projection,'ButtonDownFcn', @OnClickAxes); 
      set(depth_image,'ButtonDownFcn', @OnClickAxes); 
      guidata(hObject,handles);
      
   end

   
   function zoomin(hObject, handles)
        
         e = 0.01;
         
         % choose zoom area
         rect1=getrect;
         t1 = rect1(1);
         t2 = rect1(1) + rect1(3);
         t_a = time_temp(time_temp<=t1+e & time_temp>=t1-e);
         t_b = time_temp(time_temp<=t2+e & time_temp>=t2-e);
         if isempty(t_a)
             warndlg('Wrong x_coords. Try again...');
             return;
         end
         t_a = t_a(1); t_b = t_b(end);
         t_a = find(time_temp == t_a);
         t_b = find(time_temp == t_b);
         t_new = time_temp(t_a:t_b);
         y_new = y_temp(t_a:t_b);
         splot = plot(hsound,t_new,y_new);
         set(splot,'ButtonDownFc',@zoomin);
         line([sp sp],[-1,1],'Color','r','Parent',hsound);
         axis(hsound,[time_temp(t_a),time_temp(t_b),-1,1]);
         y_temp = y_new;
         time_temp = t_new;     
%        guidata(hObject,handles);
         
   end

   function zoomout(hObject, handles)
       y_temp = y_now;
       time_temp = time_now;
       splot = plot(hsound,time_temp,y_temp);
       line([sp sp],[-2,2],'Color','r','Parent',hsound);
       set(splot,'ButtonDownFc',@zoomin);
       axis(hsound,[sp-1,sp+1,-1,1]);
       guidata(hObject,handles);
   end

   function OnClickAxes( ~, ~ )
        dd = findobj(hdepth,'Type','text');
        delete(dd);
        pp = get(gca,'CurrentPoint');
        pp = pp(1,1:2);
        
        px = floor(pp(1));
        py = floor(pp(2));
        depth_distance = depth_data(py,px);
        text(px-100,py-100,num2str(depth_distance),'Color','y');
        click = [click;px];
        if mod(size(click,1), 2) ~= 0
            return;
        else    
        
        bottom_image = depth_data(9*(size(depth_data,1)/10):end,:);
        bottom_image = removeDepthHoles(bottom_image);
        X = sum(bottom_image);
        
        % linear mapping to laser scan
        ratio = length(X)/ laser_range;
        laser_mapping = floor(click(:,1)/ratio); click = [];
        mapping_spot = laser_angles(laser_mapping);
        point1 = find(laser_angles == mapping_spot(1));
        point2 = find(laser_angles == mapping_spot(2));
        points = [floor(point1*ratio), floor(point2*ratio)];
        X_range = X(point1 : point2);
        Y = [point1 : point2 ];
        D = mean(points);
        if gca ~= hdepth
            hold(proj_axis,'on');
            title('projected depth image');
            pl = plot(proj_axis,Y,X_range);
            hold(proj_axis,'off');
        end
        % function to get color of the specific speaker
        bboxes = findall(hrgb,'Type','rectangle');
        for i = 1 : length(bboxes)
            bbox_pos(i,:) = get(bboxes(i),'Position');
            dis(i) = abs(D - (bbox_pos(i,1) + (bbox_pos(i,3)/2)));
        end
        if ~isempty(bboxes)
            idx = find(dis==min(min(dis)));
            clr = get(bboxes(idx),'EdgeColor');
            name = get(bboxes(idx),'Tag');
            ID = eval(['frame{' num2str(tmp) '}.' name '.ID']);
            
            if gca ~= hdepth
                set(pl,'Color',clr,'ButtonDownFc',@select);
            end
        else
            warndlg('Assign speaker labels first..!!');
            return;
        end
        
            
        hold(hlaser,'on');
        laser_spots = [laser_spots;[mapping_spot, clr,ID, laser_time]];
        switch laserToggle
            case 'laser_scan'
                laserplot = plot(hlaser,laser_angles(point1:point2),new_scan_area(point1:point2),'*');
                set(laserplot,'Color',clr,'Tag','LASER','ButtonDownFc',@select);
            case '2D-scan'
                laser_flip = flipdim(new_scan_area,2);
                XX = cos(deg2rad(laser_angles)).*laser_flip;
                YY = sin(deg2rad(laser_angles)).*laser_flip;
                spot1 = length(laser_angles) - point2;
                spot2 = length(laser_angles)- point1;
                ann_plot = plot(hlaser,XX(spot1:spot2),YY(spot1:spot2),'*');
                set(ann_plot,'Color',clr,'Tag','LASER','ButtonDownFc',@select);
        end
        hold(hlaser,'off');
        
        save_data();
        end
        
   end

function intrpl_points(hObject, handles)
    % get bboxes from frames
    switch mode
        case 'Interpolation'
            % (MAYBE USE STRUCTURE NOT FINDOBJ)
            h = findobj('Type','rectangle');    
            set(h,'LineWidth',2);
            intrpl_frames = get(h,'Position');
            if ~iscell(intrpl_frames)
                intrpl_frames = {intrpl_frames};
            end
            clr = get(h,'EdgeColor');

            if ~iscell(clr)
                clr = {clr};
            end
            name = get(h,'Tag');
            if ~iscell(name)
                name = {name};
            end
            for intrpl = 1 : length(h)
                s = name{intrpl};
                eval(['ID = a.' s '.ID;']);
                SP = [ SP ;ID tmp intrpl_frames{intrpl} clr{intrpl} {s} {laser_spots}];
            end
        case 'Tracking'
            h = findobj(hrgb,'Type','rectangle');  
            if ~isempty(h)
                set(h,'LineWidth',2);
                intrpl_frames = get(h,'Position');
                if ~iscell(intrpl_frames)
                    intrpl_frames = {intrpl_frames};
                end
                clr = get(h,'EdgeColor');
                if ~iscell(clr)
                    clr = {clr};
                end
                name = get(h,'Tag');
                if ~iscell(name)
                    name = {name};
                end
                for intrpl = 1 : length(h)
                    s = name{intrpl};
                    eval(['ID = a.' s '.ID;']);
                    SP = [ SP ;ID sp intrpl_frames{intrpl} image clr{intrpl} {s}];
                end
            else
                % care only for frame
                SP = [SP; -1 sp [0,0,0,0] [0] [0,0,0] {''}];
            end
                
    end
            
    
end
    

function fill_bbox(hObject, handles)
% get bboxes from frames selected and intrpl/tracking
    switch mode
        case 'Interpolation'
        if isempty(SP)
            warndlg('Interpolation needs at least two stat-end points..');
            return;
        end
        
        
        SP = sortrows(SP,1);
        IDs = [SP{:,1}];
        IDs = unique(IDs);
        wb = waitbar(0,'Interpolation...Please wait...');
        laser_new = [];
        for jj = 1 : length(IDs)
            
            SP_j = SP([SP{:,1}] == IDs(jj),:);
            t = [SP_j{:,2}]';
            bboxes = cell2mat(SP_j(:,3));
            X_sp = bboxes(:,1);
            Y_sp = bboxes(:,2);
            W = bboxes(:,3);
            L = bboxes(:,4);
            clr = SP_j(1,4);
            name = SP_j(1,5);
            laser_anns = cell2mat(SP_j(:,6));
            if ~isempty(laser_anns)
                laser_ann_1 = laser_anns(laser_anns(:,6)==IDs(jj),1);
                laser_ann_2 = laser_anns(laser_anns(:,6)==IDs(jj),2);
            end
            for tt = t(1):t(end)
                waitbar(tt / t(end))
                if strcmp(objects2track,'Faces') | strcmp(objects2track,'Both')
                    xtemp(tt) = interp1(t, X_sp, tt, 'cubic');
                    ytemp(tt) = interp1(t, Y_sp, tt, 'cubic');
                    Wtemp(tt) = interp1(t, W, tt, 'cubic');
                    Ltemp(tt) = interp1(t, L, tt, 'cubic');  
                    speaker.color = clr{1,:};
                    speaker.name = name{1};
                    speaker.ID = IDs(jj);
                    speaker.bbox = [xtemp(tt) ytemp(tt) Wtemp(tt) Ltemp(tt)];
                    eval([ 'frame{' num2str(tt) '}.' name{1} '= speaker']);
                end
                if strcmp(objects2track,'Laser') | strcmp(objects2track,'Both')
                    laser1(tt) = interp1(t, laser_ann_1, tt, 'cubic');
                    laser2(tt) = interp1(t, laser_ann_2, tt, 'cubic'); 
                    laser_annotation{tt} = [laser_new;laser1(tt), laser2(tt),clr{1,:},IDs(jj)];
                    laser_new = laser_annotation{tt};
                    if isempty(now)
                        continue;
                    end
                end
            end
        end
        close(wb);
        SP = [];
        case 'Tracking'
            frame_array = [];
            laser_array = [];
            if isempty(SP)
                warndlg('Tracking needs at least one start point..');
                return;
            end
            
            IDs = cell2mat(SP(:,1));
            IDs = unique(IDs(IDs>0));
            frames = cell2mat(SP(:,2));
            frames = unique(frames);
            first_frame = round(frames(1)/s_step );
            frame_array = [{first_frame}];
            laser_array = [{first_frame}];
            wbar = waitbar(0,'Loading frames for tracking...');
            
            for ii = frames(1):s_step:frames(2)
                 [jpg_file, laser_frame,~,~] = find_modality_files(folder,start,ii ,laser.time,0);
                 frame_array = [frame_array;jpg_file]; 
                 laser_array = [laser_array;laser_frame];
                 waitbar(ii/frames(2));
            end
            close(wbar);
            
            for i = 1 : length(IDs)
                SP_id = SP([SP{:,1}] == IDs(i),:);
            
                bboxes2track = SP_id{1,3};
                I = SP_id{1,4};
                target.clr = SP_id{1,5};
                target.name = SP_id{1,6};
                target.bbox = bboxes2track;
                faceImage = imcrop(I,target.bbox(1,:));
                target.fImage = faceImage;
                target.ID = IDs(i);

                
                [frame,laser_annotation] = FaceMSTracking(I,target,frame_array,frame,laser_annotation,ratio,laser_angles,objects2track);
                
            end
            SP = [];  
    end
end

    function laser_edit(hObject, handles)
       e = 0.5;
       r = getrect;
       new_points = [r(1), r(1)+r(3)];
       clr = get(item,'Color');
       old_pos = get(item,'XData');
       
       if length(new_points) == 2
           point1 = find(laser_angles < new_points(1) + e & laser_angles >  new_points(1) - e );
           point2 = find(laser_angles < new_points(2) + e & laser_angles >  new_points(2) - e );  
           hold(hlaser,'on'); 
           laserplot = plot(hlaser,laser_angles(point1(1):point2(end)),new_scan_area(point1(1):point2(end)),'*');
           set(laserplot,'Color',clr,'Tag','Laser','ButtonDownFc',@select);
           d = find(laser_spots(:,1)< old_pos(1) + e & laser_spots(:,1) >  old_pos(1) - e );
           new_points = [laser_angles(point1(1)) ,laser_angles(point2(end))];
           laser_spots(d(1),:) = [new_points, clr,ID,laser_time];
           delete(item);
           hold(hlaser,'off');
           save_data();
       end
       
      
       
       
    end




%%
function selcbk(hObject,handles)
     button_group = get(hObject,'SelectedObject');  
     objects2track = get(button_group,'String');
end

function exportdata(hObject,handles)
       
       prompt = {'Insert file name to save:'};
       dlg_title = 'Export data';
       num_lines = 1;
       def = {' '};
       answer = inputdlg(prompt,dlg_title,num_lines,def);
       speaker_data = [char(answer) '_data'];
       speech_data = [char(answer) '_speech'];
       laser_data = [char(answer) '_laser'];
       all_data = [char(answer) '_all'];
       save(speaker_data,'frame');
       save(speech_data,'audio_rgb');
       save(laser_data,'laser_annotation');
       save(all_data,'frame','audio_rgb','laser_annotation');
       guidata(hObject,handles);
   
end

    function importdata(hObject,handles)
        [FileName,PathName] = uigetfile('*.mat','Select the MATLAB data file');
        
        data = load([PathName filesep FileName]);
        fields = fieldnames(data);
        for i = 1: length(fields)
            s = fields{i};
            eval([s ' = data.' s]);
        end
        msgbox('Data loaded');
        guidata(hObject,handles);
    end
        

   function cleardata(hObject,handles)
       choice = questdlg('Clear data?', ...
        'Clear Data','Clear bboxes','Clear laser data','Clear all','');
       switch choice
            case 'Clear laser data'
                frame = {};
                a = basic_struct; 
                SP = [];
                p = [];
                laser_annotation = {};
                audio_rgb = [];
                obj1 = findall(hrgb,'Type','Rectangle');
                clr = get(obj1,'EdgeColor');
                if size(clr,1) == 1
                    clr = {clr};
                end
                for i = 1 : length(clr)
                    obj4 = findobj(hlaser,'Type','line','Color',clr{i});
                    delete(obj4);
                end
                basic_struct = default_struct;
            case 'Clear bboxes and audio'
                frame = {};
                a = []; 
                SP = [];
                p = [];
                audio_rgb = [];
                set(Speech_disp,'String','No speech');
                obj1 = findall(hrgb,'Type','Rectangle');
                obj2 = findobj(hrgb,'Type','Text');
                delete(obj2);
                basic_struct = default_struct;
            case 'Clear all'
                 frame = {};
                 a = [];
                 SP = [];
                 p = [];
                 laser_annotation = {};
                 audio_rgb = [];
                 set(Speech_disp,'String','No speech');
                 obj1 = findall(hrgb,'Type','Rectangle');
                 clr = get(obj1,'EdgeColor');
                 obj2 = findobj(hrgb,'Type','Text');
                 if size(clr,1) == 1
                     clr = {clr};
                 end
                 for i = 1 : length(clr)
                    obj4 = findobj(hlaser,'Type','line','Color',clr{i});
                    delete(obj4);
                 end
                    delete(obj1);delete(obj2);
                    basic_struct = default_struct;
           case ''
               return;
       end
       guidata(hObject,handles);
   end
   function select(hObject, handles)
       item = gco;   
       set(item,'LineStyle',':');
   end
   function cancel(hObject,handles)
       SP = [];
   end

   function save_data()
       refresh;
       frame{tmp} = a;
       laser_annotation{tmp} = laser_spots;     
   end

   function infos(hObject, handles)
       save_data();
       speakernames = fieldnames(basic_struct);
       helpstr{1} = 'ID -- name';
       for k = 1 : length(speakernames)
           s = speakernames{k};
           id = eval(['basic_struct.' s '.ID']);
           str_line = [num2str(id) ':   ' s ];
           helpstr{k+1} = str_line;
       end
       helpdlg(helpstr,'Valid ID - speakers');  
       guidata(hObject,handles);
   end


   
end
