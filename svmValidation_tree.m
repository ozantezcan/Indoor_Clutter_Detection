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

load('afterHOG_10_07_2016');
%load('reTrain_clipped');

%fvec= fvec(8961:end,:);
%label = label(8961:end);
%imgLabel = imgLabel(8961:end)- 280
label1 = ceil(label/3);
%fvec1 = fvec;
%imgLabel1 = imgLabel;

%label11 = label(label<=3);
%label12 = label((label>3) & (label<= 6));
%label13 = label(label>=7);

%fvec11 = fvec(label<=3);
%fvec12 = fvec((label>3) & (label<= 6));
%fvec13 = fvec(label>=7);

%imgLabel11 = imgLabel(label<=3);
%imgLabel12 = imgLabel((label>3) & (label<= 6));
%imgLabel13 = imgLabel(label>=7);

%imgLabel11 = imglabel11-min(imgLabel11)+1;
%imgLabel12 = imglabel12-min(imgLabel12)+1;
%imgLabel13 = imglabel13-min(imgLabel13)+1;

%uniqueImgs1 = unique(imgLabel1);
%numImgs1 = length(uniqueImgs1);
%uniqueImgs11 = unique(imgLabel11);
%numImgs11 = length(uniqueImgs11);
%uniqueImgs12 = unique(imgLabel12);
%numImgs12 = length(uniqueImgs12);
%uniqueImgs13 = unique(imgLabel13);
%numImgs13 = length(uniqueImgs13);

uniqueImgs = unique(imgLabel);
numImgs = length(uniqueImgs);


result = struct();

% Set libsvm parameters here.
param.s = 0;
%param.C = 2; % this is best without augmentation
param.C1 = 1;
param.C11 = 4;
param.C12 = 4;
param.C13 = 256;
param.t = 2;
%param.g = 2^(-5); %this is best without augmentation
param.g1 = 2^(-4);
param.g11 = 2^(-7);
param.g12 = 2^(-7);
param.g13 = 2^(-5);
param.m = 2000;

param.libsvm1 = ['-s ', num2str(param.s), ' -t ', num2str(param.t), ...
    ' -c ', num2str(param.C1), ' -g ', num2str(param.g1), ...
    ' -m ', num2str(param.m)];

param.libsvm11 = ['-s ', num2str(param.s), ' -t ', num2str(param.t), ...
    ' -c ', num2str(param.C11), ' -g ', num2str(param.g11), ...
    ' -m ', num2str(param.m)];

param.libsvm12 = ['-s ', num2str(param.s), ' -t ', num2str(param.t), ...
    ' -c ', num2str(param.C12), ' -g ', num2str(param.g12), ...
    ' -m ', num2str(param.m)];

param.libsvm13 = ['-s ', num2str(param.s), ' -t ', num2str(param.t), ...
    ' -c ', num2str(param.C13), ' -g ', num2str(param.g13), ...
    ' -m ', num2str(param.m)];

% pick out training and testing sets at random in a specified ratio, run
% SVM algorithm.

permIdxs = round(crossValid * numImgs);
permIdxs(end) = permIdxs(end) + 1;
permIdxs(1) = 1;


%N=250
	while iter <= numIterations
	    permSet = randperm(numImgs);
	    cir_error_total = 0;
	    abs_error_total = [];
	    % Go through whole cross validation routine so that every image is
	    % tested once.
	    for ii = 1:(length(crossValid)-1)
		testImgs = permSet(permIdxs(ii):permIdxs(ii+1)-1);
		trainImgs = setdiff(1:numImgs, testImgs);
		
		trainIdx = ismember(imgLabel, trainImgs);
		testIdx = ismember(imgLabel, testImgs);
		
		%%%%%%%%%%%%%%%%%%%%%%%
		label_train = label(trainIdx);
		label_train1 = label1(trainIdx);
		fvec_train1 = fvec(trainIdx, :);

		label_train11 = label_train(label_train1==1);
		fvec_train11 = fvec_train1(label_train1==1, :);
		label_train12 = label_train(label_train1==2);
		fvec_train12 = fvec_train1(label_train1==2, :);
		label_train13 = label_train(label_train1==3);
		fvec_train13 = fvec_train1(label_train1==3, :);
		%B_fisher = fisher_LDA(fvec,label,N);
		%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		%keyboard
		% Call libsvm train
		model1 = svmtrain(label_train1, fvec_train1, param.libsvm1);
		model11 = svmtrain(label_train11, fvec_train11, param.libsvm11);
		model12 = svmtrain(label_train12, fvec_train12, param.libsvm12);
		model13 = svmtrain(label_train13, fvec_train13, param.libsvm13);
		disp('Train complete');
		% This should never happen anymore, leave it just in case
		if (isnan(model1.rho)|isnan(model11.rho)|isnan(model12.rho)|isnan(model13.rho))
		    error('Something went wrong, probably a data vector contains a NaN. Fix!');
		end
		
		% call libsvm predict.
		label_test = label(testIdx);
		label_test1 = label1(testIdx);
		fvec_test1 = fvec(testIdx, :);

		[pred_label1, ~, ~] = svmpredict(label_test1, fvec_test1, model1);

		label_test11 = label_test(pred_label1==1);
		fvec_test11 = fvec_test1(pred_label1==1, :);
		label_test12 = label_test(pred_label1==2);
		fvec_test12 = fvec_test1(pred_label1==2, :);
		label_test13 = label_test(pred_label1==3);
		fvec_test13 = fvec_test1(pred_label1==3, :);
        
		[pred_label11, ~, ~] = svmpredict(label_test11, fvec_test11, model11);
		[pred_label12, ~, ~] = svmpredict(label_test12, fvec_test12, model12);
		[pred_label13, ~, ~] = svmpredict(label_test13, fvec_test13, model13);
		
		abs_error = [abs(label_test11-pred_label11); abs(label_test12-pred_label12); abs(label_test13-pred_label13)];
		cir_error = sum(abs_error<=1);
		
	
		disp('Test complete');

		% Populate results.
		result(resultIdx).pred_label11 = pred_label11;
		result(resultIdx).true_label11 = label_test11;
		result(resultIdx).pred_label12 = pred_label12;
		result(resultIdx).true_label12 = label_test12;
		result(resultIdx).pred_label13 = pred_label13;
		result(resultIdx).true_label13 = label_test13;
		result(resultIdx).cir_error = cir_error;
		result(resultIdx).abs_error = abs_error;
		%result(resultIdx).img_num = imgLabel(testIdx);
		%result(resultIdx).imgName = imgName;
		result(resultIdx).total_imgs = numImgs;
		%result(resultIdx).mse = mse;
		%result(resultIdx).model = model;
		%result(resultIdx).param = param;
		result(resultIdx).numBins = numBins;
		result(resultIdx).cellSize = cellSize;
		result(resultIdx).blockSize = blockSize;
		result(resultIdx).blockOverlap = blockOverlap;
		result(resultIdx).useSignedOrientation = useSignedOrientation;
		cir_error_total = cir_error + cir_error_total;
		abs_error_total = [abs_error_total; abs_error];      
	 	resultIdx = resultIdx + 1;
	    end
	    
	    iter = iter + 1;
	end
disp(['CIR error is', num2str(cir_error_total/length(label))]);
disp(['Absolute error is: mean(',num2str(mean(abs_error_total)), '), std(', num2str(std(abs_error_total)),')']);
iter = 1;
