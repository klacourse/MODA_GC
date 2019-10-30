% Generate a real list of files from the selected directoy
function [FileNameList] = generateRealList(listOfFilesAvailable,extension)
    FileNameList = cell(0,0);
    iFileRealFile = 1;
    for iPSGFile = 1: size(listOfFilesAvailable,1)
        if ~listOfFilesAvailable(iPSGFile).isdir
            tmpFile = listOfFilesAvailable(iPSGFile).name;
            % Sometime backup file with a ~ is created in the directory
            if isempty(strfind(tmpFile,'~'))
                % If its a file with the edf extension 
                if ~isempty(strfind(lower(tmpFile),lower(extension)))
                    FileNameList{iFileRealFile,1} = ...
                        listOfFilesAvailable(iPSGFile).name;
                    iFileRealFile = iFileRealFile + 1;
                end
            end
        end
    end
end

