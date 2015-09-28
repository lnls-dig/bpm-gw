onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrMaskA
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrAddrA
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrDinA
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrEnB
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrMaskB
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrAddrB
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrDinB
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_RdAddr
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_RdQout
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/ds_DMA_Bytes_Add
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/ds_DMA_Bytes
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_PA
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_HA
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_BDA
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Length
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Control
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_BDA_eq_Null
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Status
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Done
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Tout
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsHA_is_64b
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsBDA_is_64b
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsLeng_Hi19b_True
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsLeng_Lo7b_True
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Start
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Stop
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Start2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Stop2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Channel_Rst
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Cmd_Ack
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/us_DMA_Bytes
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_PA
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_HA
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_BDA
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Length
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Control
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_BDA_eq_Null
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/us_MWr_Param_Vec
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Status
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Done
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Tout
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usHA_is_64b
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usBDA_is_64b
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usLeng_Hi19b_True
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usLeng_Lo7b_True
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Start
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Stop
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Start2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Stop2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Channel_Rst
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Cmd_Ack
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/MRd_Channel_Rst
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Tx_Reset
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Sys_IRQ
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Tx_TimeOut
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Tx_wb_TimeOut
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Msg_Routing
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/pcie_link_width
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/cfg_dcommand
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Reset
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Host_Clear
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Latency
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Num_Assert
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Num_Deassert
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Asserting
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/us_DMA_Bytes_Add
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/user_clk
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/user_lnk_up
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/user_reset
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrDin_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrAddr_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrMask_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrEn_r1
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrAddr_r1
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrMask_r1
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrDin_r1
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrEn_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrDin_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_Wr_dma_V_hi_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_Wr_dma_nV_hi_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_Wr_dma_V_nE_hi_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_Wr_dma_V_lo_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_Wr_dma_nV_lo_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_Wr_dma_V_nE_lo_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/WrDin_r1_not_Zero_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/WrDin_r2_not_Zero_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/WrDin_r1_not_Zero_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/WrDin_r2_not_Zero_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrDin_Hi19b_True_hq_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrDin_Lo7b_True_hq_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrDin_Hi19b_True_lq_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrDin_Lo7b_True_lq_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrEnA_r1
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrEnB_r1
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrEnA_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_WrEnB_r2
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Reg_WrMuxer_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Reg_WrMuxer_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_RdAddr_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Regs_RdQout_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Reg_RdMuxer_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Reg_RdMuxer_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/wb_FIFO_Rst_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_PA_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_HA_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_BDA_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Length_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Control_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Status_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Transf_Bytes_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_PA_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_HA_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_BDA_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Length_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Control_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Status_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Transf_Bytes_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_PA_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_HA_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_BDA_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Length_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Control_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Status_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Transf_Bytes_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_PA_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_HA_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_BDA_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Length_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Control_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Status_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Transf_Bytes_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Sys_IRQ_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Sys_Int_Status_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Sys_Int_Status_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Sys_Int_Status_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Sys_Int_Enable_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Sys_Int_Enable_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Sys_Int_Enable_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Sys_Error_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Sys_Error_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Sys_Error_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/General_Control_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/General_Control_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/General_Control_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/General_Status_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/General_Status_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/General_Status_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/HW_Version_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/HW_Version_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Host_Clear_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Reset_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Control_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Latency_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Latency_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Latency_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Num_Assert_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Num_Assert_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Num_Assert_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Num_Deassert_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Num_Deassert_o_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/IG_Num_Deassert_o_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Command_is_Host_iClr_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Command_is_Host_iClr_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_PA_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_HA_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_BDA_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Length_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Control_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Status_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_ds_Transf_Bytes_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Last_Ctrl_Word_ds
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsHA_is_64b_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsBDA_is_64b_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsLeng_Hi19b_True_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsLeng_Lo7b_True_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Start_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Stop_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Start2_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Start2_r1
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Stop2_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/dsDMA_Channel_Rst_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/ds_Param_Modified
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_PA_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_HA_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_BDA_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Length_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Control_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Status_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/DMA_us_Transf_Bytes_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Last_Ctrl_Word_us
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usHA_is_64b_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usBDA_is_64b_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usLeng_Hi19b_True_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usLeng_Lo7b_True_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Start_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Stop_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Start2_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Start2_r1
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Stop2_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/usDMA_Channel_Rst_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/us_Param_Modified
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Command_is_Reset_Hi
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Command_is_Reset_Lo
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/MRd_Channel_Rst_i
add wave -noupdate -expand -group EP -group Registers /board/EP/bpm_pcie_i/theTlpControl/Memory_Space/Tx_Reset_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/TLP_Has_Payload
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/TLP_Hdr_is_4DW
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Addr_Inc
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_BAR_Number
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Start
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Start2
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Stop
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Stop2
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/No_More_Bodies
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ThereIs_Snout
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ThereIs_Body
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ThereIs_Tail
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ThereIs_Dex
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_PA_Loaded
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_PA_Var
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_HA_Var
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_BDA_fsm
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/BDA_is_64b_fsm
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Snout_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Body_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Tail_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/Done_Condition_1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/Done_Condition_2
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/Done_Condition_3
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/Done_Condition_4
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/Done_Condition_5
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/us_MWr_Param_Vec
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ChBuf_aFull
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ChBuf_WrEn
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ChBuf_WrDin
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/State_Is_LoadParam
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/State_Is_Snout
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/State_Is_Body
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/State_Is_Tail
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Cmd_Ack
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ChBuf_ValidRd
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/BDA_nAligned
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_TimeOut
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Busy
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Done
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/Pkt_Tag
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/Dex_Tag
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/dma_clk
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/dma_reset
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_NextState
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_State
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/BusyDone_NextState
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/BusyDone_State
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_TimeOut_State
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Start_r1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Start2_r1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ThereIs_Dex_reg
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ThereIs_Snout_reg
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ThereIs_Body_reg
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ThereIs_Tail_reg
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/BDA_nAligned_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Busy_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Done_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/State_Is_LoadParam_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/State_Is_Snout_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/State_Is_Body_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/State_Is_Tail_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/State_Is_AwaitDex_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_Cmd_Ack_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ChBuf_WrDin_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ChBuf_WrEn_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/ChBuf_aFull_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/cnt_DMA_TO
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/Tout_Lo_Carry
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_StateMachine/DMA_TimeOut_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_PA
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_HA
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_BDA
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Control
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/HA_is_64b
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/BDA_is_64b
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Leng_Hi19b_True
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Leng_Lo7b_True
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_PA_Loaded
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_PA_Var
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_HA_Var
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_BDA_fsm
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/BDA_is_64b_fsm
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Snout_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Body_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Tail_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_PA_Snout
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_BAR_Number
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Start
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Start2
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/No_More_Bodies
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ThereIs_Snout
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ThereIs_Body
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ThereIs_Tail
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ThereIs_Dex
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/HA64bit
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Addr_Inc
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/State_Is_LoadParam
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/State_Is_Snout
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/State_Is_Body
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Param_Max_Cfg
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/dma_clk
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/dma_reset
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Max_TLP_Size
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/mxsz_left
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/mxsz_mid
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/mxsz_right
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Leng_Left_Msk
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Leng_Mid_Msk
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Leng_Right_Msk
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Lo_Leng_Left_Msk_is_True
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Lo_Leng_Mid_Msk_is_True
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Lo_Leng_Right_Msk_is_True
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_HA_Msk
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Length_Msk
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/PA_is_taken
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_PA_next
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_PA_current
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_PA_Loaded_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Carry_PA_plus_Leng
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Carry_PAx_plus_Leng
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Leng_Hi_plus_PA_Hi
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Leng_Hi_plus_PAx_Hi
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_PA_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_HA_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_BDA_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Length_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Control_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/State_Is_Snout_r1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/State_Is_Body_r1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Dex_is_Last
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Engine_Ends
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ThereIs_Snout_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ThereIs_Body_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ThereIs_Tail_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Snout_Only
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ThereIs_Dex_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/No_More_Bodies_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ALc
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ALc_B
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ALc_B_wire
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ALc_T
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/ALc_T_wire
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Leng_Two
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Leng_One
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Leng_nint
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Length_analysis
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Snout_Body_Tail
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Byte_Counter
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Length_minus
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_BC_Carry
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_HA_Var_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_HA_Carry32
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_PA_Var_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_BDA_fsm_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/BDA_is_64b_fsm_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/HA64bit_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/Addr_Inc_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/use_PA
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/HA_gap
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Snout_Length_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_Tail_Length_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/raw_Tail_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_PA_Snout_Carry
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_PA_Body_Carry
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine -group usDMA_Calculation /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_DMA_Calculation/DMA_BAR_Number_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_Req
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_RE
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_Qout
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_FC_stop
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_Last_sof
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_Last_eof
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/FIFO_Reading
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_Channel_Rst
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/DMA_us_PA
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/DMA_us_HA
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/DMA_us_BDA
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/DMA_us_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/DMA_us_Control
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_BDA_eq_Null
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_MWr_Param_Vec
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usHA_is_64b
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usBDA_is_64b
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usLeng_Hi19b_True
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usLeng_Lo7b_True
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_dex_Tag
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_Start
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_Stop
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_Start2
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_Stop2
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/DMA_Cmd_Ack
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/DMA_Done
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/DMA_TimeOut
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/DMA_Busy
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/DMA_us_Status
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/cfg_dcommand
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/user_clk
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/Local_Reset_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/DMA_Status_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/cfg_MPS
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_MWr_Tag
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_PA_Loaded
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_PA_Var
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_HA_Var
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_BDA_fsm
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usBDA_is_64b_fsm
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_BAR_Number
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_Snout_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_Body_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_Tail_Length
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usNo_More_Bodies
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usThereIs_Snout
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usThereIs_Body
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usThereIs_Tail
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usThereIs_Dex
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usHA64bit
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/us_AInc
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usState_Is_LoadParam
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usState_Is_Snout
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usState_Is_Body
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usChBuf_ValidRd
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usBDA_nAligned
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_TimeOut_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_Busy_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usDMA_Done_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_din
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_Qout_wire
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_Qout_reg
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_Qout_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_RE_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_RE_i_r1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_we
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_empty_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_prog_Full
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_pempty
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_Npempty_r1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_Nempty_r1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_empty_r1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_empty_r2
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_empty_r3
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_empty_r4
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_prog_Full_r1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_Req_i
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_nReq_r1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/FIFO_Reading_r1
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/FIFO_Reading_r2
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/FIFO_Reading_r3p
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/usTlp_MWr_Leng
add wave -noupdate -expand -group EP -group rx_Itf -group usDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Upstream_DMA_Engine/FSM_REQ_us
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/TLP_Hdr_is_4DW
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Addr_Inc
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_BAR_Number
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Start
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Start2
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Stop
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Stop2
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/No_More_Bodies
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ThereIs_Snout
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ThereIs_Body
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ThereIs_Tail
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ThereIs_Dex
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_PA_Loaded
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_PA_Var
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_HA_Var
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_BDA_fsm
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/BDA_is_64b_fsm
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Snout_Length
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Body_Length
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Tail_Length
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/Done_Condition_1
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/Done_Condition_2
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/Done_Condition_3
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/Done_Condition_4
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/Done_Condition_5
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/us_MWr_Param_Vec
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ChBuf_aFull
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ChBuf_WrEn
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ChBuf_WrDin
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/State_Is_LoadParam
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/State_Is_Snout
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/State_Is_Body
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/State_Is_Tail
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Cmd_Ack
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ChBuf_ValidRd
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/BDA_nAligned
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_TimeOut
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Busy
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Done
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/Pkt_Tag
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/Dex_Tag
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/dma_clk
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/dma_reset
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_NextState
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_State
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/BusyDone_NextState
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/BusyDone_State
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_TimeOut_State
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Start_r1
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Start2_r1
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ThereIs_Dex_reg
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ThereIs_Snout_reg
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ThereIs_Body_reg
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ThereIs_Tail_reg
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/BDA_nAligned_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Busy_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Done_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/State_Is_LoadParam_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/State_Is_Snout_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/State_Is_Body_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/State_Is_Tail_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/State_Is_AwaitDex_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_Cmd_Ack_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ChBuf_WrDin_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ChBuf_WrEn_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/ChBuf_aFull_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/cnt_DMA_TO
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/Tout_Lo_Carry
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine -group dsDMA_FSM /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_DMA_StateMachine/DMA_TimeOut_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_Req
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_RE
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_Qout
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_Channel_Rst
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/DMA_ds_PA
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/DMA_ds_HA
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/DMA_ds_BDA
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/DMA_ds_Length
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/DMA_ds_Control
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_BDA_eq_Null
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsHA_is_64b
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsBDA_is_64b
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsLeng_Hi19b_True
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsLeng_Lo7b_True
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_dex_Tag
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_Start
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_Stop
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_Start2
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_Stop2
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/DMA_Cmd_Ack
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/Tag_Map_Clear
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/FC_pop
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/tRAM_weB
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/tRAM_AddrB
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/tRAM_dinB
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/DMA_Done
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/DMA_TimeOut
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/DMA_Busy
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/DMA_ds_Status
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/cfg_dcommand
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/user_clk
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/FC_push
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/FC_counter
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsFC_stop
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsFC_stop_128B
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsFC_stop_256B
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsFC_stop_512B
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsFC_stop_1024B
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsFC_stop_2048B
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsFC_stop_4096B
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/Local_Reset_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/cfg_MRS
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/tRAM_dinB_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/tRAM_AddrB_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/tRAM_weB_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_PA_Loaded
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_PA_Var
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_HA_Var
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_BDA_fsm
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsBDA_is_64b_fsm
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_PA_snout
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_BAR_Number
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_Snout_Length
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_Body_Length
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_Tail_Length
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsNo_More_Bodies
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsThereIs_Snout
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsThereIs_Body
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsThereIs_Tail
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsThereIs_Dex
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsHA64bit
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/ds_AInc
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/Tag_DMA_dsp
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsState_Is_LoadParam
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsState_Is_Snout
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsState_Is_Body
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsState_Is_Tail
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsChBuf_ValidRd
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsBDA_nAligned
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_TimeOut_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_Busy_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/dsDMA_Done_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/DMA_Status_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/Tag_Map_Bits
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/Tag_Map_filling
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/All_CplD_have_come
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_din
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_dout
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_re_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_we
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_empty_i
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_full
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_prog_Full
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_prog_Full_r1
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_re_r1
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_empty_r1
add wave -noupdate -expand -group EP -group rx_Itf -group dsDMA_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Downstream_DMA_Engine/MRd_dsp_Req_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tlast
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tdata
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tkeep
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_terrfwd
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tvalid
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tready
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tbar_hit
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_Type
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Req_ID_Match
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/usDex_Tag_Matched
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/dsDex_Tag_Matched
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Tlp_has_4KB
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Tlp_has_1DW
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_on_Pool
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_on_EB
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_is_the_Last
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_Tag
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/FC_pop
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/ds_DMA_Bytes_Add
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/ds_DMA_Bytes
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/dsDMA_dex_Tag
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Tag_Map_Clear
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_weB
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_addrB
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_dinB
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/usDMA_dex_Tag
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/wb_FIFO_we
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/wb_FIFO_wsof
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/wb_FIFO_weof
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/wb_FIFO_din
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Regs_WrEn
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Regs_WrMask
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Regs_WrAddr
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Regs_WrDin
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/user_clk
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/user_reset
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/user_lnk_up
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/wb_Write_State
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/RxCplDTrn_NextState
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/RxCplDTrn_State
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/RxCplDTrn_State_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_State_is_AFetch
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_State_is_after_AFetch
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_State_is_AFetch_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/concat_rd
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tdata_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tdata_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tdata_r2
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tdata_r3
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tdata_r4
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tdata_Little
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tdata_Little_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tdata_Little_r2
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tdata_Little_r3
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tdata_Little_r4
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/trn_rsof_n_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/in_packet_reg
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tlast_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tlast_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tlast_r2
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tlast_r3
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tlast_r4
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tkeep_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tkeep_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tkeep_r2
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tkeep_r3
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tkeep_r4
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Addr_Inc
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/FIFO_Space_Hit
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/DDR_Space_Hit
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/wb_FIFO_we_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/wb_FIFO_wsof_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/wb_FIFO_weof_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/wb_FIFO_sof_marker
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/wb_FIFO_din_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Regs_WrEn_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Regs_WrMask_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Regs_WrAddr_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Regs_WrDin_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Reg_WrAddr_if_last_us
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Reg_WrAddr_if_last_ds
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tready_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tvalid_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tvalid_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tvalid_r2
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tvalid_r3
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/m_axis_rx_tvalid_r4
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/trn_rx_throttle
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/trn_rx_throttle_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/trn_rx_throttle_r2
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/trn_rx_throttle_r3
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/trn_rx_throttle_r4
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/ds_DMA_Bytes_Add_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/ds_DMA_Bytes_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_is_Payloaded
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_Length
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_Leng_in_Bytes
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_Leng_in_Bytes_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_is_1DW
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Small_CplD
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Small_CplD_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/RegAddr_us_Dex
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/RegAddr_ds_Dex
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_Tag_on_Dex
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Req_ID_Match_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Dex_Tag_Matched_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/MSB_DSP_Tag
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/DSP_Tag_on_RAM
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/DSP_Tag_on_RAM_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/DSP_Tag_on_RAM_r2
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/DSP_Tag_on_RAM_r3
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/DSP_Tag_on_RAM_r4p
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/DSP_Tag_on_FIFO
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/DSP_Tag_on_FIFO_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/DSP_Tag_on_FIFO_r2
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/DSP_Tag_on_FIFO_r3
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/DSP_Tag_on_FIFO_r4p
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/FC_pop_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Tag_Map_Clear_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Local_Reset_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/usDMA_dex_Tag_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/dsDMA_dex_Tag_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_wea
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_addra
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_dina
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_doutA
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_weB_i
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_DoutA_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_DoutA_r2
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_dina_aInc
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tRAM_DoutA_latch
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/CplD_is_the_Last_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Updates_tRAM
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Updates_tRAM_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/Update_was_too_late
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/hazard_update
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/hazard_update_r1
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/hazard_update_r2
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/hazard_update_r3
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/hazard_tag
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/hazard_content
add wave -noupdate -expand -group EP -group rx_Itf -group CplD_engine /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Channel/tag_matches_hazard
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tlast
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tdata
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tkeep
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_terrfwd
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tvalid
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tready
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tbar_hit
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/MWr_Type
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/Tlp_has_4KB
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/wb_FIFO_we
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/wb_FIFO_wsof
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/wb_FIFO_weof
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/wb_FIFO_din
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/Regs_WrEn
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/Regs_WrMask
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/Regs_WrAddr
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/Regs_WrDin
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/user_clk
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/user_reset
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/user_lnk_up
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/RxMWrTrn_NextState
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/RxMWrTrn_State
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tdata_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tdata_r1
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tkeep_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tkeep_r1
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tbar_hit_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tbar_hit_r1
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tvalid_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/trn_rsof_n_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/in_packet_reg
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tlast_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tlast_r1
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/FIFO_Space_Sel
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/DDR_Space_Sel
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/REGS_Space_Sel
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/wb_FIFO_we_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/wb_FIFO_wsof_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/wb_FIFO_weof_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/wb_FIFO_din_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/Regs_WrEn_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/Regs_WrMask_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/Regs_WrAddr_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/Regs_WrDin_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/m_axis_rx_tready_i
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/trn_rx_throttle
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/MWr_Has_4DW_Header
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/Tlp_is_Zero_Length
add wave -noupdate -expand -group EP -group rx_Itf -group mwr_channel /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Channel/MWr_Leng_in_Bytes
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/user_clk
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/user_reset
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/user_lnk_up
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tlast
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tdata
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tkeep
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_terrfwd
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tvalid
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tready
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/rx_np_ok
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/rx_np_req
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tbar_hit
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/pioCplD_Req
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/pioCplD_RE
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/pioCplD_Qout
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsMRd_Req
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsMRd_RE
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsMRd_Qout
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usTlp_Req
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usTlp_RE
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usTlp_Qout
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/us_FC_stop
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/us_Last_sof
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/us_Last_eof
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Irpt_Req
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Irpt_RE
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Irpt_Qout
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/cfg_interrupt
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/cfg_interrupt_rdy
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/cfg_interrupt_mmenable
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/cfg_interrupt_msienable
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/cfg_interrupt_di
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/cfg_interrupt_do
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/cfg_interrupt_assert
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/ds_DMA_Bytes_Add
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/ds_DMA_Bytes
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_ds_PA
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_ds_HA
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_ds_BDA
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_ds_Length
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_ds_Control
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsDMA_BDA_eq_Null
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_ds_Status
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_ds_Done
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_ds_Busy
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_ds_Tout
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsHA_is_64b
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsBDA_is_64b
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsLeng_Hi19b_True
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsLeng_Lo7b_True
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsDMA_Start
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsDMA_Stop
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsDMA_Start2
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsDMA_Stop2
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsDMA_Channel_Rst
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsDMA_Cmd_Ack
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_us_PA
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_us_HA
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_us_BDA
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_us_Length
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_us_Control
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usDMA_BDA_eq_Null
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/us_MWr_Param_Vec
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_us_Status
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_us_Done
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_us_Busy
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/DMA_us_Tout
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usHA_is_64b
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usBDA_is_64b
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usLeng_Hi19b_True
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usLeng_Lo7b_True
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usDMA_Start
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usDMA_Stop
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usDMA_Start2
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usDMA_Stop2
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usDMA_Channel_Rst
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usDMA_Cmd_Ack
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MRd_Channel_Rst
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Sys_IRQ
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Regs_WrEn0
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Regs_WrMask0
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Regs_WrAddr0
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Regs_WrDin0
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Regs_WrEn1
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Regs_WrMask1
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Regs_WrAddr1
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Regs_WrDin1
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/IG_Reset
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/IG_Host_Clear
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/IG_Latency
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/IG_Num_Assert
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/IG_Num_Deassert
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/IG_Asserting
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/cfg_dcommand
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/localID
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tlast_dly
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tdata_dly
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tkeep_dly
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_terrfwd_dly
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tvalid_dly
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tready_dly
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/m_axis_rx_tbar_hit_dly
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MRd_Type
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/MWr_Type
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Type
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Tlp_has_4KB
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Tlp_has_1DW
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_is_the_Last
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_on_Pool
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_on_EB
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Req_ID_Match
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usDex_Tag_Matched
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsDex_Tag_Matched
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/CplD_Tag
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/usDMA_dex_Tag
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/dsDMA_dex_Tag
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/Tag_Map_Clear
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/FC_pop
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/tRAM_weB
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/tRAM_addrB
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/tRAM_dinB
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_we
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_wsof
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_weof
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_din
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_Empty
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_Reading
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_we_i
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_wsof_i
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_weof_i
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_din_i
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_we_MWr
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_wsof_MWr
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_weof_MWr
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_din_MWr
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_we_CplD
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_wsof_CplD
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_weof_CplD
add wave -noupdate -expand -group EP -group rx_Itf /board/EP/bpm_pcie_i/theTlpControl/rx_Itf/wb_FIFO_din_CplD
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Regs_RdAddr
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Regs_RdQout
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/RdNumber
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/RdNumber_eq_One
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/RdNumber_eq_Two
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/StartAddr
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Shift_1st_QWord
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/is_CplD
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/BAR_value
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/RdCmd_Req
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/RdCmd_Ack
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/mbuf_Din
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/mbuf_WE
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/mbuf_Full
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/mbuf_aFull
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Tx_TimeOut
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/mReader_Rst_n
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/user_clk
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/TxMReader_State
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_cmd_drr
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_cmd_dsa
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_cmd_eof
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_cmd_saddr
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_cmd_tdata
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_cmd_tready
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_cmd_tvalid
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_cmd_tvalid_i
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_cmd_wtt
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_tdata
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_tkeep
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_tlast
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_tready
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_mm2s_tvalid
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Regs_RdAddr_i
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Regs_RdEn
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Regs_Hit
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/ddr_FIFO_Hit
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/DDR_Dout_wire
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Regs_RdQout_wire
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/mbuf_Din_wire_OR
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/mbuf_Din_i
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/mbuf_WE_i
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/mbuf_Full_i
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/mbuf_aFull_i
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/mbuf_aFull_r1
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/RdCmd_Req_i
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/RdCmd_Ack_i
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Shift_1st_QWord_k
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/is_CplD_k
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/may_be_MWr_k
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/regs_Rd_Counter
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/regs_Rd_Cntr_eq_One
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/regs_Rd_Cntr_eq_Two
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/DDR_Rd_Counter
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/DDR_Rd_Cntr_eq_One
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Address_var
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Address_step
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/TxTLP_eof_n
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/TxTLP_eof_n_r1
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/TimeOut_Counter
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/TO_Cnt_Rst
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Tx_TimeOut_i
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_re
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_empty
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_qout
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Tx_wb_TimeOut
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_Hit
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_re_i
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_RdEn_Mask_rise
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_RdEn_Mask_rise_r1
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_RdEn_Mask_rise_r2
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_RdEn_Mask_rise_r3
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_RdEn_Mask
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_RdEn_Mask_r1
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_RdEn_Mask_r2
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_Rd_1Dw
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_Rd_Cntr_eq_Two
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_Rd_Counter
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_qout_r1
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_qout_shift
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/wb_FIFO_Dout_wire
add wave -noupdate -expand -group EP -group tx_Itf -group tx_memReader /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ABB_Tx_MReader/Tx_wb_TimeOut_i
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/user_clk
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/user_reset
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/user_lnk_up
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/s_axis_tx_tlast
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/s_axis_tx_tdata
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/s_axis_tx_tkeep
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/s_axis_tx_terrfwd
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/s_axis_tx_tvalid
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/s_axis_tx_tready
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/s_axis_tx_tdsc
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/trn_tsof_n_i
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/us_DMA_Bytes_Add
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/us_DMA_Bytes
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Regs_RdAddr
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Regs_RdQout
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Irpt_Req
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Irpt_RE
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Irpt_Qout
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/pioCplD_Req
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/pioCplD_RE
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/pioCplD_Qout
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/dsMRd_Req
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/dsMRd_RE
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/dsMRd_Qout
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/usTlp_Req
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/usTlp_RE
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/usTlp_Qout
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/us_FC_stop
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/us_Last_sof
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/us_Last_eof
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Msg_Routing
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Tx_TimeOut
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Tx_Reset
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/localID
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/TxTrn_State
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/take_an_Arbitration
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Req_Bundle
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Read_a_Buffer
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Ack_Indice
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/b1_Tx_Indicator
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/vec_ChQout_Valid
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Tx_Busy
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/usTLP_is_MWr
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/TLP_is_CplD
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ChBuf_has_Payload
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/ChBuf_No_Payload
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Trn_Qout_wire
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Trn_Qout_reg
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/mAddr_usTlp
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/DDRAddr_usTlp
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Regs_Addr_pioCplD
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/DDRAddr_pioCplD
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/BAR_pioCplD
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/BAR_usTlp
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/AInc_usTlp
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/pioCplD_is_0Leng
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Irpt_Req_r1
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/pioCplD_Req_r1
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/dsMRd_Req_r1
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/usTlp_Req_r1
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Irpt_Qout_to_TLP
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/pioCplD_Qout_to_TLP
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/dsMRd_Qout_to_TLP
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/usTlp_Qout_to_TLP
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/pioCplD_Req_Min_Leng
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/pioCplD_Req_2DW_Leng
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/usTlp_Req_Min_Leng
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/usTlp_Req_2DW_Leng
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Irpt_RE_i
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/pioCplD_RE_i
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/dsMRd_RE_i
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/usTlp_RE_i
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/us_FC_stop_i
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/trn_tx_Reset_n
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/us_DMA_Bytes_Add_i
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/us_DMA_Bytes_i
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/RdNumber
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/RdNumber_eq_One
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/RdNumber_eq_Two
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/StartAddr
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Shift_1st_QWord
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/is_CplD
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/BAR_value
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/RdCmd_Req
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/RdCmd_Ack
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/mbuf_reset_n
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/mbuf_WE
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/mbuf_Din
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/mbuf_Full
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/mbuf_aFull
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/mbuf_RE
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/mbuf_Qout
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/mbuf_Empty
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/mbuf_RE_ok
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/mbuf_Qvalid
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/wb_FIFO_re
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/wb_FIFO_empty
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/wb_FIFO_qout
add wave -noupdate -expand -group EP -group tx_Itf /board/EP/bpm_pcie_i/theTlpControl/tx_Itf/Tx_wb_TimeOut
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axi_reset
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_reset
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_aresetn
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/ddr_axi_aresetn
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/ddr_mmcm_locked
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/ddr_ui_clk
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/ddr_ui_rst
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/irconnect_arstn
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/real_ddr/init_calib_complete
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/mm2s_err
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/s2mm_err
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_mm2s_cmd_tdata
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_mm2s_cmd_tready
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_mm2s_cmd_tvalid
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_mm2s_tdata
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_mm2s_tkeep
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_mm2s_tlast
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_mm2s_tready
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_mm2s_tvalid
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_s2mm_cmd_tdata
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_s2mm_cmd_tready
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_s2mm_cmd_tvalid
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_s2mm_tdata
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_s2mm_tkeep
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_s2mm_tlast
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_s2mm_tready
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/axis_s2mm_tvalid
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_araddr
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_arburst
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_arcache
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_aresetn
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_arlen
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_arlock
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_arprot
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_arqos
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_arready
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_arsize
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_arvalid
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_awaddr
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_awburst
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_awcache
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_awlen
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_awlock
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_awprot
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_awqos
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_awready
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_awsize
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_awvalid
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_bready
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_bresp
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_bvalid
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_rdata
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_rlast
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_rready
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_rresp
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_rvalid
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_wdata
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_wlast
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_wready
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_wstrb
add wave -noupdate -expand -group EP -group DDR_transact /board/EP/bpm_pcie_i/DDRs_ctrl_module/pcie_axi_wvalid
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/user_clk
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wr_we
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wr_sof
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wr_eof
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wr_din
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wr_full
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rdc_sof
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rdc_v
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rdc_din
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rdc_full
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rd_ren
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rd_empty
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rd_dout
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wb_clk
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wb_rst
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/addr_o
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/dat_i
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/dat_o
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/we_o
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/sel_o
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/stb_o
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/ack_i
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/cyc_o
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rst
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wb_state
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wpipe_din
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wpipe_wen
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wpipe_afull
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wpipe_full
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wpipe_empty
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wpipe_qout
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wpipe_ren
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wpipe_valid
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wpipe_last
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpipec_din
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpipec_wen
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpipec_qout
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpipec_valid
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpipec_ren
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpipec_empty
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpipec_full
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpipec_afull
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpiped_din
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpiped_qout
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpiped_full
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpiped_we
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpiped_afull
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rpiped_empty
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wb_addr
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wb_rd_cnt
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wb_dat_o
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wb_we
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wb_sel
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wb_stb
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/wb_cyc
add wave -noupdate -expand -group EP -group wb_Intf /board/EP/bpm_pcie_i/Wishbone_intf/rst_i
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/ddr3_dq
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/ddr3_addr
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/ddr3_ba
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/ddr3_we_n
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/ddr3_dm
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/sys_rst_n
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/user_clk
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/user_reset
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/user_lnk_up
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/s_axis_tx_tdata
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/s_axis_tx_tkeep
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/s_axis_tx_tlast
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/s_axis_tx_tvalid
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/s_axis_tx_tready
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/s_axis_tx_tuser
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/s_axis_tx_tdsc
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/s_axis_tx_terrfwd
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/m_axis_rx_tdata
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/m_axis_rx_tkeep
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/m_axis_rx_tlast
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/m_axis_rx_tvalid
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/m_axis_rx_tready
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/m_axis_rx_terrfwd
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/tx_cfg_req
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/tx_buf_av
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/rx_np_ok
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/rx_np_req
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/m_axis_rx_tbar_hit
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_interrupt
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_interrupt_rdy
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_interrupt_mmenable
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_interrupt_msienable
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_interrupt_di
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_interrupt_do
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_interrupt_assert
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_turnoff_ok
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_to_turnoff
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_pm_wake
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_command
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_dcommand
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_dcommand2
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_dstatus
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_lcommand
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_lstatus
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_pcie_link_state
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_trn_pending
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_bus_number
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_device_number
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/cfg_function_number
add wave -noupdate -expand -group EP -expand /board/EP/bpm_pcie_i/localId
add wave -noupdate -expand -group EP /board/EP/bpm_pcie_i/pcie_link_width
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {140847413 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 338
configure wave -valuecolwidth 159
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {140694008 ps} {141871320 ps}
