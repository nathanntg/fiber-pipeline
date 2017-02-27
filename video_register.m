function [video, angle] = video_register(video, image, varargin)
%VIDEO_REGISTER Summary of this function goes here
%   Detailed explanation goes here

%% PARAMETERS

tol = [0.01 0.99]; % contrast
show_progress = true;

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

% empty image? use second frame
ref = -1;
if isempty(image)
    image = 2;
end
if isscalar(image)
    ref = image;
    image = video(:, :, image);
end

% adjust image contrast
image = mat2gray(image);
clim = stretchlim(image, tol);
image = imadjust(image, clim, []);

% prep configuration
[optimizer, metric] = imregconfig('monomodal');
optimizer.MaximumIterations = 300;

% prep image ref for sizing
iref = imref2d(size(image));

%% REGISTER

% show progress
if show_progress
    h = waitbar(0, 'Registering video...');
end

% store angles
angle = zeros(1, size(video, 3));

last = [];
for i = 1:size(video, 3)
    % estimate transform
    if i == ref
        last = [];
        continue;
    end
    
    % adjust frame contrast
    frame = mat2gray(video(:, :, i));
    clim = stretchlim(frame, tol);
    frame = imadjust(frame, clim, []);
    
    % transformation
    if isempty(last) || ~last.isRigid()
        tform = imregtform(frame, image, 'rigid', optimizer, metric);
    else
        tform = imregtform(frame, image, 'rigid', optimizer, metric, ...
            'InitialTransformation', last);
    end
    last = tform;
    disp(tform.T);
    
    % calculate angle
    angle(i) = atan2(tform.T(1, 1), tform.T(1, 2));
    
    % transform frame
    video(:, :, i) = imwarp(video(:, :, i), tform, 'OutputView', iref);
    
    % update progress
    if show_progress
        waitbar(i / size(video, 3), h);
    end
end

% close progress
if show_progress
    close(h);
end

end
