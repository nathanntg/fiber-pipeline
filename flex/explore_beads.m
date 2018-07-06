%% process video: step 1, get range
an_neurons = AnalysisPrctile([5 50 95]); % use 95 - 50 / 50 - 5 ratio
an_background = AnalysisPrctile(3); % smoothed, percentile background
an_range = AnalysisRange(); % range for potential circles to extract

reader = connect(...
    ReaderVideo('~/Documents/School/BU/Gardner lab/Fiber/Beads 5/Data15.video'), ...
    ... FilterRegisterSift([], true), ...
    FilterDownsample(2), ...
    FilterSmoothTime(2), ...
    an_neurons, ...
    an_range ...
);

% run
reader.run();

%% range
rng = an_range.getResult();
rng = squeeze(rng(:, :, 2) - rng(:, :, 1));

%% neurons
n = an_neurons.getResult();
d1 = n(:, :, 3) - n(:, :, 2);
d2 = n(:, :, 2) - n(:, :, 1);
neurons = mat2gray(d1 ./ d2, [2 5]);
figure; imagesc(neurons);

%% circles

% find circles
[centers, radii] = imfindcircles(neurons, [8 12],'ObjectPolarity', 'bright', ...
    'Sensitivity', 0.95);

% show circles
figure;
imagesc(neurons);
h = viscircles(centers, radii);

%% extract traces

[reader, an_roi] = connect(...
    ReaderVideo('~/Documents/School/BU/Gardner lab/Fiber/Beads 5/Data15.video'), ...
    ... FilterRegisterSift([], true), ...
    FilterDownsample(2), ...
    FilterSmoothTime(2), ...
    AnalysisRoi(centers, radii ./ 2) ...
);

% run
reader.run();

% results
results_trace = an_roi.getResult();

%% sort by variability
n = 20;
v = var(results_trace, [], 2); % bsxfun(@minus, ts, mean(ts, 1))
[~, is] = sort(v, 'descend');
t = (1:size(results_trace, 2)) * 0.05;

for i = is(1:n)'
    figure;
    subplot(1, 2, 1); imshow(rng); h = viscircles(centers(i, :), radii(i));
    subplot(1, 2, 2); plot(t, results_trace(i, :)); xlim([t(1) t(end)]);
end

%% show all at once
n = 7;
figure;
subplot(1, 2, 1); imshow(imadjust(rng)); h = viscircles(centers(is(1:n), :), radii(is(1:n)));
subplot(1, 2, 2); plot_many(t, results_trace(is(1:n), :)');
