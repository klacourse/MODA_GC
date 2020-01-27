# README

* Release Version 2.0


# What is this code for?

This package is for the MODA (Massive Online Data Annotation) Groups Consensus (GC) set of spindles.
For more details, and to leave comments or questions for the project, see MODA on Open Science Framework at https://osf.io/8bma7/

### Short summary of the MODA project 
Sleep EEG time series from 180 subjects were presented as “phase#1-100 younger subjects” 
and “phase#2-80 older subjects” to be scored for spindles.
“Blocks” of 115 s were randomly extracted from artifact free Stage N2 sleep. 
3 blocks were extracted in 85 subjects in phase 1 and 65 subjects in phase 2; 
and 10 blocks were extracted in the remaining 15 subjects of each phase. 
These 115 s blocks of data extracted have been packed (concatenation of all blocks) 
in a tall vector (with a NaN separating each 115 s block). Therefore, 
the scores of the annotators can be analyzed in a tall vector (one for each phase)
 instead of 750 vectors (one for each 115 s block extracted).

### Short summary of what is a Groups Consensus (GC) set of spindles
Scorers rated their confidence (low, med, high) for each spindle marked. 
Specifically, each sample of the EEG time series had a score weighted by 
the confidence rate given by the scorer; 1 for high, 0.75 for medium, 
0.5 for low confidence and 0 for no spindle at all. 
Then, sample by sample, the scores are averaged across scorers, 
and if they exceed the chosen Group Consensus Threshold (GCt) then 
these samples were identified to be part of the GC spindle dataset.

### Data available to download
Following machine learning best practices we suggest that developers should train, 
validate and test their algorithm with a nested cross-validation on the open MODA GS.
The whole dataset is available, developpers should keep a separate data set for testing.

### Short summary of what is the code for
The spindle event locations file (that includes all the spindles scored by 
all the annotators) is read and the GC set of spindles is generated.  The GC is generated 
for each user subtype "experts (exp), researchers (re), Non-experts (ne)" 
and phase (if available). 
Main outputs generated :
    -a tall (.mat) vector of the score averaged across scorers
    -a tall (.mat) vector of the GC spindle events (1 means spindle and 0 means no spindle)
    -a text file (.txt) of the list of the GC spindle events (start index and duration)
    -a tall (.mat) vector of the EEG time series scored (extracted blocks concatenated)

The package has been developed on Linux 16.04 with MATLAB R2018b 
(no toolbox is needed unless you want to run in parallel).

## What will I find in this code package?

This package is composed of 2 main scripts : 
    "MODA01_genAvgScoreAndGC.m" and "MODA02_genEEGVectBlock.m";
with their definition setting scripts :  
    "MODA01_GC_DEF.m" and "MODA02_EEG_DEF.m";
an input, output and a library folder.

* Input folder "input" includes
	1. 1_EpochViews_exp_re.txt : The list of epochs viewed by the experts and the researchers.
	2. 2_EpochViews_ne.txt : The list of epochs viewed by the non-experts.
	3. 3_EventLocations_exp_re.txt : The list of events scored by the experts and the researchers.
	4. 4_EventLocations_ne.txt: The list of events scored by the experts and the non-experts.
	5. 5_userSubtypeAnonymLUT_exp_re.txt : The user subtype (experts or researchers) of each annotator.	
	6. 6_segListSrcDataLoc_p1.txt : The 404 extracted 115 s blocks from the 100 edf files for the phase 1.
	  * warning : a block has not been presented to the scorers
	  * 	then the subject MODA_01-02-13 has only 2 blocks
	  * 	the epoch num 1956 to 1960 have been removed from 
	  * 	the file 6_segListSrcDataLoc_p1.txt
	  * 	Real total number of block is 404
	7. 7_segListSrcDataLoc_p2.txt : The 345 extracted 115 s blocks from the 80 edf files for the phase 2.
 
  -> For more information read the #README.txt in the input folder.

