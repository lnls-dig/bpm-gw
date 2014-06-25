PLATFORM = lm32

OBJS_COMMON = ../dev/uart.o ../dev/endpoint.o ../dev/minic.o ../dev/pps_gen.o ../dev/syscon.o ../dev/softpll_ng.o ../lib/mprintf.o ../dev/ep_pfilter.o \
           ../dev/dna.o ../dev/i2c.o  ../ptp-noposix/libposix/freestanding-wrapper.o \
           ../ptp-noposix/PTPWRd/dep/msg.o

OBJS_TEST = testtool.o

INCLUDE_DIR = -I../include -I../ptp-noposix/PTPWRd

CROSS_COMPILE ?= lm32-elf-
CFLAGS_PLATFORM  = -mmultiply-enabled -mbarrel-shift-enabled
LDFLAGS_PLATFORM = -mmultiply-enabled -mbarrel-shift-enabled   -nostdlib -T ../target/lm32/ram.ld
OBJS_PLATFORM=../target/lm32/crt0.o ../target/lm32/irq.o

CC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump
CFLAGS= $(CFLAGS_PLATFORM) -ffunction-sections -fdata-sections -Os -include ../include/trace.h  -I../include/ -I../ptp-noposix/libptpnetif -I../ptp-noposix/PTPWRd
LDFLAGS= $(LDFLAGS_PLATFORM) -ffunction-sections -fdata-sections -Os
SIZE = $(CROSS_COMPILE)size

OBJS=$(OBJS_PLATFORM) $(OBJS_COMMON) $(OBJS_TEST)

OUTPUT = testtool

all:    $(OBJS)
		$(SIZE) -t $(OBJS)
		${CC} -o $(OUTPUT).elf $(OBJS) $(LDFLAGS)
		${OBJCOPY} -O binary $(OUTPUT).elf $(OUTPUT).bin

clean:
		rm -f $(OBJS) $(OUTPUT).elf $(OUTPUT).bin

%.o:    %.c
		${CC} $(CFLAGS) -c $^ -o $@

load:
		../tools/lm32-loader $(OUTPUT).bin
