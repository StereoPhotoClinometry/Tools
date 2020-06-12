'''
Author: Kristofer Drozd
Date: November 20, 2015


Description:
This python script performs calculations to obtain positional parameters (azi & zen) of the spacecraft and sun at the exact moment a picture is taken of the landmark being analyzed.

The following text files must be in the same directory in which the code is being run:
LMRKNAMES.txt: name of the landmark being analyzed
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

Output:
A text file of the name <landmark name>_viewing.txt is created in the directory the code is run
'''

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def file_len(fname):
    '''
    This function counts the number of lines in a text file
    
    Parameters
    fname: name of the text file
    
    Returns
    i + 1: number of lines in the text file
    '''
    with open(fname) as f:
        for i, l in enumerate(f):
            pass

    return i + 1

def SCPOS(SCOBJ1, SCOBJ2, SCOBJ3):
    '''
    This function creates the object's center to spacecraft vector in body fixed frame. Since the SCOBJ compoents are from the spacecraft to the object's center, the components are multiplied by -1.
    
    Parameters
    SCOBJ1: x component of SCOBJ
    SCOBJ2: y component of SCOBJ
    SCOBGJ: z component of SCOBJ
    
    Returns
    SCOBJ: vector
    '''
    SCPOS = np.array([-SCOBJ1, -SCOBJ2, -SCOBJ3])

    return SCPOS

def SUNPOS(SZ1, SZ2, SZ3):
    '''
    This function creates the object center to sun vector in body fixed frame. Since SZ is a unit vector it is multuplied by 1 AU.
        
    Parameters
    SZ1: x component of SZ
    SZ2: y component of SZ
    SZ3: z component of SZ
        
    Returns
    SCOBJ: vector
    '''
    SZ_au = np.multiply(np.array([ SZ1, SZ2, SZ3]), 1.496e8)
    
    return SZ_au

def BEN2LMRK(VLM1, VLM2, VLM3):
    '''
    This function creates the object center to landmark vector in body fixed frame.
    
    Parameters
    VLM1: x component of BEN2LMRK
    VLM2: y component of BEN2LMRK
    VLM3: z component of BEN2LMRK
    
    Returns
    yomama: vector
    '''
    yomama = np.array([VLM1, VLM2, VLM3], float)

    return yomama
    
def BF2SEZ_tm(lon,lat):
    '''
    This function creates the Body Fixed frame to SEZ fram transformation matrix.
    
    Parameters
    lon: The east longitude of the landamrk (degrees)
    lat: The latitude of the landamrk (degreesP)
    
    Returns
    Qxx_mat: The transformation matrix
    '''
    lat_r = np.radians(lat)
    lon_r = np.radians(lon)
    Qxx_mat = np.array([[ np.sin(lat_r)*np.cos(lon_r), np.sin(lat_r)*np.sin(lon_r), -np.cos(lat_r)], [-np.sin(lon_r), np.cos(lon_r), 0], [np.cos(lat_r)*np.cos(lon_r), np.cos(lat_r)*np.sin(lon_r),np.sin(lat_r)]])

    return Qxx_mat



