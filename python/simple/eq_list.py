#!/usr/bin/env python

# Finds if it's possible to split list into two equal part (sum of all values)
# MZvk 2018

import os

t1 = [11, 7, 18, 2, 1, 1, 5, 20, 15]
t2 = [1, 32, 2, 32, 2, 3, 2, 54, 23]
t3 = [3, 1, 1, 1, 2, 1, 4, 5, 8]
t4 = [100, 10, 20, 30, 40]

def fint(ilist):
  fs, bs = sum(ilist), 0
  if(fs % 2): return -1
  for idx, num in enumerate(ilist):
    fs -= num
    bs += num
    if(fs == bs): return idx

def lpp(list, idx):
  output = []
  for id, value in enumerate(list):
    color = '31' if id > idx else '33'
    output.append("\033[{}m{}\033[0m".format(color, value))
  output = ', '.join(output)
  print "[{}]".format(output)

def main():
  fl = int(os.popen('tput cols').read())
  for list in [t1, t2, t3, t4]:
    print list
    idx = fint(list)
    if idx < 0:
      print "- Cannot split into two equal parts -"
    else:
      lpp(list, idx)
    print '-' * fl

if __name__ == '__main__':
  main()

