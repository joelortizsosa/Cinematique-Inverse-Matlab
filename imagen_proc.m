function varargout = imagen_proc(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imagen_proc_OpeningFcn, ...
                   'gui_OutputFcn',  @imagen_proc_OutputFcn, ...
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


% --- Executes just before imagen_proc is made visible.
function imagen_proc_OpeningFcn(hObject, eventdata, handles, varargin)
global bandera ref_img ref_img_gray ref_pts ref_features ref_validPts timer1 envio id coordenadaX coordenadaY rango fin velocidad mostrar calibracion tcp dibujar;
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imagen_proc (see VARARGIN)


envio=0; 
coordenadaX=0;
coordenadaY=0;
rango=0;
fin=0;
velocidad=5;
mostrar = '0000';
calibracion=0;
bandera=0;

timer1 = timer('ExecutionMode','fixedRate','Period', 0.01,'TimerFcn', {@Update,handles});
tcp = tcpip('127.0.0.1',50007); % CONFIGURACION TCP IP


%configuracion de los ejes tridimensionales
set(handles.slider4,'value',0.1) % eje x
set(handles.slider5,'value',36) % eje y
set(handles.slider6,'value',7) % eje z


handles.output = hObject;
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = imagen_proc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structur
handles.output = hObject;
varargout{1} = handles.output;


% --- Executes on button press in boton1.
function boton1_Callback(hObject, eventdata, handles)
global bandera  ;
% hObject    handle to boton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% choose which webcam (winvideo-1) and which  mode (YUY2_176x144)

start(handles.timer)
bandera=1;



% --- Executes on button press in stop_boton.
function stop_boton_Callback(hObject, eventdata, handles)
global bandera timer1 id fin tcp;
% hObject    handle to stop_boton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if fin==0
        stop(handles.timer);

        if strcmp(get(handles.connectButton,'String'),'Disconnect')
        stop(timer1);
        end

            if strcmp(get(handles.connectButton,'String'),'Disconnect')
            fclose(tcp);         
            set(handles.connectButton, 'String','Connect')
            end


        bandera=0;
end

function Update(obj,event,handles)
global serConn K envio id velocidad mostrar mostrar_X tcp;

if get(handles.checkbox1,'value')==0
 slider_value1 = get(handles.slider4,'value');
 slider_value2 = get(handles.slider5,'value');
 slider_value3 = get(handles.slider6,'value');
 
 if slider_value3 < 6
     if slider_value1>0  % posicion positiva del punto en X
         if (slider_value1<=6)
             slider_value1=6;
             set(handles.slider4,'value',6) % eje x
             set(handles.slider4,'Max',36)
             set(handles.slider4,'Min',6)
         end
     end
     if slider_value1<0 %posicion negativa del punto en X
         if (slider_value1 >= -6)
             slider_value1=-6;
             set(handles.slider4,'value',-6) % eje x
             set(handles.slider4,'Max',-6)
             set(handles.slider4,'Min',-36)             
         end         
     end
 else
             set(handles.slider4,'Max',36)
             set(handles.slider4,'Min',-36)
 end
 set (handles.operacion_alto, 'string',num2str(slider_value1)) ; %x
 set (handles.edit27, 'string',num2str(slider_value2)) ;  %y
 set (handles.edit28, 'string',num2str(slider_value3)) ;  %z
 [l_shoulder_y,l_shoulder_x,l_elbow_y] = robot3_inv(slider_value1,slider_value2,slider_value3);
 motor_l_shoulder_y=Cadena_4char(l_shoulder_y);
 motor_l_shoulder_x=Cadena_4char(l_shoulder_x);
 motor_l_elbow_y=Cadena_4char(l_elbow_y);
end
if strcmp(get(handles.connectButton,'String'),'Disconnect')
    
    if get(handles.checkbox1,'value')==0

                           fprintf(tcp,'%s',motor_l_shoulder_y)
                           fprintf(tcp,'%s',',')
                           fprintf(tcp,'%s',motor_l_shoulder_x)  
                           fprintf(tcp,'%s',',-090,')% para el brazo izquierdo -090
                           fprintf(tcp,'%s',motor_l_elbow_y)
                           fwrite(tcp,10,'uchar');
                           
    end                       

            
end    








% --- Executes on button press in connectButton.
function connectButton_Callback(hObject, eventdata, handles)
global serConn timer1 id c tcp;
% hObject    handle to connectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'String'),'Connect') % currently disconnected

        try
           fopen(tcp);         
           start(timer1)
           set(hObject, 'String','Disconnect')
        catch e
            errordlg(e.message);
        end
else
    
    set(hObject, 'String','Connect')
    fclose(tcp);
    stop(timer1)

end



guidata(hObject, handles);





% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
global serConn K envio id velocidad calibracion tcp;
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

     if get(handles.checkbox1,'value')==1
        z=[6 7 8 9 10 11 12 13 14 15 15 15 15 15 15 14 13 12 11 10  9  8  7  6  5  4  3  2 2 2 2 2 2 3 4 5 6];
        y=[1 1 1 1 1   1  2  3  4  5  6  7  8  9 10 11 12 13 14 14 14 14 14 14 13 12 11 10 9 8 7 6 5 4 3 2 1];
        x=18;

                 for i=1:37
                 [l_shoulder_y,l_shoulder_x,l_elbow_y] = robot3_inv(x,y(i),z(i));
                 motor_l_shoulder_y=Cadena_4char(l_shoulder_y);
                 motor_l_shoulder_x=Cadena_4char(l_shoulder_x);
                 motor_l_elbow_y=Cadena_4char(l_elbow_y);
                                           fprintf(tcp,'%s',motor_l_shoulder_y)
                                           fprintf(tcp,'%s',',')
                                           fprintf(tcp,'%s',motor_l_shoulder_x)  
                                           fprintf(tcp,'%s',',-090,')
                                           fprintf(tcp,'%s',motor_l_elbow_y)
                                           fwrite(tcp,10,'uchar');

                pause(0.06); % velocidad aceptable para no mostrar movimineots bruscos.
                 end
     end



function operacion_alto_Callback(hObject, eventdata, handles)
% hObject    handle to operacion_alto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of operacion_alto as text
%        str2double(get(hObject,'String')) returns contents of operacion_alto as a double


% --- Executes during object creation, after setting all properties.
function operacion_alto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to operacion_alto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function operacion_alto_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to operacion_alto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function connectButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to connectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% retroceder hasta aqui
