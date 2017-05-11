function match_template(directory, varargin)
%MATCH_TEMPLATE Summary of this function goes here
%   Detailed explanation goes here

%% SETUP

% defaults
template = fullfile(directory, 'template.wav');
extracted_dir = fullfile(directory, 'synced');
aligned_dir = fullfile(directory, 'aligned');
strategy = 'center'; % exact, start, end, warp, center, point
point = 0.1; % if strategy is point, then this acts as the match point
padding = [0 0.2];
threshold = []; % hard coded for consistency
motif_between = 0.1;
show_progress = true;
replace = false;
debug = false;

% load defaults from configuration
params = load_params(directory);
flds = fieldnames(params);
for i = 1:length(flds)
    if exist(flds{i}, 'var') && ~strcmp(flds{i}, 'flds') && ~strcmp(flds{i}, 'i') && ~strcmp(flds{i}, 'params')
        eval([flds{i} ' = params.(flds{i});']);
    end
end

% load custom parameters
nparams = length(varargin);
if 0 < mod(nparams, 2)
	error('Parameters must be specified as parameter/value pairs');
end
for i = 1:2:nparams
    nm = lower(varargin{i});
    if ~exist(nm, 'var')
        error('Invalid parameter: %s.', nm);
    end
    eval([nm ' = varargin{i+1};']);
end

%% RUN
files = get_files_recursive(extracted_dir, '*.mat');

% get template
[~, ~, ext] = fileparts(template);
if strcmp(ext, '.wav')
    [template_audio, template_fs] = audioread(template);
    
    % resample
    tmp = load(files{1});
    if round(tmp.audio_fs) ~= template_fs
        warning('Resampling template to match first file.');
        template_audio = resample(template_audio, round(tmp.audio_fs), template_fs);
        template_fs = round(tmp.audio_fs);
    end
else
    error('Invalid file extension for template.');
end

% make aligned directory
if ~exist(aligned_dir, 'dir')
    mkdir(aligned_dir);
end

% prepare padding
if isscalar(padding)
    padding = padding * [1 1];
end
padding = round(padding * template_fs);

% empty
if isempty(threshold)
    warning('No threshold provided.');
end

% show progress
if show_progress
    h = waitbar(0, 'Matching template...');
end

desired_len = length(template_audio);
for i = 1:length(files)
    % relative path to file
    if ~strcmp(files{i}(1:length(extracted_dir)), extracted_dir)
        warning('Aborting, relative path mismatch.');
        break;
    end
    file_rel = files{i}((length(extracted_dir) + 1):end);
    
    % only replace if explicitly specified (will still reprocess files with
    % no song)
    [o_dir, o_name, ~] = fileparts(file_rel);
    if ~replace && exist(fullfile(aligned_dir, o_dir, [o_name '_1.mat']), 'file')
        if show_progress
            waitbar(i / length(files));
        end
        continue;
    end
    
    % load data
    ext_data = load(files{i});
    
    % mismatch frame rate
    if template_fs ~= round(ext_data.audio_fs)
        warning('Skipping %s because of frame rate mismatch.', files{i});
        continue;
    end
    
    % match against template
    [orig_starts, orig_ends, scores] = find_audio(ext_data.audio, template_audio, template_fs, ...
        'threshold_score', threshold);

    % convert times 
    orig_starts = round(orig_starts * template_fs);
    orig_ends = round(orig_ends * template_fs);
    
    % debug
    if debug
        fprintf('File: %s Matches: %d\n', o_name, length(orig_starts));
    end
    
    % normalize (always extract exact duration)
    switch strategy
        case 'exact'
            % nothing required (results in different file lengths)
            starts = orig_starts;
            ends = orig_ends;
        case 'center'
            lens = 1 + orig_ends - orig_starts;
            diffs = (desired_len - lens) / 2;
            starts = orig_starts - ceil(diffs);
            ends = orig_ends + floor(diffs);
        case {'start', 'ttl_start'}
            lens = 1 + orig_ends - orig_starts;
            diffs = desired_len - lens;
            starts = orig_starts;
            ends = orig_ends + diffs;
        case 'end'
            lens = 1 + orig_ends - orig_starts;
            diffs = desired_len - lens;
            starts = orig_starts - diffs;
            ends = orig_ends;
        case {'point'}
            starts = orig_starts;
            for j = 1:length(orig_starts)
                warped_time = warp_audio(ext_data.audio(orig_starts(j):orig_ends(j)), template_audio, template_fs, []);
                [~, idx] = min(abs(warped_time(1, :) - point));
                starts(j) = starts(j) + round(template_fs * (warped_time(2, idx) - warped_time(1, idx)));
            end
            ends = starts + desired_len - 1;
        case 'warp'
            % actual warping happens below
            starts = orig_starts;
            ends = orig_ends;
        otherwise
            error('Undefined matching strategy.');
    end
    
    % add padding
    starts = starts - padding(1);
    ends = ends + padding(2);
    
    % do extraction
    motif = 0;
    for j = 1:length(starts)
        % is same motif
        if j > 1 && (orig_ends(j - 1) + (motif_between * template_fs)) >= orig_starts(j)
            motif = motif + 1;
        else
            motif = 1;
        end
        
        % indices
        cur_start = starts(j);
        cur_end = ends(j);
        
        % figure out padding
        if cur_start < 1
            pad_front = nan(1 - cur_start, 1);
            cur_start = 1;
        else
            pad_front = [];
        end
        if cur_end > length(ext_data.audio)
            pad_back = nan(cur_end - length(ext_data.audio), 1);
            cur_end = length(ext_data.audio);
        else
            pad_back = [];
        end
        
        % video indices
        cur_video_idx = ext_data.video_roe_smp >= cur_start & ext_data.video_roe_smp <= cur_end;
        
        % extract details
        extra = struct('strategy', strategy);
        
        % extract data
        % data to store
        cur_audio = [pad_front; ext_data.audio(cur_start:cur_end); pad_back];
        cur_video = ext_data.video(:, :, cur_video_idx);

        % make structure
        data = struct(...
            'audio_fs', ext_data.audio_fs, ...
            'audio', cur_audio, ...
            'video', cur_video, ...
            'video_exposure', ext_data.video_exposure, ...
            'video_roe_smp', ext_data.video_roe_smp(cur_video_idx) - cur_start + 1 + length(pad_front), ...
            'file', files{i}, 'indices', [cur_start cur_end], ...
            'extra', extra, ...
            'match', j, 'motif', motif, 'score', scores(j));
        
        % name
        name = sprintf('%s_%d', o_name, j);
        
        % make directory
        if ~exist(fullfile(aligned_dir, o_dir), 'dir')
            mkdir(aligned_dir, o_dir);
        end
        
        % save data
        save(fullfile(aligned_dir, o_dir, [name '.mat']), '-v7.3', '-struct', 'data');
        
        % save gif
        [im, ~, ~] = zftftb_pretty_sonogram(ext_data.audio(cur_start:cur_end), template_fs, ...
            'len', 16.7, 'overlap', 14, 'zeropad', 0, 'filtering',500, 'clipping', [-2 2], 'norm_amp', 1);
        im = im .* 62;
		im = flip(im, 1);
        imwrite(uint8(im), colormap('hot(63)'), fullfile(aligned_dir, o_dir, [name '.gif']), 'gif');
    end
    
    % update progress
    if show_progress
        waitbar(i / length(files));
    end
end

% close progress
if show_progress
    close(h);
end

end

