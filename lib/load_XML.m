%% load_XML.m
% 
% Purpose:
% Load the accessory data from xml format PSG files.
% 
%
% Usage:
% [events, stages, epochLength] = readXML.m(myFile.xml)
% 
%
% Notes:
% This currently only supports loading of compumedics-format xml.
% Need to modify to load physioMimi format xml
%
% 6 Sections of the compumedics.xml:
% <?xml version="1.0" encoding="utf-8"?>
% <CMPStudyConfig>
% 
%     <EpochLength>30</EpochLength>
% 
%     <StepChannels>
%         <StepChannel>
%         <Input>LIGHT</Input>
%         <Labels>
%         <Label>ON</Label>
%         <Label>OFF</Label>
%         </Labels>
%         </StepChannel>
%     </StepChannels>
% 
%     <ScoredEventSettings>
%         <ScoredEventSetting>
%         <Name>Obstructive Apnea</Name>
%         <Colour>16628921</Colour>
%         <TextColour>4194304</TextColour>
%         <Input>ABDO RES</Input>
%         </ScoredEventSetting>
%     <ScoredEventSettings>
% 
%     <ScoredEvents>
%         <ScoredEvent>
%            <LowestSpO2>90</LowestSpO2>     ! note that LowestSpO2 field is optional
%            <Desaturation>3</Desaturation>  ! note that Desaturation filed is optional 
%            <Name>SpO2 desaturation</Name>
%            <Start>2400.4</Start>
%            <Duration>13.4</Duration>
%            <Input>SaO2</Input>
%          </ScoredEvent>
%          <ScoredEvent>
%            <Name>Hypopnea</Name>
%            <Start>2423.8</Start>
%            <Duration>27.5</Duration>
%            <Input>ABDO RES</Input>
%         </ScoredEvent>
%     </ScoredEvents>
% 
%     <SleepStages>
%         <SleepStage>0</SleepStage>
%         <SleepStage>2</SleepStage>
%         <SleepStage>2</SleepStage>
%      </SleepStages>
% 
%     <Montage>
%       <TracePanes>
%         <TracePane>
%             <BkColour>14546935</BkColour>
%             <Timebase>30</Timebase>
%             <BkColour>14155478</BkColour>
%             <Timebase>120</Timebase>
%             <Traces>
%                 <Trace>
%                     <Colour>0</Colour>
%                     <HighPass>0.3</HighPass>
%                     <Input>C3</Input>
%                     <Ref>A2</Ref>
%                     <LowerLimit>-50.0000023748726</LowerLimit>
%                     <LowPass>35</LowPass>
%                     <Notch>0</Notch>
%                     <NumGridLines>0</NumGridLines>
%                     <RelativeSize>1</RelativeSize>
%                     <UpperLimit>50.0000023748726</UpperLimit>
%                     <Zoom>5</Zoom>
%                 </Trace>
%             </Traces>
%           </TracePane>
%        </TracePanes>
%     </Montage>
%     
% </CMPStudyConfig>
%                     
%                  
%
% Requirements:
% 
% 
% Authors:
% Original readXML.m and readXML_Com.m from Case Western University
% https://sleepdata.org/tools/edf-viewer
% Accessed 2014-04-14
% Dennis Dean Version: 0.1.02 (September 25, 2013)
% Modified by
% Simon Warby 2014-04-14
% Karine Lacourse 2015-11-21
%
% Changelog:
% 2014-04-14 Modified script output of stages to a long matrix
% 2014-04-24 Included loading of Montage
% 2015-11-21 Added PolarityInverted
% 2015-12-02 Load StepChannels
%%

    
    
%% Compumedics Format %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ScoredEvent, SleepStages, EpochLength,...
    PolarityInverted, Montage, StepChannel, errorMes] = load_XML(FileName)
    try
        xdoc = xmlread(FileName);
    catch
        error('Failed to read XML file %s.',FileName);
    end
[ScoredEvent, SleepStages, EpochLength, PolarityInverted, Montage, ...
    StepChannel, errorMes] =  parseNodes(xdoc);

end

function [ScoredEventMatrix, SleepStages, EpochLength, PolarityInverted,...
    Montage, StepChannel, errorMes] = parseNodes(xmldoc)
% Function parses each XML node
        
    % Error message to keep track of error. The path are not available to
    % write directly the warning file
    errorMes = cell(0);

