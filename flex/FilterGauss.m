classdef FilterGauss < Filter
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sigma;
        radius;
    end
    
    methods
        function FF = FilterGauss(sigma, radius)
            FF@Filter();
            
            FF.sigma = sigma;
            if exist('radius', 'var') && ~isempty(radius)
                FF.radius = radius;
            else
                FF.radius = [];
            end
        end
        
        function frame = processFrame(FF, frame, i)
            if isempty(FF.radius)
                frame = imgaussfilt(frame, FF.sigma);
            else
                frame = imgaussfilt(frame, FF.sigma, 'FilterSize', FF.radius);
            end
        end
    end
    
end

