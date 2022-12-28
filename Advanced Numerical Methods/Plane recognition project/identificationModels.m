classdef (Abstract) identificationModels
    %IDENTIFICATIONMODELS abstract class defining core functiolanity for
    %subclasses
    
    methods(Abstract)
        result = testItself(filename)               % function used for testing accuracy od prediction
        recognized_obj_info = recognize(filename)   % function giving result of the prediction
    end
end

