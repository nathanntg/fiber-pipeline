threshold = 7961.16;
[song, nonsong, fs] = match_template('/Volumes/home/Fiber Scope/LR88RBlk29/screen/', 'template', '/Users/nathan/Desktop/template.wav', 'song_threshold', threshold, 'point', 0.9, 'strategy', 'point', 'mask', '*.m4a', 'channel', 1, 'nonsong_threshold', 1.25 * threshold);
