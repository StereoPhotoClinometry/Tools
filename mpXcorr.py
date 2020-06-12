Header='''
# USAGE: python mpXcorr.py [-option] outfile image1 image2
#
#     -o   Use this followed by 'outfile' to
#          specify a unique output destination.
#          Default is corrOut.png if 'outfile'
#          is not specified.
#
#     -h   Use this to print usage directions
#          to StdOut. (Prints this header)
#
#     -v   Use this to only output current
#          version number and exit. By default
#          the version will be sent to StdOut
#          at the beginning of each use.
#
########################################################
'''


##~AUTHOR INFO~##
# By Tanner Campbell
# In support of the OSIRIS-REx mission 2016
#
# Adapted from: Fast Normalized Cross-Correlation, Lewis 1995
#               Fast Template Matching, Lewis 1995
##

##~VERSION NOTES~##
# 1.0 - first release
# 1.1 - added dx,dy print out for template shift
#     - added sub-sample of template for equal size images
#     - few minor style changes
# 1.2 - added pos. axis display to the output 
#     - removed secondary "normalization"
#     - added printout of max correlation
#     - fixed output to remove blank 4th plot
# 1.2.1 - removed option print redundancies
# 1.3 - fixed 0.5 pixel dx, dy bias
#     - added colorbar to plot
#     - scaled correlation plot between 0.2 and 1
#     - fixed data print out to remove []
#     - changed marker color and type for visibility
#     - fixed autoscaled ax3
# 1.4 - CM ready version
#     - added support for .MAP files (experimental)
#     - made figure output optional '-o' turns this on
#     - added comments
#     - added required python package list
#     - added author info
#
# *** Version Split ***
#
# 1.5A - mpXcorr.py
#      - support for .MAP and showmap .pgm files
#      - rescaled template in output image
# 1.5A.1 - suppressed erroneous divide by zero warning
# 1.5A.2 - added check for beginning and ending zeros from showmap
#        - changed axis definitions to match SPC map coordinate frame
# 1.5A.3 - working .MAP support (correlates albedo channel only)
#        - turned template plot axes back on
#        - changed buffer plot background to black (white had scaling issues)
# 1.5A.3.1 - added print out to give center pixel correlation value
# 1.6A - improved input argument parsing (much faster and more gracefull)
#      - fixed potential bug for very small images
# 1.6A.1 - fixed empty image list version/header print bug
##

##~FILE DEPENDENCIES~##
# User specified:
#            - image files, the two images to correlate (small first)
#            - output image file, plotted figure showing matched 
#              location and both images
#
# Required:
#            N/A
##

##~PYTHON DEPENDENCIES~##
# re
# sys
# numpy
# struct
# scipy
# matplotlib (only if '-o' specified)
##


####################~INITIALIZE~####################
import re
import sys
import numpy as np
from struct import unpack
from scipy.ndimage import convolve
from scipy.fftpack import fftn, ifftn
from matplotlib import pyplot as plt

version = '1.6A.1'

## Read and parse command line arguments #
opt = sys.argv

option = []
images = []
output = []

out = False

for arg in opt:
    if arg.startswith('-'):
        option.append(arg)
    elif '.png' in arg:
        output.append(arg)
    elif '.pgm' in arg:
        images.append(arg)
    elif '.MAP' in arg:
        images.append(arg)

if any('v' in flag for flag in option):
    sys.exit('Version: '+version)

if any('h' in flag for flag in option):
    sys.exit(Header)

if not images:
    print('You forgot to specify the files to compare!')
    images = raw_input('Please enter the filenames now: \n').split()

im1 = images[0]
im2 = images[1]

for flag in option:
    if 'o' in flag:
        out = True
        if not output:
            efile = 'corrOut.png'
        else:
            efile = output[0]
##

print('mpXcorr.py version: '+version)
print('Image to search for: '+im1)
print('Image to search in: '+im2)

if not out:
    print('\n')
else:
    print('Output figure file: '+efile+'\n')

if any('.MAP' in file for file in images):
    dataType = 'map'
    print('\n** WARNING ** This will correlate the map albedo channel only! \n'+ \
          '------------- Expect reduced correlation values. \n')
else:
    dataType = 'pgm'


####################~CLASS~####################
class normX(object):


    def __init__(self,img):
        self.img = img


    def __call__(self,a):
        if a.ndim != self.img.ndim:
            raise Exception('Search area must have the same '\
                    'dimensions as the template')

        return norm_xcorr(self.img,a)


