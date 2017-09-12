#!/usr/bin/env python

import random, re, sys
win = ((0,1,2),(3,4,5),(6,7,8),(0,3,6),(1,4,7),(2,5,8),(0,4,8),(2,4,6))

def drawgfx(x):
  print "\n  {} | {} | {} \n ---+---+--- \n  {} | {} | {} \n ---+---+--- \n  {} | {} | {}  \n".format(x[6],x[7],x[8],x[3],x[4],x[5],x[0],x[1],x[2])

def pmove(x):
  while True:
    move = raw_input('> Please select your move [\033[37m1-9\033[0m or \033[37mblank\033[0m to quit]: ')
    if not move:
      sys.exit()
    if re.search(r'^[1-9]$', move) and x[int(move) - 1] == ' ':
      return int(move) - 1
    print ' \033[31mInvalid move...\033[0m'

def cmove(x):
##  while True:
##    for pwn in win:
    ## finish if possible
    ## block player
    ## add to existing line
    ## take middle - 75% of the time
    move = random.randint(0, 8)
    if x[move] == ' ':
      return move

def chckb(x):
  for lines in win:
    if all(x[cell] in psprite for cell in lines):
      x[lines[0]] = x[lines[1]] = x[lines[2]] = "\033[33m{}\033[0m".format(psprite)
      print ">> \033[37mYOU WIN!\033[0m"
      return 1
    if all(x[cell] in csprite for cell in lines):
      x[lines[0]] = x[lines[1]] = x[lines[2]] = "\033[33m{}\033[0m".format(csprite)
      print ">> \033[37mCPU WINS!\033[0m"
      return 1
  if all(cell not in ' ' for cell in x):
      print ">> \033[37mTIE!\033[0m"
      return 1

bstatus = [' ' for x in xrange(9)]
charset = set(['X', 'O'])
psprite = ''

while psprite not in charset:
  psprite = raw_input('> Select \'X\' or \'O\' [default X]: ').upper()
  if not psprite:
    psprite = 'X'

charset.discard(psprite)
csprite = next(iter(charset))

if(random.randint(0, 1)):
  bstatus[cmove(bstatus)] = csprite

drawgfx(bstatus)
while(True):
  bstatus[pmove(bstatus)] = psprite
  if(chckb(bstatus)):
    break
  bstatus[cmove(bstatus)] = csprite
  if(chckb(bstatus)):
    break
  drawgfx(bstatus)
drawgfx(bstatus)
