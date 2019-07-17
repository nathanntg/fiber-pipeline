classdef Reader < Node
    %READER Basic reader node
    %   A reader node only has outputs and is used to run the flex
    %   framework network. Subclasses must define functions for getting
    %   video details (getVideoDetails) and for reading the next frame.
    
    properties
        video_details;
        dim_out;
        type_out;
    end
    
    methods
        function FR = Reader()
            FR@Node();
        end
        
        function run(FR)
            % get video details
            [FR.video_details, FR.dim_out, FR.type_out] = FR.getVideoDetails();
            
            % call setup
            FR.setup(FR.video_details, FR.dim_out, FR.type_out);
            
            % for each frame
            for i = 1:FR.dim_out(end)
                FR.runFrame([], i);
            end

            % tear down
            FR.teardown(FR.video_details);
        end
        
        function setup(FR, video_details, dim_in, type_in)
            % call parent (setup sub-nodes)
            setup@Node(FR, video_details, dim_in, type_in);
        end
        
        function runFrame(FR, ~, i)
            % get frame
            [i2, frame] = FR.readNextFrame();
        
            % test loading order
            if i2 ~= i
                error('Expected frame %d, but got frame %d.', i, i2);
            end
            
            % push to outputs
            for j = 1:length(FR.outputs)
                FR.outputs{j}.runFrame(frame, i);
            end
        end
    end
    
    methods (Abstract)
        [details, dim_out, type_out] = getVideoDetails(FR);
        [i, frame] = readNextFrame(FR);
    end
end
