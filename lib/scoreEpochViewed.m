function scoreEpochViewed(epochViewsFileName, phaseLabel, usersIDSel,...
    startEpochNum, nEpochsTot, nSampleInEpoch, pathOutput, annotScoreFolderName)
% Analyze the epochViews file and mark each epoch viewed by each
% annotator in the annotScore folder, one file per annotator is saved.
% No score at all, only zeros when the epoch is viewed
%
% Inputs:
%   epochViewsFileName : string of the epochViewsFileName file to read 
%   phaseLabel : string of the phase label to load (phase1 or phase2)
%   usersIDSel : cell of string of the scorerID selected (user subtype)
%   startEpochNum : double, the start index of the epoch number
%   nEpochsTot : double, total number of epochs
%   nSampleInEpoch : double, number of samples in one epoch
%   pathOutput : string of the path to save outputs
%   annotScoreFolderName : string, the folder name to save .mat score vector
%       for each annotator.
% 
% Author: Karine Lacourse 2019-09-13
%   Changes log:
%   
%------------------------------------------------------------------------

    % Read epochViewsFileName
    % filename	epochNum	blockNum    phase	annotatorID
    expectedHdr = {'filename', 'epochNum', 'blockNum', 'phase', 'annotatorID',...
        'hitId', 'assignmentId'};
    epochsViewData          = readtext(epochViewsFileName,'[,\t]','#','"','textual');
    readHdr                 = epochsViewData(1,:);
    % error check
    if length(readHdr) ~= length(expectedHdr)
        error('The header of %s is not expected', epochViewsFileName);
    end
    if any(~strcmp(readHdr,expectedHdr))
        error('The header of %s is not expected', epochViewsFileName);
    end

    % To mark no spindle every epochs not seen by the expert
    % Eventually only the epoch num will be enough
    epochNumCol     = 2;
    phaseNumCol     = 4;
    annotatorCol    = 5;
    epochNumData    = epochsViewData(2:end, epochNumCol);
    epochNumData    = cellfun(@str2num,epochNumData);
    phaseLabelData  = epochsViewData(2:end, phaseNumCol);
    annotatorData   = epochsViewData(2:end, annotatorCol);

    % Extract data from the phase label needed only
    % Only for epoch viewed
    rightPhaseTab   = strcmp(phaseLabelData,phaseLabel);
    epochNumData    = epochNumData(rightPhaseTab==1);
    annotatorData   = annotatorData(rightPhaseTab==1);
    phaseLabelData  = phaseLabelData(rightPhaseTab==1);
    
    % the epoch num is always incremented through the phases
    % phase#2 and phase#3 are combined
    epochNumData = epochNumData - startEpochNum;
    % Discard any epoch higher than nEpochFromEEGVect (considered phase#3)
    phaseLabelData(epochNumData > nEpochsTot)=[];
    annotatorData(epochNumData > nEpochsTot)=[];
    epochNumData(epochNumData > nEpochsTot)=[];

    % error check
    nRows           = size(phaseLabelData,1);
    if size(epochNumData,1) ~= nRows
        error('Epoch number are missing');
    end

    % Extract data from the selected users only
    AnnotatorList   = unique(annotatorData);
    nAnnot          = length(AnnotatorList);
    fprintf('%i annotators from the selected phase\n', nAnnot);   
    if ~isempty(usersIDSel)
        selectAnnotLst = cell(0);
        for iannot = 1:nAnnot
            if any(strcmp(usersIDSel,AnnotatorList{iannot}))
                selectAnnotLst(end+1) = AnnotatorList(iannot);
            end
        end
        AnnotatorList = selectAnnotLst;
    end
    nAnnot        = length(AnnotatorList);  
    fprintf('%i annotators from the selected phase and user subtype\n', nAnnot);   

    % Total number of samples in the current phase
    nTotSamples = nSampleInEpoch * nEpochsTot;
    
    % Mark no spindle every epochs not seen by the annotator
%     parfor iExp = 1:nAnnot
    for iExp = 1:nAnnot
        annotatorName = AnnotatorList{iExp};
        fileName2Save = sprintf('%s/%s/%s-ScoredVectorByAnnot.mat', ...
            pathOutput, annotScoreFolderName, annotatorName);

    %   Analyze the epochViews file and mark each epoch viewed by each
    %   annotator in the annotScore folder, one file per annotator is saved.
    % No score at all, only zeros when the epoch is viewed
        saveScoredVectorWithEpochViewed(fileName2Save, annotatorName, ...
            annotatorData, epochNumData, nSampleInEpoch, nTotSamples);
    end

end

