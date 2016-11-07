%function [imgVec,imgLabel]= readRawImgs(fnames)

% Calculate feature vectors with specified HoG options and return struct
% format. Also save as .mat file if a filename is given.

subd = {'\CIRs Bedroom\','\CIRs Kitchen\','\CIRs Living Room\'};
CIRs = 4:9;
%imgVec = [];
%imgLabel = [];

for cir = CIRs 
    cir
    for rootdir = 1:length(fnames)
          for types = 1:length(subd)
            currentDir = [fnames{rootdir},subd{types}, 'CIR', num2str(cir)];

            d = dir(currentDir);
            d = {d.name};
            d = setdiff(d,{'.','..','thumbs.db','.DS_Store'});

            for kk = 1:length(d)
                if ~strcmpi((d{kk}), 'thumbs.db')
                    imgFile = [currentDir, '\', d{kk}];
                    img = imread(imgFile);
                    imgGray = rgb2gray(img);
                    imgGrayResize = imresize(imgGray,[240,360]);    
                    imgVecCurrent = imgGrayResize(:)';
                    imgVec = [imgVec;imgVecCurrent];
                    imgLabel = [imgLabel;cir];
                end
            end
          end
    end
end