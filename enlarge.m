function [X_enlarged,Y_enlarged] = enlarge(X,Y)

numOfLabels = max(Y);
freqCount = zeros(1,numOfLabels);
for k =1:numOfLabels
    freqCount(k) = sum(Y==k);
end
maxCount = max(freqCount);
X_enlarged = zeros(maxCount*numOfLabels,size(X,2));
Y_enlarged = zeros(maxCount*numOfLabels,1);
x_k_enlarged = zeros(maxCount,size(X,2));
for k = 1:numOfLabels
    x_k = X(Y==k,:);
    kCount = freqCount(k);
    iterCount = floor(maxCount/kCount);
    for l=1:iterCount
        x_k_enlarged((l-1)*kCount+1:l*kCount,:) = x_k;
    end
    remainCount = mod(maxCount,kCount);
    if(remainCount~=0)
        x_k_enlarged(iterCount*kCount+1:end,:) = x_k(1:remainCount,:);
    end
    X_enlarged((k-1)*maxCount+1:k*maxCount,:) =x_k_enlarged;
    Y_enlarged((k-1)*maxCount+1:k*maxCount) = k*ones(maxCount,1);
end