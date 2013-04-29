ifeq ($(CONFIG_FMC150),1)
	OBJS_FMC150 += fmc/fmc150/fmc150.o
endif

ifeq ($(CONFIG_FMC516),1)
	OBJS_FMC516 += fmc/fmc516/lmk02000.o fmc/fmc516/isla216p25.o fmc/fmc516/fmc516.o
endif

OBJS_FMC += $(OBJS_FMC150) $(OBJS_FMC516)


