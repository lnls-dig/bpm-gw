/*
  Register definitions for slave core: BPM Orbit Interlock Interface Registers

  * File           : orbit_intlk_regs.h
  * Author         : auto-generated by wbgen2 from wb_orbit_intlk_regs.wb
  * Created        : Fri Aug 21 15:51:50 2020
  * Standard       : ANSI C

    THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE wb_orbit_intlk_regs.wb
    DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!

*/

#ifndef __WBGEN2_REGDEFS_WB_ORBIT_INTLK_REGS_WB
#define __WBGEN2_REGDEFS_WB_ORBIT_INTLK_REGS_WB

#ifdef __KERNEL__
#include <linux/types.h>
#else
#include <inttypes.h>
#endif

#if defined( __GNUC__)
#define PACKED __attribute__ ((packed))
#else
#error "Unsupported compiler?"
#endif

#ifndef __WBGEN2_MACROS_DEFINED__
#define __WBGEN2_MACROS_DEFINED__
#define WBGEN2_GEN_MASK(offset, size) (((1<<(size))-1) << (offset))
#define WBGEN2_GEN_WRITE(value, offset, size) (((value) & ((1<<(size))-1)) << (offset))
#define WBGEN2_GEN_READ(reg, offset, size) (((reg) >> (offset)) & ((1<<(size))-1))
#define WBGEN2_SIGN_EXTEND(value, bits) (((value) & (1<<bits) ? ~((1<<(bits))-1): 0 ) | (value))
#endif


/* definitions for register: General Control Signals */

/* definitions for field: Enable in reg: General Control Signals */
#define ORBIT_INTLK_CTRL_EN                   WBGEN2_GEN_MASK(0, 1)

/* definitions for field: Clear in reg: General Control Signals */
#define ORBIT_INTLK_CTRL_CLR                  WBGEN2_GEN_MASK(1, 1)

/* definitions for field: Minimum sum enable in reg: General Control Signals */
#define ORBIT_INTLK_CTRL_MIN_SUM_EN           WBGEN2_GEN_MASK(2, 1)

/* definitions for field: Translation Interlock Enable in reg: General Control Signals */
#define ORBIT_INTLK_CTRL_TRANS_EN             WBGEN2_GEN_MASK(3, 1)

/* definitions for field: Translation Interlock Clear in reg: General Control Signals */
#define ORBIT_INTLK_CTRL_TRANS_CLR            WBGEN2_GEN_MASK(4, 1)

/* definitions for field: Angular Interlock Enable in reg: General Control Signals */
#define ORBIT_INTLK_CTRL_ANG_EN               WBGEN2_GEN_MASK(5, 1)

/* definitions for field: Angular Interlock Clear in reg: General Control Signals */
#define ORBIT_INTLK_CTRL_ANG_CLR              WBGEN2_GEN_MASK(6, 1)

/* definitions for field: Reserved in reg: General Control Signals */
#define ORBIT_INTLK_CTRL_RESERVED_MASK        WBGEN2_GEN_MASK(7, 24)
#define ORBIT_INTLK_CTRL_RESERVED_SHIFT       7
#define ORBIT_INTLK_CTRL_RESERVED_W(value)    WBGEN2_GEN_WRITE(value, 7, 24)
#define ORBIT_INTLK_CTRL_RESERVED_R(reg)      WBGEN2_GEN_READ(reg, 7, 24)

/* definitions for register: General Status Signals */

/* definitions for field: Translation Bigger X in reg: General Status Signals */
#define ORBIT_INTLK_STS_TRANS_BIGGER_X        WBGEN2_GEN_MASK(0, 1)

/* definitions for field: Translation Bigger Y in reg: General Status Signals */
#define ORBIT_INTLK_STS_TRANS_BIGGER_Y        WBGEN2_GEN_MASK(1, 1)

/* definitions for field: Translation Bigger Latched X in reg: General Status Signals */
#define ORBIT_INTLK_STS_TRANS_BIGGER_LTC_X    WBGEN2_GEN_MASK(2, 1)

/* definitions for field: Translation Bigger Latched Y in reg: General Status Signals */
#define ORBIT_INTLK_STS_TRANS_BIGGER_LTC_Y    WBGEN2_GEN_MASK(3, 1)

/* definitions for field: Translation Bigger Any (X/Y) in reg: General Status Signals */
#define ORBIT_INTLK_STS_TRANS_BIGGER_ANY      WBGEN2_GEN_MASK(4, 1)

/* definitions for field: Translation Bigger in reg: General Status Signals */
#define ORBIT_INTLK_STS_TRANS_BIGGER          WBGEN2_GEN_MASK(5, 1)

