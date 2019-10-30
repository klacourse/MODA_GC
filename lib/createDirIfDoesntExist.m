% Function to create a directoty only if it does not exist
function createDirIfDoesntExist(pathDir,folderName)
    dirLstWarnObj = dir(pathDir);
    dirFound = 0;
    for iDir = 1:size(dirLstWarnObj,1)
        dirFound = dirFound + strcmp(dirLstWarnObj(iDir).name,folderName);
    end
    if dirFound==0
        mkdir(fullfile(pathDir,folderName));
    end
end

