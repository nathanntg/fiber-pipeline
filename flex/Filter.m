classdef Filter < Node
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dim_in;
        type_in;
        
        dim_out;
        type_out;
    end
    
    methods
        function FF = Filter()
            FF@Node();
        end
        
        function dim_out = getDimensions(FF, dim_in)
            dim_out = dim_in;
        end
        
        function type_out = getType(FF, type_in)
            type_out = type_in;
        end
        
        function setup(FF, video_details, dim_in, type_in)
            % cache inputs
            FF.dim_in = dim_in;
            FF.type_in = type_in;
            
            % cache outputs
            FF.dim_out = FF.getDimensions(dim_in);
            FF.type_out = FF.getType(type_in);

            % call parent (empty)
            setup@Node(FF, video_details, FF.dim_out, FF.type_out);
        end
        
        function runFrame(FF, frame, i)
            % checks (TODO: disable)
            if ~strcmp(class(frame), FF.type_in)
                error('Unexpected output type: %s.', class(frame));
            end
            if size(frame, 1) ~= FF.dim_in(1) || size(frame, 2) ~= FF.dim_in(2)
                error('Unexpected output size: %d x %d.', size(Frame, 1), size(frame, 2));
            end
            
            frame = FF.processFrame(frame, i);
            
            % checks (disable)
            if ~strcmp(class(frame), FF.type_out)
                error('Unexpected output type: %s.', class(frame));
            end
            if size(frame, 1) ~= FF.dim_out(1) || size(frame, 2) ~= FF.dim_out(2)
                error('Unexpected output size: %d x %d.', size(Frame, 1), size(frame, 2));
            end
            
            for j = 1:length(FF.outputs)
                FF.outputs{j}.runFrame(frame, i);
            end
        end
    end
    
    methods (Abstract)
        frame = processFrame(FF, frame, i);
    end
    
end

