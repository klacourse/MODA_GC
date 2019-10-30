function scoreSpindles(eventsLocFileName, phaseLabel, startEpochNum,...
    nEpochsTot, nSampleInEpoch, pathOutput, annotScoreFolderName, FS, SCORECONFIDENCEVAL)
% Analyze the EventLocations and mark each spindles scored by each
%   annotator in the annotList file. One file per annotator is saved.
%
% Inputs:
%   eventsLocFileName : string of the eventsLocFileName file to read 
%   phaseLabel : string of the phase label to load (phase1 or phase2)
%   startEpochNum : double, the start index of the epoch number
%   nEpochsTot : double, total number of epochs
%   nSampleInEpoch : double, number of samples in one epoch
%   pathOutput : string of the path to save outputs
%   annotScoreFolderName : string, the folder name to save .mat score vector
%       for each annotator.
%   FS : double, frequency sampling rate.
%   SCORECONFIDENCEVAL : wide vector of double, confidence score [low, med, high]
% 
% Author: Karine Lacourse 2019-09-16
%   Changes log:
%   
%------------------------------------------------------------------------    
    %-----------------------------------------------
    % Read EventLocations to save ScoredVectorByAnnot.mat
    %-----------------------------------------------
    % filename	subID	epochNum	blockNum	annotatorID	MODA_batchNum	
    % annotatorEventIndex	startPercent	durationPercent	startSecs	
    % durationSecs	scoreConfidence
    expectedHdr = {'filename', 'phase', 'subID', 'epochNum', 'blockNum', 'annotatorID',...
        'MODA_batchNum', 'annotatorEventIndex', 'startPercent', 'durationPercent', ...
        'startSecs', 'durationSecs', 'scoreConfidence', 'TimeWindowFirstShown',...
        'TimeMarkerCreated', 'TimeMarkerLastModified', 'turkHitId', 'turkAssignmentId'...
        };
    phaseNumCol     = 2;
    epochNumCol     = 4;
    annotatorCol    = 6;
    startSecsCol    = 11;
    durationSecsCol = 12;
    scoreConfidCol  = 13;

    spindleScoredData       = readtext(eventsLocFileName,'[,\t]','#','"','textual');
    readHdr                 = spindleScoredData(1,:);
    % error check, file integrity
    if length(readHdr) ~= length(expectedHdr)
        error('The header of %s is not expected', eventsLocFileName);
    end
    if any(~strcmp(readHdr,expectedHdr))
        error('The header of %s is not expected', eventsLocFileName);
    end

    % Data extraction
    phaseLabelDataEvt          = spindleScoredData(2:end, phaseNumCol);
    nTotSpindlesEvt            = length(phaseLabelDataEvt);
    epochNumDataEvt            = spindleScoredData(2:end,epochNumCol);
    epochNumDataEvt            = cellfun(@str2num,epochNumDataEvt);
    annotatorDataEvt           = spindleScoredData(2:end,annotatorCol);
    startSecsCellEvt           = spindleScoredData(2:end,startSecsCol);
    durationSecsCellEvt        = spindleScoredData(2:end,durationSecsCol);
    scoreConfidDataEvt         = spindleScoredData(2:end,scoreConfidCol);

    startSecsIsEMpty        = cellfun(@isempty,spindleScoredData(2:end,startSecsCol));
    durationSecsIsEMpty     = cellfun(@isempty,spindleScoredData(2:end,durationSecsCol));

    if size(epochNumDataEvt,1)<nTotSpindlesEvt
        error('We miss exclusive epoch number');
    end

    if any(startSecsIsEMpty | durationSecsIsEMpty) 
        warning('We miss %i start sec', sum(startSecsIsEMpty));
        warning('We miss %i duration sec', sum(durationSecsIsEMpty));
        warning('Any events without startSecs or duration are discarded');
    end
    data2Take              = ~startSecsIsEMpty & ~durationSecsIsEMpty;
    phaseLabelDataEvt      = phaseLabelDataEvt(data2Take);
    epochNumDataEvt        = epochNumDataEvt(data2Take);
    annotatorDataEvt       = annotatorDataEvt(data2Take);
    startSecsDataEvt       = startSecsCellEvt(data2Take);
    durationSecsDataEvt    = durationSecsCellEvt(data2Take);
    scoreConfidDataEvt     = scoreConfidDataEvt(data2Take);

    nTotSpindlesEvt = length(phaseLabelDataEvt);
    fprintf('%i spindles marked kept including test and practice\n', nTotSpindlesEvt);

    startSecsMatEvt            = cellfun(@str2num,startSecsDataEvt);      
    durationSecsMatEvt         = cellfun(@str2num,durationSecsDataEvt);

    if size(startSecsMatEvt,1)<nTotSpindlesEvt
        warning('We miss %i start sec', nTotSpindlesEvt-size(startSecsMatEvt,1));
        warning('Any events without startSecs are discarded');
    end 
    if size(durationSecsMatEvt,1)<nTotSpindlesEvt
        warning('We miss %i duration sec',nTotSpindlesEvt-size(durationSecsMatEvt,1));
        warning('Any events without durationSecs are discarded');
    end     

    %-----------------------------------------
    % Extract data from EventLocations
    %-----------------------------------------
    % Extract data from the phase label needed only
    rightPhaseTab   = strcmp(phaseLabelDataEvt,phaseLabel);

    epochNumPhase           = epochNumDataEvt(rightPhaseTab==1);
    annotatorPhase          = annotatorDataEvt(rightPhaseTab==1);
    startSecsPhase          = startSecsMatEvt(rightPhaseTab==1);
    durationSecsPhase       = durationSecsMatEvt(rightPhaseTab==1);
    scoreConfidPhase        = scoreConfidDataEvt(rightPhaseTab==1);    
    % the epoch num is always incremented through the phases
    % phase#2 and phase#3 are combined
    epochNumPhase = epochNumPhase - startEpochNum;
    % Discard any epoch higher than nEpochFromEEGVect (considered phase#3)
    annotatorPhase(epochNumPhase > nEpochsTot)=[];
    startSecsPhase(epochNumPhase > nEpochsTot)=[];
    durationSecsPhase(epochNumPhase > nEpochsTot)=[];
    scoreConfidPhase(epochNumPhase > nEpochsTot)=[];
    epochNumPhase(epochNumPhase > nEpochsTot)=[];

    nTotSpindles = length(epochNumPhase);

    % Modify the string confidence by a number
    missingConf = 0;
    for iSpind = 1 : nTotSpindles
        switch char(scoreConfidPhase{iSpind})
            case char('high')
                scoreConfidPhase{iSpind} = SCORECONFIDENCEVAL(1);
            case char('med')
                scoreConfidPhase{iSpind} = SCORECONFIDENCEVAL(2);
            case char('low')
                scoreConfidPhase{iSpind} = SCORECONFIDENCEVAL(3);
            case char('')
                scoreConfidPhase{iSpind} = SCORECONFIDENCEVAL(2);
                missingConf = missingConf+1;
            otherwise
                error('%s is not expected as score confidence', scoreConfidPhase{iSpind});
        end
    end
    fprintf('%s : %i missing score confidence replaced by med score\n',...
        phaseLabel, missingConf);

    scoreConfidMat = cell2mat(scoreConfidPhase);
    if size(scoreConfidMat,1)<nTotSpindles
        error('We still miss score confidence');
    end

    % Read the list of annotators
    listOfFilesAvailable    = dir([pathOutput,annotScoreFolderName]);
    FileNameList            = generateRealList(listOfFilesAvailable,'.mat');    
    nAnnot                  = length(FileNameList);
    
    % Remove the nan between each epoch to compute the length in sec
    epochLengthInSec = (nSampleInEpoch-1) / FS;
    
    % Phase and userSubTypeLabel are selected
    % For each selected annotator 
    parfor iExp = 1:nAnnot
%     for iExp = 1:nAnnot
        annotatorName   = FileNameList{iExp};
        annotatorName   = annotatorName(1:regexp(annotatorName,'-')-1);
        expertTab       = strcmp(annotatorPhase,annotatorName);
        iSpindleExp     = find(expertTab==1);
        epochNumExp     = epochNumPhase(iSpindleExp);
        startSecsExp    = startSecsPhase(iSpindleExp);
        durationSecsExp = durationSecsPhase(iSpindleExp);
        scoreConfidExp  = scoreConfidMat(iSpindleExp);

        % Load the scoredVectorByAnnot with epochs viewed marked
        fileName2Save = sprintf('%s/%s/%s-ScoredVectorByAnnot.mat', ...
            pathOutput, annotScoreFolderName, annotatorName);

        % Verify if the file exist
        name2Find = sprintf('%s-ScoredVectorByAnnot.mat', annotatorName);
        if any(strcmpi(FileNameList,name2Find))
            % Analyze the EventLocations and mark each spindles scored by each
            % annotator in the annotListFileName file
            saveScoredVectorWithEventLocations( fileName2Save, epochNumExp,...
                startSecsExp, durationSecsExp, scoreConfidExp, ...
                nSampleInEpoch, epochLengthInSec, FS);
        else
            warning('%s is not found', fileName2Save);
        end
    end    
end

