function [DEF, dateFormated] = createStructFolder4MODA( ...
    genPathPackage, packageName, userSubtype)
% Function to create the structure needed to save all the analysis package
% and generate the name of the stamp text file to identify the package used
% as input.
%
% Input
%   genPathPackage  : string path of the folder to save the analysis package
%                       ex) /media/warbyCommon/ComputeLab/analyses/MrOs/
%   packageName     : string analysis package name
%                       ex) pheno.ArtifactDet.m
%   userSubtype     : string, user subtype ex. 'exp', 're', 'ne'
%
% Output
%   DEF             : struct with the path of the subfolder of the package
%                       analysis
%   dateFormated    : string of the current date and time
%
% Author : Karine Lacourse 2019-09-23
%-----------------------------------------------------------------------
    
    % Manage the stamp text file to identify the package used as input
    formatOut           = 'yyyymmdd_HHMMSS';
    dateFormated        = datestr(now,formatOut);

    % Create the package analysis
    createDirIfDoesntExist(genPathPackage,packageName);
    DEF.pathPackages = [genPathPackage,packageName,'/'];
    % create the current analysis folder
    if nargin==3
        createDirIfDoesntExist(DEF.pathPackages,[dateFormated,'_',userSubtype,'.m']);
        DEF.pathAnalysis = [DEF.pathPackages,[dateFormated,'_',userSubtype],'.m/'];
    elseif nargin==2
        createDirIfDoesntExist(DEF.pathPackages,[dateFormated,'.m']);
        DEF.pathAnalysis = [DEF.pathPackages,dateFormated,'.m/'];   
    else
        error('We expect 2 or 3 input arguments');
    end
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

end