% <EpochLength> 
    Temp = xmldoc.getElementsByTagName('EpochLength');
    EpochLength = str2double(Temp.item(0).getTextContent);

% Optional <PolarityInverted>
    PolInv = xmldoc.getElementsByTagName('PolarityInvertedTab');
    if PolInv.getLength>0
        chanPolInv = xmldoc.getElementsByTagName('ChannelPolInv');
        PolarityInverted = zeros(1,chanPolInv.getLength);
        for i = 0: chanPolInv.getLength-1 
            PolarityInverted(i+1) = str2num(chanPolInv.item(i).getTextContent);
        end
    else
        PolarityInverted = [];
    end
    % Convert the PolarityInverted from a wide matrix to a long matrix
    PolarityInverted = (PolarityInverted)' ;    
    

% <StepChannels>
    StepChannels = xmldoc.getElementsByTagName('StepChannels');
    if StepChannels.getLength==0
        errorMes{length(errorMes)+1} = ['XML error: Field StepChannels does not exist in the XML'];
    else
    % -<StepChannel>
        [StepChannel, errorMes ] = getStepChannelField(xmldoc,errorMes);
    end  
    
% <ScoredEventSettings>
    
% <ScoredEvent>
    ScoredEventInputMiss = 0;
    ScoredEvent = [];
    events = xmldoc.getElementsByTagName('ScoredEvent');
    if events.getLength>0
        for i = 0: events.getLength-1 
            
            % An error occurs if we try to acces an empty field
            % The field is set to a default value if it is empty
            thisList = events.item(i).getElementsByTagName('Name');
            if isempty(thisList.item(0))
                errorMes{length(errorMes)+1} = sprintf(...
                    'XML error: Data -Name- from the %ith ScoredEvent is missing',i+1);
                ScoredEvent(i+1).EventConcept = '';
            else
                ScoredEvent(i+1).EventConcept = char(...
                    events.item(i).getElementsByTagName('Name').item(0).getTextContent);
            end            
                                  
            Temp=strfind(ScoredEvent(i+1).EventConcept,'desaturation');
            % LowestSpO2 and Desaturation are not optional for the
            % event SpO2 desaturation, but they are sometime missing
            % from the XML (the compumedics format is not always
            % fully respected)
            if ~isempty(Temp)
                thisList = events.item(i).getElementsByTagName('LowestSpO2');
                if isempty(thisList.item(0))
                    errorMes{length(errorMes)+1} = sprintf(...
                    ['XML error: -LowestSpO2 field of a "SpO2 desaturation" '...
                    'from the %ith ScoredEvent is missing'],i+1);
                    ScoredEvent(i+1).LowestSpO2 = 0;
                else
                    ScoredEvent(i+1).LowestSpO2     = str2num(...
                    events.item(i).getElementsByTagName('LowestSpO2').item(0).getTextContent);
                end                
                thisList = events.item(i).getElementsByTagName('Desaturation');
                if isempty(thisList.item(0))
                    errorMes{length(errorMes)+1} = sprintf(...
                    ['XML error: -Desaturation field of a "SpO2 desaturation" '...
                    'from the %ith ScoredEvent is missing'],i+1);
                    ScoredEvent(i+1).Desaturation = 0;
                else
                    ScoredEvent(i+1).Desaturation     = str2num(...
                    events.item(i).getElementsByTagName('Desaturation').item(0).getTextContent);
                end 
            else
                ScoredEvent(i+1).LowestSpO2     = 0;
                ScoredEvent(i+1).Desaturation	= 0;
            end
            
            thisList = events.item(i).getElementsByTagName('Start');
            if isempty(thisList.item(0))
                errorMes{length(errorMes)+1}	= sprintf('XML error: Data -Start- from the %ith ScoredEvent is missing',i+1);
                ScoredEvent(i+1).Start          = 0;
            else
                ScoredEvent(i+1).Start = str2num(events.item(i).getElementsByTagName('Start').item(0).getTextContent);
            end
            
            thisList = events.item(i).getElementsByTagName('Duration');
            if isempty(thisList.item(0))
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -Duration- from the %ith ScoredEvent is missing',i+1);
                ScoredEvent(i+1).Duration       = 0;
            else
                ScoredEvent(i+1).Duration = str2num(events.item(i).getElementsByTagName('Duration').item(0).getTextContent);
            end            
            thisList = events.item(i).getElementsByTagName('Input');
            if isempty(thisList.item(0))
                % A lot of input are not specified for the ScoredEvent and
                % there is too many column in the excel or calc file                
                if ScoredEventInputMiss==0
                    errorMes{length(errorMes)+1}    = sprintf('XML error: Data -Input- from the %ith ScoredEvent is missing (could have more missing input)',i+1);
                end    
                ScoredEventInputMiss = 1;
                ScoredEvent(i+1).InputCh        = '';
            else
                ScoredEvent(i+1).InputCh        = char(events.item(i).getElementsByTagName('Input').item(0).getTextContent);
            end
        end
    else
        errorMes{length(errorMes)+1}    = 'Field ScoredEvent does not exist in the XML';
        ScoredEvent.EventConcept        = [];
        ScoredEvent.Start               = [];
        ScoredEvent.Duration            = []; 
        ScoredEvent.InputCh             = [];
        ScoredEvent.LowestSpO2          = []; 
        ScoredEvent.Desaturation        = [];
    end

    % Convert the events structure to a long matrix where the columns are:
    % {eventConcept, start, duration, inputCh, LowestSpO2, Desaturation}
    ScoredEventMatrix = {ScoredEvent.EventConcept; ScoredEvent.Start; ScoredEvent.Duration; ScoredEvent.InputCh; ...
        ScoredEvent.LowestSpO2; ScoredEvent.Desaturation}' ;   %'

