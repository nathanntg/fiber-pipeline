classdef AnalysisRoi < Analysis
    %ANALYSISROI Extract mean trace for circular regions of interest
    %   Specify regions of interest at creation as centers and radiuses. A
    %   mask is used to extract mean pixel intensity for each region of
    %   interest.
    
    properties (Access=protected)
        number;
        roi_centers;
        roi_radii;
        masks;
        trace;
    end
    
    methods
        function FA = AnalysisRoi(centers, radii)
            % call parent constructor
            FA@Analysis();
            
            % number of regions of interest
            FA.number = size(centers, 1);
            
            % accept single radius
            if isscalar(radii)
                radii = radii * ones(FA.number, 1);
            end
            
            % save regions of interest
            FA.roi_centers = centers;
            FA.roi_radii = radii;
        end
        
        function setup(FA, video_details, dim_in, type_in)
            % call parent setup
            setup@Analysis(FA, video_details, dim_in, type_in);
            
            % make a mesh grid based on the video dimensions
            [x, y] = meshgrid(1:dim_in(2), 1:dim_in(1));
            
            % make masks
            FA.masks = cell(1, FA.number);
            for i = 1:FA.number
                FA.masks{i} = find(((x - FA.roi_centers(i, 1)) .^ 2 + (y - FA.roi_centers(i, 2)) .^ 2) < (FA.roi_radii(i) .^ 2));
            end
            
            % make trace (always double)
            FA.trace = zeros(FA.number, dim_in(end));
        end
        
        function runFrame(FA, frame, i)
            for j = 1:FA.number
                FA.trace(j, i) = mean(frame(FA.masks{j}));
            end
        end
        
        function result = getResult(FA)
            result = FA.trace;
        end
    end
end

