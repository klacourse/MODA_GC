% fixMontage.m
% 
% Purpose:
% Fix montage of PSG data based on information from the accessory files (ie xml).
% Usually this is needed to build the correct referential montage, or to filter signals.
% This step is needed for compumedics edf files, which are stored as unreferenced channels. 
%
% Usage:
% [MINFO,MTS]=fixMontage(INFO, TS, DEF.standard_sampleRate)
% 
% Requirements:
% Need INFO and TS structures.
% INFO.montage information from xml
% 
% Notes:
% INFO is the structure containing the PSG information, including header.
% TS is the timeseries.
% 
% Both INFO and TS structure is dictated by the load_EDF script.
% The INFO.montage information is dictated by the load_XML script.
%   INFO.montage dictates the referencing, filtering and order of the channels
% Both will be modified (MINFO, MTS) in the process of fixing the montage.
% 
% Spaces are removed from the Channel names, replaced with '_'
%
% Examples:
% [MINFO, MTS] = fixMontage(OINFO, OTS, DEF.standard_sampleRate)
% 
% Authors:
% Simon Warby 2014-05-05
% 
% Changelog:
% 

function [MINFO, MTS]=fixMontage(INFO, TS, warningsDir)

if (nargin < 2)
    error('Error - fixMontage requires that you specify the INFO and TS input structures.')
end

% % Check that the INFO.montage exists and is not empty
% if isempty(INFO.montage)
%     error('Montage information is not present in the PSG INFO')
% end
% The error is already written in OINFO-0.accessoryFileError

%% Change INFO parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MINFO = INFO ; 

% Update the number of data channels, based on MINFO.montage imported from xml
MINFO.numChannels = numel(MINFO.montage.Input);

% clear MINFO.sampleRate, preallocate to size of new numChannels
MINFO.sampleRate = zeros(MINFO.numChannels, 1);
% clear MINFO.duration_samples, preallocate to size of new numChannels
MINFO.duration_samples = zeros(MINFO.numChannels, 1);
% Clear MINFO.TSinfo.physicalMax/Min, preallocate to size of new numChannels
MINFO.TSinfo.physicalMax = zeros(MINFO.numChannels, 1); 
MINFO.TSinfo.physicalMin = zeros(MINFO.numChannels, 1);
% Clear MINFO.TSinfo.digitalMax/Min, preallocate to size of new numChannels
MINFO.TSinfo.digitalMax = zeros(MINFO.numChannels, 1); 
MINFO.TSinfo.digitalMin = zeros(MINFO.numChannels, 1);
% Clear MINFO.physicalDimension
MINFO.physicalDimension = cell(MINFO.numChannels, 1);
% Clear MINFO.transducer (transTyoe) ex. DC, EEG, ECG ....
MINFO.transducer = cell(MINFO.numChannels, 1);
% Clear the prefiltering
MINFO.prefiltering = cell(MINFO.numChannels, 1);
% Clear the channelLabel
MINFO.channelLabels = cell(MINFO.numChannels, 1);
% Set modified flag to true
MINFO.TSmodified = MINFO.TSmodified + 1 ;


%% Fix the montage in the TS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preallocate space for the new TS
MTS = cell(MINFO.numChannels,1);

% Verify that all the channels included in the EDF are in the montage
edfChanLabel        = MINFO.header.label;
montageChanLabel    = MINFO.montage.Input;
refChanLabel        = MINFO.montage.Ref;
for iEDFChan = 1: size(edfChanLabel,1)
    if nargin > 3 % warningsDir is available to generate warnings
        if ( ~any(strcmp(montageChanLabel,edfChanLabel{iEDFChan})) ...
            && ~any(strcmp(refChanLabel,edfChanLabel{iEDFChan})) )
            errorMess = sprintf('EDF channel %s is not in the montage',...
                edfChanLabel{iEDFChan});
            statement{1}    = MINFO.ID;
            statement{2}    = errorMess;
            dataset         = ['MINFO-', num2str(MINFO.TSmodified)] ;
            testName        = 'MissingChanInMontage_Fail';
            createDirIfDoesntExist(warningsDir,['tmp-',testName]);
            filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
            cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
            cellstr(statement), 'a');   
            clear('statement');        
        end
    end
end

