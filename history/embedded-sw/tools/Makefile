CFLAGS = -Wall -ggdb -I. -I../include

AS		= as
LD		= ld
CC		= gcc
CPP		= $(CC) -E
AR		= ar
NM		= nm
STRIP		= strip
OBJCOPY		= objcopy
OBJDUMP		= objdump

all: genraminit genramvhd

genraminit: genraminit.o
				${CC} -o genraminit genraminit.o

genramvhd: genramvhd.o
				${CC} -o genramvhd genramvhd.o

%.o: 		%.c
				${CC} -c $^ $(CFLAGS) -O0

clean:
	rm -f genraminit genramvhd *.o
