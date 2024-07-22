#ifndef __CHEBY__POS_CALC__H__
#define __CHEBY__POS_CALC__H__
#define POS_CALC_SIZE 352 /* 0x160 */

/* Config divisor threshold TBT register */
#define POS_CALC_DS_TBT_THRES 0x0UL
#define POS_CALC_DS_TBT_THRES_VAL_MASK 0x3ffffffUL
#define POS_CALC_DS_TBT_THRES_VAL_SHIFT 0
#define POS_CALC_DS_TBT_THRES_RESERVED_MASK 0xfc000000UL
#define POS_CALC_DS_TBT_THRES_RESERVED_SHIFT 26

/* Config divisor threshold FOFB register */
#define POS_CALC_DS_FOFB_THRES 0x4UL
#define POS_CALC_DS_FOFB_THRES_VAL_MASK 0x3ffffffUL
#define POS_CALC_DS_FOFB_THRES_VAL_SHIFT 0
#define POS_CALC_DS_FOFB_THRES_RESERVED_MASK 0xfc000000UL
#define POS_CALC_DS_FOFB_THRES_RESERVED_SHIFT 26

/* Config divisor threshold Monit. register */
#define POS_CALC_DS_MONIT_THRES 0x8UL
#define POS_CALC_DS_MONIT_THRES_VAL_MASK 0x3ffffffUL
#define POS_CALC_DS_MONIT_THRES_VAL_SHIFT 0
#define POS_CALC_DS_MONIT_THRES_RESERVED_MASK 0xfc000000UL
#define POS_CALC_DS_MONIT_THRES_RESERVED_SHIFT 26

/* BPM sensitivity (X axis) parameter register */
#define POS_CALC_KX 0xcUL
#define POS_CALC_KX_VAL_MASK 0x1ffffffUL
#define POS_CALC_KX_VAL_SHIFT 0
#define POS_CALC_KX_RESERVED_MASK 0xfe000000UL
#define POS_CALC_KX_RESERVED_SHIFT 25

/* BPM sensitivity (Y axis) parameter register */
#define POS_CALC_KY 0x10UL
#define POS_CALC_KY_VAL_MASK 0x1ffffffUL
#define POS_CALC_KY_VAL_SHIFT 0
#define POS_CALC_KY_RESERVED_MASK 0xfe000000UL
#define POS_CALC_KY_RESERVED_SHIFT 25

/* BPM sensitivity (Sum) parameter register */
#define POS_CALC_KSUM 0x14UL
#define POS_CALC_KSUM_VAL_MASK 0x1ffffffUL
#define POS_CALC_KSUM_VAL_SHIFT 0
#define POS_CALC_KSUM_RESERVED_MASK 0xfe000000UL
#define POS_CALC_KSUM_RESERVED_SHIFT 25

/* DSP TBT incorrect TDM counter */
#define POS_CALC_DSP_CTNR_TBT 0x18UL
#define POS_CALC_DSP_CTNR_TBT_CH01_MASK 0xffffUL
#define POS_CALC_DSP_CTNR_TBT_CH01_SHIFT 0
#define POS_CALC_DSP_CTNR_TBT_CH23_MASK 0xffff0000UL
#define POS_CALC_DSP_CTNR_TBT_CH23_SHIFT 16

/* DSP FOFB incorrect TDM counter */
#define POS_CALC_DSP_CTNR_FOFB 0x1cUL
#define POS_CALC_DSP_CTNR_FOFB_CH01_MASK 0xffffUL
#define POS_CALC_DSP_CTNR_FOFB_CH01_SHIFT 0
#define POS_CALC_DSP_CTNR_FOFB_CH23_MASK 0xffff0000UL
#define POS_CALC_DSP_CTNR_FOFB_CH23_SHIFT 16

/* DSP Monit. incorrect TDM counter part 1 */
#define POS_CALC_DSP_CTNR1_MONIT 0x20UL
#define POS_CALC_DSP_CTNR1_MONIT_CIC_MASK 0xffffUL
#define POS_CALC_DSP_CTNR1_MONIT_CIC_SHIFT 0
#define POS_CALC_DSP_CTNR1_MONIT_CFIR_MASK 0xffff0000UL
#define POS_CALC_DSP_CTNR1_MONIT_CFIR_SHIFT 16

/* DSP Monit. incorrect TDM counter part 2 */
#define POS_CALC_DSP_CTNR2_MONIT 0x24UL
#define POS_CALC_DSP_CTNR2_MONIT_PFIR_MASK 0xffffUL
#define POS_CALC_DSP_CTNR2_MONIT_PFIR_SHIFT 0
#define POS_CALC_DSP_CTNR2_MONIT_FIR_01_MASK 0xffff0000UL
#define POS_CALC_DSP_CTNR2_MONIT_FIR_01_SHIFT 16

/* DSP error clearing */
#define POS_CALC_DSP_ERR_CLR 0x28UL
#define POS_CALC_DSP_ERR_CLR_TBT 0x1UL
#define POS_CALC_DSP_ERR_CLR_FOFB 0x2UL
#define POS_CALC_DSP_ERR_CLR_MONIT_PART1 0x4UL
#define POS_CALC_DSP_ERR_CLR_MONIT_PART2 0x8UL

