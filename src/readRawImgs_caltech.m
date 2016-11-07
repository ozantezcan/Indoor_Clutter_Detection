%function [imgVec,imgLabel]= readRawImgs_caltech(fnames)

% Calculate feature vectors with specified HoG options and return struct
% format. Also save as .mat file if a filename is given.

subd = {'\airplanes\','\barrel\','\brain\'};
%CIRs = 4:9;
imgVec = [];
imgLabel = [];


for rootdir = 1:length(fnames)
      for types = 1:length(subd)
        currentDir = [fnames{rootdir},subd{types}];

        d = dir(currentDir);
        d = {d.name};
        d = setdiff(d,{'.','..','thumbs.db','.DS_Store'});

        for kk = 1:length(d)
            if ~strcmpi((d{kk}), 'thumbs.db')
                imgFile = [currentDir, '\', d{kk}];
                img = imread(imgFile);
                if(size(img,3)==3)
                    imgGray = rgb2gray(img);
                end
                imgGrayResize = imresize(imgGray,[240,360]);    
                imgVecCurrent = imgGrayResize(:)';
                imgVec = [imgVec;imgVecCurrent];
                imgLabel = [imgLabel;types];
            end
        end
      end
end
