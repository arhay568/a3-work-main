/* Complete the C version of the driver program for mystery. This C code does
 * not need to compile. */

#include <stdio.h>
#include <stdlib.h>

extern long crunch(long, long);

int main(int argc, char *argv[]) {
  if (argc != 3) {
    puts("Two arguments required.");
    return 1;
  }

  long a = atol(argv[1]);
  long b = atol(argv[2]);

  long result = crunch(a, b);

  if (result < 0) {
    puts("hat");
  } else if (result == 0) {
    puts("tea");
  } else {
    puts("beer");
  }

  return 0;
}