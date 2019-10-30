% Script to generate the average score vector and the Group
% Consensus vector each user subtype "experts (exp), researchers (re), Non-experts (ne)" 
% and each phase (phase 1 and phase 2) of MODA.
%
% Generates the score averaged across annotators as a "scoreAvg_usr_px.mat"
%   (without 2.5 s overlap between consecutive epoch).
%   -highest score is taken between duplicated samples (2.5 s overlap)
%   -no Group Concensus threshold applied, then no spindle length rules applied.
%
% Generates the GC vector as a "GCVect_usr_px.mat"
%   (without 2.5 s overlap between consecutive epoch).
%   - The Group Concensus threshold is applied
%   - The spindle length rules are applied.
%
% Writes the list of GC spindles into a text file "GC_spindlesLst_user_px.txt".
%
% A folder is also created with the score vector of each annotator.
% The score is NaN when the annotator has not seen the epoch.
%
% There is a NaN between each block of 115 s (FS=100 Hz) in all the .mat vectors
% created.
%
% Inputs:
%   For experts and researchers
%   - 1_EpochViews_exp_re_90.txt
%   - 3_EventLocations_exp_re_90.txt
%   - 5_userSubtypeAnonymLUT_exp_re_20190521
%   For non-experts
%   - 2_EpochViews_ne_90.txt
%   - 4_EventLocations_ne_90.txt
%
% Outputs (all possibilities):
%   *** If 'exp' is chosen
%   - scoreAvg_exp_p1.mat
%   - scoreAvg_exp_p2.mat
%   - GCVect_exp_p1.mat
%   - GCVect_exp_p2.mat
%   - GC_spindlesLst_exp_p1.txt
%   - GC_spindlesLst_exp_p2.txt
%   *** If 're' is chosen
%   - scoreAvg_re_p1.mat
%   - GCVect_re_p1.mat
%   - GC_spindlesLst_re_p1.txt
%   *** If 'ne' is chosen
%   - scoreAvg_ne_p1.mat
%   - GCVect_ne_p1.mat
%   - GC_spindlesLst_ne_p1.txt
% 
% Author: Karine Lacourse 2019-09-13
%   Changes log:
%   
%--------------------------------------------------------------------------

% INIT
NEPOCHS_PHASE1 = 2025; % Number of epochs in the phase 1
NEPOCHS_PHASE2 = 1725; % Number of epochs in the phase 2
NSAMPLESINEPOCH = 2501; % Number of samples in one epoch including overlap
NSAMPLESINBLOCK = 11501; % Number of samples in one block without overlap
NSECOVERLAP = 2.5; % Duration of the overlap between epochs (in sec)
NEPOCHSINBLOCK = 5; % Number of epochs in one block
FS = 100; % Frequency sampling rate (Hz)
% Score for [high, med, low]
SCORECONFIDENCEVAL = [1, 0.75, 0.5]; % score to convert label to number

%----------------------------
% Expected number of samples
%----------------------------
% NSAMPLESINEPOCH * NEPOCHS_PHASEX
% nTotSamples (epochs) p1 : 5,064,525
% nTotSamples (epochs) p2 : 4,314,225
% NSAMPLESINBLOCK * NEPOCHS_PHASEX / NEPOCHSINBLOCK
% nTotSamples (segs) p1 : 4,657,905
% nTotSamples (segs) p2 : 3,967,845

%-----------------------------------------------------------------------
%% Start of the Package Analysis: Create the structure needed to save all the analysis
%-----------------------------------------------------------------------
% Experts
if strcmp(userSubtype,'exp')
    GCTHRESH = GCTHRESH_EXP; % Group Consensus threshold
    inputPathPackageDir{1} = [genInputPackage,'3_EventLocations_exp_re_90.txt'];
    inputPathPackageDir{2} = [genInputPackage,'1_EpochViews_exp_re_90.txt'];
    inputPathPackageDir{3} = [genInputPackage,'5_userSubtypeAnonymLUT_exp_re_20190521.txt'];
    NPHASES = 2;
% Researchers
elseif strcmp(userSubtype,'re')
    GCTHRESH = GCTHRESH_RE; % Group Consensus threshold
    inputPathPackageDir{1} = [genInputPackage,'3_EventLocations_exp_re_90.txt'];
    inputPathPackageDir{2} = [genInputPackage,'1_EpochViews_exp_re_90.txt'];
    inputPathPackageDir{3} = [genInputPackage,'5_userSubtypeAnonymLUT_exp_re_20190521.txt'];
    NPHASES = 1;
% Non-Experts
elseif strcmp(userSubtype,'ne')
    GCTHRESH = GCTHRESH_NE; % Group Consensus threshold
    inputPathPackageDir{1} = [genInputPackage,'4_EventLocations_ne_90.txt'];
    inputPathPackageDir{2} = [genInputPackage,'2_EpochViews_ne_90.txt'];
    NPHASES = 1;
else
    error('Unexpected userSubtype');
