function mapping = map_audio_and_video(audio_duration, audio_gap, video_duration, video_gap)
%MAP_AUDIO_AND_VIDEO Summary of this function goes here
%   Detailed explanation goes here

debug = true;
num_audio = length(audio_duration);
num_video = length(video_duration);

% 1:1 mapping
if num_audio == num_video
    mapping = 1:num_video;
    return;
end

% valid inputs
if num_audio ~= length(audio_gap) + 1 || num_video ~= length(video_gap) + 1
    error('Expected one more duration than gaps.');
end
if num_audio < num_video
    error('Expected more audio files than video files, since audio splits are unambgious.');
end

% add zero gap
audio_gap = [audio_gap; 0];
video_gap = [video_gap; 0];

% number of missing
num_missing = num_audio - num_video;

% consider different permutations
could_drop = nchoosek(2:num_audio, num_missing);
score = zeros(size(could_drop, 1), 1);

% for each set of potential drops
for i = 1:size(could_drop, 1)
    % list of entries to remove
    cur = could_drop(i, :);
    
    % copy duration and gap
    new_audio_duration = audio_duration;
    new_audio_gap = audio_gap;
    
    % add
    new_audio_duration(cur - 1) = new_audio_duration(cur - 1) + new_audio_duration(cur);
    new_audio_gap(cur - 1) = new_audio_gap(cur - 1) + new_audio_gap(cur);
    
    % drop duration and gap
    new_audio_duration(cur) = [];
    new_audio_gap(cur) = [];
    
    score(i) = mean(([new_audio_duration; new_audio_gap] - [video_duration; video_gap]) .^ 2);
end

% lowest
[v, i] = min(score);
to_drop = could_drop(i, :);

% debugging
if debug
    fprintf('Found exclusion with score: %f.\n', v);
    disp(to_drop);
end

% blank mapping
mapping = nan(num_audio, 1);

% generate mapping
mapping(setdiff(1:num_audio, to_drop)) = 1:num_video;
mapping(to_drop - 1) = nan;

% display for debugging
if debug
    disp(audio_duration);
    disp(video_duration);
    disp(mapping);
end

end
