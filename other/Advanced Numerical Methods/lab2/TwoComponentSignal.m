classdef TwoComponentSignal < matlab.graphics.chartcontainer.ChartContainer & matlab.mixin.SetGet
    %TWOCOMPONENT Class display signal with two signal components
    %   class is used to show signal and its high frequency zoomed
    %   component in a additional axis visible on a plot
    
    properties
        formula(1,1)function_handle = @(x) x                    % y = x on default
        xlimits(1,2){mustBeNumeric} = [0,1]                     % 2 elemet vector [x0, xend]
        displayRect (1,1)logical = true                         % if true displays rectangle with high frequency component
        displayFormula (1,1) logical = true                     % if true displays formula in a textbox
        rectLimitsUserInput(1,4){mustBeNumeric} = [0,0,0,0]     % 4 element vector  [x0, y0, xend, yend]
    end
    properties(Access = private)
        figureHandle;                                           % handle to figure
        mainAxesHandle;                                         % handle to main Axis inside figure
        axisHandle;                                             % handle to axis showing zoomed function
        rectHandle;                                             % hanlde to rectangle indicateing zoomed function
        textBoxHandle;                                          % handle to textBox showing function formula
        Line;                                                   % handle to Line in main axes
        insertedLine;                                           % handle to Line in inserted axes
    end
    properties(Dependent)
        Xdata(1,1000){mustBeNumeric};                           % x data vector
        YData(1,1000){mustBeNumeric};                           % y data vector
        Ylimits(1,2){mustBeNumeric};                            % y limits on main Axis [Ystart, Ystop]
        fotmulaString{String};                                  % function formula in String
        rectLimits (1,4){mustBeNumeric}                         % 4 element vector [Xstart,Ystart,width,height]
    end
    
    methods
        
        %getters
        function fotmulaString = get.fotmulaString(obj)
            str = func2str(obj.formula);
            str = strcat('y = ',str(1,5:end));
            fotmulaString = str;
        end
        function Xdata = get.Xdata(obj)
            Xdata = linspace(obj.xlimits(1),obj.xlimits(2),1000);
        end
        function YData = get.YData(obj)
            YData = obj.formula(obj.Xdata);
        end
        function Ylimits = get.Ylimits(obj)
            Y1 = min(obj.YData);
            Y2 = min(obj.YData) + (max(obj.YData) - min(obj.YData))*2;
            Ylimits = [Y1,Y2];
        end
        function rectLimits = get.rectLimits(obj)
            if isequal(obj.rectLimitsUserInput,[0,0,0,0])   %calculating default option
                Xstart = obj.xlimits(1);
                Ystart = min(obj.YData(1:100));
                width = (obj.xlimits(2)-obj.xlimits(1))/10;
                height = max(obj.YData(1:100)) - Ystart;
                rectLimits = [Xstart,Ystart,width,height];
            else                                            % calculating user input option
                Xstart = obj.rectLimitsUserInput(1);
                Ystart = obj.rectLimitsUserInput(2);
                width = obj.rectLimitsUserInput(3)-obj.rectLimitsUserInput(1);
                height = obj.rectLimitsUserInput(4)-obj.rectLimitsUserInput(2);
                rectLimits = [Xstart,Ystart,width,height];
            end
        end
        
    end
    methods(Access = protected)
        function setup(obj)
            obj.figureHandle = gcf;
            delete(findall(obj.figureHandle,'type','annotation'))
            % main Axes
            obj.mainAxesHandle = getAxes(obj);
            obj.Line = plot(obj.mainAxesHandle, NaN, NaN);
            xlabel(obj.mainAxesHandle,'Time[s]');
            ylabel(obj.mainAxesHandle,'SignalValue')
            grid(obj.mainAxesHandle, 'on');
            % Inserted axis
            obj.axisHandle = axes('Position',[0.5 0.55 0.4 0.37],'Box','on');
            obj.insertedLine = plot(obj.axisHandle, NaN, NaN);
            title(obj.axisHandle,'High frequency component');
            % rectangle
            obj.rectHandle = rectangle(obj.mainAxesHandle,'Position',[obj.rectLimits]);
            % textBox
            obj.textBoxHandle = annotation(obj.figureHandle,'textbox',[.15 .3 .4 .5],'FitBoxToText','on');
        end
        
        function update(obj)
            % main Axes
            obj.Line.XData = obj.Xdata;
            obj.Line.YData = obj.YData;
            xlim(obj.mainAxesHandle,obj.xlimits)
            ylim(obj.mainAxesHandle,obj.Ylimits)
            % Inserted axis
            if obj.displayRect
                set(obj.axisHandle,'Visible','on');
                set(obj.axisHandle.Children,'Visible','on');
                %insertedLine
                obj.insertedLine.XData = obj.Xdata;
                obj.insertedLine.YData = obj.YData;
                xlim(obj.axisHandle,[obj.rectLimits(1),obj.rectLimits(1)+obj.rectLimits(3)])
                ylim(obj.axisHandle,[obj.rectLimits(2),obj.rectLimits(2)+obj.rectLimits(4)])
            else
                set(obj.axisHandle,'Visible','off');
                set(obj.axisHandle.Children,'Visible','off');
            end
            % Rectangle
            obj.rectHandle.Position = [obj.rectLimits];
            % textBox
            set(obj.textBoxHandle,'String',obj.fotmulaString,'Visible',obj.displayFormula)
        end
    end
end

