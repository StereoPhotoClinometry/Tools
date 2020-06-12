Header='''
# USAGE: python transitMap.py [-option] outfile map1 ... mapN truth
#
#     -o   Use this followed by 'outfile' to
#          specify a unique output destination.
#          Default is transit.png if 'outfile'
#          is not specified.
#
#     -m   Use this followed by a pixel dx dy
#          shift to correct for inertial model
#          differences.
#
#     -s   Use this flag to save text files
#          of the map heights in a common
#          coordinate frame.
#
#     -h   Use this to print usage directions
#          to StdOut. (Prints this header)
#
#     -v   Use this to only output current
#          version number and exit. By default
#          the version will be sent to StdOut
#          at the beginning of each use.
#
#####################################################################
'''


##~AUTHOR INFO~##
# By Taner Campbell
# In support of the OSIRIS-REx mission 2016
##

##~VERSION NOTES~##
# 1.0 - first release
# 1.1 - added fix for inertial shift
#     - added filenames to plot
#     - fixed same size map bug
# 1.2 - added support for multiple [-option] flags (desperately needs a rewrite)
# 2.0 - completely new comandline option parsing
#     - complete re-write to add support for multiple mapfiles 
# 2.1 - changed variable 'type' to 'trType' to avoid built-in conflict
#     - changed plot x-axis to meters (pixels was not technically correct)
# 2.1.1 - fixed empty map list version/header print bug
# 2.1.2 - added MUCH needed comments (could add more)
# 2.2 - changed plot x-axis back to pixels (fixes multi-resolution bug)
##

##~FILE DEPENDENCIES~##
# User specified:
#            - map files, the map files to transit (model first)
#            - output image file, plotted figure showing transit (optional)
#
# Required:
#            N/A
##

##~PYTHON DEPENDENCIES~##
# sys
# numpy
# scipy (for interpolation, currently turned off)
# matplotlib
# struct
##


####################~INITIALIZE~####################
import sys
import numpy as np
from struct import unpack
from matplotlib import pyplot as plt
# from scipy.interpolate import interp2d

version = '2.2'

## Read and parse command line arguments #
opt = sys.argv

option = []
shift = []
maps = []
output = []
soutput = []

out = False
save = False
move = False

for arg in opt:
    if arg.startswith('-') and not arg[1:].isdigit():
        option.append(arg)
    elif arg.isdigit() or arg.startswith('-') and arg[1:].isdigit():
        shift.append(arg)
    elif '.png' in arg:
        output.append(arg)
    elif '.MAP' in arg:
        maps.append(arg)

if any('v' in flag for flag in option):
    sys.exit('Version: '+version)

if any('h' in flag for flag in option):
    sys.exit(Header)

if not maps:
    print('You forgot to specify the maps to compare!')
    maps = raw_input('Please enter the map filenames now: \n').split()

truth = maps[-1]

for flag in option:
    if 'm' in flag:
        move = True
        mX = []
        mY = []
        if not shift:
            shift = raw_input('Enter in dx dy pixel shift(s): \n').split()
        for i in range(0,len(shift),2):
            mX.append(int(shift[i]))
            mY.append(int(shift[i+1]))
    
    if 'o' in flag:
        out = True
        if not output:
            efile = 'transit.png'
        else:
            efile = output[0]

    if 's' in flag:
        save = True
        for map in maps:
            soutput.append(map.replace('MAP','TXT'))
##

print('transitMap.py version: '+version)
print('Model maps: '+str(maps[:-1]).strip('[]'))
print('Truth map: '+truth)

if not any([out, save, move]):
    print('\n')

if out:
    print('Output figure file: '+efile)
if save:
    print('Map save files: '+str(soutput).strip('[]'))
if move:
    print('Map shift(s) (dx, dy): '+str(zip(mX,mY)).strip('[]'))

if out or save or move:
    print('\n')


####################~MODULES~####################
## Injest maplets #
def readMAP(file):
    f = open(file,'rb')
    text = f.read()
    f.close()

    mapHead = text[0:72]
    mapData = text[72::]

    scale = unpack('>f', mapHead[6:10])[0]
    qsz = unpack('<H', mapHead[10:12])[0]
    vlm = unpack('>fff', mapHead[15:27])
    Ux = unpack('>fff', mapHead[27:39])
    Uy = unpack('>fff', mapHead[39:51])
    Uz = unpack('>fff', mapHead[51:63])
    hscale = unpack('>f', mapHead[63:67])[0]

    heights = []
    # albedo = []
    for i in range(0,len(mapData),3):
        heights.append(scale*hscale*unpack('>h', mapData[i:i+2])[0])
        # albedo.append(0.01*unpack('>B', mapData[i+2])[0])

    HT = [heights[i:i+2*qsz+1] for i in range(0,len(heights),2*qsz+1)]
    # ALB = [albedo[i:i+2*qsz+1] for i in range(0,len(albedo),2*qsz+1)]

    if all(i == 0 for i in HT[-1]):   # all(i == 0 and j ==0 for i,j in zip(HT[-1],ALB[-1])):
        del HT[-1]
        # del ALB[-1]

    MP = np.array(HT[:])   # np.array([HT[:],ALB[:]])

    return scale, qsz, vlm, Ux, Uy, Uz, MP
