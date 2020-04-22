function [eegTS, warningCell] = MASSEDFLoadResampleFilter(pathEDFFile,...
    EDFfilename, FS, primRefChan)

% Purpose : Extract eeg signal PRIMCHAN from the EDF file, 
% filter and re-sample (FS).
%
% Input
%   pathEDFFile : path of the EDF file (string)
%   EDFfilename : EDF file name
%   FS : double, frequency sampling (for the resample data)
%   primRefChan : string, primary and reference channel label
% Output
%   eegTS : c3 eeg signal, re-referenced, filtered and re-sampled
%   warningCell : cell of string, warnings
%
% Author Karine Lacourse 2016-05-26
% Changes log:
%   Karine Lacourse 2019-09-25 : remove verbose to simplify
%   Karine Lacourse 2020-03-10 : hard code the filter and the montage for MASS
%-------------------------------------------------------------------------
    PRIMARYCHANNEL = 'c3';
    EDFComplFileName = [pathEDFFile,EDFfilename];
    
    warningCell = {};
    
    % Read the EDF header file
    [OINFO, OTS]     = load_EDF(EDFComplFileName);

    % Select channels
    channelLabels = OINFO.channelLabels;
    % Find the c3 eeg channel
    iFound = strfind(lower(channelLabels),PRIMARYCHANNEL);
    iFoundTab = cellfun(@isempty,iFound);
    iFoundTab = find(iFoundTab==0);
    if isempty(iFoundTab)
        warningMess = sprintf('%s is not found in %s',PRIMARYCHANNEL, EDFfilename);
        warningCell = [warningCell;warningMess];
        warning(warningMess);
        eegTS_prim = [];
        fs_prim = [];
    elseif length(iFoundTab)>1
        warningMess = sprintf('%s is found more than once in %s',PRIMARYCHANNEL, EDFfilename);
        warningCell = [warningCell;warningMess];
        warning(warningMess); 
        eegTS_prim = [];
        fs_prim = [];        
    else
        % Load channel
        eegTS_prim = OTS{iFoundTab};    
        fs_prim = OINFO.sampleRate(iFoundTab);
    end    
    % Need to re-reference the c3 eeg channel
    if strcmpi(primRefChan,'c3-a2')
        % Find the a2 eeg channel
        REFCHAN = 'a2';
        iFound = strfind(lower(channelLabels),REFCHAN);
        iFoundTab = cellfun(@isempty,iFound);
        iFoundTab = find(iFoundTab==0);     
        if isempty(iFoundTab)
            warningMess = sprintf('%s is not found in %s',REFCHAN, EDFfilename);
            warningCell = [warningCell;warningMess];
            warning(warningMess);                
        elseif length(iFoundTab)>1
            warningMess = sprintf('%s is found more than once in %s',REFCHAN, EDFfilename);
            warningCell = [warningCell;warningMess];
            warning(warningMess);                      
        else
            % Load channel
            eegTS_ref = OTS{iFoundTab};    
            fs_ref = OINFO.sampleRate(iFoundTab);
            
            % Re-reference
            if ~isempty(fs_prim)
                if fs_ref==fs_prim
                    if length(eegTS_prim)==length(eegTS_ref)
                        eegTS = eegTS_prim - eegTS_ref;
                    else
                        warningMess = sprintf('%s: prim and ref do not have the same duration',...
                            EDFfilename);
                        warningCell = [warningCell;warningMess];
                        warning(warningMess); 
                        eegTS = [];
                    end
                else
                    warningMess = sprintf('%s: prim fs is %f and ref fs is %f',...
                        EDFfilename, fs_prim, fs_ref);
                    warningCell = [warningCell;warningMess];
                    warning(warningMess);        
                    eegTS = [];
                end
            end  
        end 
    else
        eegTS = eegTS_prim;
    end
    
    if ~isempty(eegTS)
        % Filter 0.3 - 30 Hz
        [eegTSF, errorMess] = butterFiltZPHighPassFiltFilt(eegTS, 0.3, fs_prim);
        warningCell = [warningCell;errorMess];
        [eegTSF, errorMess] = butterFiltZPLowPassFiltFilt(eegTSF, 30, fs_prim);
        warningCell = [warningCell;errorMess];  
    else
        eegTSF = [];
    end
    
    % Re-sample the channel from the montage
    if ~isempty(eegTS)
        eegTS = resampleOneTS( fs_prim, eegTSF, FS, 30);  
    end
    
    
end
