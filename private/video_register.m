function video = video_register(video, reference, show_progress)
%VIDEO_REGISTER

if 3 ~= ndims(video)
    error('Expecting a grayscale video.');
end

% show progress
if ~exist('show_progress', 'var')
    show_progress = true; % default value
end

[opt, met] = imregconfig('monomodal');
opt.MaximumIterations = 300;

% show progress
if show_progress
    h = waitbar(0, 'Registering video...');
end

% reference frame
if ~exist('reference', 'var') || isempty(reference)
    % DEFAULT: middle frame
    reference = -1;
    ref_frame = video(:, :, round(size(video, 3) / 2));
elseif reference == 0
    % mean
    ref_frame = mean(video, 3);
else
    ref_frame = video(:, :, reference);
end
    

for i = 1:size(video, 3)
    if i ~= reference
        video(:, :, i) = imregister(video(:, :, i), ref_frame, 'affine', opt, met);
    end
    
    % update progress
    if show_progress
        waitbar(i / size(video, 3));
    end
end

% close progress
if show_progress
    close(h);
end

end

