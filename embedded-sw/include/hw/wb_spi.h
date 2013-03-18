#ifndef __SPI_REGDEFS_WB
#define __SPI_REGDEFS_WB

#include <inttypes.h>

#if defined( __GNUC__)
#define PACKED __attribute__ ((packed))
#else
#error "Unsupported compiler?"
#endif

//OpenCores SPI registers description

#define SPI_REG_RX0 0x00000000
#define SPI_REG_TX0 0x00000000
#define SPI_REG_RX1 0x00000004
#define SPI_REG_TX1 0x00000004
#define SPI_REG_RX2 0x00000008
#define SPI_REG_TX2 0x00000008
#define SPI_REG_RX3 0x0000000C
#define SPI_REG_TX3 0x0000000C

#define SPI_REG_CTRL 0x00000010
#define SPI_REG_DIVIDER 0x00000014
#define SPI_REG_SS 0x00000018

#define SPI_CTRL_ASS (1<<13)
#define SPI_CTRL_IE (1<<12)
#define SPI_CTRL_LSB (1<<11)
#define SPI_CTRL_TXNEG (1<<10)
#define SPI_CTRL_RXNEG (1<<9)
#define SPI_CTRL_GO_BSY (1<<8)
#define SPI_CTRL_BSY (1<<8)
#define SPI_CTRL_CHAR_LEN(x) ((x) & 0x7f)
#define SPI_CTRL_SS(x) ((x) & 0xff)

#define SPI_LGH_MASK 0x7F
#define SPI_DIV_MASK 0xFFFF

PACKED struct SPI_WB {
    union {
        uint32_t RX0;
        uint32_t TX0;
    };
    union {
        uint32_t RX1;
        uint32_t TX1;
    };
    union {
        uint32_t RX2;
        uint32_t TX2;
    };
    union {
        uint32_t RX3;
        uint32_t TX3;
    };

    uint32_t CTRL;
    uint32_t DIVIDER;
    uint32_t SS;
};

#endif
