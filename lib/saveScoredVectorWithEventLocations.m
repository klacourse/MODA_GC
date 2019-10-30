function [ maxOutboxInSample ] = saveScoredVectorWithEventLocations(...
            fileName2Save, epochNumExp, startSecsExp, durationSecsExp,...
            scoreConfidExp, nSamplesInEpoch, epochLengthSec, standard_sampleRate)
% Purpose:   
%   Analyze the EventLocations and mark each spindles scored by each
%   annotator in the annotList file. One file per annotator is saved.
%
% Input:
%   fileName2Save   : file name of the scoredVectorByAnnot for the current
%                       annotator 
%   epochNumExp     : vector of the epoch number marked by the current annotator
%   startSecsExp    : vector of the start marked by the current annotator
%   durationSecsExp : vector of the duration marked by the current annotator
%   scoreConfidExp  : vector of the score confidence marked by the current annotator
%   nSamplesInEpoch : number of samples in one epoch
%   epochLengthSec  : epoch length in seconds
%   standard_sampleRate : double, the standard sampling rate
%
% Output:
%   maxOutboxInSample : the maximum number of samples outside the epoch marked as a spindle
%
% Author : Karine Lacourse 2016-06-06
%----------------------------------------------------------------------

    verbose = 0; % To print warnings in the command window

    % Load the ScoredVectorByAnnot file
    load(fileName2Save,'scoredVectorByAnnot'); 
    nTotSamples = length(scoredVectorByAnnot);
    
    % error check 
    iEndEpoch = nSamplesInEpoch:nSamplesInEpoch:nTotSamples; % index of start (sample) of each epoch
    % Error check, verify that every iEndEpoch are NaN
    if verbose==1
        if any(~isnan(scoredVectorByAnnot(iEndEpoch)))
           warning('epoch viewed: has %i bad NaN sep of epochs (ex. epoch#%i)', ...
               sum(~isnan(scoredVectorByAnnot(iEndEpoch))), ...
               find(isnan(scoredVectorByAnnot(iEndEpoch))==0,1,'first'));
        end
    end
    maxOutboxInSample = 0;

    for iEpochExp = 1: length(epochNumExp)

        iEpochScored    = epochNumExp(iEpochExp); 

        % Some start sec are negative, force it to zero.
        if startSecsExp(iEpochExp) < 0
            startSecsExp(iEpochExp) = 0;
        end
        
        % startSample at 0 exist
        startSample     = round(startSecsExp(iEpochExp) * standard_sampleRate);
        durationSample  = round(durationSecsExp(iEpochExp) * standard_sampleRate);
        scoreConfid     = scoreConfidExp(iEpochExp);

        if (startSample+durationSample) > (epochLengthSec * standard_sampleRate)
            samplesOver = (startSample+durationSample)- (epochLengthSec * standard_sampleRate);
            durationSample = durationSample-samplesOver;
            % to keep track of the outbox spindle
            maxOutboxInSample = max(maxOutboxInSample,samplesOver);
        end

        % Add the scored spindles
        scoredVectorByAnnot((iEpochScored-1)*nSamplesInEpoch+startSample+1:...
            (iEpochScored-1)*nSamplesInEpoch+startSample+durationSample,1) = ...
            ones(durationSample,1)*scoreConfid;
    end
    
    if verbose==1
        % Error check, verify that every iEndEpoch are NaN
        if any(~isnan(scoredVectorByAnnot(iEndEpoch)))
           warning('spindle scored vector has %i bad NaN sep of epochs (ex. epoch#%i)', ...
               sum(~isnan(scoredVectorByAnnot(iEndEpoch))), ...
               find(isnan(scoredVectorByAnnot(iEndEpoch))==0,1,'first'));
        end   
    end

    % Save the scoredVectorByAnnot with spindles marked
    save(fileName2Save,'scoredVectorByAnnot');    

end

