function [primChanData] = EDFLoadResampleFilterNoVerbose(pathEDFFile,...
    EDFfilename, pathXMLFile, XMLfilename, FS, PRIMCHAN)

% Purpose : Extract eeg signal (DEF.primaryChannel) from the EDF file, 
% filter (XML-montage) and re-sample (FS).
%
% Input
%   pathEDFFile : path of the EDF file (string)
%   EDFfilename : EDF file name
%   pathXMLFile : path of the XML file (string)
%   XMLfilename : XML file name
%   epochLengthSec : epoch length in seconds
%   FS : double, frequency sampling (for the resample data)
%   PRIMCHAN : cell of string, possible primary channel label
% Output
%   primChanData : eeg signal re-sampled, filtered (only
%       DEF.primaryChannel)
%
% Author Karine Lacourse 2016-05-26
% Changes log:
%   Karine Lacourse 2019-09-25 : remove verbose to simplify
%-------------------------------------------------------------------------

    EDFComplFileName = [pathEDFFile,EDFfilename];
    
    % Read the EDF header file
    [OINFO, OTS]        = load_EDF(EDFComplFileName);

    % Select channels
    primChanNum = [];
    for iChan = 1 : length(PRIMCHAN)
        chanTmp = find(strcmp(PRIMCHAN{iChan}, OINFO.channelLabels),1,'first');
        if ~isempty(chanTmp) && isempty(primChanNum)
            primChanNum = chanTmp;
        end
    end
    if isempty(primChanNum)
        error('No primary channel found, verify PRIMCHAN');
    end 
    
    % Load the montage
    [OINFO.events, ~, ~, ~, OINFO.montage] = ...
        load_accessoryFile(fullfile(pathXMLFile, XMLfilename));
    % Apply the montage
    if ~isempty(OINFO.montage)
        [OINFO,OTS] = fixMontage(OINFO, OTS);
    end
    
    % Update primChanNum with the montage applied
    primChanNum = [];
    for iChan = 1 : length(PRIMCHAN)
        chanTmp = find(strcmp(PRIMCHAN{iChan}, OINFO.channelLabels),1,'first');
        if ~isempty(chanTmp) && isempty(primChanNum)
            primChanNum = chanTmp;
        end
    end
    if isempty(primChanNum)
        error('No primary channel found, verify PRIMCHAN');
    end 
    samplingRate        = OINFO.sampleRate;
    
    % Re-sample the channel from the montage
    primChanData = resampleOneTS( samplingRate(primChanNum), OTS{primChanNum},...
        FS, OINFO.montage.LowPass(primChanNum));  
    
end
