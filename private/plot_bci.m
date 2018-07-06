function [handles_primary, handles] = plot_bci(time, varargin)
%PLOT_BCI Summary of this function goes here
%   Detailed explanation goes here

%% parameters
nboot = 1e3;
colors = lines(7);
use_patch = true;

% load custom parameters SPECIAL TO ACCEPT VARIABLE NUMBER OF PLOTS
first_arg = nan;
nparams = length(varargin);
for i = 1:nparams
    if isnan(first_arg)
        if ~ischar(varargin{i})
            continue;
        end
        first_arg = i;
    end
    if mod(i - first_arg, 2) == 1
        continue;
    end
    if i == nparams
        error('Parameters must be specified as parameter/value pairs');
    end
    nm = lower(varargin{i});
    if ~exist(nm, 'var')
        error('Invalid parameter: %s.', nm);
    end
    eval([nm ' = varargin{i+1};']);
end

%% plot

% convidence interval line width
ci_lw = get(0, 'DefaultLineLineWidth') / 2;

% prep
handles = [];
handles_primary = [];
hold on;
j = 0;
for i = 1:nparams
    if ~isnan(first_arg) && i >= first_arg
        break;
    end
    
    % is time
    if 1 == size(varargin{i}, 1) && i < nparams && size(varargin{i}, 2) == size(varargin{i + 1}, 1)
        time = varargin{i};
        continue;
    end
    
    % count
    j = j + 1;
    
    % color
    color = colors(1 + mod(j - 1, size(colors, 1)), :);
    
    % mean
    mn = nanmean(varargin{i}, 2);
    
    % confidence interval
    ci = bootci(nboot, {@nanmean, varargin{i}'}, 'type', 'cper');
    
    % draw patch
    if use_patch && 1 < size(varargin{i}, 2)
        % draw patch
        patch_x = [time fliplr(time)];
        patch_y = [ci(1, :) fliplr(ci(2, :))];
        h = patch(patch_x, patch_y, 1, 'FaceColor', color, 'EdgeColor', 'none', 'FaceAlpha', 0.15);
        handles(end + 1) = h; %#ok<AGROW>
        
        % draw edges
        h = plot(time, ci, '-', 'LineWidth', ci_lw, 'Color', color + (1 - color) * 0.55);
        handles = [handles; h]; %#ok<AGROW>
    end
    
    % plot
    h = plot(time, mn, 'Color', color);
    handles_primary = [handles_primary; h]; %#ok<AGROW>
    handles = [handles; h]; %#ok<AGROW>
    
    % draw confidence lines
    if ~use_patch && 1 < size(varargin{i}, 2)
        h = plot(time, ci, '--', 'LineWidth', ci_lw, 'Color', color);
        handles = [handles; h]; %#ok<AGROW>
    end
end
hold off;

end
