function full_files = get_files_recursive(directory, mask)
%GET_FILES_RECURSIVE

% default to all files
if ~exist('mask', 'var')
    mask = '*';
end

% get all files
files = dir(fullfile(directory, ['**' filesep mask]));

% make full files
full_files = arrayfun(@(x) fullfile(x.folder, x.name), files, 'UniformOutput', false);

% exclude hidden
not_hidden = cellfun(@(x) isempty(regexp(x, '/\.', 'once')), full_files);

% not hidden
full_files = full_files(not_hidden);

end

