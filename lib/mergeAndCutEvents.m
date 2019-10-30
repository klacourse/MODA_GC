function [ outDetecVector ] = mergeAndCutEvents( inDetecVector, samplingRate, ...
    maxSpindleLengthSec, minSpindleLengthSec, minSpindleStepSec2Merge )
% Purpose : to merge and cut too short or too long events.
%
% Note about the merge: 
%     From (Warby 2014) no merging rule were applied to automated detected spindles.
%     The only merge rule is applied to the marked events from the web
%     interface. If the duration of the spindle was less than 0.3 s and 
%     the adjacent spindle was less than 0.1 s away, the two identifications
%     were merged.
%
% Input :
%   - inDetecVector : wide sample vector (double) of the detections 
%           (1: means the sample is part of the event)
%   - samplingRate : sampling rate of the inDetecVector (double)
%   - maxSpindleLengthSec : maximum length of the event in second
%   - minSpindleLengthSec : minimum length of the event in second
%   - minSpindleStepSec2Merge : minimum distance between events, shorter
%   than that the events are merged together. 
%
% Ouput : 
%   - outDetecVector : sample vector (double) of the detections without any
%   too short or too long events (too close events are merge)
%
% Author : Karine Lacourse, 2017-02-13
%------------------------------------------------------------------------
verbose = 0;
    % Verify the nan included in the detection vector.
    iNan = find(isnan(inDetecVector)==1);
    if ~isempty(iNan)
        if length(iNan)>1
            allDiff = diff(iNan);
            if length(unique(allDiff))>1
               error('Unexpected detection vector, non regular NaNs');
            else
                segLength = unique(allDiff);
            end
            % If the last nan at the end is missing (usually the case)
            if iNan(end) ~= length(inDetecVector)
                iNan = [iNan, length(inDetecVector)];
            end 
        % only one segment
        else
            segLength = iNan;
            % If the last nan at the end is missing (usually the case)
            if iNan(end) ~= length(inDetecVector)
                iNan = [iNan, length(inDetecVector)];
            end             
        end
    else
        % We add a fake NaN to be similar than with NaN
        segLength = length(inDetecVector)+1;
        iNan = length(inDetecVector);
    end

    % Merge and cut events by segment.
    % We don't want to merge events not in the same segment !!!
    outDetecVector = [];
    for iSeg = 1 : length(iNan)
        
        % We dont take the NaN at the end of the segment
        iSamples = (iSeg-1) * segLength + 1 :  iSeg * segLength -1;
        
        % select the detection vector for the current segment
        inDetecVectorTmp = inDetecVector(iSamples);
        
        % Create a list of events
        [startEventSmp, endsEventSmp, durationsEventSmp] = ...
            event_StartsEndsDurations(inDetecVectorTmp);

        % If there is at least one event
        if ~isempty(startEventSmp)
            % Fix spindle list by merging any too close spinldles
            eventLst2Merge  = ((startEventSmp(2:end) - endsEventSmp(1:end-1)) / samplingRate)...
                < minSpindleStepSec2Merge;
            
            eventLst2Merge = [eventLst2Merge; 0];
            % Verify the duration of the event to merge (must be shorter
            % than the minimum duration)
            iEventLst2Merge = find(eventLst2Merge==1);
            for iEvt2Merge = 1 : length(iEventLst2Merge)
                durSecFstEvt2merge = durationsEventSmp(iEventLst2Merge(iEvt2Merge))...
                    / samplingRate;
                durSecSecEvt2merge = durationsEventSmp(iEventLst2Merge(iEvt2Merge)+1)...
                    / samplingRate;
                if ( durSecFstEvt2merge < minSpindleLengthSec && ...
                        durSecSecEvt2merge < minSpindleLengthSec )
                    eventLst2Merge(iEventLst2Merge(iEvt2Merge))=1;
                    if verbose == 1
                        fprintf('seg%i : 2 spindles are merged\n\n', iSeg);
                    end
                else
                    eventLst2Merge(iEventLst2Merge(iEvt2Merge))=0;
                end
            end
            iEventLstOK = find(eventLst2Merge==0);

            iEvntKept = 0;
            updateEnd = 0;
            startEventSmpMerge      = zeros(length(iEventLstOK),1);
            endsEventSmpMerge       = zeros(length(iEventLstOK),1);
            durationsEventSmpMerge  = zeros(length(iEventLstOK),1);

            for iEvt = 1 : length(eventLst2Merge)
                % No modif, event does not have to be merge
                if eventLst2Merge(iEvt)==0 && updateEnd==0
                    iEvntKept = iEvntKept +1;
                    startEventSmpMerge(iEvntKept)       = startEventSmp(iEvt);
                    endsEventSmpMerge(iEvntKept)        = endsEventSmp(iEvt);
                    durationsEventSmpMerge(iEvntKept)   = durationsEventSmp(iEvt);
                % Merge (completed) : end and duration have to be updated 
                % It is already done for the start
                elseif eventLst2Merge(iEvt)==0 && updateEnd==1
                    updateEnd = 0; 
                    endsEventSmpMerge(iEvntKept)  = endsEventSmp(iEvt);
                    durationsEventSmpMerge(iEvntKept) = ...
                        endsEventSmpMerge(iEvntKept)-startEventSmpMerge(iEvntKept);
                % Merge : end is removed
                else 
                    % First event of the merge of events
                    if updateEnd==0
                        iEvntKept = iEvntKept +1;
                        startEventSmpMerge(iEvntKept) = startEventSmp(iEvt);              
                    end
                    % We accumulate every events that have to be merge until the
                    % last to know the final end and duration
                    % The start does not have to be updated
                    updateEnd = 1; % It is no more the first event of a merge of events    
                end
            end


            % Fix spindle list by removing too small spindle
            iSS2Keep = find(durationsEventSmpMerge >= minSpindleLengthSec * samplingRate);
            startsEventSmpFixLength = startEventSmpMerge(iSS2Keep);
            endsEventSmpFixLength   = endsEventSmpMerge(iSS2Keep);
            durEventSmpFixLength    = durationsEventSmpMerge(iSS2Keep);

            % Fix spindle list by removing too long spindle
            iSS2Keep = find(durEventSmpFixLength <= maxSpindleLengthSec * samplingRate);
            startsEventSmpFixLength = startsEventSmpFixLength(iSS2Keep);
            endsEventSmpFixLength   = endsEventSmpFixLength(iSS2Keep); 

            % Go back to the detection vector in order to evaluate performance
            outDetecVectorTmp = eventsList2DetectVector( [...
                startsEventSmpFixLength,endsEventSmpFixLength],...
                length(inDetecVectorTmp));  
        else
            outDetecVectorTmp = inDetecVectorTmp;
        end

        % Copy the format (wide or long)
        if size(inDetecVectorTmp,1) ~= size(outDetecVectorTmp,1)
            outDetecVectorTmp = outDetecVectorTmp';
        end
        
        % Wide vector
        if size(inDetecVectorTmp,1) > size(inDetecVectorTmp,2)
            outDetecVector = [outDetecVector; outDetecVectorTmp; NaN];
        % Tall vector
        else
            outDetecVector = [outDetecVector, outDetecVectorTmp, NaN];
        end

    end

    % If the last nan at the end is missing (usually the case)
    iNan = find(isnan(inDetecVector)==1);
    if ~isempty(iNan)
        if iNan(end) ~= length(inDetecVector)
            % Remove the last end
            outDetecVector = outDetecVector(1:end-1);
        end
    else
        % Remove the last end
        outDetecVector = outDetecVector(1:end-1);        
    end
    
    % The NaNs should be kept
    if isnan(inDetecVector) ~= isnan(outDetecVector)
        error('The code the merge and cut events with segments does not work');
    end

end

