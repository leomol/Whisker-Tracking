function [imageGrad] = ReadBinFileU8MatrixGradient(fileName, height, width)
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
%   SUMMARY: Reads binary file with little endian ordering and 8-bit grayscale formatting, calculates the gradient of the
%            image to emphasize the edges and outputs a cell array of images.
%________________________________________________________________________________________________________________________
%
%   PARAMETERS: filename - [string] complete file name including extension
%               height - [integer] the height of the recorded image in pixels
%               width - [integer]  the width of the recorded image in pixels
%
%   RETURN: imageGrad - [array, u8 integer] the measured intensity values organized as
%           [image width, image height, frame number]
%________________________________________________________________________________________________________________________

% Calculate number of pixels per frame for fread
pixelsPerFrame = width*height;

% Open the file, get file size, back to the begining
fid = fopen(fileName);
fseek(fid, 0, 'eof');   % end of file
fileSize = ftell(fid);
fseek(fid, 0, 'bof');   % beginning of file

% Identify the number of frames to read. Each frame has a previously
% defined width and height (as inputs), U8 has a depth of 1.
nFrameToRead = floor(fileSize / (pixelsPerFrame));
disp(['ReadBinFileU8MatrixGradient: ' num2str(nFrameToRead) ' frames to read.']); disp(' ')

% Pre-allocate imageGrad
imageGrad = int8(zeros(width, height, nFrameToRead));
% Populate variable
for n = 1:nFrameToRead
    z = fread(fid, pixelsPerFrame, '*uint8', 0, 'l');
    indImg = reshape(z(1:pixelsPerFrame), width, height);
    imageGrad(:, :, n) = int8(gradient(double(indImg)));
end

fclose(fid);

end
