classdef FilterConvertSingle < Filter
    %FILTERCONVERTSINGLE Convert frame to single
    
    properties
    end
    
    methods
        function FF = FilterConvertSingle()
            FF@Filter();
        end
        
        function type_out = getType(FF, type_in)
            type_out = 'single';
        end
        
        function setup(FF, video_details, dim_in, type_in)
            % call parent
            setup@Filter(FF, video_details, dim_in, type_in);
        end
        
        function teardown(FF, video_details)
            % call parent
            teardown@Filter(FF, video_details);
        end
        
        function frame = processFrame(FF, frame, i)
            frame = im2single(frame);
        end
    end
    
end
