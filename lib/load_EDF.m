% load_EDF.m
% 
% Purpose:
% Load EDF format PSG data file.  Text header and binary timeseries.
% Data is loaded and converted to Physical values. 
%
% Usage:
% [INFO,TS]=load_EDF(filename, standardEpochLength)
% 
% Requirements:
% Traditional EDF format.  Will not work with EDF+
% 
% Notes:
% Byte resolution = 2 bytes per sample point
% Midnight time is 00:00:00.
% INFO contains information about the TS.
% The INFO.header strucuture contains the original edf header information and does not change.
% INFO contains additional information about the TS (INFO.channelLabels, INFO.sampleRate,
% INFO.numChannels etc), which may change if the TS is modified.
%
% For information about EDF format, see:
% http://www.edfplus.info/specs/edf.html
% 
%     EDF HEADER (header)
%     8 ascii         : version of this data format (usually 0)
%     80 ascii        : local patient identification 
%     80 ascii        : local recording identification 
%     8 ascii         : startdate of recording (dd.mm.yy) 
%     8 ascii         : starttime of recording (hh.mm.ss)
%     8 ascii         : number of bytes in header record
%     44 ascii        : reserved
%     8 ascii         : number of data records (-1 if unknown)
%     8 ascii         : duration of a data record, in seconds
%     4 ascii         : number of signals in data record
%     ns * 16 ascii   : ns * label (e.g. EEG Fpz-Cz or Body temp) 
%     ns * 80 ascii   : ns * transducer type (e.g. AgAgCl electrode)
%     ns * 8 ascii    : ns * physical dimension (e.g. uV or degreeC)
%     ns * 8 ascii    : ns * physical minimum (e.g. -500 or 34)
%     ns * 8 ascii    : ns * physical maximum (e.g. 500 or 40)
%     ns * 8 ascii    : ns * digital minimum (e.g. -2048)
%     ns * 8 ascii    : ns * digital maximum (e.g. 2047)
%     ns * 80 ascii   : ns * prefiltering (e.g. HP:0.1Hz LP:75Hz)
%     ns * 8 ascii    : ns * nr of samples in each data record
%     ns * 32 ascii   : ns * reserved
% 
%     DATA RECORD TIMESERIES (TS)
%     nr of samples[1] * integer : first signal in the data record
%     nr of samples[2] * integer : second signal
%     ..
%     nr of samples[ns] * integer : last signal
% 
% Examples:
% [OINFO, OTS] = load_EDF(fullfile(DEF.PSGDir, myEDF.edf))
% 
% Authors:
% Simon Warby 2011-10-15
% 
% Changelog:
% 2014-05-19 Added the INFO.TSinfo summaries (SW)
% 2014-05-20 Removed the scaling function, leave channels in their native units (SW)
% 20140623 Removed INFO.TSinfo.digitalMax and Min - this is not needed, since dig->phy converstion
% (digMin Max still found in the INFO.header).

function [INFO, TS, errorMess]=load_EDF(filename, standardEpochLength)

if (nargin < 2)
    standardEpochLength = 30 ;    % using 30 sec epoch as default)
end

precisionHdr = 'uint8';
precisionTS  = 'int16';

errorMess = cell(0,0);

%% Load EDF Header (INFO.header) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen(filename,'r');
if fid == -1
   fprintf('%s does not exist \n', filename); 