* Output folder "output" includes the MODA GC for the whole dataset
	There are 3 folders, one for each user subtype: "exp" for experts, "re" for researchers and "ne" for non-experts.
	Each folder includes:
	1. scoreAvg_user_px.mat : 
        the average score vector across scorers (ex. scoreAvg_exp_p1.mat),
        the GC threshold is not applied, packed in a tall vector.
	2. GCVect_user_px.mat : 
        the GC vector (ex. GCVect_exp_p1.mat), the GC threshold is applied, 
        then it includes only 0 and 1 (0 means no spindle, 1 means spindle), 
	packed in a tall vector.
	3. GC_spindlesLst_user_px.txt : 
        the GC spindles list on the tall EEG vector where each row is a spindle event with its start and duration.
	(ex. GC_spindlesLst_4EEGVect_exp_p1.txt).
	4. GC_spindlesLst_4PSG_user_px.txt :
	the GC spindles list from each PSG source file where each row is a spindle event with its start and duration.
	5. GC_blockViewedLst_4PSG_user_px.txt :
	the blocks scored from each PSG source file where each row is an eeg block scored with its start and duration.
	6. !!! EEGVect_px.mat may soon be available, for now it has to be generated from the EDF/XML files !!! : 
        the EEG time series vector (ex. EEGVect_p1.mat) of the extracted 
        115 s blocks concatenated in one tall vector.
  
  -> For more information read the #README.txt in the output folder.
						

* Library folder "lib"
  * This folder contains all the matlab functions required to run this package



## How do I get set up?

* Open "MODA01_GC_DEF.m" and modify the settings available to match your configuration.  
	Some variables (as the Group Consensus Threshold and the spindle length limit) 
    could be modified in order to create your own set of GC spindles.
* Run "MODA01_GC_DEF.m" script in matlab.
* Go to the ./MODA01_pack/currentDate_Time_user.m/output/ to view the results.
* You can also use the outputs files already saved in the output folder.
OR
* Go to http://www.ceams-carsm.ca/mass and request the dataset for MODA.  
Access to these files requires that the investigators submit a copy of their project 
(as approved by their local ethics board) and a proof of ethical approval. 
Upon reception of these documents, the MASS team will provide to the requesting 
investigators the whole set of PSG files for the MODA Gold Standard.
* Copy the 180 edf and XML files into the input folder.
* Open "MODA02_EEG_DEF.m" and modify the settings available to match your configuration.  
* Run "MODA02_EEG_DEF.m" script in matlab.
* Go to the ./MODA02_pack/currentDate_Time_user.m/output/ to view the results.


## What to expect from the MASS team

You should get from the MASS team a folder called "MODA_EDFXML".
The folder includes
-#README.txt : description of the MODA_EDFXML 
-MODA_EDF folder : includes the 180 edf (PSG) files (biosignal for each subject)
-MODA_XML folder : includes the 180 xml files (sleep stages and GS spindles as event for each subject)
Read the #README.txt in the "MODA_EDFXML" folder for more details.


## Interpreting the Results

The GC spindle events list is found in ./output/exp/GC_spindlesLst_4EEGVect_user_px.txt, 
where each row is a spindle event. Note that these spindle events are based 
on the GC vector (all the 115 s blocks concatenated in one tall vector, 
a NaN separates each block).  A startSamples=1 means the first sample of the GC vector.
Or
The GC spindle events list is found in ./output/exp/GC_spindlesLst_4PSG_user_px.txt, 
where each row is a spindle event.  Note that these spindle events are listed 
with their start and duration for each PSG file.



### Contributors

* The code was written by Karine Lacourse
* The code was reviewed by Benjamin Yetton 
* The project was under the supervision of Dr. Simon Warby (Ph.D.)



### Who do I talk to if I need help?

For more details, and to leave comments or questions for the project, 
see MODA on Open Science Framework at https://osf.io/8bma7/. 
Alternatively, raise and issue on github.



### REMARKS :
Free use and modification of this code is permitted, provided that
any modifications are also freely distributed.

When using this code or modifications of this code, please cite:

        Lacourse, K., Yetton, B., Mednick, S. & Warby, S. C. 
        Massive Online Data Annotation (MODA): crowdsourcing to generate 
        high quality sleep spindle annotations from EEG data.
	(under review)

### Change log:

version 1.0 : First release, only the train/validation GS MODA dataset is available (90% of whole dataset) 
version 2.0 : Second release, the whole dataset is available. The GS spindle list referenced to the PSG file of each subject has been added.


