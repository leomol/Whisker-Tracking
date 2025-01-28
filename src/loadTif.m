function frames = loadTif(filename)
    info = imfinfo(filename);
    nFrames = numel(info);
    info = info(1);
    frames = zeros(info.Height, info.Width, nFrames, 'uint8');
    for frame = 1:nFrames
        frames(:, :, frame) = imread(filename, frame);
    end
end