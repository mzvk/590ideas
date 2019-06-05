OLD VERSION OF FUNCTIONS, documented so I can reuse ideas if they will be such necessity.

## str2int 
#### before pack/unpack
```perl
sub str2int {
  my $ip = shift;
  if($ip !~ /^(3[0-2]|[12]?[0-9])$|$IPv4RGX/ ){ print "[ERROR] Not IPv4 address: $ip!\n"; return 0; }
  my @input = split /\./, $ip;
  my $result;
  for my $idx (0 .. $#input) {
    $result += $input[$idx] << (8 * ($#input - $idx));
  }
  return $result;
}
```

## int2str 
#### before pack/unpack
```perl
sub int2str {
  my $input = shift;
  if($input !~ /^[0-9]+$/){ print "[ERROR] Input $input is not a number - return 0!\n"; return 0; }
  if($input > 4294967295){ print "[ERROR] Input $input is larger then 32bits - return 0!\n"; return 0; }
  my @result;
  for my $idx (0 .. 3){push @result, $input >> (8 * (3 - $idx)) & 0xff;}
  return join(".", @result);
}
```

## len2msk
#### before pack/unpack
```perl
sub len2msk {
  my $len = shift;
  if($len !~ /^[0-9]+$/){ print "[ERROR] Mask length $len is not a number - return 0!\n"; return 0; }
  if($len > 32){ print "[ERROR] Mask length cannot be greater then 32 - return 0!\n"; return 0; }
  my $mask;
  for (my $i = 32; $i >= (32 - $len); $i--){ $mask |= (1 << $i); }
  return $mask
}
```

## asnconv
#### before pack/unpack
```perl
sub asnconv {
  my $input = shift // return 0;
  if($input =~ m/^([0-9]{0,5})\.([0-9]{0,5})$/ && ($1 | $2) && $1 < 65536 && $2 < 65536){
    return ($input << 16) + $2;
  } elsif($input =~ m/^[1-9][0-9]{0,9}$/ && $input <= 4294967295){
    return ($input >> 16) . "." . ($input & 0xFFFF)
  } else { print "[ERROR] Wrong ASN number (format or value)!\n"; return 0; }
}
```
