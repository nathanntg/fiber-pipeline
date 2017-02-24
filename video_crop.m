function video = video_crop(video, varargin)

%% PARAMETERS

% objective is used for default width
objective = 4;
radius_range = [];
padding = 75;

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

%% PREP

padding = round(padding);

%% IDENTIFY FIBER

% find fiber
[x1, y1, x2, y2] = video_detect_fiber(video, 'objective', objective, 'radius_range', radius_range);

% add padding
x1 = x1 - padding;
x2 = x2 + padding;
y1 = y1 - padding;
y2 = y2 + padding;

% check dimensions
if x1 < 1 || y1 < 1 || x2 > size(video, 2) || y2 > size(video, 1)
    error('Dimensions to big for video.');
end

%% CROP

video = video(y1:y2, x1:x2, :);

end
