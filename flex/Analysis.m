classdef Analysis < Node
    %ANALYSIS Basic analysis node
    %   An analysis node does not have an output, and will throw an error
    %   if you attempt to add an output. Subclasses must define functions
    %   for processing a frame (runFrame) and for getting the result
    %   (getResult).
    
    properties
        dim_in;
        type_in;
    end
    
    methods
        function FA = Analysis()
        end
        
        function addOutput(FA, output)
            error('Analysis nodes do not support outputs.');
        end
        
        function setup(FA, video_details, dim_in, type_in)
            % cache inputs
            FA.dim_in = dim_in;
            FA.type_in = type_in;
            
            % pass on to output, but not applicable for analysis
            setup@Node(FA, video_details, dim_in, type_in);
        end
    end
    
    methods (Abstract)
        runFrame(FA, frame, i);
        result = getResult(FA);
    end
    
end