/* DDS general config registers for all channels */
#define POS_CALC_DDS_CFG 0x2cUL
#define POS_CALC_DDS_CFG_VALID_CH0 0x1UL
#define POS_CALC_DDS_CFG_TEST_DATA 0x2UL
#define POS_CALC_DDS_CFG_RESERVED_CH0_MASK 0xfcUL
#define POS_CALC_DDS_CFG_RESERVED_CH0_SHIFT 2
#define POS_CALC_DDS_CFG_VALID_CH1 0x100UL
#define POS_CALC_DDS_CFG_RESERVED_CH1_MASK 0xfe00UL
#define POS_CALC_DDS_CFG_RESERVED_CH1_SHIFT 9
#define POS_CALC_DDS_CFG_VALID_CH2 0x10000UL
#define POS_CALC_DDS_CFG_RESERVED_CH2_MASK 0xfe0000UL
#define POS_CALC_DDS_CFG_RESERVED_CH2_SHIFT 17
#define POS_CALC_DDS_CFG_VALID_CH3 0x1000000UL
#define POS_CALC_DDS_CFG_RESERVED_CH3_MASK 0xfe000000UL
#define POS_CALC_DDS_CFG_RESERVED_CH3_SHIFT 25

/* DDS phase increment parameter register for channel 0 */
#define POS_CALC_DDS_PINC_CH0 0x30UL
#define POS_CALC_DDS_PINC_CH0_VAL_MASK 0x3fffffffUL
#define POS_CALC_DDS_PINC_CH0_VAL_SHIFT 0
#define POS_CALC_DDS_PINC_CH0_RESERVED_MASK 0xc0000000UL
#define POS_CALC_DDS_PINC_CH0_RESERVED_SHIFT 30

/* DDS phase increment parameter register for channel 1 */
#define POS_CALC_DDS_PINC_CH1 0x34UL
#define POS_CALC_DDS_PINC_CH1_VAL_MASK 0x3fffffffUL
#define POS_CALC_DDS_PINC_CH1_VAL_SHIFT 0
#define POS_CALC_DDS_PINC_CH1_RESERVED_MASK 0xc0000000UL
#define POS_CALC_DDS_PINC_CH1_RESERVED_SHIFT 30

/* DDS phase increment parameter register for channel 2 */
#define POS_CALC_DDS_PINC_CH2 0x38UL
#define POS_CALC_DDS_PINC_CH2_VAL_MASK 0x3fffffffUL
#define POS_CALC_DDS_PINC_CH2_VAL_SHIFT 0
#define POS_CALC_DDS_PINC_CH2_RESERVED_MASK 0xc0000000UL
#define POS_CALC_DDS_PINC_CH2_RESERVED_SHIFT 30

/* DDS phase increment parameter register for channel 3 */
#define POS_CALC_DDS_PINC_CH3 0x3cUL
#define POS_CALC_DDS_PINC_CH3_VAL_MASK 0x3fffffffUL
#define POS_CALC_DDS_PINC_CH3_VAL_SHIFT 0
#define POS_CALC_DDS_PINC_CH3_RESERVED_MASK 0xc0000000UL
#define POS_CALC_DDS_PINC_CH3_RESERVED_SHIFT 30

/* DDS phase offset parameter register for channel 0 */
#define POS_CALC_DDS_POFF_CH0 0x40UL
#define POS_CALC_DDS_POFF_CH0_VAL_MASK 0x3fffffffUL
#define POS_CALC_DDS_POFF_CH0_VAL_SHIFT 0
#define POS_CALC_DDS_POFF_CH0_RESERVED_MASK 0xc0000000UL
#define POS_CALC_DDS_POFF_CH0_RESERVED_SHIFT 30

/* DDS phase offset parameter register for channel 1 */
#define POS_CALC_DDS_POFF_CH1 0x44UL
#define POS_CALC_DDS_POFF_CH1_VAL_MASK 0x3fffffffUL
#define POS_CALC_DDS_POFF_CH1_VAL_SHIFT 0
#define POS_CALC_DDS_POFF_CH1_RESERVED_MASK 0xc0000000UL
#define POS_CALC_DDS_POFF_CH1_RESERVED_SHIFT 30

/* DDS phase offset parameter register for channel 2 */
#define POS_CALC_DDS_POFF_CH2 0x48UL
#define POS_CALC_DDS_POFF_CH2_VAL_MASK 0x3fffffffUL
#define POS_CALC_DDS_POFF_CH2_VAL_SHIFT 0
#define POS_CALC_DDS_POFF_CH2_RESERVED_MASK 0xc0000000UL
#define POS_CALC_DDS_POFF_CH2_RESERVED_SHIFT 30

/* DDS phase offset parameter register for channel 3 */
#define POS_CALC_DDS_POFF_CH3 0x4cUL
#define POS_CALC_DDS_POFF_CH3_VAL_MASK 0x3fffffffUL
#define POS_CALC_DDS_POFF_CH3_VAL_SHIFT 0
#define POS_CALC_DDS_POFF_CH3_RESERVED_MASK 0xc0000000UL
#define POS_CALC_DDS_POFF_CH3_RESERVED_SHIFT 30

/* Monit. Amplitude Value for channel 0 */
#define POS_CALC_DSP_MONIT_AMP_CH0 0x50UL

/* Monit. Amplitude Value for channel 1 */
#define POS_CALC_DSP_MONIT_AMP_CH1 0x54UL

/* Monit. Amplitude Value for channel 2 */
#define POS_CALC_DSP_MONIT_AMP_CH2 0x58UL

/* Monit. Amplitude Value for channel 3 */
#define POS_CALC_DSP_MONIT_AMP_CH3 0x5cUL

