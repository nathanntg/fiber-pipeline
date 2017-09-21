classdef FilterRegisterSift < Filter
    %FILTERREGISTERDFT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    properties (Access=protected)
        reuse_ref = false;
        ref_f;
        ref_d;
        
        use_cache = false;
        cache;
        cache_file = '';
        
        u;
        v;
    end
    
    methods
        function FF = FilterRegisterSift(initial_ref)
            FF@Filter();
            
            % setup SIFT library
            if ~exist('vl_sift', 'file')
                run('~/Development/vlfeat/toolbox/vl_setup');
            end
            
            % seed initial reference frame
            if exist('initial_ref', 'var') && ~isempty(initial_ref)
                if ~isa(initial_ref, 'single')
                    initial_ref = im2single(initial_ref);
                end
                
                % calculate reference SIFT
                [FF.ref_f, FF.ref_d] = vl_sift(initial_ref);
                FF.reuse_ref = true;
            end
        end
        
        function setup(FF, video_details, dim_in)
            if ~isempty(FF.cache_file) && strcmp(FF.cache_file, video_details.file)
                FF.use_cache = true;
            else
                % cache for subsequent pass
                FF.cache = repmat(eye(3), 1, 1, video_details.frames);
                FF.use_cache = false;
                FF.cache_file = video_details.file;
            end
            
            % prepare meshgrid
            [FF.u, FF.v] = meshgrid(1:dim_in(2), 1:dim_in(1));
        end
        
        function frame = processFrame(FF, frame, i)
            % convert from integer
            if ~isa(frame, 'single')
                frame_s = im2single(frame);
            end
            
            if FF.use_cache
                % cached registration
                H = FF.cache(:, :, i);
            else
                % calculate sift
                [cur_f, cur_d] = vl_sift(frame_s);

                % use as reference?
                if i == 1 && ~FF.reuse_ref
                    % store reference
                    FF.ref_f = cur_f;
                    FF.ref_d = cur_d;
                    
                    % leave H alone
                    H = eye(3);
                else
                    % register
                    H = sift_regp(FF.ref_f, FF.ref_d, cur_f, cur_d);
                end
                
                % save in cache
                FF.cache(:, :, i) = H;
            end
            
            % shift image
            z_ = H(3, 1) * FF.u + H(3, 2) * FF.v + H(3, 3);
            u_ = (H(1, 1) * FF.u + H(1, 2) * FF.v + H(1, 3)) ./ z_;
            v_ = (H(2, 1) * FF.u + H(2, 2) * FF.v + H(2, 3)) ./ z_;
            
            % convert to double
            if ~isa(frame, 'double')
                frame = im2double(frame);
            end
            
            frame = vl_imwbackward(frame, u_, v_);
        end
    end
    
end