####################~MODULES~####################
## Normalized cross corelation module. This is the heart of the program. #
def norm_xcorr(t,a):
    if t.size < 1000:
        raise Exception('Image is too small (< 1000 pixels).')

    std_t = np.std(t)
    mean_t = np.mean(t)

    if std_t == 0:
        raise Exception('The image is blank.')

    t = np.float64(t)
    a = np.float64(a)

    outdim = np.array([a.shape[i]+t.shape[i]-1 for i in xrange(a.ndim)])

    # Check if convolution or FFT is faster #
    spattime, ffttime = get_time(t,a,outdim)
    if spattime < ffttime:
        method = 'spatial'
    else:
        method = 'fourier'

    if method == 'fourier':
        af = fftn(a,shape=outdim)   # Fast Fourier transform of search image
        tf = fftn(nflip(t),shape=outdim)   # Fast Fourier transform of search template

        xcorr = np.real(ifftn(tf*af))   # Inverse FFT of the convolution of search tempalte and search image

    else:
        xcorr = convolve(a,t,mode='constant',cval=0) # 2D convolution of search image and template (rarely used)

    ls_a = lsum(a,t.shape)   # Running sum of search image
    ls2_a = lsum(a**2,t.shape)   # Running sum of the square of search image

    xcorr = padArray(xcorr,ls_a.shape)

    ls_diff = ls2_a-(ls_a**2)/t.size
    ls_diff = np.where(ls_diff < 0,0,ls_diff) # Replace negatives by zero
    sigma_a = np.sqrt(ls_diff)

    sigma_t = np.sqrt(t.size-1.)*std_t

    den = sigma_t*sigma_a

    num = (xcorr - ls_a*mean_t)

    tol = np.sqrt(np.finfo(den.dtype).eps) # Define zero tolerance as sqrt of machine epsilon
    with np.errstate(divide='ignore'):
        nxcorr = np.where(den < tol,0,num/den) # Normalized correlation (make zero when below tolerance)

    ## This next line is recommended by both Lewis and MATLAB but seems to introduce a ~1 px error in each axis ##
    # nxcorr = np.where((np.abs(nxcorr)-1.) > np.sqrt(np.finfo(nxcorr.dtype).eps),0,nxcorr)

    nxcorr = padArray(nxcorr,a.shape)

    return nxcorr
##

## Running sum #
def lsum(a,tsh):
    a = pad(a,tsh)

    def shiftdiff(a,tsh,shiftdim):
        ind1 = [slice(None,None),]*a.ndim
        ind2 = [slice(None,None),]*a.ndim
        ind1[shiftdim] = slice(tsh[shiftdim],a.shape[shiftdim]-1)
        ind2[shiftdim] = slice(0,a.shape[shiftdim]-tsh[shiftdim]-1)
        return a[ind1] - a[ind2]

    for i in xrange(a.ndim):
        a = np.cumsum(a,i)
        a = shiftdiff(a,tsh,i)
    return a
##

## Check calculation time #
def get_time(t,a,outdim):
    k_conv = 1.21667E-09
    k_fft = 2.65125E-08

    convtime = k_conv*(t.size*a.size)

    ffttime = 3*k_fft*(np.prod(outdim)*np.log(np.prod(outdim)))

    return convtime,ffttime
##

## Add padding of zeros around image #
def pad(a,sh=None,padval=0):
    if sh == None:
        sh = np.ones(a.ndim)
    elif np.isscalar(sh):
        sh = (sh,)*a.ndim

    padsize = [a.shape[i]+2*sh[i] for i in xrange(a.ndim)]
    b = np.ones(padsize,a.dtype)*padval

    ind = [slice(np.floor(sh[i]),a.shape[i]+np.floor(sh[i])) for i in xrange(a.ndim)]

    b[ind] = a
    return b
##

## Pads or truncates array to specific size #
def padArray(a,target,padval=0):
    b = np.ones(target,a.dtype)*padval

    aind = [slice(None,None)]*a.ndim
    bind = [slice(None,None)]*a.ndim

    for i in xrange(a.ndim):
        if a.shape[i] > target[i]:
            diff = (a.shape[i]-target[i])/2.
            aind[i] = slice(np.floor(diff),a.shape[i]-np.ceil(diff))
        elif a.shape[i] < target[i]:
            diff = (target[i]-a.shape[i])/2.
            bind[i] = slice(np.floor(diff),target[i]-np.ceil(diff))
    
    b[bind] = a[aind]

    return b
##

## Flips N dimensional array #
def nflip(a):
    ind = (slice(None,None,-1),)*a.ndim
    return a[ind]
##

## Injest PGM images. This is NOT my code, adapted for this purpose. #
def readPGM(file):
    f = open(file, 'r')
    pixels = f.read()
    f.close()

    try:
        header, width, height, maxval = re.search(
            b"(^P5\s(?:\s*#.*[\r\n])*"
            b"(\d+)\s(?:\s*#.*[\r\n])*"
            b"(\d+)\s(?:\s*#.*[\r\n])*"
            b"(\d+)\s(?:\s*#.*[\r\n]\s)*)", pixels).groups()
    except AttributeError:
        raise ValueError("Not a raw PGM file!")
    return np.frombuffer(pixels,
                            dtype = 'u1' if int(maxval) < 256 else '< u2',
                            count = int(width)*int(height),
                            offset = len(header)
                            ).reshape((int(height), int(width)))
