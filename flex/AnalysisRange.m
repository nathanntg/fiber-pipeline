classdef AnalysisRange < Analysis
    %ANALYSISRANGE Extract intensity range for each pixel
    %   Returns two concatenated frames, one corresponding with the 
    %   minimum values and one corresponding with the maximum values.
    
    properties (Access=protected)
        mn;
        mx;
    end
    
    methods
        function FA = AnalysisRange()
            FA@Analysis();
        end
        
        function setup(FA, video_details, dim_in, type_in)
            % call parent setup
            setup@Analysis(FA, video_details, dim_in, type_in);
            
            % empty containers
            FA.mn = ones(dim_in(1), dim_in(2), type_in) * Inf;
            FA.mx = ones(dim_in(1), dim_in(2), type_in) * -Inf;
        end
        
        function runFrame(FA, frame, i)
            FA.mn = min(FA.mn, frame);
            FA.mx = max(FA.mx, frame);
        end
        
        function result = getResult(FA)
            result = cat(3, FA.mn, FA.mx);
        end
    end
    
end

