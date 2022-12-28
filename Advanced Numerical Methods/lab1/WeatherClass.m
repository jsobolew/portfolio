classdef WeatherClass
    %WEATHERCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataStructure           % same structure as in zadanie 1
        %filename
        urlAddress
    end
    
    methods
        function obj = WeatherClass(varargin)
            %EATHERCLASS Construct an instance of this class
            %   loads data
            if nargin == 0
                filename = 'maindataStructure03122020.mat';
            elseif nargin == 1
                filename = varargin{1};
            elseif nargin == 2
                filename = varargin{1};
                obj.urlAddress = varargin{2};
            else
                error('too many input arguments');
            end
            vars = load(filename, 'Stations');
            obj.dataStructure = vars.Stations;
            if ~obj.CheckIfMainDataStrucreIsValid error('main data structore is invalid!'); end
        end
        
        function dataStructure = get.dataStructure(obj)
            dataStructure = obj.dataStructure;
        end
        
        % functions
        
        function [dataStructure]=GetDataFormVendor(obj, varargin)
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
                dataStructure = webread(obj.urlAddress);
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
        
        
        function dataValid = CheckIfMainDataStrucreIsValid(obj)
        % LOCALCheckIfMainDataStrucreIsValid function returns true if data is valid
        % or false if data is invalid
        %
        % input data is called Stations (insted of dataStructure like in
        % LOCALGetDataFormVendor) to underline that it checks if data structure is
        % valid for weather stations implementation

            dataValid = true;   % data is valid on default
            if iscell(obj.dataStructure) % checking if main data structure is cell
               for i = 1 : length(obj.dataStructure)
                   if ~iscell(obj.dataStructure{i})  % checking if each station is contained in a cell
                       dataValid = false;
                       break;
                   end
                   for j = 1 : length(obj.dataStructure{i})
                       if ~iscell(obj.dataStructure{i}(j))   % checking if each day is contained in a cell
                           dataValid = false;
                           break;
                       elseif ~isstruct(obj.dataStructure{i}{j}) % checking if inside day cell is contained struct
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
        
        
        function PlotData(obj, varargin)
        % LOCALPlotData plots data
        % LOCALPlotData(Station, MeasData, AddPlot)
        %'Station'      Station                                         {String}
        %'MeasData'     indicates wich data is to be ploted             {String}
        %'AddPlot'      indicates weather data on plot shoud be added or
        %               overwtitten true - adds false - overwrites      {Boolean}
        %               set to false on default
        %obj.dataStructure
        varargin{1}
        %Stations = obj.dataStructure;
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
        for i = 1:length(obj.dataStructure)
            if strcmp(obj.dataStructure{i}{1}.id_stacji, varargin{1})
                index = i;
                break;
            elseif strcmp(obj.dataStructure{i}{1}.stacja, varargin{1})
                index = i;
                break;
            end
        end

        if index == 0
            warning('didnt found station')
            return;
        end

        %plotting data
        if length(obj.dataStructure{index}) == 1
            if isfield(obj.dataStructure{index}{1},MeasData)
                data = str2double(obj.dataStructure{index}{1}.(MeasData));
                %bar(data)
                if AddPlot
                    for i = 1 : length(dataStore)
                        % checking if required plot can be added
                        if strcmp(dataStore(1).station, obj.dataStructure{index}{1}.stacja) % we don't want to plot same data twice
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
                        dataStore.station = obj.dataStructure{index}{1}.stacja;
                        dataStore.measData = MeasData;
                    else
                        ds_index = length(dataStore) + 1;
                        dataStore(ds_index).data = data;
                        dataStore(ds_index).station = obj.dataStructure{index}{1}.stacja;
                        dataStore(ds_index).measData = MeasData;
                    end
                    WeatherClass.LOCALPlotForLOCALPlotDatabar(dataStore);
                else
                    dataStore = [];
                    bar(data)
                end
            end
        else
            data = zeros(1,length(obj.dataStructure{index}));
            if isfield(obj.dataStructure{index}{2},MeasData)
                for i = 1 : length(obj.dataStructure{index})
                    if i == 1 && isnan(str2double(obj.dataStructure{index}{i}.(MeasData)))
                        error(strcat(MeasData,' is not plotable value!'));
                    end
                    data(i) = str2double(obj.dataStructure{index}{i}.(MeasData)); 
                end

                % plotting data 
                if AddPlot
                    % checking if required plot can be added
                    for i = 1 : length(dataStore)
                        if strcmp(dataStore(i).station, obj.dataStructure{index}{1}.stacja) % we don't want to plot same data twice
                            warning('station already is bein plotted')
                            WeatherClass.LOCALPlotForLOCALPlotData(dataStore);
                            return;
                        elseif ~strcmp(dataStore(i).measData, MeasData) % we don't want to plot two diffrent types of data
                            warning('You cant display two diffrent parameters on the same plot')
                            return;
                        end
                    end

                    % logic
                    if isempty(dataStore)
                        dataStore.data = data;
                        dataStore.station = obj.dataStructure{index}{1}.stacja;
                        dataStore.measData = MeasData;
                    else
                        ds_index = length(dataStore) + 1;
                        dataStore(ds_index).data = data;
                        dataStore(ds_index).station = obj.dataStructure{index}{1}.stacja;
                        dataStore(ds_index).measData = MeasData;
                    end

                    WeatherClass.LOCALPlotForLOCALPlotData(dataStore);

                else
                    dataStore = [];
                    plot(data)
                    title(strcat(MeasData, " w ",obj.dataStructure{index}{1}.stacja))
                    xlabel('numer dnia')
                    ylabel(MeasData)
                    legend(obj.dataStructure{index}{1}.stacja)
                end
            else
                warning(strcat("field ", MeasData," not found"));
            end
        end
        end
        
        function SaveMainDataStructure(obj,filename)
        % SaveMainDataStructure saves main data structure to a .mat file
            Stations = obj.dataStructure;
            try
                save(filename,'Stations');
            catch
                error("data could not be saved due to error")
            end
        end
    
        
        
    end
    methods(Static)
        function [dataValid] = CheckIfNewDataStrucreIsValid(newData)
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
        
        function dataStructure = addNewData(dataStructure, newData)
        % AddNewData adds new data to data structure
        %NewdataStructure;
        %WeatherClass.CheckIfNewDataStrucreIsValid(newData)
            %if WeatherClass.CheckIfNewDataStrucreIsValid(newData)
                if iscell(dataStructure)
                    if isequaln(dataStructure{1}{end}, newData(1))
                        warning('trying to add already existing data in data structure, aborting adding new data')
                    else
                        for i = 1 : length(dataStructure)
                            dataStructure{i}{end + 1} = newData(i);
                        end
                    end
                end
%             else
%                error('could not add data') 
%             end
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
                    length(dataStore)
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
    end
end

