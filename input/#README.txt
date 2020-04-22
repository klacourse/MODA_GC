
* Release Version 3.0

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
6_segListSrcDataLoc_p1.txt : The 404 extracted 115 s blocks from the 100 edf files for the phase 1.
* warning : a block has not been presented to the scorers
* 	then the subject MODA_01-02-13 has only 2 blocks
* 	the epoch num 1956 to 1960 have been removed from the file 6_segListSrcDataLoc_p1.txt
* 	Real total number of block is 404 but the index goes from 1 to 405.
7_segListSrcDataLoc_p2.txt : The 345 extracted 115 s blocks from the 80 edf files for the phase 2.

---------------------------------------------------------
The eeg channel used to score spindles
---------------------------------------------------------
8_MODA_primChan_180sjt.txt : The channel (C3-A2 or C3-LE) used for each of the 180 edf files.
Since clinical montage uses typically C3-A2, the C3 eeg signal from the PSG file was reformated to A2 when available.

All tab separated text file.


### Change log: ###

version 1.0 : First release, only the train/validation GS MODA dataset is available (90% of whole dataset) 

version 2.0 : Second release, the whole dataset is available. The GS spindle list referenced to the PSG file of each subject has been added.

version 3.0 : MODA GS annotations are aligned with the PSG MASS data V2.0 (ss1-ss5) subsets provided by the MASS team (http://www.ceams-carsm.ca/mass).

