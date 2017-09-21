classdef FilterRegisterMatlab < Filter
    %FILTERREGISTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        opt;
        metric;
        
        ref;
    end
    
    methods
        function frame = processFrame(FF, frame, i)
            if i == 1
                % store reference
                FF.ref = frame;
                    
                % configure matlab registration
                [FF.opt, FF.metric] = imregconfig('monomodal');
                FF.opt.MaximumIterations = 300;
                
                return;
            end
            
            % do registration
            frame = imregister(frame, FF.ref, 'affine', FF.opt, FF.metric);
        end
    end
    
end

