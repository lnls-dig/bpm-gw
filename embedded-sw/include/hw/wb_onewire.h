#ifndef __OWR_REGDEFS_WB
#define __OWR_REGDEFS_WB

#include <inttypes.h>

#if defined( __GNUC__)
#define PACKED __attribute__ ((packed))
#else
#error "Unsupported compiler?"
#endif

// OpenCores 1-wire registers description

#define OWR_CSR 0x00000000
#define OWR_CDR 0x00000004

#define OWR_CSR_DAT (1<<0)
#define OWR_CSR_RST (1<<1)
#define OWR_CSR_OVD (1<<2)
#define OWR_CSR_CYC (1<<3)
#define OWR_CSR_PWR (1<<4)
#define OWR_CSR_IRQ (1<<6)
#define OWR_CSR_IEN (1<<7)

#define OWR_CSR_SEL_OFS 8
#define OWR_CSR_SEL_MASK (0xF << OWR_CSR_SEL_OFS)
#define OWR_CSR_SEL(x) (((x) << OWR_CSR_SEL_OFS) & OWR_CSR_SEL_MASK)

#define OWR_CSR_POWER_OFS 16
#define OWR_CSR_POWER_MASK (0xFFFF << OWR_CSR_POWER_OFS)
#define OWR_CSR_POWER(x) (((x) << OWR_CSR_POWER_OFS) & OWR_CSR_POWER_MASK)

#define OWR_CDR_NOR_OFS 0
#define OWR_CDR_NOR_MASK (0xFFFF << OWR_CDR_NOR_OFS)
#define OWR_CDR_NOR(x) (((x) << OWR_CDR_NOR_OFS) & OWR_CDR_NOR_MASK)

#define OWR_CDR_OVD_OFS 16
#define OWR_CDR_OVD_MASK (0XFFFF << OWR_CDR_OVD_OFS)
#define OWR_CDR_OVD(x) (((x) << OWR_CDR_OVD_OFS) & OWR_CDR_OVD_MASK)

PACKED struct OWR_WB {
	uint32_t CSR;
	uint32_t CDR;
};

#endif
