#!/usr/bin/env python

import sys
hist = [2, 5, 4, 2, 3, 1, 1, 1]

#remove/rework it after LDN!
def draw(hist):
  print '   '+'-'*(len(hist) * 3 + 1)
  for hgh in xrange(max(hist), 0, -1):
    line1 = ['   |']
    line2 = ['   |']
    for val in hist:
      char = '##|' if val >= hgh else '  |'
      line1.append(char)
      line2.append(char)
    print ''.join(line1)
    print ''.join(line2)
    print '   '+'-'*(len(hist) * 3 + 1)
  line = ['   |']
  for val in hist:
    line.append('{:2d}|'.format(val))
  print ''.join(line) + '\n'

def pop_stck(pstack, vstack, val, pos, max):
  while vstack and vstack[len(vstack) - 1] > val:
    tpos = pstack.pop()
    thgh = vstack.pop()
    tmax = thgh * (pos - tpos)
    if tmax > max: max = tmax
  return max

def find_rect(hist):
  pos_stck = []
  hgh_stck = []
  cur_high = 0

  for pos,val in enumerate(hist):

    #inital stack push
    if not len(pos_stck):
      pos_stck.append(pos)
      hgh_stck.append(val)

    cur_high = pop_stck(pos_stck, hgh_stck, val, pos, cur_high)

    if hgh_stck and hgh_stck[len(hgh_stck) - 1] < val:
      pos_stck.append(pos)
      hgh_stck.append(val)

    if pos == len(hist) - 1:
      while len(hgh_stck):
        tpos = pos_stck.pop()
        thgh = hgh_stck.pop()
        tmax = thgh * (pos - tpos)
        if tmax > cur_high: cur_high = tmax

  return cur_high

if len(sys.argv[1:]) > 0:
  try:
    hist = [int(x, 10) for x in sys.argv[1:] if int(x) <= 10]
    print "INFO: All values above default [10] threshold will be discarded.\n"
  except ValueError:
    print "Input contains non-integers - ignored.\n"

  if not hist:
    print 'No valid input.'
    sys.exit()

draw(hist)
print "{} len: {}".format(hist, len(hist))
print "biggest rect in hist: {}".format(find_rect(hist))

