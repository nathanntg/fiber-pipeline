classdef AnalysisPrctile < Analysis
    %ANALYSISPRCTILE Extract percentile intensity for each pixel
    %   The further from the extremes (0 and 100), the more data that needs
    %   to be kept in memory. This is a processor intensive analysis node,
    %   as it must continually sort intensities to discard unneeded data.
    
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
        
        function setup(FA, video_details, dim_in, type_in)
            % call parent setup
            setup@Analysis(FA, video_details, dim_in, type_in);
            
            % per low and hi
            per_low = FA.per(FA.per <= 50);
            per_hi = 100 - FA.per(FA.per > 50);
            
            % needed frames low and high
            if isempty(per_low)
                FA.needed_low = 0;
            else
                FA.needed_low = 1 + round(dim_in(end) * max(per_low) / 100);
            end
            if isempty(per_hi)
                FA.needed_hi = 0;
            else
                FA.needed_hi = 1 + round(dim_in(end) * max(per_hi) / 100);
            end
            
            % check frame count
            if dim_in(end) < (1 + FA.needed_low + FA.needed_hi)
                error('Not enough frames.');
            end
            
            % allocate running
            FA.running = zeros(dim_in(1), dim_in(2), FA.needed_low + FA.needed_hi + 1, type_in);
        end
        
        function runFrame(FA, frame, i)
            if i <= size(FA.running, 3)
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
            FA.result = zeros(FA.dim_in(1), FA.dim_in(2), length(FA.per), 'like', FA.running);
            
            % final sort
            FA.running = sort(FA.running, 3);
            
            % extract relevant frames
            FA.result(:, :, idx_low) = FA.running(:, :, max(round(FA.dim_in(end) * per_low ./ 100), 1));
            FA.result(:, :, idx_hi) = FA.running(:, :, FA.needed_low + FA.needed_hi + 1 - round(FA.dim_in(end) * per_hi ./ 100));
        end
        
        
        function result = getResult(FA)
            result = FA.result;
        end
    end
end

