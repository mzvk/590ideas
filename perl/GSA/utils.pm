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

