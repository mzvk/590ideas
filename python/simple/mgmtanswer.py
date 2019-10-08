#!/usr/bin/env python

# Simple script to generate answers which can be send to company/team management
# Python version of Foggy
# data file take from: https://hewgill.com/com/ConsultOMatic.txt
# MZvk 2019

import random

def load(file):
   with open(file) as x: output = x.read()
   return output.split('\n')

colidx = 0
cols = [[]]

for line in load('.madata.bin'):
   if not line:
      colidx += 1
      cols.append([])
   else:
      cols[colidx].append(line)

sent = ""
for part in xrange(0, len(cols)-1):
   if not cols[part]: continue
   sent = "{}\033[3{}m {}\033[0m".format(sent, part+2, cols[part][random.randint(0, len(cols[part])-1)])

print sent
