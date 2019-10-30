% Script to generate the EEG vector of all the 115 s blocks 
% concatenated in one tall vector.  A vector is generated for each phase 
% (phase 1 and phase 2) of MODA.
% A NaN is added between each 115 s block.
% 
% Author: Karine Lacourse 2019-09-26
%   Changes log:
%   
%--------------------------------------------------------------------------

% INIT
FS              = 100; % Frequency Sampling to reduce the processing time
% All possible primary channels loaded from the EDF
PRIMCHAN        = {'C3-A2','C3-LE'};
BLOCKDURSEC     = 115; % 22.5 sec *4 + 25 sec
NPHASES         = 2; % Number of phases in the MODA project

% Path of the input files : list of the block extracted from the EEG file
inputPathPackageDir{1} = [genInputPackage,'6_segListSrcDataLoc_p1.txt'];% Phase 1
inputPathPackageDir{2} = [genInputPackage,'7_segListSrcDataLoc_p2.txt'];% Phase 2

% The name of the current script
curScriptStruct     = dbstack();
scriptName          = curScriptStruct(1).file;
packageName         = 'MODA02_pack'; % The name of the package analysis 

addpath(genpath('./lib')); % Add library
totalProTimeStart = tic ; % timekeeping for totalProTime

% Create the structure needed to save all the analysis
DEF = createStructFolder4MODA(genPathPackage, packageName);
pathOutput = DEF.pathOutput;

%--------------------------------------------------------------------------
%% Read file
%--------------------------------------------------------------------------
% Header of the source eeg data
% Header : epochNum	subjectID	blockNumSrc	blockNumExp	epochStartSample
epochNumCol         = 1;
subjectIDCol        = 2;
blockNumExpCol      = 4;
epochStartSampleCol = 5;

EEGvectorFileName = 'EEGVect'; % The filename of the output file
pathXMLFileTmp = pathXMLFile{1};
pathEDFFileTmp = pathEDFFile{1};
% parfor iphase = 1 : NPHASES
for iphase = 1 : NPHASES

    % Read the epochListSrcDataLoc
    dataSrcEEG              = readtext(inputPathPackageDir{iphase},'[,\t]');
    epochNumData            = cell2mat(dataSrcEEG(2:end,epochNumCol));
    subjectIDData           = dataSrcEEG(2:end,subjectIDCol);
    blockNumExpData         = cell2mat(dataSrcEEG(2:end,blockNumExpCol));
    epochStartSampleData    = cell2mat(dataSrcEEG(2:end,epochStartSampleCol));
   
    subjectIDUniq           = unique(subjectIDData);
    nSubjects               = length(subjectIDUniq);
    nSegments               = length(epochNumData);

    fprintf('phase#%i: %i subjects\n', iphase, nSubjects);

    % Add a NaN (+1) between each epoch
    nSampleInSeg  = BLOCKDURSEC * FS + 1;
    EEGvector       = nan(nSegments * nSampleInSeg,1);
    filenameVector  = cell(nSegments,1);

    for iSjt = 1: nSubjects

        % find the epoch 
        iSjtEpochLst = find(strcmp(subjectIDUniq{iSjt},subjectIDData)==1);

        % set the EDF/XML to load
        EDFfilename = sprintf('MODA_%s.edf',subjectIDUniq{iSjt});
        XMLfilename = sprintf('MODA_%s.edf.XML',subjectIDUniq{iSjt});    
        
        % Error check
        if isempty(iSjtEpochLst)
           warning('No epoch found for %s', subjectIDUniq{iSjt}); 
        end    

        % Load the data for the whole night
        % LOAD EDF-XML, extract the data, filter and re-sampled
        primChanData = EDFLoadResampleFilterNoVerbose(pathEDFFileTmp,...
            EDFfilename, pathXMLFileTmp, XMLfilename, FS, PRIMCHAN);

        % Store each epoch in the EEG vector
        for iSjtEpoch = 1 : length(iSjtEpochLst)
            iEpoch = iSjtEpochLst(iSjtEpoch);
            epochStartSample = epochStartSampleData(iEpoch);
            data2plot = primChanData(epochStartSample+1: epochStartSample+nSampleInSeg-1);        
            % We step the NaN between each epoch
            EEGvector( (iEpoch-1)*nSampleInSeg +1: iEpoch*nSampleInSeg-1, 1 ) = ...
                data2plot;
            filenameVector{iEpoch} = sprintf('e%i-b%i-%s-smp%i.png', iEpoch, ...
            blockNumExpData(iEpoch), subjectIDData{iEpoch}, epochStartSampleData(iEpoch));         
        end

        fprintf('%s written in the EEG vector\n', subjectIDUniq{iSjt});
    end

    % Save the tall eeg vector, a function is needed for the parallel use.
    saveEEGVector( pathOutput, iphase, EEGvector, EEGvectorFileName );
    
    % Add all the code used in the code directory of the analysis package
    codeInputDirectory = pwd;
    cleanUp(scriptName, codeInputDirectory, DEF.pathCode);
end

%--------------------------------------------------------------------------
%% End of the package analysis
%--------------------------------------------------------------------------
% If files are big, it is better to write its path
FID = fopen([DEF.pathInput,'path.txt'],'w'); 
for iF = 1 : length(inputPathPackageDir)
    fprintf(FID,'%s\n',inputPathPackageDir{iF});
end
for iF = 1 : length(pathEDFFile)
    fprintf(FID,'%s\n',pathEDFFile{iF});
end
for iF = 1 : length(pathXMLFile)
    fprintf(FID,'%s\n',pathXMLFile{iF});
end
fclose(FID);

% Write the processing time in the info dir
totalProTime = secs2hms(toc(totalProTimeStart)); % toc for total processing time, convert to hhmmss
cell2tab(fullfile(DEF.pathInfo, 'processingTimeTotal_hms.txt'), ...
    cellstr(totalProTime), 'a');

% Add all the code used in the code directory of the analysis package
codeInputDirectory = pwd;
cleanUp(scriptName, codeInputDirectory, DEF.pathCode);

fprintf('Files are written into %s\nand the code is saved into %s\n', ...
    pathOutput, DEF.pathCode);

% Clean the matlab path
rmpath(genpath('./lib'));
