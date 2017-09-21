classdef AnalysisRoi < Analysis
    %ANALYSISROI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        number;
        roi_centers;
        roi_radii;
        masks;
        trace;
    end
    
    methods
        function FA = AnalysisRoi(centers, radii)
            FA@Analysis();
            
            FA.number = size(centers, 1);
            
            % accept single radius
            if isscalar(radii)
                radii = radii * ones(FA.number, 1);
            end
            
            FA.roi_centers = centers;
            FA.roi_radii = radii;
        end
        
        function setup(FA, video_details, dim_in)
            [x, y] = meshgrid(1:dim_in(2), 1:dim_in(1));
            
            % make masks
            FA.masks = cell(1, FA.number);
            for i = 1:FA.number
                FA.masks{i} = find(((x - FA.roi_centers(i, 2)) .^ 2 + (y - FA.roi_centers(i, 1)) .^ 2) < (FA.roi_radii(i) .^ 2));
            end
            
            % make trace
            FA.trace = zeros(FA.number, video_details.frames);
        end
        
        function result = finalize(FA, video_details)
            result = FA.trace;
        end
        
        function processFrame(FA, frame, i)
            for j = 1:FA.number
                FA.trace(j, i) = mean(frame(FA.masks{j}));
            end
        end
    end
end

