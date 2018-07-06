% smooth - 4 second
results_trace_smoothed = medfilt2(results_trace, [1 80], 'symmetric');

% subtracted
results_trace_detrend = results_trace - results_trace_smoothed;

%% attempt 1: largest deviations
n = 10;
tm_idx = 1:3600;

a = quantile(results_trace_detrend(:, tm_idx), [0.01 0.5 0.995], 2);
dev = (a(:, 3) - a(:, 2)) ./ (a(:, 2) - a(:, 1));
[~, idx] = sort(dev, 'desc');

figure;
plot(tm(tm_idx), 65535 .* results_trace_detrend(idx(1:n), tm_idx)');

figure;
plot_many(tm(tm_idx), 65535 .* results_trace_detrend(idx(1:n), tm_idx)');
xlabel('Time [s]');
ylabel('Intensity');

