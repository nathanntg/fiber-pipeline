classdef FilterRegisterDft < Filter
    %FILTERREGISTERDFT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        upsample = 16;
    end
    
    properties (Access=protected)
        reuse_ref = false;
        ref;
    end
    
    methods
        function FF = FilterRegisterDft(initial_ref)
            FF@Filter();
            
            % seed initial reference frame
            if exist('initial_ref', 'var') && ~isempty(initial_ref)
                if ~isa(initial_ref, 'double') && ~isa(initial_ref, 'single')
                    initial_ref = im2single(initial_ref);
                end
                
                FF.ref = fft2(initial_ref);
                FF.reuse_ref = true;
            end
        end
        
        function frame = processFrame(FF, frame, i)
            % convert from integer
            if ~isa(frame, 'double') && ~isa(frame, 'single')
                frame = im2single(frame);
            end
            
            if i == 1 && ~FF.reuse_ref
                % store reference
                FF.ref = fft2(frame);
                
                return;
            end
    
            % register
            [out_stats, out_fft] = dftregistration(FF.ref, fft2(frame), FF.upsample);

            % inverse fft of registered frame
            frame = abs(ifft2(out_fft));
            
            %shift_x(i) = out_stats(3);
            %shift_y(i) = out_stats(4);
        end
    end
    
end

