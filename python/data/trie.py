#!/usr/env python

## Trie binary tree implementation
## Mzvk 2018

class trienode(object):

  def __init__(self, value = None):
    self._value = value
    self._child = dict()

  def add(self, word, pointer = 0):
    char = word[pointer]
    if char not in self._child:
      self._child[char] = trienode()
    if len(word[pointer:]) < 2:
      self._child[char]._value = word
    else:
      self._child[char].add(word, pointer+1)

  def all(self):
    all = []
    for key, child in self._child.iteritems():
      if not child._value is None:
         all.append(child._value)
      all += child.all()
    return all

  def pfx(self, prefix, pointer = 0):
    test = []
    if not len(prefix[pointer:]) > 0:
      return self.all()
    node = prefix[pointer]
    if node in self._child:
      return self._child[node].pfx(prefix, pointer+1)
    else:
      return "Prefix not in Trie."

class trie(object):

  def __init__(self):
    self.root = trienode()

  def add2trie(self, word):
    self.root.add(word)

  def getall(self):
    return self.root.all()

  def getpfx(self, prefix):
    return self.root.pfx(prefix)

## MAIN
data = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi tincidunt, nisl at finibus hendrerit, ex justo aliquet augue, at posuere orci neque sed libero.
Aliquam erat volutpat. In ut interdum ipsum. Quisque id ipsum quis justo congue venenatis quis id ante. Maecenas auctor egestas ligula ut vehicula.
Maecenas faucibus, nunc eu tempor convallis, nibh augue pretium neque, eu ultricies magna felis vel ex. In sollicitudin dolor vulputate facilisis pulvinar.
Morbi turpis urna, condimentum tristique metus in, faucibus eleifend ex. Maecenas est elit, pulvinar nec iaculis vel, condimentum et dui.
Morbi volutpat risus nec felis fringilla blandit eget sed elit. Sed vitae nisi ut ipsum interdum rutrum ut non nibh. Sed ut consequat dui.
Ut at posuere arcu, tempor placerat massa. Donec sit amet mi tincidunt, condimentum nibh id, viverra quam. Ut suscipit turpis non nisi eleifend, vitae rhoncus orci ultricies.
Nulla pulvinar porttitor condimentum. Integer tincidunt turpis sed volutpat sodales. Aliquam dignissim varius tempor. Vestibulum at tristique nunc, vitae fermentum ipsum.
Vivamus fermentum turpis ut finibus pretium. Morbi lorem elit, pretium quis urna at, volutpat rhoncus lectus.
"""

data = [word.strip().lower() for word in data.replace('.', ' ').replace(',', ' ').split(' ')]
data = filter(None, data)

test = trie()
[test.add2trie(string) for string in data]

print "\n Result of getall():"
print test.getall()

print "\n Result of getpfx('e'):"
print test.getpfx('e')

print "\n Result of getpfx('vi'):"
print test.getpfx('vi')