/* Monit. X Position Value */
#define POS_CALC_DSP_MONIT_POS_X 0x60UL

/* Monit. Y Position Value */
#define POS_CALC_DSP_MONIT_POS_Y 0x64UL

/* Monit. Q Position Value */
#define POS_CALC_DSP_MONIT_POS_Q 0x68UL

/* Monit. Sum Position Value */
#define POS_CALC_DSP_MONIT_POS_SUM 0x6cUL

/* Monit. Amp/Pos update trigger */
#define POS_CALC_DSP_MONIT_UPDT 0x70UL

/* Monit. 1 Amplitude Value for channel 0 */
#define POS_CALC_DSP_MONIT1_AMP_CH0 0x74UL

/* Monit. 1 Amplitude Value for channel 1 */
#define POS_CALC_DSP_MONIT1_AMP_CH1 0x78UL

/* Monit. 1 Amplitude Value for channel 2 */
#define POS_CALC_DSP_MONIT1_AMP_CH2 0x7cUL

/* Monit. 1 Amplitude Value for channel 3 */
#define POS_CALC_DSP_MONIT1_AMP_CH3 0x80UL

/* Monit. 1 X Position Value */
#define POS_CALC_DSP_MONIT1_POS_X 0x84UL

/* Monit. 1 Y Position Value */
#define POS_CALC_DSP_MONIT1_POS_Y 0x88UL

/* Monit. 1 Q Position Value */
#define POS_CALC_DSP_MONIT1_POS_Q 0x8cUL

/* Monit. 1 Sum Position Value */
#define POS_CALC_DSP_MONIT1_POS_SUM 0x90UL

/* Monit. 1 Amp/Pos update trigger */
#define POS_CALC_DSP_MONIT1_UPDT 0x94UL

/* AMP FIFO Monitoring */
#define POS_CALC_AMPFIFO_MONIT 0x98UL
#define POS_CALC_AMPFIFO_MONIT_SIZE 20 /* 0x14 */

/* FIFO 'AMP FIFO Monitoring' data output register 0 */
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R0 0x98UL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R0_AMP_CH0_MASK 0xffffffffUL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R0_AMP_CH0_SHIFT 0

/* FIFO 'AMP FIFO Monitoring' data output register 1 */
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R1 0x9cUL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R1_AMP_CH1_MASK 0xffffffffUL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R1_AMP_CH1_SHIFT 0

/* FIFO 'AMP FIFO Monitoring' data output register 2 */
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R2 0xa0UL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R2_AMP_CH2_MASK 0xffffffffUL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R2_AMP_CH2_SHIFT 0

/* FIFO 'AMP FIFO Monitoring' data output register 3 */
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R3 0xa4UL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R3_AMP_CH3_MASK 0xffffffffUL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R3_AMP_CH3_SHIFT 0

/* FIFO 'AMP FIFO Monitoring' control/status register */
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR 0xa8UL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR_FULL 0x10000UL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR_EMPTY 0x20000UL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR_COUNT_MASK 0xfUL
#define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR_COUNT_SHIFT 0

/* POS FIFO Monitoring */
#define POS_CALC_POSFIFO_MONIT 0xacUL
#define POS_CALC_POSFIFO_MONIT_SIZE 20 /* 0x14 */

/* FIFO 'POS FIFO Monitoring' data output register 0 */
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R0 0xacUL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R0_POS_X_MASK 0xffffffffUL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R0_POS_X_SHIFT 0

/* FIFO 'POS FIFO Monitoring' data output register 1 */
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R1 0xb0UL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R1_POS_Y_MASK 0xffffffffUL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R1_POS_Y_SHIFT 0

/* FIFO 'POS FIFO Monitoring' data output register 2 */
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R2 0xb4UL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R2_POS_Q_MASK 0xffffffffUL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R2_POS_Q_SHIFT 0

/* FIFO 'POS FIFO Monitoring' data output register 3 */
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R3 0xb8UL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R3_POS_SUM_MASK 0xffffffffUL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R3_POS_SUM_SHIFT 0

/* FIFO 'POS FIFO Monitoring' control/status register */
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR 0xbcUL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR_FULL 0x10000UL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR_EMPTY 0x20000UL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR_COUNT_MASK 0xfUL
#define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR_COUNT_SHIFT 0

/* AMP FIFO Monitoring 1 */
#define POS_CALC_AMPFIFO_MONIT1 0xc0UL
#define POS_CALC_AMPFIFO_MONIT1_SIZE 20 /* 0x14 */

/* FIFO 'AMP FIFO Monitoring 1' data output register 0 */
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R0 0xc0UL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R0_AMP_CH0_MASK 0xffffffffUL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R0_AMP_CH0_SHIFT 0

/* FIFO 'AMP FIFO Monitoring 1' data output register 1 */
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R1 0xc4UL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R1_AMP_CH1_MASK 0xffffffffUL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R1_AMP_CH1_SHIFT 0

/* FIFO 'AMP FIFO Monitoring 1' data output register 2 */
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R2 0xc8UL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R2_AMP_CH2_MASK 0xffffffffUL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R2_AMP_CH2_SHIFT 0

/* FIFO 'AMP FIFO Monitoring 1' data output register 3 */
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R3 0xccUL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R3_AMP_CH3_MASK 0xffffffffUL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R3_AMP_CH3_SHIFT 0

