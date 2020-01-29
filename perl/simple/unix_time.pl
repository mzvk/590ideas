#!/usr/bin/env perl

use strict;
use warnings;
use POSIX qw(strftime);

print "Epoch: ".strftime("%d.%m.%Y %H:%M:%S", localtime($ARGV[0]))."\n";
print "Elapse: ".ptime($ARGV[0])."\n";

sub ptime {
   my $time = shift;
   return int($time/31536000)."y ".($time/86400%365)."d ".($time/3600%24)."h ".($time/60%60)."min ".($time%60)."sec";
}