end

% The name of the current script
curScriptStruct     = dbstack();
scriptName          = curScriptStruct(1).file;
packageName         = 'MODA01_pack'; % The name of the package analysis 

addpath(genpath('./lib')); % Add library
totalProTimeStart = tic ; % timekeeping for totalProTime

% Create the structure needed to save all the analysis
DEF = createStructFolder4MODA( genPathPackage, packageName, userSubtype);
pathOutput = DEF.pathOutput;

%-----------------------------------------------------------------------
%% Core of the script
%-----------------------------------------------------------------------

%------------------------------------------------------------
% Select the appropriate annotators based on the userSubtype
%------------------------------------------------------------
    if ~strcmp(userSubtype,'ne')
        usersIDSel = select_userID_fromSubtype(inputPathPackageDir{3}, userSubtype);
        fprintf('%i %s selected from the user subtype (all phases)\n',...
            length(usersIDSel), userSubtype);
    else
        usersIDSel = {};
    end

%------------------------------------------------------------
% Mark the epochs viewed by each annotator
% -> No score at all, only zeros when the epoch is viewed
%------------------------------------------------------------
    fprintf('... Marking the epochs viewed by each annotator\n');
    epochViewsFileName = inputPathPackageDir{2};
    phaseLabel = 'phase1';
    % To avoid out of memory error
    % A file is created for each annotators
    annotScoreFolderName = ['p1_', userSubtype];
    createDirIfDoesntExist(pathOutput,annotScoreFolderName);
    scoreEpochViewed(epochViewsFileName, phaseLabel, usersIDSel, 0, ...
        NEPOCHS_PHASE1, NSAMPLESINEPOCH, pathOutput, annotScoreFolderName);
    if NPHASES==2
        phaseLabel = 'phase2';
        annotScoreFolderName = ['p2_', userSubtype];
        createDirIfDoesntExist(pathOutput,annotScoreFolderName);
        scoreEpochViewed(epochViewsFileName, phaseLabel, usersIDSel, NEPOCHS_PHASE1,...
            NEPOCHS_PHASE2, NSAMPLESINEPOCH, pathOutput, annotScoreFolderName);
    end

%------------------------------------------------------------
% Mark the spindles scored by each annotator
%   with 2.5 s overlap between consecutive epochs
%------------------------------------------------------------
    fprintf('... Marking the spindles scored by each annotator\n');
    eventsLocFileName = inputPathPackageDir{1};

    phaseLabel = 'phase1';
    annotScoreFolderName = ['p1_', userSubtype];
    scoreSpindles(eventsLocFileName, phaseLabel, 0, NEPOCHS_PHASE1, ...
        NSAMPLESINEPOCH, pathOutput, annotScoreFolderName, FS, ...
        SCORECONFIDENCEVAL);
    if NPHASES==2
        phaseLabel = 'phase2';
        annotScoreFolderName = ['p2_', userSubtype];
        createDirIfDoesntExist(pathOutput,annotScoreFolderName);
        scoreSpindles(eventsLocFileName, phaseLabel, NEPOCHS_PHASE1, ...
            NEPOCHS_PHASE2, NSAMPLESINEPOCH, pathOutput, annotScoreFolderName,...
            FS, SCORECONFIDENCEVAL);
    end    

%------------------------------------------------------------
% Convert the scores per epoch (including the 2.5 s overlap 
% between consecutive epochs) into scores per block of 115 s
% without overlap.
%
%   Select the highest score between duplicated samples 
%       2.5 s overlap between epoch
%------------------------------------------------------------
    fprintf('... Selecting the highest score between duplicated samples\n');
    nEpochs = NEPOCHS_PHASE1;
    annotScoreFolderName = ['p1_', userSubtype,'/'];
    [warningLst] = convertEpochScores2Block(pathOutput, annotScoreFolderName, ...
        NSAMPLESINEPOCH, NSAMPLESINBLOCK, nEpochs, NEPOCHSINBLOCK, round(NSECOVERLAP*FS));
    cell2tab([DEF.pathWarning,'p1_warning.txt'], warningLst, 'w');

    if NPHASES==2
        nEpochs = NEPOCHS_PHASE2;
        annotScoreFolderName = ['p2_', userSubtype,'/'];
        [warningLst] = convertEpochScores2Block(pathOutput, annotScoreFolderName, ...
            NSAMPLESINEPOCH, NSAMPLESINBLOCK, nEpochs, NEPOCHSINBLOCK, round(NSECOVERLAP*FS));
        cell2tab([DEF.pathWarning,'p2_warning.txt'], warningLst, 'w');    
    end
    
