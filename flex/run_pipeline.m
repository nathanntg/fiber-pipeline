function analysis_results = run_pipeline(video_details, filters, analysis)
%RUN_PIPELINE Summary of this function goes here
%   Detailed explanation goes here

%% PREP
if ischar(video_details)
    video_details = get_video_details(video_details);
end

if ~iscell(filters)
    if isempty(filters)
        filters = {};
    else
        filters = {filters};
    end
end
if ~iscell(analysis)
    analysis = {analysis};
    from_cell = true;
else
    from_cell = false;
end

%% PREPARE RETURN
% setup filters
cur_dim = [video_details.height video_details.width];
for i = 1:length(filters)
    filters{i}.setup(video_details, cur_dim); % setup
    cur_dim = filters{i}.getDimensions(cur_dim); % update dimensions
end

for i = 1:length(analysis)
    analysis{i}.setup(video_details, cur_dim); % setup
end

%% FIND FILE
fh = fopen(video_details.file, 'r');
if fh < 0
    error('Unable to open video file: %s.', video_details.file);
end

%% PROCESS
for i = 1:video_details.frames
    % read frame
    frame = fread(fh, ...
        [video_details.height video_details.width], ...
        sprintf('*uint%d', 8 * ceil(video_details.depth / 8)));
    
    % filter frame
    for j = 1:length(filters)
        frame = filters{j}.processFrame(frame, i);
    end
    
    % analyze frame
    for j = 1:length(analysis)
        analysis{j}.processFrame(frame, i);
    end
end

%% CLEAN UP
for i = 1:length(filters)
    filters{i}.teardown(video_details);
end

analysis_results = cell(1, length(analysis));
for i = 1:length(analysis)
    analysis_results{i} = analysis{i}.finalize(video_details);
end

if from_cell
    analysis_results = analysis_results{1};
end

end
