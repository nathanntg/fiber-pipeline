%% process video: step 1, get range
an_neurons = AnalysisPrctile([5 50 95]); % use 95 - 50 / 50 - 5 ratio
an_background = AnalysisPrctile(3); % smoothed, percentile background
an_range = AnalysisRange(); % range for potential circles to extract

reader = connect(...
    ReaderVideo('~/Desktop/mouse3/Data84.video'), ...
    FilterRegisterSift([], true), ...
    FilterDownsample(2), ...
    FilterSmoothTime(3), ...
    an_neurons, ...
    an_range, ...
    FilterGauss(3, 7), ...
    an_background ...
);

% run
reader.run();

%% get background

background = an_background.getResult();

%% range

r = an_range.getResult();
rng = r(:, :, 2) - r(:, :, 1);
figure; imagesc(rng);

%% neurons

n = an_neurons.getResult();
d1 = n(:, :, 3) - n(:, :, 2);
d2 = n(:, :, 2) - n(:, :, 1);
neurons = mat2gray(d1 ./ d2, [2 5]);
figure; imagesc(neurons);

%% mask

mask = imdilate(n(:, :, 1) > im2double(uint16(5000)), ones(5, 5));
figure; imagesc(mask);

neurons(mask) = 0;

%% circles

if size(neurons, 1) == 1024
    [centers, radii] = imfindcircles(imresize(neurons, 2), [8 12],'ObjectPolarity', 'bright', ...
        'Sensitivity', 0.95);
    
    centers = centers ./ 2;
    radii = radii ./ 2;
else
    % find circles
    [centers, radii] = imfindcircles(neurons, [8 12],'ObjectPolarity', 'bright', ...
        'Sensitivity', 0.95);
end

% show circles
figure;
imagesc(neurons);
h = viscircles(centers, radii);

%% extract traces

[reader, an_roi] = connect(...
    ReaderVideo('/Volumes/home/Fiber Scope/mouse5/Data97.video'), ...
    FilterRegisterSift([], true), ...
    FilterSmoothTime(2), ...
    AnalysisRoi(centers, radii) ...
);

% run
reader.run();

% results
results_trace = an_roi.getResult();

%% background subtraction
[reader, writer] = connect(...
    ReaderVideo('~/Desktop/mouse3/Data83.video'), ...
    FilterRegisterSift([], true), ...
    FilterDownsample(2), ...
    FilterSmoothTime(3), ...
    WriterVariable() ...
);

reader.run();
video = writer.getResult();

clear reader writer;
