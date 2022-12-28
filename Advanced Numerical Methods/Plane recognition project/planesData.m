classdef planesData < data
    %PLANESDATA delivers data abut plane from Tables containing data base
    %of all planes registered in USA
    
    properties(Access = private)
        planeInfo           % Table storing Information about individual planes
        aircraftNames       % Table storing Information about aircraft types
    end
    
    methods
        function obj = set.planeInfo(obj, planeInfo)
            if istable(planeInfo)
                obj.planeInfo = planeInfo;
            else
                error('planeInfo is not a table')
            end
        end
        function planeInfo = get.planeInfo (obj)
            planeInfo = obj.planeInfo;
        end
        function obj = set.aircraftNames(obj, aircraftNames)
            if istable(aircraftNames)
                obj.aircraftNames = aircraftNames;
            else
                error('planeInfo is not a table')
            end

        end
        function aircraftNames = get.aircraftNames (obj)
            aircraftNames = obj.aircraftNames;
        end
        function obj = planesData()
            %PLANESDATA Construct an instance of this class
            %   loads tables that contains data from planesData 
            load('planesData', 'planeInfo','aircraftNames');
            obj.aircraftNames = aircraftNames;
            obj.planeInfo = planeInfo;
        end
        function [typeModelSeats, manufacturedYear, ownerName] = findInTable(obj,Nnumber)
            %findInTable finds data in table
            Nnumber = Nnumber(2:length(Nnumber));
            %planeInfo
            index = find(strcmp(Nnumber,obj.planeInfo.N_NUMBER));   % finds row index in planeInfo
            manufacturerCode = char(obj.planeInfo(index,2).MFRMDLCODE); % conversion of data from Table to Cell to Char
            manufacturedYear = obj.planeInfo(index,3).YEARMFR;
            ownerName = char(obj.planeInfo(index,4).NAME);

            %aircraftNames
            index = find(strcmp(manufacturerCode,obj.aircraftNames.CODE));% finds row index in aircraftNames
            type = char(obj.aircraftNames(index,2).MFR);
            model = char(obj.aircraftNames(index,3).MODEL);
            noSeats = obj.aircraftNames(index,4).NO_SEATS;
            
            typeModelSeats = strcat(type," ",model," ",num2str(noSeats), " ",'seats');
        end
    end
    
        methods(Static)
        function createCSV()
            dirinfo = dir('.\Input_Images');    % informations about Input_Images directory
            dirinfo([dirinfo.isdir]) = [];  % remove non-directories
            filenames = {dirinfo.name};  % cell with filenames 
            
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

            % preallocation
            plane(1:length(photoFieldnames)) = struct('filename',strings(50,1),'Nnumber',strings(6,1),'typeModelSeats',strings(50,1),'manufacturedYear',zeros(4,1),'ownerName',strings(50,1),'recognitionScore',strings(20,1));
            
            % Creating structure containg data about each plane
            for i = 1:length(photoFieldnames)
                filenameDir = strcat('.\Input_Images\', char(photoFieldnames(i)));
                plane(i).filename = photoFieldnames(i);
                plane(i).Nnumber = planesRegistrationModel.recognize(filenameDir);
                if plane(i).Nnumber ~= 0 % if registration was found
                    planeData = planesData;
                    [typeModelSeats, manufacturedYear, ownerName] = planeData.findInTable(plane(i).Nnumber);
                    plane(i).typeModelSeats = typeModelSeats;
                    plane(i).manufacturedYear = manufacturedYear;
                    plane(i).ownerName = ownerName;
                    plane(i).recognitionScore = '99%';
                else % registartion not found recognizng from shape
                    recognizedObj = planesShapeModel('trainedShapeModel.mat');
                    [bestGuess, score] = recognizedObj.recognize(filenameDir);
                    plane(i).typeModelSeats = char(bestGuess);
                    plane(i).manufacturedYear = 0;
                    plane(i).ownerName = 0;
                    if max(score) == 1
                        plane(i).recognitionScore = strcat(num2str(99),'%');
                    else
                        plane(i).recognitionScore = strcat(num2str(max(score)*100),'%');
                    end
                end
            end
            writetable(struct2table(plane),'recognizerCSV.csv');
        end
    end
end