##

## Vector rotation #
def vecRT(BM,V):
    newV = [sum(x*y for x,y in zip(BM[i],V)) for i in range(len(BM))]

    return newV
##

## Array to vector #
def arrVEC(arr,scale,qsz,trType,val):
    vec = np.zeros((arr.shape[0],3))

    for i in range(arr.shape[0]):
        if trType == 'p':
            vec[i] = [-(qsz-i)*scale,-(qsz-val)*scale,arr[i]]   # [dx, dy, dz]
        elif trType == 'l':
            vec[i] = [-(qsz-val)*scale,-(qsz-i)*scale,arr[i]]

    return vec
##

## Matrix to vector #
def matVEC(mat,scale,qsz):
    cnt = 0
    vec = np.zeros((mat.shape[0]*mat.shape[1],3))

    for i in range(mat.shape[0]):
        for j in range(mat.shape[1]):
            vec[cnt] = [-(qsz-i)*scale,-(qsz-j)*scale,mat[i][j]]   # [dx, dy, dz]
            cnt += 1

    return vec
##


####################~READ DATA~####################
scaleT, qszT, vlmT, UxT, UyT, UzT, MPT = readMAP(truth)

nmap = len(maps)-1

scaleM = np.zeros(nmap)
qszM = np.zeros(nmap,np.int)
vlmM = np.zeros((nmap,3))
UxM = np.zeros((nmap,3))
UyM = np.zeros((nmap,3))
UzM = np.zeros((nmap,3))

mapDict = {map: 0 for map in maps[:-1]}

for i in range(nmap):
    scaleM[i], qszM[i], vlmM[i,:], UxM[i,:], UyM[i,:], UzM[i,:], mapDict[maps[i]] = readMAP(maps[i])

if not save:
    print(maps[0]+' size: '+str(mapDict[maps[0]].shape))
    trType,val = raw_input('Enter \'p\' or \'l\' for a pixel or line transit followed by location (ex. p 50): \n').split()
    val = int(val)

    while trType not in ['p','l']:
        print('\nInvalid transit type.')
        trType,val = raw_input('Enter pixel or line transit (p/l) followed by location: \n').split()
        val = int(val)

    if trType == 'p':
        while val > mapDict[maps[0]].shape[1]:
            print('\nInvalid column. Map is '+str(mapDict[maps[0]].shape)+' pixels.')
            val = raw_input('Enter column for transit: \n')
            val = int(val)

        transMP = mapDict[maps[0]][:,val]
    elif trType == 'l':
        while val > mapDict[maps[0]].shape[0]:
            print('\nInvalid row. Map is '+str(mapDict[maps[0]].shape)+' pixels.')
            val = raw_input('Enter row for transit: \n')
            val = int(val)
    
        transMP = mapDict[maps[0]][val]
elif save:
    transMP = mapDict[maps[0]][:]

## Rotation matricies ##
TBrot = [UxT,UyT,UzT]
BMrot = {map: 0 for map in maps[:-1]}
MBrot = {map: 0 for map in maps[:-1]}

for i in range(nmap):
    BMrot[maps[i]] = [[UxM[i][j],UyM[i][j],UzM[i][j]] for j in range(3)]
    MBrot[maps[i]] = [list(UxM[i]),list(UyM[i]),list(UzM[i])]

MBrot[truth] = TBrot
del MBrot[maps[0]]
##


########################~MATH~########################
if not save:
    Mv = arrVEC(transMP,scaleM[0],qszM[0],trType,val)   # Maplet frame vectors to each pixel in km
elif save:
    Mv = matVEC(transMP,scaleM[0],qszM[0])

Bv = np.zeros(Mv.shape)
for i in range(Mv.shape[0]):
    Bv[i] = vecRT(BMrot[maps[0]],Mv[i])   # [dx, dy, dz] Body fixed frame vectors in km

## Partial correction for inertial model shift ##
if move:
    for i in range(nmap):
        dv = [mX[i]*scaleM[i], mY[i]*scaleM[i], 0*scaleM[i]]   # Turn pixel shift into km vector
        dv = vecRT(BMrot[maps[i]],dv)   # Rotate to Body fixed frame

        vlmM[i] = [x+y for x,y in zip(vlmM[i],dv)]   # Add to each vlm
##

## Reasign variable names to make indexing work later ##
if nmap > 1:
    vlm = [list(v) for v in vlmM[1:]]
    vlm.append(list(vlmT))

    qsz = list(qszM[1:])
    qsz.append(qszT)

    scale = list(scaleM[1:])
    scale.append(scaleT)
else:
    vlm = [list(vlmT)]
    qsz = qszT
    scale = [scaleT]
