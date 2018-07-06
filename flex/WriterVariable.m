classdef WriterVariable < Analysis
    %WRITERVARIABLE Write all frames to a workspace variable
    %   Useful to debug or inspect the filtered frames, by placing them all
    %   in a 3D matrix in the workspace.
    
    properties (Access=protected)
        times;
        video;
    end
    
    methods
        function FA = WriterVariable()
            % call parent constructor
            FA@Analysis();
        end
        
        function setup(FA, video_details, dim_in, type_in)
            % call parent setup
            setup@Analysis(FA, video_details, dim_in, type_in);
            
            % store times
            FA.times = (1:dim_in(end)) .* video_details.exposure;
            
            % allocate
            FA.video = zeros(dim_in, type_in);
        end
        
        function runFrame(FA, frame, i)
            FA.video(:, :, i) = frame;
        end
        
        function teardown(FA, video_details)
            % call parent teardown
            teardown@Analysis(FA, video_details);
        end
        
        function result = getResult(FA)
            result = FA.video;
        end
    end
end

