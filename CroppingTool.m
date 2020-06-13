function varargout = CroppingTool(varargin)
% CROPPINGTOOL MATLAB code for CroppingTool.fig
%      CROPPINGTOOL, by itself, creates a new CROPPINGTOOL or raises the existing
%      singleton*.
%
%      H = CROPPINGTOOL returns the handle to a new CROPPINGTOOL or the handle to
%      the existing singleton*.
%
%      CROPPINGTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CROPPINGTOOL.M with the given input arguments.
%
%      CROPPINGTOOL('Property','Value',...) creates a new CROPPINGTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CroppingTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CroppingTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CroppingTool

% Last Modified by GUIDE v2.5 31-Mar-2020 18:24:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CroppingTool_OpeningFcn, ...
    'gui_OutputFcn',  @CroppingTool_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before CroppingTool is made visible.
function CroppingTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CroppingTool (see VARARGIN)

% Choose default command line output for CroppingTool
handles = guidata(hObject);
handles.coordinates = [];
handles.index = 1;
handles.loaded = 0;
handles.duration = [];
handles.rate = 0;
handles.counter = 0;

% Choose default command line output for Guide
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using Guide.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes CroppingTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CroppingTool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open the video
[filename, handles.selpath, filterindex] = uigetfile({'*.mp4','*.mov','*.avi'}', 'Select a video to open');
set(handles.text1, 'String', 'Loading. Please wait...');

% Create the subfolder imagestack if it does not exist already
if ~exist([handles.selpath  'imagestacks'], 'dir')
    mkdir([handles.selpath  'imagestacks']);
end

% global variables for the project
handles.coordinates = [];
handles.index = 1;
handles.loaded = 1;
handles.name = filename;
handles.videoFReader = VideoReader([handles.selpath filesep handles.name]);
handles.fr = get(handles.videoFReader,'FrameRate');

% I was using intelligent eye detection but had to disable it for difficult
% cases with lenses
handles.eyeDetector = vision.CascadeObjectDetector('EyePairBig'); %'EyePairBig');%RightEyeCART

% Read the first frame and display it
handles.nFrames = get(handles.videoFReader, 'NumberOfFrames');
A  = read(handles.videoFReader, handles.index); 
im = image(A);
handles.image = A;
im.ButtonDownFcn = @axes1_ButtonDownFcn;

% Instructions on screen
mystring = sprintf(['Scroll the slider until you select a frame with a wide eye open.','\n','If there is a time where the subject is asked to blink voluntarily, write the number under seconds, otherwise leave 0','\n','Click the top left corner of the face to start']);
set(handles.text1, 'String', mystring);
guidata(hObject, handles);
axes(handles.axes1);


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
% Update instructions on screen - 4 clicks to define rectangle
switch handles.index
    case 1
        set(handles.text1, 'String', 'Click the top right corner');
    case 2
        set(handles.text1, 'String', 'Click the bottom left corner');
    case 3
        set(handles.text1, 'String', 'Click the bottom right corner');
       
end

cpt = get(gca,'CurrentPoint');
handles.coordinates(handles.index,1:2) = cpt(1,1:2);
handles.index = handles.index +1;
error = false;

% Once we have the four coordinates, run the detection algorithm
if handles.index == 5
    leftx = min(handles.coordinates(1,1),handles.coordinates(3,1));
    topy = min(handles.coordinates(1,2), handles.coordinates(2,2));
    rightx = max(handles.coordinates(2,1), handles.coordinates(4,1));
    bottomy = max(handles.coordinates(3,2), handles.coordinates(4,2));
    % crop the image accordingly with the four courdinates
    newimage = handles.image(round(topy):round(bottomy), round(leftx):round(rightx),:);
    
    
    f1 = figure;
    subplot(2,2,1),
    imshow(newimage);
    title('Eyes detector');
   % This code commented used to run the intelligent eye detector. It has
   % been commented for the hard cases
    try
