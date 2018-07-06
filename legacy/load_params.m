function params = load_params(file, max_depth)
%LOAD_PARAMS Summary of this function goes here
%   Detailed explanation goes here

%% PARAMETERS

if ~exist('max_depth', 'var') || isempty(max_depth)
    max_depth = 3;
end

%% RUN

% get directory
[directory, ~, ext] = fileparts(file);
if isempty(ext)
    directory = file;
end

% for each depth
param_files = {};
for i = 1:max_depth
    % make params file
    param_file = fullfile(directory, 'params.m');
    
    % has file?
    if exist(param_file, 'file')
        param_files{end + 1} = param_file;
    end
    
    % move up
    [directory, ~, ~] = fileparts(directory);
end

%% RUN EACH
for i = length(param_files):-1:1
    run(param_files{i});
end

%% CLEAN UP
clear param_files param_file i max_depth directory file ext;
a = who();
params = struct();
for i = 1:length(a)
    v = a{i};
    eval(['params.(v) = ' v ';']);
end

end
