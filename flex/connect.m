function [reader, last] = connect(varargin)
%CONNECT Summary of this function goes here
%   Detailed explanation goes here

num = length(varargin);

if num < 2
    error('Must specify two or more nodes.');
end

reader = varargin{1};
last = varargin{num};

prev = varargin{1};
for i = 2:num
    prev.addOutput(varargin{i});
    if isa(varargin{i}, 'Filter')
        prev = varargin{i};
    end
end

end

