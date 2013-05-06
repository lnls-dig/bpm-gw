include lib/memmgr/memmgr.mk
include lib/ethmac/ethmac.mk
include lib/lwip/lwip.mk

ifeq ($(CONFIG_PPRINTF),0)
	OBJS_LIB += lib/mprintf.o
endif

OBJS_LIB += lib/util.o lib/int.o lib/debug_print.o
#OBJS_LIB += lib/util.o lib/int.o lib/arp.o lib/icmp.o lib/ipv4.o lib/debug_print.o

ifdef CONFIG_ETHERBONE
	#OBJS_LIB += lib/bootp.o
endif

OBJS_LIB += lib/minimal_newlibc.o
