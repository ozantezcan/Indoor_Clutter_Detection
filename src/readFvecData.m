function [label, fvec, imgLabel, imgName] = readFvecData(Fname)

% convert struct mat file to mx1 label vector and mxn feature vector.

if ~isstruct(Fname)
    input = load(Fname);
    f = fieldnames(input);
    input = input.(f{1});
else
    input = Fname;
end
CIRs = fieldnames(input);
label = []; count = 1;
imgCount = 1;
imgLabel = [];
imgName = {};

for cir = 1:length(CIRs)
    
    curStruct = input.(CIRs{cir});
    imgs = fieldnames(curStruct);
    
    for ii = 1:length(imgs)
        
        curFvec = curStruct.(imgs{ii}).fvec;
        numVecs = size(curFvec, 2);
        label(count:(count+numVecs-1), 1) = cir;
        imgLabel(count:(count+numVecs-1), 1) = imgCount;
        imgName{imgCount} = [cd '\' curStruct.(imgs{ii}).name];
        
        fvec(count:(count+numVecs-1), :) = curFvec';
        
        count = count + numVecs;
        imgCount = imgCount + 1;
    end
end


