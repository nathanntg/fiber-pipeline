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
            dim_out = [ceil(dim_in(1) ./ FF.factor), ...
                ceil(dim_in(2) ./ FF.factor), ...
                dim_in(3)];
        end
        
        function frame = processFrame(FF, frame, i)
            frame = imresize(frame, FF.dim_out(1:2), 'box');
        end
    end
    
end

