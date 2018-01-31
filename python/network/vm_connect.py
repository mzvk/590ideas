#!/usr/bin/python

# Mzvk 2016
# - Simple script to connect to the existing VM VMRC
# - Python conversion of bash script
# Note: used raw_input, because written for pyton 2.7.9 :(

from sys import stdout, exit, argv
from time import sleep
from os import system
import paramiko, getopt, re, subprocess, socket

ESXi = {"ipv4": "192.168.242.10", "login": "root", "vmid": 0}
vm_list = []

def qprint(text):
  stdout.write(text)
  stdout.flush()

def icmp(host):
  try:
    proc_out = subprocess.check_output(["ping","-c","2","-i","0.2",host], stderr=subprocess.STDOUT, universal_newlines=False)
  except subprocess.CalledProcessError as sub_e:
    if sub_e.returncode == 1:
      loss = re.search('[0-9]+% packet loss', sub_e.output)
      err_msg("ICMPnoreply", "ESXi is unreachable - "+loss.group(0)+"!", 1)
    else:
      err_msg("ICMPfail", sub_e.output.rstrip('\n')+"!", 1)
  loss = re.search('([0-9]+)% packet loss', proc_out)
  if int(loss.group(1)) != 0:
     print "{} WARNING {}] - {}!".format(Color.oran, Color.clear, loss.group(0))
  else:
     print "{} OK {}]".format(Color.green, Color.clear)

def connect(host, login):
  client = paramiko.SSHClient()
  client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
  try:
    client.connect(host, username=login)
  except paramiko.BadHostKeyException:
    err_msg("BadHostKeyException", "Something wrong with recived key!", 1)
  except paramiko.AuthenticationException:
    err_msg("AuthenticationException", "Bad usernam or password!", 1)
  except paramiko.SSHException:
    err_msg("SSHException", "Other exception occured!", 1)
  except socket.error:
    print Color.red+" ERROR "+Color.clear+"] - socket.error"
    exit()

  print "{} OK {}]".format(Color.green, Color.clear)
  qprint("Getting data: [")
  stdin, stdout, stderr = client.exec_command("vim-cmd vmsvc/getallvms")
  output = stdout.read()
  client.close()
  print "{} OK {}]".format(Color.green, Color.clear)
  return output

def parse_out(output):
  global vm_list
  qprint("Parsing data: [")
  pattern = re.compile('^[0-9]+')
  for line in output.splitlines():
    if pattern.match(line):
      vm_obj = VM()
      i = 0
      for element in line.split(' '):
        if element != "":
          i += 1
          if i == 1: vm_obj.vmid = element
          if i == 2: vm_obj.name = element
          if i == 5:
            vm_obj.guest = element
            vm_list.append(vm_obj)
  print "{} OK {}]".format(Color.green, Color.clear)
  return 0

def input_chck(input, max):
  try:
    value = int(input)
  except ValueError as e:
    err_msg("ValueError", "Not a number!", 0)
  if int(input) > int(max) or int(input) < 0:
    err_msg("ValueError", "Index out of range or negative!", 0)

def err_msg(excp, txt, err_sw):
  if(err_sw == 1): print "{} ERROR {}]".format(Color.red, Color.clear)
  elif(err_sw == 2): print "{} WARNING {}]".format(Color.oran, Color.clear)
  print "[ {}{}{} ] {}".format(Color.red, excp, Color.clear, txt)
  if(err_sw != 2): exit()

def ipv4_valid(ipv4):
  if re.match('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$', ipv4) is None:
    err_msg("SocketError", "Invalid IPv4 address", 1)
  try:
    socket.inet_aton(ipv4)
  except socket.error:
    err_msg("SocketError", "Invalid IPv4 address", 1)
      
def vmid_valid(vmid):
  try:
    value = int(vmid)
  except:
    err_msg("ValueError", "VMid must be numerical!", 1)
  if int(vmid) <= 0:
    err_msg("ValueError", "VMid must be positive!", 1)

def usage():
  print """
  Simple script to connect to the existing VM VMRC by Maciej Zurawski.
  If no moref is given, script will print all existing VMs on host as menu.

  Usage: lab_vmconnect [options]
         - arguments not tied to options will be ignored
         - unrecongnized options will terminate script
         - options are not necessary to run this script (will use defaults)

  Supported options:
         -h / --help : prints this usage
         -4 / --ipv4 : address of host
         -u / --user : username used to log on to the host
         -v / --vmid : VMid of specific VM
         - VMid will be used to connect to specific VM, but only after
           it is validated that it's existing on host
         """
  exit()

class Color:
  blue  = '\33[34m'
  oran  = '\33[33m'
  green = '\33[92m'
  red   = '\33[31m'
  clear = '\33[0m'

class VM:
  def __init__ (self):
    self.vmid = 0
    self.name = ""
    self.guest =""

## MAIN ##

print "{}--------------------------------------------------------------{}".format(Color.oran, Color.clear)

if len(argv) > 1:
  def_txt = "default "
  qprint ("Validating input data: [")
  try:
    argv_opt, argv_rest = getopt.gnu_getopt(argv[1:], 'h4:6:u:v:', ['help', 'ipv4=', 'ipv6=', 'user=', 'vmid='])
  except getopt.GetoptError as e:
    err_msg("GetoptError", str(e) + ", use -h/--help for usage", 1)
  for opt, arg in argv_opt:
    if opt in ('-h', '--help'):
      print "{} OK {}]".format(Color.green, Color.clear)
      usage()
    elif opt in ('-4', '--ipv4'):
      ipv4_valid(arg)
      ESXi["ipv4"] = arg
    elif opt in ('-u', '--user'):
      ESXi["login"] = arg
    elif opt in ('-v', '--vmid'):
      vmid_valid(arg)
      ESXi["vmid"] = arg
  print "{} OK {}]".format(Color.green, Color.clear)
  def_txt = ""
print "Using {}- {}host: {}, login: {}{}".format(def_txt, Color.blue, ESXi["ipv4"], ESXi["login"], Color.clear)

qprint("Checking reachability to ESXi: [")
icmp(ESXi["ipv4"])

qprint("Connecting to ESXi console: [")
parse_out(connect(ESXi["ipv4"], ESXi["login"]))
print "\n .----.----------------------.----------------------.------. "
print " | ID |       VM_ NAME       |       GUEST_OS       | VMid | "
print " '----'----------------------'----------------------'------' "

for idx, vms in enumerate(vm_list):
  print " | %2d | %s | %s | %4d |" % (idx, vms.name.ljust(20), vms.guest.ljust(20), int(vms.vmid))
print " '----'----------------------'----------------------'------' "
vm_idx = raw_input("Select VM to which VMRC you want to connect (q to quit): ")

if vm_idx == 'q':
  print "Bye!"
  print "{}--------------------------------------------------------------{}".format(Color.oran, Color.clear)
  exit()

input_chck(vm_idx, len(vm_list))
system("vmrc -H "+ESXi["ipv4"]+" -U "+ESXi["login"]+" -M "+vm_list[int(vm_idx)].vmid)
print " Goodbye!"
print "{}--------------------------------------------------------------{}".format(Color.oran, Color.clear)

