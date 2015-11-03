function varargout = MusicFace(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MusicFace_OpeningFcn, ...
                   'gui_OutputFcn',  @MusicFace_OutputFcn, ...
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

function MusicFace_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
handles.output = hObject;

guidata(hObject, handles);

setBlockStarted(false)
setInitialBlocksCompleted
setTrackOrder

setIntroText(handles)

function varargout = MusicFace_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
varargout{1} = handles.output;

function figure_KeyPressFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
numberPressed = str2double(eventdata.Key);

if strcmp(eventdata.Key, 'space') && ~getBlockStarted
    startBlock(handles)
elseif numberPressed >= 1 && numberPressed <= 7 && getBlockStarted
    fprintf(getFileID, num2str(numberPressed));
    fprintf(getFileID, [', ', num2str(toc)]);
end

function startBlock(handles)
setBlockStarted(true)

if getBlocksCompleted == 0
    setFileID
end

fprintf(getFileID, ['\n\nBlock: ', num2str(getBlocksCompleted + 1)]);

set(handles.textbox, 'Visible', 'Off')

delay = startMusic;

startBlockTimer = timer('StartDelay', delay);
startBlockTimer.TimerFcn = {@startImages, handles};
start(startBlockTimer)

function delay = startMusic
randomTrackOrder = getTrackOrder;
randomTrackType = randomTrackOrder(getBlocksCompleted + 1);
randomTrackFolder = '';

switch randomTrackType
    case 1
        randomTrackFolder = 'Happy';
    case 2
        randomTrackFolder = 'Sad';
end

trackCount = 1; % This should be however many tracks there are
randomTrackNumber = randi([1, trackCount]);

delay = 0;

if ~isempty(randomTrackFolder)
    [y, Fs] = audioread(['Tracks/', randomTrackFolder, '/', num2str(randomTrackNumber), '.wav']);
    sound(y, Fs)
    
    fprintf(getFileID, ['\nMusic type: ', randomTrackFolder]);
    
    delay = 30;
end

function startImages(obj, event, handles) %#ok<INUSL>
setInitialFacesCompleted

faceTypeOrder(1 : getFaceCount / 3) = 1;
faceTypeOrder((getFaceCount / 3) + 1 : (getFaceCount / 3) * 2) = 2;
faceTypeOrder(((getFaceCount / 3) * 2) + 1 : getFaceCount) = 3;
faceTypeOrder = faceTypeOrder(randperm(length(faceTypeOrder)));
faceOrder = 1 : getFaceCount;
faceOrderHappy = faceOrder(randperm(length(faceOrder)));
faceOrderNeutral = faceOrder(randperm(length(faceOrder)));
faceOrderSad = faceOrder(randperm(length(faceOrder)));

changeImageTimer = timer('ExecutionMode', 'fixedRate', 'Period', 6, 'TasksToExecute', getFaceCount + 1); % +1 to account for end block fn call at start of final change image fn call
changeImageTimer.TimerFcn = {@changeImage, handles, faceTypeOrder, faceOrderHappy, faceOrderNeutral, faceOrderSad};
changeImageTimer.StopFcn = {@endBlock, handles};
start(changeImageTimer)

imshow('rating.jpg', 'Parent', handles.rating)

function changeImage(obj, event, handles, faceTypeOrder, faceOrderHappy, faceOrderNeutral, faceOrderSad) %#ok<INUSL>
if getFacesCompleted < getFaceCount
    tic
    
    currentFace = getFacesCompleted + 1;
    randomFaceFolder = '';
    randomFaceNumber = 0;

    switch faceTypeOrder(currentFace)
        case 1
            randomFaceFolder = 'Happy';
            randomFaceNumber = faceOrderHappy(currentFace);
        case 2
            randomFaceFolder = 'Neutral';
            randomFaceNumber = faceOrderNeutral(currentFace);
        case 3
            randomFaceFolder = 'Sad';
            randomFaceNumber = faceOrderSad(currentFace);
    end

    randomFaceFile = ['Faces/', randomFaceFolder, '/', num2str(randomFaceNumber), '.bmp'];
    imshow(randomFaceFile, 'Parent', handles.axes)

    fprintf(getFileID, ['\nFace: ', randomFaceFolder, ', ', num2str(randomFaceNumber), ', ']);

    incrementFacesCompleted
end

function endBlock(obj, event, handles) %#ok<INUSL>
setBlockStarted(false)
incrementBlocksCompleted

clear sound

imshow('', 'Parent', handles.axes)
imshow('', 'Parent', handles.rating)
set(handles.textbox, 'Visible', 'On')

if ~(getBlocksCompleted >= getBlockCount)
    set(handles.textbox, 'String', 'You can take a break now. Press the space bar when you are ready to continue.')
else
    set(handles.textbox, 'String', 'Thank you for participating. The experiment is not ogre. It is never ogre.')
    
    fclose(getFileID);
    
    setInitialBlocksCompleted
    
    pause(5)
    
    setIntroText(handles)
end

function setIntroText(handles)
set(handles.textbox, 'String', sprintf('%s\n%s\n\n%s\n\n%s\n\n\n\n\n\n\n\n\n\n\n\n%s', '    Welcome to the experiment, you will see a series of faces alongside which music will either be played or not.', 'You will be asked to rate the faces in terms of their emotional expression, ranging from  1 (very sad) to 7 (very happy).', '                                   You will be asked to do this for three blocks.', '                                       Please ensure you only make one rating.', '                                    If you are ready to start, press the space bar.'))

function setTrackOrder
order = 1 : getBlockCount;
order = order(randperm(length(order)));
global trackOrder
trackOrder = order;

function r = getTrackOrder
global trackOrder
r = trackOrder;

function r = getBlockCount
r = 3;

function r = getFaceCount
r = 60;

function setBlockStarted(val)
global blockStarted
blockStarted = val;

function r = getBlockStarted
global blockStarted
r = blockStarted;

function setInitialBlocksCompleted
global blocksCompleted
blocksCompleted = 0;

function incrementBlocksCompleted
global blocksCompleted
blocksCompleted = blocksCompleted + 1;

function r = getBlocksCompleted
global blocksCompleted
r = blocksCompleted;

function setInitialFacesCompleted
global facesCompleted
facesCompleted = 0;

function incrementFacesCompleted
global facesCompleted
facesCompleted = facesCompleted + 1;

function r = getFacesCompleted
global facesCompleted
r = facesCompleted;

function setFileID
global fileID
fileID = fopen([num2str(now), '.txt'], 'w');

function r = getFileID
global fileID
r = fileID;
