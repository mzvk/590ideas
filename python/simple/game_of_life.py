#!/usr/bin/env python

# Terminal animation for the Conway's Game of Life
# MZvk 2019

##example flocks:
# glider      6x6   f="2,6,8,13,14"
# glider      10x10 f="2,10,12,21,22"
# random      20x20 f="2,50,52,101,102,46,96,98,146,147,21,22,32,42,46,85,33,123,33, 200, 201, 202, 210, 220, 234, 224"
# R-pentomino 20x20 f="72,73,91,92,112"

import sys, time, copy, re

_GRIDX = 20
_GRIDY = 20
nmap = [-_GRIDX+1,-_GRIDX,-_GRIDX-1,+1,_GRIDX+1,_GRIDX,_GRIDX-1,-1]
immortal = []                          # cells which will never die
init_flock = [72,73,91,92,112]         # defualt starting flock [20x20 grid]
newborns = {}

class regex(object):
  def __or__(self, other):
    self.sre = other
    return other
  def group(self, index=0):
    return self.sre.group(index)

def argparse(args):
   rgx = regex()
   global _GRIDX, _GRIDY, nmap, immortal, init_flock
   f = 0
   for arg in args:
      if (rgx|re.match(r'^([3-9]|1[0-9]|2[0-5])x([3-9]|1?[0-9]|2[0-5])$', arg)) and not (f & 0x1):
         f |= 0x1
         (_GRIDX, _GRIDY) = (int(rgx.group(1)), int(rgx.group(2)))
         nmap = [-_GRIDX+1,-_GRIDX,-_GRIDX-1,+1,_GRIDX+1,_GRIDX,_GRIDX-1,-1]
      elif (rgx|re.match(r'^([if])=([0-9]+(?:, ?[0-9]+)*)$', arg)):
         if rgx.group(1) == 'i' and not (f & 0x2):
            f |= 0x2
            immortal = [int(x) for x in rgx.group(2).split(',')]
         elif rgx.group(1) == 'f' and not (f & 0x4):
            f |= 0x4
            init_flock = [int(x) for x in rgx.group(2).split(',')]

def eprint(txt):
   sys.stdout.write(txt)
   sys.stdout.flush()

def countN(cell, flock):
   neighbors = set(nmap)
   result = 0
   if(cell / _GRIDY == 0):          neighbors -= {-_GRIDX-1, -_GRIDX, -_GRIDX+1} ## upper
   if(cell / _GRIDY == _GRIDY - 1): neighbors -= { _GRIDX-1,  _GRIDX,  _GRIDX+1} ## lower
   if(cell % _GRIDX == 0):          neighbors -= {-_GRIDX-1,      -1,  _GRIDX-1} ## leftmost
   if(cell % _GRIDX == _GRIDX - 1): neighbors -= {-_GRIDX+1,       1,  _GRIDX+1} ## righmost
   for neighbor in neighbors:
      if neighbor + cell in flock: result += 1
      else: newborns[neighbor + cell] = newborns[neighbor + cell] + 1 if neighbor + cell in newborns else 1
   return result

if __name__ == '__main__':
   argparse(sys.argv[1:])
   try:
      eprint("\033[2J\033[H\033[?25l")
      print "*** THIS IS THE GAME OF LIFE ***\n"
      print "{}{}{}".format(' +-', '-' * (_GRIDX * 2 - 1), '-+ ')
      for x in xrange(_GRIDX):
         print '{}{}{}'.format(' | ', ' '.join(['.'] * _GRIDY), ' | ')
      print "{}{}{}".format(' +-', '-' * (_GRIDX * 2 - 1), '-+ ')

      flock = {k:[1, 0] for k in (init_flock + immortal)}
      deadmans = []
      epoch = 1
      phash = [0]

      while(1):
         new_flock = {}
         newborns = {}
         eprint("\033[2;1HEpoch: {}".format(epoch))

         for cell in deadmans:
            eprint("\033[{};{}H.".format((cell/_GRIDX)+4, (cell%_GRIDY)*2+4))
         deadmans = []

         for cell in flock:
            if cell >= _GRIDX * _GRIDY: continue
            eprint("\033[{};{}H\033[33m*\033[0m".format((cell/_GRIDX)+4, (cell%_GRIDY)*2+4))
            flock[cell][1] = countN(cell, flock)
            if (flock[cell][1] >= 2 and flock[cell][1] <= 3) or cell in immortal: new_flock[cell] = [1,0]
            else: deadmans.append(cell)

         for cell in newborns:
            if newborns[cell] == 3:
               new_flock[cell] = [1,0]
         flock = copy.deepcopy(new_flock)
         epoch += 1
         time.sleep(0.2)

         if(hash(tuple(sorted(flock.keys()))) in phash): break
         else:
            if not len(phash) < 5: phash.pop(0)
            phash.append(hash(tuple(sorted(flock.keys()))))

      eprint("\033[{};0H".format(_GRIDY + 6))
      print "> Simulation terminated due no pattern change in the five consecutive epochs."
      print "> {} of cells will live forever".format(len(flock))
   except KeyboardInterrupt:
      print "\033[2J\033[H"
   finally:
      print "\033[?25h"
