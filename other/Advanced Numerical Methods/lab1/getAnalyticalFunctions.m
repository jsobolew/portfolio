function [funStruct] = getAnalyticalFunctions()
funStruct.GetDataFormVendor=@LOCALGetDataFormVendor;
funStruct.CheckIfMainDataStrucreIsValid=@LOCALCheckIfMainDataStrucreIsValid;
funStruct.CheckIfNewDataStrucreIsValid=@LOCALCheckIfNewDataStrucreIsValid;
funStruct.AddNewData=@LOCALAddNewData;
funStruct.LoadMainDataStructure=@LOCALLoadMainDataStructure;
funStruct.LoadMainDataStructureStruct=@LOCALLoadMainDataStructureStruct;
funStruct.SaveMainDataStructure=@LOCALSaveMainDataStructure;
funStruct.PlotData=@LOCALPlotData;
funStruct.PlotDataStruct=@LOCALPlotDataStruct;
funStruct.CheckIfMainDataStrucreIsValidStruct=@LOCALCheckIfMainDataStrucreIsValidStruct;
funStruct.SaveMainDataStructureStruct=@LOCALSaveMainDataStructureStruct;
end


function [dataStructure]=LOCALGetDataFormVendor(urlAddress, varargin)
% LOCALGetDataFormVendor Function gest json data from given url
% address and returns data structure of givendata. Use -h option 
% to get console help.

%chek if options passed 
    if(nargin==2)
        if(isstring(varargin{1}) | ischar(varargin{1}))
            if(strcmp(varargin{1},'-h'))
                fprintf('LOCALGetDataFormVendor Function gest json data');
                fprintf('from given url address and returns\n data structure ');
                fprintf('of ulodet data. Use -h option to get console help.\n')
            end
        end
    end
    
%Try to download data    
    try
        dataStructure = webread(urlAddress);
    catch ME
        if (strcmp(ME.identifier,'MATLAB:minrhs'))
            msg = ['Za malo argumentow.'];
            causeException = MException('MATLAB:myCode:argumentNo',msg);
            ME = addCause(ME,causeException);
        end
        if (strcmp(ME.identifier,'MATLAB:webservices:UnknownHost'))
            msg = ['Adres URL jest niepoprawny.'];
            causeException = MException('MATLAB:myCode:wrngURL',msg);
            ME = addCause(ME,causeException);
        end
        rethrow(ME)        
    end
%If data are not organized into structure this was probably not jason
%compatible URL
    if(~isstruct(dataStructure))
        dataStructure=[];
        error('Dane z podanego adresu nie sa danymi komatybilnymi z formatem json.');
    end
end

function [dataValid] = LOCALCheckIfMainDataStrucreIsValid(Stations)
% LOCALCheckIfMainDataStrucreIsValid function returns true if data is valid
% or false if data is invalid
%
% input data is called Stations (insted of dataStructure like in
% LOCALGetDataFormVendor) to underline that it checks if data structure is
% valid for weather stations implementation

    dataValid = true;   % data is valid on default
    if iscell(Stations) % checking if main data structure is cell
       for i = 1 : length(Stations)
           if ~iscell(Stations{i})  % checking if each station is contained in a cell
               dataValid = false;
               break;
           end
           for j = 1 : length(Stations{i})
               if ~iscell(Stations{i}(j))   % checking if each day is contained in a cell
                   dataValid = false;
                   break;
               elseif ~isstruct(Stations{i}{j}) % checking if inside day cell is contained struct
                   dataValid = false;
                   break;
               end
            end
        end
    end
    
    % log error if data is invalid
    if dataValid == false
       error('invalid main data structure format'); 
    end
end

function dataValid = LOCALCheckIfMainDataStrucreIsValidStruct(MainStruct)
% LOCALCheckIfMainDataStrucreIsValidStruct function returns true if data is valid
% or false if data is invalid
    fields = fieldnames(MainStruct);
    if ~isstruct(MainStruct)
        dataValid = false;
    else
        for i = 1:length(fields)
            if ~isstruct(MainStruct.(fields(i)))
                dataValid = false;
                break;
            end
        end
    end
    if dataValid == false
       error('invalid main data structure format'); 
    end
end

function [dataValid] = LOCALCheckIfNewDataStrucreIsValid(newData)
% LOCALCheckIfNewDataStrucreIsValid checks if data to be added is valid
    dataValid = true;
    if ~isstruct(newData)
        dataValid = false;
    end
    if dataValid == false
       error('invalid new data format'); 
    end
    
    fields = ["id_stacji","stacja","data_pomiaru","godzina_pomiaru","temperatura","predkosc_wiatru","kierunek_wiatru","wilgotnosc_wzgledna","suma_opadu","cisnienie"];
    fn = fieldnames(newData);
    if length(fields) == length(fn)
        for i = 1 : length(fields)
            if fields(i) ~= fn(i)
               error('new data is not compatible with current data')
            end
        end
    else
       error('new data is not compatible with current data');
    end
end