/* FIFO 'AMP FIFO Monitoring 1' control/status register */
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR 0xd0UL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR_FULL 0x10000UL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR_EMPTY 0x20000UL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR_COUNT_MASK 0xfUL
#define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR_COUNT_SHIFT 0

/* POS FIFO Monitoring 1 */
#define POS_CALC_POSFIFO_MONIT1 0xd4UL
#define POS_CALC_POSFIFO_MONIT1_SIZE 20 /* 0x14 */

/* FIFO 'POS FIFO Monitoring 1' data output register 0 */
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R0 0xd4UL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R0_POS_X_MASK 0xffffffffUL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R0_POS_X_SHIFT 0

/* FIFO 'POS FIFO Monitoring 1' data output register 1 */
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R1 0xd8UL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R1_POS_Y_MASK 0xffffffffUL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R1_POS_Y_SHIFT 0

/* FIFO 'POS FIFO Monitoring 1' data output register 2 */
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R2 0xdcUL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R2_POS_Q_MASK 0xffffffffUL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R2_POS_Q_SHIFT 0

/* FIFO 'POS FIFO Monitoring 1' data output register 3 */
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R3 0xe0UL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R3_POS_SUM_MASK 0xffffffffUL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R3_POS_SUM_SHIFT 0

/* FIFO 'POS FIFO Monitoring 1' control/status register */
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR 0xe4UL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR_FULL 0x10000UL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR_EMPTY 0x20000UL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR_COUNT_MASK 0xfUL
#define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR_COUNT_SHIFT 0

/* Switching Tag synchronization */
#define POS_CALC_SW_TAG 0xe8UL
#define POS_CALC_SW_TAG_EN 0x1UL
#define POS_CALC_SW_TAG_DESYNC_CNT_RST 0x100UL
#define POS_CALC_SW_TAG_DESYNC_CNT_MASK 0x7ffe00UL
#define POS_CALC_SW_TAG_DESYNC_CNT_SHIFT 9

/* Switching Data Mask */
#define POS_CALC_SW_DATA_MASK 0xecUL
#define POS_CALC_SW_DATA_MASK_EN 0x1UL
#define POS_CALC_SW_DATA_MASK_SAMPLES_MASK 0x1fffeUL
#define POS_CALC_SW_DATA_MASK_SAMPLES_SHIFT 1

/* TbT Synchronizing Trigger */
#define POS_CALC_TBT_TAG 0xf0UL
#define POS_CALC_TBT_TAG_EN 0x1UL
#define POS_CALC_TBT_TAG_DLY_MASK 0x1fffeUL
#define POS_CALC_TBT_TAG_DLY_SHIFT 1
#define POS_CALC_TBT_TAG_DESYNC_CNT_RST 0x20000UL
#define POS_CALC_TBT_TAG_DESYNC_CNT_MASK 0xfffc0000UL
#define POS_CALC_TBT_TAG_DESYNC_CNT_SHIFT 18

/* TbT Masking Control */
#define POS_CALC_TBT_DATA_MASK_CTL 0xf4UL
#define POS_CALC_TBT_DATA_MASK_CTL_EN 0x1UL

/* TbT Data Masking Samples */
#define POS_CALC_TBT_DATA_MASK_SAMPLES 0xf8UL
#define POS_CALC_TBT_DATA_MASK_SAMPLES_BEG_MASK 0xffffUL
#define POS_CALC_TBT_DATA_MASK_SAMPLES_BEG_SHIFT 0
#define POS_CALC_TBT_DATA_MASK_SAMPLES_END_MASK 0xffff0000UL
#define POS_CALC_TBT_DATA_MASK_SAMPLES_END_SHIFT 16

/* MONIT1 Synchronizing Trigger */
#define POS_CALC_MONIT1_TAG 0xfcUL
#define POS_CALC_MONIT1_TAG_EN 0x1UL
#define POS_CALC_MONIT1_TAG_DLY_MASK 0x1fffeUL
#define POS_CALC_MONIT1_TAG_DLY_SHIFT 1
#define POS_CALC_MONIT1_TAG_DESYNC_CNT_RST 0x20000UL
#define POS_CALC_MONIT1_TAG_DESYNC_CNT_MASK 0xfffc0000UL
#define POS_CALC_MONIT1_TAG_DESYNC_CNT_SHIFT 18

/* MONIT1 Masking Control */
#define POS_CALC_MONIT1_DATA_MASK_CTL 0x100UL
#define POS_CALC_MONIT1_DATA_MASK_CTL_EN 0x1UL

/* MONIT1 Data Masking Samples */
#define POS_CALC_MONIT1_DATA_MASK_SAMPLES 0x104UL
#define POS_CALC_MONIT1_DATA_MASK_SAMPLES_BEG_MASK 0xffffUL
#define POS_CALC_MONIT1_DATA_MASK_SAMPLES_BEG_SHIFT 0
#define POS_CALC_MONIT1_DATA_MASK_SAMPLES_END_MASK 0xffff0000UL
#define POS_CALC_MONIT1_DATA_MASK_SAMPLES_END_SHIFT 16

/* MONIT Synchronizing Trigger */
#define POS_CALC_MONIT_TAG 0x108UL
#define POS_CALC_MONIT_TAG_EN 0x1UL
#define POS_CALC_MONIT_TAG_DLY_MASK 0x1fffeUL
#define POS_CALC_MONIT_TAG_DLY_SHIFT 1
#define POS_CALC_MONIT_TAG_DESYNC_CNT_RST 0x20000UL
#define POS_CALC_MONIT_TAG_DESYNC_CNT_MASK 0xfffc0000UL
#define POS_CALC_MONIT_TAG_DESYNC_CNT_SHIFT 18

