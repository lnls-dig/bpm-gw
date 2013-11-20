ifeq ($(CONFIG_FMC150),y)
	OBJS_FMC150 += fmc/fmc150/fmc150.o
	INCLUDE_DIRS += -I$(TOPDIR)/include/fmc/fmc150
endif

ifeq ($(CONFIG_FMC516),y)
	OBJS_FMC516 += fmc/fmc516/lmk02000.o fmc/fmc516/isla216p25.o fmc/fmc516/fmc516.o
	INCLUDE_DIRS += -I$(TOPDIR)/include/fmc/fmc516
endif

OBJS_FMC += $(OBJS_FMC150) $(OBJS_FMC516)


