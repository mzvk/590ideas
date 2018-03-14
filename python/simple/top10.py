import sys

# Simple Top10 implementation using sort, takes filename as argument
# MZvk 2018

## EXAMPLE FILE CONTENT - IPs are generated
#http://vgsa_node1.pl, 223.227.216.236, 5420
#http://vgsa_node3.pl, 170.205.209.232, 2802
#http://jsux.devnet.pl, 91.243.205.225, 9632
#http://vgsa_node1.pl, 12.242.218.250, 17549
#http://hpna_node2.pl, 150.206.203.252, 10383
#http://vgsa_node3.pl, 222.238.248.208, 5709
#http://vgsa_node1.pl, 54.241.212.226, 6862
#http://vgsa_node3.pl, 99.220.247.218, 9822
#http://jsux.devnet.pl, 126.213.223.201, 13850
#http://hpna_node2.pl, 87.253.225.246, 10376
#http://vgsa_node1.pl, 147.219.242.239, 16544
#http://csux.devnet.pl, 199.227.254.223, 18226
#http://vgsa_node3.pl, 125.207.230.208, 10998
#http://hpna_node2.pl, 217.247.242.207, 6163
#http://hpna_node3.pl, 194.248.201.220, 5694
#http://hpna_node2.pl, 169.206.213.242, 1799
#http://vgsa_node2.pl, 131.224.223.215, 12902
#http://hpna_node3.pl, 78.229.209.201, 17836
#http://csux.devnet.pl, 97.201.219.245, 10402
#http://hpna_node3.pl, 1.223.224.235, 4821
#http://hpna_node3.pl, 192.253.252.220, 13033
#http://hpna_node2.pl, 134.244.205.218, 10535
#http://hpna_node1.pl, 84.201.204.215, 14810
#http://hpna_node1.pl, 211.227.252.234, 13382
#http://hpna_node1.pl, 190.204.249.252, 14676
#http://csux.devnet.pl, 84.206.227.238, 15607
#http://vgsa_node3.pl, 36.230.236.243, 7314
#http://vgsa_node3.pl, 45.222.219.226, 1597
#http://hpna_node1.pl, 157.230.212.243, 11721
#http://hpna_node1.pl, 38.242.211.213, 5267
#http://hpna_node3.pl, 108.236.242.215, 2939
#http://vgsa_node3.pl, 22.246.252.233, 16831
#http://vgsa_node3.pl, 77.231.205.217, 5416
#http://vgsa_node1.pl, 73.237.200.227, 4990
#http://jsux.devnet.pl, 146.235.211.218, 11141
#http://vgsa_node3.pl, 87.240.232.250, 12666
#http://hpna_node2.pl, 209.219.254.202, 18315
#http://vgsa_node3.pl, 188.202.204.230, 11417
#http://jsux.devnet.pl, 97.208.233.245, 13955
#http://vgsa_node3.pl, 105.226.242.226, 13986
#http://csux.devnet.pl, 182.203.243.251, 5396
#http://vgsa_node1.pl, 160.207.240.227, 12346
#http://csux.devnet.pl, 102.246.218.217, 12983
#http://vgsa_node3.pl, 9.230.210.207, 4684
#http://hpna_node2.pl, 173.230.252.242, 10257
#http://csux.devnet.pl, 196.245.232.212, 10142
#http://hpna_node2.pl, 24.237.238.227, 5872
#http://vgsa_node2.pl, 85.249.227.253, 10903
#http://hpna_node1.pl, 13.237.201.223, 5683
#http://hpna_node3.pl, 211.248.212.221, 19228

def top10(filename):
  list = []
  try:
    with open(filename) as file:
      content = file.readlines()
      content = [line.strip() for line in filter(lambda x: len(x.strip()) > 0, content)]
      for line in content:
        value, key = line.strip()[::-1].split(',', 1)
        list.append((key[::-1], value[::-1]))
    file.close()
  except IOError:
    print "[Error]: \"{}\" not found.".format(filename)
  return sorted(list, key = lambda x: int(x[1]), reverse = True)[:10]

if __name__ == "__main__":
  if(len(sys.argv[1:]) > 0):
    data = top10(sys.argv[1])
    print " ### TOP-TALKER ### "
    for value in data:
      print "{:<48}: {} Bytes".format(value[0], value[1])
