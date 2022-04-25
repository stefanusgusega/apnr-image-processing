classdef app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        AlreadyPlateSwitch    matlab.ui.control.Switch
        AlreadyPlateLabel     matlab.ui.control.Label
        ResultLabel           matlab.ui.control.Label
        AutomaticNumberPlateRecognitionLabel  matlab.ui.control.Label
        PlateTitleLabel       matlab.ui.control.Label
        BrowseButton          matlab.ui.control.Button
        BoundingBoxImageAxes  matlab.ui.control.UIAxes
        InputImageAxes        matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        imageFname % Image filename
    end
    
    methods (Access = private)
        
        function initiateImageAxesComponent(~, component)
            component.Visible = 'off';
            component.Colormap = gray(256);
            axis(component, 'image');
        end
        
        function updateImage(app, fname)
            % techniqueDropDownArr = [app.GradientTechniqueDropDown, app.LaplacianTechniqueDropDown];
            
            % Read the image
            try
                im = imread(fname);
            catch ME
                % if problem reading image, display error message
                uialert(app.UIFigure, ME.message, 'Image Error');
                return;
            end

%             % assign current tab input
%             currInputImageAxes = app.inputImageAxesArr(tab_num);
% 
%             % assign current tab edge
%             currEdgeImageAxes = app.edgeImageAxesArr(tab_num);
%             
%             % assign current tab segmented object
%             currSegmentImageAxes = app.segmentImageAxesArr(tab_num);    
% 
            % display the image
            imagesc(app.InputImageAxes, im);

            recognizedChars = getOutput(app, im);
            disp(recognizedChars);