/* MONIT Masking Control */
#define POS_CALC_MONIT_DATA_MASK_CTL 0x10cUL
#define POS_CALC_MONIT_DATA_MASK_CTL_EN 0x1UL

/* MONIT Data Masking Samples */
#define POS_CALC_MONIT_DATA_MASK_SAMPLES 0x110UL
#define POS_CALC_MONIT_DATA_MASK_SAMPLES_BEG_MASK 0xffffUL
#define POS_CALC_MONIT_DATA_MASK_SAMPLES_BEG_SHIFT 0
#define POS_CALC_MONIT_DATA_MASK_SAMPLES_END_MASK 0xffff0000UL
#define POS_CALC_MONIT_DATA_MASK_SAMPLES_END_SHIFT 16

/* BPM X position offset parameter register */
#define POS_CALC_OFFSET_X 0x114UL

/* BPM Y position offset parameter register */
#define POS_CALC_OFFSET_Y 0x118UL

/* ADC gains fixed-point position constant */
#define POS_CALC_ADC_GAINS_FIXED_POINT_POS 0x11cUL
#define POS_CALC_ADC_GAINS_FIXED_POINT_POS_DATA_MASK 0xffffffffUL
#define POS_CALC_ADC_GAINS_FIXED_POINT_POS_DATA_SHIFT 0

/* ADC channel 0 gain on RFFE switch state 0 (direct) */
#define POS_CALC_ADC_CH0_SWCLK_0_GAIN 0x120UL
#define POS_CALC_ADC_CH0_SWCLK_0_GAIN_DATA_MASK 0xffffffffUL
#define POS_CALC_ADC_CH0_SWCLK_0_GAIN_DATA_SHIFT 0

/* ADC channel 1 gain on RFFE switch state 0 (direct) */
#define POS_CALC_ADC_CH1_SWCLK_0_GAIN 0x124UL
#define POS_CALC_ADC_CH1_SWCLK_0_GAIN_DATA_MASK 0xffffffffUL
#define POS_CALC_ADC_CH1_SWCLK_0_GAIN_DATA_SHIFT 0

/* ADC channel 2 gain on RFFE switch state 0 (direct) */
#define POS_CALC_ADC_CH2_SWCLK_0_GAIN 0x128UL
#define POS_CALC_ADC_CH2_SWCLK_0_GAIN_DATA_MASK 0xffffffffUL
#define POS_CALC_ADC_CH2_SWCLK_0_GAIN_DATA_SHIFT 0

/* ADC channel 3 gain on RFFE switch state 0 (direct) */
#define POS_CALC_ADC_CH3_SWCLK_0_GAIN 0x12cUL
#define POS_CALC_ADC_CH3_SWCLK_0_GAIN_DATA_MASK 0xffffffffUL
#define POS_CALC_ADC_CH3_SWCLK_0_GAIN_DATA_SHIFT 0

/* ADC channel 0 gain on RFFE switch state 1 (inverted) */
#define POS_CALC_ADC_CH0_SWCLK_1_GAIN 0x130UL
#define POS_CALC_ADC_CH0_SWCLK_1_GAIN_DATA_MASK 0xffffffffUL
#define POS_CALC_ADC_CH0_SWCLK_1_GAIN_DATA_SHIFT 0

/* ADC channel 1 gain on RFFE switch state 1 (inverted) */
#define POS_CALC_ADC_CH1_SWCLK_1_GAIN 0x134UL
#define POS_CALC_ADC_CH1_SWCLK_1_GAIN_DATA_MASK 0xffffffffUL
#define POS_CALC_ADC_CH1_SWCLK_1_GAIN_DATA_SHIFT 0

/* ADC channel 2 gain on RFFE switch state 1 (inverted) */
#define POS_CALC_ADC_CH2_SWCLK_1_GAIN 0x138UL
#define POS_CALC_ADC_CH2_SWCLK_1_GAIN_DATA_MASK 0xffffffffUL
#define POS_CALC_ADC_CH2_SWCLK_1_GAIN_DATA_SHIFT 0

/* ADC channel 3 gain on RFFE switch state 1 (inverted) */
#define POS_CALC_ADC_CH3_SWCLK_1_GAIN 0x13cUL
#define POS_CALC_ADC_CH3_SWCLK_1_GAIN_DATA_MASK 0xffffffffUL
#define POS_CALC_ADC_CH3_SWCLK_1_GAIN_DATA_SHIFT 0

/* ADC channel 0 offset on RFFE switch state 0 (direct)
Uses 2's complement representation and is subtracted from ADC samples.
 */
#define POS_CALC_ADC_CH0_SWCLK_0_OFFSET 0x140UL
#define POS_CALC_ADC_CH0_SWCLK_0_OFFSET_DATA_MASK 0xffffUL
#define POS_CALC_ADC_CH0_SWCLK_0_OFFSET_DATA_SHIFT 0

/* ADC channel 1 offset on RFFE switch state 0 (direct)
Uses 2's complement representation and is subtracted from ADC samples.
 */
#define POS_CALC_ADC_CH1_SWCLK_0_OFFSET 0x144UL
#define POS_CALC_ADC_CH1_SWCLK_0_OFFSET_DATA_MASK 0xffffUL
#define POS_CALC_ADC_CH1_SWCLK_0_OFFSET_DATA_SHIFT 0

