unction outstruct = calcHogFeatures_allImgs(rootdir,cellSize, blockSize, blockOverlap, numBins, useSignedOrientation, ...
    imgSize, augmentDataShift, augmentDataFlip, augmentDataRotate)

% Calculate feature vectors with specified HoG options and return struct
% format. Also save as .mat file if a filename is given.

subd1 = {'1_images_till_Feb_2016\','2_images_Feb_June_2016\','3_images_June_Sept_2016\'};
subd2 = {'CIRs Bedroom\', 'CIRs Kitchen\', 'CIRs Living Room\'};
CIRs = 1:9;
outstruct = struct();

if (nargin==1)
    cellSize = 20;
    blockSize = 2;
    blockOverlap = 0;
    numBins = 4;
    useSignedOrientation = false;
    imgSize = [255, 335];
    augmentDataShift = false;
    augmentDataFlip = false;
    augmentDataRotate = false;
end

% populate struct with all images feature vectors.

for cir = CIRs
    %cir
    imgCount = 1;
    
    for types = 1:length(subd1)
    for level = 1:length(subd2)
    currentDir = [rootdir,subd1{types},subd2{level},'CIR', num2str(cir)];
        d = dir(currentDir);
        d = {d.name};
        d = d(3:end);
        %keyboard
    cir
        %keyboard
        for kk = 1:length(d)
            if ~(strcmpi((d{kk}), 'thumbs.db')||strcmpi((d{kk}), '.DS_Store'))
                imgFile = [currentDir, '\', d{kk}];

                fvec = calcHogFeatures_singleImg(imgFile, ...
                    cellSize, blockSize, blockOverlap, numBins, useSignedOrientation, ...
                    imgSize, augmentDataShift, augmentDataFlip, augmentDataRotate);

                % Temporarily augment high CIR images!!!!
                %
                %

                tempFvec = [];

                outstruct.(['CIR', num2str(cir)]).(['im', num2str(imgCount)]).fvec = ...
                    [tempFvec, fvec];
                outstruct.(['CIR', num2str(cir)]).(['im', num2str(imgCount)]).name = imgFile;

                imgCount = imgCount + 1;
                %
                %
                % \ Temporarily augment high CIR images!!!!
        end
            end
        end
    end
end

