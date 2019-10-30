function [DEF, stampFileName, dateFormated] = createStructFolder4PackageA( genPathPackage,...
    packageName, packageRev, dateFormatedRev)
% Function to create the structure needed to save all the analysis package
% and generate the name of the stamp text file to identify the package used
% as input.
%
% Input
%   genPathPackage  : string path of the folder to save the analysis package
%                       ex) /media/warbyCommon/ComputeLab/analyses/MrOs/
%   packageName     : string analysis package name
%                       ex) pheno.ArtifactDet.m
%   packageRev (optional) : string, path of the revision to update
%       ex) '/media/warbyCommon/ComputeLab/analyses/WSC_subset/A2A7ssDetect.m/20170424_A2A7ssDetect.m';
%   dateFormatedRev (optional) : string, the date of the revision to update
%        ex) '20170424'       
%
% Output
%   DEF             : struct with the path of the subfolder of the package
%                       analysis
%   stampFileName   : string of the filename of the stamp file
%                       to identify an output taken as input for the
%                       current analysis
%   dateFormated    : string of the current date and time
%
% Author : Karine Lacourse 2016-08-31
% Change logs : Karine Lacourse 2019-09-23 : output the dateFormated
%-----------------------------------------------------------------------
    
    %---------------------------------------------------------------------
    % Update a revision
    %---------------------------------------------------------------------
    if nargin == 4
        dateFormated        = dateFormatedRev;
        stampFileName       = ['_usedAsInput_',packageName,'_',dateFormated];
        DEF.pathPackages    = [genPathPackage, packageName, '/'];
        % Look if the revision exist
        % Create a list of files included in the input path
        listIncludedInFolder = dir(DEF.pathPackages);
        startIndex      = regexp(packageRev,'/');
        packageRevName  = packageRev(startIndex(end-1)+1:startIndex(end)-1);
        folderNameLst   = cell(size(listIncludedInFolder,1),1);
        for iFolder = 1 : size(listIncludedInFolder,1)
            folderNameLst{iFolder}   = listIncludedInFolder(iFolder).name;
        end
        if ~any(strcmp(folderNameLst, packageRevName))
            error('The packageRev to update does not exist');
        end
        % Set all paths
        DEF.pathAnalysis    = packageRev;
        DEF.pathInput       = [DEF.pathAnalysis,'input/'];
        DEF.pathOutput      = [DEF.pathAnalysis,'output/'];
        DEF.pathCode        = [DEF.pathAnalysis,'code/'];
        DEF.pathWarning     = [DEF.pathAnalysis,'warning/'];  
        DEF.pathInfo        = [DEF.pathAnalysis,'info/'];  
        
    %---------------------------------------------------------------------
    % Create a new revision
    %---------------------------------------------------------------------        
    elseif nargin==2
        % Manage the stamp text file to identify the package used as input
        formatOut           = 'yyyymmdd_HHMMSS';
        dateFormated        = datestr(now,formatOut);
        stampFileName       = ['_usedAsInput_',packageName,'_',dateFormated];
        % Create the package analysis
        createDirIfDoesntExist(genPathPackage,packageName);
        DEF.pathPackages = [genPathPackage,packageName,'/'];
        % create the current analysis folder
        createDirIfDoesntExist(DEF.pathPackages,[dateFormated,'_',packageName]);
        DEF.pathAnalysis = [DEF.pathPackages,[dateFormated,'_',packageName],'/'];
        % create the folder input
        createDirIfDoesntExist(DEF.pathAnalysis,'input');
        DEF.pathInput = [DEF.pathAnalysis,'input/'];
        % create the folder output
        createDirIfDoesntExist(DEF.pathAnalysis,'output');
        DEF.pathOutput = [DEF.pathAnalysis,'output/'];
        % create the folder code
        createDirIfDoesntExist(DEF.pathAnalysis,'code');
        DEF.pathCode = [DEF.pathAnalysis,'code/'];
        % create the folder warning
        createDirIfDoesntExist(DEF.pathAnalysis,'warning');
        DEF.pathWarning = [DEF.pathAnalysis,'warning/'];    
        % create the folder info
        createDirIfDoesntExist(DEF.pathAnalysis,'info');
        DEF.pathInfo        = [DEF.pathAnalysis,'info/'];  
        
    elseif nargin<2
        error('The input arguments are wrong');
    end

end