/* definitions for field: Translation Bigger Latched in reg: General Status Signals */
#define ORBIT_INTLK_STS_TRANS_BIGGER_LTC      WBGEN2_GEN_MASK(6, 1)

/* definitions for field: Angular Bigger X in reg: General Status Signals */
#define ORBIT_INTLK_STS_ANG_BIGGER_X          WBGEN2_GEN_MASK(7, 1)

/* definitions for field: Angular Bigger Y in reg: General Status Signals */
#define ORBIT_INTLK_STS_ANG_BIGGER_Y          WBGEN2_GEN_MASK(8, 1)

/* definitions for field: Angular Bigger Latched X in reg: General Status Signals */
#define ORBIT_INTLK_STS_ANG_BIGGER_LTC_X      WBGEN2_GEN_MASK(9, 1)

/* definitions for field: Angular Bigger Latched Y in reg: General Status Signals */
#define ORBIT_INTLK_STS_ANG_BIGGER_LTC_Y      WBGEN2_GEN_MASK(10, 1)

/* definitions for field: Angular Bigger Any (X/Y) in reg: General Status Signals */
#define ORBIT_INTLK_STS_ANG_BIGGER_ANY        WBGEN2_GEN_MASK(11, 1)

/* definitions for field: Angular Bigger in reg: General Status Signals */
#define ORBIT_INTLK_STS_ANG_BIGGER            WBGEN2_GEN_MASK(12, 1)

/* definitions for field: Angular Bigger Latched in reg: General Status Signals */
#define ORBIT_INTLK_STS_ANG_BIGGER_LTC        WBGEN2_GEN_MASK(13, 1)

/* definitions for field: Interlock Bigger in reg: General Status Signals */
#define ORBIT_INTLK_STS_INTLK_BIGGER          WBGEN2_GEN_MASK(14, 1)

/* definitions for field: Interlock Bigger Latched in reg: General Status Signals */
#define ORBIT_INTLK_STS_INTLK_BIGGER_LTC      WBGEN2_GEN_MASK(15, 1)

/* definitions for field: Reserved in reg: General Status Signals */
#define ORBIT_INTLK_STS_RESERVED_MASK         WBGEN2_GEN_MASK(16, 16)
#define ORBIT_INTLK_STS_RESERVED_SHIFT        16
#define ORBIT_INTLK_STS_RESERVED_W(value)     WBGEN2_GEN_WRITE(value, 16, 16)
#define ORBIT_INTLK_STS_RESERVED_R(reg)       WBGEN2_GEN_READ(reg, 16, 16)

/* definitions for register: Minimum sum threshold */

/* definitions for register: Maximum translation X threshold */

/* definitions for register: Maximum translation Y threshold */

/* definitions for register: Maximum angular X threshold */

/* definitions for register: Maximum angular Y threshold */

/* definitions for register: Minimum translation X threshold */

/* definitions for register: Minimum translation Y threshold */

/* definitions for register: Minimum angular X threshold */

/* definitions for register: Minimum angular Y threshold */
/* [0x0]: REG General Control Signals */
#define ORBIT_INTLK_REG_CTRL 0x00000000
/* [0x4]: REG General Status Signals */
#define ORBIT_INTLK_REG_STS 0x00000004
/* [0x8]: REG Minimum sum threshold */
#define ORBIT_INTLK_REG_MIN_SUM 0x00000008
/* [0xc]: REG Maximum translation X threshold */
#define ORBIT_INTLK_REG_TRANS_MAX_X 0x0000000c
/* [0x10]: REG Maximum translation Y threshold */
#define ORBIT_INTLK_REG_TRANS_MAX_Y 0x00000010
/* [0x14]: REG Maximum angular X threshold */
#define ORBIT_INTLK_REG_ANG_MAX_X 0x00000014
/* [0x18]: REG Maximum angular Y threshold */
#define ORBIT_INTLK_REG_ANG_MAX_Y 0x00000018
/* [0x1c]: REG Minimum translation X threshold */
#define ORBIT_INTLK_REG_TRANS_MIN_X 0x0000001c
/* [0x20]: REG Minimum translation Y threshold */
#define ORBIT_INTLK_REG_TRANS_MIN_Y 0x00000020
/* [0x24]: REG Minimum angular X threshold */
#define ORBIT_INTLK_REG_ANG_MIN_X 0x00000024
/* [0x28]: REG Minimum angular Y threshold */
#define ORBIT_INTLK_REG_ANG_MIN_Y 0x00000028
#endif
