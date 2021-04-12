#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;
use Digest::MD5;
use Digest::SHA;

# LOCAL_ENGINE SUBTYPE CHECK [0x6]?

my ($LOGSTATE, $SILENT, $GIBS, $APROT) = (0, 0, 0, '');
my @kuls;

usage() unless scalar @ARGV > 0;
my @args = argparse();
my $jeid = verify_EngineID($args[0]);
for (1..$#args){
   push @kuls, createKul($args[$_], $jeid);
   printf "%s%s\n", $SILENT ? '' : sprintf("LOC. %s KEY [KUL]: ", $_-1 ? 'PRIV' : 'AUTH'), unpack 'H*', $kuls[$_-1];
}
createExtK($kuls[0]) if $GIBS;

sub verify_EngineID {
   my $eid = lc(shift);
   my $eoid = {9 => 'CISCO', 11 => 'HP', 94 => 'NOKIA', 429 => '3COM', 1588 => 'BROCADE', 1777 => 'ATOS', 2011 => 'HUAWEI', 2620 => 'CHECKPOINT', 2636 => 'JUNIPER',
               3376 => 'F5', 3746 => 'SWISSCOM', 4329 => 'SIEMENS', };
   my @unpeid;
   my ($spec, $vndr) = ('', '');
   my %decode = (
      1 => sub { printf "ENGINE_ID ENCODES IPv4 ADDRESS\n" if $LOGSTATE; for (1..4 ) { $spec .= sprintf("%d%s",   $unpeid[$_], $_ == 8  ? '' : '.') } },
      2 => sub { printf "ENGINE_ID ENCODES IPv6 ADDRESS\n" if $LOGSTATE; for (1..16) { $spec .= sprintf("%02X%s", $unpeid[$_], $_ % 2 ? '' : ':') }; $spec =~ s/:$// },
      3 => sub { printf "ENGINE_ID ENCODES MAC  ADDRESS\n" if $LOGSTATE; for (1..6 ) { $spec .= sprintf("%02X%s", $unpeid[$_], $_ == 10 ? '' : ':') } },
      4 => sub { printf "ENGINE_ID ENCODES ADMINISTRATIVELY ASSIGNED TEXT\n"   if $LOGSTATE; for (1..(length $eid)-4) { $spec .= chr($unpeid[$_]) } },
      5 => sub { printf "ENGINE_ID ENCODES ADMINISTRATIVELY ASSIGNED OCTETS\n" if $LOGSTATE; for (1..(length $eid)-4) { $spec .= sprintf("%02X ", $unpeid[$_]) }; $spec =~ s/ $// },
      6 => sub { printf "ENGINE_ID IS LOCAL, IDENTFIES DEFAULT CONTEXT\n"; }, ## NO DATA HOW IT IS FORMATED (RFC5434)
   );
   say "----[ENGINE_ID_VERIFICATION]----" if $LOGSTATE;

   if($eid =~ m/^(?:0x)?([a-f0-9]+)$/i) { 
      $eid = pack 'H*', length($1) % 2 ? '0'.$1 : $1;
      if(length $eid < 5 || length $eid > 32) { printf "[ERROR] Supplied EngineID is out of range (5-32 octets).\n"; return 0; }
      @unpeid = unpack 'NC*', $eid;
      if($unpeid[0] & 0x80000000) {
         printf "RFC2571 ENGINE_ID FORMAT (VARIABLE LENGTH)\n" if $LOGSTATE;
         die "ENGINE_ID DOES NOT FIT SPECIFIED FORMAT LENGTH\n" if len_eid($unpeid[1], scalar @unpeid);
         unless (exists $decode{$unpeid[1]}) { printf "[ERROR] RESERVED OR NOT SUPPORTED FORMAT SPECIFIED INSIDE ENGINE_ID (5th OCTET = 0x%02X)\n", $unpeid[1]; return 0 }
         $decode{$unpeid[1]}();
      } else {
         printf "RFC1910 AGENT_ID FORMAT (12 OCTETS)\n" if $LOGSTATE;
         if(length $eid != 12) { printf "[ERROR] Supplied EngineID fails length check for specified format [%d != 12].\n", length $eid; return 0 }
         $decode{5}();
      }
      $unpeid[0] &= 0x7FFFFFFF;
      $vndr = exists $eoid->{$unpeid[0]} ? $eoid->{$unpeid[0]} : "'$unpeid[0]' NOT RECOGNISED";
   } else { 
      printf "[ERROR] EngineID not in expected format (hexadecimal)\n"; 
      return 0;
   }
   printf "-----\nRAW ENGINE_ID:     %s\nVENDOR:            %s\nSPECIFIC DECODED:  %s\n", uc(unpack 'H*', $eid), $vndr, $spec if $LOGSTATE;
   say "ENGINE_ID SEEMS VALID" unless $SILENT || $LOGSTATE;
   return uc(unpack 'H*', $eid);
}

sub len_eid {
   my ($type, $len) = @_;
   my $limits = {1 => 9, 2 => 21, 3 => 11, 4 => 32, 5 => 32};
   return $len <= $limits->{$type} ? 0 : 1 if $type > 3;
   return $len == $limits->{$type} ? 0 : 1;
}

sub createKul {
   my ($pass, $aeid, $proto) = @_;
   my $digests = {MD5 => 'Digest::MD5', SHA => 'Digest::SHA'};
   die "[ERROR] Unrecognized protocol $proto\n" if !exists $digests->{$APROT};
   my $digest = $digests->{$APROT}->new();
   my $c = 0;
   say "\n----[AUTH/PRIV KEY LOCALIZATION]----"  if $LOGSTATE;
   say "PASSWORD:            $pass"              if $LOGSTATE;
   say "AUTH. ENGINE ID:     $aeid"              if $LOGSTATE;
   say "PROTO:               $APROT"             if $LOGSTATE;
   $aeid = pack 'H*', $aeid;
   my @p = split //, $pass;
   while ($c < 2**20) {
      $digest->add($p[$c % (length($pass))]);
      $c++;
   }
   my $d = $digest->digest();
   printf "DIGEST.0 [KU]:       %s\n", unpack 'H*', $d if $LOGSTATE;
   return $digest->add($d . $aeid . $d)->digest();
}

sub createExtK {
   my $kul = shift;
   my ($ipad, $opad) = ("\x36" x 64, "\x5c" x 64);
   $kul .= "\x00" x (64 - length $kul);
   my $K1 = $kul ^ $ipad;
   my $K2 = $kul ^ $opad;
   
   printf "K1 VALUE: %s\n", (unpack 'H*', $K1);
   printf "K2 VALUE: %s\n", (unpack 'H*', $K2);
}

sub argparse {
   my @args;
   for (@ARGV) {
      s/ +//g;
      if(m/^-help$/i)    { usage() }
      if(m/^-verbose$/i) { $LOGSTATE = 1; next }
      if(m/^-silent$/i)  { $SILENT   = 1; next }
      if(m/^-all$/i)     { $GIBS     = 1; next }
      if(m/^-.*$/)       { print "UNKNOWN OR INCORRECT USE OF OPTION, '$_' WILL BE IGNORED.\n"; next }
      s/^SHA1$/SHA/i; 
      push @args, $_;
   }
   die "[ERROR] SCRIPT REQUIRES AT LEAST 3 VALID ARGUMENTS TO OPERATE\n" if scalar @args < 3;
   $LOGSTATE = 0 if $SILENT;
   $APROT = uc(splice @args, 2, 1);
   printf "[WARN.] TOO MANY ARGUMENTS PROVIDED, LAST %d WERE/WAS DISCARDED\n", scalar @args - 3 if scalar @args > 3;
   return splice @args, 0, 3;
}

sub usage {
my $lb = '#' x (`tput cols`/2);
my $sb = '-' x 20;
    print <<END_USAGE;
$lb
Script used to verify key localization performed by the hosts, can be as well used to create localized keys for the snmp walks. 
Engine ID validation and decoding is done as a part of localization process.

$lb
Usage $0 [options] engineID auth_passwd auth_protocol [priv_passwd]
   Options:
      -help    - prints this message and terminates                           (no operands)
      -verbose - sets output to verbose mode                                  (no operands)  
      -silent  - outputs only localized keys, newline seperated               (no operands)
      -all     - calculates K1, K2 and pre-IV values                          (no operands)
   Silent mode has higher priority then verbose or all mode.
   All and verbose are not exclusive.
   $sb
   engineID:      engine ID in the hexadecimal format                         (5-32 octets)      
   auth_passwd:   password used for the authentication key localization       (8-32 characters)
   auth_protocol: authentication protocols used for key localization          (SHA1 or MD5)
   priv_passwd:   password used for the encryption (privacy) key localization (8-32 characters)
Example:
    $0 -verbose 000000000000000000000002 maplesyrup MD5

$lb
MZvk v0.4a // 06.04.2021
END_USAGE
exit 0;
}
