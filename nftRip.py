# Eric E. Palmer - 23 Sep 2019
# Read in a file and parse it for generating input files for NFT
import sys, os

####################################
# This dumps the bigmap and other
####################################

# version 0.9.1
def printme( stub, pict, sample, line, gsd, q):
  "This prints a passed string into this function"

  print stub, gsd, q
  out = open ("nftConfig/" + "nftBigmap-" + stub + ".IN", "w")

  try:
    out.write ("p\n")
    out.write (pict + "\n")
    out.write ("   " + sample + " " +line + "\n")
    out.write ("   " + gsd + " " + q  + "   1.23400  1000 "+ "\n")

    newStr = stub.replace("-", "")
    out.write (newStr + "\n")
  
    out.write ("1\n")
    out.write ("0.005\n")
    out.write ("0.025\n")
    out.write ("1\n")
    out.write ("1\n")
    out.write ("1\n")
    out.write ("1\n")
    out.write ("1\n")
    out.write ("1\n")
    out.write ("1\n")
    out.write ("0\n")
    out.write ("0\n")
  finally:
    out.close()

  if stub[6] == 'A':
    return

  # Output the make_scriptT.seed file
  name = "nftSeed-" + stub + ".seed"
  out = open ("nftConfig/" + name, "w")


  try:
    out.write (gsd + ", 49\n")
    second = open ("/opt/local/spc/bin/base.seed", "r")
    try:
      out.write (second.read())
    finally:
      second.close()
    
  finally:
    out.close()

  return





####################################
# Start
####################################

len=len(sys.argv)
if len != 2:
  print "Error:  Usage nftRip.py <filename>"
  sys.exit ("Wrong number of inputs");

filename=sys.argv[1]
#os.mkdir ("nftConfig", 0775)


####################################
# Open the input file
####################################
inF = open (filename, "r")
 
line = inF.readline();

####################################
# For each line, do the output
####################################
for line in inF: 
  print "\n##" + line 
  words = line.split()
  #words = line.split()

  ####################################
  # Break out each string to an important variable
  ####################################
  theID = words [0]
  #print "theID: " + theID
  pict = words [2]
  #print "pict: " + pict
  sample = words [3]
  #print "sample: " + sample
  line = words [4]
  #print "line: " + line
  rawGSD = words [5]
  #print "rawGSD: " + rawGSD
  floatGSD = float (rawGSD)
  q = words [6]
  print "rawGSD:  " + rawGSD + "floatGSD:  " 
  print  floatGSD

  half = floatGSD/2
  print "half"
  print half



  ####################################
  # Create the base, low and/or medium outputs
  ####################################
  if ( half <= 6):
    stub = theID + "-6"
    printme(stub, pict, sample, line, "0.0000600", "150")

  if ( half <= 2.4):
    stub = theID + "-2"
    printme(stub, pict, sample, line, "0.0000240", "150")

  if ( half <= 1.0):
    stub = theID + "-1" 
    printme(stub, pict, sample, line, "0.0000100", "150")

  ####################################
  # set up the 1/2 GSD 
  ####################################
#  gsdHalf = "-%1.0f" % (floatGSD/2)

  gsd=floatGSD/1000/100/2
  gsdT = "%5.7f" % gsd
  if (floatGSD < .5):
    gsdT = "0.0000050"
#  if (floatGSD < 2):
  gsdHalf="-0"

  stub = theID + gsdHalf 
  printme(stub, pict, sample, line, gsdT, "150")

  stub = theID + "-A" 
  floatGSD = float (rawGSD)
  gsd=floatGSD/1000.0/100.0
  gsdT = "%5.9f" % gsd
  printme(stub, pict, sample, line, gsdT, q)

