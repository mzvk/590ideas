#!/usr/bin/env python

import re, threading
from sys import argv, exit
from xml.dom import minidom

ver = '0.5.2b [23:36 11.03.2017]'

ifRgxPtn = ['^(lo)o?p?b?a?c?k?([0-9]+)$',
            '^(vlan)([0-9]+)$',
            '^(mgmt)(0)$',
            '^(eth)e?r?n?e?t?([0-9]+/[0-9]+(.[0-9]+)?)$']

def needhelp(argv):
  if argv[1] == '__cli_script_help':
    print 'Run ping sweep across configured interface(s) - must be up/up'
    exit()
  if argv[1] == '__cli_script_args_help':
    print '<interface>'
    print 'all'
    exit()

class PingThrd(object):
  status = {'alive': [], 'dead': 0}
  thread_cout = 4
  lock = threading.Lock()
  prefix = None
  masklen = None
  generator = None

  def ping(self, ipv4Host):
    result = re.search(r'([0-9.]+%) packet loss', cli('ping '+ipv4Host+' vrf '+ifDict[ifname]['ifvrf']+' timeout 1 count 2'))
    return 1 if not result.group(1) == '100.00%' else 0

  def popQueue(self):
    ipv4Host = None
    self.lock.acquire()
    try:
      ipv4Host = int2str(self.generator.next())
      if str2int(ipv4Host) == self.prefix: ipv4Host = int2str(self.generator.next())
    except StopIteration:
      pass
    self.lock.release()
    return ipv4Host

  def dequeue(self):
    while True:
      ipv4Host = self.popQueue()
      if not ipv4Host: return None
      if self.ping(ipv4Host): self.status['alive'].append(ipv4Host)
      else: self.status['dead'] += 1

  def start(self, argprefix, argmasklen):
    jobs = []
    self.status = {'alive': [], 'dead': 0}
    (self.prefix, self.masklen) = (argprefix, argmasklen)
    subnet = self.prefix & ((2 ** 32 - 1) - (2 ** (32 - self.masklen) - 1))
    print '+ ICMP sweep for: {}/{} - {}'.format(int2str(subnet), self.masklen, ifDict[ifname]['ifnme'])
    self.generator = hostgen(subnet, self.masklen)
    for i in range(self.thread_count):
      thrd = threading.Thread(target=self.dequeue)
      thrd.start()
      jobs.append(thrd)
    [ thrd.join() for thrd in jobs ]
    return self.status

def redalert(txt):
  return '\x1b[31;01m'+txt+'\x1b[00m'

def str2int(ipStr):
  ipStr = ipStr.split('.')
  return 0 | (int(ipStr[0]) << 24) | (int(ipStr[1]) << 16) | (int(ipStr[2]) << 8) | int(ipStr[3])

def int2str(ipInt):
  return str(ipInt >> 24 & 0xff)+'.'+str(ipInt >> 16 & 0xff)+'.'+str(ipInt >> 8 & 0xff)+'.'+str(ipInt & 0xFF)

def parsearg(argv):
  iflist = []
  for arg in argv:
    for rgxp in ifRgxPtn:
      rgx = re.match(rgxp, arg.lower())
      if rgx:
        iflist.append(rgx.group(1) + rgx.group(2))
        break
    if not rgx: print redalert('[Error]')+' Invalid interface name: {} - ignoring.'.format(arg)
  if len(iflist) < 1:
    print redalert('[Error]')+' No valid interfaces supplied. -- (terminated)'
    exit()
  return iflist

def hostgen(subnet, masklen):
  shift = 1 if masklen < 30 else 0
  ipv4 = subnet + 1 if masklen < 30 else subnet
  while ipv4 <= subnet | (2 ** (32 - masklen) - 1 - shift):
    yield ipv4
    ipv4 += 1

def cli2xml(cmd):
  xmlout = cli(cmd + ' | xml').replace('\n', '').strip('\\n]]>]]>')
  xmlout += '>'
  xmlout = minidom.parseString(xmlout)
  return xmlout

def node2txt(node):
  try:
    nodetext=node[0].firstChild.data.strip()
    return nodetext
  except IndexError:
    return "__na__"

