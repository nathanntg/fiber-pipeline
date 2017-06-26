classdef Explorer < handle
    %EXPLORER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % dimensions
        d_height
        d_width
        d_frames
        d_trials
        
        % video
        image
        video_s % standard deviation 
        video_r % video, but with pixels as a single vector
        video_roe_smp
        
        % pixel size
        pixel_size
    end
    
    properties (Access=protected)
        % mode
        mode = 1 % 1 - extract point, 2 - adjust image
        
        % handles
        win
        axes
        
        % gui elements
        gui_toolbar
    end
    
    methods
        function EX = Explorer(video, video_roe_smp, pixel_size)
            % dimensions
            EX.d_height = size(video, 1);
            EX.d_width = size(video, 2);
            EX.d_frames = size(video, 3);
            EX.d_trials = size(video, 4);
            
            % set parameters
            %EX.image = imadjust(mat2gray(video(:, :, 1, 1)));
            EX.video_r = reshape(video, [], EX.d_frames, EX.d_trials);
            EX.video_roe_smp = video_roe_smp;
            EX.pixel_size = pixel_size;
            
            % calculate standard deviation
            EX.video_s = zeros(EX.d_height, EX.d_width, EX.d_trials);
            for i = 1:EX.d_trials
                EX.video_s(:, :, i) = nanstd(video(:, :, :, i), 0, 3);
            end
            
            % get screen size
            screen = get(0, 'ScreenSize');
            
            % inital dimensions
            h = EX.d_height;
            w = EX.d_width;
            x = max((screen(3) - w) / 2, 0);
            y = max((screen(2) - h) / 2, 0);
            
            % make color
            color_bg = [0.85 0.85 0.85];
            
            % create viewer window
            EX.win = figure('Visible', 'on', 'Name', 'Explore Video', ...
                'Position', [x y w h], 'NumberTitle', 'off', 'Toolbar', ...
                'none', 'MenuBar', 'none', 'Resize', 'off', 'Color', ...
                color_bg);
            
            % set 
            set(EX.win, 'PaperPositionMode', 'auto');
            set(EX.win, 'InvertHardcopy', 'off');
            set(EX.win, 'Units', 'pixels');
            set(EX.win, 'Pointer', 'crosshair');
            set(EX.win, 'WindowButtonDownFcn', {@EX.cb_clickWindow});
            set(EX.win, 'DeleteFcn', {@EX.cb_closeWindow});
            
            % toolbar
            EX.gui_toolbar = uitoolbar('Parent', EX.win);
            
            % add magic button
            [ico, ~, alpha] = imread(fullfile(matlabroot, 'toolbox', 'matlab', 'icons', 'tool_shape_rectangle.png'));
            if isa(ico, 'uint8')
                ico = double(ico) / (256 - 1);
            elseif isa(ico, 'uint16')
                ico = double(ico) / (256 * 256 - 1);
            end
            ico(repmat(alpha == 0, 1, 1, size(ico, 3))) = nan;
            uipushtool('Parent', EX.gui_toolbar, 'CData', ico, ...
                'ClickedCallback', {@EX.cb_adjustImage}, 'TooltipString', ...
                'Calibrate Brightness');
            
            % get axes
            EX.axes = axes('Parent', EX.win);
            axis off;
            
            % show image
            EX.updateImage();
        end
        
        function delete(EX)
            try
                delete(EX.win);
            catch err %#ok<NASGU>
            end
        end
        
        % TODO: remove this function
        function ax = getAxes(EX)
            if isempty(EX.axes)
                ax = imgca(EX.win);
                warning('Handle disappeared.');
            else
                ax = EX.axes;
            end
        end
        
        function cb_clickWindow(EX, h, ~)
            % check mode
            if EX.mode ~= 1
                return
            end
            
            % try axes
            pos = get(EX.getAxes(), 'CurrentPoint');
            
            % make sure there is a value
            if size(pos, 1) < 1
                return;
            end
            
            i = pos(1, 1); j = pos(1, 2);
            
            % right click? do nothing...
            if strcmp(h.SelectionType, 'alt')
                return;
            end
            
            % debugging
            disp([i, j]);
            
            % extract and display
            EX.extractActivity(i, j);
        end
        
        function cb_closeWindow(EX, ~, ~)
            % nothing to do
            if ~ishandle(EX)
                return;
            end
            
            % clear image
            clear EX.video_r;
        end
        
        function extractActivity(EX, i, j)
            % make mesh grid
            [x, y] = meshgrid(1:size(EX.image, 2), 1:size(EX.image, 1));
            
            % radius squared
            r2 = (EX.pixel_size / 2) ^ 2;
            
            % mask
            mask = ((x - i) .^ 2 + (y - j) .^ 2) <= r2;
            
            % extracted
            traces = squeeze(mean(EX.video_r(mask, :, :), 1));
            
            % open figure
            figure;
            plot(EX.video_roe_smp, traces);
        end
        
        function cb_adjustImage(EX, ~, ~)
            % draw polygon
            old_mode = EX.mode;
            EX.mode = 2; % mode: adjust image
            h = impoly(EX.getAxes(), 'Closed', true);
            EX.mode = old_mode;
            
            % make mask
            mask = h.createMask();
            
            % replace image
            EX.updateImage(2, mask);
            
            % debugging
            figure;
            imagesc(mask);
            
            % delete
            delete(h);
        end
        
        function updateImage(EX, type, dr) % type: 1 - raw, 2 - std; % dr: [], [min max], [mask]
            % defaults
            if ~exist('type', 'var')
                type = 1;
            end
            if ~exist('dr', 'var')
                dr = [];
            end
            
            % get base image
            if type == 2
                im = mean(EX.video_s, 3);
            else
                im = reshape(EX.video_r(:, 1, 1), EX.d_height, EX.d_width);
            end
            
            % scale range
            if isempty(dr)
                im = mat2gray(im);
            elseif numel(dr) == 2
                im = mat2gray(im, dr);
            elseif numel(dr) == (EX.d_width * EX.d_height)
                t = im(dr);
                dr = quantile(t, [0.01 0.99]);
                disp(dr);
                disp([min(im(:)) max(im(:))]);
                im = mat2gray(im, [min(t) max(t)]);
            else
                error('Invalid dynamic range parameter.');
            end
            
            % make image
            EX.image = imadjust(im);
            
            % show image
            imshow(EX.image, 'Parent', EX.axes, 'Border', 'tight');
            pan off;
        end
    end
    
end

