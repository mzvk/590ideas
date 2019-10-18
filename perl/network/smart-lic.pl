#!/usr/bin/env perl

## Script for polling CISCO-SMART-LIC-MIB and peresting data in more appealing format.
## It was created for one purspose, of testing Cisco Smart Licensing and was not intended for prod.
## Because of that, it is hacked together and supports only v2c.
## Mzvk 2019

use v5.10;
use strict;
use warnings;
use Net::SNMP;
use POSIX qw(strftime);

use constant VERBOSE => 0;
use constant MISSING => "\033[31mOBJECT N/A\033[0m";
use constant NULL    => "\033[34mNULL\033[0m";

my %enums = (
   'entenf' => {
      1  => 'INITIALIZED',
      2  => 'WAITING',
      3  => 'AUTHORIZED',
      4  => 'OUT-OF-COMPLIANCE',
      5  => 'OVERAGE',
      6  => 'EVALUATION-PEROID',
      7  => 'EVALUATION-EXPIRED',
      8  => 'GRADE-PEROID',
      9  => 'GRADE-PEROID-EXPIRED',
      10 => 'DISABLED',
      11 => 'INVALID-TAG',
   },
   'regstt' => {
      1 => 'NOT-REGISTERED',
      2 => 'REGISTRATION-IN-PROGRESS',
      3 => 'REGISTRATION-FAILED',
      4 => 'REGISTRATION-RETRY',
      5 => 'REGISTRATION-COMPLETED',
   },
);

my %tempMap = (
   '0.1'       => {var => 'slaiid', type => 's', space => 'sla'},          #ciscoSlaInstanceId
   '0.2'       => {var => 'sudi',   type => 's', space => 'dev'},          #ciscoSlaSUDIInfo
   '0.3'       => {var => 'slaver', type => 's', space => 'sla'},          #ciscoSlaVersion
   '0.4'       => {var => 'slaena', type => 'b', space => 'sla'},          #ciscoSlaEnabled
   '0.5.1.1.1' => {var => 'entidx', type => 's', space => 'ent'},          #ciscoSlaEntitlementInfoIndex   
   '0.5.1.1.2' => {var => 'entrqc', type => 's', space => 'ent'},          #ciscoSlaEntitlementRequestCount
   '0.5.1.1.3' => {var => 'enttag', type => 's', space => 'ent'},          #ciscoSlaEntitlementTag
   '0.5.1.1.4' => {var => 'entver', type => 's', space => 'ent'},          #ciscoSlaEntitlementVersion
   '0.5.1.1.5' => {var => 'entenf', type => 'e', space => 'ent'},          #ciscoSlaEntitlementEnforceMode
   '0.5.1.1.6' => {var => 'entdsc', type => 's', space => 'ent'},          #ciscoSlaEntitlementDescription
   '0.5.1.1.7' => {var => 'entfnm', type => 's', space => 'ent'},          #ciscoSlaEntitlementFeatureName
   '0.6.1'     => {var => 'regstt', type => 'e', space => 'reg'},          #ciscoSlaRegistrationStatus
   '0.6.2'     => {var => 'regvac', type => 's', space => 'reg'},          #ciscoSlaVirtualAccount
   '0.6.3'     => {var => 'regcex', type => 't', space => 'reg'},          #ciscoSlaNextCertificateExpireTime
   '0.6.4'     => {var => 'regeac', type => 's', space => 'reg'},          #ciscoSlaEnterpirseAccountName
   '0.6.5.1'   => {var => 'regini', type => 't', space => 'reg'},          #ciscoSlaRegisterInitTime
   '0.6.5.2'   => {var => 'regsuc', type => 'b', space => 'reg'},          #ciscoSlaRegisterSuccess
   '0.6.5.3'   => {var => 'regfai', type => 's', space => 'reg'},          #ciscoSlaRegisterFailureReason
   '0.6.5.4'   => {var => 'regnex', type => 't', space => 'reg'},          #ciscoSlaRegisterNextRetryTime
   '0.6.6.1'   => {var => 'regrin', type => 't', space => 'reg'},          #ciscoSlaRenewInitTime
   '0.6.6.2'   => {var => 'regrsu', type => 'b', space => 'reg'},          #ciscoSlaRenewSuccess
   '0.6.6.3'   => {var => 'regrfa', type => 's', space => 'reg'},          #ciscoSlaRenewFailureReason
   '0.6.6.4'   => {var => 'regrnr', type => 't', space => 'reg'},          #ciscoSlaRenewNextRetryTime
   '0.7.1'     => {var => 'autexp', type => 't', space => 'aut'},          #ciscoSlaAuthExpireTime
   '0.7.2'     => {var => 'autcst', type => 's', space => 'aut'},          #ciscoSlaAuthComplianceStatus
   '0.7.3'     => {var => 'autooc', type => 't', space => 'aut'},          #ciscoSlaAuthOOCStartTime
   '0.7.4.1'   => {var => 'auteiu', type => 'b', space => 'aut'},          #ciscoSlaAuthEvalPeroidInUse
   '0.7.4.2'   => {var => 'auteex', type => 't', space => 'aut'},          #ciscoSlaAuthEvalExpiredTime
   '0.7.4.3'   => {var => 'autelf', type => 'c', space => 'aut'},          #ciscoSlaAuthEvalPeriodLeft
   '0.7.5.1'   => {var => 'autrin', type => 't', space => 'aut'},          #ciscoSlaAuthRenewInitTime
   '0.7.5.2'   => {var => 'autrsc', type => 'b', space => 'aut'},          #ciscoSlaAuthRenewSuccess
   '0.7.5.3'   => {var => 'autrfl', type => 's', space => 'aut'},          #ciscoSlaAuthRenewFailureReason
   '0.7.5.4'   => {var => 'autrnx', type => 't', space => 'aut'},          #ciscoSlaAuthRenewNextRetryTime
   '0.8.1'     => {var => 'ntfglb', type => 'b', space => 'ntf'},          #ciscoSlaGlobalNotifEnable 
   '0.8.2'     => {var => 'ntfent', type => 'b', space => 'ntf'},          #ciscoSlaEntitlementNotifEnable
);
my %OIDs = ("SL-MIB" => '1.3.6.1.4.1.9.9.831');
my $tw = `tput cols`;
$tw = $tw ? $tw : 20;

