package utils;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(str2int int2str msk2len);

sub str2int {
  my @input = split /\./, shift;
  my $result;
  for my $idx (0 .. $#input) {$result += $input[$idx] << (8 * ($#input - $idx));}
  return $result;
}

sub int2str {
  my $input = shift;
  if($input !~ /^[0-9]+$/){
    print "[ERROR] Input $input is not a number - return 0!\n";
    return 0;
  }
  my @result;
  for my $idx (0 .. 3){push @result, $input >> (8 * (3 - $idx)) & 0xff;}
  return join(".", @result);
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
}

1;