/* ADC channel 2 offset on RFFE switch state 0 (direct)
Uses 2's complement representation and is subtracted from ADC samples.
 */
#define POS_CALC_ADC_CH2_SWCLK_0_OFFSET 0x148UL
#define POS_CALC_ADC_CH2_SWCLK_0_OFFSET_DATA_MASK 0xffffUL
#define POS_CALC_ADC_CH2_SWCLK_0_OFFSET_DATA_SHIFT 0

/* ADC channel 3 offset on RFFE switch state 0 (direct)
Uses 2's complement representation and is subtracted from ADC samples.
 */
#define POS_CALC_ADC_CH3_SWCLK_0_OFFSET 0x14cUL
#define POS_CALC_ADC_CH3_SWCLK_0_OFFSET_DATA_MASK 0xffffUL
#define POS_CALC_ADC_CH3_SWCLK_0_OFFSET_DATA_SHIFT 0

/* ADC channel 0 offset on RFFE switch state 1 (inverted)
Uses 2's complement representation and is subtracted from ADC samples.
 */
#define POS_CALC_ADC_CH0_SWCLK_1_OFFSET 0x150UL
#define POS_CALC_ADC_CH0_SWCLK_1_OFFSET_DATA_MASK 0xffffUL
#define POS_CALC_ADC_CH0_SWCLK_1_OFFSET_DATA_SHIFT 0

/* ADC channel 1 offset on RFFE switch state 1 (inverted)
Uses 2's complement representation and is subtracted from ADC samples.
 */
#define POS_CALC_ADC_CH1_SWCLK_1_OFFSET 0x154UL
#define POS_CALC_ADC_CH1_SWCLK_1_OFFSET_DATA_MASK 0xffffUL
#define POS_CALC_ADC_CH1_SWCLK_1_OFFSET_DATA_SHIFT 0

/* ADC channel 2 offset on RFFE switch state 1 (inverted)
Uses 2's complement representation and is subtracted from ADC samples.
 */
#define POS_CALC_ADC_CH2_SWCLK_1_OFFSET 0x158UL
#define POS_CALC_ADC_CH2_SWCLK_1_OFFSET_DATA_MASK 0xffffUL
#define POS_CALC_ADC_CH2_SWCLK_1_OFFSET_DATA_SHIFT 0

/* ADC channel 3 offset on RFFE switch state 1 (inverted)
Uses 2's complement representation and is subtracted from ADC samples.
 */
#define POS_CALC_ADC_CH3_SWCLK_1_OFFSET 0x15cUL
#define POS_CALC_ADC_CH3_SWCLK_1_OFFSET_DATA_MASK 0xffffUL
#define POS_CALC_ADC_CH3_SWCLK_1_OFFSET_DATA_SHIFT 0

#ifndef __ASSEMBLER__
struct pos_calc {
  /* [0x0]: REG (rw) Config divisor threshold TBT register */
  uint32_t ds_tbt_thres;

  /* [0x4]: REG (rw) Config divisor threshold FOFB register */
  uint32_t ds_fofb_thres;

  /* [0x8]: REG (rw) Config divisor threshold Monit. register */
  uint32_t ds_monit_thres;

  /* [0xc]: REG (rw) BPM sensitivity (X axis) parameter register */
  uint32_t kx;

  /* [0x10]: REG (rw) BPM sensitivity (Y axis) parameter register */
  uint32_t ky;

  /* [0x14]: REG (rw) BPM sensitivity (Sum) parameter register */
  uint32_t ksum;

  /* [0x18]: REG (ro) DSP TBT incorrect TDM counter */
  uint32_t dsp_ctnr_tbt;

  /* [0x1c]: REG (ro) DSP FOFB incorrect TDM counter */
  uint32_t dsp_ctnr_fofb;

  /* [0x20]: REG (ro) DSP Monit. incorrect TDM counter part 1 */
  uint32_t dsp_ctnr1_monit;

  /* [0x24]: REG (ro) DSP Monit. incorrect TDM counter part 2 */
  uint32_t dsp_ctnr2_monit;

  /* [0x28]: REG (wo) DSP error clearing */
  uint32_t dsp_err_clr;

  /* [0x2c]: REG (rw) DDS general config registers for all channels */
  uint32_t dds_cfg;

  /* [0x30]: REG (rw) DDS phase increment parameter register for channel 0 */
  uint32_t dds_pinc_ch0;

  /* [0x34]: REG (rw) DDS phase increment parameter register for channel 1 */
  uint32_t dds_pinc_ch1;

  /* [0x38]: REG (rw) DDS phase increment parameter register for channel 2 */
  uint32_t dds_pinc_ch2;

  /* [0x3c]: REG (rw) DDS phase increment parameter register for channel 3 */
  uint32_t dds_pinc_ch3;

  /* [0x40]: REG (rw) DDS phase offset parameter register for channel 0 */
  uint32_t dds_poff_ch0;

  /* [0x44]: REG (rw) DDS phase offset parameter register for channel 1 */
  uint32_t dds_poff_ch1;

  /* [0x48]: REG (rw) DDS phase offset parameter register for channel 2 */
  uint32_t dds_poff_ch2;

  /* [0x4c]: REG (rw) DDS phase offset parameter register for channel 3 */
  uint32_t dds_poff_ch3;

