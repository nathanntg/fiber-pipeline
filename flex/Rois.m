classdef Rois < handle
    %ROIS Annotator for drawing regions of interest on an image
    %   Useful in cases where regions of interest can not be automatically
    %   extracted.
    
    properties
        default_diameter = 10;
        
        % only populated on close
        centers;
        radii;
    end
    
    properties (Access=protected)
        % image
        image
        
        % annotations
        annotations = {}; % rows: points, columns: x, y, type
        
        % handles
        win
        axes
    end
    
    methods
        function RN = Rois(image, centers, radii)
            RN.image = image;
            
            % create viewer window
            RN.win = figure();
            
            % set 
%             set(RN.win, 'PaperPositionMode', 'auto');
%             set(RN.win, 'InvertHardcopy', 'off');
            set(RN.win, 'Units', 'pixels');
%             set(RN.win, 'Pointer', 'crosshair');
            set(RN.win, 'WindowButtonDownFcn', {@RN.cb_clickWindow});
            set(RN.win, 'DeleteFcn', {@RN.cb_closeWindow});
            
            % get axes
            RN.axes = axes('Parent', RN.win);
%             axis off;
            
            % show image
            imshow(RN.image, 'Parent', RN.axes, 'Border', 'tight');
            pan off;

            % initial values
            if exist('centers', 'var') && exist('radii', 'var')
                for i = 1:size(centers, 1)
                    % add to annotations
                    RN.annotations{end + 1} = imellipse(RN.axes, [...
                        centers(i, 1) - radii(i), ...
                        centers(i, 2) - radii(i), ...
                        2 * radii(i), ...
                        2 * radii(i) ...
                        ]);
                end
            end
        end
        
        function delete(RN)
            try
                delete(RN.win);
            catch err %#ok<NASGU>
            end
        end
        
        function cb_clickWindow(RN, h, event)
            % imgca(AN.win)
            pos = get(RN.axes, 'CurrentPoint');
            
            % make sure there is a value
            if size(pos, 1) < 1
                return;
            end
            
            i = pos(1, 1); j = pos(1, 2);
            
            % add to annotations
            if strcmp(h.SelectionType, 'open')
                RN.addAnnotation(i, j);
            end
        end
        
        function cb_closeWindow(RN, h, event)
            [RN.centers, RN.radii, ~] = RN.getAnnotations();
            
            % nothing to do
            if ~isvalid(RN)
                return;
            end
            
            % clear image
            clear RN.image;
        end
        
        function [centers, radii, annots] = getAnnotations(RN)
            % get position for each annotation
            annots = cellfun(@getPosition, RN.annotations, 'UniformOutput', false);
            
            % concatenate
            annots = cat(1, annots{:});
            
            % convert to centers and radii
            centers = annots(:, 1:2) + annots(:, 3:4) ./ 2;
            radii = annots(:, 3) ./ 2;
        end
        
        function [centers, radii] = waitForAnnotations(RN)
            waitfor(RN.axes);
            centers = RN.centers;
            radii = RN.radii;
        end
    end
    
    methods (Access=protected)
        function addAnnotation(RN, i, j)
            % add to annotations
            RN.annotations{end + 1} = imellipse(RN.axes, [...
                i - RN.default_diameter / 2, ...
                j - RN.default_diameter / 2, ...
                RN.default_diameter, ...
                RN.default_diameter, ...
                ]);
        end
    end
end
