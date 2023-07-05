#!/usr/bin/env perl

use warnings;
use strict;
use v5.14;

say fib_opt(40);
say fib_cls(40);

sub fib_opt {
    my ($n, $buffer) = @_;
    $buffer = {} unless $buffer;
    return $buffer->{$n} if exists $buffer->{$n};
    return 1 if $n <= 2;
    $buffer->{$n} = fib_opt($n -1, $buffer) + fib_opt($n - 2, $buffer);
}

sub fib_cls {
    my $n = shift;
    return 1 if $n <= 2;
    return fib_cls($n - 1) + fib_cls($n - 2);
}
