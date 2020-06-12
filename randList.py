# Eric E. Palmer - 22 Apr 2019
# Reads a list of strings and outputs a random list
from random import sample
from random import shuffle

F = open ("t2", "r")

myList = []
for line in F:
  myList.append(line)
shuffle(myList)
#print(myList)

with open ('reordered.txt', 'w') as f:
  for item in myList:
    f.write ("%s" % item)

