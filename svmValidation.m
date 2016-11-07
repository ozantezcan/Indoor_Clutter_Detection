%function result = svmValidation(numIterations, imgSize, ...
%    augmentDataShift, augmentDataFlip, augmentDataRotate)

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

% Set up HOG parameters here.
numBins = 4;
cellSize = 20;
blockSize = 2;
blockOverlap = 0;
useSignedOrientation = false;
%if nargin == 0
    numIterations = 1;
    imgSize = [];
    augmentDataShift = true;
    augmentDataFlip = true;
    augmentDataRotate = false;
%end
iter = 1;
resultIdx = 1;

% Determines indexing for cross validation. For 5-fold split, use [0, 0.2,
% 0.4, 0.6, 0.8, 1] etc.
crossValid = [0, 0.25, 0.5, 0.75, 1];
%crossValid = [0, 0.33, 0.67, 1];
useThreeGroups = false;

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

%fvec= fvec(8961:end,:);
%label = label(8961:end);
%imgLabel = imgLabel(8961:end)- 280;
%label = ceil(label/2);


uniqueImgs = unique(imgLabel);
numImgs = length(label);
result = struct();

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
trueLabels = [];
predLabels = [];

%N=250
	while iter <= numIterations
        fvec_current = fvec_HOG(randIdx,:);
        label_current = label_HOG(randIdx);
	    permSet = randperm(numImgs);
	    CIR_error = 0;
	    % Go through whole cross validation routine so that every image is
	    % tested once.
	    for ii = 1:(length(crossValid)-1)
		testIdx = permSet(permIdxs(ii):permIdxs(ii+1)-1);
		trainIdx = setdiff(1:numImgs, testIdx);
		
		%trainIdx = ismember(imgLabel, trainImgs);
		%testIdx = ismember(imgLabel, testImgs);
		
		%%%%%%%%%%%%%%%%%%%%%%%
        [fvec_train,label_train] = enlarge(fvec_current(trainIdx, :),label_current(trainIdx));
		%label_train = label_current(trainIdx);
		%fvec_train = fvec_current(trainIdx, :);
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
		
		% call libsvm predict.
		[pred_label, mse, ~] = svmpredict(label_current(testIdx), fvec_current(testIdx, :), model);
		disp('Test complete');

		% Populate results.
		result(resultIdx).pred_label = pred_label;
		result(resultIdx).true_label = label(testIdx);
		result(resultIdx).CIR_error = sum(abs(label(testIdx)-pred_label)<=1);
		result(resultIdx).abs_error = abs(label(testIdx) - pred_label);
		result(resultIdx).img_num = imgLabel(testIdx);
		%result(resultIdx).imgName = imgName;
		result(resultIdx).total_imgs = numImgs;
		result(resultIdx).mse = mse;
		result(resultIdx).model = model;
		result(resultIdx).param = param;
		result(resultIdx).numBins = numBins;
		result(resultIdx).cellSize = cellSize;
		result(resultIdx).blockSize = blockSize;
		result(resultIdx).blockOverlap = blockOverlap;
		result(resultIdx).useSignedOrientation = useSignedOrientation;
		CIR_error = CIR_error + result(resultIdx).CIR_error;       
	 	resultIdx = resultIdx + 1;
        trueLabels =[trueLabels;label_current(testIdx)];
        predLabels =[predLabels;pred_label];
	    end
	    
	    iter = iter + 1;
	end

confMat = confusionmat(trueLabels, predLabels);
calc_cirErr;
cir_HOG_enlarge = [cir_1;cir_Success]