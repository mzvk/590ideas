OLD VERSION OF FUNCTIONS, documented for so I can reuse ideas if they will be such necessity.

## str2int 
#### before pack/unpack
```
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
```
sub int2str {
  my $input = shift;
  if($input !~ /^[0-9]+$/){ print "[ERROR] Input $input is not a number - return 0!\n"; return 0; }
  if($input > 4294967295){ print "[ERROR] Input $input is larger then 32bits - return 0!\n"; return 0; }
  my @result;
  for my $idx (0 .. 3){push @result, $input >> (8 * (3 - $idx)) & 0xff;}
  return join(".", @result);
}
```
