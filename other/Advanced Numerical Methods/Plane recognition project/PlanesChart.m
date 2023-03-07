classdef PlanesChart < matlab.graphics.chartcontainer.ChartContainer
    %PLANESCHART Class that "puts pieces together"
    %   Uses right model to predict plane type
    %   if it's possible to read registration number, displays additional
    %   information
    properties
        CurrentlyRecognised             % indicates wich plane is currently selected
        GuiHandle                       % handle to GUI
        ax                              % handle to Axis
    end
    
    methods
        function set.GuiHandle(obj, GuiHandle)
            obj.GuiHandle = GuiHandle;
        end
        function GuiHandle = get.GuiHandle(obj)
            GuiHandle = obj.GuiHandle;
        end
        function set.CurrentlyRecognised(obj, CurrentlyRecognised)
            obj.CurrentlyRecognised = CurrentlyRecognised;
        end
        function CurrentlyRecognised = get.CurrentlyRecognised(obj)
            CurrentlyRecognised = obj.CurrentlyRecognised;
        end
        
        function delete(obj)
           delete(obj.GuiHandle)
        end
    end
    
    methods(Access = protected)        
        function setup(obj)
            
            % gets wich file is seleted to be recognized
            handles = guidata(obj.GuiHandle);
            idx = get(handles.lista_zdjec, 'Value');
            items = get(handles.lista_zdjec,'String');
            filename = items{idx};
            fileDir = strcat('.\Input_Images\', filename);
            obj.ax = getAxes(obj);
            imshow(fileDir, 'Parent', obj.ax);
        end
        function update(obj) 
            % gets wich picture is selected and displays it
            handles = guidata(obj.GuiHandle);
            idx = get(handles.lista_zdjec, 'Value');
            items = get(handles.lista_zdjec,'String');
            filename = items{idx};
            fileDir = strcat('.\Input_Images\', filename);
            imshow(fileDir, 'Parent', obj.ax);
            
            %PlanesChart.updateLabels(obj.GuiHandle,fileDir);       
            % use this if you want to recognize plane on selection
        end
    end
    
    methods(Static)
        function updateLabels (GuiHandle)
            %invoked by pushing recognize button(Rozpoznaj!)
            %   2 cases possible:
            %   recognized registration => find data about plane and
            %   display it
            %   not recognized registration => shape registration
            
            % finding selected file directory
            handles = guidata(GuiHandle);
            idx = get(handles.lista_zdjec, 'Value');
            items = get(handles.lista_zdjec,'String');
            filename = items{idx};
            fileDir = strcat('.\Input_Images\', filename);
 
            % RECOGNITION LOGIC
            Nnumber = planesRegistrationModel.recognize(fileDir);
            if Nnumber ~= 0 % if registration was found
                planeData = planesData;
                [typeModelSeats, manufacturedYear, ownerName] = planeData.findInTable(Nnumber);
                if typeModelSeats == "   seats"
                    handles.model.String = strcat('Model:', " ", 'nie znaleziono w bazie danych');
                else
                    handles.model.String = strcat('Model:', " ", typeModelSeats);
                end
                handles.rejestracja.String = strcat('Rejestracja:', " ", Nnumber);
                if isempty(manufacturedYear)
                    handles.rok_produkcji.String = strcat('Rok produkcji:', " ", 'nie znaleziono roku produkcji');
                else
                    handles.rok_produkcji.String = strcat('Rok produkcji:', " ", num2str(manufacturedYear));
                end
                if isempty(ownerName)
                    handles.wlasciciel.String = strcat('W³aœciciel:', " ", 'nie znaleziono w³aœciciela');
                else
                    handles.wlasciciel.String = strcat('W³aœciciel:', " ", ownerName);
                end
                handles.pewnosc_predykcji.String = 'Pewnoœæ predykcji: 99%';
            else    % registartion not found -> recognizng from shape
                recognizedObj = planesShapeModel('trainedShapeModel.mat');
                [bestGuess, score] = recognizedObj.recognize(fileDir);
                if score == 0   % if prediction is inaccurate it's not displayed
                    handles.model.String = 'Nie uda³o siê rozpoznaæ!';
                else
                    handles.model.String = strcat('Model:', " ", char(bestGuess));
                    handles.rejestracja.String = 'Rejestracja: Nie uda³o siê odczytaæ rejestracji!';
                    handles.rok_produkcji.String = 'Rok produkcji: ---';
                    handles.wlasciciel.String = 'W³aœciciel: ---';
                    if max(score) == 1
                        handles.pewnosc_predykcji.String = strcat('Pewnoœæ predykcji:', " ", num2str(99), '%');
                    else
                        handles.pewnosc_predykcji.String = strcat('Pewnoœæ predykcji:', " ", num2str(max(score)*100), '%');
                    end
                end
            end
        end  
    end
end

