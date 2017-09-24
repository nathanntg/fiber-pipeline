classdef ReaderVariable < Reader
    %READERVARIABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        video;
        last_frame;
        frame_number = 0;
    end
    
    methods
        function FR = ReaderVariable(video)
            % call parent constructor
            FR@Reader();
            
            % store video file
            FR.video = video;
        end
        
        function details = getVideoDetails(FR)
            % pull out relevant information
            frames = size(FR.video, 3);
            height = size(FR.video, 1);
            width = size(FR.video, 2);
            exposure = 1;

            % assemble details
            details = struct(...
                'file', FR.video, 'frames', frames, ...
                'exposure', exposure, ...
                'width', width, 'height', height ...
            );
        end
        
        function setup(FR, video_details, dim_in)
            % reset frame number
            FR.frame_number = 0;
            
            % call parent
            setup@Reader(FR, video_details, dim_in);
        end
        
        function teardown(FR, video_details)
            % call parent
            teardown@Reader(FR, video_details);
        end
        
        function [i, frame] = readNextFrame(FR)
            FR.frame_number = FR.frame_number + 1;
            
            % return frame
            i = FR.frame_number;
            frame = FR.video(:, :, FR.frame_number);
        end
    end
end
