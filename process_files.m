function process_files(directory, cb, name)
%PROCESS_FILES Summary of this function goes here
%   Detailed explanation goes here

% parameters
show_progress = true;

% find all files
files_mat = get_files_recursive(directory, '*.mat');

% show progress
if show_progress
    h = waitbar(0, 'Processing files...');
end

% for each
for i = 1:length(files_mat)
    % update progress
    if show_progress
        waitbar(i / length(files_mat), h);
    end
    
    % load structure
    w = warning('off', 'MATLAB:load:variableNotFound');
    s = load(files_mat{i}, 'processing');
    warning(w);
    
    % already processed?
    if isfield(s, 'processing') && ismember(name, s.processing)
        continue;
    end
    
    % load full file
    s = load(files_mat{i});
    
    % load parameters
    params = load_params(files_mat{i});
    
    % process
    try
        s = cb(s, params);
    catch exc
        fprintf('File %s failed: %s\n', files_mat{i}, exc.message);
        continue
    end
    
    % flag as processed
    if isfield(s, 'processing')
        s.processing{end + 1} = name;
    else
        s.processing = {name};
    end
    
    % save
    save(files_mat{i}, '-v7.3', '-struct', 's');
end

% close progress
if show_progress
    close(h);
end

end
