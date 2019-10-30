* Release Version 1.0

---------------------------------------------------------
OUTPUT of MODA01 : the generation of the Group Consensus
---------------------------------------------------------

1. The scores averaged across scorers: 
	Filename : scoreAvg_exp_p1.mat, scoreAvg_exp_p2.mat, 
        scoreAvg_re_p1.mat, scoreAvg_ne_p1.mat
	One file per user subtype and phase (if available).
	The average scores of all the 115 s blocks are concatenated in one tall vector.
	There is a NaN between each 115 s block, a unseen block is marked by NaN.
	The frequency sampling rate is 100 Hz.
	Each sample of the tall vector varies between 0 and 1; 
	- 0 : means all scorers agreed for "no spindle"
	- between 0 and 1 : intermediate agreement for a possible spindle
	- 1 : means all scorers agreed for "a definitive spindle"
	
2. The Group Consensus (GC) vector :
	Filename : GCVect_exp_p1.mat, GCVect_exp_p2.mat, 
        GCVect_re_p1.mat, GCVect_ne_p1.mat
	One file per user subtype and phase (if available).
	The frequency sampling rate is 100 Hz.
	The GC vector includes only 0 and 1 (0 means no spindle, 1 means spindle).
	The GC vector is created by thresholding the average scores.
    Therefore, it includes all the 115 s blocks concatenated in one tall vector.
	There is a NaN between each 115 s block, a unseen block is marked by NaN.

3. The GC spindles list where each row is a spindle event with its start 
    and duration (tab separated text file).
	Filename : GC_spindlesLst_exp_p1.txt, GC_spindlesLst_exp_p2.txt, 
        GC_spindlesLst_re_p1.txt, GC_spindlesLst_ne_p1.txt
	One file per user subtype and phase (if available).
	The frequency sampling rate is 100 Hz.
	The row header of the file is: "eventNum, startSamples, durationSamples,
        startSec, durationSec"
	Where the eventNum is the incremental event number,
        based on the location in the GC vector and is unique for each GC.
	Where the startSamples is the start index of the spindle mesured with 
        the number of samples (1 means the first sample of the GC vector).
	Where the durationSamples is the length of the spindle mesured with 
        the number of samples (100 means a duraiton of one second).
	Where the startSec is the start index of the spindle mesured in second.
	Where the durationSec is the length of the spindle mesured in second.


---------------------------------------------------------
OUTPUT of MODA02 : the generation of the EEG time series vector
---------------------------------------------------------

!!! Removed for now since we have to make sure it respects the MASS ethics contract !!!
4.  The EEG time series vector : 
	Filename : EEGVect_p1.mat, EEGVect_p2.mat (One file per phase.)
	The frequency sampling rate is 100 Hz.  
	The EEG values are expressed in µV.
	The EEG vector includes all the 115 s blocks concatenated in one tall vector.
	There is a NaN between each 115 s block.



### Change log: ###	

						


