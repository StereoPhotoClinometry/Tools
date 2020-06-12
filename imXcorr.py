Header='''
# USAGE: python imXcorr.py [-option] outfile image1 image2
#
#     -o   Use this followed by 'outfile' to
#          specify a unique output destination
#          for the correlation plot.
#          Default is corrOut.png if 'outfile'
#          is not specified.
#
#     -s   Use this followed by 'outfile' to
#          specify a unique PGM output 
#          destination for the shifted template
#          image. Default is modelShift.pgm if
#          'outfile' is not specified.
#
#     -c   Use this followed by x1 x2 y1 y2 to
#          specify a box to crop out of the 
#          template image. The coordinate system
#          follows the SPC maplet convention:
#          .--> +y
#          |
#          v
#          +x
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
# 1.5B - imXcorr.py
#      - support only imager_mg images for flight (pgm)
#      - rescaled tempalte in output image
# 1.5B.1 - fixed remEdge tilt bug
# 1.5B.2 - increased area from remEdge
#        - suppressed erroneous divide by zero warning
# 1.5B.3 - more graceful error handling for blank images
#        - fixed possible edge of image bugs in remEdge
#        - changed axis definitions to match SPC map coordinate frame
# 1.5B.3.1 - added print out to give center pixel correlation value
# 1.5B.4 - added 's' option to save the shifted template image
#        - changed header wording to make output opions less ambiguous
#        - added 'os'/'so' option to save both the plots and shifted image
# 1.6B - improved input argument parsing (much faster and more gracefull)
#      - fixed potential bug for very small images
# 1.6B.1 - fixed empty image list version/header print bug
# 1.7B - added support for PNG input images (experimental)
#      - lighter weight initialization (moved imports to modules if possible)
#      - fixed potential bug in remEdge for full images
#      - fixed numpy integer deprication warning
# 1.7B.1 - fixed remEdge for images with no-data pixels
# 1.7B.2 - added warning for correlations on the edge of an image
#        - added support for user supplied cropping box
# 1.7B.3 - increased border gate for warning to 100 pixels
#        - actually fixed cropping routine this time (I promise)
# 1.7B.4 - I didn't.
# 1.7C.0 -Eric added printing of the inset image coordinates
##

##~FILE DEPENDENCIES~##
# User specified:
#            - image files, the two images to correlate (model first)
#            - output image file, plotted figure showing matched 
#              location and both images
#
# Required:
#            N/A
##

##~PYTHON DEPENDENCIES~##
# re (only if PGM input images)
# sys
# PIL (only if PNG input images)
# numpy
# struct
# scipy
# matplotlib (only if '-o' specified)
##


####################~INITIALIZE~####################
import sys
import numpy as np
from struct import unpack
from scipy.ndimage import convolve
from scipy.fftpack import fftn, ifftn

version = '1.7C.0'

## Read and parse command line arguments #
opt = sys.argv

option = []
images = []
output = []
soutput = []
cropn = []

out = False
sout = False
cropf = False

for arg in opt:
    if arg.startswith('-'):
        option.append(arg)
    elif '.png' in arg:
        output.append(arg)
    elif '.pgm' in arg:
        images.append(arg)
    elif arg.isdigit():
        cropn.append(arg)

if any('v' in flag for flag in option):
    sys.exit('Version: '+version)

if any('h' in flag for flag in option):
    sys.exit(Header)

if len(output) == 3:
    images = images + output[1:]

if output and not any('o' in flag for flag in option):
    images = images + output

if not images:
    print('You forgot to specify the image files to compare!')
    images = raw_input('Please enter the filenames now: \n').split()

if len(images) == 3:
    soutput.append(images[0])
    images = images[1:]

im1 = images[0]
im2 = images[1]

for flag in option:
    if 'o' in flag:
        out = True
        if not output:
            efile = 'corrOut.png'
        else:
            efile = output[0]

    if 's' in flag:
        sout = True
        if not soutput:
            efile2 = 'modelShift.pgm'
        else:
            efile2 = soutput[0]

    if 'c' in flag:
        cropf = True
        if not cropn:
            cropn = raw_input('Enter px (y) / ln (x) box (min 50px x 50px) to use as x1 x2 y1 y2: \n').split()
 
        cx1 = int(cropn[0])
        cx2 = int(cropn[1])
        cy1 = int(cropn[2])
        cy2 = int(cropn[3])
##

print('imXcorr.py version: '+version)
print('Image to search for: '+im1)
print('Image to search in: '+im2)

if not any([out, sout]):
    print('\n')

if out:
    print('Output figure file: '+efile)
if sout:
    print('Output shifted image file: '+efile2)

if out or sout:
    print('\n')


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

    ind = [slice(int(sh[i]),a.shape[i]+int(sh[i])) for i in xrange(a.ndim)]

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
            aind[i] = slice(int(diff),a.shape[i]-int(np.ceil(diff)))
        elif a.shape[i] < target[i]:
            diff = (target[i]-a.shape[i])/2.
            bind[i] = slice(int(diff),target[i]-int(np.ceil(diff)))
    
    b[bind] = a[aind]

    return b
##

## Flips N dimensional array #
def nflip(a):
    ind = (slice(None,None,-1),)*a.ndim
    return a[ind]
##

## Injest PNG images #
def readPNG(file):
    from PIL import Image

    im = Image.open(file)
    pic = np.array(im.getdata()).reshape(im.size)
    im.close()

    return pic
##

## Injest PGM images. This is NOT my code, adapted for this purpose. #
def readPGM(file):
    import re

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

## Write out PGM images. #
def writePGM(data,file):
    head = 'P5'+'\n'+str(data.shape[1])+' '+str(data.shape[0])+' '+str(255)+'\n'
    data = data.ravel()

    g = open(file, 'wb')
    g.write(head)
    data.tofile(g)
    g.close()
##

## Remove boarder #
def remEdge(image):
    image = np.where(image == 2, 0, image)

    nonZ = []
    for i in range(len(image)):
        if image[i].any():
            nonZ.append([i,np.nonzero(image[i])[0][0],np.nonzero(image[i])[0][-1]])

    if len(nonZ) <= 4:
        raise Exception('The image is either blank or too small.')

    ledge = min(nonZ, key=lambda x: x[1])
    redge = max(nonZ, key=lambda x: x[2])
    bedge = nonZ[-1]
    tedge = nonZ[0]
    print "Original", tedge[0], bedge[0], ledge[1], redge[2]
    #print ledge, redge, bedge, tedge

    subImage = image[tedge[0]:bedge[0]+1,ledge[1]:redge[2]+1]
    #print tedge[0], bedge[0]+1, ledge[1], redge[2]+1
    box = subImage[:]

    cnt = 0
    while not np.concatenate((subImage[:,0],subImage[:,-1],subImage[0,:],subImage[-1,:])).all():
        subImage = subImage[1:-1,1:-1]
        cnt += 1
    print "top bottom left right"
    tmpCnt = cnt+5;
    print "Inset ",tmpCnt, ": ", tedge[0]+tmpCnt, bedge[0]-tmpCnt, ledge[1]+tmpCnt, redge[2]-tmpCnt


    if cnt > 0:
        idim = subImage.shape

        corner = [box[cnt-1][cnt-1],box[cnt-1][idim[1]+cnt],box[idim[0]+cnt][cnt-1],box[idim[0]+cnt][idim[1]+cnt]]
        outside = np.nonzero(np.array(corner) == 0)[0]

        if len(outside) == 1:
            cnt2 = 1
            if not corner[0]:
                a = idim[0]+cnt
                b = idim[1]+cnt
                newCorner = [box[cnt][cnt],box[cnt][b],box[a][cnt],box[a][b]]

                while all(newCorner):
                    if a+cnt2 < box.shape[0] and b+cnt2 < box.shape[1]:
                        newCorner[1:] = [box[cnt][b+cnt2],box[a+cnt2][cnt],box[a+cnt2][b+cnt2]]
                        cnt2 += 1
                    else:
                        break

                subImage = box[cnt:a+cnt2-2,cnt:b+cnt2-2]

            elif not corner[1]:
                a = idim[0]+cnt
                b = cnt-1
                newCorner = [box[cnt][b],box[cnt][idim[1]+b],box[a][b],box[a][idim[1]+b]]

                while all(newCorner):
                    if a+cnt2 < box.shape[0] and b-cnt2 >= 0:
                        newCorner = [box[cnt][b-cnt2],box[cnt][idim[1]+b],box[a+cnt2][b-cnt2],box[a+cnt2][idim[1]+b]]
                        cnt2 += 1
                    else:
                        break

                subImage = box[cnt:a+cnt2-2,b-(cnt2-2):idim[1]+cnt-1]

            elif not corner[2]:
                a = cnt-1
                b = idim[1]+cnt
                newCorner = [box[a][cnt],box[a][b],box[idim[0]+a][cnt],box[idim[0]+a][b]]

                while all(newCorner):
                    if a-cnt2 >= 0 and b+cnt2 < box.shape[1]:
                        newCorner = [box[a-cnt2][cnt],box[a-cnt2][b+cnt2],box[idim[0]+a][cnt],box[idim[0]+a][b+cnt2]]
                        cnt2 += 1
                    else:
                        break

                subImage = box[a-(cnt2-2):idim[0]+cnt-1,cnt:b+cnt2-2]

            elif not corner[3]:
                a = cnt-1
                b = cnt-1
                newCorner = [box[a][b],box[a][idim[1]+b],box[idim[0]+a][b],box[idim[0]+a][idim[1]+b]]

                while all(newCorner):
                    if a-cnt2 >= 0 and b-cnt2 >= 0:
                        newCorner[:-1] = [box[a-cnt2][b-cnt2],box[a-cnt2][idim[1]+b],box[idim[0]+a][b-cnt2]]
                        cnt2 += 1
                    else:
                        break

                subImage = box[a-(cnt2-2):idim[0]+cnt-1,b-(cnt2-2):idim[1]+cnt-1]

    return subImage    # np.where(subImage == 0, 2, subImage)
##

## Shift template to matched location. #
def shiftIM(image,size,dx,dy):
    shiftImage = padArray(temp,size,0)
    
    xpad = np.zeros((np.abs(dx),size[1]),dtype='uint8')
    ypad = np.zeros((size[0],np.abs(dy)),dtype='uint8')

    if dx > 0:
        shiftImage = np.vstack((xpad,shiftImage))
        
        d = shiftImage.shape[0]-np.arange(dx)-1

        shiftImage = np.delete(shiftImage,d,0)
    elif dx < 0:
        shiftImage = np.vstack((shiftImage,xpad))
        
        d = np.arange(np.abs(dx))

        shiftImage = np.delete(shiftImage,d,0)

    if dy > 0:
        shiftImage = np.hstack((ypad,shiftImage))

        d = shiftImage.shape[1]-np.arange(dy)-1

        shiftImage = np.delete(shiftImage,d,1)
    elif dy < 0:
        shiftImage = np.hstack((shiftImage,ypad))

        d = np.arange(np.abs(dy))

        shiftImage = np.delete(shiftImage,d,1)

    return shiftImage
##


####################~READ DATA~####################
if 'pgm' in im1:
    temp = readPGM(im1)
    reg = readPGM(im2)
elif 'png' in im1:
    temp = readPNG(im1)
    reg = readPNG(im2)    

if cropf:
    temp = temp[cx1:cx2,cy1:cy2]
else:
    temp = remEdge(temp)
    # temp = temp[100:300,100:300] # for debugging temp = reg
    # reg = remEdge(reg)

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
        temp = temp[x1:x2,y1:y2]
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

bCheck = [i <= 100 for i in [x, ncc.shape[0]-x, y, ncc.shape[1]-y]]
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

if any(bCheck):
    print('\n**WARNING** The peak correlation appears to be within 100 pixels '+ \
          'of the border! \nRun again using the \'-o\' flag to check the output.\n')

if out:
    from matplotlib import pyplot as plt

    fig = plt.figure()

    # Plot search image #
    ax1 = plt.subplot(2,2,1)
    ax1.imshow(reg,plt.cm.gray,interpolation='nearest')
    ax1.set_title('Search Image')

    # Plot search template #
    ax2 = plt.subplot(2,2,2)
    ax2.imshow(padArray(temp,reg.shape,255),plt.cm.gray,interpolation='nearest')
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

if sout:
    shiftTemp = shiftIM(temp,reg.shape,dx,dy)
    writePGM(shiftTemp,efile2)
