% This script provides an example of a grid search for finding SVM
% parameters. Right now, it's searching for the RBF parameters C and gamma.
% Need to search different parameter set if using a polynomial basis
% function.

% Set up HOG parameters and cross validation.
numIterations = 4;
numBins = 4;
cellSize = 20;
blockSize = 2;
blockOverlap = 0;
useSignedOrientation = false;
imgSize = [240, 320];
augmentDataShift = false;
augmentDataFlip = false;
augmentDataRotate = false;
crossValid = [0, 0.25, 0.5, 0.75, 1];

% Calculate all HOG features ...
%outstruct = calcHogFeatures_allImgs(cellSize, blockSize, blockOverlap, ...
%    numBins, useSignedOrientation, imgSize, augmentDataShift, augmentDataFlip, augmentDataRotate, []);

% ... and read them in to a useful format.
%[label, fvec, imgLabel] = readFvecData(outstruct);

load('cnnFeatures.mat');
%uniqueImgs = unique(imgLabel);
numImgs = length(label);
result = struct();

% Set libsvm parameters here and search set for C and gamma.
param.s = 0;
param.Cset = 2.^(-13:10);
param.t = 2;
param.gset = 2.^(-10:0);

% set up absolute error array.
absErr = zeros(length(param.Cset), length(param.gset));

rng(1);
permIdxs = round(crossValid * numImgs);
permIdxs(end) = permIdxs(end) + 1;
permIdxs(1) = 1;
permSet = randperm(numImgs);

% loop over all parameters.
for ii = 1:length(param.Cset)
    param.C = param.Cset(ii);
    
    for jj = 1:length(param.gset)
        param.g = param.gset(jj);
        param.libsvm = ['-s ', num2str(param.s), ' -t ', num2str(param.t), ...
            ' -c ', num2str(param.C), ' -g ', num2str(param.g)];
        
        fprintf('Calculating abs error for C = %f, g = %f', param.C, param.g);
        
        % This is all just like svmValidation.m except .....
        for kk = 1:(length(crossValid)-1)
            
            testImgs = permSet(permIdxs(kk):permIdxs(kk+1)-1);
            trainImgs = setdiff(1:numImgs, testImgs);
            
            trainIdx = ismember(imgLabel, trainImgs);
            testIdx = ismember(imgLabel, testImgs);
            
            model = svmtrain(label(trainIdx), fvec(trainIdx, :), param.libsvm);
            
            if isnan(model.rho)
                error('Something went wrong, probably a data vector contains a NaN. Fix!');
            end
            
            testLabel = label(testIdx);
            pred_label = svmpredict(testLabel, fvec(testIdx, :), model);
            
            nanIdx = isnan(pred_label);
            
            % just keep track of mean absolute error over parameter set
            % rather than populating full results!
            absErrAll{kk} = abs(testLabel - pred_label);
        end
        
        absErrAll = cell2mat(absErrAll(:));
        absErr(ii, jj) = mean(absErrAll(:));
        clear absErrAll
                
    end
end
