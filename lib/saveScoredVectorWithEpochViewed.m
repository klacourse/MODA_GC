function saveScoredVectorWithEpochViewed(fileName2Save, annotatorName, ...
        annotatorData, epochNumData, nSamplesInEpoch, nTotSamples)

% Purpose:   
%   Analyze the epochViews file and mark each epoch viewed by each
%   annotator in the annotScore folder, one file per annotator is saved.
%
% Input:
%   fileName2Save   : file name of the scoredVectorByAnnot for the current
%                       annotator
%   annotatorName   : annotator name (string) of the current annotator
%   annotatorData   : cell of strings of the annotator's name who has seen each
%                       epoch of the current phase
%   epochNumData    : vector of the epoch number of the current phase
%   nSamplesInEpoch : number of samples in one epoch
%   nTotSamples     : total number of samples in the eeg vector
%
% Output:
%   no output but the fileName2Save (scoredVectorByAnnot) is saved 
%
% Author : Karine Lacourse 2016-06-06
%----------------------------------------------------------------------

    scoredVectorByAnnot = nan(nTotSamples,1);
    expertTab           = strcmp(annotatorData,annotatorName);
    epochNumExp         = epochNumData(expertTab);
    for iEpochExp = 1: length(epochNumExp)
        scoredVectorByAnnot((epochNumExp(iEpochExp)-1)*nSamplesInEpoch+1:...
            epochNumExp(iEpochExp)*nSamplesInEpoch-1,1) = ...
                zeros(1,nSamplesInEpoch-1);    
    end
    
    % error check 
    iEndEpoch = nSamplesInEpoch:nSamplesInEpoch:nTotSamples; % index of start (sample) of each epoch
    % Error check, verify that every iEndEpoch are NaN
    if any(~isnan(scoredVectorByAnnot(iEndEpoch)))
       warning('epoch viewed: has %i bad NaN sep of epochs (ex. epoch#%i)', ...
           sum(~isnan(scoredVectorByAnnot(iEndEpoch))), ...
           find(isnan(scoredVectorByAnnot(iEndEpoch))==0,1,'first'));
    end
    
    % Save the scoredVectorByAnnot with epochs viewed marked
    save(fileName2Save,'scoredVectorByAnnot');    

end

