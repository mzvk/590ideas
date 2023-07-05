#!/usr/bin/env perl

## Simple verification of binary search
## Mzvk 2022

use strict;
use warnings;
use v5.14;

my @dataSet = generateDS(500);
binarySearch(\@dataSet, int(rand(200)));

sub binarySearch {
    my ($ds, $target) = @_;
    my ($min, $max, $run) = (0, scalar @dataSet - 1, 0);

    while(1){
        printf "%d -- %d, %d\n", $run++, $min, $max;
        my $nc = int(($min + $max) / 2);
        if($ds->[$nc] == $target) { printf "Target value found on index: %d\n", $nc; last }
        if($max - $min == 1){ say "Target value not found in given data set."; last }
        if($ds->[$nc] < $target) {
            $min = $nc++;
        } else {
            $max = $nc--;
        }
    }
}

sub generateDS {
    my $n = shift;
    my $cntr = 0;
    my (%dataSet, @retDS);
    while(1) {
        my $val = int(rand(1000));
        unless(exists $dataSet{$val}) { $dataSet{$val} = 1; $cntr++; }
        last if $cntr >= $n;
    }
    for (sort { $a <=> $b } keys %dataSet) { push @retDS, $_ }
    return @retDS;
}

