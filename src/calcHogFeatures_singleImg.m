function fVec = calcHogFeatures_singleImg(imgFname, ...
    cellSize, blockSize, blockOverlap, numBins, useSignedOrientation, ...
    imgSize, augmentDataShift, augmentDataFlip, augmentDataRotate)

img = imread(imgFname);
img2 = zeros(0, 0, 0);
grad = img2; ang = img2;

if nargin == 1
    cellSize = 20;
    blockSize = 2;
    blockOverlap = 0;
    numBins = 4;
    useSignedOrientation = false;
end

if isempty(imgSize)
    imgSize = [255, 335];
end

[~, ~, d] = size(img);
if d > 1
    img = rgb2gray(img);
end

if augmentDataRotate
    rotAngle = [-10 -5 5 10];
    imgRotTemp = imresize(img, round(1.3 * imgSize));
    
    for rot = 1:length(rotAngle)    
        imgRotTemp2 = imrotate(imgRotTemp, rotAngle(rot), 'bilinear', 'crop');
        
        if rotAngle(rot) > 0
            idx1 = find(imgRotTemp2(:, 1) > 0, 1, 'first');
            idx2 = find(imgRotTemp2(end, :) > 0, 1, 'first');
        else
            idx1 = find(imgRotTemp2(:, end) > 0, 1, 'first');
            idx2 = find(imgRotTemp2(1, :) > 0, 1, 'first');
        end
        
        imgRotTemp2 = imgRotTemp2(idx1:(size(imgRotTemp2, 1)-idx1), idx2:(size(imgRotTemp2, 2)-idx2));
        img2(:, :, end+1) = imresize(imgRotTemp2, imgSize + 2);
    end
end

% resize image to 15 pixels larger than 320x240 so we can shift it by 5
% pixels.
% Also add 2 to the size to account for taking filter output only in the
% valid region.
img2(:, :, end+1) = imresize(img, imgSize + 2);

for ii = 1:size(img2, 3);
    [grad(:, :, ii), ang(:, :, ii)] = calculateGradient(img2(:, :, ii));
end

iter = 1;

for rot = 1:size(img2, 3)
    if augmentDataShift
        
        loopIdx = 0:double(augmentDataFlip);
        numBlocks = floor(((imgSize-15)./cellSize - blockSize)./(blockSize - blockOverlap) + 1);
        fVec = zeros(prod([numBlocks, blockSize.^2, numBins]), 16 * length(loopIdx));
        
        for kk = loopIdx
            for ii = 1:4
                for jj = 1:4
                    rowIdx = (1:(imgSize(1)-15))+(ii-1)*5;
                    colIdx = (1:(imgSize(2)-15))+(jj-1)*5;
                    if kk
                        colIdx = fliplr(colIdx);
                    end
                    tempVec = buildFeatureVectorSVR(grad(rowIdx, colIdx, rot), ang(rowIdx, colIdx, rot), ...
                        cellSize, blockSize, blockOverlap, numBins, useSignedOrientation);
                    fVec(:, iter) = reshape(tempVec, [numel(tempVec), 1]);
                    iter = iter + 1;
                end
            end
        end
        
    elseif ~augmentDataShift && augmentDataFlip
        loopIdx = 0:1;
        numBlocks = floor(((imgSize)./cellSize - blockSize)./(blockSize - blockOverlap) + 1);
        fVec = zeros(prod([numBlocks, blockSize.^2, numBins]), 2);
        colIdx = 1:size(grad, 2);
        
        for kk = loopIdx
            if kk
                colIdx = fliplr(colIdx);
            end
            tempVec = buildFeatureVectorSVR(grad(:, colIdx, rot), ang(:, colIdx, rot),...
                cellSize, blockSize, blockOverlap, numBins, useSignedOrientation);
            fVec(:, iter) = reshape(tempVec, [numel(tempVec), 1]);
            iter = iter + 1;
        end
        
    else
        tempVec = buildFeatureVectorSVR(grad(:, :, rot), ang(:, :, rot), ...
            cellSize, blockSize, blockOverlap, numBins, useSignedOrientation);
        fVec(:, iter) = reshape(tempVec, [numel(tempVec), 1]);
        iter = iter + 1;
    end
end


return;