% <SleepStage>    
    Stages = xmldoc.getElementsByTagName('SleepStage');
    if Stages.getLength>0
       SleepStages = zeros(1,Stages.getLength);
           for i = 0: Stages.getLength-1 
            SleepStages(i+1) = str2num(Stages.item(i).getTextContent);
           end
    end
    % Convert the Sleepstages from a wide matrix to a long matrix
    SleepStages = (SleepStages)' ;

% <Trace> - channels in the montage
    Montage = [];  % may need to preallocate this
    Trace = xmldoc.getElementsByTagName('Trace');
    if Trace.getLength>0
        for i = 0: Trace.getLength-1 
            thisList = Trace.item(i).getElementsByTagName('Colour');
        	if ~isempty(thisList.item(0))
                Montage.Colour(i+1,1)      = cellstr(char(Trace.item(i).getElementsByTagName('Colour').item(0).getTextContent)) ;
            else
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -Colour- from the %ith Montage is missing',i+1);
            end
            thisList = Trace.item(i).getElementsByTagName('HighPass');
        	if ~isempty(thisList.item(0))
                Montage.HighPass(i+1,1)        = str2num(Trace.item(i).getElementsByTagName('HighPass').item(0).getTextContent);
            else
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -HighPass- from the %ith Montage is missing',i+1);
            end
            thisList = Trace.item(i).getElementsByTagName('Input');
        	if ~isempty(thisList.item(0))            
                Montage.Input(i+1,1)           = cellstr(char(Trace.item(i).getElementsByTagName('Input').item(0).getTextContent)) ;
            else
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -Input- from the %ith Montage is missing',i+1);
            end
            thisList = Trace.item(i).getElementsByTagName('Ref');
        	if ~isempty(thisList.item(0))   
                Montage.Ref(i+1,1)             = cellstr(char(Trace.item(i).getElementsByTagName('Ref').item(0).getTextContent)) ; 
            else
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -Ref- from the %ith Montage is missing',i+1);
            end
            % Optional Name to rename channel
            thisList = Trace.item(i).getElementsByTagName('Name');
        	if ~isempty(thisList.item(0))   
                Montage.Name(i+1,1)             = cellstr(char(Trace.item(i).getElementsByTagName('Name').item(0).getTextContent)) ; 
            end     
            % Optional InputNum to get the input channel index order from EDF
            thisList = Trace.item(i).getElementsByTagName('InputNum');
        	if ~isempty(thisList.item(0))   
                Montage.InputNum(i+1,1)             = cellstr(char(Trace.item(i).getElementsByTagName('InputNum').item(0).getTextContent)) ; 
            end     
            % Optional RefNum to get the ref channel index order from EDF
            thisList = Trace.item(i).getElementsByTagName('RefNum');
        	if ~isempty(thisList.item(0))   
                Montage.RefNum(i+1,1)             = cellstr(char(Trace.item(i).getElementsByTagName('RefNum').item(0).getTextContent)) ; 
            end                 
            thisList = Trace.item(i).getElementsByTagName('LowerLimit');
        	if ~isempty(thisList.item(0))   
                Montage.LowerLimit(i+1,1)      = str2num(Trace.item(i).getElementsByTagName('LowerLimit').item(0).getTextContent);
            else
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -LowerLimit- from the %ith Montage is missing',i+1);
            end
            thisList = Trace.item(i).getElementsByTagName('LowPass');
        	if ~isempty(thisList.item(0))   
                Montage.LowPass(i+1,1)         = str2num(Trace.item(i).getElementsByTagName('LowPass').item(0).getTextContent);  
            else
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -LowPass- from the %ith Montage is missing',i+1);
            end
            thisList = Trace.item(i).getElementsByTagName('Notch');
        	if ~isempty(thisList.item(0))   
                Montage.Notch(i+1,1)           = str2num(Trace.item(i).getElementsByTagName('Notch').item(0).getTextContent);   
            else
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -Notch- from the %ith Montage is missing',i+1);
            end            
            thisList = Trace.item(i).getElementsByTagName('NumGridLines');
        	if ~isempty(thisList.item(0))   
                Montage.NumGridLines(i+1,1)    = str2num(Trace.item(i).getElementsByTagName('NumGridLines').item(0).getTextContent);  
            else
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -NumGridLines- from the %ith Montage is missing',i+1);
            end                
            thisList = Trace.item(i).getElementsByTagName('RelativeSize');
        	if ~isempty(thisList.item(0))   
                Montage.RelativeSize(i+1,1)    = str2num(Trace.item(i).getElementsByTagName('RelativeSize').item(0).getTextContent); 
            else
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -RelativeSize- from the %ith Montage is missing',i);
            end     
            thisList = Trace.item(i).getElementsByTagName('UpperLimit');
        	if ~isempty(thisList.item(0))   
                Montage.UpperLimit(i+1,1)      = str2num(Trace.item(i).getElementsByTagName('UpperLimit').item(0).getTextContent);    
            else
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -UpperLimit- from the %ith Montage is missing',i+1);
            end       
            thisList = Trace.item(i).getElementsByTagName('Zoom');
        	if ~isempty(thisList.item(0))   
                Montage.Zoom(i+1,1)            = str2num(Trace.item(i).getElementsByTagName('Zoom').item(0).getTextContent);      
            else
                errorMes{length(errorMes)+1} = sprintf('XML error: Data -Zoom- from the %ith Montage is missing',i+1);
            end          
            
        end
    end  
    if isempty(Montage)
        errorMes{length(errorMes)+1} = ['Field Montage does not exist in the XML'];
    end    
