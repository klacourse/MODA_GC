% resampleTS.m
% 
% Purpose:
% Convert all channels in a TS to a standardized sampling frequency
%
% Usage:
% [INFO, TS] = resampleTS(INFO, TS, resamplingFrequency)
% 
% INFO is the TS information structure
% TS is the timeseries itself
% resamplingFrequency = the default resampling frequency (ie the output fs)
%    *if this data is alread at this fs, then this function does nothing
%
% Requirements:
% INFO and TS created from load_EDF and load_XML
% fixMontage may have also been applied.
% 
% Notes:
%
% Examples:
% [MINFO, MTS] = resampleTS(OINFO, OTS, DEF.fs)
% 
% Authors:
% Simon Warby 2012-11-25
% 
% Changelog:
% 2014-05-22 changed name from resampleEDF to resampleTS


function [TS, modFlag] = resampleOneTS(sampleRate, TS, resamplingFrequency, LowPass)

    %% Check inputs
    if (nargin < 2)
        error('Please provide the sampleRate and TS inputs')
    end

    if (nargin < 3)
       error('Please provide the sampling frequency the TS is to be resampled to')
    end


    modFlag = 0;
    %% Resample

        % Channel label can be empty, it that case time series are empty and
        % the sampling rate is set to 0.
        if ~isempty(TS) 
            if sampleRate ~= resamplingFrequency

                % We should check OINFO.header.prefiltering but OINFO.header.prefiltering
                % is often empty and the data is modified by fixmontage, 
                % then we priorize montage
                minNyquist = min(sampleRate/2, resamplingFrequency/2);

                % If the Time series is not low-pass filtered : low-pass filter
                if ( LowPass == 0  || (LowPass > minNyquist) )
                    [TS, ~] = butterFiltZPLowPass(TS, minNyquist, sampleRate);
                end

                TS = resample(TS, 1/sampleRate:1/sampleRate:length(TS)/sampleRate,...
                    resamplingFrequency); 
                modFlag = 1;
            end
        end

end