%----------------------------------------------------------------------
%% Create the new channels specified by MINFO.montage
%----------------------------------------------------------------------
for iMontChan = 1:MINFO.numChannels
    % Determine the paired input channel and reference channel
    % Note both MINFO.montage.Input & MINFO.header.label have channel names which include spaces.
  
    %****************************
    % XML input : index order of the channel
    %****************************
    if isfield(INFO.montage,'InputNum')
        iInputChanFound = str2double(MINFO.montage.InputNum{iMontChan});
        % Verify that the index order of the channel specified by InpuNum
        % in the montage match the channel label in the EDF        
        if nargin > 3 % warningsDir is available to generate warnings
            % Verify that the Input was found in the EDF
            if iInputChanFound ~= 0
                % Verify if the label match
                if ~strcmp(MINFO.montage.Input{iMontChan},edfChanLabel{iInputChanFound})
                    errorMess = sprintf(['The EDF channel label %s from InputNum '...
                        'is different than the Input %s'], edfChanLabel{iInputChanFound},...
                        MINFO.montage.Input{iMontChan});
                    statement{1}    = MINFO.ID;
                    statement{2}    = errorMess;
                    dataset         = ['MINFO-', num2str(MINFO.TSmodified)] ;
                    testName        = 'InputNumFromMontage_Fail';
                    createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                    filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                    cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                    cellstr(statement), 'a');   
                    clear('statement');
                end
            else
                errorMess = sprintf('The InputNum is zero, the Input to find is %s',...
                    MINFO.montage.Input{iMontChan});
                statement{1}    = MINFO.ID;
                statement{2}    = errorMess;
                dataset         = ['MINFO-', num2str(MINFO.TSmodified)] ;
                testName        = 'InputNumFromMontage_Fail';
                createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                cellstr(statement), 'a');   
                clear('statement');                
            end
        end
    else
    %****************************
    % XML input : channel label
    %****************************
        % The input field can be empty 
        % (the entire channel is empty when the input XML field is empty)
        iInputChanFound = find(strcmp(MINFO.montage.Input{iMontChan},...
            MINFO.header.label),1,'first');
        
        % QC to make sure the input and ref channels were found 
        % (if they are not empty)
        if ~isempty(MINFO.montage.Input{iMontChan}) 
            % if input channel is specfied but match not found
            if isempty(iInputChanFound) 
                iInputChanFoundIgnCase = ...
                    find(strcmpi(MINFO.montage.Input{iMontChan}, MINFO.header.label));

                if nargin > 3 % warningsDir is available to generate warnings
                    if ~isempty(iInputChanFoundIgnCase)
                        errorMess = sprintf(['Input channel %s (from montage) is not',...
                            ' in the EDF, the equivalent could be %s'],...
                            MINFO.montage.Input{iMontChan}, ...
                            MINFO.header.label{iInputChanFoundIgnCase});  
                    else
                        errorMess = sprintf(['Input channel %s (from montage) is not',...
                            ' in the EDF, no equivalent was found'],...
                            MINFO.montage.Input{iMontChan});                 
                    end
                
                    statement{1}    = MINFO.ID;
                    statement{2}    = errorMess;
                    dataset         = ['MINFO-', num2str(MINFO.TSmodified)] ;
                    testName        = 'MontageInput_Fail';
                    createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                    filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                    cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                    cellstr(statement), 'a');   
                    clear('statement');      
                end
            end
        end        
    end
    
    %****************************
    % XML RefNum : index order of the channel
    %****************************
    if isfield(INFO.montage,'RefNum')
        if ~isempty(MINFO.montage.RefNum{iMontChan})
            iRefChanFound = str2double(MINFO.montage.RefNum{iMontChan});
            if nargin > 3 % warningsDir is available to generate warnings
                % Verify that the Ref was found in the EDF
                if iRefChanFound ~= 0
                    % Verify if the label match
                    if ~strcmp(MINFO.montage.Ref{iMontChan},edfChanLabel{iInputChanFound})
                        errorMess = sprintf(['The EDF channel label %s from RefNum '...
                            'is different than the Ref %s'], edfChanLabel{iInputChanFound},...
                            MINFO.montage.Ref{iMontChan});
                        statement{1}    = MINFO.ID;
                        statement{2}    = errorMess;
                        dataset         = ['MINFO-', num2str(MINFO.TSmodified)] ;
                        testName        = 'RefNumFromMontage_Fail';
                        createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                        filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                        cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                        cellstr(statement), 'a');   
                        clear('statement');                  
                    end
                else
                    errorMess = sprintf('The RefNum is zero, the Ref to find is %s',...
                        MINFO.montage.Ref{iMontChan});
                    statement{1}    = MINFO.ID;
                    statement{2}    = errorMess;
                    dataset         = ['MINFO-', num2str(MINFO.TSmodified)] ;
                    testName        = 'RefNumFromMontage_Fail';
                    createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                    filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                    cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                    cellstr(statement), 'a');   
                    clear('statement');                     
                end
            end
        else
            iRefChanFound = [];
        end
    else    
    %****************************
    % XML RefNum : channel label
    %****************************        
        iRefChanFound = find(strcmp(MINFO.montage.Ref{iMontChan},...
        MINFO.header.label), 1, 'first');
        if ~isempty(MINFO.montage.Ref{iMontChan})  
            if nargin > 3 % warningsDir is available to generate warnings
                % if ref channel is specfied but match not found
                if isempty(iRefChanFound)
                    montRefOriChanNumIgnCase = ...
                        find(strcmpi(MINFO.montage.Ref{iMontChan}, MINFO.header.label)) ;
                    if ~isempty(montRefOriChanNumIgnCase)
                        errorMess = sprintf(['Ref channel %s (from montage) is not ',...
                            'in the EDF, the equivalent could be %s'],...
                            MINFO.montage.Input{iMontChan}, ...
                            MINFO.header.label{montRefOriChanNumIgnCase});  
                    else
                        errorMess = sprintf(['Ref channel %s (from montage) is not ',...
                            'in the EDF, no equivalent was found'],...
                            MINFO.montage.Input{iMontChan});                 
                    end
                    statement{1} = MINFO.ID;
                    statement{2} = errorMess;
                    dataset = ['MINFO-', num2str(MINFO.TSmodified)] ;
                    testName = 'MontageRef_Fail';
                    createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                    filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                    cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                    cellstr(statement), 'a');   
                    clear('statement');              
                end
            end
        end   
    end
    
    %----------------------------------------------------------------------
    % QC to make sure input and ref channels are compatible
    %----------------------------------------------------------------------
    if nargin > 3 % warningsDir is available to generate warnings
        if ((~isempty(iRefChanFound) && ~isempty(iInputChanFound)) && ...
                (iRefChanFound ~= 0 && iInputChanFound ~= 0))
            %****************************
            % Check that the sample rates of the two channels are the same
            %****************************
            if INFO.sampleRate(iInputChanFound) ~= INFO.sampleRate(iRefChanFound)
                statement{1} = INFO.ID;
                errorMess = sprintf(['Input channel %s (from montage) has a sampling rate of %g Hz; ',...
                    'Ref channel %s (from montage) has a sampling rate of %g Hz'],...
                    MINFO.montage.Input{iMontChan},INFO.sampleRate(iInputChanFound),...
                    INFO.montage.Ref{iMontChan}, INFO.sampleRate(iRefChanFound));      
                statement{2} = errorMess;   
                dataset = ['MINFO-', num2str(MINFO.TSmodified)] ;
                testName = 'MontageInputRef_Fail' ;            
                createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                cellstr(statement), 'a');   
                clear('statement'); 

            end
            %****************************
            % Check that the physical Dimensions (ie uV) of the channels are the same
            %****************************
            if ~strcmp(INFO.header.physicalDimension(iInputChanFound),...
                    INFO.header.physicalDimension(iRefChanFound))
                statement{1} = INFO.ID;
                errorMess = sprintf(['Input channel %s (from montage) has a physical dim in %s; ',...
                    'Ref channel %s (from montage) has a physical dim in %s'],...
                    MINFO.montage.Input{iMontChan},INFO.header.physicalDimension{iInputChanFound},...
                    INFO.montage.Ref{iMontChan}, INFO.header.physicalDimension{iRefChanFound});      
                statement{2} = errorMess;    
                dataset = ['MINFO-', num2str(MINFO.TSmodified)] ;
                testName = 'MontageInputRef_Fail' ;            
                createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                cellstr(statement), 'a');   
                clear('statement'); 
            end
            %****************************
            % Check that the physical Dimensions (ie uV) of the channels are the same
            %****************************
            if ~strcmp(INFO.header.physicalDimension(iInputChanFound),...
                    INFO.header.physicalDimension(iRefChanFound))
                statement{1} = INFO.ID;
                errorMess = sprintf(['Input channel %s (from montage) has a physical dim in %s; ',...
                    'Ref channel %s (from montage) has a physical dim in %s'],...
                    MINFO.montage.Input{iMontChan},INFO.header.physicalDimension{iInputChanFound},...
                    INFO.montage.Ref{iMontChan}, INFO.header.physicalDimension{iRefChanFound});      
                statement{2} = errorMess;    
                dataset = ['MINFO-', num2str(MINFO.TSmodified)] ;
                testName = 'MontageInputRef_Fail' ;            
                createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                cellstr(statement), 'a');   
                clear('statement'); 
            end            
            %****************************
            % Check that the transducer of the channels are the same
            %****************************
            if ~strcmp(INFO.header.transducer{iInputChanFound},...
                    INFO.header.transducer{iRefChanFound})
                statement{1} = INFO.ID;
                errorMess = sprintf(['Input channel %s (from montage) has the transducer %s; ',...
                    'Ref channel %s (from montage) has the transducer %s'],...
                    MINFO.montage.Input{iMontChan},INFO.header.transducer{iInputChanFound},...
                    INFO.montage.Ref{iMontChan}, INFO.header.transducer{iRefChanFound});      
                statement{2} = errorMess;    
                dataset = ['MINFO-', num2str(MINFO.TSmodified)] ;
                testName = 'MontageInputRef_Fail';            
                createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                cellstr(statement), 'a');   
                clear('statement');           
            end
        end
    end
    %----------------------------------------------------------------------
    % Combine the channels by subtraction, or add unreferenced channel in MTS
    %----------------------------------------------------------------------
    if ((~isempty(iRefChanFound) && ~isempty(iInputChanFound)) && ...
            (iRefChanFound ~= 0 && iInputChanFound ~= 0))
        % Check that the length of the channels are the same
        if size(TS{iInputChanFound},1)==size(TS{iRefChanFound},1)
            MTS{iMontChan} = TS{iInputChanFound} - TS{iRefChanFound} ;   
        else       
            if nargin > 3 % warningsDir is available to generate warnings
                statement{1} = INFO.ID;
                errorMess = sprintf(['Input channel %s (from montage) has a different length ',...
                    'than Ref channel %s'],MINFO.montage.Input{iMontChan},...
                    INFO.montage.Ref{iMontChan});      
                statement{2} = errorMess;
                dataset = ['MINFO-', num2str(MINFO.TSmodified)] ;
                testName = 'MontageInputRef_Fail' ;                 
                createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                cellstr(statement), 'a');   
                clear('statement'); 
            end
            minLength = min(size(TS{iInputChanFound},1),size(TS{iRefChanFound},1));
            MTS{iMontChan}  = TS{iInputChanFound}(1:minLength,1) - TS{iRefChanFound}(1:minLength,1) ;   
        end
    elseif ~isempty(iInputChanFound) && iInputChanFound~=0
        MTS{iMontChan} = TS{iInputChanFound} ;
    end
    
    %----------------------------------------------------------------------
    % Rename channel label
    %----------------------------------------------------------------------
    % Take information from Montage.Name if the field exist
    if isfield(INFO.montage,'Name') 
        if ~isempty(INFO.montage.Name{iMontChan})
            MINFO.channelLabels{iMontChan} = INFO.montage.Name{iMontChan};
        else
            MINFO.channelLabels{iMontChan} = MINFO.montage.Input{iMontChan};
            % Create new Channel Labels, including the subtracted Ref channel
            if ~isempty(MINFO.montage.Ref{iMontChan})
                MINFO.channelLabels(iMontChan) = cellstr([char(MINFO.channelLabels{iMontChan}),...
                '-',char(MINFO.montage.Ref{iMontChan})]);            
            end 
        end
    else
        MINFO.channelLabels{iMontChan} = MINFO.montage.Input{iMontChan};
        % Create new Channel Labels, including the subtracted Ref channel
        if ~isempty(MINFO.montage.Ref{iMontChan})
            MINFO.channelLabels(iMontChan) = cellstr([char(MINFO.channelLabels{iMontChan}),...
            '-',char(MINFO.montage.Ref{iMontChan})]);            
        end    
    end
    % Remove spaces from the new channel names
    MINFO.channelLabels{iMontChan} = regexprep(MINFO.channelLabels{iMontChan}, ' ', '_');
    
    %----------------------------------------------------------------------
    % Modify the channel input of each event
    % The original channel of events
    %----------------------------------------------------------------------
    inputChanCol = 4;
    if ~isempty(MINFO.events)
        oChanInputEvent  = MINFO.montage.Input{iMontChan};
        oChanEventLst    = MINFO.events(:,inputChanCol);
        iChan2Change     = strcmp(oChanEventLst,oChanInputEvent);
        MINFO.events(iChan2Change==1,inputChanCol) = MINFO.channelLabels(iMontChan); 
    end
    
    
    %% If there is no input all the field are let to zero
    if ~isempty(iInputChanFound) && iInputChanFound ~= 0
        % Update the sampleRate for current channel iMontChan
        MINFO.sampleRate(iMontChan)             = INFO.sampleRate(iInputChanFound);
        % Update the duration_samples for the current channel iMontChan
        MINFO.duration_samples(iMontChan)       = INFO.duration_samples(iInputChanFound);      
        % Update the physical dimensions
        MINFO.physicalDimension(iMontChan)      = MINFO.header.physicalDimension(iInputChanFound);  
        % Update the transducer
        MINFO.transducer(iMontChan)             = MINFO.header.transducer(iInputChanFound);         
        % Update the prefiltering
        MINFO.prefiltering{iMontChan}           = MINFO.header.prefiltering{iInputChanFound};
        % Update the Max of the channel (this might be updated again after filtering, see below)
        MINFO.TSinfo.physicalMax(iMontChan)     = max(MTS{iMontChan});
        % Update the Min of the channel (this might be updated again after filtering, see below)
        MINFO.TSinfo.physicalMin(iMontChan)     = min(MTS{iMontChan});    
        % Only for TS_Viewer Update the digital Max of the channel
        MINFO.TSinfo.digitalMax(iMontChan)     = MINFO.header.digitalMax(iInputChanFound);  
        % Only for TS_Viewer Update the digital Min of the channel 
        MINFO.TSinfo.digitalMin(iMontChan)     = MINFO.header.digitalMin(iInputChanFound);      
    end
  
