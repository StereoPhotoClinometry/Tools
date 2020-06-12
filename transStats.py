Header='''
# USAGE: python transStats.py [-option] infile
#
#     -h   Use this to print usage directions
#          to StdOut. (Prints this header)
#
#     -v   Use this to only output current
#          version number and exit. By default
#          the version will be sent to StdOut
#          at the begining of each use.
#
###################################################
'''


##~AUTHOR INFO~##
# By Tanner Campbell
# In support of the OSIRIS-REx mission 2016
##

##~VERSION NOTES~##
# 1.0 - first release
# 1.1 - eliminated outliers from stats
#     - classification done by vector instead of magnitude
#     - fixed indexing bug
#     - added correlation histogram
#     - added percentage printout
# 1.1.1 - added average dx and dy printout
# 1.2 - CM ready version
#     - fixed read data as 'all'
#     - added required python package list
#     - added author info
##

##~-FILE DEPENDENCIES~##
# User Specified:
#            - input file, should be the output from batchCorr.sh
#
# Required:
#            N/A
##

##~PYTHON DEPENDENCIES~##
# sys
# numpy
##


########################~INITIALIZE~########################
import sys
import numpy as np

version = '1.2'

opt = sys.argv

if len(opt) == 1:
    file = raw_input('Input filename: \n')
elif len(opt) == 2 and opt[1][0] != '-':
    file = opt[1]
elif opt[1][0] == '-':
    if opt[1][1] == 'h':
        sys.exit(Header)
    if opt[1][1] == 'v':
        sys.exit('Version: '+version)
else:
    sys.exit('Try again :(')

print('\ntransStats.py version: '+version)
print('Input file: '+file+'\n')


########################~READ DATA~########################
f = open(file,'r')
text = f.read()
f.close()

text = text.split()

lm = text[0::6]
# x = [float(i) for i in text[1::6]]
# y = [float(i) for i in text[2::6]]
dx = [float(i) for i in text[3::6]]
dy = [float(i) for i in text[4::6]]
cor = [float(i) for i in text[5::6]]


########################~MATH~########################
avgX = np.mean(dx)
avgY = np.mean(dy)

fmag = [np.sqrt((i-avgX)**2+(j-avgY)**2) for i,j in zip(dx,dy)]

fail = []
nlm = []
ndx = []
ndy = []
ncor = []

for i in range(len(fmag)):
    if fmag[i] >= 100:
        fail.append(lm[i])
    else:
        nlm.append(lm[i])
        ndx.append(dx[i])
        ndy.append(dy[i])
        ncor.append(cor[i])

navgX = np.mean(ndx)
navgY = np.mean(ndy)

dmag = [np.sqrt(i**2+j**2) for i,j in zip (ndx,ndy)]
mmag = [np.sqrt((i-navgX)**2+(j-navgY)**2) for i,j in zip(ndx,ndy)]

median = np.median(dmag)
mean = np.mean(dmag)
stdv = np.std(dmag)
max = np.max(dmag)
min = np.min(dmag)

bound = 5

pss = []
marg = []

for i in range(len(mmag)):
    if mmag[i] > bound:
        marg.append(nlm[i])
    else:
        pss.append(nlm[i])

ppss = (float(len(pss))/len(lm))*100
ppss = "{0:.2f}".format(ppss)

pmarg = (float(len(marg))/len(lm))*100
pmarg = "{0:.2f}".format(pmarg)

pfail = (float(len(fail))/len(lm))*100
pfail = "{0:.2f}".format(pfail)

bin = [[],[],[],[],[],[]]

for i in range(len(ncor)):
    if ncor[i] <= 0.5:
        bin[0].append(nlm[i])
    elif ncor[i] > 0.5 and ncor[i] <= 0.6:
        bin[1].append(nlm[i])
    elif ncor[i] > 0.6 and ncor[i] <= 0.7:
        bin[2].append(nlm[i])
    elif ncor[i] > 0.7 and ncor[i] <= 0.8:
        bin[3].append(nlm[i])
    elif ncor[i] > 0.8 and ncor[i] <= 0.9:
        bin[4].append(nlm[i])
    elif ncor[i] > 0.9:
        bin[5].append(nlm[i])

lbin = []
for i in range(len(bin)):
    lbin.append(str(len(bin[i])))


####################~OUTPUT~####################
print('Maximum: '+str(max))
print('Minimum: '+str(min))
print('Median: '+str(median))
print('Average: '+str(mean)+' dx: '+str(navgX)+' dy: '+str(navgY))
print('Standard Deviation: '+str(stdv))
print('Marginal Bound from Average: +/- '+str(bound)+'\n')

print('Pass: '+ppss+'%  Marginal: '+pmarg+'%  Fail: '+pfail+'%\n')
print('Correlation < 0.5: '+lbin[0]+'\n\t    0.5-0.6: '+lbin[1]+'\n\t    0.6-0.7: '\
      +lbin[2]+'\n\t    0.7-0.8: '+lbin[3]+'\n\t    0.8-0.9: '+lbin[4]+'\n\t    > 0.9: '+lbin[5]+'\n')

print('\nPass:\n')

for i in range(len(pss)):
    print('\t'+pss[i])

print('\nMarginal:\n')

for i in range(len(marg)):
    print('\t'+marg[i])

print('\nFail:\n')

for i in range(len(fail)):
    print('\t'+fail[i])
