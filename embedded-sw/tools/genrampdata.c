#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	if (argc < 3)
		return -1;

	int i = 0;
	int n_out = atoi(argv[1]);
	int n_words = atoi(argv[2]);

	if (n_words > n_out)
		n_words = n_out;

	while (i < n_words) {
		printf("write %x %08X\n", i, (unsigned) i);
		i++;
	}

	for (; i < n_out;) {
		printf("write %x %02X%02X%02X%02X\n", i++, 0, 0, 0, 0);
	}

	return 0;
}