  /* [0x50]: REG (ro) Monit. Amplitude Value for channel 0 */
  uint32_t dsp_monit_amp_ch0;

  /* [0x54]: REG (ro) Monit. Amplitude Value for channel 1 */
  uint32_t dsp_monit_amp_ch1;

  /* [0x58]: REG (ro) Monit. Amplitude Value for channel 2 */
  uint32_t dsp_monit_amp_ch2;

  /* [0x5c]: REG (ro) Monit. Amplitude Value for channel 3 */
  uint32_t dsp_monit_amp_ch3;

  /* [0x60]: REG (ro) Monit. X Position Value */
  uint32_t dsp_monit_pos_x;

  /* [0x64]: REG (ro) Monit. Y Position Value */
  uint32_t dsp_monit_pos_y;

  /* [0x68]: REG (ro) Monit. Q Position Value */
  uint32_t dsp_monit_pos_q;

  /* [0x6c]: REG (ro) Monit. Sum Position Value */
  uint32_t dsp_monit_pos_sum;

  /* [0x70]: REG (wo) Monit. Amp/Pos update trigger */
  uint32_t dsp_monit_updt;

  /* [0x74]: REG (ro) Monit. 1 Amplitude Value for channel 0 */
  uint32_t dsp_monit1_amp_ch0;

  /* [0x78]: REG (ro) Monit. 1 Amplitude Value for channel 1 */
  uint32_t dsp_monit1_amp_ch1;

  /* [0x7c]: REG (ro) Monit. 1 Amplitude Value for channel 2 */
  uint32_t dsp_monit1_amp_ch2;

  /* [0x80]: REG (ro) Monit. 1 Amplitude Value for channel 3 */
  uint32_t dsp_monit1_amp_ch3;

  /* [0x84]: REG (ro) Monit. 1 X Position Value */
  uint32_t dsp_monit1_pos_x;

  /* [0x88]: REG (ro) Monit. 1 Y Position Value */
  uint32_t dsp_monit1_pos_y;

  /* [0x8c]: REG (ro) Monit. 1 Q Position Value */
  uint32_t dsp_monit1_pos_q;

  /* [0x90]: REG (ro) Monit. 1 Sum Position Value */
  uint32_t dsp_monit1_pos_sum;

  /* [0x94]: REG (wo) Monit. 1 Amp/Pos update trigger */
  uint32_t dsp_monit1_updt;

  /* [0x98]: BLOCK AMP FIFO Monitoring */
  struct ampfifo_monit {
    /* [0x0]: REG (ro) FIFO 'AMP FIFO Monitoring' data output register 0 */
    uint32_t ampfifo_monit_r0;

    /* [0x4]: REG (ro) FIFO 'AMP FIFO Monitoring' data output register 1 */
    uint32_t ampfifo_monit_r1;

    /* [0x8]: REG (ro) FIFO 'AMP FIFO Monitoring' data output register 2 */
    uint32_t ampfifo_monit_r2;

    /* [0xc]: REG (ro) FIFO 'AMP FIFO Monitoring' data output register 3 */
    uint32_t ampfifo_monit_r3;

    /* [0x10]: REG (ro) FIFO 'AMP FIFO Monitoring' control/status register */
    uint32_t ampfifo_monit_csr;
  } ampfifo_monit;

  /* [0xac]: BLOCK POS FIFO Monitoring */
  struct posfifo_monit {
    /* [0x0]: REG (ro) FIFO 'POS FIFO Monitoring' data output register 0 */
    uint32_t posfifo_monit_r0;

    /* [0x4]: REG (ro) FIFO 'POS FIFO Monitoring' data output register 1 */
    uint32_t posfifo_monit_r1;

    /* [0x8]: REG (ro) FIFO 'POS FIFO Monitoring' data output register 2 */
    uint32_t posfifo_monit_r2;

    /* [0xc]: REG (ro) FIFO 'POS FIFO Monitoring' data output register 3 */
    uint32_t posfifo_monit_r3;

    /* [0x10]: REG (ro) FIFO 'POS FIFO Monitoring' control/status register */
    uint32_t posfifo_monit_csr;
  } posfifo_monit;

  /* [0xc0]: BLOCK AMP FIFO Monitoring 1 */
  struct ampfifo_monit1 {
    /* [0x0]: REG (ro) FIFO 'AMP FIFO Monitoring 1' data output register 0 */
    uint32_t ampfifo_monit1_r0;

    /* [0x4]: REG (ro) FIFO 'AMP FIFO Monitoring 1' data output register 1 */
    uint32_t ampfifo_monit1_r1;

    /* [0x8]: REG (ro) FIFO 'AMP FIFO Monitoring 1' data output register 2 */
    uint32_t ampfifo_monit1_r2;

    /* [0xc]: REG (ro) FIFO 'AMP FIFO Monitoring 1' data output register 3 */
    uint32_t ampfifo_monit1_r3;

    /* [0x10]: REG (ro) FIFO 'AMP FIFO Monitoring 1' control/status register */
    uint32_t ampfifo_monit1_csr;
  } ampfifo_monit1;

  /* [0xd4]: BLOCK POS FIFO Monitoring 1 */
  struct posfifo_monit1 {
    /* [0x0]: REG (ro) FIFO 'POS FIFO Monitoring 1' data output register 0 */
    uint32_t posfifo_monit1_r0;

    /* [0x4]: REG (ro) FIFO 'POS FIFO Monitoring 1' data output register 1 */
    uint32_t posfifo_monit1_r1;

