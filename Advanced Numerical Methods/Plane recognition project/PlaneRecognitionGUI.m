function varargout = PlaneRecognitionGUI(varargin)
% PLANERECOGNITIONGUI MATLAB code for PlaneRecognitionGUI.fig
%      PLANERECOGNITIONGUI, by itself, creates a new PLANERECOGNITIONGUI or raises the existing
%      singleton*.
%
%      H = PLANERECOGNITIONGUI returns the handle to a new PLANERECOGNITIONGUI or the handle to
%      the existing singleton*.
%
%      PLANERECOGNITIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLANERECOGNITIONGUI.M with the given input arguments.
%
%      PLANERECOGNITIONGUI('Property','Value',...) creates a new PLANERECOGNITIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlaneRecognitionGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlaneRecognitionGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlaneRecognitionGUI

% Last Modified by GUIDE v2.5 17-Nov-2020 23:16:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlaneRecognitionGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PlaneRecognitionGUI_OutputFcn, ...
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


% --- Executes just before PlaneRecognitionGUI is made visible.
function PlaneRecognitionGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlaneRecognitionGUI (see VARARGIN)

% Choose default command line output for PlaneRecognitionGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PlaneRecognitionGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

dirinfo = dir('.\Input_Images');    % informations about Input_Images directory
dirinfo([dirinfo.isdir]) = [];  % remove non-directories
filenames = {dirinfo.name};  % cell with filenames
photoFieldnames = cell(1,7); % preallocation

% finding only valid filenames
for i = 1:length(filenames)
    % finding index of a dots
    k = strfind(filenames{i},'.');
    
    % finding index of last dot in filename
    if length(k) > 1
        k = k(end);
    end
    
    % checking if extension is right
    if strcmp(filenames{i}(k+1:end), 'jpg')
        photoFieldnames{i} = filenames{i};
    end
end
photoFieldnames = photoFieldnames(~cellfun(@isempty, photoFieldnames)); % removes empty cells

%populating popup menu
set(handles.lista_zdjec, 'String', photoFieldnames);

handles.output = hObject;

GuiHandle = ancestor(hObject, 'figure');
handles.PlanesChartHandle = PlanesChart('GuiHandle',GuiHandle);

guidata(hObject,handles)
    
%set(gca, 'units','normalized', 'outerposition',[0.08 0.1 0.85 1]);


% --- Outputs from this function are returned to the command line.
function varargout = PlaneRecognitionGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in rozpoznaj.
function rozpoznaj_Callback(hObject, eventdata, handles)
% hObject    handle to rozpoznaj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.rozpoznaj_wszystkie,'Value') == 1
    %createCSV
    planesData.createCSV();
else
PlanesChart.updateLabels(ancestor(hObject, 'figure'));
end


% --- Executes on selection change in lista_zdjec.
function lista_zdjec_Callback(hObject, eventdata, handles)
% hObject    handle to lista_zdjec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lista_zdjec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lista_zdjec
idx = get(handles.lista_zdjec, 'Value');
items = get(handles.lista_zdjec,'String');
filename = items{idx};

PlanesChartHandle = handles.PlanesChartHandle;
PlanesChartHandle.CurrentlyRecognised = filename;

handles.model.String = 'Model:';
handles.rejestracja.String = 'Rejestracja:';
handles.rok_produkcji.String = 'Rok produkcji:';
handles.wlasciciel.String = 'W³aœciciel:';
handles.pewnosc_predykcji.String = 'Pewnoœæ predykcji:';


% --- Executes during object creation, after setting all properties.
function lista_zdjec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lista_zdjec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rozpoznaj_wszystkie.
function rozpoznaj_wszystkie_Callback(hObject, eventdata, handles)
% hObject    handle to rozpoznaj_wszystkie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rozpoznaj_wszystkie
