import sys, os

configDir = '/path/to/some/files'

def wasteTime(filename):
  try:
    with open(filename, 'r') as file:
      cfgline = [line.strip() for line in file]
  except IOError, err:
      print err
      return 0
  return cfgline

def progressBar(current, max, title = 'Progress'):
    percent = "{:>6.2f}%".format(100 * current/float(max))
    ending = "\n" if current == max else ""
    fill = int(50 * current // max)
    sys.stdout.write('\r{} |{}| {} Completed {}'.format(title, "{}{}".format("#" * fill, '_' * (50 - fill)),  percent, ending))    
    sys.stdout.flush()

def main():
  print "\033[?25lChecking if I care..."
  try:
    files = os.listdir(configDir)
    progressBar(0, len(files), title = 'Checking in progress:')
  except OSError, err:
    print err
    sys.exit()             
  for idx, cfgfile in enumerate(files):
    progressBar(idx + 1, len(files), title = 'Checking in progress:')
    target = wasteTime('/'.join([configDir, cfgfile]))
    if not (len(target) > 0):              
      continue
  print "\033[31mFailed!\033[0m I do not care!\033[?25h"

main()
