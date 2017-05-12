function [audio, audio_fs, video, video_roe_smp, files] = concatenate_aligned(directory)
%CONCATENATE_ALIGNED Summary of this function goes here
%   Detailed explanation goes here

% get all mat files
files = get_files_recursive(directory, '*.mat');

audio = [];
audio_fs = [];
video = [];
video_roe_smp = [];

for i = 1:length(files)
    data = load(files{i});
    
    % audio
    audio = cat(2, audio, data.audio);
    
    % audio_fs
    if isempty(audio_fs)
        audio_fs = data.audio_fs;
    elseif audio_fs ~= data.audio_fs
        warning('Mismatched audio sample rate.');
    end
    
    % video
    if isempty(video)
        video = data.video;
        video_roe_smp = data.video_roe_smp;
    elseif size(video, 3) < size(data.video, 3)
        % append nan
        num = size(data.video, 3) - size(video, 3);
        
        video = cat(3, video, nan(size(video, 1), size(video, 2), num, size(video, 4)));
        video = cat(4, video, data.video);
        
        video_roe_smp = cat(1, video_roe_smp, nan(num, size(video_roe_smp, 2)));
        video_roe_smp = cat(2, video_roe_smp, data.video_roe_smp);
    elseif size(data.video, 3) < size(video, 3)
        % append nan
        num = size(video, 3) - size(data.video, 3);
        
        data.video = cat(3, data.video, nan(size(data.video, 1), size(data.video, 2), num));
        video = cat(4, video, data.video);
        
        data.video_roe_smp = cat(1, data.video_roe_smp, nan(num, 1));
        video_roe_smp = cat(2, video_roe_smp, data.video_roe_smp);
    else
        video = cat(4, video, data.video);
        video_roe_smp = cat(2, video_roe_smp, data.video_roe_smp);
    end
end

end