%         BB = step(handles.eyeDetector,newimage);
%         if ~isempty(BB)
%             if size(BB,1)>3
%                 index = 4;
%             else if size(BB,1)>1
%                     index = 2;
%                 else
%                     index = 1;
%                 end
%                 
%             end
%             rectangle('Position',BB(index,1:4),'LineWidth', 3,'LineStyle', '-', 'EdgeColor', 'r');
%             Eyes = imcrop(newimage,BB(index,1:4));
%             handles.whiteness = sum(Eyes(:));
%         else
%             disp('Not found');
%         end
        Eyes = newimage;
        HSIimg = rgb2hsv(Eyes);        
        S = HSIimg(:,:,2);
        [m n] = size(S);
        subplot(2,2,2),
        imshow(S);
        title('Saturation Image');
        axis off %%
        % We apply the binarization (brighter pixels are converted into
        % white using the first threshold)
        S(S< str2num(handles.threshold.String)/100)=255;
              
        threshsclera = uint8(S);
        subplot(2,2,3),
        imshow(threshsclera);
        title('Thresholded Sclera');
        axis off; %%
        BW = (threshsclera==255);
        % We refined the result with the area open filter
        scleraimg = bwareaopen(BW,100);
        handles.whiteness= sum(scleraimg(:));
        subplot(2,2,4), imshow(scleraimg);
        title(['Sclera Mask - whiteness index ' int2str(handles.whiteness)]);
    catch
     
        error = true;
        
    end
    
    %If there were no errors ask the user for confirmation with current
    %threshold
    if ~error
        prompt = {'If the cropping window is fine and the white thresholding of the sclera is correct, write name for new folder (under imagestack). Otherwise click Cancel to redo and change parameters - bigger values in Threshold will be less aggresive during the binarization (more white will be visible) and bigger values for White% will return more potential blink cases'};
        dlgtitle = 'Check window';
        answer = inputdlg(prompt,dlgtitle);
        close(f1);
      
        % If user not satisfied with the current thresholding, then start over
        if isempty(answer)%   case 'No'
            handles.index = 1;
            handles.coordinates = [];
            set(handles.text1, 'String', 'Click the top left corner of the face');
            %case 'Yes'
        else
            set(handles.text1, 'String', 'Generating image stack. Please wait...');
            
            % Make the folders for each case
            answer = cell2mat(answer);
            if ~exist([handles.selpath 'imagestacks' filesep answer], 'dir')
                mkdir([handles.selpath 'imagestacks' filesep answer]);
                mkdir([handles.selpath 'imagestacks' filesep answer filesep 'volitional']);
                mkdir([handles.selpath 'imagestacks' filesep answer filesep 'involuntary']);
                mkdir([handles.selpath 'imagestacks' filesep answer filesep 'noeye']);
                mkdir([handles.selpath 'imagestacks' filesep answer filesep 'noblink']);
            end
            duration = handles.nFrames / handles.fr;
          
            
            w = waitbar(0,'Please wait...');
            
            % local variables for statistics
            blinktimes = [];
            secperframe = 1/handles.fr;
            numblinks = 0;
            blinking = false;
            blinkframes = [];
            i = 1;
            
            % Iterate until we cover all frames
            while i < handles.nFrames
                %  try
                image =  read(handles.videoFReader, i); 
                
                % Use the cropped image
                newimage = image(round(topy):round(bottomy), round(leftx):round(rightx),:);
                
                % Classifying frame with blink o no
                blinkYesNo = classify(handles, newimage);
                
                if blinkYesNo==1 && ~blinking
                    numblinks = numblinks + 1;
                    blinking = true;
                    a = i;
                end
                
                if ~blinkYesNo && blinking
                    blinking = false;
                    handles.duration = cat(1,handles.duration, (i-a)*handles.fr);
                end
                
                if blinkYesNo==1
                    blinktimes = cat(1,blinktimes,[i,secperframe*i,1]);
                    
                    category = 'involuntary';
                    
                    % If there is any number different than 0 in the
                    % interface for seconds, it would save blinks detected
                    % after that period in the folder 'volitional'
                    if handles.voluntary.String ~= "0" && i>= str2double(handles.voluntary.String)*handles.fr
                        % It is voluntary
                        category = 'volitional';
                    end
                    % It is a blink, so we save the frame 
                    imwrite(newimage,[ handles.selpath 'imagestacks' filesep answer filesep category filesep handles.name(1:end-4) '-' answer '-' num2str(i) '.jpg']);
                    
                    i = i+1;
                else
                    if blinkYesNo == 0
                        category = 'noblink';
                        
                        
                        % Not a blink, so we register the frame as no blink
                        % to save it later
                        blinkframes = cat(1,blinkframes,i);
                        i = i + 1;%handles.framestep.String);
                    else
                        disp('no eye');
                        category = 'noeye';
                        i = i + 1;
                    end
                end
                
                waitbar(i/handles.nFrames,w,['Processing blinks. Please wait. ', num2str(numblinks) ' blinks found' ]);
                
            end
            
            % here we save frames that were not blink. We will save 1 for
            % every X (the number indicated in the interface, by default is 10)
            %disp('saving no blink frames');
            noblinktimes = [];
            for i=1:str2num(handles.framestep.String):length(blinkframes)
                waitbar(i/length(blinkframes),w,['Saving no blink frames. Please wait. ' num2str(numblinks) ' blinks found' ]);
                image =  read(handles.videoFReader, blinkframes(i)); %handles.data(i);
                category = 'noblink';
                imwrite(image,[ handles.selpath 'imagestacks' filesep answer filesep category filesep handles.name(1:end-4) '-' answer '-' num2str() '.jpg']);
                noblinktimes = cat(1,noblinktimes,[blinkframes(i), secperframe*blinkframes(i), 0]);
            end
            globaltimes= [];
            % If we found any blink, we save the info of timesamples in an
            % excel and the statistics in a text file
            if ~isempty(blinktimes)
                fileID = fopen([handles.name '.txt'],'w');
                fprintf(fileID, ['Blinks found: ' num2str(numblinks) ', blink rate:' num2str(60*numblinks/duration) ' per minute, average blink duration =' num2str(mean(handles.duration)) ' ms' ]);
                fclose(fileID);
                globaltimes = cat(1,globaltimes,blinktimes);
            end
            globaltimes = cat(1,globaltimes,noblinktimes);
           
            xlswrite([handles.name '.xls'], globaltimes, 'Sheet1' );
            close(w);
            set(handles.text1, 'String', ['Done. Frames non identified: ' num2str(handles.counter) '; Blinks found: ' num2str(numblinks) ', blink rate:' num2str(60*numblinks/duration) ' per minute, average blink duration =' num2str(mean(handles.duration)) ' ms - Click on the image to start again']);
            
        end
        handles.index =1;
    else
        % if there was an error, start over 
        handles.index = 1;
        close(f1);
        handles.coordinates = [];
        set(handles.text1, 'String', 'No eye detected. Try again. Click the top left corner of the face');
        error = false;
    end
    