function [dataStructure] = LOCALAddNewData(newData, dataStructure)
% LOCALAddNewData adds new data to data structure
    if LOCALCheckIfNewDataStrucreIsValid(newData)
        if iscell(dataStructure)
            if isequaln(dataStructure{1}{end}, newData(1))
                warning('trying to add already existing data in data structure, aborting adding new data')
            else
                for i = 1 : length(dataStructure)
                    dataStructure{i}{end + 1} = newData(i); 
                end
            end
        elseif isstruct(dataStructure)
            fields = fieldnames(dataStructure);
            if isequaln(dataStructure(end).station12295, newData(1))
                warning('trying to add already existing data in data structure, aborting adding new data')
            else
                lastIndex = length(dataStructure);
                for i = 1 : length(fields)
                    dataStructure(lastIndex+1).(fields{i}) = newData(i); 
                end
            end
        end
    else
       error('could not add data') 
    end
end

function [Stations] = LOCALLoadMainDataStructure (filename)
% LOCALLoadMainDataStructure loads main data structure from a .mat file

    try
        load(filename, 'Stations');
    catch
       error("could load data due to error");
    end
end

function [MainStruct] = LOCALLoadMainDataStructureStruct (filename)
% LOCALLoadMainDataStructureStruct loads main data structure from a .mat file

    try
        load(filename, 'MainStruct');
    catch
       error("could load data due to error");
    end
end

function LOCALSaveMainDataStructure(Stations,filename)
% LOCALSaveMainDataStructure saves main data structure to a .mat file
    try
        save(filename,'Stations');
    catch
        error("data could not be saved due to error")
    end
end

function LOCALSaveMainDataStructureStruct(MainStruct,filename)
% LOCALSaveMainDataStructure saves main data structure to a .mat file
    try
        save(filename,'MainStruct');
    catch
        error("data could not be saved due to error")
    end
end


function LOCALPlotData(Stations, varargin)
% LOCALPlotData plots data
% LOCALPlotData(Station, MeasData, AddPlot)
%'Station'      Station                                         {String}
%'MeasData'     indicates wich data is to be ploted             {String}
%'AddPlot'      indicates weather data on plot shoud be added or
%               overwtitten true - adds false - overwrites      {Boolean}
%               set to false on default
    persistent dataStore;
    AddPlot = false;
    if nargin == 1 || nargin == 2
        error('not enough input arguments')
    elseif nargin == 3
        MeasData = varargin{2};
    elseif nargin == 4
        MeasData = varargin{2};
        if varargin{3} == true || varargin{3} == false
            AddPlot = varargin{3};
        else
            warning('Addplot optin is not boolean, setting it to false');
        end
    elseif nargin > 5
       error('too many input arguments') 
    end
    
    % finding index of a station
    index=0;
    for i = 1:length(Stations)
        if strcmp(Stations{i}{1}.id_stacji, varargin{1})
            index = i;
            break;
        elseif strcmp(Stations{i}{1}.stacja, varargin{1})
            index = i;
            break;
        end
    end
    
    if index == 0
        warning('didnt found station')
        return;
    end
    
    %plotting data
    if length(Stations{index}) == 1
        if isfield(Stations{index}{1},MeasData)
            data = str2double(Stations{index}{1}.(MeasData));
            %bar(data)
            if AddPlot
                for i = 1 : length(dataStore)
                    % checking if required plot can be added
                    if strcmp(dataStore(1).station, Stations{index}{1}.stacja) % we don't want to plot same data twice
                            warning('station already is bein plotted')
                            bar(dataStore);
                            return;
                        elseif ~strcmp(dataStore(1).measData, MeasData) % we don't want to plot two diffrent types of data
                            warning('You cant display two diffrent parameters on the same plot')
                            return;
                    end
                end
                
                % logic
                if isempty(dataStore)
                    dataStore.data = data;
                    dataStore.station = Stations{index}{1}.stacja;
                    dataStore.measData = MeasData;
                else
                    ds_index = length(dataStore) + 1;
                    dataStore(ds_index).data = data;
                    dataStore(ds_index).station = Stations{index}{1}.stacja;
                    dataStore(ds_index).measData = MeasData;
                end
                LOCALPlotForLOCALPlotDatabar(dataStore);
            else
                dataStore = [];
                bar(data)
            end
        end
    else
        data = zeros(1,length(Stations{index}));
        if isfield(Stations{index}{1},MeasData)
            for i = 1 : length(Stations{index})
                if i == 1 && isnan(str2double(Stations{index}{i}.(MeasData)))
                    error(strcat(MeasData,' is not plotable value!'));
                end
                data(i) = str2double(Stations{index}{i}.(MeasData)); 
            end

            % plotting data 
            if AddPlot
                % checking if required plot can be added
                for i = 1 : length(dataStore)
                    if strcmp(dataStore(i).station, Stations{index}{1}.stacja) % we don't want to plot same data twice
                        warning('station already is bein plotted')
                        LOCALPlotForLOCALPlotData(dataStore);
                        return;
                    elseif ~strcmp(dataStore(i).measData, MeasData) % we don't want to plot two diffrent types of data
                        warning('You cant display two diffrent parameters on the same plot')
                        return;
                    end
                end

                % logic
                if isempty(dataStore)
                    dataStore.data = data;
                    dataStore.station = Stations{index}{1}.stacja;
                    dataStore.measData = MeasData;
                else
                    ds_index = length(dataStore) + 1;
                    dataStore(ds_index).data = data;
                    dataStore(ds_index).station = Stations{index}{1}.stacja;
                    dataStore(ds_index).measData = MeasData;
                end

                LOCALPlotForLOCALPlotData(dataStore);

            else
                dataStore = [];
                plot(data)
                title(strcat(MeasData, " w ",Stations{index}{1}.stacja))
                xlabel('numer dnia')
                ylabel(MeasData)
                legend(Stations{index}{1}.stacja)
            end
        else
            warning(strcat("field ", MeasData," not found"));
        end
    end
