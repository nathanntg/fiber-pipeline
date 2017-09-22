classdef Filter < Node
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dim_out;
    end
    
    methods
        function FF = Filter()
            FF@Node();
        end
        
        function dim_out = getDimensions(FF, dim_in)
            dim_out = dim_in;
        end
        
        function setup(FF, video_details, dim_in)
            % cache dimensions out
            FF.dim_out = FF.getDimensions(dim_in);

            % call parent (empty)
            setup@Node(FF, video_details, FF.dim_out);
        end
        
        function runFrame(FF, frame, i)
            frame = FF.processFrame(frame, i);
            
            for j = 1:length(FF.outputs)
                FF.outputs{j}.runFrame(frame, i);
            end
        end
    end
    
    methods (Abstract)
        frame = processFrame(FF, frame, i);
    end
    
end

