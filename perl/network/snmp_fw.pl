#!/usr/bin/env perl

## Unfinished PoC script which retrieves routing information from SRX/ASA/SSG firewalls via SNMP
## Mzvk 2017

##------------
## MODULES ###
use feature qw(say);
use strict;
use warnings;
### CST MODULES ###
use YAML qw(LoadFile);
use Getopt::Long;
use Net::SNMP;
use Data::Dumper;
### OWN MODULES ###
use lib "$ENV{HOME}/scripts/libs/perl/GSA";
use utils qw(str2int int2str msk2len);

##---------------
## GLOBAL VAR ###
my %OIDs = (
             "CidrRoute" => '1.3.6.1.2.1.4.24.4.1',  # IP-FORWARD-MIB => ipCidrRouteTable
             "CidrCount" => '1.3.6.1.2.1.4.24.3.0',  # IP-FORWARD-MIB => ipCIdrRouteNumber
             "IPFWRoute" => '1.3.6.1.2.4.21',        # RFC1213-MIB2   => ipRouteTable
             "IPEntIf"   => '1.3.6.1.2.1.4.20.1.2',  # RFC1213-MIB2   => ipAddrEntIfIndex
             "ifDescr"   => '1.3.6.1.2.1.2.2.1.2',   # IF-MIB         => ifTable/ifDescr
             "SysDescr"  => '1.3.6.1.2.1.1.1.0',
             "ObjectID"  => '1.3.6.1.2.1.1.2.0',
             "SysName"   => '1.3.6.1.2.1.1.5.0'
           );
my ($argDebug, $argCSV) = (0, 0);
my $FWresult;
my $cfh;

#-----------
### MAIN ###
GetOptions (
  "debug" => \$argDebug,
  "csv"   => \$argCSV,
) or exit 255;

my @hostlist = getFeed("$ENV{HOME}/ini/snmp-feed.in");
my $vplist = getYAML("$ENV{HOME}/ini/ent-prod.yml");
if($argCSV){open ($cfh, '>', 'output.csv') or die "[ERROR] Cloud not open/create file: $!";}

if($argDebug) {print "hostlist dump:\n----\n".Dumper(\@hostlist)."----\n";}

for my $ip (@hostlist){
  my ($model, $vendor);
  my($session, $error) = Net::SNMP->session(-hostname => $ip, -community => '**********', -version => '2',); ### SNMP_STRING
  if(!defined $session){
    printf "[ERROR] Failed to create SNMP session for %s, %s!\n", $ip, $error; 
    $FWresult->{$ip}->{status} = 'SNMP session failed'; 
    next;
  }
  my $result = $session->get_request(-varbindlist => [$OIDs{SysDescr}, $OIDs{ObjectID}, $OIDs{SysName}]);
  if(!defined $result) {
    printf "[ERROR] %s", $session->error();
    $FWresult->{$ip}->{status} = 'SNMP query failed';
    $session->close();
    next;
  }
  if($result->{$OIDs{ObjectID}} eq 'noSuchInstance') {say "[ERROR] No such object - $OIDs{ObjectID}"; next;}
  if($argDebug){printf "%s = %s\n", $OIDs{SysDescr}, $result->{$OIDs{SysDescr}};}

  my ($vid, $pid) = $result->{$OIDs{ObjectID}} =~ m/1\.3\.6\.1\.4\.1\.([0-9]+)\.1\.(.*)$/;
  if($argDebug){say $pid;}
  if(exists $vplist->{$vid})
    {$FWresult->{$ip}->{vendor} = $vplist->{$vid}->{name};}
  else
    {$FWresult->{$ip}->{vendor} = 'Undetermined';}

  $FWresult->{$ip}->{model} = $vplist->{$vid}->{$pid} if exists $vplist->{$vid}->{$pid};
  $FWresult->{$ip}->{os} = getOSVersion($vid, $pid, $result->{$OIDs{SysDescr}});
  $result->{$OIDs{ObjectID}} =~ s/\..*$//;
  $FWresult->{$ip}->{name} = $result->{$OIDs{SysName}};

  if($FWresult->{$ip}->{vendor} eq "Juniper"){
    $FWresult->{$ip}->{routes} = snmpJuniper($ip, $session);
  }
  elsif($FWresult->{$ip}->{vendor} eq "Cisco"){
    $FWresult->{$ip}->{routes} = cfgCisco($ip);
  }

  $FWresult->{$ip}->{status} = 'Success';
  $session->close();
}

