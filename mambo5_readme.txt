Author: Kristofer Drozd
Date: November 20, 2015

Description:
This text file explains how to use mambo5.py to get polar plots of spacecraft and sun locations with respect to a landmark. 

Inputs:
In order for this code to work, it must be ran in a directory containing the following text files (all textiles are a column):

LMRKNAMES.txt: name of the landmark being analyzed (only one landmark)
NUMBERPIC.txt: # of pictures taken of landmark
RESOLUTION.txt: resolution of each picture
PICTIMES.txt: UTC time of each picture
LAT.txt: latitude of landmark
LON.txt: west longitude of landmark
SCOBJ1.txt: x component of space craft to object center vectors (BF frame)
SCOBJ2.txt: y component of space craft to object center vectors (BF frame)
SCOBJ3.txt: z component of space craft to object center vectors (BF frame)
SZ1.txt: x component of object center to sun unit vectors (BF frame)
SZ2.txt: y component of object center to sun unit vectors (BF frame)
SZ3.txt: z component of object center to sun unit vectors (BF frame)
VLM1.txt: x component of object center to landmark vectors (BF frame)
VLM2.txt: y component of object center to landmark vectors (BF frame)
VLM3.txt: z component of object center to landmark vectors (BF frame)

Outputs:
When this code is run it makes a sun polar plot, sc polar plot, and a text file of parameters in the same directory the code is run.

How to use mambo5.py:
type "python <path>/mambo5.py" in the LMRK_SUN_SC_POS_TEXTILES directory.


How to make the text files:
Make a directory called LMRK_SUN_SC_POS_TXTFILES in a SPC working directory. Then within LMRK_SUN_SC_POS_TXTFILES make a textfile named LMRKNAMES.txt with just the name of the one landmark to be analyzed. Next, make sure RESIDUALS has been used so that MAPINFO.TXT and PICINFO.TXT are in the working directory. Then type "sh POS_SCRIPT_new.sh" in the SPC working directory. 


