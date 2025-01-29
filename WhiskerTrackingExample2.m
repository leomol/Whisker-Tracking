% 2018-11-09. Original code by Kevin L. Turner.
% 2025-01-29. Revision: support long TIF files by LM.

% Run the whisker analysis code to pull out the average whisker angle changes over time.
% Image size: 153x852
% Number of frames: 25000
% Approximate running time: 386.3s
filename = 'data/50Hz25000Frames.tif';
samplingRate = 50;
frames = loadTif(filename);
data = WhiskerTracker(frames, samplingRate);

% Save.
[folder, basename] = fileparts(filename);
save(fullfile(folder, sprintf('%s-whisker-data.mat', basename)), '-struct', 'data');