def popifDict():
  xml = cli2xml('show ip interface vrf all')
  ifDict = {}

  for ifs in zip(xml.getElementsByTagName('ROW_intf'), xml.getElementsByTagName('ROW_vrf')):
    if not node2txt(ifs[0].getElementsByTagName('intf-name')) == '__na__':
      xml = cli2xml('show ip interface '+node2txt(ifs[0].getElementsByTagName('intf-name')))
      ifname = node2txt(ifs[0].getElementsByTagName('intf-name')).lower()
      ifDict[ifname] = dict(\
         ifnme=node2txt(ifs[0].getElementsByTagName('intf-name')),
         ifvrf=node2txt(ifs[1].getElementsByTagName('vrf-name-out')),
         ifpfx=node2txt(ifs[0].getElementsByTagName('prefix')),
         ifmln=[node2txt(sec.getElementsByTagName('masklen')) for sec in xml.getElementsByTagName('ROW_intf')],
         ifsec=[node2txt(sec.getElementsByTagName('prefix1')) for sec in xml.getElementsByTagName('ROW_secondary_address')],
         ifsml=[node2txt(sec.getElementsByTagName('masklen1')) for sec in xml.getElementsByTagName('ROW_secondary_address')],
         ifadm=node2txt(ifs[0].getElementsByTagName('admin-state')),
         ifprt=node2txt(ifs[0].getElementsByTagName('proto-state')),
         iflnk=node2txt(ifs[0].getElementsByTagName('link-state')))
      ifDict[ifname]['ifmln'] = ifDict[ifname]['ifmln'][0]
    else:
      print redalert('[Error]')+' Hit unknown index while parsing xml node.'
  return ifDict

##############################
needhelp(argv)
if len(argv) - 1 < 1:
  print 'Usage: <script> {<interface>|all}'
  print 'Version: {} {} (A544778)'.format(ver, redalert('MZvk'))
  exit()

if 'all' in argv:
  print '+ Option \'ALL\' selected, sweeping through all interfaces.'
  iflist = ['all']
else:
  iflist = parsearg(argv[1:])

ifDict = popifDict()

print '+ Interfaces configured for IPv4: '
print '-' * 65
print '| ifname         | prefix          | status         | vrf'
print '|                |                 | (amd/prt/lnk)  |'
print '-' * 65
for ifn in ifDict:
   if not 'all' in iflist: pri = '*' if ifn in iflist else ' '
   else: 
     pri = '*'
     iflist.append(ifn)
   print redalert(pri)+'{:<15}  {:<16}  {:<16} {}'.format(ifDict[ifn]['ifnme'], ifDict[ifn]['ifpfx'],
                                                          ifDict[ifn]['ifadm'] +'/'+ ifDict[ifn]['ifprt']
                                                          +'/'+ ifDict[ifn]['iflnk'], ifDict[ifn]['ifvrf'])
   if len(ifDict[ifn]['ifsec']) > 0: 
     for sec in ifDict[ifn]['ifsec']:
       print redalert(pri)+'{:<15}  {:<16}  {:<16} {}'.format(' \_secondary_ ',
                                                              sec, ' --- ', ' --- ')
print '-' * 65
if iflist[0] == 'all': iflist.pop(0)

ping = PingThrd()
ping.thread_count = 16

for ifname in iflist:
  if not ifname in ifDict:
    print redalert('[Error]')+' Interface ' + ifname + ' is not configured on this device.'
  elif not ifDict[ifname]['ifprt'] == 'up' or not ifDict[ifname]['iflnk'] == 'up' or not ifDict[ifname]['ifadm'] == 'up':
    print redalert('[Error]')+' Interface ' + ifname + ' is not operational.'
  else:
    result = ping.start(str2int(ifDict[ifname]['ifpfx']), int(ifDict[ifname]['ifmln']))
    print ' + Sweep completed: {}/{}'.format(len(result['alive']) + 1, result['dead'] + len(result['alive']) + 1)
    for aip in result['alive']: print '  -\x1b[00;32m {} is reachable \x1b[00m'.format(aip) 
    if len(ifDict[ifname]['ifsec']) > 0:
      for ipsec in zip(ifDict[ifname]['ifsec'], ifDict[ifname]['ifsml']):
        result = ping.start(str2int(ipsec[0]), int(ipsec[1]))
        print ' + Sweep completed: {}/{}'.format(len(result['alive']) + 1, result['dead'] + len(result['alive']) + 1)
        for aip in result['alive']: print '  -\x1b[00;32m {} is reachable \x1b[00m'.format(aip)

