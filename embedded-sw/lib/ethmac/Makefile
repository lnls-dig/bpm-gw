#Kept for reference. Makefile from upstream (lm32 ohwr respository)

CC	= lm32-elf-gcc
CFLAGS	= -Wall -Os -g -mmultiply-enabled -mbarrel-shift-enabled -mdivide-enabled -msign-extend-enabled -ffunction-sections

TARGETS=etherbone

all:	$(TARGETS)

clean:
	rm -f *.o $(TARGETS)

etherbone:	etherbone.c ethmac.c ethmac-int.c int.c cpu-utils.c ../crt0ram.o
	$(CC) $(CFLAGS) -T ../linker.ld -o $@ $^

ethmac-tx:	ethmac-tx.c ethmac.c ethmac-int.c int.c cpu-utils.c ../crt0ram.o
	$(CC) $(CFLAGS) -T ../linker.ld -o $@ $^

ethmac-rx:	ethmac-rx.c ethmac.c ethmac-int.c int.c cpu-utils.c ../crt0ram.o
	$(CC) $(CFLAGS) -T ../linker.ld -o $@ $^

ethmac-rxtx:	ethmac-rxtx.c ethmac.c ethmac-int.c int.c cpu-utils.c ../crt0ram.o
	$(CC) $(CFLAGS) -T ../linker.ld -o $@ $^
