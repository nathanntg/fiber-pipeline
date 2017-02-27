%% compare light levels

% do for hist_low, hist_med, hist_high
% make histogram
hist = accumarray(1 + video(:), 1, [1 + intmax(class(video)) 1]);

% find appropriate dynamic range
first = min(min(find(hist_low, 1), find(hist_med, 1)), find(hist_high, 1));
last = max(max(find(hist_low, 1, 'last'), find(hist_med, 1, 'last')), find(hist_high, 1, 'last'));

% trim dynamic range
x = first:last;
hist_low = hist_low(x);
hist_med = hist_med(x);
hist_high = hist_high(x);

% normalize
hist_low = hist_low ./ sum(hist_low);
hist_med = hist_med ./ sum(hist_med);
hist_high = hist_high ./ sum(hist_high);

% plot
set(0, 'DefaultAxesLineWidth', 2);
set(0, 'DefaultLineLineWidth', 3);
set(0, 'DefaultAxesFontSize', 16);

% CDF
figure;
plot(x, cumsum(hist_low), x, cumsum(hist_med), x, cumsum(hist_high));
title('CDF of pixel intensity');
ylim([-0.05 1.05]); set(gca,'YTick', [0 1]); ylabel('Cumulative proability');
xlim([90 120]); % custom tuned
r = xlim; set(gca,'XTick', r + [5 -5]); xlabel('Intensity');
legend('No light', 'LED strip', 'Room light', 'Location', 'SouthEast');

% PDF
figure;
plot(x, hist_low, x, hist_med, x, hist_high);
title('PDF of pixel intensity');
mx = max(max(max(hist_med), max(hist_high)), max(hist_low));
ylim([-0.05 mx * 1.05]); set(gca,'YTick', [0 mx]); ylabel('Proability');
xlim([90 120]); % custom tuned
r = xlim; set(gca,'XTick', r + [5 -5]); xlabel('Intensity');
legend('No light', 'LED strip', 'Room light', 'Location', 'NorthEast');
