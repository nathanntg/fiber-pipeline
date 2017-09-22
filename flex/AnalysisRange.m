classdef AnalysisRange < Analysis
    %ANALYSISRANGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        mn;
        mx;
    end
    
    methods
        function FA = AnalysisRange()
            FA@Analysis();
        end
        
        function setup(FA, video_details, dim_in)
            % call parent setup
            setup@Analysis(FA, video_details, dim_in);
            
            % empty containers
            FA.mn = [];
            FA.mx = [];
        end
        
        function runFrame(FA, frame, i)
            if i == 1
                FA.mn = frame;
                FA.mx = frame;
                return;
            end
            
            FA.mn = min(FA.mn, frame);
            FA.mx = max(FA.mx, frame);
        end
        
        function result = getResult(FA)
            result = cat(3, FA.mn, FA.mx);
        end
    end
    
end

