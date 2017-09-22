classdef Analysis < Node
    %ANALYSIS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dim_in;
    end
    
    methods
        function FA = Analysis()
        end
        
        function addOutput(FA, output)
            error('Analysis nodes do not support outputs.');
        end
        
        function setup(FA, video_details, dim_in)
            % pass on to output, but not applicable for analysis
            setup@Node(FA, video_details, dim_in);

            FA.dim_in = dim_in;
        end
    end
    
    methods (Abstract)
        runFrame(FA, frame, i);
        result = getResult(FA);
    end
    
end

