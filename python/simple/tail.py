import time, sys

def pprint(text):
  print text

if not len(sys.argv[1:]):
  print "[Error]: No file to follow!"
  sys.exit()

if len(sys.argv[1:]) > 1: print "[Warn.]: Only one file will be followed!"

try:
  watcher = open(sys.argv[1], 'r')
except IOError:
  print "{} file not found".format(FILENAME)
  sys.exit()

watcher.seek(0, 2)
print "^C to break watchers loop"
while True:
  try:
    input = watcher.readlines()
    watcher.seek(0, 2)
    if input:
      [pprint(line.rstrip()) for line in input if line]
    time.sleep(1)
  except KeyboardInterrupt:
     break

watcher.close()
