classdef FilterRegisterMatlab < Filter
    %FILTERREGISTERMATLAB Motion correction using MATLAB imregister method
    %   Pass either an initial reference image to be used for registration,
    %   or the first frame will be used for registration.
    
    properties (Access=protected)
        opt;
        metric;
        
        reuse_ref = false;
        ref;
    end
    
    methods
        function FF = FilterRegisterMatlab(initial_ref)
            FF@Filter();
            
            % seed initial reference frame
            if exist('initial_ref', 'var') && ~isempty(initial_ref)
                if ~isa(initial_ref, 'double') && ~isa(initial_ref, 'single')
                    initial_ref = single(initial_ref);
                end
                
                FF.ref = fft2(initial_ref);
                FF.reuse_ref = true;
            end
        end
        
        function setup(FF, video_details, dim_in)
            % configure matlab registration
            [FF.opt, FF.metric] = imregconfig('monomodal');
            FF.opt.MaximumIterations = 300;
        end
        
        function frame = processFrame(FF, frame, i)
            if i == 1 && ~FF.reuse_ref
                % store reference
                FF.ref = frame;
                
                return;
            end
            
            % do registration
            frame = imregister(frame, FF.ref, 'affine', FF.opt, FF.metric);
        end
    end
    
end

