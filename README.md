Fiber Pipeline
==============

A custom set of tools to process and analyze video of fluorescence activity 
recorded via optical microfibers. Supports acquisition of standalone video 
or combining video with synchronized audio. Scripts include the conversion 
from Hamamatsu CXD file format to raw binary files, synchronization of 
analog signals with video frames and a node-based processing framework 
for analyzing the video files. Each feature is described in brief below.

Conversion Code
---------------

The conversion code is written in Python. It reads the CXD format generated 
by the Hamamatsu software, and converts it to a video file (which contains 
raw pixel intensities) and a CSV file with frame meta data.

The Python code requires `numpy` and `olefile`, which can be installed by 
running the following command:

```
> pip install -r convert/requirements.txt
```

Once the requirements are installed, you can run a conversion by:

```
> python extract_cxd.py video123.cxd
```

This will read in the "video123.cxd" file and save the raw binary 
file and CSV file as "video123.video" and "video123.csv" respectively.

Flex: Node Based Analysis
-------------------------

The flex folder contains set of MATLAB classes that allow constructing 
analysis networks. The network approach has a few advantages, notably 
that the full video never needs to be in memory. Instead, frames are 
individually loaded and pushed through the network. Further work may 
extend this with the ability to parallelize analysis.

There are four node types:

* reader (only has one or more outputs)
* filter (has an input and one or more outputs)
* analysis (has an input)
* writer (has an input)

Once the network is constructed and nodes are connected, the reader 
node is used to initialize processing. The reader will sequentially 
load video frames and "push" them through the network.

The helper function `connect` allows easily connecting a simple 
sequential network, or you can use the class `addOutput` method 
to connect nodes. For example, these two code segments construct
the same network:

```matlab

% manually
reader = ReaderVideo('recording.video');
filter_register = FilterRegisterSift([], true); % motion correct (register to first frame)
filter_ds = FilterDownsample(2); % downsample by a factor of two
an_range = AnalysisRange(); % extract the intensity range for each pixel
an_mean = AnalysisMean(); % extract the mean intensity of each pixel
an_frame = AnalysisFrame(1); % extract the first frame

reader.addOutput(filter_register);
filter_register.addOutput(filter_ds);
filter_ds.addOutput(an_range);
filter_ds.addOutput(an_mean);
filter_ds.addOutput(an_frame);

reader.run();

% use connect helper
an_range = AnalysisRange(); % extract the intensity range for each pixel
an_mean = AnalysisMean(); % extract the mean intensity of each pixel
an_frame = AnalysisFrame(1); % extract the first frame

reader = connect(...
    ReaderVideo('recording.video'), ... 
    FilterRegisterSift([], true), ... % motion correct (register to first frame)
    FilterDownsample(2), ... % downsample by a factor of two
    an_frame, ...
    an_mean, ...
    an_range ...
);

reader.run();
```

To read the output of an analysis node, use the `getResult` method:

```matlab
mean_frame = an_mean.getResult();
```


Legacy Code
-----------

Code in the "legacy" folder is no longer actively used (it may need some 
edits to restore full functionality), but it includes the ability to:

* Convert Hamamatsu files into individual frames (raw)
* Read an audio format file containing analog data in one channel (i.e., audio) and frame synchronization pulses on the other channel
* Synchronize the video and audio based on the frame pulses
* Align synchronized acquisition by audio template
* Perform basic analysis through the `Explore` MATLAB class

For synchronization the Hamamatsu camera is configured to generate 
an output timing trigger, using the PROGRAMMABLE EDGE aligned to 
VSYNC (delay 0, period 500 µs, positive). The timing pin is 
connected to the right input audio channel via a voltage divider.

The analog (audio) signal is acquired through the left input audio 
channel, using the [Video Capture application](https://github.com/gardner-lab/video-capture).

Aligning acquired signals depends on the [Find Audio](https://github.com/gardner-lab/find-audio)
tool, a MATLAB library (and accompanying MEX files) to use a 
variant of dynamic time warping to find and align renditions of an 
audio template in a longer signal.

Details
-------

This code is licensed under the MIT license. It was created by [L. Nathan Perkins](https://github.com/nathanntg).
