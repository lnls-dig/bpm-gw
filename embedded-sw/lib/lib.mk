include lib/memmgr/memmgr.mk

OBJS_LIB +=	lib/mprintf.o \
						lib/util.o

#ifdef CONFIG_ETHERBONE

#OBJS_LIB += lib/arp.o lib/icmp.o lib/ipv4.o lib/bootp.o

#endif