end
    


%% Filtering %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ! Notch filtering not currently implemented
%if ~isempty(MINFO.montage(iMontChan).Notch)

% High/Low Pass
for iMontChan = 1:MINFO.numChannels
    
    % Fields HighPass and LowPass are never empty even when the input
    % channel is empty (it doesnt make any sens if the input is empty)    
    % MTS could be empty if the channel specified in the XML is wrong 
    if ~isempty(MINFO.montage.Input{iMontChan}) && ~isempty(MTS{iMontChan})
        if ((MINFO.montage.HighPass(iMontChan) > 0) || (MINFO.montage.LowPass(iMontChan) > 0))
            
            %************
            % High Pass
            %************
            if MINFO.montage.HighPass(iMontChan) > 0     
                [MTS{iMontChan}, highPassErrorMess] = butterFiltZPHighPassFiltFilt(MTS{iMontChan},...
                    MINFO.montage.HighPass(iMontChan), MINFO.sampleRate(iMontChan));

                if nargin > 3 % warningsDir is available to generate warnings
                    % Write the error in the warning directory
                    if ~isempty(highPassErrorMess)
                        statement{1} = MINFO.ID;
                        statement{2} = MINFO.montage.Input{iMontChan};
                        % highPassErrorMess is already a cell
                        dataset = ['MINFO-', num2str(MINFO.TSmodified)] ;
                        testName = 'MontageHighPass_Fail';                    
                        statement = [ statement, highPassErrorMess];                       
                        createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                        filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                        cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                        cellstr(statement), 'a');   
                        clear('statement'); 
                    end  
                end
            end

            %************
            % Low Pass
            %************
            if INFO.montage.LowPass(iMontChan) > 0  
                [MTS{iMontChan}, lowPassErrorMess] = butterFiltZPLowPassFiltFilt(MTS{iMontChan},...
                    MINFO.montage.LowPass(iMontChan), MINFO.sampleRate(iMontChan));
                
                if nargin > 3 % warningsDir is available to generate warnings
                    
                    % Write the error in the warning directory
                    if ~isempty(lowPassErrorMess)
                        statement{1} = MINFO.ID;
                        statement{2} = MINFO.montage.Input{iMontChan};
                        dataset = ['MINFO-', num2str(MINFO.TSmodified)];
                        testName = 'MontageLowPass_Fail';                    
                        % lowPassErrorMess is already a cell
                        statement = [ statement, lowPassErrorMess];             
                        createDirIfDoesntExist(warningsDir,['tmp-',testName]);
                        filename = [dataset, '.', testName, '-', MINFO.ID, '.txt'];
                        cell2tab(fullfile(warningsDir, ['tmp-', testName], filename),...
                        cellstr(statement), 'a');   
                        clear('statement'); 
                    end     
                end
            end

            % Update the Max of the channel
            MINFO.TSinfo.physicalMax(iMontChan) = max(MTS{iMontChan}) ;
            % Update the Min of the channel
            MINFO.TSinfo.physicalMin(iMontChan) = min(MTS{iMontChan}) ;    
            
        end
    end
end






