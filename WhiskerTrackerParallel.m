function [angle] = WhiskerTrackerParallel(fileName)
%________________________________________________________________________________________________________________________
%
% Edited by Kevin L. Turner
% Ph.D. Candidate, Department of Biomedical Engineering
% The Pennsylvania State University
%
% Originally written by Aaron T. Winder
%
%   Last Revised: August 4th, 2018
%________________________________________________________________________________________________________________________
%
%   Written by Aaron Winder, Drew Lab, ESM, Penn State University
%
%   SUMMARY: Tracks the approximate movement of whiskers using the radon transform of an image of the whiskers. Identifies
%            the whisker angles by analyzing the column variance of the transformed image. Columns with the highest variance
%            will correspond to the correct angle where the highest value of the radon transform will correspond to the
%            correct angle and y-position in the image, while the lowest value will correspond to the correct angle but an
%            incorrect image position.
%
%            **This version of the code uses an onboard GPU to speed up the calculation of the whisker angles.
%________________________________________________________________________________________________________________________
%
%   PARAMETER TYPE: filename - [string] list of filames without the extension.
%________________________________________________________________________________________________________________________
%
%   RETURN: TDMSFile - [struct] contains measured analog data and trial notes from the LabVIEW acquisition program
%________________________________________________________________________________________________________________________

% Variable Setup.
theta = -40:80;   % Angles used for radon
height = 350;   % Whisker image pixel height
width = 30;   % Whisker image pixel width

% Import whisker movie.
importStart = tic;
cameraFrames = ReadBinFileU8MatrixGradient([fileName '_WhiskerCam.bin'], height, width);
importTime = toc(importStart);
disp(['WhiskerTrackerParallel: Binary file import time was ' num2str(importTime) ' seconds.']); disp(' ')

% Transfer the images to the GPU. gpuarray is part of the Parallel Computing Toolbox and is only compatible with specific
% graphics cards, such as Nvidia's CUDA. https://www.mathworks.com/products/parallel-computing.html. This greatly reduces 
% computation time.
gpuStart = tic;
gpuFrames = gpuArray(cameraFrames);
gpuTransfer = toc(gpuStart);
disp(['WhiskerTrackerParallel: GPU transfer time was ' num2str(gpuTransfer) ' seconds.']); disp(' ')

% Pre=allocate array of whisker angles, use NaN as a place holder.
angle = NaN*ones(1, length(cameraFrames));
radonStart = tic;
for n = 1:(length(cameraFrames) - 1)
    % Radon on individual frame
    [R, ~] = radon(gpuFrames(:, :, n), theta);
    % Get transformed image from GPU and calculate the variance
    colVar = var(gather(R));
    % Sort the columns according to variance
    ordVar = sort(colVar);
    % Choose the top 0.1*number columns which show the highest variance
    thresh = round(numel(ordVar)*0.9);
    sieve = gt(colVar, ordVar(thresh));
    % Associate the columns with the corresponding whisker angle
    angles = nonzeros(theta.*sieve);
    % Calculate the average of the whisker angles
    angle(n) = mean(angles);
end

radonTime = toc(radonStart);
disp(['WhiskerTrackerParallel: Whisker Tracking time was ' num2str(radonTime) ' seconds.']); disp(' ')

inds = isnan(angle) == 1;
angle(inds) = [];

end
