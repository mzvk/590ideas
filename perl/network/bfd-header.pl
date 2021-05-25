#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

my @DIAG_MAP = ('NO DIAGNOSTIC', 'CONTROL DETECTION TIME EXPIRED', 'ECHO FUNCTION FAILED', 'NEIGHBOR SIGNALED SESSION DOWN', 'FORWARDING PLANE RESET',
                'PATH DOWN', 'CONCATENATED PATH DOWN', 'ADMINISTRATIVELY DOWN', 'REVERSE CONCATENATED PATH DOWN');
my @STAT_MAP = ('ADMINDOWN', 'DOWN', 'INIT', 'UP');
my @FLAG_MAP = ('P - POLL', 'F - FINAL', 'C - CONTROL PLANE INDEPENDENT', 'A - AUTHENTICATION', 'D - DEMAND', 'M - MULTIPOINT');

my @normstr = usage(argval(@ARGV));
map { parse($_) } @normstr;

sub argval {
   my @normout;
   return @normout if scalar @_ < 1;
   for my $hexstr (@_) {
      $hexstr =~ s/ //g;
      if($hexstr !~ m/^[0-9a-fA-F]+$/) { printf "IGNORED: %s - INVALID CHARACTERS IN HEX STRING\n", $hexstr; next }
      if((length $hexstr) % 2)         { printf "IGNORED: %s - INVALID HEX STRING LENGTH\n", $hexstr; next }
      push @normout, uc($hexstr);
   }
   return @normout;
}

sub shiftn {
   my ($buffer, $idx, $size) = @_;
   return substr($buffer, $idx*2, 2*$size);
}

sub shtime {
   my $hxd = shift;
   my ($int, $unit) = (hex($hxd), 0);
   my @tma = ("us", "ms", "s ");
   while($int > 1000){ $int /= 1000; $unit++ }
   return sprintf "%d %s [%s us] (0x%s)\n", $int, $tma[$unit], hex($hxd), $hxd;
}

sub mapper {
   my ($hxd, $type) = @_;
   if($type == 0) { if($hxd > 31) { say "VALUE OVERFLOWN"; exit }; return sprintf "%s (0x%x)", $hxd > 8 ? 'RESERVED' : $DIAG_MAP[$hxd], $hxd }
   if($type == 1) { if($hxd > 3) { say "VALUE OVERFLOWN"; exit };  return sprintf "%s (0x%s)", $STAT_MAP[$hxd], $hxd }
}

sub shflags {
   my $flag = shift;
   my $output = sprintf "%s%s%s%s%s%s (0x%x)\n", $flag & 0x20 ? 'P' : '-', $flag & 0x10 ? 'F' : '-', $flag & 0x08 ? 'C' : '-',
                                                 $flag & 0x04 ? 'A' : '-', $flag & 0x02 ? 'D' : '-', $flag & 0x01 ? 'M' : '-', $flag;
   for my $i (-5 .. 0) { $output .= sprintf "               %s\n", $FLAG_MAP[5+$i] if $flag & 2**-$i; }
   return $output;
}

sub parse {
   my $hdr = shift;
   my ($idx, $oct, $flag) = (1, shiftn($hdr, 0, 1), 0);
   print "#" x `tput cols`;
   printf "VERSION:       %d\n", hex($oct) >> 5;
   $oct = hex($oct) & 0x1F;
   printf "DIAG:          %s\n", mapper($oct, 0);
   $oct = shiftn($hdr, $idx++, 1);
   $flag = hex($oct) >> 6;
   printf "STATUS:        %s\n", mapper($flag, 1);
   $flag = hex($oct) & 0x3F;
   printf "FLAGS:         %s", shflags($flag);
   $oct = shiftn($hdr, $idx++, 1);
   printf "DETECT MULT.:  %d (0x%s)\n", hex($oct), $oct;
   $oct = shiftn($hdr, $idx++, 1);
   printf "LENGTH:        %d (0x%s)\n", hex($oct), $oct;
   $oct = shiftn($hdr, $idx++, 4);
   printf "LOCAL DISCR.:  %d (0x%s)\n", hex($oct), $oct;
   $idx+=3; $oct = shiftn($hdr, $idx, 4);
   printf "REMOTE DISCR.: %d (0x%s)\n", hex($oct), $oct;
   $idx+=4; $oct = shiftn($hdr, $idx, 4);
   printf "MIN TX:        %s", shtime($oct);
   $idx+=4; $oct = shiftn($hdr, $idx, 4);
   printf "MIN RX:        %s", shtime($oct);
   $idx+=4; $oct = shiftn($hdr, $idx, 4);
   printf "MIN ECHO RX:   %s", shtime($oct);
}

sub usage {
   return @_ if scalar @_;
   print <<END_USAGE;

Script decodes BFD header hex dump. Only version 1 would be decoded, as version 0 (ieee-draft) is not widely implemented. 
Usage: $0 BFD_header
   BFD_header: Please provide BFD header as a hex string without delimiters. 
               Script is able to remove spaces only if string is provided as single argument.
Example:
   $0 '20 48 03 18 00 00 00 10 00 00 00 00 00 1E 84 80 00 1E 84 80 00 00 00 00'
   $0 20C8031800000012000100020000C3500000C35000000000

END_USAGE
exit 0;
}
