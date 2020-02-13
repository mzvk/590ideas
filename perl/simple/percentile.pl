#!/usr/bin/env perl

## Calculates any percentile for the given data set
## using 8 different methods
## Mzvk 2020

use warnings;
use strict;

my $percentile;
my @data_set;
my @methods = (['Weighted Avarage at X[np]', \&waxn], ['Weighted Avarage at X[(n+1)p]', \&waxnp], ['Empirical Distribution Function', \&edf],
               ['Empirical Distribution Function - Averaging', \&edfa], ['Empirical Distribution Function - Interpolation', \&edfi], 
               ['Closest Observation', \&co], ['TrueBasic - Statistics Graphics Toolkit', \&sgt], ['MS Excel (Old)', \&mse]);

if(@ARGV){
   die "Percentile must be integer from range 1-99.\n" if $ARGV[0] !~ m/^([1-9]|[1-9][0-9])$/;
   @data_set = split ',', $ARGV[1] if $ARGV[1] =~ m/^[0-9]+(,[0-9]+){2,}$/;
   $percentile = $ARGV[0];
} else { $percentile = 75; }
if(!@data_set) { @data_set = genset(30); }
@data_set = sort @data_set;

printf "DATA SET: [%s]\n\n", join(', ', @data_set);
for my $method (@methods){
   printf "#### %s\n%dTH PERCENTILE OF DATA SET: %s\n\n", uc $method->[0], $percentile, $method->[1]();
}

sub genset {
   return map { int(rand(100)) } ( 1..shift );
}

sub indexing {
   my $offset = shift // 0;
   my $shift = shift // 0;
   my $i = (scalar @data_set + $offset) * $percentile/100 + $shift;
   $i = scalar @data_set - 1 if $i >= scalar @data_set;
   return ($i - int($i), int($i));
}

sub waxn {
   (my $f, my $i) = indexing();
   return (1 - $f) * $data_set[$i-1] + $f * $data_set[$i];
}

sub waxnp {
   (my $f, my $i) = indexing(1);
   return (1 - $f) * $data_set[$i-1] + $f * $data_set[$i];
}

sub edf {
   (my $f, my $i) = indexing();
   return $f ? $data_set[$i] : $data_set[$i-1];
}

sub edfa {
   (my $f, my $i) = indexing();
   return $f ? $data_set[$i] : ($data_set[$i] + $data_set[$i-1])/2;
}

sub edfi {
   (my $f, my $i) = indexing(-1);
   return $f ? ($data_set[$i] + $f * ($data_set[$i+1] - $data_set[$i])) : $data_set[$i];
}

sub co {
   (my $f, my $i) = indexing(0, 0.5);
   return $data_set[$i-1];
}

sub sgt {
   (my $f, my $i) = indexing(1);
   return $f ? $f * $data_set[$i-1] + (1-$f) * $data_set[$i] : $data_set[$i-1];
}

sub mse {
   (my $f, my $i) = indexing(1);
   return $data_set[$i-1] if $f < 0.5;
   return ($data_set[$i] + $data_set[$i-1])/2 if $f == 5;
   return $data_set[$i];
}