##

## Rotate first map into each other map frame (to get correct px/ln locations) ##
Tv = {map: 0 for map in maps[1:]}
for i in range(nmap):
    svt = np.zeros(Bv.shape)   # Place holder with rotated pixel locations
    for j in range(Bv.shape[0]):
        Bvt = [x+y-z for x,y,z in zip(Bv[j],vlmM[0],vlm[i])]
        # Pixel vector + vlm1 - vlm2 to get pixel location from center of map2

        Tvm = vecRT(MBrot[maps[i+1]],Bvt)
        # Vector from center of each other map to first map pixels in each 
        # other map coordinate frame in km.

        svt[j] = [Tvm[0]/scale[i], Tvm[1]/scale[i], Tvm[2]]
        # Same as above but first two elements in maplet pixels. Last element 
        # only important for first map in truth frame.

    Tv[maps[i+1]] = svt
    # Dictionary where each key represents the first map in that maps 
    # coordinate frame. We only keep the last one (first map in truth frame), 
    # the others are just used for the px/ln locations and reassigned.
##

## OLD CODE (will not work) ##
# x = np.arange(-qszT,qszT+1)
# y = np.arange(round(Tv[0][0])-16,round(Tv[0][0])+16)
# X,Y = np.meshgrid(x,y)
# ht = interp2d(Y, X, MPT[qszT+round(Tv[0][0])-16:qszT+round(Tv[0][0])+16,:], kind='cubic')
# transMPT = []
# transMPT.append(1000*ht(Tv[i][0],Tv[i][1])[0])
##

## Get all but first map in the truth frame (reassigns keys in Tv dictionary) ##
if nmap > 1:
    for i in range(nmap-1):
        Mv = []   # Re-initialize Mv
        MP = mapDict[maps[i+1]]   # Because I don't like typing
        sT = Tv[maps[i+1]]   # Ditto
        for j in range(sT.shape[0]):
            a = qsz[i]+round(sT[j][0])
            b = qsz[i]+round(sT[j][1])

            if a < MP.shape[0] and b < MP.shape[1]:
                Mv.append([-(qsz[i]-a)*scale[i], -(qsz[i]-b)*scale[i], MP[a][b]])

        Mv = np.array(Mv)
        svt = np.zeros(Mv.shape)
        for j in range(Mv.shape[0]):
            Bv = vecRT(BMrot[maps[i+1]],Mv[j])              #
            Bvt = [x+y-z for x,y,z in zip(Bv,vlm[i],vlmT)]  # <- Should look familiar
            Tvm = vecRT(MBrot[truth],Bvt)                   #
            svt[j] = [Tvm[0]/scaleT, Tvm[1]/scaleT, Tvm[2]] #
        Tv[maps[i+1]] = svt   
        # Now each key is each map in the truth frame. 
        # (Except truth key. Which is the first map in the truth frame. Don't judge me.)
##

nearNT = []   # Empty list for nearest neighboring point from truth
sT = Tv[truth]   # I really don't like typing
for i in range(sT.shape[0]):
    a = qszT+round(sT[i][0])
    b = qszT+round(sT[i][1])

    if a < MPT.shape[0] and b < MPT.shape[1]:
        nearNT.append(1000*MPT[a][b])   # Truth heights in meters

transMPM = 1000*Tv[truth][:,2]   # First map heights in truth frame in meters

modelShift = {map: 0 for map in maps[:-1]}
modelShift[maps[0]] = transMPM

if nmap > 1:
    for i in range(nmap-1):
        transMPM = 1000*Tv[maps[i+1]][:,2]
        modelShift[maps[i+1]] = transMPM   # All other map heights in truth frame in meters


####################~OUTPUT~####################
if not save:
    fig = plt.figure()
    ax1 = plt.subplot(1,1,1)
    ax1.plot(np.arange(len(nearNT)), nearNT, c='k', label=truth)   # Plot truth in black

    ## Plot all other maps ##
    for i in range(nmap):
        ax1.plot(np.arange(len(modelShift[maps[i]])), modelShift[maps[i]], label=maps[i])
        # ax1.plot(range(len(transMPT)), transMPT, c='g', label='Truth')
    ##

    plt.legend(loc='upper right')
    plt.grid()
    plt.xlabel('Pixels (%d cm/px)' % round(100000*scaleM[0]))
    plt.ylabel('Meters')

    if not out:
        plt.show()
    elif out:
        plt.savefig(efile)
elif save:
    mapo = {map: 0 for map in maps}

    mapo[truth] = np.array(nearNT).reshape((2*qszM[0]+1,2*qszM[0]+1))   # Reshape truth

    for i in range(nmap):
        mapo[maps[i]] = np.array(modelShift[maps[i]]).reshape((2*qszM[0]+1,2*qszM[0]+1))   # Reshape everybody else

    for i in range(nmap+1):
        np.savetxt(soutput[i],mapo[maps[i]])
