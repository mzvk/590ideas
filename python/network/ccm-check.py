#!/usr/bin/env python

## Script to validate if all of the configured MEPs are pacing CCMs correctly.
## Analysis pcap file.
## Mzvk 2020

import scapy.error
from scapy.utils import RawPcapReader
from scapy.all import bytes_hex
from StringIO import StringIO
import argparse, sys

def errormap(key):
   if key == 'len': return 'PACKET LENGTH'
   if key == 'dmac': return 'WRONG DESTINATION MAC'
   if key == 'etht': return 'WRONG ETHERTYPE'
   if key == 'noam': return 'NOT AN OAM CFM FRAME'
   if key == 'nccm': return 'NOT A CCM FRAME'
   if key == 'lost': return 'LOST OR OUT OF ORDER CCM FRAMES'
   if key == 'dlay': return 'PACKET MISSED ITS SEND INTERVAL'

def timecmp(ts1, ts2, mode):
   if mode == 1:
      if ts2 > ts1: return ts2
      return ts1
   if mode == 2:
      if ts1 == 0: return ts2
      if ts2 < ts1: return ts2
      return ts1
   else:
      return -1

def timeavg(tsls):
   if len(tsls) < 2: return tsls[0]
   return sum(tsls) / len(tsls)

parser = argparse.ArgumentParser(prog='ccm-check', usage='%(prog)s [options] pcap-file')
parser.add_argument('pcap', metavar='path', type=str)
parser.add_argument('--debug', action='store_true')
parser.add_argument('--verbose', action='store_true')
args = parser.parse_args()

error = {'len': 0, 'dmac': 0, 'etht': 0, 'noam': 0, 'nccm': 0, 'lost': 0, 'dlay': 0}
intmap = ['invalid', '3.33ms', '10ms', '100ms', '1s', '10s', '1min', '10min']

### BASE VALUES
ccm_int = 60000
ccm_ths = 0.05
ccm_base = ccm_int + int(ccm_ths * ccm_int)

count = 0
gcount = 0
result = {}
ooseq = set()
delay = set()

try:
   RawPcapReader(args.pcap)
except IOError:
   sys.exit('No such file.')
except scapy.error.Scapy_Exception:
   sys.exit('Not a pcap file.')

for (pkt_data, pkt_meta) in RawPcapReader(args.pcap):
   count += 1
   if pkt_meta[3] < 92:
      if args.debug: print "packet {} ignored - incorrect packet length (less then 92 bytes) :: {}".format(count, pkt_meta[3])
      error['len'] += 1
      continue

   raw_pkt = bytes_hex(pkt_data)
   h_ether = raw_pkt[  :28]
   h_8021q = raw_pkt[28:36]
   h_cfm   = raw_pkt[36:40]
   h_ccm   = raw_pkt[40:  ]

   if raw_pkt[:11] != '0180c200003':
      if args.debug: print "packet {} ignored - destination MAC is not an OAM Multicast (01:80:C2:00:00:3X) :: {}.".format(count, raw_pkt[:12])
      error['dmac'] += 1
      continue

   if int(raw_pkt[24:28], 16) < 1536 and raw_pkt[24:28] != '8100':
      if args.debug: print "packet {} ignored - wrong ethertype or no 802.1Q header :: {}.".format(count, raw_pkt[24:28])
      error['etht'] += 1
      continue

   if raw_pkt[32:36] != '8902':  ## currently it is assumed that only 802.1q tagged frames are rcvd (cfm is 2nd ethtype)!
      if args.debug: print "packet {} ignored - not a OAM CFM frame :: {}.".format(count, raw_pkt[32:36])
      error['noam'] += 1
      continue

   if raw_pkt[38:40] != '01':
      if args.debug: print "packet {} ignored - not a CCM frame :: {}".format(count, raw_pkt[38:40])
      error['nccm'] += 1
      continue

   gcount += 1
   mpid = int(raw_pkt[52:56], 16)
   seq  = int(raw_pkt[44:52], 16)
   rxt = pkt_meta[:2]

   if int(raw_pkt[40:42]) & 7 != 6:
      print "\033[31mWARNING:\033[0m wrong CCM transmission interval on packet {} [MEP ID: {}] :: {}".format(count, mpid, intmap[int(raw_pkt[40:42])])

   if mpid not in result:
      result[mpid] = [[seq,rxt]]
   else:
      if result[mpid][len(result[mpid])-1][0] != seq - 1:
         print "\033[31mWARNING:\033[0m not the next sequance number for {} CCM is {}, should be {} for MEP ID: {}".format(count, seq, result[mpid][len(result[mpid])-1][0] + 1, mpid)
         error['lost'] += 1
         ooseq.add(mpid)

      sec = (rxt[0] - result[mpid][len(result[mpid])-1][1][0]) * 10**9
      sec += rxt[1] - result[mpid][len(result[mpid])-1][1][1]
      sec = int(sec * 10**-6)
      if sec >= ccm_base:
         print "\033[31mWARNING:\033[0m too big delay between next CCM frame {} from MEP ID {}, threshold: {} was rcvd: {}".format(
               count, mpid, ccm_base, sec)
         error['dlay'] += 1
         delay.add(mpid)

      result[mpid].append([seq,rxt])




print "\nPackets read: {}\nPackets discarded: {}".format(count, count - gcount)
print "-------\nErrors: "
for key in error:
   print "  {:32} = {}".format(errormap(key), error[key])

print "-------\nNumber of discovered MEPs: {}\nNumber of MEPs with OoO or missing CCM: {}\nNumber of MEPs to miss its trans. interval: {}\n".format(
      len(result), len(ooseq), len(delay))

if not ooseq and not delay and not count - gcount:
   print "ALL *SEEMS* GOOD! :)"
else:
   print "SOME ERRORS WERE OBSERVERD! :("
   if not args.verbose:
      print "RUN --verbose TO GET DUMP OF MEP ID SPECIFIC DATA LIKE SEQUENCE NUMBERS OR TIMESTAMPS"
   if not args.debug:
      print "RUN --debug TO GET ERROR MESSAGES OF DISCARDED FRAMES"

if args.verbose:
   print "\nPress enter to continue."
   org = sys.stdout
   sys.stdout = StringIO()
   raw_input()
   sys.stdout = org
   print "MEP DATA DUMP\n"
   for mpid in result:
      (tmax, tmin, tavg) = (0, 0, 0)
      tvar = []
      for idx, frames in enumerate(result[mpid]):
         if idx == 0: continue
         sec = (frames[1][0] - result[mpid][idx-1][1][0]) * 10**9
         sec += frames[1][1] - result[mpid][idx-1][1][1]
         sec = int(sec * 10**-6)
         tvar.append(sec)
         tmax = timecmp(tmax, sec, 1)
         tmin = timecmp(tmin, sec, 2)
      tavg = timeavg(tvar)
      print "MEP ID {}\n--------\nseq: {}\nrcv time delta\n MAX: {}ms\n MIN: {}ms\n AVG: {}ms\n".format(mpid, [x[0] for x in result[mpid]], tmax, tmin, tavg)
   if ooseq: print "OOSEQ DATA DUMP\n{}".format(ooseq)
   if delay: print "DELAY DATA DUMP\n{}".format(delay)
