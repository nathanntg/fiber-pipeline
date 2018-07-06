%% process video: step 2, align other video, get ROIs
[reader, an_roi] = connect(...
    ReaderVideo('~/Desktop/mouse4/Data88.video'), ...
    FilterRegisterSift(results_frame, true), ...
    AnalysisRoi(centers, radii) ...
);

% run
reader.run();

% results
results_trace88 = an_roi.getResult();

%% process video: step 2, align other video, get ROIs
[reader, an_roi] = connect(...
    ReaderVideo('~/Desktop/mouse4/Data90.video'), ...
    FilterRegisterSift(results_frame, true), ...
    AnalysisRoi(centers, radii) ...
);

% run
reader.run();

% results
results_trace90 = an_roi.getResult();

%% clean
clear reader
clear an_*
