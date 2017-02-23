function [audio, fs] = audio_load_all(directory, desired_duration)
%AUDIO_LOAD_ALL

% default
if ~exist('desired_duration', 'var')
    desired_duration = [];
end

% get all audio files
all_audio_files = get_files_recursive(directory, '*.m4a');

% for each audio file
fs = [];
audio = [];
for i = 1:length(all_audio_files)
    [cur_audio, cur_fs] = audioread(all_audio_files{i});
    
    % change sample rate
    if isempty(fs)
        fs = cur_fs;
    elseif cur_fs ~= fs
        error('Audio sample rate changed. Previous files are %d, but %s is %d.', fs, all_audio_files{i}, cur_fs);
    end
    
    % append left channel
    audio = [audio; cur_audio(:, 1)];
    
    % sufficient?
    if ~isempty(desired_duration) && length(audio) > desired_duration * fs
        break
    end
end

end
