#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

argsSanity();
printf "Number of possible routes in %d x %d grid is %d\n", $ARGV[0], $ARGV[1], goGrid($ARGV[0], $ARGV[1]);

sub goGrid {
    my ($x, $y, $mem) = @_;
    $mem = {} if !defined $mem;
    my $key = sprintf("%d_%d", $x, $y);
    return 0 unless $x * $y;
    return 1 if $x * $y == 1;
    return $mem->{$key} if exists $mem->{$key};
    $mem->{$key} = goGrid($x - 1, $y, $mem) + goGrid($x, $y - 1, $mem);
    return $mem->{$key};
}

sub argsSanity {
    die "Script accepts only two numeric values: number of rows and columns.\n" unless scalar @ARGV == 2;
    die "Number of rows provided [$ARGV[0]] is not a numeric value.\n" unless $ARGV[0] =~ m/^[0-9]+$/;
    die "Number of columns provided [$ARGV[1]] is not a numeric value.\n" unless $ARGV[1] =~ m/^[0-9]+$/;
    die "Number of possible routes would exceed 64bit integer, I cannot allow that ;)\n" if $ARGV[0] + $ARGV[1] >= 69
}