say '----------[BEGIN]----------';
for my $FW (keys %{$FWresult}){
  say '------------------';
  printf "Name:    %s (%s)\n", $FWresult->{$FW}->{name}, $FW;
  printf "Type:    %s (%s)\n", $FWresult->{$FW}->{model}, $FWresult->{$FW}->{vendor};
  printf "SW ver.: %s\n", $FWresult->{$FW}->{os};
  printf "Routes:  %d\n", $FWresult->{$FW}->{routes} ? $FWresult->{$FW}->{routes} : 0;
  if($FWresult->{$FW}->{model} =~ /SRX/){
    printf "Default: %s\n", defined($FWresult->{$FW}->{defif}) ? $FWresult->{$FW}->{ifidx}->{$FWresult->{$FW}->{defif}} : "N/A";
  } else { printf "Default: %s\n", defined($FWresult->{$FW}->{defif}) ? $FWresult->{$FW}->{defif} : "N/A"; }

  say '======[NETWORKS BEHIND]======';
  for my $rte (@{$FWresult->{$FW}->{rtlist}}){
    if($FWresult->{$FW}->{model} !~ m/ASA/){ next if $rte->{ifi} == $FWresult->{$FW}->{defif}; }
    my ($prot, $ifname);
    if($FWresult->{$FW}->{model} =~ m/NetScreen/){
      if($rte->{proto} eq 'NetMGMT' && $rte->{type} eq 'LOCAL') {
        $prot = 'STATIC';
        $ifname = $FWresult->{$FW}->{ipidx}->{$rte->{nh}};
      }
      else{ $prot = $rte->{proto}; $ifname = $FWresult->{$FW}->{ifidx}->{$FWresult->{$FW}->{ipidx}->{$rte->{dst}}}; }
    }
    elsif($FWresult->{$FW}->{model} =~ m/SRX/){
      if($rte->{proto} eq 'NetMGMT' && $rte->{type} eq 'REMOTE') {$prot = 'STATIC';}
      elsif($rte->{proto} eq 'NetMGMT' && $rte->{type} eq 'LOCAL') {$prot = 'LOCAL';}
      else{$prot = $rte->{proto};}
      $ifname = $FWresult->{$FW}->{ifidx}->{$rte->{ifi}};
    }
    else{ $prot = $rte->{proto}; $ifname = $FWresult->{$FW}->{ifidx}->{$rte->{ifi}};}
    printf "%-10s %-16s/%-2s %s: %-16s via %s\n", 
      $prot, int2str(str2int($rte->{dst}) & str2int($rte->{msk})),
      msk2len($rte->{msk}), 'LA', $prot eq 'LOCAL' ? $rte->{dst} : $rte->{nh}, $ifname;
    if($argCSV){
       printf $cfh "%s;%s;%s;%s;%s;%s;%s/%s;%s;%s\n", 
                   $FW, $FWresult->{$FW}->{name}, $FWresult->{$FW}->{vendor}, $FWresult->{$FW}->{model}, $FWresult->{$FW}->{os},
                   $prot, int2str(str2int($rte->{dst}) & str2int($rte->{msk})), msk2len($rte->{msk}), $prot eq 'LOCAL' ? $rte->{dst} : $rte->{nh}, $ifname;
    }
  }
}
say '--------[END OF SCRIPT]----';
if($argCSV){close $cfh;}

