function [x1, y1, x2, y2] = video_detect_fiber(video, varargin)
%VIDEO_DETECT_FIBER Summary of this function goes here
%   Detailed explanation goes here

%% PARAMETERS

% objective is used for default width
objective = 4;
radius_range = [];
gauss_filter = 2;
frame_number = 1;
debug = false;

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

% default radius range
if isempty(radius_range)
    switch objective
        case 4
            % 450 550
            radius_range = [450 648] ./ 2;
            
        case 10
            % 450 550
            radius_range = [1002 1200] ./ 2;
            
        otherwise
            error('Uncalibrated objective: %d.', objective);
    end
end

% get first frame
frame = mat2gray(imgaussfilt(video(:, :, frame_number), gauss_filter));

%% ATTEMPT 1: circle detection

[centers, radii] = imfindcircles(frame, radius_range, 'ObjectPolarity', 'bright', 'Sensitivity', 0.98);

% debugging, show fiber
if debug
    figure;
    imagesc(frame);
    viscircles(centers, radii);
end

% found just one circle?
if length(radii) == 1
    c = round(centers);
    r = round(radii);
    
    x1 = c(1) - r;
    y1 = c(2) - r;
    x2 = c(1) + r;
    y2 = c(2) + r;
    return;
end

%% GIVE UP

error('Unable to detect fiber in video.');


end

