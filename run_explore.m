function e = run_explore(directory, count, pixel_size)
%RUN_EXPLORE Summary of this function goes here
%   Detailed explanation goes here

% load 50 songs by default
if ~exist('count', 'var')
    count = 50;
end
if ~exist('pixel_size', 'var')
    pixel_size = 28;
end

%% load
% [audio, audio_fs, video, video_roe_smp, files]
[~, ~, video, video_roe_smp, ~] = concatenate_aligned(directory, count);

%% convert format
video = single(video);

% restore nan
to_nan = all(all(video < 1, 1), 2);
video(repmat(to_nan, size(video, 1), size(video, 2), 1, 1)) = nan;
clear to_nan;

%% register
reference = video(:, :, 1);
shift_x = zeros(size(video, 3), size(video, 4));
shift_y = zeros(size(video, 3), size(video, 4));
for i = 1:size(video, 4)
    [video(:, :, :, i), shift_x(:, i), shift_y(:, i)] = video_register2(video(:, :, :, i), reference, false);
end

%% detrend
% mean illumination
illumin = squeeze(mean(mean(video, 1), 2));

% trend
illumin_med = nanmedian(illumin);

% recover
illumin_adj = max(illumin_med) - illumin_med;

% adjusted video
video = bsxfun(@plus, video, reshape(illumin_adj, 1, 1, 1, []));

%% open explorerer
e = Explorer(video, video_roe_smp, pixel_size);

end

