% load_accessoryFile.m
%
%
% Purpose:
% Load EDF accessory files that contain sleep staging, events or montage information.
% (ie .xml, .sta, .sco)
%
%
% Usage:
% [EVENTS, STAGES, EPOCHLENGTH, POLARITYINV, MONTAGE, STEPCHANNEL, ERRORMESS] 
%  = load_accessoryFile(filename)
% 
%
% Requirements:
% Coded primarily for compumedics xml format.
% 
%
% Notes:
% Need to have an IF statement for each type of accessory file (.xml, .sta, .sco)
% Input from the various formats is converted to standardized STAGES and EVENTS variables

% STAGES is a single long vector [numberofEpochs,1], the index indicates the epoch number
% EVENTS is a tall matrix corresponding to the following headers: 
%        {eventConcept, start(sec), duration(sec), inputCh, LowestSpO2(%), Desaturation(%)}
% EPOCHLENGTH is a single double, usually 30 seconds
% POLARITYINV is an optional field, it is a single tall vector of the number
%       of channels indicates if the polarity of the channel is inverted.
%       Empty if unused.
% MONTAGE is a structure containing montage adjustments and filtering instructions 
%  {Colour, HighPass, Input, Ref, LowerLimit, LowPass, Notch, NumGridLines, RelativeSize,
%  UpperLimit, Zoom} ... could have optional fields InputNum, RefNum and
%  Name.
% STEPCHANNEL is a structure containing the step channel, it has 2 fields :
%   {Input, Label} you can have multiple Labels for each Input.
%
%
% Examples:
% [OINFO.events, OINFO.stages, OINFO.epochLength, OINFO.montage]=load_accessoryFile(filename)
%
%
% Authors:
% Simon Warby 2011-10-15
% Karine Lacourse 2015-10-30
% 
% Changelog:
%   2015-10-30 : add POLARITYINV
%   2015-12-02 : add STEPCHANNEL

function [EVENTS, STAGES, EPOCHLENGTH, POLARITYINV, MONTAGE, STEPCHANNEL, ...
    ERRORMESS]= load_accessoryFile(filename)
  
    % Check for .XML 
    if regexpi(filename, '.XML$')
        [EVENTS, STAGES, EPOCHLENGTH, POLARITYINV, MONTAGE, STEPCHANNEL, ...
            ERRORMESS] = load_XML(filename) ;
    else
        ERRORMESS = 'Only XML accessory file is supported';
    end

end




