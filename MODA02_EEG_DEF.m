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
% 6_segListSrcDataLoc_p1.txt, 7_segListSrcDataLoc_p2.txt 
% and 8_MODA_primChan_180sjt.txt
genInputPackage = './input/';

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% These files must be requested to the MASS team
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Folder of the EDF files from MASS to read
pathEDFFile = {'./input/MASS_PSG/'};
            
% Run the main script
MODA02_genEEGVectBlock

% % To plot eegVector and GCvect
% load('./output/exp/GCVect_exp_p1.mat');
% load('./MODA02_pack/20200314_160930.m/output/EEGVect_p1.mat');
% iseg=292; iepoch=1;
% figure; subplot(2,1,1); 
% plot(1/100:1/100:23,EEGvector((iseg-1)*11501+(iepoch-1)*2300+1:(iseg-1)*11501+iepoch*2300));
% subplot(2,1,2); 
% plot(1/100:1/100:23,GCVect((iseg-1)*11501+(iepoch-1)*2300+1:(iseg-1)*11501+iepoch*2300));
