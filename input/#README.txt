
* Release Version 1.0

The scoring files modified to keep only 90% of the total number of subjects for training/validation.

Total number of subjects for the whole database:
	phase 1 : 100 subjects
	  -85 subjects with 3 blocks 
	  -15 subjects with 10 blocks
	  -Total of 405 blocks
	phase 2 : 80 subjects
	  -65 subjects with 3 blocks
	  -15 subjects with 10 blocks
	  -Total of 345 blocks
	For a total of 750 blocks

The training/validation set includes:
	phase 1 : 13 subjects/10 blocks + 77 subjects/3 blocks = 361 blocks
	phase 2 : 14 subject/10 blocks + 58 subjects/3 blocks = 314 blocks

---------------------------------------------------------
The MODA web interface output files
---------------------------------------------------------

1_EpochViews_exp_re_90.txt : The list of epochs viewed by the experts and the researchers.
2_EpochViews_ne_90.txt : The list of epochs viewed by the non-experts.
3_EventLocations_exp_re_90.txt : The list of events scored by the experts and the researchers.
4_EventLocations_ne_90.txt : The list of events scored by the experts and the non-experts.
5_userSubtypeAnonymLUT_exp_re_20190521.txt : The user subtype (experts or researchers) of each annotator.

---------------------------------------------------------
The lists of the extracted 115 s block.
---------------------------------------------------------
6_segListSrcDataLoc_p1.txt : The 405 extracted 115 s blocks from the 100 edf files for the phase 1.
7_segListSrcDataLoc_p2.txt : The 345 extracted 115 s blocks from the 80 edf files for the phase 2.
6_segListSrcDataLoc_p1_90.txt : 361 extracted 115 s blocks from 90 edf files for the phase 1.
7_segListSrcDataLoc_p2_90.txt : 314 extracted 115 s blocks from 72 edf files for the phase 2.
6_segListSrcDataLoc_p1_10.txt : 44 extracted 115 s blocks from 10 edf files for the phase 1.
7_segListSrcDataLoc_p2_10.txt : 31 extracted 115 s blocks from 8 edf files for the phase 2.


All tab separated text file.

!!! Warnings !!!
The EDF/XML files for MODA and provided my the MASS team could be added in this input folder.
The MODA EDF/XML are needed to run the MODA02_EEG_DEF.m script.


### Change log: ###

version 1.0 : First release, only the training/validation GC MODA dataset is available (90% of whole dataset)


