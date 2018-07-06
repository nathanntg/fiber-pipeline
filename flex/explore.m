%% process video: step 1, get range
an_range = AnalysisRange();
an_frame = AnalysisFrame(1); % for subsequent registration

reader = connect(...
    ReaderVideo('~/Desktop/mouse4/Data94.video'), ...
    FilterRegisterSift([], true), ...
    an_frame, ...
    an_range ...
);

% run
reader.run();

% results
results_rng = an_range.getResult();
results_frame = an_frame.getResult();

%% get range
rng = mat2gray(results_rng(:, :, 2) - results_rng(:, :, 1));

%% optionally mask?
% make a mask
mask = results_rng(:, :, 1) > 5000;

% dilate
mask = imdilate(mask, ones(5, 5));

% clear range
rng(mask) = 0;

%% find fibers

if size(rng, 1) == 1024
    [centers, radii] = imfindcircles(imresize(rng, 2), [6 10],'ObjectPolarity', 'bright', ...
        'Sensitivity', 0.93);
    
    centers = centers ./ 2;
    radii = radii ./ 2;
else
    % find circles
    [centers, radii] = imfindcircles(rng, [6 10],'ObjectPolarity', 'bright', ...
        'Sensitivity', 0.93);
end

% show circles
figure;
imshow(mat2gray(rng));
h = viscircles(centers,radii);

%% roi extraction
[reader, an_roi] = connect(...
    ReaderVideo('~/Desktop/mouse4/Data94.video'), ...
    FilterRegisterSift([], true), ...
    AnalysisRoi(centers, radii) ...
);

reader.run();
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

%% sort by range
[~, idx] = sort(max(results_trace, [], 2) - min(results_trace, [], 2), 'descend');

% plot traces
plot(results_trace(idx(1:5), :)');
