function indices = regions_of_true(binary, min_duration)
%REGIONS_OF_TRUE Summary of this function goes here
%   Detailed explanation goes here

% default minimum duration
if ~exist('min_duration', 'var') || isempty(min_duration)
    min_duration = 1;
end

% based on:
% http://stackoverflow.com/questions/3274043/finding-islands-of-zeros-in-a-sequence

% binary
tsig = ~binary(:);

% calculate differences
dsig = diff([1; tsig; 1]);
index_start = find(dsig < 0);
index_end = find(dsig > 0)-1;
duration = index_end - index_start + 1;

% threshold duration
index_string = (duration >= min_duration);
index_start = index_start(index_string);
index_end = index_end(index_string);

% combine indices
indices = [index_start index_end];

end

