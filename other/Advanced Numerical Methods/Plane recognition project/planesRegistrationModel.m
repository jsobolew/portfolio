classdef planesRegistrationModel < identificationModels
    %PLANESREGISTRATIONMODEL Static class containing methods used to
    %recognize registration from a photo
    %   each method takas image filename as an input and returns
    %   recognized registration as na output
    
    methods(Static)
        function recognizedRegistration = recognize (filename)
            %RECOGNIZE specifies wich function is used for recognizing
            recognizedRegistration = planesRegistrationModel.modelMSER(filename);
        end
        function recognizedRegistration = modelMSER(filename)
            %MODELMSER recognizes registration from a picture
            %   takes filename as an input return recognized registration
            try
            colorImage = imread(filename);
            I = rgb2gray(colorImage);
            % Detect MSER regions.
            [mserRegions, mserConnComp] = detectMSERFeatures(I, ... 
                'RegionAreaRange',[200 8000],'ThresholdDelta',4);

            % Use regionprops to measure MSER properties
            mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
                'Solidity', 'Extent', 'Euler', 'Image');

            % Compute the aspect ratio using bounding box data.
            bbox = vertcat(mserStats.BoundingBox);
            w = bbox(:,3);
            h = bbox(:,4);
            aspectRatio = w./h;

            % Threshold the data to determine which regions to remove. These thresholds
            filterIdx = aspectRatio' > 3; 
            filterIdx = filterIdx | [mserStats.Eccentricity] > .995 ;
            filterIdx = filterIdx | [mserStats.Solidity] < .3;
            filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
            filterIdx = filterIdx | [mserStats.EulerNumber] < -4;

            % Remove regions
            mserStats(filterIdx) = [];

            % removeing areas based on stroke width
            % Get a binary image of the a region, and pad it to avoid boundary effects
            % during the stroke width computation.
            regionImage = mserStats(6).Image;
            regionImage = padarray(regionImage, [1 1]);

            % Compute the stroke width image.
            distanceImage = bwdist(~regionImage); 
            skeletonImage = bwmorph(regionImage, 'thin', inf);

            % Compute the stroke width variation metric 
            strokeWidthValues = distanceImage(skeletonImage);   
            strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);
            % Threshold the stroke width variation metric
            strokeWidthThreshold = 0.4;
            strokeWidthFilterIdx = strokeWidthMetric > strokeWidthThreshold;
            % Process the remaining regions
            for j = 1:numel(mserStats)

                regionImage = mserStats(j).Image;
                regionImage = padarray(regionImage, [1 1], 0);

                distanceImage = bwdist(~regionImage);
                skeletonImage = bwmorph(regionImage, 'thin', inf);

                strokeWidthValues = distanceImage(skeletonImage);

                strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);

                strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;

            end

            % Remove regions based on the stroke width variation
            mserStats(strokeWidthFilterIdx) = [];

            % Get bounding boxes for all the regions
            bboxes = vertcat(mserStats.BoundingBox);

            % Convert from the [x y width height] bounding box format to the [xmin ymin
            % xmax ymax] format for convenience.
            xmin = bboxes(:,1);
            ymin = bboxes(:,2);
            xmax = xmin + bboxes(:,3) - 1;
            ymax = ymin + bboxes(:,4) - 1;

            % Expand the bounding boxes by a small amount.
            expansionAmount = 0.02;
            xmin = (1-expansionAmount) * xmin;
            ymin = (1-expansionAmount) * ymin;
            xmax = (1+expansionAmount) * xmax;
            ymax = (1+expansionAmount) * ymax;

            % Clip the bounding boxes to be within the image bounds
            xmin = max(xmin, 1);
            ymin = max(ymin, 1);
            xmax = min(xmax, size(I,2));
            ymax = min(ymax, size(I,1));

            % expanded bounding boxes
            expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];

            % Compute the overlap ratio
            overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);

            % Set the overlap ratio between a bounding box and itself to zero to
            % simplify the graph representation.
            n = size(overlapRatio,1); 
            overlapRatio(1:n+1:n^2) = 0;

            % Create the graph
            g = graph(overlapRatio);

            % Find the connected text regions within the graph
            componentIndices = conncomp(g);
            % Merge the boxes based on the minimum and maximum dimensions.
            xmin = accumarray(componentIndices', xmin, [], @min);
            ymin = accumarray(componentIndices', ymin, [], @min);
            xmax = accumarray(componentIndices', xmax, [], @max);
            ymax = accumarray(componentIndices', ymax, [], @max);

            % Compose the merged bounding boxes using the [x y width height] format.
            textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
            % Remove bounding boxes that only contain one text region
            numRegionsInGroup = histcounts(componentIndices);
            textBBoxes(numRegionsInGroup == 1, :) = [];

            % recognition
            ocrtxt = ocr(I, textBBoxes);
            recognizedRegistration = planesRegistrationModel.findRegistrationInString([ocrtxt.Text]);
            catch
                recognizedRegistration = 0;
                disp('didnt found registration, assigning 0 to Nnumber')
            end
        end
        function Nnumber = findRegistrationInString(inputString)
        %PLANESREGISTRATIONMODEL returns N number
        %   finds N number in a string containg 'noise' data and
        %   registation number for eg.
        %   inputString it's a string with registartion and noise
        %   inputString = '$0000 '* N802AW ml XYS 6. L’ G '
        %   on an outpu Nnumber = 'N802AW'
        
        %finding place where registration starts
        k = strfind(inputString,'N');
        
        % checking if there is one 'N' and input string is long
        % enough to contain it
        if (length(k) == 1 && length(inputString) >= k+3)
            Nnumber = inputString(k:k+5);
        else
            Nnumber = 0;    % Nnumber is equall to 0 when is not found in the noise
        end
        
        % condition for minimal registration lenght
        if length(Nnumber) < 4
            Nnumber = 0;
        end
        end
        function testItself % option for further development
            %test logic
        end
    end
end

