#!/usr/bin/perl
#
# Encrypts plain-text using Juniper based Vigenere algorithm
# initial Vigenere table, hex values of string: QzF3n6/9CAtpu0OB1IREhcSyrleKvMW8LXx7N-dVbwsY2g4oaJZGUDjiHkq.mPf5T
# MZvk|A544778
#

use strict;
use warnings;

#vigenere table
my @jvig = (0x51,0x7a,0x46,0x33,0x6e,0x36,0x2f,0x39,0x43,0x41,0x74,0x70,0x75,0x30,0x4f,0x42,0x31,0x49,0x52,0x45,
            0x68,0x63,0x53,0x79,0x72,0x6c,0x65,0x4b,0x76,0x4d,0x57,0x38,0x4c,0x58,0x78,0x37,0x4e,0x2d,0x64,0x56,
            0x62,0x77,0x73,0x59,0x32,0x67,0x34,0x6f,0x61,0x4a,0x5a,0x47,0x55,0x44,0x6a,0x69,0x48,0x6b,0x71,0x2e,
            0x6d,0x50,0x66,0x35,0x54);

#pad length
my @padl = (0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x02,0x02,0x02,0x02,0x02,
            0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x01,0x01,0x01,0x01,0x01,
            0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x00,0x00,0x00,0x00,0x00,
            0x00,0x00,0x00,0x00,0x00);

#moduli table		 
my @jmod = ([0x01,0x04,0x20],[0x01,0x10,0x20],[0x01,0x08,0x20],[0x01,0x40],
            [0x01,0x20],[0x01,0x04,0x10,0x80],[0x01,0x20,0x40]);

die "No string provided for encryption!\n" unless $ARGV[0];
my $junk = '';
my $salt;

if($ARGV[1] and $ARGV[1] =~ /^[a-z0-9\/.\-]+$/i){
  ($salt) = grep { $jvig[$_] eq hex(unpack 'H*', substr($ARGV[1], 0, 1)) } 0 .. $#jvig;
  die "Incorrect salt!\n" unless length(substr($ARGV[1], 1, $padl[$salt])) eq $padl[$salt];
  $junk = substr($ARGV[1], 1, $padl[$salt]);
} else {
  $salt = int(rand(scalar @jvig));
  $junk .= chr($jvig[int(rand(scalar @jvig))]) for 1 .. $padl[$salt];
}

my $prv = $salt;
my @string = split //, $ARGV[0];
my $output = '$9$'.chr($jvig[$salt]).$junk;

for (0 .. $#string){
  my $nibb = $jmod[$_ % @jmod];  
  my $echar = ord($string[$_]);
  my @gaps;
  for my $mod (reverse @$nibb){
    push @gaps, int($echar/$mod);
    $echar %= $mod;
  }
  for my $gap (reverse @gaps){
    $gap += $prv + 1;
    $prv = $gap;
    $output .= chr($jvig[$gap % @jvig]);
  }
}

print $output;
