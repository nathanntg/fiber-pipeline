function video_smooth = video_smooth2(video, space_steps, time_steps)
%VIDEO_SMOOTH Smooths a video over time
%   Smooths neighboring frames in a video based on parameter time steps.
%   Each returned frame will be a running average of time_step frames in
%   the input video. Supports both grayscale and multichannel videos.
%   
%   This function takes advantage of matlab n-dimensional convolution
%   function to use a simple smoothing filter along the time dimension of
%   the video. To avoid zero padding, the first and last frames are
%   repeated.

% make filter
n = space_steps * space_steps * time_steps;
filter = ones(1, n, 'like', video) ./ cast(n, 'like', video);

% amount of padding
pad_space = ceil((space_steps - 1) / 2);
pad_time = ceil((time_steps - 1) / 2);

% handle different video types
if ndims(video) == 4
    % reshape to filter over time
    filter = reshape(filter, space_steps, space_steps, 1, time_steps);
    
    % pad space and/or time
    video = padarray(video, [pad_space, pad_space, 0, pad_time], 'replicate');
    
    % smooth video
    video_smooth = convn(video, filter, 'valid');
elseif ndims(video) == 3
    % reshape to filter over time
    filter = reshape(filter, space_steps, space_steps, time_steps);
    
    % replicate first and last frames
    video = padarray(video, [pad_space, pad_space, pad_time], 'replicate');
    
    % smooth video
    video_smooth = convn(video, filter, 'valid');
else
    error('Invalid number of dimensions (expecting 3 or 4).');
end

end
