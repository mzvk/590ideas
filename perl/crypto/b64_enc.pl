#!/usr/bin/env perl

## Perl base64 implementation (encoder)
## MZvk 2017

use strict;
use warnings;

sub Encode {
  my $d = shift;
  my $p = shift // '=';
  my @b = shift // ('A'..'Z','a'..'z',0..9,'+','/');

  my $pad = (3 - length($d) % 3) % 3;
  $d =~ s/(.)(.)?(.)?/$b[unpack('C', $1) >> 2].$b[((unpack('C', $1) & 0x03) << 4) + ($2 ? ((unpack('C', $2) & 0xF0) >> 4) : 0)].
                      $b[($2 ? ((unpack('C', $2) & 0x0F) << 2) : 0) + ($3 ? ((unpack('C', $3) & 0xC0) >> 6) : 0)].$b[($3 ? unpack('C', $3) & 0x3F : 0)]/ge;
  $d =~ s/.{$pad}$/$p x $pad/e if $pad;
  return $d;
}

if($ARGV[0]){
  print Encode($ARGV[0]);
}
