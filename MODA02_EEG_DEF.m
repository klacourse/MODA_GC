% Package analysis to generate the EEG vector of all the 115 s blocks 
% concatenated in one tall vector.  A vector is generated for each phase 
% (phase 1 and phase 2) of MODA.
% A NaN is added between each 115 s block.
% 
% A similar script could be used to create spindle detection vector 
%   (same concatenation of 115 s block as the eeg vector).  The created 
%   detection vector could be compared to the GCVector to evaluate the
%   performance of the detector.
%
% Author Karine Lacourse 20019-09-25
%   Changes log:
%   
%--------------------------------------------------------------------------

% Clear the environment
clc
clear java 
clear variables

% To use parallel uncomment the parfor and comment
%   the for loop in MODA02_genEEGVectBlock.

% Where the whole package analysis will be saved
    % the folder "MODA02_pack" is created 
    %   with a subfolder that includes the current date & time 
    %   The subfolder includes these folders :
    %       code, info, input, output, warning
genPathPackage  = '';
% Input of the current package
genInputPackage = './input/';

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% These files must be requested to the MASS team
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Folder of the EDF and XML files to read
pathEDFFile = {'./input/MODA_EDFXML/EDF/'};
pathXMLFile = {'./input/MODA_EDFXML/XML/'};
            
% Run the main script
MODA02_genEEGVectBlock
            
            