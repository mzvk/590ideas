#include <stdio.h>

int main (void)
{
  __uint32_t word = 0x12345678;
  char *pointer = (char *) &word;

  if (*pointer == 0x78){
    printf("Byte order is Little Endian.\n");
  } else {
    printf("Byte order is Big Endian.\n");
  }
}
