classdef Node < handle
    %NODE Base node class
    
    properties (Access=protected)
        outputs = {};
    end
    
    methods
        function FN = Node()
        end
        
        function addOutput(FN, output)
            if iscell(output)
                FN.outputs = [FN.outputs output];
            else
                FN.outputs{end + 1} = output;
            end
        end

        function setup(FN, video_details, dim, type)
            % setup sub-nodes
            for i = 1:length(FN.outputs)
                FN.outputs{i}.setup(video_details, dim, type);
            end
        end
        
        function teardown(FN, video_details)
            % teardown sub-nodes
            for i = 1:length(FN.outputs)
                FN.outputs{i}.teardown(video_details);
            end
        end
    end
    
    methods (Abstract)
        runFrame(FN, frame, i);
    end
end
