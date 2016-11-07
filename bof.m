try
    rootFolder = 'testImgs/';
    subd= {'CIRs Bedroom/'}
    imgFolders = cell(1,27);

    index =1;
    imgSets = imageSet();
    for k =1:length(subd)
        for cir =1:9
            d = [rootFolder, subd{k}, 'CIR ',num2str(cir)];
            imgFolders{index} = d;
            imgSets = [imgSets, imageSet(d)];
            index = index + 1;
        end
    end

    imgSets = imgSets(2:end);

    [trainingSets, validationSets] = partition(imgSets, 0.75, 'randomize');
    bag = bagOfFeatures(trainingSets);

    categoryClassifier = trainImageCategoryClassifier(trainingSets, bag);
    confMatrix = evaluate(categoryClassifier, validationSets);
    save bof.mat confMatrix;
        !touch mailMessage
        !mail -s allSet mtezcan@bu.edu < mailMessage
	exit
catch
        !touch mailMessage
        !mail -s ERROR mtezcan@bu.edu < mailMessage	
	exit
end
