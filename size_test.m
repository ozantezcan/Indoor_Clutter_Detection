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

numImgs = length(label);
sizeRanges = [0 .1 .2 .3 .4 .5 .6 .7 .8 .9 1];
randIdx = randperm(numImgs);
sizeRanges = round(sizeRanges * numImgs);
sizeRanges(1)=1;
%ccr = zeros(1,10);
k=10;
%for k=1:10
    fvec_current = fvec_HOG(randIdx(1:sizeRanges(k+1)),:);
    label_current = label_HOG(randIdx(1:sizeRanges(k+1)));
    
    crossValid = [0, 0.25, 0.5, 0.75, 1];
    permIdxs = round(crossValid * sizeRanges(k+1));
    permIdxs(1) = 1;
    permIdxs(end) = permIdxs(end) +1;
    current_ccr = 0;
    for l = 1:(length(crossValid)-1)
        testIdx = permIdxs(l):permIdxs(l+1)-1;
		trainIdx = setdiff(1:sizeRanges(k+1), testIdx);
        [fvec_train,label_train] = enlarge(fvec_current(trainIdx, :),label_current(trainIdx));
        %label_train = label_current(trainIdx);
		%fvec_train = fvec_current(trainIdx, :);
        
        label_test = label_current(testIdx);
		fvec_test = fvec_current(testIdx, :);
        
        model = svmtrain(label_train, fvec_train, param.libsvm);
        [pred_label, mse, ~] = svmpredict(label_test, fvec_test, model);
        current_ccr = current_ccr + sum(abs(label_test-pred_label)<=1);
        %keyboard
    end
    %ccr(k) = current_ccr/sizeRanges(k+1);
%end
ccr