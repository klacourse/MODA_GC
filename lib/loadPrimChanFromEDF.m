function [ eegTS, fs, chanLabel, nSecFromMidNight ] = loadPrimChanFromEDF(...
    inputPath, curFile, PRIMARYCHANNEL, readEdfOn)
% Function to extract the primary channel time series from an edf.
% 
% Input : 
%   inputPath : string, path of the edf folder
%   curFile : string, edf filename to load
%   PRIMARYCHANNEL : string, channel label to load
%   readEdfOn : flag to use readEDF function otherwise load_EDF
% Output :
%   eegTS : tall vector of the time series loaded from the primary channel.
%   fs : sampling rate in Hz
%   chanLabel : string of the primary channel label
%   nSecFromMidNight : seconds from midnight 
% 
% Author : Karine Lacourse 2020-02-13
%-----------------------------------------------------------------------

    if nargin < 4
        error('4 argument inputs are needed');
    end

    % Load MASS v2.0 edf
    if readEdfOn==0
        [MASS_info, MASS_ts, errorMess] = load_EDF([inputPath, curFile]);
        if ~isempty(errorMess)
            error(errorMess);
        end
        channelLabels = MASS_info.channelLabels;
    else
        [MASS_ts, MASS_info] = readEDF([inputPath, curFile]);
        channelLabels = MASS_info.labels;
    end
    % Number of second from midnight
    nSecFromMidNight = hms2seconds( MASS_info.header.startTime );
    
    % Look for the c3 channel
    iFound = strfind(lower(channelLabels),lower(PRIMARYCHANNEL));
    iFoundTab = cellfun(@isempty,iFound);
    iFoundTab = find(iFoundTab==0);
    if isempty(iFoundTab)
        warning('%s is not found in %s',PRIMARYCHANNEL, curFile);
        eegTS = [];
        fs = [];
        chanLabel = [];
    elseif length(iFoundTab)>1
        error('%s is found more than once in %s',PRIMARYCHANNEL, curFile);
    else
        % Load channel
        eegTS = MASS_ts{iFoundTab};    
        fs = MASS_info.sampleRate(iFoundTab);
        chanLabel = channelLabels(iFoundTab);
    end

end

