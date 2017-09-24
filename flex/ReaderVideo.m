classdef ReaderVideo < Reader
    %READERVIDEO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fh;
        video;
        last_frame;
        frame_number = 0;
        read_size;
        read_precision;
    end
    
    methods
        function FR = ReaderVideo(video)
            % call parent constructor
            FR@Reader();
            
            % store video file
            FR.video = video;
        end
        
        function [details, dim_out, type_out] = getVideoDetails(FR)
            % find correspond csv file
            [path, name, ~] = fileparts(FR.video);
            data = csvread(fullfile(path, [name '.csv']));

            % pull out relevant information
            frames = size(data, 1);
            depth = data(1, 3);
            height = data(1, 4);
            width = data(1, 5);
            exposure = data(1, 7);

            bytes = ceil(depth / 8) * width * height;

            % assemble details
            details = struct(...
                'file', FR.video, 'frames', frames, ...
                'exposure', exposure, ...
                'width', width, 'height', height, ...
                'depth', depth, 'bytes', bytes ...
            );
        
            % output types
            dim_out = [height width frames];
            type_out = sprintf('uint%d', 8 * ceil(depth / 8));
        end
        
        function setup(FR, video_details, dim_in, type_in)
            % open file
            FR.fh = fopen(video_details.file, 'r');
            if FR.fh < 0
                error('Unable to open video file: %s.', video_details.file);
            end
            
            % read settings
            FR.read_size = [video_details.height video_details.width];
            FR.read_precision = sprintf('*uint%d', 8 * ceil(video_details.depth / 8));
            
            % reset frame number
            FR.frame_number = 0;
            
            % call parent
            setup@Reader(FR, video_details, dim_in, type_in);
        end
        
        function teardown(FR, video_details)
            % call parent
            teardown@Reader(FR, video_details);
            
            % close file handle
            fclose(FR.fh);
        end
        
        function [i, frame] = readNextFrame(FR)
            FR.frame_number = FR.frame_number + 1;
            i = FR.frame_number;
            
            % read frame
            frame = fread(FR.fh, FR.read_size, FR.read_precision);
        end
    end
end
