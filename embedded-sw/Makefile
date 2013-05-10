# Autodependencies generatation by Scott McPeak, November 2001,
# from article "Autodependencies with GNU make"

# Choose your board here.
BOARD = ml605

# Some configurations
CONFIG_PPRINTF =? 1

#ifeq ($(CONFIG_PPRINTF),1)
	#CONFIG_PRINT_BUFSIZE = 200
#endif

CONFIG_ETHERBONE =? 1
CONFIG_FMC150 ?= 0
CONFIG_FMC516 ?= 0

# Don't touch the rest unless you know what you're doing.
CROSS_COMPILE ?= lm32-elf-

CC =		$(CROSS_COMPILE)gcc
LD =		$(CROSS_COMPILE)ld
OBJDUMP =	$(CROSS_COMPILE)objdump
OBJCOPY =	$(CROSS_COMPILE)objcopy
SIZE =		$(CROSS_COMPILE)size
AR =		$(CROSS_COMPILE)ar

-include $(CURDIR)/.config

TOPDIR=.

OBJS_DBE = dbe_lwip.o
#OBJS_DBE = dbe_main.o
#OBJS_DBE = dbe_main_test.o

INCLUDE_DIRS = -Iinclude   \
		-Ipp_printf	\
		-Ilib

CFLAGS = -Wall
#-include $(CURDIR)/include/generated/autoconf.h

CFLAGS_MEMMGR = -DDEBUG_MEMMGR_FATAL=1 \
	-DDEBUG_MEMMGR_SUPPORT_STATS=1 \
	-DPOOL_SIZE=2048

CFLAGS_DEBUG = -DDBE_DBG=1 -DLWIP_DEBUG=1

CFLAGS_PLATFORM  = -mmultiply-enabled -mbarrel-shift-enabled
#LDFLAGS_PLATFORM = -mmultiply-enabled -mbarrel-shift-enabled \
#	-nostdlib -T arch/lm32/ram.ld
LDFLAGS_PLATFORM = -mmultiply-enabled -mbarrel-shift-enabled \
	-nostdlib -T arch/lm32/ram.ld

#LIBS = -llwip4
#LIB_DIRS = lib/lwip
#LFLAGS = $(addprefix -L,$(LIB_DIRS))

OBJS_PLATFORM = arch/lm32/crt0.o arch/lm32/irq.o arch/lm32/debug.o

include lib/lib.mk
include dev/dev.mk
include pp_printf/printf.mk
include boards/boards.mk
include fmc/fmc.mk

CFLAGS += $(CFLAGS_PLATFORM) $(CFLAGS_EB) $(INCLUDE_DIRS) \
	$(CFLAGS_MEMMGR) $(CFLAGS_DEBUG) $(CFLAGS_LWIP) -ffunction-sections \
	-fdata-sections -Os

LDFLAGS = $(LDFLAGS_PLATFORM) \
	-ffunction-sections -fdata-sections -Wl,--gc-sections -Os -Iinclude

OBJS = $(OBJS_PLATFORM) $(OBJS_DBE) \
	$(OBJS_SHELL) $(OBJS_TESTS) $(OBJS_LIB) \
	$(OBJS_DEV) $(OBJS_BOARD) $(OBJS_FMC)

OUTPUT = dbe_lwip
#OUTPUT = dbe
#OUTPUT = dbe_test

REVISION=$(shell git describe --dirty --always)

all: tools $(OUTPUT).ram $(OUTPUT).vhd

.PHONY: all tools clean

$(OUTPUT).elf: $(OBJS)
	#$(MAKE) -C $(LIB_DIRS) all
	$(CC) $(CFLAGS) -DGIT_REVISION=\"$(REVISION)\" -c revision.c
	$(SIZE) -t $(OBJS)
	${CC} $(LFLAGS) -o $@ revision.o $(OBJS) $(LDFLAGS) $(LIBS)
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
# Bad...
	find . -iname "*.d" -exec rm '{}' \;
	make clean -C tools

# Pull in dependency info for *existing* .o files and don't complain if the
# corresponding .d file is not found
-include $(OBJS:.o=.d)

# Compile and generate dependency info;
%.o: %.c
	${CC} $(CFLAGS) $(INCLUDE_DIRS) $(LIB_DIR) -c $*.c -o $@
# create the dependency files "target: pre-requisites"
	${CC} -MM $(CFLAGS) $*.c > $*.d

# Workaround to make objects in different folders have
# the correct target path. e.g., "dir/bar.o: dir/bar.c dir/foo.h"
# instead of "bar.o: dir/bar.c dir/foo.h"
	@mv -f $*.d $*.d.tmp
	@sed -e 's|.*:|$*.o:|' < $*.d.tmp > $*.d

# All prereqs listed will also become command-less,
# prereq-less targets. In this way, the prereq file will be
# treated as changed and the target will be rebuilt
#   sed:    strip the target (everything before colon)
#   sed:    remove any continuation backslashes
#   fmt -1: list words one per line
#   sed:    strip leading spaces
#   sed:    add trailing colons
	@sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | \
                sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
	@rm -f $*.d.tmp

tools:
	$(MAKE) -C tools
