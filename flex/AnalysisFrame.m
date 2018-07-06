classdef AnalysisFrame < Analysis
    %ANALYSISRANGE Extract specific frame(s) from the video
    %   When created, pass one or more frame indices (as a vector). Frame
    %   indices can be positive (counting from the start) or negative
    %   (counting from the last frame).
    
    properties (Access=protected)
        frame_idx; % relative frame indices
        frame_idx_abs; % absolute frame indices (calculated during setup)
        frames;
    end
    
    methods
        function FA = AnalysisFrame(fetch_frame_idx)
            FA@Analysis();
            
            FA.frame_idx = fetch_frame_idx;
        end
        
        function setup(FA, video_details, dim_in, type_in)
            % call parent setup
            setup@Analysis(FA, video_details, dim_in, type_in);
            
            % set frame indices
            FA.frame_idx_abs = FA.frame_idx;
            
            % correct negative indices
            neg = FA.frame_idx < 0;
            if any(neg)
                FA.frame_idx_abs(neg) = dim_in(end) + 1 + FA.frame_idx(neg);
            end
            
            % allocate frames
            FA.frames = zeros(dim_in(1), dim_in(2), length(FA.frame_idx), type_in);
        end
        
        function runFrame(FA, frame, i)
            b = FA.frame_idx == i;
            if any(b)
                FA.frames(:, :, b) = frame;
            end
        end
        
        function result = getResult(FA)
            result = FA.frames;
        end
    end
    
end

