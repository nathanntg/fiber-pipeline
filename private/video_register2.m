function [video, shift_x, shift_y] = video_register2(video, reference, show_progress)
%VIDEO_REGISTER2

us = 16;
if 3 ~= ndims(video)
    error('Expecting a grayscale video.');
end

% show progress
if ~exist('show_progress', 'var')
    show_progress = true; % default value
end

% show progress
if show_progress
    h = waitbar(0, 'Registering video...');
end

% convert
if isa(video, 'double') || isa(video, 'single')
    convert = false;
else
    convert = class(video);
end

% reference frame
if ~exist('reference', 'var') || isempty(reference)
    % DEFAULT: middle frame
    reference = round(size(video, 3) / 2);
    ref_frame = video(:, :, round(size(video, 3) / 2));
elseif reference == 0
    % mean
    ref_frame = mean(video, 3);
elseif isscalar(reference)
    ref_frame = video(:, :, reference);
else
    ref_frame = reference;
    reference = -1;
end

% calculate fft of reference frame
if convert
    ref_fft = fft2(single(ref_frame));
else
    ref_fft = fft2(ref_frame);
end

% seed shifts
shift_x = zeros(size(video, 3), 1);
shift_y = zeros(size(video, 3), 1);

for i = 1:size(video, 3)
    % skip reference frame
    if i == reference
        continue;
    end
    
    % skip nan
    if any(any(isnan(video(:, :, i))))
        continue;
    end
    
    % calculate fft
    if convert
        cur_fft = fft2(single(video(:, :, i)));
    else
        cur_fft = fft2(video(:, :, i));
    end
    
    % register
    [out_stats, out_fft] = dftregistration(ref_fft, cur_fft, us);
    
    % inverse fft of registered frame
    if convert
        video(:, :, i) = cast(abs(ifft2(out_fft)), convert);
    else
        video(:, :, i) = abs(ifft2(out_fft));
    end
    
    % get shifts
    shift_x(i) = out_stats(3);
    shift_y(i) = out_stats(4);
    
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
