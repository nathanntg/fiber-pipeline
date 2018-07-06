classdef FilterRegisterSift < Filter
    %FILTERREGISTERSIFT Motion correction using SIFT method
    %   Pass either an initial reference image to be used for registration,
    %   or the first frame will be used for registration. Requires the
    %   VLFeat library (http://www.vlfeat.org/). Has the ability to cache
    %   the transform matrices for faster reapplication of the motion
    %   correction. Pass `true` for cache_storage to automatically store
    %   the correciton in a file in the same folder as the video, or pass
    %   the path to another file to use for storage.
    
    properties
    end
    
    properties (Access=protected)
        reuse_ref = false;
        ref_f;
        ref_d;
        
        use_cache = false;
        cache;
        cache_file = '';
        cache_storage;
        
        u;
        v;
    end
    
    methods
        function FF = FilterRegisterSift(initial_ref, cache_storage)
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
            
            % cache storage
            if exist('cache_storage', 'var') && ~isempty(cache_storage)
                FF.cache_storage = cache_storage;
            end
        end
        
        function type_out = getType(FF, type_in)
            type_out = 'double';
        end
        
        function setup(FF, video_details, dim_in, type_in)
            % call parent
            setup@Filter(FF, video_details, dim_in, type_in);
            
            % has cache storage
            if ~isempty(FF.cache_storage)
                if islogical(FF.cache_storage)
                    [path, nm, ~] = fileparts(video_details.file);
                    cur_cache_storage = fullfile(path, [nm '.cache-sift.mat']);
                else
                    cur_cache_storage = FF.cache_storage;
                end
                
                % file exists
                if exist(cur_cache_storage, 'file')
                    cur_cache = load(cur_cache_storage);
                    if cur_cache.version == 1
                        FF.cache_file = cur_cache.cache_file;
                        FF.cache = cur_cache.cache;
                    end
                end
            end
            
            if ~isempty(FF.cache_file) && strcmp(FF.cache_file, video_details.file)
                FF.use_cache = true;
            else
                % cache for subsequent pass
                FF.cache = repmat(eye(3), 1, 1, dim_in(end));
                FF.use_cache = false;
                FF.cache_file = video_details.file;
            end
            
            % prepare meshgrid
            [FF.u, FF.v] = meshgrid(1:dim_in(2), 1:dim_in(1));
        end
        
        function teardown(FF, video_details)
            % has cache storage
            if ~isempty(FF.cache_storage) && FF.use_cache
                if islogical(FF.cache_storage)
                    [path, nm, ~] = fileparts(video_details.file);
                    cur_cache_storage = fullfile(path, [nm '.cache-sift.mat']);
                else
                    cur_cache_storage = FF.cache_storage;
                end
                
                % save cache
                s = struct('version', 1, 'cache_file', FF.cache_file, 'cache', FF.cache); %#ok<NASGU>
                save(cur_cache_storage, '-struct', 's');
            end
            
            % call parent
            teardown@Filter(FF, video_details);
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
