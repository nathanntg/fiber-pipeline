%% load file
load('/Users/nathan/Desktop/2017-05-09b.mat');


%% improve alignment (adjust rotate frames)

% get exposure time in samples
video_exp_smp = nanmedian(reshape(diff(video_roe_smp), [], 1));

% start frame
video_start_frame = 1 + round((video_roe_smp(1, :) - 1) ./ video_exp_smp);

% todo: finish me

%% convert to single
video = single(video);

% restore nan
to_nan = all(all(video < 1, 1), 2);
video(repmat(to_nan, size(video, 1), size(video, 2), 1, 1)) = nan;
clear to_nan;

%% examine registration
figure;
imagesc(std(video(:, :, 1, :), [], 4));
title('First frame across videos');

figure;
imagesc(nanstd(video(:, :, :, 1), [], 3));
title('First video across frames');

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
video_adj = bsxfun(@plus, video, reshape(illumin_adj, 1, 1, 1, []));

%% average together frames

% mean
video_mn = nanmean(video_adj, 4);


%% background subtraction

video_bs = bsxfun(@minus, video_adj, nanmean(video_adj, 3));

mx = quantile(video_bs(:), [0.5 0.75 0.95 0.99]);
video_write('~/Desktop/test.mp4', mat2gray(nanmean(video_bs, 4), double(mx([1 end]))));




