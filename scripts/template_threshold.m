% load all audio files
[audio, fs] = audio_load_all('/Volumes/home/Fiber Scope/LR44/raw/');

% write to file for template
audiowrite('~/Desktop/lr44.wav', audio, fs);
fprintf('Find and extract template. Maybe trim if long?\n');
fprintf('Press enter when done.\n');
pause;

% launch threshold calculation
threshold_for_find_audio