end

axes(handles.axes1);

guidata(hObject, handles);

% This function was not used in the end
function [movmat movobj]=doReadMovie(file)
 w = waitbar(0,'Please wait...');
% creat movie object
movobj=VideoReader(file);

% video specs
nFrames=movobj.NumberOfFrames;
vidHeight=movobj.Height;
vidWidth=movobj.Width;
a = tic;
% Read one frame at a time.
for k=1:nFrames
    
    waitbar(k/nFrames,w,'Reading frames. Please wait' );
            
    movmat(k).cdata=read(movobj,k);
end
disp(toc(a));
save('temporal.mat', 'movmat', 'movobj', '-v7.3');



% This function is the one classifying the frames with blink or not
function category = classify(handles, image)

try
%     BB = step(handles.eyeDetector,image);
%     if ~isempty(BB)
%         if size(BB,1)>3
%             index = 4;
%         else
%             if size(BB,1)>1
%                 index = 2;
%             else
%                 index = 1;
%             end
% 
%         end
%         %rectangle('Position',BB(index,1:4),'LineWidth', 3,'LineStyle', '-', 'EdgeColor', 'r');
%         Eyes = imcrop(image,BB(index,1:4));
%     else
%         disp('Not found');
%     end
    Eyes = image;
    HSIimg = rgb2hsv(Eyes);
    S = HSIimg(:,:,2);
    
    % Same thresholding that it was applied in the first frame
    S(S< str2num(handles.threshold.String)/100)=255;
    threshsclera = uint8(S);
    category = 0;
    threshsclera = uint8(threshsclera);
    BW = (threshsclera==255);
    scleraimg = bwareaopen(BW,100);%6000
    whiteness= sum(scleraimg(:));

    if whiteness < (handles.whiteness)*(str2double(handles.whitepercent.String))/100
        category = 1;
    end
catch
    %disp('There was a frame where the eye detector did not work');
    handles.counter = handles.counter+1;
    category=2;
    
end





% --- Executes on slider movement.
function myslider_Callback(hObject, eventdata, handles)
% hObject    handle to myslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles = guidata(hObject);
if handles.loaded ==1
    
    % the slider updates with the equivalent frame to the slider position
    set(hObject,'Max', round(handles.videoFReader.duration));
    slidervalue = max(1,get(hObject,'Value'));
    A = read(handles.videoFReader, round(handles.videoFReader.FrameRate*slidervalue));
    im = image(A);
    handles.image = A;
    im.ButtonDownFcn = @axes1_ButtonDownFcn;
end

guidata(hObject, handles);
axes(handles.axes1);

%handles.sliderval =  get(hObject,'Value'); %returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function myslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to myslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function voluntary_Callback(hObject, eventdata, handles)
% hObject    handle to voluntary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of voluntary as text
%        str2double(get(hObject,'String')) returns contents of voluntary as a double


% --- Executes during object creation, after setting all properties.
function voluntary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voluntary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function whitepercent_Callback(hObject, eventdata, handles)
% hObject    handle to whitepercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of whitepercent as text
%        str2double(get(hObject,'String')) returns contents of whitepercent as a double


% --- Executes during object creation, after setting all properties.
function whitepercent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whitepercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function framestep_Callback(hObject, eventdata, handles)
% hObject    handle to framestep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framestep as text
%        str2double(get(hObject,'String')) returns contents of framestep as a double


% --- Executes during object creation, after setting all properties.
function framestep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framestep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
