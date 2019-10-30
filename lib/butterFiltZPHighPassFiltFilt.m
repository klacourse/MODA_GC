
function [output, errorMess] = butterFiltZPHighPassFiltFilt(input, Fpass, Fs, filterOrder)
% Highpass Butterworth IIR filter.
% Filter constructed using butter
% Filter constructed zero-pole-gain filter 
% Input is an EEG timeseries. Output is the filtered EEG signal.
%
% Simon Warby 2014-04-30 (from filtfilt_butter_highpass.m) 
% Modified log:
%   Karine Lacourse 2015-10-13
%                   - Change for a zero pole butterworth with order=10
%                   (because the recursive application shows less
%                   significative modification of the filtered time series)
%-------------------------------------------------------------------------

    if nargin < 4
        filterOrder = 10; % the higher the order, the steeper the slope of the filter and longer processing
    end

    nyq             = Fs*0.5;   % Nyquist frequency
    Wn              = Fpass/nyq;% Window; fraction of 0-nyq being filtered
    showFreqResp    = 0;        % To show the frequency response of the filter

    errorMess = cell(0,0);

    % Check that input is numeric
    if ~isnumeric(input)
        errorMess{length(errorMess)+1} = 'highpass - input is not numeric';
    end

    % Check that Fpass is not less than zero or greater than, or too close to nyquist
    if Fpass < 0
        errorMess{length(errorMess)+1} = 'highpass - cutoff freq must be > 0 Hz';
    end
    if Fpass>=nyq
        errorMess{length(errorMess)+1} = 'highpass - frequency cannot be > fs/2';
    end

    % Check that the Fs is not too low for the Fpass   
    if Wn>=1
        errorMess{length(errorMess)+1} = 'highpass - frequency is higher than Nyquist';      
    end

    % If an error occurs dont apply the filter (xml file has to be fixed)
    if isempty(errorMess)
        
        % Desing with transfer function
        % [a,b] = butter(filterOrder, Wn, 'high');
        % Design the filter with zero-pole-gain form
        [z,p,k] = butter(filterOrder, Wn, 'high');
        [sos,scaleFactG] = zp2sos(z,p,k);
%         if scaleFactG~=1
%             warning('The scaling factor is %f',scaleFactG);
%         end
        
        % Plot Freq response
        if showFreqResp == 1
            fvtool(sos,'Fs',Fs); xlim([0 nyq/2]);
        end
        
        % Apply filtering with FilFilt to remove the phase and group delay
        % It is applied 2 times on the eeg signal (forward and backward)
        output = filtfilt(sos,scaleFactG,input);
    else
        output = input;
    end

end


