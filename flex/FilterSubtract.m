classdef FilterSubtract < Filter
    %FILTERSUBTRACT Subtract backgroound from frame intensity
    
    properties
        background;
    end
    
    properties (Access=protected)
        cur_background;
    end
    
    methods
        function FF = FilterSubtract(background)
            FF@Filter();
            
            FF.background = background;
        end
        
        function setup(FF, video_details, dim_in, type_in)
            % call parent
            setup@Filter(FF, video_details, dim_in, type_in);
            
            FF.cur_background = FF.background;
            if ~isa(FF.cur_background, type_in)
                warning('Switching type of background from %s to %s.', class(FF.cur_background), type_in);
                FF.cur_background = cast(FF.cur_background, type_in);
            end
            if size(FF.cur_background, 1) ~= dim_in(1) || size(FF.cur_background, 2) ~= dim_in(2)
                warning('Resizing background from %d x %d to %d x %d.', FF.cur_background(1), FF.cur_background(2), dim_in(1), dim_in(2));
                FF.cur_background = imresize(FF.cur_background, dim_in([1 2]));
            end
        end
        
        function frame = processFrame(FF, frame, i)
            frame = frame - FF.cur_background;
        end
    end
    
end