end


% Local function to get the data from the StepChannel field
function [ScoredEvent, errorMes] = getStepChannelField(xmldoc, errorMes)

    ScoredEvent = [];
    events = xmldoc.getElementsByTagName('StepChannel');
    if events.getLength>0

        % For all the channel
        for i = 0: events.getLength-1 

            % An error occurs if we try to acces an empty field
            % The field is set to a default value if it is empty
            thisList = events.item(i).getElementsByTagName('Input');
            if isempty(thisList.item(0))
                errorMes{length(errorMes)+1} = sprintf(...
                    'XML error: Data -Input- from the %ith StepChannel is missing',i+1);
                ScoredEvent(i+1).Input = '';
            else
                ScoredEvent(i+1).Input = char(events.item(i).getElementsByTagName('Input').item(0).getTextContent);
            end            

            thisList = events.item(i).getElementsByTagName('Labels');
            if thisList.getLength==0
                errorMes{length(errorMes)+1} = ['Field Labels does not exist in the XML'];
            else
                thisList = events.item(i).getElementsByTagName('Label');
                if thisList.getLength>0
                    % For all the labels of each channel
                    for iLabel = 0: thisList.getLength-1 
                        ScoredEvent(i+1).Label{iLabel+1} = ...
                            char(events.item(i).getElementsByTagName('Label').item(iLabel).getTextContent);
                    end
                end
            end                
        end
    else
        errorMes{length(errorMes)+1}    = 'Field StepChannel does not exist in the XML';
        ScoredEvent.Input            = [];
        ScoredEvent.Label           = [];
    end

end


