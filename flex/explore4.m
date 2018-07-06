% MOUSE 4 - convert subsection to video

an_range = AnalysisRange();
an_frame = AnalysisFrame(1); % for subsequent registration

[reader, writer] = connect(...
    ReaderVideo('~/Desktop/mouse4/Data96.video', 650 .* 20, 50 .* 20), ...
    FilterRegisterSift(results_frame), ...
    WriterVariable() ...
);

% run
reader.run();

% results
video = writer.getResult();

clear reader writer;
