%________________________________________________________________________________________________________________________
%
% Edited by Kevin L. Turner
% Ph.D. Candidate, Department of Biomedical Engineering
% The Pennsylvania State University
%
%   Last Revised: November 9th, 2018
%________________________________________________________________________________________________________________________

%% BLOCK [1]: Run the whisker analysis code to pull out the average whisker angle changes over time
fileName = 'Example';
[whiskerAngle] = WhiskerTrackerParallel(fileName);

%% BLOCK [2]: Filter the whisker angle and evaluate potential whisking events
samplingRate = 150;   % Acquired sampling Rate (Hz)
downSampleRate = 30;   % Downsampled sampling Rate (Hz)
filterThreshold = 20;   % Cutoff frequency (Wn) in Hz for butterworth filter  
filterOrder = 2;   % Butterworth filter order
[z, p, k] = butter(filterOrder, filterThreshold / (samplingRate / 2), 'low');   % Lowpass filter design
[sos, g] = zp2sos(z, p, k);   %  Zero-pole-gain filter parameters to second-order sections
filteredWhiskerAngle = filtfilt(sos, g, whiskerAngle - mean(whiskerAngle));   % Zero-phase filtering
resampledWhiskers = resample(filteredWhiskerAngle, downSampleRate, samplingRate);   % downsample the filtered signal

whiskerAcceleration = (diff(whiskerAngle, 2));   % Calculate the accelerationm of the whisker angle
whiskingThreshold = abs((diff(whiskerAngle, 2)))*downSampleRate^2; % square the absV of the signal to determine whisking events
threshLine = ones(1, length(whiskingThreshold))*5000;   % arbitrary event threshold line

%% BLOCK [3]: Figure generation
figure;
ax1 = subplot(3, 1, 1);
plot((1:length(whiskerAngle)) / samplingRate, whiskerAngle, 'k');
title('Whisker Angle')
ylabel('Angle (degrees)')
xlabel('Time (seconds)')

ax2 = subplot(3, 1, 2);
plot((1:length(whiskerAcceleration)) / samplingRate, whiskerAcceleration, 'k');
title('Whisker Acceleration')
ylabel('Acceleration (degrees/sec^2)')
xlabel('Time (seconds)')

ax3 = subplot(3, 1, 3);
plot((1:length(whiskingThreshold)) / samplingRate, whiskingThreshold, 'k');
hold on;
threshold = plot((1:length(whiskingThreshold)) / samplingRate, threshLine, 'r', 'LineWidth', 2);
title('Setting Whisking Event Threshold')
ylabel('a.u.')
xlabel('Time (seconds)')
legend(threshold, {'Whisking Threshold'})
linkaxes([ax1 ax2 ax3], 'x')
