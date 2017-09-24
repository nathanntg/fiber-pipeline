classdef WriterVariable < Analysis
    %WRITERVARIABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        times;
        video;
    end
    
    methods
        function FA = WriterVariable()
            % call parent constructor
            FA@Analysis();
        end
        
        function setup(FA, video_details, dim_in)
            % call parent setup
            setup@Analysis(FA, video_details, dim_in);
            
            % store times
            FA.times = (1:video_details.frames) .* video_details.exposure;
        end
        
        function runFrame(FA, frame, i)
            if i == 1
                FA.video = zeros(size(frame, 1), size(frame, 2), length(FA.times), 'like', frame);
            end
            
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

