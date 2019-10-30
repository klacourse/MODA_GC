% cleanUp.m
%
% Purpose:
% Makes a copy of all of the scripts used in the analysis to the code directory.
% This includes the active scripts, and all custom functions that are called.
% Functions or scripts that reside in the root MATLAB directory are not copied.
%
% Usage:
% cleanUp(scriptName, codeInputDirectory, codeOutputDirectory)
% 
% Variables:
%   scriptName            - name of the script file (with '.m'), filename will be derived
%   codeInputDirectory    - script file source location
%   codeDirectory         - destination location to save the script files
%   (optional) functUsedBefClean - cell of strings, additionnal functions
%       to keep track of. This option is useful when the memory is cleared
%       during the run. ex) after a parfor the memory is clear and we could
%       loose track of used functions.
%
%
% Requirements:
% This script is intended to work with the script.m
%
% Examples:
% cleanUp(DEF.analysisName, DEF.sourceCodeDir, WORK.codeDir)
%
% Authors:
% Simon Warby 2014-02-21
% 
% Changelog:
%   Karine Lacourse 2015-10-02 :    remove temporary file of the list to copy
%                                   temporary files are file included in a
%                                   tmp directory
%   Karine Lacourse 2018-11-22 :    added the optional input argument when functUsedBefClean

function cleanUp(scriptName, codeInputDirectory, codeOutputDirectory, functUsedBefClean)

    if nargin<1
        error('Please provide the script name, without .m extension.')
    end
    if nargin<2
        error('Please provide the input location where the script files are stored.')
    end
    if nargin<3
        error('Please provide the output location to copy the script files that were used in the analysis.')
    end



    %% Copy the script and script_DEF file to the output directory

    % Copy the main script
    copyfile(fullfile(codeInputDirectory, scriptName), codeOutputDirectory) ;

    % create a folder funtion and copy every functions used into that
    % folder
    createDirIfDoesntExist(codeOutputDirectory,'functions');
    
    functionsUsed = inmem('-completenames') ; % identify all used functions with full path
    % Patch because parallel has been used
    if nargin==4
        functUsedBefCleanAll = {};
        % Extra work for parallel
        for iLoop = 1: size(functUsedBefClean,1)
            functUsedBefCleanAll = [functUsedBefCleanAll; functUsedBefClean{iLoop}];
        end
        functionsUsed = unique([functUsedBefCleanAll;functionsUsed]);
    end
    % Create a list of all of the custom functions used
    functionsUsedCustomIndex = strfind(functionsUsed, matlabroot) ; % create cell of matches
    functionsUsedCustomIndex = cellfun(@isempty,functionsUsedCustomIndex) ;% convert cell to logical vector
    functionsUsedCustom = functionsUsed(functionsUsedCustomIndex) ; % index the list to get only custom functions
    iTmpFilesTab = find(cellfun(@isempty,strfind(functionsUsedCustom,'/tmp/'))==1); % Remove temporary files

    % Copy all of the custom functions that were used to the code directory
    for iH=iTmpFilesTab'
        copyfile(functionsUsedCustom{iH}, [codeOutputDirectory,'functions/']) ; 
    end
    
    % Remove the main script from the function folder
    delete([codeOutputDirectory,'functions/',scriptName]);

end

    
