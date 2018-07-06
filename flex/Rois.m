classdef Rois < handle
    %ANNOTATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        default_diameter = 10;
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
        function RN = Rois(image)
            RN.image = image;
            
            % create viewer window
            RN.win = figure();
            
            % set 
%             set(RN.win, 'PaperPositionMode', 'auto');
%             set(RN.win, 'InvertHardcopy', 'off');
%             set(RN.win, 'Units', 'pixels');
%             set(RN.win, 'Pointer', 'crosshair');
            set(RN.win, 'WindowButtonDownFcn', {@RN.cb_clickWindow});
            set(RN.win, 'DeleteFcn', {@RN.cb_closeWindow});
            
            % get axes
            RN.axes = axes('Parent', RN.win);
%             axis off;
            
            % show image
            imshow(RN.image, 'Parent', RN.axes, 'Border', 'tight');
%             pan off;
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
