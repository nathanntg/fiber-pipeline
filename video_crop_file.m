function struct = video_crop_file(struct,  params)
%VIDEO_CROP_FILE Summary of this function goes here
%   Detailed explanation goes here

struct.video = video_crop(struct.video, 'objective', params.objective);

end

