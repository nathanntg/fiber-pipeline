%% process video: step 1, get range
an_range = AnalysisRange();
an_video = WriterVariable();

reader = connect(...
    ReaderVideo('~/Desktop/Data72.video'), ...
    FilterRegisterSift([], true), ...
    FilterDownsample(2), ...
    FilterSmoothTime(2), ...
    FilterConvertSingle(), ...
    an_video, ...
    an_range ...
);

% run
reader.run();

video = an_video.getResult();
whos
%% potentials

n = prctile(video, [5 50 95], 3);
d1 = n(:, :, 3) - n(:, :, 2);
d2 = n(:, :, 2) - n(:, :, 1);
fibers = mat2gray(d1 ./ d2, [1 5]);
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
    ReaderVariable(video), ...
    AnalysisRoi(centers, radii .* .75) ...
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
    subplot(1, 2, 1); imshow(fibers); h = viscircles(centers(i, :), radii(i));
    subplot(1, 2, 2); plot(t, results_trace(i, :)); xlim([t(1) t(end)]);
end

%% show all at once
n = 7;
figure;
subplot(1, 2, 1); imshow(imadjust(rng)); h = viscircles(centers(is(1:n), :), radii(is(1:n)));
subplot(1, 2, 2); plot_many(t, results_trace(is(1:n), :)');

%% make paper figure
set(0, 'DefaultAxesLineWidth', 2);
set(0, 'DefaultLineLineWidth', 4);
set(0, 'DefaultAxesFontSize', 24);

figure;
colors = lines(n);
subplot(1, 3, [1 2]);
imshow(imadjust(rng));
xticks([]); yticks([]); axis square;
xlim([512 1024]); ylim([512 1024]);
for i = 1:n
    viscircles(centers(is(i), :), radii(is(i)) + 4, 'Color', colors(i, :), 'EnhanceVisibility', false, 'LineWidth', 4);
end
subplot(1, 3, 3);
plot_many(t, results_trace(is(1:n), :)');
xlim([0 t(end)]); xticks([0 t(end) / 2 t(end)]);
xlabel('Time [s]');

r = get(gcf, 'renderer'); print(gcf, '-depsc2', ['-' r], '~/Desktop/beads.eps'); close;
