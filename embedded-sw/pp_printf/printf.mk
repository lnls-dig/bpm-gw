# This is included from ../Makefile, for the wrc build system.
# The Makefile in this directory is preserved from the upstream version

ifeq ($(CONFIG_PPRINTF),y)
	OBJS_LIB += pp_printf/printf.o
	#obj-$(CONFIG_PP_PRINTF) += pp_printf/printf.o

	#ppprintf-$(CONFIG_PRINTF_FULL) += pp_printf/vsprintf-full.o
	#ppprintf-$(CONFIG_PRINTF_MINI) += pp_printf/vsprintf-mini.o
	#ppprintf-$(CONFIG_PRINTF_NONE) += pp_printf/vsprintf-none.o
	#ppprintf-$(CONFIG_PRINTF_XINT) += pp_printf/vsprintf-xint.o

	#ppprintf-y ?= pp_printf/vsprintf-xint.o

	#obj-$(CONFIG_PP_PRINTF) += $(ppprintf-y)
	# make full printf for now
	OBJS_LIB += pp_printf/vsprintf-full.o
endif


