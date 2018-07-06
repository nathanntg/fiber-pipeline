% RUN CHECK SIGNAL TO REGISTER AND DETREND

% remove nan
is_nan = all(reshape(stack, [], size(stack, 3)), 1);
stack(:, :, is_nan) = [];

% normalization value
q = quantile(stack(:), [0.01 0.99]);

% convert to double
stack = (stack - q(1)) ./ (q(2) - q(1));

% squash
stack(stack > 1) = 1;
stack(stack < 0) = 0;

% calculate variance
figure;
v = var(stack, 0, 3);
imagesc(v);
colorbar;

% maximium difference
figure;
d = max(stack, [], 3) - min(stack, [], 3);
imagesc(d);
colorbar;

% find circles
mn = mean(stack(:, :, 1:10), 3);
mn = imresize(mn, 4);
[centers, radii] = imfindcircles(mn, [30 40], 'ObjectPolarity', 'dark', 'Sensitivity', 0.99);
[c, r] = imfindcircles(mn, [30 40], 'ObjectPolarity', 'bright', 'Sensitivity', 0.99);
centers = [centers; c]; radii = [radii; r];

centers = centers ./ 4;
radii = radii ./ 4;

fprintf('Mean radius = %f\n', mean(radii));

figure;
imshow(mean(stack, 3));
h = viscircles(centers, radii);

ts = zeros(size(centers, 1), size(stack, 3));
[x, y] = meshgrid(1:size(stack, 2), 1:size(stack, 1));
stack_r = reshape(stack, [], size(stack, 3));
for i = 1:size(centers, 1)
    % calculate circular mask
    d = ((x - centers(i, 2)) .^ 2 + (y - centers(i, 1)) .^ 2) < (radii(i) * radii(i));
    % extract mean time series
    ts(i, :) = mean(stack_r(d(:), :), 1);
end

n = 20;
v = var(ts, [], 2); % bsxfun(@minus, ts, mean(ts, 1))
[~, is] = sort(v, 'descend');
t = (0:(size(stack, 3) - 1)) ./ fps;

for i = is(1:n)'
    figure;
    subplot(1, 2, 1); imshow(mean(stack, 3)); h = viscircles(centers(i, :), radii(i));
    subplot(1, 2, 2); plot(t, ts(i, :)); xlim([t(1) t(end)]);
end

figure;
clrs = lines(n);
subplot(1, 2, 1); imshow(mean(stack, 3)); 
subplot(1, 2, 2); xlim([t(1) t(end)]); ylim([0 n]); xlabel('Time (s)'); set(gca,'ytick',[]);
for j = 1:n
    i = is(j);
    s = ts(i, :);
    s = (s - min(s)) ./ (max(s) - min(s));
    subplot(1, 2, 1); h = viscircles(centers(i, :), radii(i), 'Color', clrs(j, :));
    subplot(1, 2, 2); hold on; plot(t, j - 1 + s, 'Color', clrs(j, :)); hold off;
end

% rotate
mn = mean(stack, 3);
imshow(mn);
