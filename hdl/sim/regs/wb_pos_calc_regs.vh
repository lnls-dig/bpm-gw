// Do not edit.  Generated by cheby 1.6.dev0 using these options:
//  -i wb_pos_calc_regs.cheby --hdl vhdl --gen-wbgen-hdl wb_pos_calc_regs.vhd --doc html --gen-doc doc/wb_pos_calc_regs_wb.html --gen-c wb_pos_calc_regs.h --consts-style verilog --gen-consts ../../../sim/regs/wb_pos_calc_regs.vh
// Generated on Mon Jul 22 15:15:26 2024 by guilherme.ricioli

`define POS_CALC_SIZE 352
`define ADDR_POS_CALC_DS_TBT_THRES 'h0
`define POS_CALC_DS_TBT_THRES_VAL_OFFSET 0
`define POS_CALC_DS_TBT_THRES_VAL 'h3ffffff
`define POS_CALC_DS_TBT_THRES_RESERVED_OFFSET 26
`define POS_CALC_DS_TBT_THRES_RESERVED 'hfc000000
`define ADDR_POS_CALC_DS_FOFB_THRES 'h4
`define POS_CALC_DS_FOFB_THRES_VAL_OFFSET 0
`define POS_CALC_DS_FOFB_THRES_VAL 'h3ffffff
`define POS_CALC_DS_FOFB_THRES_RESERVED_OFFSET 26
`define POS_CALC_DS_FOFB_THRES_RESERVED 'hfc000000
`define ADDR_POS_CALC_DS_MONIT_THRES 'h8
`define POS_CALC_DS_MONIT_THRES_VAL_OFFSET 0
`define POS_CALC_DS_MONIT_THRES_VAL 'h3ffffff
`define POS_CALC_DS_MONIT_THRES_RESERVED_OFFSET 26
`define POS_CALC_DS_MONIT_THRES_RESERVED 'hfc000000
`define ADDR_POS_CALC_KX 'hc
`define POS_CALC_KX_VAL_OFFSET 0
`define POS_CALC_KX_VAL 'h1ffffff
`define POS_CALC_KX_RESERVED_OFFSET 25
`define POS_CALC_KX_RESERVED 'hfe000000
`define ADDR_POS_CALC_KY 'h10
`define POS_CALC_KY_VAL_OFFSET 0
`define POS_CALC_KY_VAL 'h1ffffff
`define POS_CALC_KY_RESERVED_OFFSET 25
`define POS_CALC_KY_RESERVED 'hfe000000
`define ADDR_POS_CALC_KSUM 'h14
`define POS_CALC_KSUM_VAL_OFFSET 0
`define POS_CALC_KSUM_VAL 'h1ffffff
`define POS_CALC_KSUM_RESERVED_OFFSET 25
`define POS_CALC_KSUM_RESERVED 'hfe000000
`define ADDR_POS_CALC_DSP_CTNR_TBT 'h18
`define POS_CALC_DSP_CTNR_TBT_CH01_OFFSET 0
`define POS_CALC_DSP_CTNR_TBT_CH01 'hffff
`define POS_CALC_DSP_CTNR_TBT_CH23_OFFSET 16
`define POS_CALC_DSP_CTNR_TBT_CH23 'hffff0000
`define ADDR_POS_CALC_DSP_CTNR_FOFB 'h1c
`define POS_CALC_DSP_CTNR_FOFB_CH01_OFFSET 0
`define POS_CALC_DSP_CTNR_FOFB_CH01 'hffff
`define POS_CALC_DSP_CTNR_FOFB_CH23_OFFSET 16
`define POS_CALC_DSP_CTNR_FOFB_CH23 'hffff0000
`define ADDR_POS_CALC_DSP_CTNR1_MONIT 'h20
`define POS_CALC_DSP_CTNR1_MONIT_CIC_OFFSET 0
`define POS_CALC_DSP_CTNR1_MONIT_CIC 'hffff
`define POS_CALC_DSP_CTNR1_MONIT_CFIR_OFFSET 16
`define POS_CALC_DSP_CTNR1_MONIT_CFIR 'hffff0000
`define ADDR_POS_CALC_DSP_CTNR2_MONIT 'h24
`define POS_CALC_DSP_CTNR2_MONIT_PFIR_OFFSET 0
`define POS_CALC_DSP_CTNR2_MONIT_PFIR 'hffff
`define POS_CALC_DSP_CTNR2_MONIT_FIR_01_OFFSET 16
`define POS_CALC_DSP_CTNR2_MONIT_FIR_01 'hffff0000
`define ADDR_POS_CALC_DSP_ERR_CLR 'h28
`define POS_CALC_DSP_ERR_CLR_TBT_OFFSET 0
`define POS_CALC_DSP_ERR_CLR_TBT 'h1
`define POS_CALC_DSP_ERR_CLR_FOFB_OFFSET 1
`define POS_CALC_DSP_ERR_CLR_FOFB 'h2
`define POS_CALC_DSP_ERR_CLR_MONIT_PART1_OFFSET 2
`define POS_CALC_DSP_ERR_CLR_MONIT_PART1 'h4
`define POS_CALC_DSP_ERR_CLR_MONIT_PART2_OFFSET 3
`define POS_CALC_DSP_ERR_CLR_MONIT_PART2 'h8
`define ADDR_POS_CALC_DDS_CFG 'h2c
`define POS_CALC_DDS_CFG_VALID_CH0_OFFSET 0
`define POS_CALC_DDS_CFG_VALID_CH0 'h1
`define POS_CALC_DDS_CFG_TEST_DATA_OFFSET 1
`define POS_CALC_DDS_CFG_TEST_DATA 'h2
`define POS_CALC_DDS_CFG_RESERVED_CH0_OFFSET 2
`define POS_CALC_DDS_CFG_RESERVED_CH0 'hfc
`define POS_CALC_DDS_CFG_VALID_CH1_OFFSET 8
`define POS_CALC_DDS_CFG_VALID_CH1 'h100
`define POS_CALC_DDS_CFG_RESERVED_CH1_OFFSET 9
`define POS_CALC_DDS_CFG_RESERVED_CH1 'hfe00
`define POS_CALC_DDS_CFG_VALID_CH2_OFFSET 16
`define POS_CALC_DDS_CFG_VALID_CH2 'h10000
`define POS_CALC_DDS_CFG_RESERVED_CH2_OFFSET 17
`define POS_CALC_DDS_CFG_RESERVED_CH2 'hfe0000
`define POS_CALC_DDS_CFG_VALID_CH3_OFFSET 24
`define POS_CALC_DDS_CFG_VALID_CH3 'h1000000
`define POS_CALC_DDS_CFG_RESERVED_CH3_OFFSET 25
`define POS_CALC_DDS_CFG_RESERVED_CH3 'hfe000000
`define ADDR_POS_CALC_DDS_PINC_CH0 'h30
`define POS_CALC_DDS_PINC_CH0_VAL_OFFSET 0
`define POS_CALC_DDS_PINC_CH0_VAL 'h3fffffff
`define POS_CALC_DDS_PINC_CH0_RESERVED_OFFSET 30
`define POS_CALC_DDS_PINC_CH0_RESERVED 'hc0000000
`define ADDR_POS_CALC_DDS_PINC_CH1 'h34
`define POS_CALC_DDS_PINC_CH1_VAL_OFFSET 0
`define POS_CALC_DDS_PINC_CH1_VAL 'h3fffffff
`define POS_CALC_DDS_PINC_CH1_RESERVED_OFFSET 30
`define POS_CALC_DDS_PINC_CH1_RESERVED 'hc0000000
`define ADDR_POS_CALC_DDS_PINC_CH2 'h38
`define POS_CALC_DDS_PINC_CH2_VAL_OFFSET 0
`define POS_CALC_DDS_PINC_CH2_VAL 'h3fffffff
`define POS_CALC_DDS_PINC_CH2_RESERVED_OFFSET 30
`define POS_CALC_DDS_PINC_CH2_RESERVED 'hc0000000
`define ADDR_POS_CALC_DDS_PINC_CH3 'h3c
`define POS_CALC_DDS_PINC_CH3_VAL_OFFSET 0
`define POS_CALC_DDS_PINC_CH3_VAL 'h3fffffff
`define POS_CALC_DDS_PINC_CH3_RESERVED_OFFSET 30
`define POS_CALC_DDS_PINC_CH3_RESERVED 'hc0000000
`define ADDR_POS_CALC_DDS_POFF_CH0 'h40
`define POS_CALC_DDS_POFF_CH0_VAL_OFFSET 0
`define POS_CALC_DDS_POFF_CH0_VAL 'h3fffffff
`define POS_CALC_DDS_POFF_CH0_RESERVED_OFFSET 30
`define POS_CALC_DDS_POFF_CH0_RESERVED 'hc0000000
`define ADDR_POS_CALC_DDS_POFF_CH1 'h44
`define POS_CALC_DDS_POFF_CH1_VAL_OFFSET 0
`define POS_CALC_DDS_POFF_CH1_VAL 'h3fffffff
`define POS_CALC_DDS_POFF_CH1_RESERVED_OFFSET 30
`define POS_CALC_DDS_POFF_CH1_RESERVED 'hc0000000
`define ADDR_POS_CALC_DDS_POFF_CH2 'h48
`define POS_CALC_DDS_POFF_CH2_VAL_OFFSET 0
`define POS_CALC_DDS_POFF_CH2_VAL 'h3fffffff
`define POS_CALC_DDS_POFF_CH2_RESERVED_OFFSET 30
`define POS_CALC_DDS_POFF_CH2_RESERVED 'hc0000000
`define ADDR_POS_CALC_DDS_POFF_CH3 'h4c
`define POS_CALC_DDS_POFF_CH3_VAL_OFFSET 0
`define POS_CALC_DDS_POFF_CH3_VAL 'h3fffffff
`define POS_CALC_DDS_POFF_CH3_RESERVED_OFFSET 30
`define POS_CALC_DDS_POFF_CH3_RESERVED 'hc0000000
`define ADDR_POS_CALC_DSP_MONIT_AMP_CH0 'h50
`define ADDR_POS_CALC_DSP_MONIT_AMP_CH1 'h54
`define ADDR_POS_CALC_DSP_MONIT_AMP_CH2 'h58
`define ADDR_POS_CALC_DSP_MONIT_AMP_CH3 'h5c
`define ADDR_POS_CALC_DSP_MONIT_POS_X 'h60
`define ADDR_POS_CALC_DSP_MONIT_POS_Y 'h64
`define ADDR_POS_CALC_DSP_MONIT_POS_Q 'h68
`define ADDR_POS_CALC_DSP_MONIT_POS_SUM 'h6c
`define ADDR_POS_CALC_DSP_MONIT_UPDT 'h70
`define ADDR_POS_CALC_DSP_MONIT1_AMP_CH0 'h74
`define ADDR_POS_CALC_DSP_MONIT1_AMP_CH1 'h78
`define ADDR_POS_CALC_DSP_MONIT1_AMP_CH2 'h7c
`define ADDR_POS_CALC_DSP_MONIT1_AMP_CH3 'h80
`define ADDR_POS_CALC_DSP_MONIT1_POS_X 'h84
`define ADDR_POS_CALC_DSP_MONIT1_POS_Y 'h88
`define ADDR_POS_CALC_DSP_MONIT1_POS_Q 'h8c
`define ADDR_POS_CALC_DSP_MONIT1_POS_SUM 'h90
`define ADDR_POS_CALC_DSP_MONIT1_UPDT 'h94
`define ADDR_POS_CALC_AMPFIFO_MONIT 'h98
`define POS_CALC_AMPFIFO_MONIT_SIZE 20
`define ADDR_POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R0 'h98
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R0_AMP_CH0_OFFSET 0
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R0_AMP_CH0 'hffffffff
`define ADDR_POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R1 'h9c
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R1_AMP_CH1_OFFSET 0
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R1_AMP_CH1 'hffffffff
`define ADDR_POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R2 'ha0
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R2_AMP_CH2_OFFSET 0
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R2_AMP_CH2 'hffffffff
`define ADDR_POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R3 'ha4
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R3_AMP_CH3_OFFSET 0
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_R3_AMP_CH3 'hffffffff
`define ADDR_POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR 'ha8
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR_FULL_OFFSET 16
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR_FULL 'h10000
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR_EMPTY_OFFSET 17
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR_EMPTY 'h20000
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR_COUNT_OFFSET 0
`define POS_CALC_AMPFIFO_MONIT_AMPFIFO_MONIT_CSR_COUNT 'hf
`define ADDR_POS_CALC_POSFIFO_MONIT 'hac
`define POS_CALC_POSFIFO_MONIT_SIZE 20
`define ADDR_POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R0 'hac
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R0_POS_X_OFFSET 0
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R0_POS_X 'hffffffff
`define ADDR_POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R1 'hb0
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R1_POS_Y_OFFSET 0
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R1_POS_Y 'hffffffff
`define ADDR_POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R2 'hb4
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R2_POS_Q_OFFSET 0
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R2_POS_Q 'hffffffff
`define ADDR_POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R3 'hb8
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R3_POS_SUM_OFFSET 0
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_R3_POS_SUM 'hffffffff
`define ADDR_POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR 'hbc
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR_FULL_OFFSET 16
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR_FULL 'h10000
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR_EMPTY_OFFSET 17
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR_EMPTY 'h20000
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR_COUNT_OFFSET 0
`define POS_CALC_POSFIFO_MONIT_POSFIFO_MONIT_CSR_COUNT 'hf
`define ADDR_POS_CALC_AMPFIFO_MONIT1 'hc0
`define POS_CALC_AMPFIFO_MONIT1_SIZE 20
`define ADDR_POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R0 'hc0
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R0_AMP_CH0_OFFSET 0
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R0_AMP_CH0 'hffffffff
`define ADDR_POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R1 'hc4
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R1_AMP_CH1_OFFSET 0
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R1_AMP_CH1 'hffffffff
`define ADDR_POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R2 'hc8
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R2_AMP_CH2_OFFSET 0
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R2_AMP_CH2 'hffffffff
`define ADDR_POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R3 'hcc
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R3_AMP_CH3_OFFSET 0
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_R3_AMP_CH3 'hffffffff
`define ADDR_POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR 'hd0
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR_FULL_OFFSET 16
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR_FULL 'h10000
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR_EMPTY_OFFSET 17
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR_EMPTY 'h20000
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR_COUNT_OFFSET 0
`define POS_CALC_AMPFIFO_MONIT1_AMPFIFO_MONIT1_CSR_COUNT 'hf
`define ADDR_POS_CALC_POSFIFO_MONIT1 'hd4
`define POS_CALC_POSFIFO_MONIT1_SIZE 20
`define ADDR_POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R0 'hd4
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R0_POS_X_OFFSET 0
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R0_POS_X 'hffffffff
`define ADDR_POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R1 'hd8
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R1_POS_Y_OFFSET 0
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R1_POS_Y 'hffffffff
`define ADDR_POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R2 'hdc
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R2_POS_Q_OFFSET 0
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R2_POS_Q 'hffffffff
`define ADDR_POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R3 'he0
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R3_POS_SUM_OFFSET 0
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_R3_POS_SUM 'hffffffff
`define ADDR_POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR 'he4
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR_FULL_OFFSET 16
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR_FULL 'h10000
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR_EMPTY_OFFSET 17
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR_EMPTY 'h20000
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR_COUNT_OFFSET 0
`define POS_CALC_POSFIFO_MONIT1_POSFIFO_MONIT1_CSR_COUNT 'hf
`define ADDR_POS_CALC_SW_TAG 'he8
`define POS_CALC_SW_TAG_EN_OFFSET 0
`define POS_CALC_SW_TAG_EN 'h1
`define POS_CALC_SW_TAG_DESYNC_CNT_RST_OFFSET 8
`define POS_CALC_SW_TAG_DESYNC_CNT_RST 'h100
`define POS_CALC_SW_TAG_DESYNC_CNT_OFFSET 9
`define POS_CALC_SW_TAG_DESYNC_CNT 'h7ffe00
`define ADDR_POS_CALC_SW_DATA_MASK 'hec
`define POS_CALC_SW_DATA_MASK_EN_OFFSET 0
`define POS_CALC_SW_DATA_MASK_EN 'h1
`define POS_CALC_SW_DATA_MASK_SAMPLES_OFFSET 1
`define POS_CALC_SW_DATA_MASK_SAMPLES 'h1fffe
`define ADDR_POS_CALC_TBT_TAG 'hf0
`define POS_CALC_TBT_TAG_EN_OFFSET 0
`define POS_CALC_TBT_TAG_EN 'h1
`define POS_CALC_TBT_TAG_DLY_OFFSET 1
`define POS_CALC_TBT_TAG_DLY 'h1fffe
`define POS_CALC_TBT_TAG_DESYNC_CNT_RST_OFFSET 17
`define POS_CALC_TBT_TAG_DESYNC_CNT_RST 'h20000
`define POS_CALC_TBT_TAG_DESYNC_CNT_OFFSET 18
`define POS_CALC_TBT_TAG_DESYNC_CNT 'hfffc0000
`define ADDR_POS_CALC_TBT_DATA_MASK_CTL 'hf4
`define POS_CALC_TBT_DATA_MASK_CTL_EN_OFFSET 0
`define POS_CALC_TBT_DATA_MASK_CTL_EN 'h1
`define ADDR_POS_CALC_TBT_DATA_MASK_SAMPLES 'hf8
`define POS_CALC_TBT_DATA_MASK_SAMPLES_BEG_OFFSET 0
`define POS_CALC_TBT_DATA_MASK_SAMPLES_BEG 'hffff
`define POS_CALC_TBT_DATA_MASK_SAMPLES_END_OFFSET 16
`define POS_CALC_TBT_DATA_MASK_SAMPLES_END 'hffff0000
`define ADDR_POS_CALC_MONIT1_TAG 'hfc
`define POS_CALC_MONIT1_TAG_EN_OFFSET 0
`define POS_CALC_MONIT1_TAG_EN 'h1
`define POS_CALC_MONIT1_TAG_DLY_OFFSET 1
`define POS_CALC_MONIT1_TAG_DLY 'h1fffe
`define POS_CALC_MONIT1_TAG_DESYNC_CNT_RST_OFFSET 17
`define POS_CALC_MONIT1_TAG_DESYNC_CNT_RST 'h20000
`define POS_CALC_MONIT1_TAG_DESYNC_CNT_OFFSET 18
`define POS_CALC_MONIT1_TAG_DESYNC_CNT 'hfffc0000
`define ADDR_POS_CALC_MONIT1_DATA_MASK_CTL 'h100
`define POS_CALC_MONIT1_DATA_MASK_CTL_EN_OFFSET 0
`define POS_CALC_MONIT1_DATA_MASK_CTL_EN 'h1
`define ADDR_POS_CALC_MONIT1_DATA_MASK_SAMPLES 'h104
`define POS_CALC_MONIT1_DATA_MASK_SAMPLES_BEG_OFFSET 0
`define POS_CALC_MONIT1_DATA_MASK_SAMPLES_BEG 'hffff
`define POS_CALC_MONIT1_DATA_MASK_SAMPLES_END_OFFSET 16
`define POS_CALC_MONIT1_DATA_MASK_SAMPLES_END 'hffff0000
`define ADDR_POS_CALC_MONIT_TAG 'h108
`define POS_CALC_MONIT_TAG_EN_OFFSET 0
`define POS_CALC_MONIT_TAG_EN 'h1
`define POS_CALC_MONIT_TAG_DLY_OFFSET 1
`define POS_CALC_MONIT_TAG_DLY 'h1fffe
`define POS_CALC_MONIT_TAG_DESYNC_CNT_RST_OFFSET 17
`define POS_CALC_MONIT_TAG_DESYNC_CNT_RST 'h20000
`define POS_CALC_MONIT_TAG_DESYNC_CNT_OFFSET 18
`define POS_CALC_MONIT_TAG_DESYNC_CNT 'hfffc0000
`define ADDR_POS_CALC_MONIT_DATA_MASK_CTL 'h10c
`define POS_CALC_MONIT_DATA_MASK_CTL_EN_OFFSET 0
`define POS_CALC_MONIT_DATA_MASK_CTL_EN 'h1
`define ADDR_POS_CALC_MONIT_DATA_MASK_SAMPLES 'h110
`define POS_CALC_MONIT_DATA_MASK_SAMPLES_BEG_OFFSET 0
`define POS_CALC_MONIT_DATA_MASK_SAMPLES_BEG 'hffff
`define POS_CALC_MONIT_DATA_MASK_SAMPLES_END_OFFSET 16
`define POS_CALC_MONIT_DATA_MASK_SAMPLES_END 'hffff0000
`define ADDR_POS_CALC_OFFSET_X 'h114
`define ADDR_POS_CALC_OFFSET_Y 'h118
`define ADDR_POS_CALC_ADC_GAINS_FIXED_POINT_POS 'h11c
`define POS_CALC_ADC_GAINS_FIXED_POINT_POS_DATA_OFFSET 0
`define POS_CALC_ADC_GAINS_FIXED_POINT_POS_DATA 'hffffffff
`define ADDR_POS_CALC_ADC_CH0_SWCLK_0_GAIN 'h120
`define POS_CALC_ADC_CH0_SWCLK_0_GAIN_DATA_OFFSET 0
`define POS_CALC_ADC_CH0_SWCLK_0_GAIN_DATA 'hffffffff
`define ADDR_POS_CALC_ADC_CH1_SWCLK_0_GAIN 'h124
`define POS_CALC_ADC_CH1_SWCLK_0_GAIN_DATA_OFFSET 0
`define POS_CALC_ADC_CH1_SWCLK_0_GAIN_DATA 'hffffffff
`define ADDR_POS_CALC_ADC_CH2_SWCLK_0_GAIN 'h128
`define POS_CALC_ADC_CH2_SWCLK_0_GAIN_DATA_OFFSET 0
`define POS_CALC_ADC_CH2_SWCLK_0_GAIN_DATA 'hffffffff
`define ADDR_POS_CALC_ADC_CH3_SWCLK_0_GAIN 'h12c
`define POS_CALC_ADC_CH3_SWCLK_0_GAIN_DATA_OFFSET 0
`define POS_CALC_ADC_CH3_SWCLK_0_GAIN_DATA 'hffffffff
`define ADDR_POS_CALC_ADC_CH0_SWCLK_1_GAIN 'h130
`define POS_CALC_ADC_CH0_SWCLK_1_GAIN_DATA_OFFSET 0
`define POS_CALC_ADC_CH0_SWCLK_1_GAIN_DATA 'hffffffff
`define ADDR_POS_CALC_ADC_CH1_SWCLK_1_GAIN 'h134
`define POS_CALC_ADC_CH1_SWCLK_1_GAIN_DATA_OFFSET 0
`define POS_CALC_ADC_CH1_SWCLK_1_GAIN_DATA 'hffffffff
`define ADDR_POS_CALC_ADC_CH2_SWCLK_1_GAIN 'h138
`define POS_CALC_ADC_CH2_SWCLK_1_GAIN_DATA_OFFSET 0
`define POS_CALC_ADC_CH2_SWCLK_1_GAIN_DATA 'hffffffff
`define ADDR_POS_CALC_ADC_CH3_SWCLK_1_GAIN 'h13c
`define POS_CALC_ADC_CH3_SWCLK_1_GAIN_DATA_OFFSET 0
`define POS_CALC_ADC_CH3_SWCLK_1_GAIN_DATA 'hffffffff
`define ADDR_POS_CALC_ADC_CH0_SWCLK_0_OFFSET 'h140
`define POS_CALC_ADC_CH0_SWCLK_0_OFFSET_DATA_OFFSET 0
`define POS_CALC_ADC_CH0_SWCLK_0_OFFSET_DATA 'hffff
`define ADDR_POS_CALC_ADC_CH1_SWCLK_0_OFFSET 'h144
`define POS_CALC_ADC_CH1_SWCLK_0_OFFSET_DATA_OFFSET 0
`define POS_CALC_ADC_CH1_SWCLK_0_OFFSET_DATA 'hffff
`define ADDR_POS_CALC_ADC_CH2_SWCLK_0_OFFSET 'h148
`define POS_CALC_ADC_CH2_SWCLK_0_OFFSET_DATA_OFFSET 0
`define POS_CALC_ADC_CH2_SWCLK_0_OFFSET_DATA 'hffff
`define ADDR_POS_CALC_ADC_CH3_SWCLK_0_OFFSET 'h14c
`define POS_CALC_ADC_CH3_SWCLK_0_OFFSET_DATA_OFFSET 0
`define POS_CALC_ADC_CH3_SWCLK_0_OFFSET_DATA 'hffff
`define ADDR_POS_CALC_ADC_CH0_SWCLK_1_OFFSET 'h150
`define POS_CALC_ADC_CH0_SWCLK_1_OFFSET_DATA_OFFSET 0
`define POS_CALC_ADC_CH0_SWCLK_1_OFFSET_DATA 'hffff
`define ADDR_POS_CALC_ADC_CH1_SWCLK_1_OFFSET 'h154
`define POS_CALC_ADC_CH1_SWCLK_1_OFFSET_DATA_OFFSET 0
`define POS_CALC_ADC_CH1_SWCLK_1_OFFSET_DATA 'hffff
`define ADDR_POS_CALC_ADC_CH2_SWCLK_1_OFFSET 'h158
`define POS_CALC_ADC_CH2_SWCLK_1_OFFSET_DATA_OFFSET 0
`define POS_CALC_ADC_CH2_SWCLK_1_OFFSET_DATA 'hffff
`define ADDR_POS_CALC_ADC_CH3_SWCLK_1_OFFSET 'h15c
`define POS_CALC_ADC_CH3_SWCLK_1_OFFSET_DATA_OFFSET 0
`define POS_CALC_ADC_CH3_SWCLK_1_OFFSET_DATA 'hffff
