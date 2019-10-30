function [warningLst] = convertEpochScores2Block(pathOutput, annotScoreFolderName, ...
    nSamplesInEpoch, nSamplesInBlock, nTotEpochs, nEpochsInBlock, nSamplesOverlap)
% Convert the scores per epoch (including the 2.5 s overlap 
% between consecutive epochs) into scores per block of 115 s.
%
%   Select the highest score taken between duplicated samples 
%       2.5 s overlap between epoch
%   One file per annotator is saved.
%
% Inputs:
%   pathOutput : string of the path to save outputs
%   annotScoreFolderName : string, the folder name to save .mat score vector
%       for each annotator.
%   nSampleInEpoch : double, number of samples in one epoch
%   nSamplesInBlock : double, number of samples in one block (115 s)
%   nTotEpochs : double, number of epochs in the current phases
%   nEpochsInBlock : double, number of epochs in one block
%   nSamplesOverlap : double, number of samples of the overlap between 
%       consecutive epochs.
% 
% Author: Karine Lacourse 2019-09-16
%   Changes log:
%   
%------------------------------------------------------------------------    
    warningLst = {};
    
    % Number of samples per epoch before the overlap
    nSamplesInEpochBefOvl = nSamplesInEpoch-1-nSamplesOverlap;
    nTotBlocks      = nTotEpochs / nEpochsInBlock; % Number of blocks
    nTotSamples_seg = nSamplesInBlock * nTotBlocks; % Total number of samples
    
    % To avoid out of memory errot there is a file for each annotator
    % load the score with overlaps for each annotator
    scorerFolderPath = [pathOutput,annotScoreFolderName,'/'];
    scorerFileNameList = generateRealListFromPath(scorerFolderPath,'.mat');
    nAnnotators = length(scorerFileNameList);
    for iAnnot = 1 : nAnnotators
        fileName2Load = sprintf([scorerFolderPath, scorerFileNameList{iAnnot}]);
        scoredVectorByAnnot = load(fileName2Load);
        scoredVectorByAnnot_epoch = scoredVectorByAnnot.scoredVectorByAnnot;
        
        % Modify the scores matrix to remove the overlap
        nTotSamples_epoch = length(scoredVectorByAnnot_epoch);
        epoch_iStartSmp = 1 : nSamplesInEpoch : nTotSamples_epoch;
        epoch_iStopSmp = nSamplesInEpoch : nSamplesInEpoch : nTotSamples_epoch;

        % error check if there is a nan between each epochs
        if ~all(isnan(scoredVectorByAnnot_epoch(epoch_iStopSmp)))
            error('%s : not all the epochs ends with a nan', scorerFileNameList{iAnnot});
        end
        
        % Preallocate the new scores matrix
        scoredVectorByAnnot_seg = nan(nTotSamples_seg,1);
        
        % Verify if the epoch has been seen by the annotator
        % because NaN cannot be converted into logical.
        % Extract current epoch start epoch
        for iSeg = 1 : nTotBlocks
            % Extract the 5 epochs of the current segment
            iEpochs = (iSeg-1) * nEpochsInBlock + 1 : 1 : iSeg * nEpochsInBlock;
            curSegValPerEpoch = nan(nEpochsInBlock, nSamplesInEpoch-1);
            curSegVal = nan(nSamplesInBlock,1);
            curValidTab = zeros(nEpochsInBlock,1);
            for epochInc = 1 : nEpochsInBlock
                % Extract current epoch score without the final NaN
                curEpochValues = scoredVectorByAnnot_epoch(...
                    epoch_iStartSmp(iEpochs(epochInc))...
                    :epoch_iStopSmp(iEpochs(epochInc))-1);                
                curSegValPerEpoch(epochInc,:) = curEpochValues;
                curValidTab(epochInc) = ~any(isnan(curEpochValues));
            end
            if any(curValidTab) && ~all(curValidTab)
                sotScored_i = find(curValidTab==0);
                for iNotScored = 1 : length(sotScored_i)
                    message = sprintf('%s : epoch %i is not scored from the segment seen %i',...
                    	scorerFileNameList{iAnnot}, sotScored_i(iNotScored), iSeg);   
                    warningLst = [warningLst;message];
                end
            end

            if any(curValidTab)
                for epochInc = 1 : nEpochsInBlock
                    % In the epochs with overlap
                    if epochInc>1
                        startTmp = round((epochInc-1) * nSamplesInEpochBefOvl);
                        % Current scores of the 2.5 sec overlap
                        curOverlapValue = curSegValPerEpoch(epochInc,1:nSamplesOverlap);
                        % Previous scores of the 2.5 sec overlap
                        preOverlapValue = curSegValPerEpoch(epochInc-1,nSamplesInEpochBefOvl+1:end);
                        % If both epochs have been scored, take the max score
                        if curValidTab(epochInc) && curValidTab(epochInc-1)
                            overlapValue = max([curOverlapValue;preOverlapValue]); 
                            curSegVal(startTmp+1: startTmp+nSamplesOverlap) = overlapValue;
                        % If only the previous epoch has been scored, 
                        % take only the previous epoch
                        elseif curValidTab(epochInc-1)==1
                            curSegVal(startTmp+1: startTmp+nSamplesOverlap) = preOverlapValue;
                            message = sprintf('%s : (seg %i) epoch %i is taken alone (no overlap)',...
                                scorerFileNameList{iAnnot}, iSeg, epochInc-1);
                            warningLst = [warningLst;message];
                        % If only the current epoch has been scored, 
                        % take only the current epoch
                        elseif curValidTab(epochInc)==1
                            curSegVal(startTmp+1: startTmp+nSamplesOverlap) = curOverlapValue;
                            message = sprintf('%s : (seg %i) epoch %i is taken alone (no overlap)',...
                                scorerFileNameList{iAnnot}, iSeg, epochInc); 
                            warningLst = [warningLst;message];
                        % If both includes nan, mark the overlap as nan
                        else
                            curSegVal(startTmp+1: startTmp+nSamplesOverlap)...
                                = nan(nSamplesOverlap,1);
                        end
                        % Init the rest of the epoch
                        if epochInc < nEpochsInBlock
                            curSegVal(startTmp+nSamplesOverlap+1: startTmp+nSamplesInEpochBefOvl) = ...
                                curSegValPerEpoch(epochInc,nSamplesOverlap+1:end-nSamplesOverlap);
                        else
                            curSegVal(startTmp+nSamplesOverlap+1: startTmp+nSamplesInEpoch-1) = ...
                                curSegValPerEpoch(epochInc,nSamplesOverlap+1:end);                        
                        end
                    else
                        % No overlap in the first epoch
                        % Init the first 22.5 sec
                        curSegVal(1:nSamplesInEpochBefOvl) = ...
                            curSegValPerEpoch(epochInc,1:nSamplesInEpochBefOvl);
                    end
                end
                % Error check
                isnan_i = find(isnan(curSegVal)==1);
                if isempty(isnan_i)
                    error('%s (seg%i): missing the last nan',...
                        scorerFileNameList{iAnnot}, iSeg);
                elseif length(isnan_i)>1
                    message = sprintf('%s (seg%i): more than one nan', ...
                        scorerFileNameList{iAnnot}, iSeg);
                    warningLst = [warningLst;message];
                elseif isnan_i~=nSamplesInBlock
                    error('%s (seg%i): the nan is not the end of the segment',...
                        scorerFileNameList{iAnnot}, iSeg);
                end                
            end

            % Store the current segment in the scoredVectorByAnnot_seg
            scoredVectorByAnnot_seg((iSeg-1)*nSamplesInBlock+1:iSeg*nSamplesInBlock,1) = ...
                curSegVal;
        end
        % Save the current annotator
        save([pathOutput, annotScoreFolderName, scorerFileNameList{iAnnot}],...
            'scoredVectorByAnnot_seg');
    end

end

