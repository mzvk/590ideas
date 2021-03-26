package utils;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(str2int int2str msk2len len2msk asnconv);

my $IPv4RGX = '^(?:(?>25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\.){3}(?>25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$';

sub asnconv {
  my $input = shift // return -1;
  if($input =~ m/^([0-9]{0,5})\.([0-9]{0,5})$/ && ($1 | $2) && $1 < 65536 && $2 < 65536){
    return unpack 'N', pack 'n2', split /\./, $input;
  } elsif($input =~ m/^[1-9][0-9]{0,9}$/ && $input <= 4294967295){
    return join ".", unpack "n2", pack "N", $input;
  } else { print "[ERROR] Wrong ASN number (format or value)!\n"; return -1; }
}

sub str2int {
  my $ip = shift // return -1;
  if($ip !~ /^(3[0-2]|[12]?[0-9])$|$IPv4RGX/ ){ print "[ERROR] Not IPv4 address: $ip!\n"; return -1; }
  return unpack ('N', pack ('C4', split /\./, $ip));
}

sub int2str {
  my $input = shift // return -1;
  if($input !~ /^[0-9]+$/){ print "[ERROR] Input $input is not a number - return 0!\n"; return -1; }
  if($input > 4294967295){ print "[ERROR] Input $input is larger than 32bits - return 0!\n"; return -1; }
  return join ".", unpack 'C4', pack 'N', $input;
}

sub msk2len {
   my $len = shift // return -1;
   for (reverse 0..32) { 
      return $_ if $mask & 0x1;
      $mask >>= 1;
   }
   return -1;
}

sub len2msk {
  my $len = shift // return -1;
  if($len !~ /^[0-9]+$/){ print "[ERROR] Mask length $len is not a number - return 0!\n"; return -1; }
  if($len > 32){ print "[ERROR] Mask length cannot be greater then 32 - return 0!\n"; return -1; }
  return join ".", unpack 'C4', pack 'N', 2**32 - 2**(32 - $len);
}

1;
