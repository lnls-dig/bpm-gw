TARGETDIR=lib
CONTRIBDIR=lib/lwip/contrib
LWIPDIR=lib/lwip/src

LWIPARCH=$(CONTRIBDIR)/ports/lm32
LWIPDRVDIR=$(CONTRIBDIR)/ports/ethmac10100-drv

CFLAGS_LWIP += $(CPPFLAGS) -I$(LWIPDIR)/include -I. \
	-I$(LWIPARCH)/include -I$(LWIPARCH)/include/arch \
    	-I$(LWIPDIR)/include/ipv4 -I$(LWIPDRVDIR) \
    	-I$(LWIPDRVDIR)/netif -I$(INCDIR)

# COREOBJS, CORE4OBJS: The minimum set of files needed for lwIP.
COREOBJS=$(LWIPDIR)/core/mem.o  \
	$(LWIPDIR)/core/memp.o  \
	$(LWIPDIR)/core/netif.o  \
	$(LWIPDIR)/core/pbuf.o  \
	$(LWIPDIR)/core/raw.o  \
	$(LWIPDIR)/core/stats.o  \
	$(LWIPDIR)/core/sys.o  \
	$(LWIPDIR)/core/timers.o  \
	$(LWIPDIR)/core/tcp.o  \
	$(LWIPDIR)/core/tcp_in.o  \
	$(LWIPDIR)/core/tcp_out.o  \
	$(LWIPDIR)/core/udp.o  \
	$(LWIPDIR)/core/dhcp.o  \
	$(LWIPDIR)/core/init.o

CORE4OBJS=$(LWIPDIR)/core/ipv4/icmp.o \
	$(LWIPDIR)/core/ipv4/ip.o  \
	$(LWIPDIR)/core/ipv4/inet.o  \
	$(LWIPDIR)/core/ipv4/ip_addr.o  \
	$(LWIPDIR)/core/ipv4/ip_frag.o  \
	$(LWIPDIR)/core/ipv4/inet_chksum.o

# NETIFOBJS: Files implementing various generic network interface functions.'
NETIFOBJS=$(LWIPDIR)/netif/etharp.o  \
	$(LWIPDRVDIR)/netif/ethernetif.o

# LWIPOBJS: All the above.
LWIPOBJS=$(COREOBJS) $(CORE4OBJS) $(NETIFOBJS)
OBJS_LIB+=$(LWIPOBJS)

CFLAGS_LWIP = -I$(LWIPDIR)/include -I. \
			-I$(LWIPARCH)/include -I$(LWIPARCH)/include/arch \
    	-I$(LWIPDIR)/include/ipv4 -I$(LWIPDRVDIR) \
    	-I$(LWIPDRVDIR)/netif

$(LWIPLIB): $(LWIPOBJS)
	$(AR) $(ARFLAGS) $(LWIPLIB) $?
