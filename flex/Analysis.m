classdef Analysis < handle
    %ANALYSIS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function FA = Analysis()
        end
        
        function setup(FA, video_details, dim_in)
        end
        
        function result = finalize(FA, video_details)
        end
    end
    
    methods (Abstract)
        processFrame(FA, frame, i);
    end
    
end

