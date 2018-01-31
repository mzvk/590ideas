#!/usr/bin/env perl

## Perl base64 implementation (encoder)
## MZvk 2017

use strict;
use warnings;

sub Encode {
  my $d = shift;
  my $p = shift // '=';
  my @b = shift // ('A'..'Z','a'..'z',0..9,'\+');

  my $pad = (3 - length($d) % 3) % 3;
  $d =~ s/(.)(.)?(.)?/$b[unpack('C', $1) >> 2].$b[((unpack('C', $1) & 0x03) << 4) + ((unpack('C', $2?$2:0) & 0xF0) >> 4)].
                      $b[((unpack('C', $2?$2:0) & 0x0F) << 2) + ((unpack('C', $3?$3:0) & 0xC0) >> 6)].$b[unpack('C', $3?$3:0) & 0x3F]/ge;
  $d =~ s/.{$pad}$/$p x $pad/e if $pad;
  return $d;
}

if($ARGV[0]){
  print Encode($ARGV[0]);
}