    /* [0x8]: REG (ro) FIFO 'POS FIFO Monitoring 1' data output register 2 */
    uint32_t posfifo_monit1_r2;

    /* [0xc]: REG (ro) FIFO 'POS FIFO Monitoring 1' data output register 3 */
    uint32_t posfifo_monit1_r3;

    /* [0x10]: REG (ro) FIFO 'POS FIFO Monitoring 1' control/status register */
    uint32_t posfifo_monit1_csr;
  } posfifo_monit1;

  /* [0xe8]: REG (rw) Switching Tag synchronization */
  uint32_t sw_tag;

  /* [0xec]: REG (rw) Switching Data Mask */
  uint32_t sw_data_mask;

  /* [0xf0]: REG (rw) TbT Synchronizing Trigger */
  uint32_t tbt_tag;

  /* [0xf4]: REG (rw) TbT Masking Control */
  uint32_t tbt_data_mask_ctl;

  /* [0xf8]: REG (rw) TbT Data Masking Samples */
  uint32_t tbt_data_mask_samples;

  /* [0xfc]: REG (rw) MONIT1 Synchronizing Trigger */
  uint32_t monit1_tag;

  /* [0x100]: REG (rw) MONIT1 Masking Control */
  uint32_t monit1_data_mask_ctl;

  /* [0x104]: REG (rw) MONIT1 Data Masking Samples */
  uint32_t monit1_data_mask_samples;

  /* [0x108]: REG (rw) MONIT Synchronizing Trigger */
  uint32_t monit_tag;

  /* [0x10c]: REG (rw) MONIT Masking Control */
  uint32_t monit_data_mask_ctl;

  /* [0x110]: REG (rw) MONIT Data Masking Samples */
  uint32_t monit_data_mask_samples;

  /* [0x114]: REG (rw) BPM X position offset parameter register */
  uint32_t offset_x;

  /* [0x118]: REG (rw) BPM Y position offset parameter register */
  uint32_t offset_y;

  /* [0x11c]: REG (ro) ADC gains fixed-point position constant */
  uint32_t adc_gains_fixed_point_pos;

  /* [0x120]: REG (rw) ADC channel 0 gain on RFFE switch state 0 (direct) */
  uint32_t adc_ch0_swclk_0_gain;

  /* [0x124]: REG (rw) ADC channel 1 gain on RFFE switch state 0 (direct) */
  uint32_t adc_ch1_swclk_0_gain;

  /* [0x128]: REG (rw) ADC channel 2 gain on RFFE switch state 0 (direct) */
  uint32_t adc_ch2_swclk_0_gain;

  /* [0x12c]: REG (rw) ADC channel 3 gain on RFFE switch state 0 (direct) */
  uint32_t adc_ch3_swclk_0_gain;

  /* [0x130]: REG (rw) ADC channel 0 gain on RFFE switch state 1 (inverted) */
  uint32_t adc_ch0_swclk_1_gain;

  /* [0x134]: REG (rw) ADC channel 1 gain on RFFE switch state 1 (inverted) */
  uint32_t adc_ch1_swclk_1_gain;

  /* [0x138]: REG (rw) ADC channel 2 gain on RFFE switch state 1 (inverted) */
  uint32_t adc_ch2_swclk_1_gain;

  /* [0x13c]: REG (rw) ADC channel 3 gain on RFFE switch state 1 (inverted) */
  uint32_t adc_ch3_swclk_1_gain;

  /* [0x140]: REG (rw) ADC channel 0 offset on RFFE switch state 0 (direct)
Uses 2's complement representation and is subtracted from ADC samples.
 */
  uint32_t adc_ch0_swclk_0_offset;

  /* [0x144]: REG (rw) ADC channel 1 offset on RFFE switch state 0 (direct)
Uses 2's complement representation and is subtracted from ADC samples.
 */
  uint32_t adc_ch1_swclk_0_offset;

  /* [0x148]: REG (rw) ADC channel 2 offset on RFFE switch state 0 (direct)
Uses 2's complement representation and is subtracted from ADC samples.
 */
  uint32_t adc_ch2_swclk_0_offset;

  /* [0x14c]: REG (rw) ADC channel 3 offset on RFFE switch state 0 (direct)
Uses 2's complement representation and is subtracted from ADC samples.
 */
  uint32_t adc_ch3_swclk_0_offset;

  /* [0x150]: REG (rw) ADC channel 0 offset on RFFE switch state 1 (inverted)
Uses 2's complement representation and is subtracted from ADC samples.
 */
  uint32_t adc_ch0_swclk_1_offset;

  /* [0x154]: REG (rw) ADC channel 1 offset on RFFE switch state 1 (inverted)
Uses 2's complement representation and is subtracted from ADC samples.
 */
  uint32_t adc_ch1_swclk_1_offset;

  /* [0x158]: REG (rw) ADC channel 2 offset on RFFE switch state 1 (inverted)
Uses 2's complement representation and is subtracted from ADC samples.
 */
  uint32_t adc_ch2_swclk_1_offset;

  /* [0x15c]: REG (rw) ADC channel 3 offset on RFFE switch state 1 (inverted)
Uses 2's complement representation and is subtracted from ADC samples.
 */
  uint32_t adc_ch3_swclk_1_offset;
};
#endif /* !__ASSEMBLER__*/

#endif /* __CHEBY__POS_CALC__H__ */
