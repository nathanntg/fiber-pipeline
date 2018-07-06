function mov = video_bs(mov, varargin)
%VIDEO_BS Summary of this function goes here
%   Detailed explanation goes here

% parameters
smooth = 3;
filt_rad = 7; % gauss filter radius
filt_alpha = 3; % gauss filter alpha
per = 10; % baseline percentile (0 for min)
clim = [0.5 0.99]; % color limits for saturation (1st number represents black percentile, 2nd number represents white percentile)

% load custom parameters
nparams=length(varargin);
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

if smooth > 1
    % smooth (use a [1/3 1/3 1/3] convolution along the third dimension)
    mov = video_smooth(single(mov), smooth);
end

% Gaussian filter video
if filt_alpha > 0
    mov = imgaussfilt(mov, filt_alpha, 'FilterSize', filt_rad);
end

% calculate baseline using percentile and repeat over video
baseline = prctile(mov, per, 3);

% calculate dff
%video_dff = bsxfun(@minus, mov .^ 2, baseline .^ 2);
%video_dff = bsxfun(@rdivide, video_dff, baseline);

% calculate bs
mov = bsxfun(@minus, mov, baseline);

% get high and low percentiles
mov = video_adjust(mov, clim);

end

