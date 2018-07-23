classdef ReaderImageDirectory < Reader
    %READERIMAGEDIRECTORY Read video frames from a directory
    %   Uses a mask to find all images in a directory and appends them as
    %   frames.
    
    properties
        file_mask;
    end
    
    properties (Access=protected)
        files;
        frame_number = 0;
    end
    
    methods
        function FR = ReaderImageDirectory(file_mask)
            % call parent constructor
            FR@Reader();
            
            % store mask
            FR.file_mask = file_mask;
            
            % get all files
            [directory, ~, ~] = fileparts(file_mask);
            files = dir(file_mask);
            FR.files = cellfun(@(x) fullfile(directory, x), {files(:).name}, 'UniformOutput', false);
        end
        
        function [details, dim_out, type_out] = getVideoDetails(FR)
            % read frame
            frame = imread(FR.files{1});

            % pull out relevant information
            frames = length(FR.files);
            height = size(frame, 1);
            width = size(frame, 2);

            %bytes = ceil(depth / 8) * width * height;

            % assemble details
            details = struct(...
                'file', FR.files{1}, 'frames', length(FR.files), ...
                'exposure', nan, ...
                'width', width, 'height', height, ...
                'depth', nan, 'bytes', nan ...
            );
        
            % output types
            dim_out = [height width frames];
            type_out = class(frame);
        end
        
        function setup(FR, video_details, dim_in, type_in)
            % reset frame number
            FR.frame_number = 0;
            
            % call parent
            setup@Reader(FR, video_details, dim_in, type_in);
        end
        
        function teardown(FR, video_details)
            % call parent
            teardown@Reader(FR, video_details);
        end
        
        function [i, frame] = readNextFrame(FR)
            FR.frame_number = FR.frame_number + 1;
            i = FR.frame_number;
            
            % read frame
            frame = imread(FR.files{i});
        end
    end
end