#==========================================================
def main():
    '''
    The various input files are read in, so that their data can be used to calculate the azimuth and zenith angles of the spacecraft and sun with respect to a topcentric NEZ frame centered on the landmark during the exact moment a picture is taken of said landmark.
    A text file is then created listing the angles, picture resolution, and picture UTC time.
    '''
    
    '''
    Reading in TXT Files
    '''

    fid1 = open('LAT.txt')
    fid2 = open('LON.txt')
    fid3 = open('NUMBERPIC.txt')
    fid4 = open('PICTIMES.txt')
    fid5 = open('LMRKNAMES.txt')
    fid6 = open('RESOLUTION.txt')
    fid7 = open('SCOBJ1.txt')
    fid8 = open('SCOBJ2.txt')
    fid9 = open('SCOBJ3.txt')
    fid10 = open('SZ1.txt')
    fid11 = open('SZ2.txt')
    fid12 = open('SZ3.txt')
    fid13 = open('VLM1.txt')
    fid14 = open('VLM2.txt')
    fid15 = open('VLM3.txt')
    
    '''
    Getting latitude and longitude of landmark
    '''
    
    lat = float(fid1.readline().rstrip())
    
    lon = 360 - float(fid2.readline().rstrip())
    
    '''
    Getting object center to landmark vector components and then vector
    '''
    
    VLM1 = fid13.readline().rstrip()
    
    VLM1 = float(VLM1.replace('D', 'E'))
    
    VLM2 = fid14.readline().rstrip()
    
    VLM2 = float(VLM2.replace('D', 'E'))
    
    VLM3 = fid15.readline().rstrip()

    VLM3 = float(VLM3.replace('D', 'E'))
    
    lmrk_vec = BEN2LMRK(VLM1, VLM2, VLM3)
    
    '''
    Getting number of pictures and landmark name
    '''
    
    number_pics = int(fid3.readline().rstrip())
    
    lmrk_name = fid5.readline().rstrip()
    
    '''
    Formting outputs & creating text file
    '''
    
    file = open(lmrk_name+"_viewing.txt", "w")
    file.write( "\n")
    file.write( lmrk_name)
    file.write( "\n")
    file.write( "lat = %f,   Elon = %f\n" % (lat, lon))
    file.write( "# of pictures taken = %f\n" % (number_pics))
    file.write("\n")
    file.write( "|             UTC            |    res    |  sun_zen   |  sun_azi   |  sc_zen    |   sc_azi   |\n")
    file.write( "|--------------------------------------------------------------------------------------------|\n")
    
    '''
    for loop
    '''
    
    for j in range(0, number_pics):
       
        '''
        Getting the SCOBJ vector components one line at a time
        '''
        
        SCOBJ1 = fid7.readline().rstrip()
        
        SCOBJ1 = float(SCOBJ1.replace('D', 'E'))
        
        SCOBJ2 = fid8.readline().rstrip()
        
        SCOBJ2 = float(SCOBJ2.replace('D', 'E'))
        
        SCOBJ3 = fid9.readline().rstrip()
        
        SCOBJ3 = float(SCOBJ3.replace('D', 'E'))
        
        '''
        Getting the SZ vector components one line at a time
        '''
        
        SZ1 = fid10.readline().rstrip()
        
        SZ1 = float(SZ1.replace('D', 'E'))
        
        SZ2 = fid11.readline().rstrip()
        
        SZ2 = float(SZ2.replace('D', 'E'))
        
        SZ3 = fid12.readline().rstrip()
        
        SZ3 = float(SZ3.replace('D', 'E'))
        
        '''
        Getting picture resolution one line at a time
        '''
        
        res = float(fid6.readline().rstrip())
        
        '''
        Getting UTC time of each picture one line at a time
        '''
        
        time = fid4.readline().rstrip()
       
        '''
        SC Calculations
        
        lmrk2sc_vec: landmark to sc vector in body fixed frame
        
        n_sc: landmark to sc vector in topographical SEZ frame
        
        elvation_sc: elevation angle of n_sc
        
        zenith_sc: zenith angle of n_sc
        
        azimuth_sc: azimuth angle of n_sc, but manipulated so it is in NEZ frame opposed to SEZ
        '''
    
        lmrk2sc_vec = np.subtract(SCPOS(SCOBJ1, SCOBJ2, SCOBJ3),lmrk_vec)
    
        n_sc = np.dot(BF2SEZ_tm(lon,lat),lmrk2sc_vec)
    
        elevation_sc = np.degrees(np.arcsin(np.true_divide(n_sc[2],np.linalg.norm(n_sc))))
    
        zenith_sc = 90-elevation_sc
    
        azimuth_sc = np.degrees(np.arctan2(n_sc[1],-n_sc[0]))

        if azimuth_sc < 0:
            azimuth_sc = 360+azimuth_sc

        else:
            azimuth_sc = azimuth_sc

        '''
        Sun Calculations
        
        lmrk2sun_vec: landmark to sun vector in body fixed frame
        
        n_sun: landmark to sun vector in topographical SEZ frame
        
        elvation_sun: elevation angle of n_sun
        
        zenith_sun: zenith angle of n_sun
        
        azimuth_sun: azimuth angle of n_sun, but manipulated so it is in NEZ frame opposed to SEZ
        '''
    
        lmrk2sun_vec = np.subtract(SUNPOS(SZ1, SZ2, SZ3),lmrk_vec)
    
        n_sun = np.dot(BF2SEZ_tm(lon,lat),lmrk2sun_vec)
    
        elevation_sun = np.degrees(np.arcsin(np.true_divide(n_sun[2],np.linalg.norm(n_sun))))
    
        zenith_sun = 90-elevation_sun
    
        azimuth_sun = np.degrees(np.arctan2(n_sun[1],-n_sun[0]))

        if azimuth_sun < 0:
            azimuth_sun = 360+azimuth_sun

        else:
            azimuth_sun = azimuth_sun
        
        '''
        Continued formatting of text file
        '''
        
        file.write("|  ")
        file.write(time)
        file.write("  ")
        file.write( "|  %07.3f  |  %+08.3f  |  %08.3f  |  %+08.3f  |  %08.3f  \n" % (res, zenith_sun, azimuth_sun, zenith_sc, azimuth_sc))

    file.close()




    with open(lmrk_name+"_viewing.txt") as ifh:
        arr = np.loadtxt(ifh, usecols = (1,2,3,4,5), dtype = float, delimiter = " | ", skiprows = 7)

    theta = np.linspace(-np.pi, np.pi, 100)
    azi_sun_1 = arr[:,2]
    zen_sun_1 = arr[:,1]
    azi_sc_1 = arr[:,4]
    zen_sc_1 = arr[:,3]
    res = arr[:,0]

    '''
    Sun plot
    '''

    plt.figure(1)

    ax1 = plt.subplot(111, polar = True)

    ax1.set_theta_zero_location("N")

    ax1.set_theta_direction(-1)

    plt.grid(True)

    ax1.set_rgrids([15,30,45,60,75,90], angle = 60, fontsize = 10)
    
    ax1.set_rlim(0, 90)

    ax1.set_thetagrids([0, 45, 90, 135, 180, 225, 270, 315], frac = 1.08, fontsize = 10)

    for k in range(0, number_pics):
        if res[k] >=1:
            ax1.plot(np.radians(azi_sun_1[k]), zen_sun_1[k], 'or')
        elif 1 > res[k] and res[k] >= .5:
            ax1.plot(np.radians(azi_sun_1[k]), zen_sun_1[k], 'og')
        elif .5 > res[k] and res[k] >= .25:
            ax1.plot(np.radians(azi_sun_1[k]), zen_sun_1[k], 'ob')
        elif .25 > res[k] and res[k] >= .1:
            ax1.plot(np.radians(azi_sun_1[k]), zen_sun_1[k], 'oy')
        elif .1 > res[k] and res[k] >= .05:
            ax1.plot(np.radians(azi_sun_1[k]), zen_sun_1[k], 'om')
        else:
            ax1.plot(np.radians(azi_sun_1[k]), zen_sun_1[k], 'oc')

    mot1 = mpatches.Patch( color = 'r', label = 'Res $\geq$ 50 cm')
    
    mot2 = mpatches.Patch( color = 'g', label = '100 cm > Res $\geq$ 50 cm')
    
    mot3 = mpatches.Patch( color = 'b', label = '50 cm > Res $\geq$ 25 cm')
    
    mot4 = mpatches.Patch( color = 'y', label = '25 cm > Res $\geq$ 10 cm')
    
    mot5 = mpatches.Patch( color = 'm', label = '10 cm > Res $\geq$ 5 cm')
    
    mot6 = mpatches.Patch( color = 'c', label = 'Res < 5 cm')
    
    plt.legend( handles = [mot1, mot2, mot3, mot4, mot5, mot6], fontsize = 8, loc = 2, bbox_to_anchor = (.93, 1.1))

    figure_title1 = lmrk_name+' Sun Azimuth vs. Zenith'

    plt.text(.5, 1.08,figure_title1,
            horizontalalignment = 'center',
             fontsize = 15,
             transform = ax1.transAxes)

    plt.savefig( lmrk_name+'_sun_plot.png')

    plt.clf()

    '''
    SC plot
    '''

    plt.figure(2)

    ax2 = plt.subplot(111, polar = True)

    ax2.set_theta_zero_location("N")
    
    ax2.set_theta_direction(-1)

    plt.grid(True)
    
    ax2.set_rgrids([15,30,45,60,75,90], angle = 60, fontsize = 10)
    
    ax2.set_rlim(0, 90)
    
    ax2.set_thetagrids([0, 45, 90, 135, 180, 225, 270, 315], frac = 1.08, fontsize = 10)

    for k in range(0, number_pics):
        if res[k] >=1:
            ax2.plot(np.radians(azi_sc_1[k]), zen_sc_1[k], 'or')
        elif 1 > res[k] and res[k] >= .5:
            ax2.plot(np.radians(azi_sc_1[k]), zen_sc_1[k], 'og')
        elif .5 > res[k] and res[k] >= .25:
            ax2.plot(np.radians(azi_sc_1[k]), zen_sc_1[k], 'ob')
        elif .25 > res[k] and res[k] >= .1:
            ax2.plot(np.radians(azi_sc_1[k]), zen_sc_1[k], 'oy')
        elif .1 > res[k] and res[k] >= .05:
            ax2.plot(np.radians(azi_sc_1[k]), zen_sc_1[k], 'om')
        else:
            ax2.plot(np.radians(azi_sc_1[k]), zen_sc_1[k], 'oc')

    dot1 = mpatches.Patch( color = 'r', label = 'Res $\geq$ 50 cm')

    dot2 = mpatches.Patch( color = 'g', label = '100 cm > Res $\geq$ 50 cm')

    dot3 = mpatches.Patch( color = 'b', label = '50 cm > Res $\geq$ 25 cm')

    dot4 = mpatches.Patch( color = 'y', label = '25 cm > Res $\geq$ 10 cm')

    dot5 = mpatches.Patch( color = 'm', label = '10 cm > Res $\geq$ 5 cm')

    dot6 = mpatches.Patch( color = 'c', label = 'Res < 5 cm')

    plt.legend( handles = [dot1, dot2, dot3, dot4, dot5, dot6], fontsize = 8, loc = 2, bbox_to_anchor = (.93, 1.1))

    figure_title2 = lmrk_name+' SC Azimuth vs. Zenith'
    
    plt.text(.5, 1.08,figure_title2,
            horizontalalignment = 'center',
            fontsize = 15,
            transform = ax2.transAxes)

    plt.savefig(lmrk_name+'_sc_plot.png')

    plt.clf()

    #print(n_sc)
    #print(lmrk2sc_vec)
    #print(elevation_sc)
    #print(elevation_sun)
    #print(BF2SEZ_tm(lon,lat))

if __name__ == '__main__':
    main()
