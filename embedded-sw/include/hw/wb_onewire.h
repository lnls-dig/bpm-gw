#ifndef __ONEWIRE_REGDEFS_WB
#define __ONEWIRE_REGDEFS_WB

#include <inttypes.h>

#if defined( __GNUC__)
#define PACKED __attribute__ ((packed))
#else
#error "Unsupported compiler?"
#endif

// OpenCores 1-wire registers description

#define ONEWIRE_CSR 0x00000000
#define ONEWIRE_CDR 0x00000004

#define ONEWIRE_CSR_DAT (1<<0)
#define ONEWIRE_CSR_RST (1<<1)
#define ONEWIRE_CSR_OVD (1<<2)
#define ONEWIRE_CSR_CYC (1<<3)
#define ONEWIRE_CSR_PWR (1<<4)
#define ONEWIRE_CSR_IRQ (1<<6)
#define ONEWIRE_CSR_IEN (1<<7)

#define ONEWIRE_CSR_SEL_OFS 8
#define ONEWIRE_CSR_SEL (0xF<<8)

#define ONEWIRE_CSR_POWER_OFS 16
#define ONEWIRE_CSR_POWER (0xFFFF<<16)

#define ONEWIRE_CDR_NOR (0xFFFF<<0)

#define ONEWIRE_CDR_OVD_OFS 16
#define ONEWIRE_CDR_OVD (0XFFFF<<16)

PACKED struct ONEWIRE_WB {
    uint32_t CSR;
    uint32_t CDR;
};

#endif
