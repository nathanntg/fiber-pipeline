classdef FilterMedian < Filter
    %FILTERMEDIAN Median filter frames
    
    properties
        size = [3 3];
        sigma;
        radius;
    end
    
    methods
        function FF = FilterMedian(size)
            FF@Filter();
            
            if exist('size', 'var') && ~isempty(size)
                FF.size = size;
            end
        end
        
        function frame = processFrame(FF, frame, i)
            frame = medfilt2(frame, FF.size, 'symmetric');
        end
    end
    
end

