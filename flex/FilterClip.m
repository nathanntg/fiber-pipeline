classdef FilterClip < Filter
    %FILTERCLIP Clip values between 0 and 1
    
    properties
        mn = 0;
        mx = 1;
    end
    
    methods
        function FF = FilterClip()
            FF@Filter();
        end
        
        function frame = processFrame(FF, frame, i)
            frame(frame < FF.mn) = FF.mn;
            frame(frame > FF.mx) = FF.mx;
        end
    end
    
end

