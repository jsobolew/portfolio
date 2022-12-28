classdef PadsRecognition < handle
    %PADSRECOGNITION class analyzes image PCB.jpg
    %   hardcoded for PCB.jpg
    
    properties
        Image                           % stores analyzed image
    end
    properties(Access = private)
        Pads                            % data structure containg info about pads location
        AxesHandle                      % handle to axis displaying image
        legthPerPixel=200/12            % legthPerPixel in um
        hIm
        txtHandle
    end
    properties(Constant)
        referencePad = [273 169]        % location of reference pad
        %legthPerPixel = 200/12          % legthPerPixel in um
    end
    
    methods
        
        function obj = PadsRecognition(filename)
        % constructor reads the image and constructs axes
            obj.Image = imread(filename);
            obj.AxesHandle = axes();
        end
        
        %set/get
        function set.Image(obj, value)
        % value can be both filename or image itself
            if ischar(value) || isstring(value)
                obj.Image = imread(value);
            else
                obj.Image = value;
            end
        end
        
        function analyze(obj)
        %analyze analizes the image and writes the results into it
            
            BW = imbinarize(rgb2gray(obj.Image),0.19);                      % binarazes the imaga, most optimal threshold 0.19
            BW = bwareaopen(BW,300);                                        % deletes small objects
            stats = regionprops('struct',BW,'BoundingBox','Centroid');      % extracts the positions of objects
            stats(1) = [];                                                  % deletes first object wich is board itself
            
            % adding bounding boxes and displaying info on the screen
            hold on;
            for i = 1:length(stats)
                
                % defines the region where the circular pads are located
                if (stats(i).BoundingBox(1) > 130 && stats(i).BoundingBox(1) < 200 &&...
                    stats(i).BoundingBox(2) > 100 && stats(i).BoundingBox(2) < 700)    
                    radious = stats(i).BoundingBox(3)/2;
                    viscircles(stats(i).Centroid,radious,'Color','y','LineWidth',0.1);
                    
                % rest of the picture with rectangular bounding boxes    
                else
                    rectangle('position',stats(i).BoundingBox,'EdgeColor','y')
                end
                
                % displays text label in bounding box
                obj.txtHandle(i) = text(obj.AxesHandle,stats(i).BoundingBox(1)+0.1*stats(i).BoundingBox(3),stats(i).BoundingBox(2)+0.5*stats(i).BoundingBox(4),...
                strcat(num2str(round(stats(i).BoundingBox(3)*obj.legthPerPixel)),'x',num2str(round(stats(i).BoundingBox(4)*obj.legthPerPixel))),...
                'Color','red','FontSize',9);
            end
            title(obj.AxesHandle,'Board pads dimensions in um')
            hold off;
            obj.Pads = stats;
            
            %line to measure distance from main pad
            sz = size(obj.Image);
            myData.Units = 'um';
            myData.MaxValue = hypot(sz(1),sz(2));
            myData.Colormap = hot;
            myData.ScaleFactor = obj.legthPerPixel;
            
            h = images.roi.Line(gca,'Position',[obj.referencePad;400 650],'UserData',myData);
                        
            addlistener(h,'MovingROI',@obj.updateLabel);
            
            %line to measure length per pixel
            myData.Units = 'px';
            myData.MaxValue = hypot(sz(1),sz(2));
            myData.Colormap = hot;
            myData.ScaleFactor = 1;
            
            h = images.roi.Line(gca,'Position',[168.6186  654.9785;168.9756  666.9647],'UserData',myData);
                        
            addlistener(h,'MovingROI',@obj.updateLabel);
            
            
            btn=uicontrol('Parent',gcf,'Style','pushbutton','String','View Data','Units','normalized','Position',[0.45 0.01 0.15 0.05],'Visible','on');%,'ButtonPushedFcn', @(btn,event) obj.updateTextLabels(btn));
            btn.Callback = @obj.updateTextLabels;
        end
        
        function [x,y] = allPadsPosition(obj)
            %allPadsPosition extracts all pads position relative to a specified point
            % return length in mm
            x = zeros(1,length(obj.Pads));
            y = zeros(1,length(obj.Pads));
            for i = 1:length(obj.Pads)
                x(i) = (obj.Pads(i).BoundingBox(1)-obj.referencePad(1))*obj.legthPerPixel/1e3;
                y(i) = (obj.Pads(i).BoundingBox(2)-obj.referencePad(2))*obj.legthPerPixel/1e3;
            end
        end
        
        function perspectiveFix(obj)
            %perspectiveFix fix the perspective so that white shape around
            %processor is square
            fixedPoints = [0 0;size(obj.Image,2) 0;size(obj.Image,2) size(obj.Image,1);0 size(obj.Image,1)];
            movingPoints = [218,116; 1164 129; 1175 1114; 173 1102];
            tform = fitgeotrans(movingPoints,fixedPoints,'projective');
            obj.Image = imwarp(obj.Image,tform,'OutputView',imref2d(size(obj.Image)));
            obj.hIm = imshow(obj.Image, 'Parent', obj.AxesHandle);
        end
    
        function data =  calculateLengthPerPixel(obj)
            % function gets the length of path in pixels and returns length (in um) per pixel
                image=imbinarize(rgb2gray(obj.Image),'adaptive');
                image=bwareaopen(image,500);
                data=regionprops('struct',image,'Centroid','MinorAxisLength');
                data(23).MinorAxisLength
                obj.legthPerPixel=200/data(23).MinorAxisLength;
        end
        
        function updateTextLabels(obj,src,event)
            stats = obj.Pads;
            for i = 1:length(stats)
            set(obj.txtHandle,'String',strcat(num2str(round(stats(i).BoundingBox(3)*obj.legthPerPixel)),'x',num2str(round(stats(i).BoundingBox(4)*obj.legthPerPixel))));
            end
        end
        
        function updateLenthperPixel(obj,src,evt)

            % Get the current line position.
            pos = evt.Source.Position;

            % Determine the length of the line.
            diffPos = diff(pos);
            mag = hypot(diffPos(1),diffPos(2));
            obj.legthPerPixel = 200/mag;

            % Choose a color from the color map based on the length of the line. The
            % line changes color as it gets longer or shorter.
            color = src.UserData.Colormap(ceil(64*(mag/src.UserData.MaxValue)),:);

            % Apply the scale factor to line length to calibrate the measurements.
            mag = mag*src.UserData.ScaleFactor;

            % Update the label.
            set(src,'Label',[num2str(mag,'%30.1f') ' ' src.UserData.Units],'Color',color);
            
            %-----------
            % displays text label in bounding box
            stats =obj.Pads;
