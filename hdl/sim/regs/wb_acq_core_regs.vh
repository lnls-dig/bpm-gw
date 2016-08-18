`define ADDR_ACQ_CORE_CTL              6'h0
`define ACQ_CORE_CTL_FSM_START_ACQ_OFFSET 0
`define ACQ_CORE_CTL_FSM_START_ACQ 32'h00000001
`define ACQ_CORE_CTL_FSM_STOP_ACQ_OFFSET 1
`define ACQ_CORE_CTL_FSM_STOP_ACQ 32'h00000002
`define ACQ_CORE_CTL_RESERVED1_OFFSET 2
`define ACQ_CORE_CTL_RESERVED1 32'h0000fffc
`define ACQ_CORE_CTL_FSM_ACQ_NOW_OFFSET 16
`define ACQ_CORE_CTL_FSM_ACQ_NOW 32'h00010000
`define ACQ_CORE_CTL_RESERVED2_OFFSET 17
`define ACQ_CORE_CTL_RESERVED2 32'hfffe0000
`define ADDR_ACQ_CORE_STA              6'h4
`define ACQ_CORE_STA_FSM_STATE_OFFSET 0
`define ACQ_CORE_STA_FSM_STATE 32'h00000007
`define ACQ_CORE_STA_FSM_ACQ_DONE_OFFSET 3
`define ACQ_CORE_STA_FSM_ACQ_DONE 32'h00000008
`define ACQ_CORE_STA_RESERVED1_OFFSET 4
`define ACQ_CORE_STA_RESERVED1 32'h000000f0
`define ACQ_CORE_STA_FC_TRANS_DONE_OFFSET 8
`define ACQ_CORE_STA_FC_TRANS_DONE 32'h00000100
`define ACQ_CORE_STA_FC_FULL_OFFSET 9
`define ACQ_CORE_STA_FC_FULL 32'h00000200
`define ACQ_CORE_STA_RESERVED2_OFFSET 10
`define ACQ_CORE_STA_RESERVED2 32'h0000fc00
`define ACQ_CORE_STA_DDR3_TRANS_DONE_OFFSET 16
`define ACQ_CORE_STA_DDR3_TRANS_DONE 32'h00010000
`define ACQ_CORE_STA_RESERVED3_OFFSET 17
`define ACQ_CORE_STA_RESERVED3 32'hfffe0000
`define ADDR_ACQ_CORE_TRIG_CFG         6'h8
`define ACQ_CORE_TRIG_CFG_HW_TRIG_SEL_OFFSET 0
`define ACQ_CORE_TRIG_CFG_HW_TRIG_SEL 32'h00000001
`define ACQ_CORE_TRIG_CFG_HW_TRIG_POL_OFFSET 1
`define ACQ_CORE_TRIG_CFG_HW_TRIG_POL 32'h00000002
`define ACQ_CORE_TRIG_CFG_HW_TRIG_EN_OFFSET 2
`define ACQ_CORE_TRIG_CFG_HW_TRIG_EN 32'h00000004
`define ACQ_CORE_TRIG_CFG_SW_TRIG_EN_OFFSET 3
`define ACQ_CORE_TRIG_CFG_SW_TRIG_EN 32'h00000008
`define ACQ_CORE_TRIG_CFG_INT_TRIG_SEL_OFFSET 4
`define ACQ_CORE_TRIG_CFG_INT_TRIG_SEL 32'h000001f0
`define ACQ_CORE_TRIG_CFG_RESERVED_OFFSET 9
`define ACQ_CORE_TRIG_CFG_RESERVED 32'hfffffe00
`define ADDR_ACQ_CORE_TRIG_DATA_CFG    6'hc
`define ACQ_CORE_TRIG_DATA_CFG_THRES_FILT_OFFSET 0
`define ACQ_CORE_TRIG_DATA_CFG_THRES_FILT 32'h000000ff
`define ACQ_CORE_TRIG_DATA_CFG_RESERVED_OFFSET 8
`define ACQ_CORE_TRIG_DATA_CFG_RESERVED 32'hffffff00
`define ADDR_ACQ_CORE_TRIG_DATA_THRES  6'h10
`define ADDR_ACQ_CORE_TRIG_DLY         6'h14
`define ADDR_ACQ_CORE_SW_TRIG          6'h18
`define ADDR_ACQ_CORE_SHOTS            6'h1c
`define ACQ_CORE_SHOTS_NB_OFFSET 0
`define ACQ_CORE_SHOTS_NB 32'h0000ffff
`define ACQ_CORE_SHOTS_RESERVED_OFFSET 16
`define ACQ_CORE_SHOTS_RESERVED 32'hffff0000
`define ADDR_ACQ_CORE_TRIG_POS         6'h20
`define ADDR_ACQ_CORE_PRE_SAMPLES      6'h24
`define ADDR_ACQ_CORE_POST_SAMPLES     6'h28
`define ADDR_ACQ_CORE_SAMPLES_CNT      6'h2c
`define ADDR_ACQ_CORE_DDR3_START_ADDR  6'h30
`define ADDR_ACQ_CORE_DDR3_END_ADDR    6'h34
`define ADDR_ACQ_CORE_ACQ_CHAN_CTL     6'h38
`define ACQ_CORE_ACQ_CHAN_CTL_WHICH_OFFSET 0
`define ACQ_CORE_ACQ_CHAN_CTL_WHICH 32'h0000001f
`define ACQ_CORE_ACQ_CHAN_CTL_RESERVED_OFFSET 5
`define ACQ_CORE_ACQ_CHAN_CTL_RESERVED 32'h000000e0
`define ACQ_CORE_ACQ_CHAN_CTL_DTRIG_WHICH_OFFSET 8
`define ACQ_CORE_ACQ_CHAN_CTL_DTRIG_WHICH 32'h00001f00
`define ACQ_CORE_ACQ_CHAN_CTL_RESERVED1_OFFSET 13
`define ACQ_CORE_ACQ_CHAN_CTL_RESERVED1 32'hffffe000
