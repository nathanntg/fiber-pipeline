classdef WriterMovie < Analysis
    %WRITERMOVIE Write movie file
    %   Writes incoming frames to a movie file. Optionally specify the
    %   frame rate at creation (otherwise matches input file).
    
    properties (Access=protected)
        movie;
        format;
        fps;
        
        vh;
    end
    
    methods
        function FA = WriterMovie(movie, format, fps)
            % call parent constructor
            FA@Analysis();
            
            % number of regions of interest
            if exist('movie', 'var') && ~isempty(movie)
                FA.movie = movie;
            end
            
            % format
            if exist('format', 'var') && ~isempty(format)
                FA.format = format;
            elseif ~isempty(FA.movie)
                % infer format from name
                switch FA.movie((end-2):end)
                    case 'mp4'
                        FA.format = 'MPEG-4';
                    case 'm4v'
                        FA.format = 'MPEG-4';
                    case 'mj2'
                        FA.format = 'Motion JPEG 2000';
                    case 'avi'
                        FA.format = 'Motion JPEG AVI';
                    otherwise
                        error('Unknown format.');
                end
            else
                FA.format = 'MPEG-4';
            end
            
            % fps
            if exist('fps', 'var') && ~isempty(fps)
                FA.fps = fps;
            end
        end
        
        function setup(FA, video_details, dim_in, type_in)
            % call parent setup
            setup@Analysis(FA, video_details, dim_in, type_in);
            
            % movie 
            cur_movie = FA.movie;
            if isempty(cur_movie)
                [path, name, ~] = fileparts(video_details.file);
                
                switch FA.format
                    case 'MPEG-4'
                        ext = 'mp4';
                    case 'Motion JPEG 2000'
                        ext = 'mj2';
                    case 'Motion JPEG AVI'
                        ext = 'avi';
                    otherwise
                        error('Unknown format.');
                end
                
                cur_movie = fullfile(path, [name '.' ext]);
            end
            
            % open video handle
            FA.vh = VideoWriter(cur_movie, FA.format);
            
            % set frame rate
            if isempty(FA.fps)
                FA.vh.FrameRate = 1 / video_details.exposure;
            else
                FA.vh.FrameRate = FA.fps;
            end
            
            % open
            open(FA.vh);
        end
        
        function runFrame(FA, frame, i)
            if isa(frame, 'uint16') || isa(frame, 'single')
                frame = im2uint8(frame);
            end
            
            % turn to color
            if ismatrix(frame)
                frame = repmat(frame, 1, 1, 3);
            end
            
            writeVideo(FA.vh, im2frame(frame));
        end
        
        function teardown(FA, video_details)
            % call parent teardown
            teardown@Analysis(FA, video_details);
            
            close(FA.vh);
        end
        
        function result = getResult(FA)
            result = 1;
        end
    end
end