%             %delete(obj.txtHandle);
%             for i = 1:length(stats)
% %                 obj.txtHandle = text(obj.AxesHandle,stats(i).BoundingBox(1)+0.1*stats(i).BoundingBox(3),stats(i).BoundingBox(2)+0.5*stats(i).BoundingBox(4),...
% %                 strcat(num2str(round(stats(i).BoundingBox(3)*obj.legthPerPixel)),'x',num2str(round(stats(i).BoundingBox(4)*obj.legthPerPixel))),...
% %                 'Color','red','FontSize',9);
%             set(obj.txtHandle,'String',strcat(num2str(round(stats(i).BoundingBox(3)*obj.legthPerPixel)),'x',num2str(round(stats(i).BoundingBox(4)*obj.legthPerPixel))));

            %end
       
        end  
    end
    
    methods(Static)
        
        function updateLabel(src,evt)

            % Get the current line position.
            pos = evt.Source.Position;

            % Determine the length of the line.
            diffPos = diff(pos);
            mag = hypot(diffPos(1),diffPos(2));

            % Choose a color from the color map based on the length of the line. The
            % line changes color as it gets longer or shorter.
            color = src.UserData.Colormap(ceil(64*(mag/src.UserData.MaxValue)),:);

            % Apply the scale factor to line length to calibrate the measurements.
            mag = mag*src.UserData.ScaleFactor;

            % Update the label.
            set(src,'Label',[num2str(mag,'%30.1f') ' ' src.UserData.Units],'Color',color);

        end
        
    end
end

