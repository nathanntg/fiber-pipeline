%% load
[audio, audio_fs, video, video_roe_smp, files] = concatenate_aligned('/Volumes/home/Fiber Scope/LR16/aligned/2017-06-06/', 10);

%% calibrate pixel size
imagesc(video(:, :, 1, 1));

%% calculate std
s = zeros(size(video, 1), size(video, 2), size(video, 4));
for i = 1:size(video, 4)
    s(:, :, i) = nanstd(video(:, :, :, i), 0, 3);
end

%% pixel size
pixel_size = 28;

%% open interface
e = Explorer(video, video_roe_smp, pixel_size);
