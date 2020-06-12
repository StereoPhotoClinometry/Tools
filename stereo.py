Header='''
# USAGE: python stereo.py [-option] outfile infile
#
#     -o   Use this followed by 'outfile' to
#          specify a unique output destination.
#          Default is stereo.txt
#
#     -h   Use this to print usage directions
#          to StdOut. (Prints this header)
#
#     -v   Use this to only output current 
#          version number and exit. By default 
#          the version will be sent to StdOut
#          at the beginning of each use.
#
#   ** N.B. If 'infile' is not specified, LMRKLIST.TXT
#           will be used.  
#######################################################
'''


##~AUTHOR INFOR~##
# By Tanner Campbell
# In support of the OSIRIS-REx mission 2016
##

##~VERSION NOTES~##
# 1.0 - first release
# 1.1 - fixed LatLon index bug (forgot to change limit after debugging)
#     - added support for files other than default ending with 'END'
# 1.1.1 - added file dependencies
# 1.1.2 - added "-h" option to display usage
# 1.2 - removed option print redundancies
#     - made pictures array more robust
#     - fixed single image bug
#     - improved readability
# 2.0 - reworked to give net stereo and sun divergent angle (more useful)
#     - updated and streamlined code
# 2.1 - fixed zero image bug
# 2.1.1 - fixed append typo
# 2.2 - correctly fixed zero image bug
#     - removed string assignment redundancies
# 2.3 - exclude zero image landmarks from computation
#     - print out excluded landmarks
# 2.4 - CM ready version
#     - fixed max of list of lists bug
#     - fixed read data as 'all'
#     - added author info
#     - added comments
#     - added required python package list
##

##~FILE DEPENDENCIES~##
# User specified:
#            - input file, list of landmarks to process. Default is LMRKLIST.TXT
#            - output file, where data out is to be stored. Default is $wd/stereo.txt
#
# Required:
#            - MAPINFO.TXT, must be up to date to access landmark Lat and Lon
#            - SUMFILES/, required for SCOBJ and SZ vector
#            - LMKFILES/, required for image names and VLM
##

##~PYTHON DEPENDENCIES~##
# sys
# math
##


########################~INITIALIZE~########################
import sys
import math

version = '2.4'

## Read and parse command line arguments #
opt = sys.argv
efile = 'stereo.txt'

if len(opt) == 1:
    file = 'LMRKLIST.TXT'
elif len(opt) == 2 and opt[1][0] != '-':
    file = opt[1]
else:
    if opt[1][0] == '-':
        if opt[1][1] == 'v':
            sys.exit('Version: '+version)
        elif opt[1][1] == 'h':
            sys.exit(Header)
        elif opt[1][1] == 'o':
            efile=opt[2]
            if len(opt) == 3:
                file = 'LMRKLIST.TXT'
            else:
                file = opt[3]
##

print('Stereo.py version: '+version)
print('List of landmarks used: '+file)
print('Output file: '+efile)


########################~MODULES~########################
## Select range from list between two patterns #
def RNGTXT(p1,p2,text):
    l1 = text.find(p1)
    l2 = text.find(p2)
    rangeText = text[l1+len(p1):l2]

    return rangeText
##

## Vector dot product #
def VDOT(v1,v2):
    a = [x*y for x,y in zip(v1,v2)]
    vdot = sum(a)

    return vdot
##

## Fix float rounding error ( for use with acos() ) #
def FXFLT(v):
    return min(1,max(v,-1))
##


########################~READ DATA~########################
f = open(file,'r')
lmklist = f.read()
f.close()

## Parse list of landmarks and check for "END" #    
p2 = 'END'
l2 = lmklist.find(p2)

if l2 == -1:
    list = lmklist.splitlines()
else:    
    list = lmklist[0:l2]
    list = list.splitlines()
##

## Read MAPINFO.TXT #
mapfile = 'MAPINFO.TXT'
h = open(mapfile,'r')
maps = h.readlines()
h.close()
##

cnt1 = 0

lines = [0 for i in list]
allpics = []
maxSCST = []
avgSCST = []
maxSUNST = []
avgSUNST = []
exclude = []

