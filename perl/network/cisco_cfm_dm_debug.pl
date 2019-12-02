#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use Data::Dumper;

my $texp = 0;
my $sref = 0;
my @mamd;
my @mamj;
my $count = 0;
my %errors;
my $errorstamp;

die "USAGE: $0 <debug_file>\nOnly one file is read, others are ignored.\n" if $#ARGV < 0;
readfile($ARGV[0]);
print "\033[15;0H";

say "Detected Errors:";
for my $err (keys %errors){
   say $err;
   for my $line (@{$errors{$err}}){
      say " - ".$line;
   }
}

sub readfile {
   my $max;
   my $min;
   open(FILE, '<', $_[0]) || die say "[Error] Cannot open file!: $!";
   print "\033[2J\033[H\n";
   while(<FILE>){
      chomp;
      next if length $_ < 37;
      my $line = substr($_, 37);
      my $date = substr($line, 0, 23);
      $line =~ m/ EPM-MONITOR\(session ID: [0-9]+\) T\[c\] = ([0-9]+) T\[p\] = ([0-9]+) aggregated for max_data [0-9]+ wrap [01] set zero [01] ((?:(?:\b[0-9]+:[0-9]+\b ){7})[0-9]+:[0-9]+)/;
      if(defined $3){
         my @data = split / /, $3;
         timestamp(\@data, ndate($date), $1, $2);
         $texp = $texp < 4 ? $texp+1 : 0;
         $count++;
      }
   }
}

sub timestamp {
   my $data = shift;
   my $date = shift;
   my $tcn = shift;
   my $tpn = shift;
   my $ctr = 0;
   my $rtt, my $ptt;
   $errorstamp = $date;
   for my $el (@{$data}){
      my @tmp = split ':', $el;
      $data->[$ctr] = [];
      push @{$data->[$ctr]}, @tmp;
      $ctr++;
   }
   $rtt = tdiff($data->[0], $data->[3]);
   $ptt = tdiff($data->[2], $data->[1]);
   if($rtt < 0 || $ptt < 0) {
      push @{$errors{$errorstamp}}, "\033[31mPrevious Timestamps incorrect - ".($rtt < 0 ? "Roundtrip Time" : "Processing Time")."\033[0m";
      return;
   }
   my $pframe = tdiff($ptt, $rtt);

   $rtt = tdiff($data->[4], $data->[7]);
   $ptt = tdiff($data->[6], $data->[5]);
   if($rtt < 0 || $ptt < 0) {
      push @{$errors{$errorstamp}}, "\033[31mCurrent Timestamps incorrect - ".($rtt < 0 ? "Roundtrip Time" : "Processing Time")."\033[0m";
      return;
   }
   my $cframe = tdiff($ptt, $rtt);   
   if($pframe < 0 || $cframe < 0){
      push @{$errors{$errorstamp}}, "\033[31mCalculated Delay is negative - ".($pframe < 0 ? "Previous timestamps" : "Current timestamps")."\033[0m";
      return;
   }
   my $jitter = tjitter($pframe, $cframe);
   $mamd[0] = compare($mamd[0], $cframe, 'min');
   $mamd[1] = compare($mamd[1], $cframe, 'avg');
   $mamd[2] = compare($mamd[2], $cframe, 'max');   

   $mamj[0] = compare($mamj[0], $jitter, 'min');
   $mamj[1] = compare($mamj[1], $jitter, 'avg');
   $mamj[2] = compare($mamj[2], $jitter, 'max');
   
   printf("\033[H Timestamp: %s\n", $date);
   printf("                 Tc id: %2d           Tp id: %2d\n", $1, $2);
   printf(" TxTimeStampf: %12d:%12d %12d:%12d\n", $data->[0]->[0], $data->[0]->[1], $data->[4]->[0], $data->[4]->[1]);
   printf(" RxTimeStampf: %12d:%12d %12d:%12d\n", $data->[2]->[0], $data->[2]->[1], $data->[6]->[0], $data->[6]->[1]);
   printf(" TxTimeStampb: %12d:%12d %12d:%12d\n", $data->[1]->[0], $data->[1]->[1], $data->[5]->[0], $data->[5]->[1]);
   printf(" TxTimeStampb: %12d:%12d %12d:%12d\n", $data->[3]->[0], $data->[3]->[1], $data->[7]->[0], $data->[7]->[1]);
   printf(" Delay:        %12d:%12d %12d:%12d\n", $cframe->[0], $cframe->[1], $pframe->[1], $pframe->[1]);
   printf(" Jitter:       %12d:%12d\n", $jitter->[0], $jitter->[1]);
   printf("\n Delay  Min/Avg/Max: %9d:%9d / %9d:%9d / %9d:%9d\n", $mamd[0]->[0], $mamd[0]->[1], $mamd[1]->[0], $mamd[1]->[1], $mamd[2]->[0], $mamd[2]->[1]);
   printf(" Jitter Min/Avg/Max: %9d:%9d / %9d:%9d / %9d:%9d\n", $mamj[0]->[0], $mamj[0]->[1], $mamj[1]->[0], $mamj[1]->[1], $mamj[2]->[0], $mamj[2]->[1]);

   select(undef, undef, undef, 0.1);
}