end

function LOCALPlotDataStruct(MainStruct, varargin)
% LOCALPlotData plots data
% LOCALPlotData(Station, MeasData, AddPlot)
%'Station'      Station                                         {String}
%'MeasData'     indicates wich data is to be ploted             {String}
%'AddPlot'      indicates weather data on plot shoud be added or
%               overwtitten true - adds false - overwrites      {Boolean}
%               set to false on default

    persistent dataStore;
    AddPlot = false;
    if nargin == 1 || nargin == 2
        error('not enough input arguments')
    elseif nargin == 3
        MeasData = varargin{2};
    elseif nargin == 4
        MeasData = varargin{2};
        if varargin{3} == true || varargin{3} == false
            AddPlot = varargin{3};
        else
            warning('Addplot optin is not boolean, setting it to false');
        end
    elseif nargin > 5
       error('too many input arguments') 
    end
    
    % finding index of a station
    index=0;
    fields = fieldnames(MainStruct);
    for i = 1:length(fields)
        if strcmp(MainStruct(1).(fields{i}).stacja, varargin{1})
            index = i;
            break;
        elseif strcmp(MainStruct(1).(fields{i}).id_stacji, varargin{1})
            index = i;
            break;
        end
    end
    
    if index == 0
        warning('didnt found station')
        return;
    end
    %plotting data
    data = zeros(1,length(MainStruct));
    if isfield(MainStruct(1).(fields{index}),MeasData)        
            fields = fieldnames(MainStruct);
            if isfield(MainStruct(1).(fields{index}),MeasData)
                if isnan(str2double(MainStruct(1).(fields{index}).(MeasData)))
                    error(strcat(MeasData,' is not plotable value!'));
                end
                for i = 1 : length(MainStruct)
                    data(i) = str2double(MainStruct(i).(fields{index}).(MeasData)); 
                end
            end
        
        
        % plotting data 
        if AddPlot
            % checking if required plot can be added
            for i = 1 : length(dataStore)
                if strcmp(dataStore(i).station, MainStruct(1).(fields{index}).stacja) % we don't want to plot same data twice
                    warning('station already is bein plotted')
                    LOCALPlotForLOCALPlotData(dataStore);
                    return;
                elseif ~strcmp(dataStore(i).measData, MeasData) % we don't want to plot two diffrent types of data
                    warning('You cant display two diffrent parameters on the same plot')
                    return;
                end
            end
            
            % logic
            if isempty(dataStore)
                dataStore.data = data;
                dataStore.station = MainStruct(1).(fields{index}).stacja;
                dataStore.measData = MeasData;
            else
                ds_index = length(dataStore) + 1;
                dataStore(ds_index).data = data;
                dataStore(ds_index).station = MainStruct(1).(fields{index}).stacja;
                dataStore(ds_index).measData = MeasData;
            end

            LOCALPlotForLOCALPlotData(dataStore);

        else
            dataStore = [];
            plot(data)
            title(strcat(MeasData, " w ",MainStruct(1).(fields{index}).stacja))
            xlabel('numer dnia')
            ylabel(MeasData)
            legend(MainStruct(1).(fields{index}).stacja)
        end
    else
        warning(strcat("field ", MeasData," not found"));
    end
end

function LOCALPlotForLOCALPlotData(dataStore)
            close all;
            if length(dataStore) >= 2
                hold on;
            end
            for i = 1 : length(dataStore)
                plot(dataStore(i).data,'DisplayName',dataStore(i).station)
            end
            hold off;
            if length(dataStore)== 1
                title(strcat(dataStore.measData, " w ",dataStore.station))
            else
                title(dataStore(1).measData)
            end
            legend show;
            xlabel('numer dnia')
            ylabel(dataStore(1).measData)
end

function LOCALPlotForLOCALPlotDatabar(dataStore)
            close all;
            if length(dataStore) >= 2
                hold on;
            end
            for i = 1 : length(dataStore)
                %bar(dataStore(i).data)%,dataStore(i).station)
                Y(i) = dataStore(i).data;
            end
            hold off;
            if length(dataStore)== 1
                title(strcat(dataStore.measData, " w ",dataStore.station))
            else
                title(dataStore(1).measData)
            end
            bar(Y)
end