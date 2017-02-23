function full_files = get_files(directory, mask)
%GET_FILES Get a list of files by directory matching mask

% default to all files
if ~exist('mask', 'var')
    mask = '*';
end

% get all files
files = dir(fullfile(directory, mask));

% make full files
full_files = cellfun(@(x) fullfile(directory, x), {files(:).name}, 'UniformOutput', false);

end