sub tjitter {
   my $tp = shift;
   my $tc = shift;
   return tdiff($tp, $tc) > 0 ? tdiff($tp, $tc) : tdiff($tc, $tp);
}

sub tdiff {
   my $tx = shift;
   my $rx = shift;
   my $_sec = ($rx->[0] - $tx->[0]);
   if($_sec < 0){
      my $tmp = tdiff($rx, $tx);
      push @{$errors{$errorstamp}}, "Rx timestamp is before Tx by: ".$tmp->[0]."Sec ".$tmp->[1]."nSec !!";
      return -1;
   }
   if($rx->[1] < $tx->[1]) {
      if($_sec < 1) {
         return $rx->[1] - $tx->[1];
      }
      $_sec--;
      $rx->[1] += 1000000000;
   }
   my $nsec = ($rx->[1] - $tx->[1]);
   return [$_sec, $nsec];
}

sub ndate {
   my $date = shift;
   $date =~ m/([A-Z][a-z]{2})  ([0-9]+) ([0-9]{2}):([0-9]{2}):([0-9]{2})\.([0-9]{3}) (.*)/;

   my $tz   = $7;
   my $msec = $6;
   my $sec  = $5;
   my $min  = $4;
   my $h    = $3;
   my $d    = $2;
   my $m    = $1;

   if($sref != $sec){ $sref = $sec; $texp = 0 }
   if($sec + $texp > 59) {
      $sec = ($sec + $texp) % 60;
      $min++;
      if($min > 59) { $min %= 60; $h++ }
      if($h > 23) { $h %= 24; $d++ }
   } else { $sec += $texp }

   return sprintf("%02d:%02d:%02d.%03d %3s %02d %3s", $h, $min, $sec, $msec, $tz, $d, $m);
}

sub compare {
   my $value1 = shift;
   my $value2 = shift;
   my $type = shift;

   $value1 = $value2 if ! defined $value1;
   if($type eq 'max') {
      if($value2->[0] > $value1->[0]) { return $value2; }
      if($value2->[0] == $value1->[0] && $value2->[1] > $value1->[1]) { return $value2; }
   }
   elsif($type eq 'min') {
      if($value2->[0] < $value1->[0]) { return $value2; }
      if($value2->[0] == $value1->[0] && $value2->[1] < $value1->[1]) { return $value2; }
   }
   elsif($type eq 'avg') {
#      my $tmp = int((($value2->[0] * 1000000000) + $value2->[1]) + $count * (($value1->[0] * 1000000000) + $value1->[1]))/($count+1);
      my $tmp = int($value1->[0] * 1000000000 + $value1->[1]) + (($value2->[0] * 1000000000 + $value2->[1]) - ($value1->[0] * 1000000000 + $value1->[1]))/($count+1);
      $value1->[0] = int($tmp / 1000000000);
      $value1->[1] = $tmp % 1000000000;
   }
   return $value1;
}
