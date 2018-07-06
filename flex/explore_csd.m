%% process video: step 1, get range
an_range = AnalysisRange();
an_ptile = AnalysisPrctile([1 99]); % percentile (less drastic than range)

reader = connect(...
    ReaderVideo('~/Desktop/Data97.video'), ...
    FilterRegisterSift([], true), ...
    FilterSmoothTime(2), ...
    an_range, ...
    an_ptile ...
);

% run
reader.run();

%% potentials

n = an_ptile.getResult();
fibers = mat2gray(n(:, :, 2) - n(:, :, 1));
figure; imagesc(fibers);

%% circles

% find circles
if size(fibers, 1) == 1024
    [centers, radii] = imfindcircles(imresize(fibers, 2), [8 12],'ObjectPolarity', 'bright', ...
        'Sensitivity', 0.93);
    
    centers = centers ./ 2;
    radii = radii ./ 2;
else
    [centers, radii] = imfindcircles(fibers, [8 12],'ObjectPolarity', 'bright', ...
        'Sensitivity', 0.93);
end

% show circles
figure;
imagesc(fibers);
h = viscircles(centers, radii);

%% extract traces

[reader, an_roi] = connect(...
    ReaderVideo('~/Desktop/Data97.video'), ...
    FilterRegisterSift([], true), ...
    AnalysisRoi(centers, radii * 0.75) ...
);

% run
reader.run();

% results
results_trace_med = an_roi.getResult();

%% sort by variability
% read csv
data = csvread('Data97.csv');

% times
tm = cumsum(data(:, 6));

% get brightest treaces
brightest = max(results_trace, [], 2) - median(results_trace, 2);
[~, idx] = sort(brightest, 'descend');

% plot
n = 20;
figure;
plot(tm, 65535 .* results_trace(idx(1:n), :)');
xlabel('Time [s]');
ylabel('Intensity');

% plot many
n = 20;
figure;
plot_many(tm, 65535 .* results_trace(idx(1:n), :)');
xlabel('Time [s]');
ylabel('Intensity');

%% read for video

[reader, writer] = connect(...
    ReaderVideo('~/Desktop/Data97.video', 3400, 6500 - 3400), ...
    FilterRegisterSift(), ...
    FilterSmoothTime(2), ...
    WriterVariable() ...
);

reader.run();
video = writer.getResult();

bg = prctile(video, 10, 3);
video2 = bsxfun(@minus, video, bg);D
video2(video2 < 0) = 0;
sc = prctile(video2(:), 98);
video2 = video2 ./ sc;
video2(video2 > 1) = 1;
video_write('~/Desktop/Data97.mp4', video2, 20);


%% read before CSD

[reader, writer] = connect(...
    ReaderVideo('~/Desktop/Data97.video', 100, 3300), ...
    FilterRegisterSift(), ...
    FilterSmoothTime(2), ...
    WriterVariable() ...
);

reader.run();
video = writer.getResult();


bg = prctile(video, 10, 3);
video2 = bsxfun(@minus, video, bg);
video2(video2 < 0) = 0;
sc = prctile(video2(:), 95);
video2 = video2 ./ sc;
video2(video2 > 1) = 1;
video_write('~/Desktop/Data97pre.mp4', video2, 20);

