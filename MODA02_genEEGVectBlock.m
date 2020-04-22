% Script to generate the EEG vector of all the 115 s blocks 
% concatenated in one tall vector.  A vector is generated for each phase 
% (phase 1 and phase 2) of MODA.
% A NaN is added between each 115 s block.
% 
%   * warning : a block has not been presented to the scorers
%   * 	then the subject 01-02-13 has only 2 blocks
%   * 	the epoch num 1956 to 1960 have been removed from 
%   * 	the file 6_segListSrcDataLoc_p1.txt
%   * 	Real total number of block is 404
%
% Author: Karine Lacourse 2019-09-26
%   Changes log:
%   
%--------------------------------------------------------------------------

% INIT
FS              = 100; % Frequency Sampling to reduce the processing time
BLOCKDURSEC     = 115; % 22.5 sec *4 + 25 sec
NPHASES         = 2; % Number of phases in the MODA project
NSEGMENTS       = {405,345};
NEPOCHSINBLOCK  = 5; % Number of epochs in one block

% Path of the input files : list of the block extracted from the EEG file
inputPathPackageDir{1} = [genInputPackage,'6_segListSrcDataLoc_p1.txt'];% Phase 1
inputPathPackageDir{2} = [genInputPackage,'7_segListSrcDataLoc_p2.txt'];% Phase 2
% The list of the eeg reference is used
inputPathPackageDir{3} = [genInputPackage,'8_MODA_primChan_180sjt.txt'];

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
epochStartSecCol    = 5;

% The list of eeg channel reference used
[eegChanRef_data] = readtext(inputPathPackageDir{3},'[,\t]');

EEGvectorFileName = 'EEGVect'; % The filename of the output file
pathEDFFileTmp = pathEDFFile{1};
% parfor iPhase = 1 : NPHASES
for iPhase = 1 : NPHASES

    % Read the epochListSrcDataLoc
    dataSrcEEG              = readtext(inputPathPackageDir{iPhase},'[,\t]');
    epochNumData            = cell2mat(dataSrcEEG(2:end,epochNumCol));
    subjectIDData           = dataSrcEEG(2:end,subjectIDCol);
    blockNumExpData         = cell2mat(dataSrcEEG(2:end,blockNumExpCol));
    epochStartSecData    = cell2mat(dataSrcEEG(2:end,epochStartSecCol));
   
    subjectIDUniq           = unique(subjectIDData);
    nSubjects               = length(subjectIDUniq);

    fprintf('phase#%i: %i subjects\n', iPhase, nSubjects);

    % Add a NaN (+1) between each epoch
    nSampleInSeg  = BLOCKDURSEC * FS + 1;
    EEGvector       = nan(NSEGMENTS{iPhase} * nSampleInSeg,1);
    filenameVector  = cell(NSEGMENTS{iPhase},1);

    for iSjt = 1: nSubjects

        % find the epoch 
        iSjtSegIncLst = find(strcmp(subjectIDUniq{iSjt},subjectIDData)==1);
        iSjtEpochLst = epochNumData(iSjtSegIncLst);
        
        % set the EDF to load
        EDFfilename = sprintf('%s PSG.edf',subjectIDUniq{iSjt});
        
        % Error check
        if isempty(iSjtEpochLst)
           warning('No epoch found for %s', subjectIDUniq{iSjt}); 
        end    
        
        % Find the channel label to know the reference
        chanRef = eegChanRef_data(strcmp(eegChanRef_data(:,1),[subjectIDUniq{iSjt},'.edf']),2);
        
        % Load the data for the whole night
        % LOAD EDF, extract the primary channel and ref channel if available, 
        % filter and re-sampled to FS (100 Hz)
        [primChanData, warningLst] = MASSEDFLoadResampleFilter(pathEDFFileTmp,...
           EDFfilename, FS, chanRef{1});
        

        % Store each epoch in the EEG vector
        for iSjtEpoch = 1 : length(iSjtEpochLst)
            iEpoch = iSjtEpochLst(iSjtEpoch);
            iSegInc = iSjtSegIncLst(iSjtEpoch);
            epochStartSec = epochStartSecData(iSegInc);
            % -1 to avoid ploting the nan 
            data2plot = primChanData(round(epochStartSec*FS)+1: round(epochStartSec*FS)+nSampleInSeg-1);        
            % We step the NaN between each epoch
            iSegReal = floor((iEpoch-1)/NEPOCHSINBLOCK)+1;
            EEGvector( (iSegReal-1)*nSampleInSeg +1: iSegReal*nSampleInSeg-1, 1 ) = ...
                data2plot;
            filenameVector{iEpoch} = sprintf('e%i-b%i-%s-sec%i.png', iEpoch, ...
            blockNumExpData(iSegInc), subjectIDData{iSegInc}, epochStartSecData(iSegInc));         
        end

        fprintf('%s written in the EEG vector\n', subjectIDUniq{iSjt});
    end

    % Save the tall eeg vector, a function is needed for the parallel use.
    saveEEGVector( pathOutput, iPhase, EEGvector, EEGvectorFileName );
    
    % Add all the code used in the code directory of the analysis package
    codeInputDirectory = pwd;
    cleanUp(scriptName, codeInputDirectory, DEF.pathCode);
end

%--------------------------------------------------------------------------
%% End of the package analysis
%--------------------------------------------------------------------------
% Write warnings
cell2tab([DEF.pathWarning,'warning.txt'], warningLst, 'w');

% If files are big, it is better to write its path
FID = fopen([DEF.pathInput,'path.txt'],'w'); 
for iF = 1 : length(inputPathPackageDir)
    fprintf(FID,'%s\n',inputPathPackageDir{iF});
end
for iF = 1 : length(pathEDFFile)
    fprintf(FID,'%s\n',pathEDFFile{iF});
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

