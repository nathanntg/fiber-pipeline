angles_wrapped = angles;
angles_wrapped(angles < 0) = angles_wrapped(angles < 0) + 2 * pi;

% plot
set(0, 'DefaultAxesLineWidth', 2);
set(0, 'DefaultLineLineWidth', 3);
set(0, 'DefaultAxesFontSize', 16);

% CDF
figure;
plot(video_roe_tm, angles_wrapped);
ylim([0 2 * pi]); set(gca,'YTick', [0 pi 2* pi], 'YTickLabel', {'0', '\pi', '2\pi'});
ylabel('Angle (rad)');
xlim([0 ceil(video_roe_tm(end))]); 
xlabel('Time (s)');

% PDF
figure;
plot(x, hist_low, x, hist_med, x, hist_high);
title('PDF of pixel intensity');
mx = max(max(max(hist_med), max(hist_high)), max(hist_low));
ylim([-0.05 mx * 1.05]); set(gca,'YTick', [0 mx]); ylabel('Proability');
xlim([90 120]); % custom tuned
r = xlim; set(gca,'XTick', r + [5 -5]); xlabel('Intensity');
legend('No light', 'LED strip', 'Room light', 'Location', 'NorthEast');
