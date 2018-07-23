classdef FilterAdjust < Filter
    %FILTERADJUST Gaussian filter frames
    
    properties
        in;
        out;
    end
    
    methods
        function FF = FilterAdjust(in, out)
            FF@Filter();
            
            FF.in = in;
            if exist('out', 'var') && ~isempty(out)
                FF.out = out;
            else
                FF.out = [0 1];
            end
        end
        
        function frame = processFrame(FF, frame, i)
            frame = imadjust(frame, FF.in, FF.out);
        end
    end
    
end