print('Working on:')
for lm in list:
    print(lm+' '+str(cnt1+1)+' out of '+str(len(list)))

    cnt2 = 0

    lines[cnt1] = [x for x in maps if x[0:6] == lm]   # Get landmark info from MAPINFO.TXT for lat lon later 

    ## Read landmark file #
    lmkfile = 'LMKFILES/'+lm+'.LMK'
    g = open(lmkfile,'r')
    text = g.read()
    g.close()
    ##

    ## Get list of images in landmark #
    imlist = RNGTXT('PICTURES','MAP',text)
    imlist = imlist.split()
    pictures = [i for i in imlist if len(i) == 12]
    allpics.append(len(pictures))
    ##

    ## Get landmark central vector #
    vlm = RNGTXT('RMSLMK','VLM',text)
    vlm = vlm.replace('D','E')
    vlm = vlm.split()
    vector = [float(i) for i in vlm]
    ##

    lmksc = [[0]*3 for _ in range(len(pictures))]
    lmksun = [[0]*3 for _ in range(len(pictures))]

    stereoSC = [[0]*len(pictures) for _ in range(len(pictures))]
    stereoSUN = [[0]*len(pictures) for _ in range(len(pictures))]

    for j in pictures:
        ## Read picture sumfile #
        pictfile = 'SUMFILES/'+j+'.SUM'
        k = open(pictfile,"r")
        sumf = k.read()
        k.close()
        ##

        ## Get SCOBJ #
        sc = RNGTXT('CTR','SCOBJ',sumf)
        sc = sc.replace('D','E')
        sc = sc.split()
        scobj = [float(i) for i in sc]
        ##

        ## Get Sun vector #
        sun = RNGTXT('CZ','SZ',sumf)
        sun = sun.replace('D','E')
        sun = sun.split()
        vsun = [float(i)*1.496e8 for i in sun]   # Approx Sun-Bennu distance ~ 1AU
        ##


########################~MATH~########################
        lmksc[cnt2] = [-(i+j) for i,j in zip(scobj,vector)]   # Landmark-Spacecraft vector
        lmksun[cnt2] = [i-j for i,j in zip(vsun,vector)]   # Landmark-Sun vector

        cnt2 += 1

    for l in range(len(pictures)):
        for n in range(len(pictures)):
            vsq1 = [i**2 for i in lmksc[l]]
            vmag1 = sum(vsq1)**0.5

            vsq2 = [i**2 for i in lmksc[n]]
            vmag2 = sum(vsq2)**0.5

            den = vmag1*vmag2
            num = VDOT(lmksc[l],lmksc[n])
            v = FXFLT(float(num)/den)
            
            stereoSC[l][n] = math.degrees(math.acos(v))   # Angles between each lmksc vector
            if l == n:
                stereoSC[l][n] = 0.0
           
            vsq1 = [i**2 for i in lmksun[l]]
            vmag1 = sum(vsq1)**0.5

            vsq2 = [i**2 for i in lmksun[n]]
            vmag2 = sum(vsq2)**0.5

            den = vmag1*vmag2
            num = VDOT(lmksun[l],lmksun[n])
            v = FXFLT(float(num)/den)
            
            stereoSUN[l][n] = math.degrees(math.acos(v))   # Angles between each lmksun vector
            if l == n:
                stereoSUN[l][n] = 0.0

    ## Exclude landmarks with no images #
    if len(pictures) == 0:
        exclude.append(lm)
        list.remove(lm)
        del lines[cnt1]
    ##

    else:
        max1 = max(max(a[:]) for a in stereoSC)
        max1 = "{0:.3f}".format(max1)
        maxSCST.append(max1)   # Maximum lmksc stereo angle

        max2 = max(max(a[:]) for a in stereoSUN)
        max2 = "{0:.3f}".format(max2)
        maxSUNST.append(max2)   # Maximum lmksun stereo angle

        avg1 = float(sum([sum(i) for i in stereoSC]))/len(pictures)**2
        avg1 = "{0:.3f}".format(avg1)
        avgSCST.append(avg1)   # Average lmksc stereo angle

        avg2 = float(sum([sum(i) for i in stereoSUN]))/len(pictures)**2
        avg2 = "{0:.3f}".format(avg2)
        avgSUNST.append(avg2)   # Average lmksun stereo angle

    cnt1 += 1


########################~FILE WRITEOUT~########################
print('\nExcluded landmarks (0 images):')

for i in range(len(exclude)):
    print(exclude[i])

## Pull lat & lon from MAPINFO.TXT data #
LL = []
for i in range(len(list)):
    LL.append(str(lines[i]).split()[3:5])
##

d = open(efile,'w')
for m in range(len(list)):
    d.write(list[m]+'  '+LL[m][0]+'  '+LL[m][1]+'  '+str(allpics[m])+ \
            '  '+avgSCST[m]+' '+maxSCST[m]+'  '+avgSUNST[m]+' '+maxSUNST[m]+'\n')
d.close()
