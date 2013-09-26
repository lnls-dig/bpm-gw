ifeq ($(CONFIG_LWIP),y)
	OBJS_LIB += lib/ethmac/ethmac.o
else
	OBJS_LIB += lib/ethmac/ethmac_nolwip.o
endif

INCLUDE_DIRS += -I$(TOPDIR)/lib/ethmac
#lib/ethmac/ethmac-int.o
