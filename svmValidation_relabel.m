function [results, cirErr, absErrMean, absErrStd] = svmValidation_relabel(fvec,relabel,imgName,imgLabel,label,iterationCount,iter,results,cirErr,absErrMean,absErrStd)

% This function provides a pathway into all core functionality of this
% work. It calculates vectors for all images located in the testImgs
% directory which are in the expected folder format, keeps track of data
% augmentation, sets up libsvm and the 4-fold split, and outputs data so
% that makePlots can be used to compare runs.
%
% Inputs:
%   numIterations: this should probably always be 1, it was included
%       before I figured out how to properly 4-fold split data and just runs
%       with whole chain multiple times with multiple random testing/training
%       sets. Now with it as 1, all images are rated.
%   imgSize: common resize vector of all input images. Set to [240, 320]
%       when not using shift augmentation or [255, 335] when using shift
%       augmentation. Should work with other properly chosen sizes as well.
%   augmentDataShift: true/false; turn on/off data shift augmentation.
%   augmentDataFlip: true/false; turn on/off data horizontal flip
%       augmentation.
%   augmentDataRotate: true/false; turn on/off data rotation augmentation.
%
% Outputs:
%   result: crazy struct format that makePlots needs to make the 4x3
%       subplot result presentation.

% Set random seed for repeatability.
rng(1);



% Determines indexing for cross validation. For 5-fold split, use [0, 0.2,
% 0.4, 0.6, 0.8, 1] etc.
crossValid = [0, 0.25, 0.5, 0.75, 1];
%crossValid = [0, 0.33, 0.67, 1];

% Calculate all HOG features ...
%outstruct = calcHogFeatures_allImgs(cellSize, blockSize, blockOverlap, ...
%    numBins, useSignedOrientation, imgSize, augmentDataShift, augmentDataFlip, augmentDataRotate, []);
%save newImgsAfterHOG.mat outstruct;


disp('HOG complete');
% ... and read them in to a useful format.
%if useThreeGroups
%    [label, fvec, imgLabel] = readFvecData_threeLabels(outstruct);
%else
%    [label, fvec, imgLabel, imgName] = readFvecData(outstruct);
%end

%load('afterHOG_10_07_2016');
%load('reTrain_clipped');

%relabel = label;
%relabel2=relabel;
%fvec= fvec(8961:end,:);
%label = label(8961:end);
%imgLabel = imgLabel(8961:end)- 280;
%label = ceil(label/2);


uniqueImgs = unique(imgLabel);
numImgs = length(uniqueImgs);
%result = struct();

% Set libsvm parameters here.
param.s = 0;
%param.C = 2; % this is best without augmentation
param.C = 2^4;
param.t = 2;
%param.g = 2^(-5); %this is best without augmentation
param.g = 2^(-4);
param.m = 2000;

param.libsvm = ['-s ', num2str(param.s), ' -t ', num2str(param.t), ...
    ' -c ', num2str(param.C), ' -g ', num2str(param.g), ...
    ' -m ', num2str(param.m)];

% pick out training and testing sets at random in a specified ratio, run
% SVM algorithm.

permIdxs = round(crossValid * numImgs);
permIdxs(end) = permIdxs(end) + 1;
permIdxs(1) = 1;



permSet = randperm(numImgs);
CIR_error = 0;
% Go through whole cross validation routine so that every image is
% tested once.
absErr = [];

result = struct();
for ii = 1:(length(crossValid)-1)
    testImgs = permSet(permIdxs(ii):permIdxs(ii+1)-1);
    trainImgs = setdiff(1:numImgs, testImgs);

    trainIdx = ismember(imgLabel, trainImgs);
    testIdx = ismember(imgLabel, testImgs);

    %%%%%%%%%%%%%%%%%%%%%%%
    label_train = relabel(trainIdx);
    fvec_train = fvec(trainIdx, :);
    %B_fisher = fisher_LDA(fvec,label,N);
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    %keyboard
    % Call libsvm train
    model = svmtrain(label_train, fvec_train, param.libsvm);
    disp('Train complete');
    % This should never happen anymore, leave it just in case
    if isnan(model.rho)
        error('Something went wrong, probably a data vector contains a NaN. Fix!');
    end

    label_test = label(testIdx);
    fvec_test = fvec(testIdx, :);
    % call libsvm predict.
    [pred_label, mse, ~] = svmpredict(label_test, fvec_test, model);
    disp('Test complete');
    label_test(pred_label>label_test) = label_test(pred_label>label_test) +1;
    label_test(pred_label>label_test) = label_test(pred_label>label_test) -1;
    relabel(testIdx) = label_test;
    
    % Populate results.
    %if(iterationCount == 1)
    results(iter).result(ii).abs_error = abs(label(testIdx)-pred_label);
    results(iter).result(ii).pred_label = pred_label;
    results(iter).result(ii).true_label = label(testIdx);
    results(iter).result(ii).CIR_error = sum(abs(label(testIdx)-pred_label)<=1);
    results(iter).result(ii).abs_error = abs(label(testIdx) - pred_label);
    results(iter).result(ii).img_num = imgLabel(testIdx);
    results(iter).result(ii).imgName = imgName;
    results(iter).result(ii).total_imgs = numImgs;
    results(iter).result(ii).mse = mse;
    CIR_error = CIR_error + results(iter).result(ii).CIR_error;
    absErr = [absErr; results(iter).result(ii).abs_error];
    %ii = ii + 1;
    %end
end

cirErr(iter) = CIR_error/length(label);
absErrMean(iter) = mean(absErr);
absErrStd(iter) = std(absErr);
if(iterationCount>1)
    [results,cirErr,absErrMean,absErrStd] = svmValidation_relabel(fvec,relabel,imgName,imgLabel,label,iterationCount-1 ...
    ,iter+1,results,cirErr,absErrMean,absErrStd);
end



