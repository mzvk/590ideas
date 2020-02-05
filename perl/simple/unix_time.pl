#!/usr/bin/env perl

use strict;
use warnings;
use POSIX qw(strftime);

die "No UNIX time provided.\n" if @ARGV < 1;

for my $time (@ARGV) {
   if($time !~ m/^[0-9]+$/) { print "ERROR: UNIX time must be numeric value (\033[31m".$time."\033[0m => NaN).\n"; next }
   print "UNIX: ".$time."\n";
   print "Epoch: ".strftime("%d.%m.%Y %H:%M:%S", localtime($time))."\n";
   print "Elapse: ".ptime($time)."\n\n";
}

sub ptime {
   my $time = shift;
   return int($time/31536000)."y ".($time/86400%365)."d ".($time/3600%24)."h ".($time/60%60)."min ".($time%60)."sec";
}