%-----------------------------------------------
% Average the scores across annotators
%-----------------------------------------------    
    fprintf('... Averaging the scores across annotatorss\n');
    annotScoreFolderName = ['p1_', userSubtype,'/'];
    scoreVectorAvgFileName = ['scoreAvg_',userSubtype, '_', 'p1.mat'];
    nEpochs = NEPOCHS_PHASE1;
    nTotSamples_seg = NSAMPLESINBLOCK * nEpochs / NEPOCHSINBLOCK;
    averageScores(pathOutput, annotScoreFolderName, scoreVectorAvgFileName,...
        nTotSamples_seg);
    
    if NPHASES==2
        annotScoreFolderName = ['p2_', userSubtype,'/'];
        scoreVectorAvgFileName = ['scoreAvg_',userSubtype, '_', 'p2.mat'];
        nEpochs = NEPOCHS_PHASE2;
        nTotSamples_seg = NSAMPLESINBLOCK * nEpochs / NEPOCHSINBLOCK;        
        averageScores(pathOutput, annotScoreFolderName, ...
            scoreVectorAvgFileName, nTotSamples_seg);
    end    

    
%-----------------------------------------------
% Apply the GC threshold and manage the spindle length
%-----------------------------------------------        
    fprintf('... Applying the GC threshold and managing the spindle length\n');
    for iPhase = 1 : NPHASES

        % To load the average scores
        tmp = load([pathOutput,'/scoreAvg_', ...
            userSubtype,'_p', num2str(iPhase),'.mat']);
        avgScoresVect = tmp.(char(fieldnames(tmp)));
        nTotalSample = length(avgScoresVect);

        % Convert avg scores into a binary vector (and keep the nan)
        avgScoresVect( avgScoresVect > GCTHRESH{iPhase}) = 1;
        avgScoresVect( avgScoresVect <= GCTHRESH{iPhase}) = 0;

        % Merge, remove too short and too long spindles from the Group Consensus
        GCVect = nan(nTotalSample,1);
        % Start/Stop index of each segment
        iStartSeg = 1 : NSAMPLESINBLOCK : nTotalSample;
        iStopSeg = NSAMPLESINBLOCK : NSAMPLESINBLOCK : nTotalSample;    
        for iSeg = 1 : length(iStartSeg)
            curSeg = avgScoresVect(iStartSeg(iSeg):iStopSeg(iSeg));
            if ~any(isnan(curSeg(1:end-1)))
                GCVect(iStartSeg(iSeg):iStopSeg(iSeg)) = ...
                    mergeAndCutEvents( curSeg, FS, SPINDLELENGTH.max,...
                    SPINDLELENGTH.min, SPINDLELENGTH.merge );
            end
        end

        % Save the GC vector (.mat file)
        save([pathOutput,'GCVect_',userSubtype, '_p', num2str(iPhase),'.mat'],'GCVect');
    end
    

%-----------------------------------------------
% Write the list of spindles from the GC into a text file
%-----------------------------------------------            
fprintf('... Writing the list of spindles from the GC into a text file\n');
    rowHeader = {'eventNum', 'startSamples', 'durationSamples', 'startSec', 'durationSec'};
    for iPhase = 1 : NPHASES
        tmp = load([pathOutput,'GCVect_',userSubtype, '_p', num2str(iPhase),'.mat']);
        GCVect = tmp.(char(fieldnames(tmp)));
        GCVectNoNaN = GCVect;
        GCVectNoNaN(isnan(GCVectNoNaN))=0;
        [ssStarts, ssEnds, ssDur] = event_StartsEndsDurations(GCVectNoNaN); 
        % Write the header
        cell2tab([pathOutput,'GC_spindlesLst_',userSubtype, '_p', ...
            num2str(iPhase),'.txt'], rowHeader, 'w');
        % Write the spindles list
        eventNum = num2cell(1:length(ssStarts));
        eventNum = eventNum';
        startSamples = num2cell(ssStarts);
        durationSamples = num2cell(ssDur);
        startSec = num2cell(round(ssStarts/FS,2));
        durationSec = num2cell(round(ssDur/FS,2));
        cell2Write = [eventNum, startSamples, durationSamples, startSec, durationSec];
        cell2tab([pathOutput,'GC_spindlesLst_',userSubtype, '_p', ...
            num2str(iPhase),'.txt'], cell2Write, 'a');
    end


    
    
%--------------------------------------------------------------------------
%% END of Package analysis 
%--------------------------------------------------------------------------
fprintf('End of the package... saving files\n');

% Copy the input files into the input folder
    FID = fopen([DEF.pathInput,'path.txt'],'w'); 
    for iF = 1 : length(inputPathPackageDir)
        fprintf(FID,'%s\n',inputPathPackageDir{iF});
    end
    fclose(FID);
    
% Write the processing time in the info dir
% toc for total processing time, convert to hhmmss
    totalProTime = secs2hms(toc(totalProTimeStart)); 
    cell2tab(fullfile(DEF.pathInfo, 'processingTimeTotal_hms.txt'), ...
        cellstr(totalProTime), 'a');

% Package analysis :  Add all the code used in the code directory 
% of the analysis package
    codeInputDirectory = pwd;
    cleanUp(scriptName, codeInputDirectory, DEF.pathCode);

