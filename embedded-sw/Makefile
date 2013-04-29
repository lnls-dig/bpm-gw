# choose your board here.
BOARD = ml605

# some configurations
CONFIG_PPRINTF =? 1

#ifeq ($(CONFIG_PPRINTF),1)
	#CONFIG_PRINT_BUFSIZE = 200
#endif

CONFIG_ETHERBONE =? 1
CONFIG_FMC150 ?= 0
CONFIG_FMC516 ?= 0

# and don't touch the rest unless you know what you're doing.
CROSS_COMPILE ?= lm32-elf-

CC =		$(CROSS_COMPILE)gcc
LD =		$(CROSS_COMPILE)ld
OBJDUMP =	$(CROSS_COMPILE)objdump
OBJCOPY =	$(CROSS_COMPILE)objcopy
SIZE =		$(CROSS_COMPILE)size

-include $(CURDIR)/.config

OBJS_DBE = dbe_main.o
#OBJS_DBE = dbe_main_test.o

INCLUDE_DIRS = -Iinclude   \
		-Iinclude/memmgr \
		-Iinclude/fmc/fmc150 \
		-Iinclude/fmc/fmc516  \
		-I$(CURDIR)/pp_printf	\
		-I$(CURDIR)/lib	\
		-I$(CURDIR)/lib/ethmac

CFLAGS = -Wall
#-include $(CURDIR)/include/generated/autoconf.h

CFLAGS_MEMMGR = -DDEBUG_MEMMGR_FATAL=1 \
	-DDEBUG_MEMMGR_SUPPORT_STATS=1 \
	-DPOOL_SIZE=2048

CFLAGS_DEBUG = -DDBE_DBG=1

CFLAGS_PLATFORM  = -mmultiply-enabled -mbarrel-shift-enabled
LDFLAGS_PLATFORM = -mmultiply-enabled -mbarrel-shift-enabled \
	-nostdlib -T arch/lm32/ram.ld

OBJS_PLATFORM = arch/lm32/crt0.o arch/lm32/irq.o arch/lm32/debug.o

include lib/lib.mk
include dev/dev.mk
include pp_printf/printf.mk
include boards/boards.mk
include fmc/fmc.mk

CFLAGS += $(CFLAGS_PLATFORM) $(CFLAGS_EB) $(INCLUDE_DIRS) \
	$(CFLAGS_MEMMGR) $(CFLAGS_DEBUG) -ffunction-sections -fdata-sections \
	-Os

LDFLAGS = $(LDFLAGS_PLATFORM) \
	-ffunction-sections -fdata-sections -Wl,--gc-sections -Os -Iinclude

OBJS = $(OBJS_PLATFORM) $(OBJS_DBE) \
	$(OBJS_SHELL) $(OBJS_TESTS) $(OBJS_LIB) \
	$(OBJS_DEV) $(OBJS_BOARD) $(OBJS_FMC)

OUTPUT = dbe
#OUTPUT = dbe_test

REVISION=$(shell git describe --dirty --always)

all: tools $(OUTPUT).ram $(OUTPUT).vhd

.PHONY: all tools clean

$(OUTPUT).elf: $(OBJS)
	$(CC) $(CFLAGS) -DGIT_REVISION=\"$(REVISION)\" -c revision.c
	$(SIZE) -t $(OBJS)
	${CC} -o $@ revision.o $(OBJS) $(LDFLAGS)
	${OBJDUMP} -d $(OUTPUT).elf > $(OUTPUT)_disasm.S
	$(SIZE) $@

%.bin: %.elf
	${OBJCOPY} -O binary $^ $@

%.ram: tools %.bin
	./tools/genraminit $*.bin 0 > $@

%.vhd: tools %.bin
	./tools/genramvhd -s 131072 $*.bin > $@

$(OBJS): include/board.h

include/board.h:
	ln -sf ../boards/$(BOARD)/board.h include/board.h

clean:
	rm -f $(OBJS) $(OUTPUT).elf $(OUTPUT).bin $(OUTPUT).ram $(OUTPUT)_disasm.S $(OUTPUT).vhd include/board.h
	make clean -C tools

%.o: %.c
	${CC} $(CFLAGS) $(INCLUDE_DIRS) $(LIB_DIR) -c $*.c -o $@

tools:
	$(MAKE) -C tools
