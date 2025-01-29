% 2018-11-09. Original code by Kevin L. Turner.
% 2025-01-29. Revision: support long TIF files by LM.

% Run the whisker analysis code to pull out the average whisker angle changes over time.
% Image size: 30x350
% Number of frames: 8989
% Approximate running time (RTX A4000): 12.117s
filename = 'Example_WhiskerCam.bin';
samplingRate = 150;
frames = ReadBinFileU8MatrixGradient(filename, 350, 30);
data = WhiskerTracker(frames, samplingRate);

% Save.
[folder, basename] = fileparts(filename);
save(fullfile(folder, sprintf('%s-whisker-data.mat', basename)), '-struct', 'data');