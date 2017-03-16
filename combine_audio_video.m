function combine_audio_video(dir_cxd, prefix_cxd, dir_audio, dir_out, prefix_out)

%% DEFAULTS
if ~exist('prefix_out', 'var')
    prefix_out = '';
end

%% PARAMETERS

% audio threshold
audio_pulse_threshold = 0.1;
audio_pulse_duration = 0.001;
frame_split_gap = 0.1; % allow one dropped frame?
output_mat = true;
output_av = false;

%% CHECKS

% check for existence of files
if ~exist(dir_cxd, 'dir')
    error('CXD directory %s must already exist.', dir_cxd);
end
if ~exist(dir_audio, 'dir')
    error('Audio directory %s must already exist.', dir_audio);
end
if ~exist(dir_out, 'dir')
    error('Output directory %s must already exist.', dir_out);
end

% get files
files_frame = get_files(dir_cxd, [prefix_cxd '*.frame']);
files_audio = get_files(dir_audio, '*.m4a');

% check 
if isempty(files_frame)
    error('No video frames found.');
end
if isempty(files_audio)
    error('No audio files found.');
end

% find csv file
frame_list = csvread(fullfile(dir_cxd, [prefix_cxd 'frames.csv']));

% check length of frame list
if length(files_frame) ~= size(frame_list, 1)
    error('Mismatch between frames (%d) and frame list (%d).', ...
        length(files_frame), size(frame_list, 1));
end

% unpack csv into vectors
frame_binning = frame_list(:, 2);
frame_depth = frame_list(:, 3);
frame_height = frame_list(:, 4);
frame_width = frame_list(:, 5);
frame_time_between = frame_list(:, 6);
frame_exposure = frame_list(:, 7);

% check variables
if any(frame_exposure ~= frame_exposure(1))
    warning('The exposure time changes during acquisition (min: %f ms, max: %f ms).', ...
        min(frame_exposure), max(frame_exposure));
end
if any(frame_height ~= frame_height(1)) || any(frame_width ~= frame_width(1))
    error('The frame size changes during acquisition (min: %d x %d, max: %d x %d).', ...
        min(frame_width), min(frame_height), max(frame_width), max(frame_height));
end
if any(frame_depth ~= frame_depth(1))
    error('The frame depth changes acquisition (min: %d, max: %d).', ...
        min(frame_depth), max(frame_depth));
end

% condense
frame_exposure = frame_exposure(1);
frame_height = frame_height(1);
frame_width = frame_width(1);
frame_depth = frame_depth(1);
switch frame_depth
    case 8
        frame_type = 'uint8';
    case 16
        frame_type = 'uint16';
    otherwise
        error('Unsupported frame depth: %d.', frame_depth);
end

%% LOAD FRAME TIMES FROM AUDIO

% load audio timestamps
audio_fs = [];
audio_timing = cell(length(files_audio), 1);
audio_duration = zeros(length(files_audio), 1);
for i = 1:length(files_audio)
    % load audio
    [y, fs] = audioread(files_audio{i});
    
    % change sample rate
    if isempty(audio_fs)
        audio_fs = fs;
    elseif audio_fs ~= fs
        error('Audio sample rate changed. Previous files are %d, but %s is %d.', audio_fs, files_audio{i}, fs);
    end
    
    % calculate regions of true
    rot = regions_of_true(y(:, 2) > audio_pulse_threshold);
    
    % duration (as check)
    dur = (rot(:, 2) - rot(:, 1)) ./ fs;
    if any(dur < audio_pulse_duration * 0.9) || any(dur > audio_pulse_duration * 1.1)
        warning('File %s has pulse of unexpected duration (min: %f ms, max: %f ms).', files_audio{i}, min(dur) * 1000, max(dur) * 1000);
    end
    
    % read out end times (in samples)
    audio_timing{i} = rot(:, 1);

    % duration
    audio_duration(i) = size(y, 1) / fs;
end

% ignore empty audio
audio_empty = cellfun(@isempty, audio_timing);
if any(audio_empty)
    warning('Some audio contains no frames (%d file(s)) and will be ignored.', sum(audio_empty));
    files_audio = files_audio(~audio_empty);
    audio_timing = audio_timing(~audio_empty);
    audio_duration = audio_duration(~audio_empty);
end

%% SPLIT FRAMES BASED ON INTRINSIC TIMING

% split frames
is_split = frame_time_between > frame_split_gap;
expected_audio = sum(is_split) + 1;
number_seq = sum(is_split) + 1;

% simple expectation for now
if length(audio_timing) == expected_audio
    mapping = 1:expected_audio;
