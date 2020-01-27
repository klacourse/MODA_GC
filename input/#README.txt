
* Release Version 2.0

The scoring files of the whole dataset.

Total number of subjects and blocks of 115 sec for the whole database:
	phase 1 : 100 subjects
	  -85 subjects with 3 blocks 
	  -15 subjects with 10 blocks
	  -Total of 405 blocks
	  * warning : a block has not been presented to the scorers
	  * 	then the subject MODA_01-02-13 has only 2 blocks
	  * 	the epoch num 1956 to 1960 have been removed from 
	  * 	the file 6_segListSrcDataLoc_p1.txt
	  * 	Real total number of block is 404
	phase 2 : 80 subjects
	  -65 subjects with 3 blocks
	  -15 subjects with 10 blocks
	  -Total of 345 blocks
	For a total of 750 blocks

---------------------------------------------------------
The MODA web interface output files
---------------------------------------------------------
1_EpochViews_exp_re.txt : The list of epochs viewed by the experts and the researchers.
(The same epoch is viewed many times, but not by the same scorer.)
2_EpochViews_ne.txt : The list of epochs viewed by the non-experts.
3_EventLocations_exp_re.txt : The list of events scored by the experts and the researchers.
4_EventLocations_ne.txt : The list of events scored by the experts and the non-experts.
5_userSubtypeAnonymLUT_exp_re.txt : The user subtype (experts or researchers) of each annotator.

---------------------------------------------------------
The lists of the extracted 115 s block.
---------------------------------------------------------
-> !!! the eeg signal here is downsampled to 100 Hz !!!
6_segListSrcDataLoc_p1.txt : The 404 extracted 115 s blocks from the 100 edf files for the phase 1.
* warning : a block has not been presented to the scorers
* 	then the subject MODA_01-02-13 has only 2 blocks
* 	the epoch num 1956 to 1960 have been removed from the file 6_segListSrcDataLoc_p1.txt
* 	Real total number of block is 404 but the index goes from 1 to 405.
7_segListSrcDataLoc_p2.txt : The 345 extracted 115 s blocks from the 80 edf files for the phase 2.


All tab separated text file.

!!! Warnings !!!
The EDF/XML files for MODA and provided my the MASS team could be added in this input folder.
The MODA EDF/XML are needed to run the MODA02_EEG_DEF.m script.


### Change log: ###

version 1.0 : First release, only the training/validation GC MODA dataset is available (90% of whole dataset)
version 2.0 : Second release, the whole GC MODA dataset is available

