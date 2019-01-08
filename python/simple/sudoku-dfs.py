#!/usr/bin/env python

# BruteForce sudoku sovler using Depth First Search (DFS)
# MZvk 2018

def getSudoku(file):
  with open(file) as f:
    contents = f.read()
  contents = [x for x in "".join(contents.split("\n")).split(";") if x]
  return [int(x) if x != ' ' else 0 for x in contents]

class SudokuGrid(object):
  (grid, blck) = ([], [])
  border = "+---+---+---+ +---+---+---+ +---+---+---+\n"

  def __init__(self, rawin):
    self.grid = rawin
    self.blck = [1 if x > 0 else 0 for x in rawin]

  def __repr__(self):
    output = ""
    for idx, value in enumerate(self.grid):
      if idx % 9 == 0: output += "\n{}".format(self.border)
      if idx and idx % 27 == 0: output += self.border
      output += "| {} {}".format(value if value > 0 else " ", "" if (idx + 1) % 3 else "| ")
    output += "\n{}".format(self.border)
    return output

  def checkInsert(self, value, id):
    (row, col) = (id / 9, id % 9)
    blk = 3 * (row / 3) + (col / 3)
    for idx in xrange(9):
      if self.grid[idx + 9 * row] == value: return 0 #check row
      if self.grid[9 * idx + col] == value: return 0 #check col
      if self.grid[(idx % 3) + 3 * (blk % 3) + 9 * (idx / 3) + 27 * (blk / 3)] == value: return 0 #check block
    return 1

  def getNext(self, start = 0):
    for cursor in xrange(start, 81):
      if self.blck[cursor] == 0: return cursor
    return cursor

  def solve(self, pos = 0):
    pos = self.getNext(pos)
    for value in xrange(1, 10):
      if self.checkInsert(value, pos):
        self.grid[pos] = value
        if pos == 80 or self.solve(self.getNext(pos + 1)): return 1
      self.grid[pos] = 0
    return 0

  def validateGrid(self):
    pass

Sudoku = SudokuGrid(getSudoku("3.sdk"))
if(Sudoku.solve()):
  print Sudoku
else:
  print "\nImpossibru! Could not solve this sudoku."

