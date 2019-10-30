% Script to setup your local environment and to tun MODA01_genAvgScoreAndGC.m.
%
% Inputs: (all saved in the ./input folder)
%   For experts (exp) and researchers (re)
%   - EventLocationsAnonym_exp_re_20190521.txt
%   - EpochViewsAnonym_exp_re_20190521.txt
%   - userSubtypeAnonymLUT_exp_re_20190521.txt
%   For non-experts (ne)
%   - EventLocations_ne_20160713.txt
%   - EpochViews_ne_20160706.txt
%
% Outputs: 
%   An output folder "MODA01_pack" is created after the run of this script to avoid overwrite. 
%   The folder "MODA01_pack" is created with a subfolder named with the 
%   current date & time and the chosen userSubtype ex) 20190924_100513_exp.m
%   It's a whole package analysis that includes the Matlab code, the processing time info, 
%   an input folder with the list of input files used and an output folder with the generated data.
%   To have more detail read the README.txt, the header of MODA01_genAvgScoreAndGC.m
%   and the #README in the ./output folder.
%
%   The most relevant outputs (for exp, re and ne) have already been saved 
%   in the ./output folder.
% 
% Author: Karine Lacourse 2019-09-24
%   Changes log:
%   
%--------------------------------------------------------------------------

% Clear the environment
clc
clear java 
clear variables

% Choose the user subtype between 'exp', 're', 'ne'
%   Running non-expert (ne) is longer and can be optimized by using parallel
%   toolbox if available. To use parallel uncomment the parfor and comment
%   the for loop in scoreEpochViewed.m and scoreSpindles.m.
userSubtype = 'ne';

% Where the whole package analysis will be saved
    % the folder "MODA01_pack" is created 
    %   with a subfolder that includes the current date & time and the
    %   chosen userSubtype ex) 20190924_100513_exp.m
    %   The subfolder includes these folders :
    %       code, info, input, output, warning
genPathPackage  = '';
% Input of the current package
genInputPackage = './input/';

% Group Consensus threshold to use for phase1 and phase2 if available.
GCTHRESH_EXP = {0.2, 0.35};
GCTHRESH_RE  = {0.15};
GCTHRESH_NE  = {0.3};

% Manage the length of the spindles for the GC
% An average of scores threholded for the consensus could produce too
% short, too close or too long spindles, the GC needs to be cleaned-up.
SPINDLELENGTH.min   = 0.3;
SPINDLELENGTH.max   = 2.5;
SPINDLELENGTH.merge = 0.1;

% Patch to make sure none of the toolboxes were needed.
% S = toggleToolbox('all','off');

% Run the main script
MODA01_genAvgScoreAndGC

% % To evaluate if the generated file is the same than the original one
% fileOri = './output/GC_spindlesLst_re_p1.txt';
% file2Test = './MODA01_pack/20190924_150251_re.m/output/GC_spindlesLst_re_p1.txt';
% diff -s -B -b fileOri file2Test


