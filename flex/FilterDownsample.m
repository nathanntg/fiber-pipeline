classdef FilterDownsample < Filter
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        factor;
    end
    
    methods
        function FF = FilterDownsample(factor)
            FF@Filter();
            
            FF.factor = factor;
        end
        
        function dim_out = getDimensions(FF, dim_in)
            dim_out = dim_in ./ FF.factor;
        end
        
        function frame = processFrame(FF, frame, i)
            frame = imresize(frame, FF.dim_out);
        end
    end
    
end

