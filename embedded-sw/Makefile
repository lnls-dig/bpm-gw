# choose your board here.
BOARD = ml605

# and don't touch the rest unless you know what you're doing.
CROSS_COMPILE ?= lm32-elf-

CC =		$(CROSS_COMPILE)gcc
OBJDUMP =	$(CROSS_COMPILE)objdump
OBJCOPY =	$(CROSS_COMPILE)objcopy
SIZE =		$(CROSS_COMPILE)size

-include $(CURDIR)/.config

OBJS_DBE = dbe_main.o #\
#		wrc_ptp.o \
#		monitor/monitor.o

#PTP_NOPOSIX = ptp-noposix

INCLUDE_DIRS = -Iinclude   \
               -Iinclude/memmgr
#-I$(PTP_NOPOSIX)/wrsw_hal \
#		-I$(PTP_NOPOSIX)/libptpnetif \
#		-I$(PTP_NOPOSIX)/softpll \

CFLAGS = 
#-include $(CURDIR)/include/generated/autoconf.h

CFLAGS_MEMMGR = -DDEBUG_MEMMGR_FATAL=1	\
								-DDEBUG_MEMMGR_SUPPORT_STATS=1

#CFLAGS_PTPD  = -ffreestanding \
#	-DPTPD_FREESTANDING \
#	-DWRPC_EXTRA_SLIM \
#	-DPTPD_MSBF \
#	-DPTPD_DBG \
#	-DPTPD_NO_DAEMON \
#	-DNEW_SINGLE_WRFSM \
#	-DPTPD_TRACE_MASK=0 \
#	-include $(PTP_NOPOSIX)/compat.h \
#	-include $(PTP_NOPOSIX)/PTPWRd/dep/trace.h \
#	-include $(PTP_NOPOSIX)/libposix/ptpd-wrappers.h

#OBJS_PTPD = $(PTP_NOPOSIX)/PTPWRd/arith.o \
#	$(PTP_NOPOSIX)/PTPWRd/bmc.o \
#	$(PTP_NOPOSIX)/PTPWRd/dep/msg.o \
#	$(PTP_NOPOSIX)/PTPWRd/dep/net.o \
#	$(PTP_NOPOSIX)/PTPWRd/dep/sys.o \
#	$(PTP_NOPOSIX)/PTPWRd/dep/timer.o \
#	$(PTP_NOPOSIX)/PTPWRd/dep/wr_servo.o \
#	$(PTP_NOPOSIX)/PTPWRd/dep/servo.o \
#	$(PTP_NOPOSIX)/PTPWRd/protocol.o \
#	$(PTP_NOPOSIX)/PTPWRd/wr_protocol.o \
#	$(PTP_NOPOSIX)/libposix/freestanding-startup.o \
#	$(PTP_NOPOSIX)/libposix/freestanding-wrapper.o \
#	$(PTP_NOPOSIX)/libposix/net.o \
#	$(PTP_NOPOSIX)/softpll/softpll_ng.o

CFLAGS_PLATFORM  = -mmultiply-enabled -mbarrel-shift-enabled
LDFLAGS_PLATFORM = -mmultiply-enabled -mbarrel-shift-enabled \
	-nostdlib -T arch/lm32/ram.ld

OBJS_PLATFORM = arch/lm32/crt0.o arch/lm32/irq.o arch/lm32/debug.o

#include shell/shell.mk
#include tests/tests.mk
include lib/lib.mk
#include sockitowm/sockitowm.mk
include dev/dev.mk
include boards/boards.mk

CFLAGS += $(CFLAGS_PLATFORM) $(CFLAGS_EB) $(INCLUDE_DIRS) \
					$(CFLAGS_MEMMGR) -ffunction-sections -fdata-sections	\
					-Os

LDFLAGS = $(LDFLAGS_PLATFORM) \
	-ffunction-sections -fdata-sections -Wl,--gc-sections -Os -Iinclude

OBJS = $(OBJS_PLATFORM) $(OBJS_DBE)\
	$(OBJS_SHELL) $(OBJS_TESTS) $(OBJS_LIB) \
  $(OBJS_DEV) $(OBJS_BOARD)

OUTPUT = dbe

REVISION=$(shell git describe --dirty --always)

all: tools dbe

dbe: $(OBJS)
	echo "const char *build_revision = \"$(REVISION)\";" > revision.c
	echo "const char *build_date = __DATE__ \" \" __TIME__;" >> revision.c
	ln -sf ../boards/$(BOARD)/board.h include/board.h
	$(CC) $(CFLAGS) -c revision.c
	$(SIZE) -t $(OBJS)
	${CC} -o $(OUTPUT).elf revision.o $(OBJS) $(LDFLAGS)
	${OBJCOPY} -O binary $(OUTPUT).elf $(OUTPUT).bin
	${OBJDUMP} -d $(OUTPUT).elf > $(OUTPUT)_disasm.S
	cd tools; $(MAKE)
	./tools/genraminit $(OUTPUT).bin 0 > $(OUTPUT).ram
	./tools/genramvhd -s 90112 $(OUTPUT).bin > $(OUTPUT).vhd

clean:
	rm -f $(OBJS) $(OUTPUT).elf $(OUTPUT).bin $(OUTPUT).ram
	make clean -C tools

%.o:		%.c
	$(CC) $(CFLAGS) $(INCLUDE_DIR) $(LIB_DIR) -c $^ -o $@

tools:
	make -C tools

# following targets from Makefile.kconfig
#silentoldconfig:
#	@mkdir -p include/config
#	$(MAKE) -f Makefile.kconfig $@

#scripts_basic config %config:
#	$(MAKE) -f Makefile.kconfig $@

#.config: silentoldconfig
