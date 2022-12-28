classdef data
    %DATA abstract class defining core functionality for finding data in
    %database and how should communication between chart look like.
    
    methods(Abstract)
        data = findInTable(identifier)  % search in Table for data      
    end
    methods(Static = true, Abstract)
        createCSV()                     % creates CSV file containg input data
    end
end