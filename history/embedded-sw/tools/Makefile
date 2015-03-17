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

all: genraminit genramvhd genrampdata

genraminit: genraminit.o
				${CC} -o genraminit genraminit.o

genramvhd: genramvhd.o
				${CC} -o genramvhd genramvhd.o

genrampdata: genrampdata.o
				${CC} -o genrampdata genrampdata.o

%.o: 		%.c
				${CC} -c $^ $(CFLAGS) -O0

clean:
	rm -f genraminit genramvhd genrampdata *.o
