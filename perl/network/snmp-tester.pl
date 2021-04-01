#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;
use Net::SNMP;
use Digest::MD5;
use Digest::SHA;

my ($LOGSTATE) = (0);
my $gkul;

usage() unless scalar @ARGV > 0;
my @args = argparse();

my $jeid = verify_EngineID($args[0]);
$gkul = unpack 'H*', createKul($args[1], $jeid, uc($args[2]));
printf "LOC. AUTH_KEY [KUL]: %s\n", $gkul;
if(scalar @args > 3) {
   $gkul = unpack 'H*', createKul($args[3], $jeid, uc($args[2]));
   printf "LOC. PRIV_KEY [KUL]: %s\n", $gkul;
} 

sub verify_EngineID {
   my $eid = lc(shift);
   my $eoid = {'2636' => 'JUNIPER', 9 => 'CISCO'};
   my @tmpeid;
   my $spec = '';
   my $vndr;
   ### ADD LENGTH CHECK
   my %decode = (
      1 => sub { printf "ENGINE_ID ENCODES IPv4 ADDRESS\n" if $LOGSTATE; for (5..8 ) { $spec .= sprintf("%d%s",   $tmpeid[$_], $_ == 8  ? '' : '.') } },
      2 => sub { printf "ENGINE_ID ENCODES IPv6 ADDRESS\n" if $LOGSTATE; for (5..20) { $spec .= sprintf("%02X",   $tmpeid[$_]); } },   ## NOT WORKING
      3 => sub { printf "ENGINE_ID ENCODES MAC  ADDRESS\n" if $LOGSTATE; for (5..10) { $spec .= sprintf("%02X%s", $tmpeid[$_], $_ == 10 ? '' : ':') } },
      4 => sub { printf "ENGINE_ID ENCODES ADMINISTRATIVELY ASSIGNED TEXT\n"   if $LOGSTATE; for (5..(length $eid)-1) { $spec .= chr($tmpeid[$_]) } },
      5 => sub { printf "ENGINE_ID ENCODES ADMINISTRATIVELY ASSIGNED OCTETS\n" if $LOGSTATE; for (5..(length $eid)-1) { $spec .= sprintf("%02X ", $tmpeid[$_]) }; $spec =~ s/ $// },
      6 => sub { }, ## NO DATA HOW IT IS FORMATED (RFC5434)
   );
   say "----[ENGINE_ID_VERIFICATION]----" if $LOGSTATE;

   if($eid =~ m/^(?:0x)?([a-f0-9]+)$/i) { 
      $eid = pack 'H*', length($1) % 2 ? '0'.$1 : $1;
      if(length $eid < 5 || length $eid > 32) { printf "[ERROR] Supplied EngineID is out of range (5-32 octets).\n"; return 0; }
      my @vndrtp = unpack 'N*', $eid;
      @tmpeid = unpack 'C*', $eid;
      $vndrtp[0] &= 0x7FFFFFFF;
      $vndr = exists $eoid->{$vndrtp[0]} ? $eoid->{$vndrtp[0]} : "'$vndrtp[0]' NOT RECOGNISED";
      if($tmpeid[0] & 0x80){
         printf "RFC2571 ENGINE_ID FORMAT (VARIABLE LENGTH)\n" if $LOGSTATE;
         unless (exists $decode{$tmpeid[4]}) { printf "[ERROR] RESERVED OR NOT SUPPORTED FORMAT SPECIFIED INSIDE ENGINE_ID (5th OCTET = 0x%02X)\n", $tmpeid[4]; return 0; }
         $decode{$tmpeid[4]}();
#         if($tmpeid[4] == 1) {   
#            if(length $eid != 9) {}
#         }
#         elsif($tmpeid[4] == 2) {
#            if(length $eid != 21) {}    
#            printf "ENGINE_ID ENCODES IPv6 ADDRESS\n";
#            
#         }
#         elsif($tmpeid[4] == 3) { 
#            if(length $eid != 11) {}   
#         }
      } else {
         printf "RFC1910 AGENT_ID FORMAT (12 OCTETS)\n";
         if(length $eid != 12) { printf "[ERROR] Supplied EngineID fails length check for specified format [%d != 12].\n", length $eid; return 0; }
         ### DECODE FOR THAT PART 
      }
   } else { 
      printf "[ERROR] EngineID not in expected format (hexadecimal)\n"; 
      return 0;
   }
   printf "-----\nRAW ENGINE_ID:     %s\nVENDOR:            %s\nSPECIFIC DECODED:  %s\n", uc(unpack 'H*', $eid), $vndr, $spec if $LOGSTATE;
   say "ENGINE_ID SEEMS VALID" unless $LOGSTATE;
   return uc(unpack 'H*', $eid);
}

sub createKul {
   my ($pass, $aeid, $proto) = @_;
   my $digests = {MD5 => 'Digest::MD5', SHA => 'Digest::SHA'};
   die "[ERROR] Unrecognized protocol $proto\n" if !exists $digests->{$proto};
   my $digest = $digests->{$proto}->new();
   my $c = 0;
   say "\n----[AUTH/PRIV KEY LOCALIZATION]----" if $LOGSTATE;
   say "PASSWORD:           $pass"              if $LOGSTATE;
   say "AUTH. ENGINE ID:    $aeid"              if $LOGSTATE;
   say "PROTO:              $proto"             if $LOGSTATE;
   $aeid = pack 'H*', $aeid;
   my @p = split //, $pass;
   while ($c < 2**20) {
      $digest->add($p[$c % (length($pass))]);
      $c++;
   }
   my $d = $digest->digest();
   printf "DIGEST.0 [KU]:      %s\n", unpack 'H*', $d if $LOGSTATE;
   return $digest->add($d . $aeid . $d)->digest();
}

sub argparse {
   my @args;
   for (@ARGV) {
      if(m/^-help$/)    { usage() }
      if(m/^-verbose$/) { $LOGSTATE = 1; next }
      if(m/^-.*$/)      { print "UNKNOWN OR INCORRECT USE OF OPTION, '$_' WILL BE IGNORED.\n"; next }
      s/ +//g;
      s/^SHA1$/SHA/; 
      push @args, $_;
   }
   die "SCRIPT REQUIRES AT LEAST 3 VALID ARGUMENTS TO OPERATE\n" if scalar @args < 3;
   return @args;
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
   $sb
   engineID:      engine ID in the hexadecimal format                         (5-32 octets)      
   auth_passwd:   password used for the authentication key localization       (8-32 characters)
   auth_protocol: authentication protocols used for key localization          (SHA1 or MD5)
   priv_passwd:   password used for the encryption (privacy) key localization (8-32 characters)
Example:
    $0 -verbose 000000000000000000000002 maplesyrup MD5

$lb
MZvk v0.2b // 01.04.2021
END_USAGE
exit 0;
}