sub getFeed {
  my @ip;
  open(FILE, '<', shift) || die "[ERROR] Could not open feed file: $!\n";
  while(<FILE>){
    next if m/^(\s*|#.*)$/;
    chomp && push @ip, $_;
  }
  close(FILE);
  return @ip;
}

sub getYAML {
  open(my $yfh, '<', shift) || die "[ERROR] Couldn't open sysObjectID mapping: $!\n";
  return LoadFile($yfh);
}

sub getOSVersion {
  my ($vid, $pid, $sysDesc) = @_;
  my $version = '** missing **';
  if($vid eq '2636') {($version) = $sysDesc =~ m/JUNOS ([0-9A-Za-z.-]+)/;}
  elsif($vid eq '3224') {($version) = $sysDesc =~ m/version ([0-9A-Za-z.-]+)/;}
  elsif($vid eq '9') {($version) = $sysDesc =~ m/Version ([0-9A-Za-z\.\-\(\)]+)/;}
  return $version;
}

sub getConfig {
  my @lines;
  open(FILE, '<', $_[0]) || do {say "[ERROR] Cannot config open file!: $!"; return @lines;};
  while(<FILE>){
     next if m/^\s+$/;
     chomp && push @lines, $_;
  }
  close(FILE) && return @lines;
}

sub snmpJuniper {
  my ($ip, $session) = @_;
## NAME-VALUE MAPPING
  my %map = ('msk' => '2', 'nh' => '4', 'ifi' => '5', 'type' => '6', 'proto' => '7');
  my %PRmap = (1 => "OTHER", 2 =>  "LOCAL", 3 =>  "NetMGMT", 4 =>  "ICMP", 5 =>  "EGP", 6 =>  "GGP",
               7 =>  "HELLO", 8 =>  "RIP", 9 =>  "ISIS", 10 =>  "ESIS", 11 =>  "IGRP", 12 =>  "bbnSPFIGP",
               13 =>  "OSPF", 14 =>  "BGP", 15 =>  "IDPR", 16 =>  "EIGRP");
  my %RTmap = (1 => "other", 2 => "REJECT", 3 => "LOCAL", 4 => "REMOTE");
  my (%ifindex, %ipifindex);
  my @routes;
  my $prev = '0';
  my $rtcheck = $session->get_request($OIDs{CidrCount});
  if($rtcheck->{$OIDs{CidrCount}} =~ m/noSuch(Instance|Object)/) {
    say "[ERROR] IP-FORWARD-MIB missing, fallback to RFC1213-MIB";
    $rtcheck = $session->get_table($OIDs{IPFWRoute});
    if(!$rtcheck){ say "[ERROR] IP subtree of MIB-2 not found, device skipped!"; return 0;}
#######################
    else { return 0; }
  }
  my $result = $session->get_table($OIDs{CidrRoute});
  for my $oid (sort keys %{$result}){
    if($oid =~ m/1.3.6.1.2.1.4.24.4.1.(1[0-6]|[3,8,9])/){delete $result->{$oid}; next;}
    my ($type, $id) = $oid =~ m/$OIDs{CidrRoute}\.([0-9]+)\.(.*)$/;
    if($type eq '1'){
      my %rte;
      $rte{dst} = $result->{$oid};
      for (keys %map){
        if($_ eq 'type'){$rte{$_} = $RTmap{$result->{join ".", $OIDs{CidrRoute}, $map{$_}, $id}};}
        elsif($_ eq 'proto'){$rte{$_} = $PRmap{$result->{join ".", $OIDs{CidrRoute}, $map{$_}, $id}};}
        else{$rte{$_} = $result->{join ".", $OIDs{CidrRoute}, $map{$_}, $id};}
        if($_ eq 'ifi' && $rte{dst} eq '0.0.0.0'){$FWresult->{$ip}->{defif} = $rte{$_};}
      }
      if($rte{msk} ne '255.255.255.255' && $rte{proto} ne 'OTHER'){push @routes, \%rte;}
    }
  }
  $result = $session->get_table($OIDs{ifDescr});
  for my $oid (sort keys %{$result}){
    $ifindex{substr($oid, length($OIDs{ifDescr}) + 1)} = $result->{$oid}; 
  }
  $result = $session->get_table($OIDs{IPEntIf});
  for my $oid (sort keys %{$result}){
    $ipifindex{substr($oid, length($OIDs{IPEntIf}) + 1)} = $result->{$oid};
  }
  $FWresult->{$ip}->{rtlist} = \@routes;
  $FWresult->{$ip}->{ifidx} = \%ifindex;
  $FWresult->{$ip}->{ipidx} = \%ipifindex;
  return $rtcheck->{$OIDs{CidrCount}};
}

sub cfgCisco {
  my $ip = shift;
  my @filename = glob "cfg/Config-$ip-*";
  if(scalar @filename > 0){
    @filename = sort @filename;
    my @input = getConfig($filename[$#filename]);
    return parseASA(\@input, $ip);
  }
  else{say "[ERROR] Config file for $ip not found!";} 
  return 0;
}

sub parseASA { 
  my @cfg = @{my $cfgref = shift};
  my $ip = shift;
  my @rtlist;
  my $skipped;
  
  while ($_ = shift @cfg){  
    if(m/^interface (((Gigabit|Fast)?Ethernet|Management)[0-9]+\/[0-9]+(\.[0-9]+)?)$/) {
      my $ifd = $1;
      my $ifi = '';
      while(($_ = shift @cfg) !~ /^!/) {
        my %rte;
    	last if m/^\s+shutdown/;
        if(m/^\s+nameif (.*)/){$ifi = $1;}
        elsif(m/^\s+ip\s+address\s+([0-9.]+) ([0-9.]+)( standby .*)?/){
          $rte{ifi} = $ifi;
          $FWresult->{$ip}->{ifidx}->{$rte{ifi}} = $ifd;
          $rte{dst} = $1;
          $rte{msk} = $2;
	  $rte{nh} = '0.0.0.0';
	  $rte{proto} = 'LOCAL';
	  $rte{type} = 'LOCAL';
	  push @rtlist, \%rte;
	}
      }
    }
    elsif(m/^route (.*) ([0-9.]+) ([0-9.]+) ([0-9.]+) [0-9]+$/i) {
      my ($dst, $ifi) = ($2, $1);
      if($dst =~ m/0\.0\.0\.0/){ $FWresult->{$ip}->{defif} = $ifi; $skipped+=1; }
      elsif($dst =~ m/157\.163\.[0-9]{1,3}\.[0-9]{1,3}/){ $FWresult->{$ip}->{mgtif} = $ifi; $skipped+=1; }
      else{
        my %rte;
        $rte{ifi} = $1;
        $rte{dst} = $2;
        $rte{msk} = $3;
        $rte{nh} = $4;
        $rte{proto} = 'STATIC';
        $rte{type} = 'REMOTE';
        push @rtlist, \%rte;
      }
    }
  }
  for my $rte (reverse 0..$#rtlist){
     if(defined($FWresult->{$ip}->{defif})){if($rtlist[$rte]->{ifi} eq $FWresult->{$ip}->{defif}){splice @rtlist, $rte, 1;}}
     if(defined($FWresult->{$ip}->{mgtif})){if($rtlist[$rte]->{ifi} eq $FWresult->{$ip}->{mgtif}){splice @rtlist, $rte, 1;}}
  }
  $FWresult->{$ip}->{rtlist} = \@rtlist;
  return (scalar @rtlist) + $skipped;
}
