#!/usr/bin/env python

# Find rectangle as a result of intersection of other two
# MZvk 2018

rect1 = ((1,1), (1,4), (4,1), (4,4))
rect2 = ((3,3), (3,6), (6,3), (6,6))

def find_lo(rect):
  return (min(rect[0][0], rect[1][0], rect[2][0]), min(rect[0][1], rect[1][1], rect[2][1]))

def find_hi(rect):
  return (max(rect[0][0], rect[1][0], rect[2][0]), max(rect[0][1], rect[1][1], rect[2][1]))

def intersect(rect1, rect2):
  lo = max(find_lo(rect1), find_lo(rect2))
  hi = min(find_hi(rect1), find_hi(rect2))
  return (lo,(lo[0],hi[0]),hi,(lo[1],hi[1]))

print "Rectangle 1:      {}".format(rect1)
print "Rectangle 2:      {}".format(rect2)
print "-" * 80
print "Common rectangle: {}".format(intersect(rect1,rect2))

