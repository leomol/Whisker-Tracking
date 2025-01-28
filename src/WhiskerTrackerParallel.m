% 2018-11-09. Original code by Kevin L. Turner.
% https://github.com/DrewLab/Whisker-Tracking
% 
% 2025-01-28. Revision by LM.
% https://github.com/leomol/Whisker-Tracking

function angle = WhiskerTrackerParallel(cameraFrames, theta)
    % Angles used for radon.
    if nargin < 2
        theta = -40:80;
    end
    
    % Calculate frames per batch with a safety margin.
    available = double(intmax('int32'));
    nFrames = size(cameraFrames, 3);
    bytesPerFrame = variableSize(cameraFrames(:, :, 1));
    safetyMargin = 1;
    framesInBatch = floor(safetyMargin * available / bytesPerFrame);
    nBatches = ceil(nFrames / framesInBatch);
    
    gpuTransfer = 0;
    radonTime = 0;
    angle = NaN * ones(1, nFrames);
    
    for b = 1:nBatches
        % Define batch range.
        startIndex = (b - 1) * framesInBatch + 1;
        endIndex = min(b * framesInBatch, nFrames);
        range = startIndex:endIndex;
        n = numel(range);
        
        % Transfer frames to GPU.
        gpuStart = tic;
        fprintf('Batch %d/%d (frames %d to %d)\n', b, nBatches, startIndex, endIndex);
        fprintf('  Transferring to GPU... ');
        gpuFrames = gpuArray(cameraFrames(:, :, range));
        fprintf('done\n');
        gpuTransfer = gpuTransfer + toc(gpuStart);
        
        % Process frames.
        radonStart = tic;
        fprintf('  Radon calculation... ');
        for f = 1:n
            % Radon transform on individual frame.
            [R, ~] = radon(gpuFrames(:, :, f), theta);
            colVar = var(gather(R));
            ordVar = sort(colVar);
            thresh = round(0.9 * numel(ordVar));
            sieve = gt(colVar, ordVar(thresh));
            angles = nonzeros(theta .* sieve);
            angle(range(f)) = mean(angles);
        end
        fprintf('done\n');
        radonTime = radonTime + toc(radonStart);
    end
    
    fprintf('GPU transfer time was %.2fs\n', gpuTransfer);
    fprintf('Whisker Tracking time was %.2fs\n', radonTime);
    
    % Remove NaN values.
    inds = isnan(angle);
    angle(inds) = [];
end

function bytes = variableSize(variable)
    bytes = numel(variable) * sizeof(variable);
end

function bytesPerElement = sizeof(variable)
    switch class(variable)
        case {'double', 'int64'}
            bytesPerElement = 8;
        case {'single', 'int32'}
            bytesPerElement = 4;
        case {'int16'}
            bytesPerElement = 2;
        case {'uint8', 'int8'}
            bytesPerElement = 1;
        otherwise
            error('Unsupported data type');
    end
end
