classdef AnalysisMean < Analysis
    %ANALYSISMEAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        sum;
        cnt;
    end
    
    methods
        function FA = AnalysisMean()
            % call parent constructor
            FA@Analysis();
        end
        
        function setup(FA, video_details, dim_in, type_in)
            % call parent setup
            setup@Analysis(FA, video_details, dim_in, type_in);
            
            % allocate variables
            FA.cnt = 0;
            FA.sum = zeros(dim_in(1), dim_in(2), 'double');
        end
        
        function runFrame(FA, frame, i)
            FA.sum = FA.sum + double(frame);
            FA.cnt = FA.cnt + 1;
        end
        
        function result = getResult(FA)
            result = FA.sum ./ FA.cnt;
        end
    end
end

