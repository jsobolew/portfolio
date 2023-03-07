classdef planesShapeModel < identificationModels
    properties(Access = private)
        bag                         % bag of features
        trainedModel                % trained recognition model
    end
    methods
        function obj = set.bag(obj, bag)
            if isequal('bagOfFeatures',class(bag))
                obj.bag = bag;
            else
                error('wrog bag of feature format')
            end
        end
        function bag = get.bag (obj)
            bag = obj.bag;
        end
        function obj = set.trainedModel(obj, trainedModel)
            if isstruct(trainedModel)
                obj.trainedModel = trainedModel;
            else
                error('wrong trainedModel format')
            end
        end
        function trainedModel = get.trainedModel (obj)
            trainedModel = obj.trainedModel;
        end
        function obj = planesShapeModel(model)
            load(model,'bag','trainedModel');
            obj.bag = bag;
            obj.trainedModel = trainedModel;
        end
        function [bestGuess , score] = recognize(obj,filename)
            img = imread(filename);
            
            % finding image features
            imagefeatures = double(encode(obj.bag, img));
            
            % Find closest matches for each feature
            [bestGuess, score] = predict(obj.trainedModel.ClassificationTree,imagefeatures);
        end
        function testItself()% option for further development
            %test logic
        end
    end
end