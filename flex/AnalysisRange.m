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
            FA.mn = [];
            FA.mx = [];
        end
        
        function result = finalize(FA, video_details)
            result = cat(3, FA.mn, FA.mx);
        end
        
        function processFrame(FA, frame, i)
            if i == 1
                FA.mn = frame;
                FA.mx = frame;
                return;
            end
            
            FA.mn = min(FA.mn, frame);
            FA.mx = max(FA.mx, frame);
        end
    end
    
end

