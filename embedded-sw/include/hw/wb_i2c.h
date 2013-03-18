#ifndef __I2C_REGDEFS_WB
#define __I2C_REGDEFS_WB

#include <inttypes.h>

#if defined( __GNUC__)
#define PACKED __attribute__ ((packed))
#else
#error "Unsupported compiler?"
#endif

// OpenCores I2C registers description

#define I2C_PREL 0x00000000
#define I2C_PREH 0x00000004
#define I2C_CTR 0x00000008
#define I2C_TXR 0x0000000C
#define I2C_RXR 0x0000000C
#define I2C_CR 0x00000010
#define I2C_SR 0x00000010

#define I2C_CTR_EN (1<<7)
#define I2C_CR_STA (1<<7)
#define I2C_CR_STO (1<<6)
#define I2C_CR_RD (1<<5)
#define I2C_CR_WR (1<<4)
#define I2C_CR_ACK (1<<3)
#define I2C_SR_RXACK (1<<7)
#define I2C_SR_TIP (1<<1)

PACKED struct I2C_WB {
    uint32_t PREL;
    uint32_t PREH;
    uint32_t CTR;
    uint32_t TXR;
    uint32_t RXR;
    uint32_t CR;
    uint32_t SR;
};

#endif
