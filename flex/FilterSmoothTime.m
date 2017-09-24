classdef FilterSmoothTime < Filter
    %FILTERSMOOTHTIME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % TODO: potentially add non flat filters? 
        smooth_frames;
    end
    
    properties (Access=protected)
        at_start;
        next_frame = 1;
        running;
    end
    
    methods
        function FF = FilterSmoothTime(smooth_frames)
            FF@Filter();
            
            FF.smooth_frames = smooth_frames;
            
            FF.at_start = ceil((smooth_frames - 1) / 2);
        end
        
        function type_out = getType(FF, type_in)
            if strcmp(type_in, 'single') || strcmp(type_in, 'double')
                type_out = type_in;
            else
                type_out = 'single';
            end
        end
        
        function setup(FF, video_details, dim_in, type_in)
            % call parent
            setup@Filter(FF, video_details, dim_in, type_in);
            
            % set next frame
            FF.next_frame = 1;
            FF.running = zeros(dim_in(1), dim_in(2), FF.smooth_frames, FF.type_out);
        end
        
        function runFrame(FF, frame, i)
            % convert to single
            if ~isa(frame, 'single') && ~isa(frame, 'double')
                frame = im2single(frame);
            end
            
            % add to running
            FF.running(:, :, FF.next_frame) = frame;
            
            % advance next frame
            FF.next_frame = 1 + mod(FF.next_frame + 1, FF.smooth_frames);
            
            % pad start with at_start
            if i == 1
                for j = 1:FF.at_start
                    % add to running
                    FF.running(:, :, FF.next_frame) = frame;

                    % advance next frame
                    FF.next_frame = 1 + mod(FF.next_frame + 1, FF.smooth_frames);
                end
            end
            
            % should emit
            if i > FF.at_start
                % flat filter (mean)
                smoothed_frame = mean(FF.running, 3);
                
                % send to outputs
                for j = 1:length(FF.outputs)
                    FF.outputs{j}.runFrame(smoothed_frame, i - FF.at_start);
                end
            end
            
            % at end?
            if i == FF.dim_in(end)
                for k = 1:FF.at_start
                    % add to running
                    FF.running(:, :, FF.next_frame) = frame;

                    % advance next frame
                    FF.next_frame = 1 + mod(FF.next_frame + 1, FF.smooth_frames);
                    
                    % emit frame
                    smoothed_frame = mean(FF.running, 3);
                
                    % send to outputs
                    for j = 1:length(FF.outputs)
                        FF.outputs{j}.runFrame(smoothed_frame, i - FF.at_start + k);
                    end
                end
            end
            
        end
        
        function frame = processFrame(FF, frame, i)
        end
    end
    
end

