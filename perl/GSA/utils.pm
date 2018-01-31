package utils;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(str2int int2str msk2len);

my $IPv4RGX = '^(?:(?>25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\.){3}(?>25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$';

sub str2int {
  my $ip = shift;
  if($ip !~ /^(3[0-2]|[12]?[0-9])$|$IPv4RGX/ ){ print "[ERROR] Not IPv4 address: $ip!\n"; return 0; }
  return unpack ('N', pack ('C4', split /\./, $ip));
}

sub int2str {
  my $input = shift;
  if($input !~ /^[0-9]+$/){ print "[ERROR] Input $input is not a number - return 0!\n"; return 0; }
  my @result;
  for my $idx (0 .. 3){push @result, $input >> (8 * (3 - $idx)) & 0xff;}
  return join(".", @result);
#  return join ".", unpack 'C4', pack 'N', $input;
}

sub msk2len {
  my $mask = str2int(shift);
  my ($len, $cont);
  for my $idx (0 .. 31){
    if((($mask >> $idx) & 0x1) == 0 && !defined($cont)){$len++;}
    elsif((($mask >> $idx) & 0x1) == 0 && defined($cont)){return "- incorrect mask -";}
    else {$cont = 1;}
  }
  return defined $len ? 32 - $len : 32;
}

sub len2msk {
  my $len = shift;
  if($len !~ /^[0-9]+$/){
    print "[ERROR] Mask length $len is not a number - return 0!\n";
    return 0;
  }
  my $mask;
  for (my $i = 32; $i >= (32 - $len); $i--){ $mask |= (1 << $i); }
  return $mask
#  return 2**32 - 2**(32 - $len);
}

1;