elseif length(audio_timing) > expected_audio
    % print warning
    warning('Intrinsic split points do not match audio files. Expected %d, but found %d. Extracting clear matches by aligning durations and gaps.', ...
        expected_audio, length(audio_timing));
    
    % calculate audio time between
    matches = regexp(files_audio, '([0-9]{4})-([0-9]{2})-([0-9]{2})\s+([0-9]{1,2})\s+([0-9]{1,2})\s([0-9]{1,2})\.m4a', 'tokens');

    % convert match format to vector of numbers
    matches = cellfun(@(x) cellfun(@str2double, x{1}), matches, 'UniformOutput', false);

    % convert to date time
    matches = cellfun(@(x) datetime(x(1), x(2), x(3), x(4), x(5), x(6)), matches, 'UniformOutput', false);

    % concatenate into vector (because cell arrays suck)
    matches = cat(1, matches{:});

    % convert to time between
    audio_time_between = seconds(diff(matches)) - audio_duration(1:(end - 1));
    
    % frame duration
    video_duration = diff([1; find(frame_time_between > frame_split_gap); length(frame_time_between)]) .* median(frame_time_between);
    
    % perform mapping
    mapping = map_audio_and_video(audio_duration, audio_time_between, video_duration, frame_time_between(is_split));
else
    error('Intrinsic split points do not match audio files. Expected %d, but found %d.', ...
        expected_audio, length(audio_timing));
end

% number frames (1 is first recording, 2 is second, etc)
frame_seq = 1 + cumsum(is_split);

%% BEGIN EXTRACTION
nd = 1 + floor(log10(number_seq));
frmt_fn = sprintf('%%s%%0%dd.%s', nd);
for i = 1:number_seq
    % no mapping?
    if isnan(mapping(i))
        continue;
    end
    
    % extraction number i
    cur_frames = (frame_seq == mapping(i));
    
    % timing of camera (from audio) and of frames (from cxd file)
    cur_camera_sample = audio_timing{i};
    cur_camera_timing = cur_camera_sample ./ audio_fs;
    cur_frame_timing = cumsum(frame_time_between(cur_frames)) - frame_time_between(find(cur_frames, 1));
    
    % has dropped frames
    if max(diff(cur_frame_timing)) > 1.1 * max(diff(cur_camera_timing))
        % TODO: eventually turn to warning and recover, by removing
        % offending entries from cur_camera_timing and cur_camera_sample
        error('Frame dropped from sequence %d. Audio timing suggests %f ms, frames have gap of %f ms.', ...
            i, ...
            mean(diff(cur_camera_timing)) * 1000, ...
            max(diff(cur_frame_timing)) * 1000);
    end
    
    % less frames than audio
    if length(cur_frame_timing) < length(cur_camera_timing)
        error('In sequence %d, there are less frames (%d) than expected given audio pulses (%d).', ...
            i, length(cur_frame_timing), length(cur_camera_timing));
    end
    
    number_of_frames = length(cur_camera_timing);
    
    % load audio
    [audio, fs] = audioread(files_audio{i});
    audio = audio(:, 1);
    
    % get frames (dropping extras)
    k = 1;
    video = zeros(frame_height, frame_width, number_of_frames, frame_type);
    for j = find(cur_frames, number_of_frames)'
        % load file
        fh = fopen(files_frame{j}, 'rb');
        im = fread(fh, frame_type);
        fclose(fh);
        
        % add frame
        video(:, :, k) = reshape(im, frame_height, frame_width);
        
        k = k + 1;
    end
    
    if output_av
        % save
        fn = fullfile(dir_out, sprintf(frmt_fn, prefix_out, i, 'mp4'));
        video_write(fn, mat2gray(video), 1 / median(diff(cur_camera_timing)));
        
        % save
        fn = fullfile(dir_out, sprintf(frmt_fn, prefix_out, i, 'm4a'));
        audiowrite(fn, audio, fs);
    end
    
    if output_mat
        % make structure for saving
        s = struct('audio_file', files_audio{i}, ...
            'audio_fs', fs, 'audio', audio, 'video', video, ...
            'video_roe_smp', cur_camera_sample, 'video_roe_tm', cur_camera_timing, ...
            'video_binning', frame_binning(find(cur_frames, number_of_frames)), ...
            'video_exposure', frame_exposure); %#ok<NASGU>

        % save
        fn = fullfile(dir_out, sprintf(frmt_fn, prefix_out, i, 'mat'));
        save(fn, '-v7.3', '-struct', 's');
    end
end

end
