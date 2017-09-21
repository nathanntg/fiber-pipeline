classdef Filter < handle
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function FF = Filter()
        end
        
        function dim_out = getDimensions(FF, dim_in)
            dim_out = dim_in;
        end
        
        function setup(FF, video_details, dim_in)
        end
        
        function teardown(FF, video_details)
        end
    end
    
    methods (Abstract)
        frame = processFrame(FF, frame, i);
    end
    
end

