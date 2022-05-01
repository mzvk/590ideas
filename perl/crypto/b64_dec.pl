#!/usr/bin/env perl

## Perl base64 implementation (decoder)
## MZvk 2017

use strict;
use warnings;

my @b64 = ('A'..'Z','a'..'z',0..9,'+','/');
my %crypt_b64 = map { $b64[$_] => $_ } 0..$#b64;

sub Decode {
  my $e = shift;

  die "Wrong Base64 string\n" unless (length($e) % 4 == 0 && $e =~ m/^[A-Za-z0-9+\/]+=*$/);
  my $p = ($e =~ s/=/A/g);
  $e =~ s/(.)(.)(.)(.)/pack('C', ($crypt_b64{$1}  << 2) + ($crypt_b64{$2} >> 4)).
                       pack('C', (($crypt_b64{$2} & 0x0F) << 4) + ($crypt_b64{$3} >> 2)).
                       pack('C', (($crypt_b64{$3} & 0x03) << 6) +  $crypt_b64{$4})/ge;
  return substr($e, 0, -1 * $p);
}

if($ARGV[0]){
  print Decode($ARGV[0]);
}