%             switch size(im,3)
%                 case 1
%                     % Display the grayscale image
%                     imagesc(app.BoundingBoxImageAxes, im);
%                     recognizedChars = getOutput(app, im);
% 
%                 case 3
%                     imagesc(app.BoundingBoxImageAxes, im);
%                     imgray = rgb2gray(im);
%                     recognizedChars = getOutput(app, imgray);
% 
%                 otherwise
%                     % Error when image is not grayscale or truecolor
%                     uialert(app.UIFigure, 'Image must be grayscale or truecolor.', 'Image Error');
%                     return;
%             end 

            app.ResultLabel.Text = recognizedChars;
        end
        
        function letters = getOutput(app, im)
            % If not a plate, detect the plate first
            if strcmp(app.AlreadyPlateSwitch.Value, 'No')
                plateIm = detectPlate(im);
                imagesc(app.BoundingBoxImageAxes, plateIm);
            % Else apply grayscaling directly
            else
                plateIm = im2gray(im);
                imagesc(app.BoundingBoxImageAxes, im);
            end

            segments = segmentLetter(plateIm);
            letters = [];

            [h, ~] = size(plateIm);

            for k = 1:length(segments)

                ow = length(segments(k).Image(1, :));
                oh = length(segments(k).Image(:, 1));
                ratio = ow/oh;

                % The height of bounding box should be in range (0.26*h, 0.8*h)
                % and its weight should be less than or equal with its height
                if oh < (0.8 * h) && oh > (0.26 * h) && ow <= oh && ratio > 0.1
                    ratio = ow/oh
                    thisBB = segments(k).BoundingBox;
                    %     figure,imshow(imcrop(imcr, thisBB));
                    rectangle(app.BoundingBoxImageAxes, 'Position', [thisBB(1), thisBB(2), thisBB(3), thisBB(4)], ...
                    'EdgeColor', 'g', 'LineWidth', 2)
        
                    thisLetter = segments(k).Image;
        
                    detect = detectLetter(thisLetter);
                    letters = [letters detect];
                end
        
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % image path
            path = [pwd filesep '..' filesep 'images' filesep];

            % Show loading dialog
            d = uiprogressdlg(app.UIFigure, 'Title', 'Recognizing plate number...', 'Indeterminate', 'on');
            drawnow

            initiateImageAxesComponent(app, app.InputImageAxes);
            initiateImageAxesComponent(app, app.BoundingBoxImageAxes);
            app.imageFname = [path 'indirect-plate' filesep '01.jpg'];

            updateImage(app, app.imageFname);

            % Stop loading dialog
            close(d);
        end

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            % Display uigetfile dialog
            filterspec = {'*.jpg;*.tif;*.png;*.gif;*.bmp','All Image Files'};
            [f, p] = uigetfile(filterspec);
            
            % Make sure user didn't cancel uigetfile dialog
            if (ischar(p))
               app.imageFname = [p f];
               d = uiprogressdlg(app.UIFigure, 'Title', 'Recognizing plate number...', 'Indeterminate', 'on');
               drawnow
               updateImage(app, app.imageFname);
               close(d);
            end
        end

        % Value changed function: AlreadyPlateSwitch
        function AlreadyPlateSwitchValueChanged(app, event)
           d = uiprogressdlg(app.UIFigure, 'Title', 'Recognizing plate number...', 'Indeterminate', 'on');
           drawnow
           updateImage(app, app.imageFname);
           close(d);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create InputImageAxes
            app.InputImageAxes = uiaxes(app.UIFigure);
            title(app.InputImageAxes, 'Input Image')
            app.InputImageAxes.XTick = [];
            app.InputImageAxes.YTick = [];
            app.InputImageAxes.Position = [35 231 267 167];

            % Create BoundingBoxImageAxes
            app.BoundingBoxImageAxes = uiaxes(app.UIFigure);
            title(app.BoundingBoxImageAxes, 'Bounding Box')
            app.BoundingBoxImageAxes.XTick = [];
            app.BoundingBoxImageAxes.YTick = [];
            app.BoundingBoxImageAxes.Position = [333 231 267 167];

            % Create BrowseButton
            app.BrowseButton = uibutton(app.UIFigure, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [119 209 100 23];
            app.BrowseButton.Text = 'Browse';

            % Create PlateTitleLabel
            app.PlateTitleLabel = uilabel(app.UIFigure);
            app.PlateTitleLabel.Position = [261 168 147 22];
            app.PlateTitleLabel.Text = 'Here is your number plate:';

            % Create AutomaticNumberPlateRecognitionLabel
            app.AutomaticNumberPlateRecognitionLabel = uilabel(app.UIFigure);
            app.AutomaticNumberPlateRecognitionLabel.FontSize = 24;
            app.AutomaticNumberPlateRecognitionLabel.FontWeight = 'bold';
            app.AutomaticNumberPlateRecognitionLabel.Position = [44 416 438 31];
            app.AutomaticNumberPlateRecognitionLabel.Text = 'Automatic Number Plate Recognition';

            % Create ResultLabel
            app.ResultLabel = uilabel(app.UIFigure);
            app.ResultLabel.HorizontalAlignment = 'center';
            app.ResultLabel.FontSize = 24;
            app.ResultLabel.FontWeight = 'bold';
            app.ResultLabel.Position = [150 80 367 81];
            app.ResultLabel.Text = 'Not Found';

            % Create AlreadyPlateLabel
            app.AlreadyPlateLabel = uilabel(app.UIFigure);
            app.AlreadyPlateLabel.HorizontalAlignment = 'center';
            app.AlreadyPlateLabel.Position = [432 175 83 22];
            app.AlreadyPlateLabel.Text = 'Already Plate?';

            % Create AlreadyPlateSwitch
            app.AlreadyPlateSwitch = uiswitch(app.UIFigure, 'slider');
            app.AlreadyPlateSwitch.Items = {'No', 'Yes'};
            app.AlreadyPlateSwitch.ValueChangedFcn = createCallbackFcn(app, @AlreadyPlateSwitchValueChanged, true);
            app.AlreadyPlateSwitch.Position = [450 212 45 20];
            app.AlreadyPlateSwitch.Value = 'No';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end