die "Error: No arguments, need IP and community string.\n" if !scalar @ARGV;
die "Error: Bad IP format.\n" if !($ARGV[0] =~ m/^(?:(?=((?:25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\.))\1){3}(?:25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$/);

my ($session, $error) = Net::SNMP->session(-hostname => $ARGV[0], -community => $ARGV[1], -version => '2', -timeout => 1,);
die "Error: ".$error."\n" if !defined $session;
my $result = $session->get_table($OIDs{"SL-MIB"});
die "Error: ".$session->error()."\n" if !$result;

#idiom Schwarzego#
my @sorted =
    map { $_->[0] }
    sort { $a->[1] cmp $b->[1] }
    map { [$_, join '', map { sprintf "%8d", $_ } split /\./, $_] }
    keys %{$result};

my %sla;
for my $oid (@sorted){
   my $suboid = $oid =~ s/^1\.3\.6\.1\.4\.1\.9\.9\.831\.//r;
   $suboid =~ m/^(.*)\.([0-9]+)$/g;
   if(exists $tempMap{$1} && ref $tempMap{$1} eq ref {}){
      if($tempMap{$1}{type} eq 'b') { $result->{$oid} = $result->{$oid} ? 'TRUE' : 'FALSE'}
      if($tempMap{$1}{type} eq 'e') { $result->{$oid} = $enums{$tempMap{$1}{var}}{$result->{$oid}} }
      if($tempMap{$1}{type} eq 't') { $result->{$oid} = $result->{$oid} ? strftime("%d.%m.%Y %H:%M:%S", localtime($result->{$oid})) : '--'};
      if($tempMap{$1}{type} eq 'c') { $result->{$oid} = $result->{$oid} ? ptime($result->{$oid}) : "EXPIRED"};
      if($2 > 0){
         if(! exists $sla{$tempMap{$1}{space}}){$sla{$tempMap{$1}{space}} = []}
         if(scalar @{$sla{$tempMap{$1}{space}}} < $2){push @{$sla{$tempMap{$1}{space}}}, {}}
         $sla{$tempMap{$1}{space}}[$2-1]{$tempMap{$1}{var}} = $result->{$oid} if exists $tempMap{$1}{var};
      } else {
         $sla{$tempMap{$1}{space}}{$tempMap{$1}{var}} = $result->{$oid} if exists $tempMap{$1}{var};
      }
   }
   else { say "[error] OID ".$oid." was not found in CISCO-SMART-LIC-MIB mapping" if VERBOSE; }
}
say "\033[36m+"."-"x($tw-2)."+\033[0m";
say ptitle('Device Information', $tw);
say "\033[36m+"."-"x($tw-2)."+\033[0m";
say "Device Session Address:          ".$ARGV[0];
say "Device Poll Status:              ".(exists $sla{sla}?'TRUE':'FALSE');
say "Secure Unique Device Identifier: ".$sla{dev}{sudi};
if(exists $sla{sla}){
   say "\033[36m+"."-"x($tw-2)."+\033[0m";
   say ptitle('Smart License Information', $tw);
   say "\033[36m+"."-"x($tw-2)."+\033[0m";   
   say "SmartLicense Enabled:            ".$sla{sla}{slaena};
   say "SmartLicense Instance ID:        ".$sla{sla}{slaiid};
   say "SmartLicense Version:            ".$sla{sla}{slaver};
}
if(exists $sla{ent}){
   say "\033[36m+"."-"x($tw-2)."+\033[0m";
   say ptitle('Smart License Entitlement', $tw);
   say "\033[36m+"."-"x($tw-2)."+\033[0m";
   for my $entit (@{$sla{ent}}){
      say ptitle('ENTITLEMENT ENTRY', $tw, 1);
      say "Entitlement Info Index:          ".(exists $entit->{entidx}?$entit->{entidx}:MISSING);
      say "Entitlement Tag:                 ".$entit->{enttag};
      say "Entitlement Description:         ".ifnull($entit->{entdsc});
      say "Entitlement Feature Name:        ".ifnull($entit->{entfnm});
      say "Entitlement Request Count:       ".$entit->{entrqc};
      say "Entitlement Version:             ".$entit->{entver};
      say "Entitlement Enforcement Mode:    ".$entit->{entenf};
   }
}
if(exists $sla{reg}){
   say "\033[36m+"."-"x($tw-2)."+\033[0m";
   say ptitle('Smart License Registration', $tw);
   say "\033[36m+"."-"x($tw-2)."+\033[0m";   
   say "Registration Status:             ".$sla{reg}{regstt};
   say "Registration Virtual Account:    ".ifnull($sla{reg}{regvac});
   say "Registration Enterprise Account: ".ifnull($sla{reg}{regeac});
   say "Registration Cerificate Expire:  ".ifnull($sla{reg}{regcex});
   if($sla{reg}{regstt} eq "REGISTRATION-COMPLETED"){
      say ptitle('REGISTRATION', $tw, 1);
      say "Registration Init Time:          ".$sla{reg}{regini};
      say "Registration Success:            ".$sla{reg}{regsuc};
      say "Registration Last Failure:       ".($sla{reg}{regfai}?$sla{reg}{regfai}:NULL);
      say "Registration Next Retry:         ".$sla{reg}{regnex};
      say ptitle('RENEWAL', $tw, 1);             
      say "Renewal Init Time:               ".($sla{reg}{regrin}?$sla{reg}{regrin}:NULL);
      say "Renewal Success:                 ".$sla{reg}{regrsu};
      say "Renewal Last Failure:            ".($sla{reg}{regrfa}?$sla{reg}{regrfa}:NULL);
      say "Renewal Next Retry:              ".$sla{reg}{regrnr};
   }
}
if(exists $sla{aut}){
   say "\033[36m+"."-"x($tw-2)."+\033[0m";
   say ptitle('Smart License Authorization', $tw);
   say "\033[36m+"."-"x($tw-2)."+\033[0m";   
   say "Authorization Expire:            ".$sla{aut}{autexp};
   say "Authorization Compliance Status: ".$sla{aut}{autcst};
   say "Authorization OOC Init:          ".$sla{aut}{autooc};
   if($sla{aut}{autcst} ne 'EVAL MODE'){
      say ptitle('RENEWAL', $tw, 1);             
      say "Authorization Renewal Init:      ".$sla{aut}{autrin};
      say "Authorization Renewal Success:   ".$sla{aut}{autrsc};
      say "Authorization Renewal Failure:   ".($sla{aut}{autrfl}?$sla{aut}{autrfl}:NULL);
      say "Authorization Renewal Next:      ".$sla{aut}{autrnx};
   }
   say ptitle('EVALUTION LICENSE', $tw, 1);             
   say "Authorization Eval In Use:       ".$sla{aut}{auteiu};
   say "Authorization Eval Expire:       ".$sla{aut}{auteex};
   say "Authorization Eval Left:         ".$sla{aut}{autelf};
}
say "\033[36m+"."-"x($tw-2)."+\033[0m";
say ptitle('Smart License Notifications', $tw);
say "\033[36m+"."-"x($tw-2)."+\033[0m";
say "Global Notif. Enabled:           ".$sla{ntf}{ntfglb};
say "Entitlement Notif. Enabled:      ".$sla{ntf}{ntfent};


sub ptime {
   my $time = shift;
   return int($time/86400)."d ".($time/3600%24)."h ".($time/60%60)."min ".($time%60)."sec";
}

sub ptitle {
   my $title = shift;
   my $tw = shift;
   my $type = shift // 0;
   my $apad = ($tw - length($title)) % 2 ? 1 : 0;
   my $pad = ($tw - length($title) - 2) / 2;
   return $type ? "\033[36m".('-'x$pad)."[\033[37m".$title."\033[36m]".('-'x($pad+$apad))."\033[0m" : "\033[36m|".(' 'x$pad)."\033[37m".$title."\033[36m".(' 'x($pad+$apad))."|\033[0m";
}

sub ifnull {
   my $value = shift // MISSING;
   return $value ? $value : NULL;
}
