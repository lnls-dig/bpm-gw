//----------------------------------------------------------------------------
// Title      : Testbench for BPM Swap Wishbone Slave
//----------------------------------------------------------------------------
// Author     : Jose Alvim Berkenbrock
// Company    : CNPEM LNLS-DIG
// Platform   : FPGA-generic
//-----------------------------------------------------------------------------
// Description: This desing put together a wishbone master and slave block for
//             control of swap channels in RF Front-End Board.
//-----------------------------------------------------------------------------
// Copyright (c) 2013 CNPEM
// Licensed under GNU Lesser General Public License (LGPL) v3.0
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author                Description
// 2013-04-14  1.0      jose.berkenbrock      Created 
//-----------------------------------------------------------------------------

// Common definitions
`include "defines.v"
// Simulation timescale
`include "timescale.v"
// Wishbone Master
`include "wishbone_test_master.v"
// bpm swap Register definitions
`include "regs/xbpm_swap_regs.vh"

module wb_bpm_swap_tb;

  WB_TEST_MASTER WB();

  reg  [`ADC_DATA_WIDTH-1:0] cha_i, chb_i, chc_i, chd_i;
  wire [`ADC_DATA_WIDTH-1:0] cha_o, chb_o, chc_o, chd_o;
  wire [7:0]  ctrl1_o, ctrl2_o ;  

  wire clk = WB.wb_clk;
  wire rst = WB.wb_rst;

  wb_bpm_swap dut(

    .rst_n_i    (WB.wb_rst),
    .clk_sys_i  (WB.wb_clk),
    .wb_adr_i   (WB.wb_addr),
    .wb_dat_i   (WB.wb_data_o),
    .wb_dat_o   (WB.wb_data_i),
    .wb_cyc_i   (WB.wb_cyc),
    .wb_sel_i   (WB.wb_bwsel),
    .wb_stb_i   (WB.wb_stb),
    .wb_we_i    (WB.wb_we),
    .wb_ack_o   (WB.wb_ack),
    .cha_i      (cha_i),
    .chb_i      (chb_i),
    .chc_i      (chc_i),
    .chd_i      (chd_i),
    .cha_o      (cha_o),
    .chb_o      (chb_o),
    .chc_o      (chc_o),
    .chd_o      (chd_o),
    .ctrl1_o    (ctrl1_o),
    .ctrl2_o    (ctrl2_o)
  );

  reg [31:0] ans, ans2, ans3, ans4;

  initial begin

    // Initial values for ADC data signals
    if (`debug) begin
    cha_i <= 16'h0001;
    chc_i <= 16'h0002;
    end else begin
    cha_i <= 16'h00ff;
    chc_i <= 16'hf00f;
    end
    chb_i <= 16'hff00;
    chd_i <= 16'h0ff0;

    if (`debug) begin $display("Debug mode running");
    $display("-----------------------------------");
    $display("Config. on Debug mode: ");
    $display("ch A = 1 and ch C = 2");
    $display("AA Gain = 3, CC Gain = 5, AC Gain = 7 and CA Gain = 11");
    $display("Swap Freq = 13 KHz, Delay1 = 2 and Delay2 = 8");
    $display("-----------------------------------");
    $display("Otherwise, all of them are loaded as unitary value");
    $display("-----------------------------------");
    end else begin $display("Normal running"); end

    wait (WB.ready)

    @(posedge clk);
    $display("-----------------------------------");
    $display("@%0d:  Inicialization  Begin", $time);
    $display("-----------------------------------");

    ////////////////////////
    // Set delay values between cross and uncross actions

    #1 $display("Set delay 2");
    if (`debug) begin WB.write32(`ADDR_BPM_SWAP_CTRL +(4),(16'h0008 << `BPM_SWAP_DLY_2_OFFSET));
    //WB.read32(`ADDR_BPM_SWAP_CTRL <<4, ans);
    //WB.write32(`ADDR_BPM_SWAP_CTRL <<4,(~`BPM_SWAP_DLY_2&ans)|(16'h0008 << `BPM_SWAP_DLY_2_OFFSET));
    end else begin WB.write32(`ADDR_BPM_SWAP_CTRL +(4),(16'h0001 << `BPM_SWAP_DLY_2_OFFSET)); end

    #1 $display("Set delay 1");
    //WB.write32(`ADDR_BPM_SWAP_CTRL <<4,(16'h0002 << `BPM_SWAP_DLY_1_OFFSET));
    WB.read32(`ADDR_BPM_SWAP_CTRL +(4), ans);
    if (`debug) begin WB.write32(`ADDR_BPM_SWAP_CTRL +(4),(~`BPM_SWAP_DLY_1&ans)|(16'h0002 << `BPM_SWAP_DLY_1_OFFSET));
    end else begin WB.write32(`ADDR_BPM_SWAP_CTRL +(4),(~`BPM_SWAP_DLY_1&ans)|(16'h0001 << `BPM_SWAP_DLY_1_OFFSET)); end

    ////////////////////////
    // Set swap frequency
    
    #1 $display("Set swap frequency");
    if (`debug) begin WB.write32(`ADDR_BPM_SWAP_CTRL,(16'h1e0a << `BPM_SWAP_CTRL_SWAP_DIV_F_OFFSET));
    //WB.read32(`ADDR_BPM_SWAP_CTRL, ans);
    //WB.write32(`ADDR_BPM_SWAP_CTRL,(~`BPM_SWAP_CTRL_SWAP_DIV_F&ans)|(16'h00ff << `BPM_SWAP_CTRL_SWAP_DIV_F_OFFSET));
    end else begin WB.write32(`ADDR_BPM_SWAP_CTRL,(16'h0001 << `BPM_SWAP_CTRL_SWAP_DIV_F_OFFSET)); end

    ////////////////////////
    // Set gain channels compensation

    #1 $display("Set constant AA");
    if (`debug) begin WB.write32(`ADDR_BPM_SWAP_CTRL+(8),(10'h003 << `BPM_SWAP_A_A_OFFSET));
    //WB.read32(`ADDR_BPM_SWAP_CTRL<<8, ans);
    //WB.write32(`ADDR_BPM_SWAP_CTRL<<8,(~`BPM_SWAP_A_A&ans)|(10'h001 << `BPM_SWAP_A_A_OFFSET));
    end else begin WB.write32(`ADDR_BPM_SWAP_CTRL+(8),(10'h001 << `BPM_SWAP_A_A_OFFSET)); end

    #1 $display("Set constant BB");
    WB.write32(`ADDR_BPM_SWAP_CTRL+'hc,(10'h001 << `BPM_SWAP_B_B_OFFSET));
    //WB.read32(`ADDR_BPM_SWAP_CTRL<<'hc, ans);
    //WB.write32(`ADDR_BPM_SWAP_CTRL<<'hc,(~`BPM_SWAP_B_B&ans)|(10'h001 << `BPM_SWAP_B_B_OFFSET));

    #1 $display("Set constant CC");
    if (`debug) begin WB.write32(`ADDR_BPM_SWAP_CTRL+'h10,(10'h005 << `BPM_SWAP_C_C_OFFSET));
    //WB.read32(`ADDR_BPM_SWAP_CTRL<<'h10, ans);
    //WB.write32(`ADDR_BPM_SWAP_CTRL<<'h10,(~`BPM_SWAP_C_C&ans)|(10'h001 << `BPM_SWAP_C_C_OFFSET));
    end else begin WB.write32(`ADDR_BPM_SWAP_CTRL+'h10,(10'h001 << `BPM_SWAP_C_C_OFFSET)); end

    #1 $display("Set constant DD");
    WB.write32(`ADDR_BPM_SWAP_CTRL+'h14,(10'h001 << `BPM_SWAP_D_D_OFFSET));
    //WB.read32(`ADDR_BPM_SWAP_CTRL<<'h14, ans);
    //WB.write32(`ADDR_BPM_SWAP_CTRL<<'h14,(~`BPM_SWAP_D_D&ans)|(10'h001 << `BPM_SWAP_D_D_OFFSET));

    #1 $display("Set constant AC");
    //WB.write32(`ADDR_BPM_SWAP_CTRL+'h8,(10'h001 << `BPM_SWAP_A_C_OFFSET));
    WB.read32(`ADDR_BPM_SWAP_CTRL+'h8, ans);
    if (`debug) begin WB.write32(`ADDR_BPM_SWAP_CTRL+'h8,(~`BPM_SWAP_A_C&ans)|(10'h007 << `BPM_SWAP_A_C_OFFSET));
    end else begin WB.write32(`ADDR_BPM_SWAP_CTRL+'h8,(~`BPM_SWAP_A_C&ans)|(10'h001 << `BPM_SWAP_A_C_OFFSET)); end

    #1 $display("Set constant BD");
    //WB.write32(`ADDR_BPM_SWAP_CTRL+'hc,(10'h001 << `BPM_SWAP_B_D_OFFSET));
    WB.read32(`ADDR_BPM_SWAP_CTRL+'hc, ans);
    WB.write32(`ADDR_BPM_SWAP_CTRL+'hc,(~`BPM_SWAP_B_D&ans)|(10'h001 << `BPM_SWAP_B_D_OFFSET));

    #1 $display("Set constant CA");
    //WB.write32(`ADDR_BPM_SWAP_CTRL+'h10,(10'h001 << `BPM_SWAP_C_A_OFFSET));
    WB.read32(`ADDR_BPM_SWAP_CTRL+'h10, ans);
    if (`debug) begin WB.write32(`ADDR_BPM_SWAP_CTRL+'h10,(~`BPM_SWAP_C_A&ans)|(10'h00b << `BPM_SWAP_C_A_OFFSET));
    end else begin WB.write32(`ADDR_BPM_SWAP_CTRL+'h10,(~`BPM_SWAP_C_A&ans)|(10'h001 << `BPM_SWAP_C_A_OFFSET)); end

    #1 $display("Set constant DB");
    //WB.write32(`ADDR_BPM_SWAP_CTRL+'h14,(10'h001 << `BPM_SWAP_D_B_OFFSET));
    WB.read32(`ADDR_BPM_SWAP_CTRL+'h14, ans);
    WB.write32(`ADDR_BPM_SWAP_CTRL+'h14,(~`BPM_SWAP_D_B&ans)|(10'h001 << `BPM_SWAP_D_B_OFFSET));

    ////////////////////////
    // Set operation mode of channel pairs

    #1 $display("Set mode1 to direct");
    WB.read32(`ADDR_BPM_SWAP_CTRL, ans);
    //WB.write32(`ADDR_BPM_SWAP_CTRL, (ans&32'hfff9) | 32'h0004); //works, but complicated 
    //WB.write32(`ADDR_BPM_SWAP_CTRL, (~`BPM_SWAP_CTRL_MODE1&ans)|32'h0004); //works, with mask
    WB.write32(`ADDR_BPM_SWAP_CTRL,((~`BPM_SWAP_CTRL_MODE1)&ans)|(2'b01 << `BPM_SWAP_CTRL_MODE1_OFFSET));
    //WB.write32(`ADDR_BPM_SWAP_CTRL,(2'b10 << `BPM_SWAP_CTRL_MODE1_OFFSET));

    #1 $display("Set mode2 to inverted");
    WB.read32(`ADDR_BPM_SWAP_CTRL, ans);
    //WB.write32(`ADDR_BPM_SWAP_CTRL, ((ans&32'hffe7) | 32'h0008));
    WB.write32(`ADDR_BPM_SWAP_CTRL,(~`BPM_SWAP_CTRL_MODE2&ans)|(2'b10 << `BPM_SWAP_CTRL_MODE2_OFFSET));
    //WB.write32(`ADDR_BPM_SWAP_CTRL,(2'b11 << `BPM_SWAP_CTRL_MODE2_OFFSET));

    $display("-------------------------------------");
    $display("@%0d:  Inicialization  Done!", $time);
    $display("-------------------------------------");

    ////////////////////////
    // reading registers

    #1; // wait
    WB.read32(`ADDR_BPM_SWAP_CTRL, ans);
    $display("Mode1 Response %b (%x) and mode2 is %b", ans[2:1], ans[2:1], ans[4:3]);
    $display("\t&");
    $display("Swap Div Freq Response %b (%x)", ans[23:8], ans[23:8]);

    #1; // wait
    WB.read32(`ADDR_BPM_SWAP_CTRL+'h8, ans);
    $display("Gain AC Response %b (%x)", ans[9:0], ans[9:0]);

    #1; // wait
    WB.read32(`ADDR_BPM_SWAP_CTRL+'h4, ans);
    $display("Delay1 @%.3f ut and Delay2 @%.3f ut", ans[15:0], ans[31:16]);

    ////////////////////////
    // change mode 1 value

    #1000 WB.read32(`ADDR_BPM_SWAP_CTRL, ans);
    $display("-------------------------------------------------");
    $display("Set mode1 to swapping @%.3f KHz", 1000000/(`WB_CLOCK_PERIOD*(ans[23:8]+2)));
    $display("-------------------------------------------------");
    WB.write32(`ADDR_BPM_SWAP_CTRL,((~`BPM_SWAP_CTRL_MODE1)&ans)|(2'b11 << `BPM_SWAP_CTRL_MODE1_OFFSET));

    #1 $display("That's it");
    $display("---------------------------------------------");
    #1 $finish;
  end

endmodule
