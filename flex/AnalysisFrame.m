classdef AnalysisFrame < Analysis
    %ANALYSISRANGE Summary of this class goes here
    %   Detailed explanation goes here
    
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
        
        function setup(FA, video_details, dim_in)
            % call parent setup
            setup@Analysis(FA, video_details, dim_in);
            
            % correct negative indices
            neg = FA.frame_idx < 0;
            if any(neg)
                FA.frame_idx_abs(neg) = video_details.frames + 1 + FA.frame_idx(neg);
            else
                FA.frame_idx_abs = FA.frame_idx;
            end
        end
        
        function runFrame(FA, frame, i)
            b = FA.frame_idx == i;
            if any(b)
                % initialize
                if isempty(FA.frames)
                    FA.frames = zeros(size(frame, 1), size(frame, 2), length(FA.frame_idx), 'like', frame);
                end
                
                FA.frames(:, :, b) = frame;
            end
        end
        
        function result = getResult(FA)
            result = FA.frames;
        end
    end
    
end

