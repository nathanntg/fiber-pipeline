classdef ReaderVideo < Reader
    %READERVIDEO Read video from raw binary file
    %   Uses accompanying CSV file to get pixel dimension, frame count and
    %   frame timing.
    
    properties
        video;
        
        read_start;
        read_frames;
    end
    
    properties (Access=protected)
        fh;
        frame_number = 0;
        read_size;
        read_precision;
        
        cur_start;
        cur_frames;
    end
    
    methods
        function FR = ReaderVideo(video, start, frames)
            % call parent constructor
            FR@Reader();
            
            % store video file
            FR.video = video;
            
            % range
            if exist('start', 'var') && ~isempty(start)
                FR.read_start = start;
            end
            if exist('frames', 'var') && ~isempty(frames)
                FR.read_frames = frames;
            end
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
        
            % frames to read
            if isempty(FR.read_start) || FR.read_start == 0
                FR.cur_start = 1;
            elseif FR.read_start < 0
                FR.cur_start = frames + FR.read_start;
                if FR.cur_start < 1
                    error('Unable to read the desired number of frames.');
                end
            else
                FR.cur_start = FR.read_start;
            end
            if isempty(FR.read_frames)
                FR.cur_frames = frames + 1 - FR.cur_start;
            else
                FR.cur_frames = min(frames + 1 - FR.cur_start, FR.read_frames);
            end
        
            % output types
            dim_out = [height width FR.cur_frames];
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
            
            % jump to start
            if FR.cur_start > 1
                fseek(FR.fh, prod(FR.read_size) * ceil(video_details.depth / 8) * (FR.cur_start - 1), 'bof');
            end
            
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
