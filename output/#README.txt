* Release Version 3.0

---------------------------------------------------------
OUTPUT of MODA01 : the generation of the Group Consensus
---------------------------------------------------------

There are 3 folders, one for each user subtype: "exp" for experts, 
"re" for researchers and "ne" for non-experts.

Here we describe the "exp" folder 
(similar files are also included in the "re" and "ne" folders,
these folders include only the phase 1).

1. The scores averaged across scorers: 
	Filename : scoreAvg_exp_p1.mat and scoreAvg_exp_p2.mat
	The average scores of all the 115 s blocks are concatenated in one tall vector.
	There is a NaN between each 115 s block, a unseen block is marked by NaN.
	The frequency sampling rate is 100 Hz.
	Each sample of the tall vector varies between 0 and 1; 
	- 0 : means all scorers agreed for "no spindle"
	- between 0 and 1 : intermediate agreement for a possible spindle
	- 1 : means all scorers agreed for "a definitive spindle"
	phase#1 : 405 blocks of 115 sec sampled at 100 Hz with a NaN between each block (4657905 samples)
		an unseen block is marked NaN.
	phase#2 : 345 blocks of 115 sec sampled at 100 Hz with a NaN between each block (3967845 samples)
	
2. The Group Consensus (GC) vector :
	Filename : GCVect_exp_p1.mat and GCVect_exp_p2.mat
	The frequency sampling rate is 100 Hz.
	The GC vector includes only 0 and 1 (0 means no spindle, 1 means spindle).
	The GC vector is created by thresholding the average scores.
    	Therefore, it includes all the 115 s blocks concatenated in one tall vector.
	There is a NaN between each 115 s block, a unseen block is marked by NaN.
	phase#1 : 405 blocks of 115 sec sampled at 100 Hz with a NaN between each block (4657905 samples)
		an unseen block is marked NaN.
	phase#2 : 345 blocks of 115 sec sampled at 100 Hz with a NaN between each block (3967845 samples)

3. The GC spindles list where each row is a spindle event with its start 
    and duration (tab separated text file).
        Events referenced to the tall EEG vector.
	Filename : GC_spindlesLst_4EEGVect_exp_p1.txt and GC_spindlesLst_4EEGVect_exp_p2.txt
	The frequency sampling rate is 100 Hz.
	The row header of the file is: "eventNum, startSamples, durationSamples,
        startSec, durationSec"
	Where the eventNum is the incremental event number, based on the location 
	in the GC vector (phase#1: 1 to 4657905 samples; phase#2 : 1 to 3967845 samples)
	Where the startSamples is the start index of the spindle mesured with 
        the number of samples (1 means the first sample of the GC vector).
	Where the durationSamples is the length of the spindle mesured with 
        the number of samples (100 means a duration of one second).
	Where the startSec is the start index of the spindle mesured in second.
	Where the durationSec is the length of the spindle mesured in second.

4. The annotation files (.txt) with the GC spindle events for each subject used (tab separated text file).
	Annotation files include events called "segmentViewed" and "spindle".  
	Only the "segmentViewed" were scored for spindles, 10 or 3 segments were scored per PSG file.
	Filename : file name is consistent with the MASS data set (ex 01-01-0001_MODA_GS.txt).
	The row header of the file is: "'startSec','durationSec','eventName'"
	Where the startSec is the start index of the event mesured in second.
	Where the durationSec is the length of the event mesured in second.
	Where the eventName is "segmentViewed" or "spindle".


---------------------------------------------------------
OUTPUT of MODA02 : the generation of the EEG time series vector
---------------------------------------------------------
 The output is not saved because the MASS PSG files are subject to licencing as described on the MASS website
 (http://www.ceams-carsm.ca/mass).

 What output to expect : 
 The EEG time series vector : 
	Filename : EEGVect_p1.mat, EEGVect_p2.mat (One file per phase.)
	The frequency sampling rate is 100 Hz.  
	The EEG values are expressed in µV.
	The EEG vector includes all the 115 s blocks concatenated in one tall vector.
	There is a NaN between each 115 s block.
	phase#1 : 405 blocks of 115 sec sampled at 100 Hz with a NaN between each block (4657905 samples)
	phase#2 : 345 blocks of 115 sec sampled at 100 Hz with a NaN between each block (3967845 samples)



### Change log: ###

version 1.0 : First release, only the train/validation GS MODA dataset is available (90% of whole dataset) 

version 2.0 : Second release, the whole dataset is available. The GS spindle list referenced to the PSG file of each subject has been added.

version 3.0 : MODA GS annotations are aligned with the PSG MASS data V2.0 (ss1-ss5) subsets provided by the MASS team (http://www.ceams-carsm.ca/mass).
						


