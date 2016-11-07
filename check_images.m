dir1Name = 'Data_Sets/1_images_mid_dec_2015/';
dir2Name = 'Data_Sets/2_images_till_Feb_2016/';
%dirCIRsName = 'CIRs february 2016/';
dirfolders = {'CIRs Bedroom/', 'CIRs Kitchen/', 'CIRs Living Room/'};

for k=1:3
    for cir = 1:9
        currentdir1= [dir1Name,dirfolders{k},'CIR',num2str(cir)];
        currentdir2= [dir2Name,dirfolders{k},'CIR',num2str(cir)];
        
        dir1 = dir(currentdir1); 
        dir2=dir(currentdir2);
        names1 = {dir1.name};
        names2 = {dir2.name};
        
        sameNames = intersect(names1,names2);
        %sameNames = setdiff(intersect(names1,names2),{'.','..','Thumbs.db'});
        if(~isempty(setdiff(sameNames,names1)))
            disp(':(');
            keyboard
        end
    end
end