end
% Get file identifier
[~,INFO.ID,~] = fileparts(filename) ;
% Recording information
INFO.header.version = str2double(char(fread(fid,8,precisionHdr)')) ;
INFO.header.patient = char(fread(fid,80,precisionHdr)') ;
INFO.header.localRecording = char(fread(fid,80,precisionHdr)') ;
INFO.header.startDate = char(fread(fid,8,precisionHdr)') ;
INFO.header.startTime = char(fread(fid,8,precisionHdr)') ;
INFO.header.headerSize_bytes = str2double(char(fread(fid,8,precisionHdr)')) ;
INFO.header.reserved = char(fread(fid,44,precisionHdr)') ;
INFO.header.numDataRecords = str2double(char(fread(fid,8,precisionHdr)')) ; % Could be (-1: unknown)
INFO.header.durationOfDataRecord_sec = str2double(char(fread(fid,8,precisionHdr)')) ;
INFO.header.numSignals = str2double(char(fread(fid,4,precisionHdr)')) ;
% Channel information
INFO.header.label = cellstr(char(fread(fid,[16,INFO.header.numSignals],precisionHdr)')) ;
INFO.header.transducer = cellstr(char(fread(fid,[80,INFO.header.numSignals],precisionHdr)')) ;
INFO.header.physicalDimension = cellstr(char(fread(fid,[8,INFO.header.numSignals],precisionHdr)')) ;
INFO.header.physicalMin = str2double(cellstr(char(fread(fid,[8,INFO.header.numSignals],precisionHdr)'))) ;
INFO.header.physicalMax = str2double(cellstr(char(fread(fid,[8,INFO.header.numSignals],precisionHdr)'))) ;
INFO.header.digitalMin = str2double(cellstr(char(fread(fid,[8,INFO.header.numSignals],precisionHdr)'))) ;
INFO.header.digitalMax = str2double(cellstr(char(fread(fid,[8,INFO.header.numSignals],precisionHdr)'))) ;
INFO.header.prefiltering = cellstr(char(fread(fid,[80,INFO.header.numSignals],precisionHdr)')) ;
INFO.header.numSamples_perDataRecord = str2double(cellstr(char(fread(fid,[8,INFO.header.numSignals],precisionHdr)'))) ;
INFO.header.reservedChannels = cellstr(char(fread(fid,[32,INFO.header.numSignals],precisionHdr)')) ;

% If the numDataRecords is unknown -> read the file until the end
% compute the numDataRecords by the size of the data loaded
if INFO.header.numDataRecords == -1
    errorMess{length(errorMess)+1} = 'numDataRecords is unknown';
    realSize                = length(fread(fid,Inf,precisionTS));
    INFO.header.numDataRecords = ...
        floor(realSize / (sum(INFO.header.numSamples_perDataRecord)));
    fclose(fid);
    fid = fopen(filename,'r');
end

%% Calculated TS information (INFO) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
INFO.sampleRate = INFO.header.numSamples_perDataRecord/INFO.header.durationOfDataRecord_sec ;
INFO.duration_sec = INFO.header.durationOfDataRecord_sec*INFO.header.numDataRecords ;
INFO.duration_samples = INFO.duration_sec*INFO.sampleRate ;

% Note that spaces are taken out of the channelLabels and therefor may differ from INFO.header.label
INFO.channelLabels = regexprep (INFO.header.label, ' ', '_') ; % take out spaces in the labels
INFO.numChannels = INFO.header.numSignals ;
% Calculate the number of Epochs
INFO.numberEpochsTotal = INFO.duration_sec / standardEpochLength;
INFO.physicalDimension = INFO.header.physicalDimension ; 
% Flag for whether the TS is original (same as edf), or modified
INFO.TSmodified = 0 ; % 0=unmodified, 1=modified


%% Load the TimeSeries (TS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Timeseries in the file are recorded digitally (recoredValue) but scaled to a physical min/max
% realSignal = 
% [physicalMin+(recordedValue-digitalMin)*(physicalMax-physicalMin)/(digitalMax-digitalMin)]

% If the time series is requested
if nargout > 1

    % pre-allocate a cell for the signals
    TS = cell(INFO.header.numSignals,1); 
    numBytes_perSample = 2; % each sample point is stored as two bytes.

    % Preallocated matrix - Report TS digital & physical characteristics
    INFO.TSinfo.digitalMax = zeros(numel(TS),1) ; 
    INFO.TSinfo.digitalMin = zeros(numel(TS),1) ; 
    INFO.TSinfo.physicalMax = zeros(numel(TS),1) ; 
    INFO.TSinfo.physicalMin = zeros(numel(TS),1) ; 


    for LOOP = 1:INFO.header.numSignals
        numSamples_currentDataRecord = INFO.header.numSamples_perDataRecord(LOOP);

        % Calculate the offset
        skip = (sum(INFO.header.numSamples_perDataRecord)-numSamples_currentDataRecord)*numBytes_perSample ; 
        currentDataRecord_offset = sum(INFO.header.numSamples_perDataRecord(1:LOOP-1))*numBytes_perSample ; 
        offset = INFO.header.headerSize_bytes+currentDataRecord_offset;

        % Read the data
        fseek(fid,offset,'bof');
        precision = [num2str(numSamples_currentDataRecord),['*',precisionTS]];
        duration_samples    = INFO.duration_samples(LOOP);

        TS{LOOP} = fread(fid,duration_samples,precision,skip);   % Samples are in digital scale

        % Report TS digital characteristics - max/min
        INFO.TSinfo.digitalMax(LOOP,1) =  max(TS{LOOP}) ;
        INFO.TSinfo.digitalMin(LOOP,1) =  min(TS{LOOP}) ;

        % Signals need to be scaled to uV, sometimes they are recorded in mV or V.
        %     physicalDim = INFO.header.physicalDimension{LOOP} ;
        %     if(strcmpi(physicalDim,'mv'))
        %         scale = 1e3;
        %     elseif(strcmpi(physicalDim,'v'))
        %         scale = 1e6;
        %     else
        %         scale = 1;
        %     end
        % Removing this scaling function, it is a better idea to leave the data with its native units
        % rather than converting everything to uV.  Many channels are meant to be viewed in mV.
        scale = 1 ; 

        % Scale the data to appropriate units and physical scale
        TS{LOOP} = scale*(INFO.header.physicalMin(LOOP)+(TS{LOOP}(:)-INFO.header.digitalMin(LOOP))...
            *(INFO.header.physicalMax(LOOP)-INFO.header.physicalMin(LOOP))...
            /(INFO.header.digitalMax(LOOP)-INFO.header.digitalMin(LOOP)));


        % Report TS physical characteristics
        INFO.TSinfo.physicalMax(LOOP,1) =  max(TS{LOOP}) ;
        INFO.TSinfo.physicalMin(LOOP,1) =  min(TS{LOOP}) ;
    end
end    

fclose(fid);


