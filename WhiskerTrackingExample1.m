% 2018-11-09. Original code by Kevin L. Turner.
% 2025-01-10. Revision: support long TIF files by LM.

% Run the whisker analysis code to pull out the average whisker angle changes over time.
% Image size: 30x350
% Number of frames: 8989
% Approximate running time: 12.117s
filename = 'Example_WhiskerCam.bin';
samplingRate = 150;
frames = ReadBinFileU8MatrixGradient(filename, 350, 30);
WhiskerTracker(frames);