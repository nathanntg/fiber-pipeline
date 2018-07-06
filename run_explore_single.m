%% convert to single
downsample = false;
if downsample
    video_s = zeros(size(video, 1) / 2, size(video, 2) / 2, size(video, 3), 'single');
    for i = 1:size(video, 3)
        video_s(:, :, i) = imresize(im2single(video(:, :, i)), 0.5);
    end
else
    video_s = single(video);
end

%% register
video_s = video_register2(video_s, 1, false);

%% open explorerer
diameter = 14;
if downsample
    diameter = diameter / 2;
end
e = ExplorerSingle(video_s, video_time_between, diameter);
