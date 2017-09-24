classdef AnalysisPrctile < Analysis
    %ANALYSISPRCTILE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        per;
        
        needed_low = 0;
        needed_hi = 0;
        
        running; % running data
        
        result;
    end
    
    methods
        function FA = AnalysisPrctile(per)
            % call parent constructor
            FA@Analysis();
            
            % number of regions of interest
            FA.per = per;
        end
        
        function setup(FA, video_details, dim_in)
            % call parent setup
            setup@Analysis(FA, video_details, dim_in);
            
            % per low and hi
            per_low = FA.per(FA.per <= 50);
            per_hi = 100 - FA.per(FA.per > 50);
            
            % needed frames low and high
            if isempty(per_low)
                FA.needed_low = 0;
            else
                FA.needed_low = 1 + round(video_details.frames * max(per_low) / 100);
            end
            if isempty(per_hi)
                FA.needed_hi = 0;
            else
                FA.needed_hi = 1 + round(video_details.frames * max(per_hi) / 100);
            end
            
            % check frame count
            if video_details.frames < (1 + FA.needed_low + FA.needed_hi)
                error('Not enough frames.');
            end
        end
        
        function runFrame(FA, frame, i)
            if i == 1
                % setup
                FA.running = repmat(frame, 1, 1, FA.needed_low + FA.needed_hi + 1);
            elseif i <= size(FA.running, 3)
                % insert into position
                FA.running(:, :, i) = frame;
            else
                % sort and insert
                FA.running = sort(FA.running, 3);
                FA.running(:, :, FA.needed_low + 1) = frame;
            end
        end
        
        function teardown(FA, video_details)
            % per low and hi
            idx_low = FA.per <= 50;
            per_low = FA.per(idx_low);
            idx_hi = FA.per > 50;
            per_hi = 100 - FA.per(idx_hi);
            
            % allocate result (must match type)
            FA.result = zeros([size(FA.running, 1) size(FA.running, 2) length(FA.per)], 'like', FA.running);
            
            % final sort
            FA.running = sort(FA.running, 3);
            
            % extract relevant frames
            FA.result(:, :, idx_low) = FA.running(:, :, max(round(video_details.frames * per_low ./ 100), 1));
            FA.result(:, :, idx_hi) = FA.running(:, :, FA.needed_low + FA.needed_hi + 1 - round(video_details.frames * per_hi ./ 100));
        end
        
        
        function result = getResult(FA)
            result = FA.result;
        end
    end
end

