classdef FilterRegisterDft < Filter
    %FILTERREGISTERDFT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        upsample = 16;
    end
    
    properties (Access=protected)
        ref;
    end
    
    methods
        function frame = processFrame(FF, frame, i)
            % convert from integer
            if ~isa(frame, 'double') && ~isa(frame, 'single')
                frame = single(frame);
            end
            
            if i == 1
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

