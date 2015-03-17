include lib/memmgr/memmgr.mk
include lib/ethmac/ethmac.mk

ifeq ($(CONFIG_PPRINTF),n)
	OBJS_LIB += lib/mprintf.o
endif

ifeq ($(CONFIG_LWIP),y)
	include lib/lwip/lwip.mk
	OBJS_LIB += lib/minimal_newlibc.o
else
	OBJS_LIB += lib/arp.o lib/icmp.o lib/ipv4.o
endif

OBJS_LIB += lib/util.o lib/int.o lib/debug_print.o

ifeq ($(CONFIG_ETHERBONE),y)
endif