##

## Injest maplets #
def readMAP(file):
    g = open(file,'rb')
    text = g.read()
    g.close()

    mapHead = text[0:72]
    mapData = text[72::]

    # scale = unpack('>f', mapHead[6:10])[0]
    qsz = unpack('<H', mapHead[10:12])[0]
    # vlm = unpack('>fff', mapHead[15:27])
    # Ux = unpack('>fff', mapHead[27:39])
    # Uy = unpack('>fff', mapHead[39:51])
    # Uz = unpack('>fff', mapHead[51:63])
    # hscale = unpack('>f', mapHead[63:67])[0]

    # heights = []
    albedo = []
    for i in range(0,len(mapData),3):
        # heights.append(scale*hscale*unpack('>h', mapData[i:i+2])[0])
        albedo.append(0.01*unpack('>B', mapData[i+2])[0])

    # HT = [heights[i:i+2*qsz+1] for i in range(0,len(heights),2*qsz+1)]
    ALB = [albedo[i:i+2*qsz+1] for i in range(0,len(albedo),2*qsz+1)]

    if all(i == 0 for i in ALB[-1]):   # all(i == 0 and j == 0 for i,j in zip(HT[-1],ALB[-1])):
        # del HT[-1]
        del ALB[-1]

    MP = np.array(ALB[:])   # np.array([HT[:],ALB[:]])
    # MP = MP-MP.min()
    # MP = MP/MP.max()
    # MP = MP*(2**8).astype(int)

    return MP
##


####################~READ DATA~####################
if dataType == 'map':
    temp = readMAP(im1)
    reg = readMAP(im2)
elif dataType == 'pgm':
    temp = readPGM(im1)
    if not temp[:,0].any() and not temp[:,-1].any():
        temp = temp[:,1:-2]
    # temp = temp[100:301,100:301] # for debugging temp = reg
    reg = readPGM(im2)
    # reg = reg[:,1:-2]

## Check template size and resize if necessary #
if temp.size >= reg.size:
    print('ERROR: Image must be smaller than search area.')
    print('Template size: '+str(temp.shape))
    ans = raw_input('Would you like to sub-sample search template? (y/n) \n')

    while ans != 'y' and ans != 'n':
        ans = raw_input('Would you like to sub-sample search template? (y/n) \n')
    if ans == 'y':
        x1,x2,y1,y2 = raw_input('Enter px/ln box (min 50px x 50px) to use as x1 x2 y1 y2: \n').split()
        x1 = int(x1)
        x2 = int(x2)
        y1 = int(y1)
        y2 = int(y2)
        temp = temp[y1:y2+1,x1:x2+1]
    if ans == 'n':
        sys.exit('Choose a smaller image.')
##

## Initialize class, calculate corelation surface, & max corelation location #
A = normX(temp)
ncc = A(reg) 
nccloc = np.nonzero(ncc == ncc.max())

midx = int(float(ncc.shape[0])/2)
midy = int(float(ncc.shape[1])/2)

cncc = ncc[midx][midy]

x = int(nccloc[0])
y = int(nccloc[1])
##

## Calculatate distance of max corelation from center pixel #
expx = int(float(reg.shape[0])/2)
expy = int(float(reg.shape[1])/2)

dx = x-expx
dy = y-expy
##


####################~OUTPUT~####################
axes = '\n.----> +y \n| \n| \nv \n+x'

print('Found match in search area at px/ln: '+str(y)+' '+str(x))
print('Max correlation value: '+str(ncc.max()))
print('Center pixel correlation: '+str(cncc))
print('Template moved dx = '+str(dx)+' dy = '+str(dy)+ \
      ' pixels from center of search area. '+axes)

if out:
    fig = plt.figure()

    # Plot search image #
    ax1 = plt.subplot(2,2,1)
    ax1.imshow(reg,plt.cm.gray,interpolation='nearest')
    ax1.set_title('Search Image')

    # Plot search template #
    ax2 = plt.subplot(2,2,2)
    ax2.imshow(padArray(temp,reg.shape,0),plt.cm.gray,interpolation='nearest')
    # ax2.axis('off')
    ax2.set_title('Search Template')

    # Plot correlation surface #
    ax3 = plt.subplot(2,2,3)
    ax3.hold(True)
    im = ax3.imshow(ncc,vmin=0.2,vmax=1,interpolation='nearest')
    ax3.plot(y,x,'rs',ms=6,fillstyle='none')       # Box around correlation peak
    ax3.set_title('Normalized Cross-Correlation')
    plt.xlim(0,reg.shape[1])
    plt.ylim(reg.shape[0],0)

    cax = fig.add_axes([0.9, 0.1, 0.03, 0.8])
    fig.colorbar(im,cax=cax)

    plt.savefig(efile)

