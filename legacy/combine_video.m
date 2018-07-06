function combine_video(dir_cxd, prefix_cxd, file_out)

%% PARAMETERS

% audio threshold
output_mat = true;
output_av = false;

%% CHECKS

% check for existence of files
if ~exist(dir_cxd, 'dir')
    error('CXD directory %s must already exist.', dir_cxd);
end
if exist(file_out, 'file')
    error('Output file %s already exists.', file_out);
end

% get files
files_frame = get_files(dir_cxd, [prefix_cxd '*.frame']);

% check 
if isempty(files_frame)
    error('No video frames found.');
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

%% BEGIN EXTRACTION
number_of_frames = length(files_frame);

% get frames
video = zeros(frame_height, frame_width, number_of_frames, frame_type);
for j = 1:number_of_frames
    % load file
    fh = fopen(files_frame{j}, 'rb');
    im = fread(fh, frame_type);
    fclose(fh);

    % add frame
    video(:, :, j) = reshape(im, frame_height, frame_width);
end
    
if output_av
    % save
    fn = [file_out '.mp4'];
    video_write(fn, mat2gray(video), 1 ./ median(frame_time_between));

    % save
    fn = fullfile(dir_out, sprintf(frmt_fn, prefix_out, i, 'm4a'));
    audiowrite(fn, audio, fs);
end
    
if output_mat
    % make structure for saving
    s = struct('video', video, ...
        'video_time_between', frame_time_between, ...
        'video_exposure', frame_exposure); %#ok<NASGU>

    % save
    save(file_out, '-v7.3', '-struct', 's');
end

end
