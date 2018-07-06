function generate_bs_video(dir_in, dir_out)

%% PARAMETERS

% audio threshold
audio_pulse_threshold = 0.1;
audio_pulse_duration = 0.001;
frame_split_gap = 0.1; % allow one dropped frame?
output_mat = true;
output_av = false;

%% CHECKS

% check for existence of files
if ~exist(dir_in, 'dir')
    error('Directory %s must already exist.', dir_cxd);
end
if ~exist(dir_out, 'dir')
    error('Output directory %s must already exist.', dir_out);
end

% get all mat files
files_mat = get_files(dir_in, '*.mat');

%% RUN

for i = 1:length(files_mat)
    % load data
    data = load(files_mat{i});
    
    % fps
    fps = median(data.audio_fs ./ diff(data.video_roe_smp));
    
    % convert to single
    video = single(data.video);
    
    % register
    video = video_register(video, 1, false);
    
    % background subtract
    video_bs = video_bs(video);
    
    % out
    [~, fn, ~] = fileparts(files_mat{i});
    
    % write video
    video_write(fullfile(dir_out, [fn '.mp4']), video_bs, fps);
end

end
