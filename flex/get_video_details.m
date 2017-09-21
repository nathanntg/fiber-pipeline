function video_details = get_video_details(video_file)
%GET_VIDEO_DETAILS Summary of this function goes here
%   Detailed explanation goes here

% find correspond csv file
[path, name, ~] = fileparts(video_file);
data = csvread(fullfile(path, [name '.csv']));

% pull out relevant information
frames = size(data, 1);
depth = data(1, 3);
height = data(1, 4);
width = data(1, 5);
exposure = data(1, 7);

bytes = ceil(depth / 8) * width * height;

% assemble details
video_details = struct(...
    'file', video_file, 'frames', frames, ...
    'exposure', exposure, ...
    'width', width, 'height', height, ...
    'depth', depth, 'bytes', bytes ...
);

end

