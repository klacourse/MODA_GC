% Generate a real list of files from the selected directoy
% input 
%   pathOfFiles : path of the files (string)
%   extension : extension (string) ex) edf
% Output
%   FileNameList : cell of the files with the right extension in listOfFilesAvailable
%
% Author Karine Lacourse
%
function [FileNameList] = generateRealListFromPath(pathOfFiles,extension)

    % Create a list of files included in the input path
    listOfFilesAvailable = dir(pathOfFiles);
    % To case insensitve
    extension = lower(extension);
    % Extract only the real files with the right extension
    FileNameList = cell(0,0);
    iFileRealFile = 1;
    for iPSGFile = 1: size(listOfFilesAvailable,1)
        if ~listOfFilesAvailable(iPSGFile).isdir
            tmpFile = listOfFilesAvailable(iPSGFile).name;
            % Sometime backup file with a ~ is created in the directory
            if isempty(strfind(tmpFile,'~'))
                % If its a file with the edf extension 
                if ~isempty(strfind(lower(tmpFile),extension))
                    FileNameList{iFileRealFile,1} = ...
                        listOfFilesAvailable(iPSGFile).name;
                    iFileRealFile = iFileRealFile + 1;
                end
            end
        end
    end
end

