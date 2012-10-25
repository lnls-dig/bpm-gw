`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:  ziti, Uni. HD
// Engineer:  wgao
//            weng.ziti@gmail.com
// 
// Create Date:   16:54:18 04 Nov 2008
// Design Name:   tlpControl
// Module Name:   tf64_pcie_axi.v
// Project Name:  PCIE_SG_DMA
// Target Device:  
// Tool versions:  
// Description:  PIO and DMA are both simulated.
//
// Verilog Test Fixture created by ISE for module: tlpControl
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// 
// Revision 1.00 - Released to OpenCores.org   14.09.2011
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////


//`define  RANDOM_SEQUENCE

  /*  Time parameters  */
`define  T_HALF_CYCLE_CLK                   4.0
`define  T_HALF_CYCLE_MEMCLK                5.0
`define  T_DELAY_AFTER                      0.0
`define  T_DELTA                            0.1
`define  T_PIO_INTERVAL                    50.0
`define  T_DMA_INTERVAL                   300.0
`define  T_RX_NO_FC_PERIOD            1900000.0
`define  T_TX_NO_FC_PERIOD            1500000.0

  /* Memory size for simulation */
`define  C_ARRAY_DIMENSION              4096

  /* Start indices */
`define  PIO_START_INDEX                'H0300
`define  DMA_START_INDEX                'H0000

  /* Request completion boundary */
`define  C_RCB_16_DW                    'H10
`define  C_RCB_32_DW                    'H20

  /* BAR */
`define  C_BAR0_HIT                    7'H01
`define  C_BAR1_HIT                    7'H02
`define  C_BAR2_HIT                    7'H04
`define  C_BAR3_HIT                    7'H78
`define  C_BAR4_HIT                    7'H10
`define  C_BAR5_HIT                    7'H20
`define  C_BAR6_HIT                    7'H30
`define  C_NO_BAR_HIT                  7'H00


  /* Requester ID and Completer ID */
`define  C_HOST_WRREQ_ID              16'H0ABC
`define  C_HOST_RDREQ_ID              16'HE1E2
`define  C_HOST_CPLD_ID               16'HC01D

  /* 1st header */
`define  HEADER0_MWR3_                32'H40000000
`define  HEADER0_MWR4_                32'H60000000
`define  HEADER0_MRD3_                32'H00000000
`define  HEADER0_MRD4_                32'H20000000
`define  HEADER0_CPLD                 32'H4A000000
`define  HEADER0_CPL                  32'H0A000000
`define  HEADER0_MSG                  32'H34000001

  /* Message codes */
`define  C_MSG_CODE_INTA               8'H20
`define  C_MSG_CODE_INTA_N             8'H24

  /* Payload type */
`define  USE_PRIVATE                    1
`define  USE_PUBLIC                     0

  /* General registers */
`define  C_ADDR_VERSION                 32'H0000
`define  C_ADDR_IRQ_STAT                32'H0008
`define  C_ADDR_IRQ_EN                  32'H0010
`define  C_ADDR_GSR                     32'H0020
`define  C_ADDR_GCR                     32'H0028

  /* Control registers for special ports */
`define  C_ADDR_MRD_CTRL                32'H0074
`define  C_ADDR_TX_CTRL                 32'H0078
`define  C_ADDR_ICAP                    32'H007C
`define  C_ADDR_EB_STACON               32'H0090

  /* Downstream DMA channel registers */
`define  C_ADDR_DMA_DS_PAH              32'H0050
`define  C_ADDR_DMA_DS_CTRL             32'H006C
`define  C_ADDR_DMA_DS_STA              32'H0070

  /* Upstream DMA channel registers */
`define  C_ADDR_DMA_US_PAH              32'H002C
`define  C_ADDR_DMA_US_CTRL             32'H0048
`define  C_ADDR_DMA_US_STA              32'H004C

  /* DMA-specific constants */
`define  C_DMA_RST_CMD                  32'H0200000A


module tf64_pcie_axi();

   // Inputs
   reg  user_reset;
   reg  user_lnk_up;
   reg  user_clk;
   reg  trn_rsof_n;
   reg  m_axis_rx_tlast;
   reg  [63:0] m_axis_rx_tdata;
   reg  [7:0] m_axis_rx_tkeep;
   reg  m_axis_rx_tvalid;
   wire m_axis_rx_tready;
   reg  [6:0] m_axis_rx_tbar_hit;
   wire rx_np_ok;
   reg  m_axis_rx_terrfwd;
   wire trn_tsof_n; //internal tx_Transact signal
   wire s_axis_tx_tlast;
   wire [63:0] s_axis_tx_tdata;
   wire [7:0] s_axis_tx_tkeep;
   wire s_axis_tx_tvalid;
   reg  s_axis_tx_tready;
   wire s_axis_tx_terrfwd;
   wire s_axis_tx_tdsc;
   reg  [5:0] tx_buf_av;

   reg [5:0] pcie_link_width;
   reg [15:0] cfg_dcommand;
   reg [15:0] localID;

   // Outputs
   wire DDR_wr_v;
   wire DDR_wr_sof;
   wire DDR_wr_eof;
   wire DDR_wr_Shift;
   wire [1:0] DDR_wr_Mask;
   wire [63:0] DDR_wr_din;
   wire DDR_wr_full;
   wire DDR_rdc_v;
   wire DDR_rdc_sof;
   wire DDR_rdc_eof;
   wire DDR_rdc_Shift;
   wire [63:0] DDR_rdc_din;
   wire DDR_rdc_full;
   wire DDR_FIFO_RdEn;
   wire DDR_FIFO_Empty;
   wire [63:0] DDR_FIFO_RdQout;
   reg  mbuf_UserFull;
   wire DDR_Ready;
   wire trn_Blinker;
   reg  mem_clk;
	
	//SIMONE
	wire ddr_wr_fa;
	wire DDR_rdc_FA;
	
	
   // FIFO
   wire           eb_FIFO_we; 
   wire [64-1:00] eb_FIFO_din;
   wire           eb_FIFO_re; 
   wire [72-1:00] eb_FIFO_qout;
   wire [64-1:00] eb_FIFO_Status;
   wire           eb_FIFO_Rst;

   wire           eb_pfull;
   wire           eb_full;
   wire           eb_pempty;
   wire           eb_empty;

   wire [27-1:0]  eb_FIFO_Data_Count;

   // flow control toggles
   reg            Rx_No_Flow_Control;
   reg            Tx_No_Flow_Control;

   // message counters 
   reg  [31:00] Accum_Msg_INTA        = 0;
   reg  [31:00] Accum_Msg_INTA_n      = 0;

   // random seed
   reg [127: 0]  Op_Random;

   // Generated Array
   reg [15:00]  ii;
   reg [31:00]  D_Array[`C_ARRAY_DIMENSION-1:00];

   //
   reg  [ 7: 0] FSM_Trn;
   reg  [31: 0] Hdr_Array[3:0];
   reg  [31: 0] Private_Array[15:0];
   reg  [10: 0] Rx_TLP_Length;
   reg  [ 7: 0] Rx_MWr_Tag;
   reg  [ 4: 0] Rx_MRd_Tag;
   reg  [31:00] Tx_MRd_Addr;
   reg  [31:00] Tx_MRd_Leng;
   reg  [10: 0] tx_MRd_Length;
   reg  [ 7: 0] tx_MRd_Tag;
   reg  [ 7: 0] tx_MRd_Tag_k;

   reg  [31:00] DMA_PA;
   reg  [63:00] DMA_HA;
   reg  [63:00] DMA_BDA;
   reg  [31:00] DMA_Leng;
   reg  [31:00] DMA_L1;
   reg  [31:00] DMA_L2;
   reg  [02:00] DMA_bar;
   reg          DMA_ds_is_Last;
   reg          DMA_us_is_Last;
   reg  [31:00] CplD_Index;

   reg          Desc_tx_MRd_Valid;
   reg  [10:00] Desc_tx_MRd_Leng;
   reg  [31:00] Desc_tx_MRd_Addr;
   reg  [07:00] Desc_tx_MRd_TAG;
   reg          tx_MRd_come;

   reg  [63:00] PIO_Addr;
   reg  [31:00] PIO_Leng;
   reg  [ 3:00] PIO_1st_BE;
   reg  [ 6:00] PIO_bar;
   
 //Rimossi da v5 a v6
 //wire           DBG_dma_start;

 //Aggiunti da v5 a v6
 
   reg  [01:00]  protocol_link_act;
   reg  			  DAQ_irq;                  
   reg           CTL_irq;                  
   reg           DLM_irq;                  
   reg  [31:00]  ctl_status;               
   reg           ctl_tv;                   
   reg  [31:00]  ctl_td;                   
   reg           dlm_rv;                   
   reg  [31:00]  dlm_rd;                   
   reg           DG_is_Running;            
	reg           cfg_interrupt_rdy;      
	reg  [02:00]  cfg_interrupt_mmenable;   
	reg           cfg_interrupt_msienable;  
	reg  [07:00]  cfg_interrupt_do;         
   reg           eb_FIFO_ow;               

	// Instantiate the Unit Under Test (UUT)
	tlpControl uut (
		.mbuf_UserFull(mbuf_UserFull), 
		.trn_Blinker(trn_Blinker), 
      .eb_FIFO_we     (eb_FIFO_we    ) , //          : OUT std_logic; 
      .eb_FIFO_din    (eb_FIFO_din   ) , //          : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      .eb_FIFO_re     (eb_FIFO_re    ) , //          : OUT std_logic; 
      .eb_FIFO_empty  (eb_empty      ) , //          : IN  std_logic; 
      .eb_FIFO_qout   (eb_FIFO_qout[63:0]  ) , //          : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      .eb_FIFO_Data_Count   (eb_FIFO_Data_Count  ) , //          : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      .eb_FIFO_Status (eb_FIFO_Status) , //          : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      .eb_FIFO_Rst    (eb_FIFO_Rst   ) , //          : OUT std_logic;
      .Link_Buf_full  (eb_pfull   ) ,
		.DDR_Ready      (DDR_Ready), 
		.DDR_wr_sof(DDR_wr_sof), 
		.DDR_wr_eof(DDR_wr_eof), 
		.DDR_wr_v(DDR_wr_v), 
		.DDR_wr_FA(ddr_wr_fa),  //SIMONE era () 
		.DDR_wr_Shift(DDR_wr_Shift), 
		.DDR_wr_Mask(DDR_wr_Mask), 
		.DDR_wr_din(DDR_wr_din), 
		.DDR_wr_full(DDR_wr_full), 
		.DDR_rdc_sof(DDR_rdc_sof), 
		.DDR_rdc_eof(DDR_rdc_eof), 
		.DDR_rdc_v(DDR_rdc_v), 
		.DDR_rdc_FA(DDR_rdc_FA),  //SIMONE era () 
      .DDR_rdc_Shift(DDR_rdc_Shift),
		.DDR_rdc_din(DDR_rdc_din), 
		.DDR_rdc_full(DDR_rdc_full), 
		.DDR_FIFO_RdEn(DDR_FIFO_RdEn), 
		.DDR_FIFO_Empty(DDR_FIFO_Empty), 
		.DDR_FIFO_RdQout(DDR_FIFO_RdQout), 
		.user_clk(user_clk), 
		.user_reset(user_reset), 
		.user_lnk_up(user_lnk_up), 
		.m_axis_rx_tlast(m_axis_rx_tlast), 
		.m_axis_rx_tdata(m_axis_rx_tdata), 
      .m_axis_rx_tkeep(m_axis_rx_tkeep),
		.m_axis_rx_terrfwd(m_axis_rx_terrfwd), 
		.m_axis_rx_tvalid(m_axis_rx_tvalid), 
		.m_axis_rx_tready(m_axis_rx_tready), 
		.rx_np_ok(rx_np_ok), 
		.m_axis_rx_tbar_hit(m_axis_rx_tbar_hit), 
		.s_axis_tx_tlast(s_axis_tx_tlast), 
		.s_axis_tx_tdata(s_axis_tx_tdata), 
      .s_axis_tx_tkeep(s_axis_tx_tkeep),
		.s_axis_tx_terrfwd(s_axis_tx_terrfwd), 
		.s_axis_tx_tvalid(s_axis_tx_tvalid), 
		.s_axis_tx_tready(s_axis_tx_tready), 
		.s_axis_tx_tdsc(s_axis_tx_tdsc),
      .trn_tsof_n(trn_tsof_n),
		.tx_buf_av(tx_buf_av), 
		.pcie_link_width(pcie_link_width), 
		.cfg_dcommand(cfg_dcommand), 
		.localID(localID),


      //Rimosse da v5 a v6!!
		//S .DMA_ds_Start   (DBG_dma_start),

		//Aggiunte da v5 a v6!!
      .DMA_us_Done(),
      .DMA_us_Busy(),
      .DMA_us_Busy_LED(),
      .DMA_ds_Done(),
      .DMA_ds_Busy(),
      .DMA_ds_Busy_LED(),
      .ctl_rv(),                   
      .ctl_rd(),                   
      .protocol_rst(),             
      .ctl_ttake(),                
      .ctl_tstop(),                
      .ctl_reset(),                
      .dlm_tv(),                   
      .dlm_td(),                   
		.cfg_interrupt(),          
		.cfg_interrupt_di(),         
		.cfg_interrupt_assert(),   
      .Format_Shower(),            
      .DG_Reset(),                 
      .DG_Mask(),                  
      .tab_we(),                   
      .tab_wa(),                   
      .tab_wd(),                   
      .eb_FIFO_wsof(),             
      .eb_FIFO_weof(),             
      .pio_reading_status(),       

		.DAQ_irq                    (DAQ_irq                 ),     
      .CTL_irq                    (CTL_irq                 ),
      .DLM_irq                    (DLM_irq                 ),
      .ctl_status                 (ctl_status              ),
      .ctl_tv                     (ctl_tv                  ),
      .ctl_td                     (ctl_td                  ),
      .dlm_rv                     (dlm_rv                  ),
      .dlm_rd                     (dlm_rd                  ),
      .DG_is_Running              (DG_is_Running           ),
      .cfg_interrupt_rdy        (cfg_interrupt_rdy     ),
      .cfg_interrupt_mmenable     (cfg_interrupt_mmenable  ),
      .cfg_interrupt_msienable    (cfg_interrupt_msienable ),
      .cfg_interrupt_do           (cfg_interrupt_do        ),
      .eb_FIFO_ow                 (eb_FIFO_ow              )

	);



	// Instantiate the BRAM module
   bram_DDRs_Control_loopback 
	DDRs_ctrl_module
   (
    .DDR_wr_sof(DDR_wr_sof), 
    .DDR_wr_eof(DDR_wr_eof), 
    .DDR_wr_v(DDR_wr_v), 
    .DDR_wr_FA(1'b0), 
    .DDR_wr_Shift(DDR_wr_Shift), 
    .DDR_wr_Mask(DDR_wr_Mask), 
    .DDR_wr_din(DDR_wr_din), 

	  //Aggiunti da v5 a v6	
    .DDR_wr_full(DDR_wr_full),

 
    .DDR_rdc_sof(DDR_rdc_sof), 
    .DDR_rdc_eof(DDR_rdc_eof), 
    .DDR_rdc_v(DDR_rdc_v), 
    .DDR_rdc_FA(1'b0), 
    .DDR_rdc_Shift(DDR_rdc_Shift),
    .DDR_rdc_din(DDR_rdc_din), 
    .DDR_rdc_full(DDR_rdc_full), 
	 
    .DDR_FIFO_RdEn(DDR_FIFO_RdEn), 
    .DDR_FIFO_Empty(DDR_FIFO_Empty), 
    .DDR_FIFO_RdQout(DDR_FIFO_RdQout), 
	 
    .DDR_Ready(DDR_Ready), 
	 .DDR_blinker(DDR_blinker), 
    .Sim_Zeichen(Sim_Zeichen), 
    .mem_clk(mem_clk), 
    .user_clk(user_clk), 
    .user_reset(user_reset)

    //S .DBG_dma_start(DBG_dma_start),
    );

   assign  DDR_wr_full = 0;


	// Instantiate the FIFO module
   eb_wrapper_loopback
   queue_buffer(
         .wr_clk     (  user_clk        ),
         .wr_en      (  eb_FIFO_we     ),
         .din        (  {8'H0, eb_FIFO_din}    ),
         .pfull      (  eb_pfull       ),
         .full       (  eb_full        ),

         .rd_clk     (  user_clk        ),
         .rd_en      (  eb_FIFO_re     ),
         .dout       (  eb_FIFO_qout   ),
         .pempty     (  eb_pempty      ),
         .empty      (  eb_empty       ),
         .data_count (  eb_FIFO_Data_Count[15:1]),

         .rst        (  eb_FIFO_Rst    )
         );

   assign  eb_FIFO_Data_Count[26:16] = 0;
   assign  eb_FIFO_Data_Count[0] = 0;
   assign  eb_FIFO_Status = {34'H0, eb_FIFO_Data_Count, eb_pfull, eb_empty};
   //assign  trn_tsof_n = tf64_pcie_trn.uut.tx_Itf.trn_tsof_n_i;
   //assign trn_tsof_n = 1'b0;



   // initialiation
	initial begin
		// Initialize Inputs
		user_clk = 0;
      mem_clk = 1;
		user_reset = 1;
		user_lnk_up = 0;
		m_axis_rx_terrfwd = 0;
		tx_buf_av = -1;

      //Aggiunti da v5 a v6
		DAQ_irq  					= 0;              
		CTL_irq                 = 0;
		DLM_irq                 = 0;
		ctl_status              = 0;
		ctl_tv                  = 0;
		ctl_td                  = 0;
		dlm_rv                  = 0;
		dlm_rd                  = 0;
		DG_is_Running           = 0;
		cfg_interrupt_rdy     = 0;
		cfg_interrupt_mmenable  = 0;
		cfg_interrupt_msienable = 0;
		cfg_interrupt_do        = 0;
		eb_FIFO_ow              = 0;

		mbuf_UserFull = 0;
		pcie_link_width = 'H19;
      cfg_dcommand = 'H2000;
		localID = 'HD841;

      Rx_No_Flow_Control = 1;    // = 0;  // Set to 0 to enable the Rx throttling
      Tx_No_Flow_Control = 1;    // = 0;  // Set to 0 to enable the Tx throttling

		// Wait some nanoseconds for global reset to finish
		#101;
		user_reset = 0;
		user_lnk_up = 1;

		#10000;
//      $stop();

	end

   // user_clk toggles
   always #`T_HALF_CYCLE_CLK
   user_clk = ~user_clk;

   // mem_clk toggles
   always #`T_HALF_CYCLE_MEMCLK
   mem_clk = ~mem_clk;

   // Randoms generated for process flow
   always @(posedge user_clk) begin
     Op_Random[ 31:00] = $random();
     Op_Random[ 63:32] = $random();
     Op_Random[ 95:64] = $random();
     Op_Random[127:96] = $random();
   end


   /// Rx Flow Control
   always # `T_RX_NO_FC_PERIOD
   Rx_No_Flow_Control = ~Rx_No_Flow_Control;

   /// Tx Flow Control
   always # `T_TX_NO_FC_PERIOD
   Tx_No_Flow_Control = ~Tx_No_Flow_Control;

   // Signal prepared for m_axis_rx_tvalid
   reg m_axis_rx_tvalid_seed;
   always @(posedge user_clk) begin
     m_axis_rx_tvalid_seed <= ~(Op_Random[8] & Op_Random[10] & ~Rx_No_Flow_Control);
   end

   // s_axis_tx_tready
   always @(posedge user_clk )
   begin
     # `T_DELAY_AFTER
      s_axis_tx_tready <= ~((Op_Random[24] & Op_Random[21] & ~Tx_No_Flow_Control) | user_reset);
   end



   // Initialization mem in host
   initial begin
     for (ii = 0; ii< `C_ARRAY_DIMENSION; ii= ii+1) begin
`ifdef  RANDOM_SEQUENCE
        D_Array[ii]    <= $random ();
`else
        D_Array[ii]    <= Inv_Endian ('H8760_0000 + ii + 1);
`endif
     end
   end


  //  Simulation procedure
  initial begin

    // Simulation Initialization
    FSM_Trn               <= 'H00;
    Gap_Insert_Rx;

    PIO_bar               <= -1;
    DMA_bar               <= 'H1;
    Rx_MWr_Tag            <= 'H80;
    Rx_MRd_Tag            <= 'H10;

   $display("\n ####  Starting simulation...  ####\n");
    // Initialization: TLP
    # 400
      Rx_TLP_Length    <= 'H01;

    # `T_DELTA    // reset TX module
      $display("   reset TX module\n");
      Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
      Hdr_Array[2] <= `C_ADDR_TX_CTRL;
      Private_Array[0] <= 'H0000000A;

    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
      Gap_Insert_Rx;


    # `T_DELTA     // Test MRd with 4-DW header  BAR[0]
      $display("   Test MRd with 4-DW header  BAR[0]\n");
      Hdr_Array[0] <= `HEADER0_MRD4_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 8'HA1, 4'Hf, 4'Hf};
      Hdr_Array[2] <= -1;
      Hdr_Array[3] <= `C_ADDR_VERSION;

    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Gap_Insert_Rx;

    # 100
      Rx_TLP_Length    <= 'H01;


    # `T_DELTA    // reset upstream DMA channel
      $display("   reset upstream DMA channel\n");
      Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
      Hdr_Array[2] <= `C_ADDR_DMA_US_CTRL;
      Private_Array[0] <= `C_DMA_RST_CMD;

    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
      Gap_Insert_Rx;

    # `T_DELTA    // reset downstream DMA channel
      $display("   reset downstream DMA channel\n");
      Hdr_Array[0] <= `HEADER0_MWR4_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
      Hdr_Array[2] <= -1;
      Hdr_Array[3] <= `C_ADDR_DMA_DS_CTRL;
      Private_Array[0] <= `C_DMA_RST_CMD;

    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
      Gap_Insert_Rx;


    # `T_DELTA    // reset Event Buffer FIFO
      $display("   reset Event Buffer FIFO\n");
      Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
      Hdr_Array[2] <= `C_ADDR_EB_STACON;
      Private_Array[0] <= 'H0000000A;

    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
      Gap_Insert_Rx;


    # `T_DELTA    // Enable INTerrupts
      $display("   Enable INTerrupts\n");
      Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
      Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
      Hdr_Array[2] <= `C_ADDR_IRQ_EN;
      Private_Array[0] <= 'H0000_0003;

    # `T_DELTA
      TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
      Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
      Gap_Insert_Rx;

    /////////////////////////////////////////////////////////////////////
    //                       PIO simulation                            //
    /////////////////////////////////////////////////////////////////////

   $display("#### PIO simulation ####\n");
   
     # `T_PIO_INTERVAL;

       FSM_Trn          <= 'H04;

    //  ///////////////////////////////////////////////////////////////////
    //  PIO write & read BAR[0]
      $display("   PIO write & read BAR[0]\n");
       PIO_Addr         <= `C_ADDR_DMA_US_PAH + 'H8;
       PIO_bar          <= `C_BAR0_HIT;
       PIO_1st_BE       <= 4'Hf;
       Gap_Insert_Rx;
       Hdr_Array[0]     <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};
       Private_Array[0] <= 'HF000_8888;
       Rx_TLP_Length    <= 'H01;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, PIO_bar);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

     # `T_PIO_INTERVAL
       ;

     # `T_DELTA
       Hdr_Array[0]     <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};

     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, `PIO_START_INDEX, PIO_bar);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H08;

    //  ///////////////////////////////////////////////////////////////////
    //  PIO write & read BAR[1]
      $display("   PIO write & read BAR[1]\n");
       PIO_Addr         <= 'H8000;
       PIO_bar          <= `C_BAR1_HIT;
       PIO_1st_BE       <= 4'Hf;
       Gap_Insert_Rx;
       Hdr_Array[0]     <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};
       Private_Array[0] <= 'HA1111111;
       Rx_TLP_Length    <= 'H01;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, PIO_bar);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

     # `T_PIO_INTERVAL
       ;

     # `T_DELTA
       Hdr_Array[0]     <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};

     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, `PIO_START_INDEX, PIO_bar);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H10;

    //  ///////////////////////////////////////////////////////////////////
    //  PIO write & read BAR[2]
    //  NOTE:  FIFO address is 64-bit aligned, only the lower 32-bit is
    //         accessible by BAR[2] PIO write and is returned in BAR[2] 
    //         PIO read.
      $display("   PIO write & read BAR[2]\n");
       PIO_Addr         <= 'H0;
       PIO_bar          <= `C_BAR2_HIT;
       PIO_1st_BE       <= 4'Hf;
       Gap_Insert_Rx;
       Hdr_Array[0]     <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};
       Private_Array[0] <= 'HB222_2222;
       Rx_TLP_Length    <= 'H01;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, PIO_bar);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

     # `T_PIO_INTERVAL
       ;

     # `T_DELTA
       Hdr_Array[0]     <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1]     <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, PIO_1st_BE};
       Hdr_Array[2]     <= {PIO_Addr[31:2], 2'b00};

     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, `PIO_START_INDEX, PIO_bar);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H14;

    $display("### End PIO simulation\n");

     # `T_DMA_INTERVAL
       ;

    //  ///////////////////////////////////////////////////////////////////
    //  DMA write & read BAR[1]
    //  Single-descriptor case
      $display("### DMA write & read BAR[1], Single-descriptor case###\n");
       DMA_PA   <= 'H1234;
       DMA_HA   <= 'H5000;
       DMA_BDA  <= 'Hffff;
		 DMA_Leng <= 'H0100;
       DMA_bar  <= 'H1;
       DMA_ds_is_Last  <= 'B1;

     # `T_DELTA
       // Initial DMA descriptor
       Private_Array[0] <= -1;
       Private_Array[1] <= DMA_PA[31:00];       //'H0300;
       Private_Array[2] <= DMA_HA[63:32];       // 0;
       Private_Array[3] <= DMA_HA[31:00];       // 'H4000;
       Private_Array[4] <= DMA_BDA[63:32];      // 0;
       Private_Array[5] <= DMA_BDA[31:00];      //'H0BDA0090;
       Private_Array[6] <= DMA_Leng;            //'H100;
       Private_Array[7] <=  {4'H0
                            ,3'H1, DMA_ds_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, DMA_bar
                            ,1'B1
                            ,15'H0
                            };

       //  DMA write
      $display(" >> DMA write\n");
       Rx_TLP_Length    <= 'H01;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_PAH;

       //  Write PA_H
       $display("   Write PA_H\n");
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write PA_L
       $display("   Write PA_L\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H1, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_H
       $display("   Write HA_H\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H2, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_L
       $display("   Write HA_L\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H3, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_H
       $display("   Write BDA_H\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H4, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_L
       $display("   Write BDA_L\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H5, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write LENG
       $display("   Write LENG\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H6, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write CTRL and start the DMA
       $display("   Write CTRL and start the DMA\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H7, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;


     # `T_DELTA     // Polling the DMA status
     $display("   Polling the DMA status\n");
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H18;


       // feeding the payload CplD
       $display("   feeding the payload CplD\n");
       wait (tx_MRd_come);
       Gap_Insert_Rx;
       tx_MRd_come  <= 'B0;
       Tx_MRd_Leng  <= DMA_Leng>>2;
       Tx_MRd_Addr  <= DMA_HA[31:0];
       tx_MRd_Tag_k <= tx_MRd_Tag;
       CplD_Index   <= 'H0;

       Gap_Insert_Rx;
       Rx_TLP_Length    <= 'H10;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
//       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;


       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
      $display("   Polling the DMA status\n");
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_STA;

     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H1C;

     # `T_DMA_INTERVAL
       ;

       //  DMA read
      $display(" >DMA read\n");
       Rx_TLP_Length    <= 'H01;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_PAH;

       //  Write PA_H
       $display("   Write PA_H\n");
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write PA_L
       $display("   Write PA_L\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H1, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_H
       $display("   Write HA_H\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H2, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_L
       $display("   Write HA_L\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H3, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_H
       $display("   Write BDA_H\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H4, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_L
       $display("   Write BDA_L\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H5, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write LENG
       $display("   Write LENG\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H6, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write CTRL and start the DMA
       $display("   Write CTRL and start the DMA\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H7, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;


       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
     $display("   Polling the DMA status\n");
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H20;

     # (`T_DMA_INTERVAL*4)
       ;


  //////////////////////////////////////////////////////////////////////////////////

       Rx_TLP_Length    <= 'H01;
     # `T_DELTA    // reset downstream DMA channel
     $display("   reset downstream DMA channel\n");
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_CTRL;
       Private_Array[0] <= `C_DMA_RST_CMD;

     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

       Rx_TLP_Length    <= 'H01;
     # `T_DELTA    // reset upstream DMA channel
     $display("   reset upstream DMA channel\n");
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_CTRL;
       Private_Array[0] <= `C_DMA_RST_CMD;

     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

  //////////////////////////////////////////////////////////////////////////////////


       FSM_Trn          <= 'H24;

     # `T_PIO_INTERVAL
       ;


    //  ///////////////////////////////////////////////////////////////////
    //  DMA write & read BAR[2]
    //  Multiple-descriptor case
    //  
      $display("### DMA write & read BAR[2], Multiple-descriptor case ###\n");
       DMA_PA   <= 'H789ABC;
       DMA_HA   <= 'HDF0000;
       DMA_BDA  <= 'H0BDABDA0;
		 DMA_Leng <= 'H0208;
     # `T_DELTA
		 DMA_L1   <= 'H0100;
     # `T_DELTA
		 DMA_L2   <= DMA_Leng - DMA_L1;
       DMA_bar  <= 'H2;
       DMA_ds_is_Last  <= 'B0;

     # `T_DELTA
       // Initial DMA descriptor
       Private_Array[0] <= -1;
       Private_Array[1] <= DMA_PA[31:00];
       Private_Array[2] <= DMA_HA[63:32];       // 0;
       Private_Array[3] <= DMA_HA[31:00];
       Private_Array[4] <= DMA_BDA[63:32];      // 0;
       Private_Array[5] <= DMA_BDA[31:00];
       Private_Array[6] <= DMA_L1;
       Private_Array[7] <=  {4'H0
                            ,3'H1, DMA_ds_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, DMA_bar
                            ,1'B1
                            ,15'H0
                            };

       Rx_TLP_Length    <= 'H01;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_PAH;

       //  Write PA_H
       $display("   Write PA_H\n");
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write PA_L
       $display("   Write PA_L\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H1, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_H
       $display("   Write HA_H\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H2, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_L
       $display("   Write HA_L\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H3, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_H
       $display("   Write BDA_H\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H4, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_L
       $display("   Write BDA_L\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H5, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write LENG
       $display("   Write LENG\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H6, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write CTRL and start the DMA
       $display("   Write CTRL and start DMA\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H7, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;


       FSM_Trn          <= 'H28;


       // feeding the descriptor CplD
       $display("   feeding the descriptor CplD\n");
       wait (Desc_tx_MRd_Valid);
       Gap_Insert_Rx;
       Desc_tx_MRd_Valid <= 'B0;
       DMA_ds_is_Last    <= 'B1;
       Gap_Insert_Rx;

       // Initial DMA descriptor
       Private_Array[0] <= 0;
       Private_Array[1] <= DMA_PA[31:00] + 'H500;
       Private_Array[2] <= DMA_HA[63:32];          // 0;
       Private_Array[3] <= DMA_HA[31:00] + 'H500;
       Private_Array[4] <= -1;                     // dont-care
       Private_Array[5] <= -1;                     // dont-care
       Private_Array[6] <= DMA_L2;
       Private_Array[7] <=  {4'H0
                            ,3'H1, DMA_ds_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, DMA_bar
                            ,1'B1
                            ,15'H0
                            };

       Rx_TLP_Length    <= 'H08;
       Gap_Insert_Rx;
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Rx_TLP_Length[9:0], 2'b00};
       Hdr_Array[2] <= {localID, Desc_tx_MRd_TAG, 1'b0, DMA_BDA[6:0]};
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 0, `C_NO_BAR_HIT);
       Gap_Insert_Rx;


       // feeding the payload CplD
       $display("   feeding the payload CplD\n");
       wait (tx_MRd_come);
       Gap_Insert_Rx;
       tx_MRd_come  <= 'B0;
       Tx_MRd_Leng  <= DMA_L1>>2;
       Tx_MRd_Addr  <= DMA_HA[31:0];
       tx_MRd_Tag_k <= tx_MRd_Tag;
       CplD_Index   <= 'H0;

       Gap_Insert_Rx;
       Rx_TLP_Length    <= 'H10;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
//       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
//       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;


       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
     $display("   Polling the DMA status\n");
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_STA;
   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;


       FSM_Trn          <= 'H2C;


       // feeding the payload CplD (2nd descriptor)
       $display("   feeding the payload CplD (2nd descriptor)\n");
       wait (tx_MRd_come);
       Gap_Insert_Rx;
       tx_MRd_come  <= 'B0;
       Tx_MRd_Leng  <= (DMA_L2>>2) - 'H2;
       Tx_MRd_Addr  <= DMA_HA[31:0] + 'H500;
       tx_MRd_Tag_k <= tx_MRd_Tag_k + 'H1;
       CplD_Index   <= 'H40;

       Gap_Insert_Rx;
       Rx_TLP_Length    <= 'H10;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
//       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       Rx_TLP_Length    <= 'H02;
       Tx_MRd_Leng      <= 'H2;
       tx_MRd_Tag_k     <= tx_MRd_Tag_k + 'H1;
     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Tx_MRd_Leng[9:0], 2'b00};
       Hdr_Array[2] <= {localID, tx_MRd_Tag_k, 1'b0, Tx_MRd_Addr[6:0]};
       Tx_MRd_Leng  <= Tx_MRd_Leng - Rx_TLP_Length;
       Tx_MRd_Addr  <= Tx_MRd_Addr + Rx_TLP_Length;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PUBLIC, CplD_Index, `C_NO_BAR_HIT);
       CplD_Index   <= CplD_Index + Rx_TLP_Length;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H30;



     # (`T_DMA_INTERVAL*2)
       ;

       DMA_us_is_Last   <= 'B0;
     # `T_DELTA
       //  DMA read
       $display(" >DMA Read\n");
       Private_Array[0] <= 0;
       Private_Array[1] <= DMA_PA[31:00];
       Private_Array[2] <= DMA_HA[63:32];          // 0;
       Private_Array[3] <= DMA_HA[31:00];
       Private_Array[4] <= DMA_BDA[63:32];         // 0;
       Private_Array[5] <= DMA_BDA[31:00] + 'H10000;
       Private_Array[6] <= DMA_L1;
       Private_Array[7] <=  {4'H0
                            ,3'H1, DMA_us_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, DMA_bar
                            ,1'B1
                            ,15'H0
                            };
       Rx_TLP_Length    <= 'H01;

     # `T_DELTA
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_PAH;

       //  Write PA_H
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write PA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H1, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_H
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H2, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write HA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H3, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_H
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H4, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write BDA_L
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H5, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write LENG
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H6, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;

       //  Write CTRL and start the DMA
       $display("   Write CTRL and start the DMA\n");
       Hdr_Array[2] <= Hdr_Array[2] + 'H4;
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H7, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;
       Gap_Insert_Rx;


       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
     $display("   Polling the DMA status\n");
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H34;


       // feeding the descriptor CplD
       $display("   feeding the descriptor CplD\n");
       wait (Desc_tx_MRd_Valid);
       Gap_Insert_Rx;
       Desc_tx_MRd_Valid <= 'B0;
       DMA_us_is_Last    <= 'B1;
       Gap_Insert_Rx;

       // Initial DMA descriptor
       Private_Array[0] <= 0;
       Private_Array[1] <= DMA_PA[31:00] + 'H500;
       Private_Array[2] <= DMA_HA[63:32];          // 0;
       Private_Array[3] <= DMA_HA[31:00] + 'H500;
       Private_Array[4] <= -1;                     // dont-care
       Private_Array[5] <= -1;                     // dont-care
       Private_Array[6] <= DMA_L2;
       Private_Array[7] <=  {4'H0
                            ,3'H1, DMA_us_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, DMA_bar
                            ,1'B1
                            ,15'H0
                            };

       Rx_TLP_Length    <= 'H08;
       Gap_Insert_Rx;
       Hdr_Array[0] <= `HEADER0_CPLD | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_CPLD_ID, 4'H0, Rx_TLP_Length[9:0], 2'b00};
       Hdr_Array[2] <= {localID, Desc_tx_MRd_TAG, 1'b0, DMA_BDA[6:0]};
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 0, `C_NO_BAR_HIT);
       Gap_Insert_Rx;


       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
     $display("   Polling the DMA status\n");
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;


     # (`T_DMA_INTERVAL*4)
       ;

       Rx_TLP_Length    <= 'H01;
     # `T_DELTA     // Polling the DMA status
     $display("   Polling the DMA status\n");
       Hdr_Array[0] <= `HEADER0_MRD3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_RDREQ_ID, 3'H3, Rx_MRd_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_STA;

   
     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MRd_Tag       <= Rx_MRd_Tag + 1;
       Gap_Insert_Rx;

       FSM_Trn          <= 'H38;

     # (`T_DMA_INTERVAL*4)
       ;


  //////////////////////////////////////////////////////////////////////////////////

       Rx_TLP_Length    <= 'H01;
     # `T_DELTA    // reset downstream DMA channel
     $display("   reset DS DMA channel\n");
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_DS_CTRL;
       Private_Array[0] <= `C_DMA_RST_CMD;

     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

       Rx_TLP_Length    <= 'H01;
     # `T_DELTA    // reset upstream DMA channel
     $display("   reset US DMA channel\n");
       Hdr_Array[0] <= `HEADER0_MWR3_ | Rx_TLP_Length[9:0];
       Hdr_Array[1] <= {`C_HOST_WRREQ_ID, Rx_MWr_Tag, 4'Hf, 4'Hf};
       Hdr_Array[2] <= `C_ADDR_DMA_US_CTRL;
       Private_Array[0] <= `C_DMA_RST_CMD;

     # `T_DELTA
       TLP_Feed_Rx(`USE_PRIVATE, 'H0, `C_BAR0_HIT);
       Rx_MWr_Tag   <= Rx_MWr_Tag + 1;
       Gap_Insert_Rx;

  //////////////////////////////////////////////////////////////////////////////////


       FSM_Trn          <= 'H40;
   
      # 1000
      $display("### Simulation FINISHED ###\n");
      $stop();

  end




// ========================================== //
//         Checking and verification          //
//                                            //
   reg           Err_signal;
//                                            //
//                                            //
// ========================================== //

   // TLP format check out Rx
   //  in case stimuli incorrect: verification over verification
   reg [ 7: 0]   FSM_Rx_Fmt;
   reg [10: 0]   rxchk_TLP_Length;
   reg           rxchk_TLP_Has_Data;
   reg           rxchk_TLP_4DW_Hdr;
   reg           rxchk_Mem_TLP;
   always @(negedge user_clk )
   if (user_reset) begin
      FSM_Rx_Fmt      <= 0;
   end
   else begin

      case (FSM_Rx_Fmt)

        'H00: begin
            FSM_Rx_Fmt    <= 'H010;
         end

        'H10: begin
            if ( ~m_axis_rx_tvalid | ~m_axis_rx_tready) begin
              FSM_Rx_Fmt        <= 'H10;
            end
            else if (m_axis_rx_tlast) begin
                  $display ("\n %t:\n !! Unexpected m_axis_rx_tlast !!", $time);
                  Err_signal <= 1;
            end
            else if (~trn_rsof_n & ~m_axis_rx_tlast) begin
                rxchk_TLP_Has_Data    <= m_axis_rx_tdata[30];
                rxchk_TLP_4DW_Hdr     <= m_axis_rx_tdata[29];
                rxchk_TLP_Length[10]  <= (m_axis_rx_tdata[9:0]=='H0);
                rxchk_TLP_Length[9:0] <= m_axis_rx_tdata[9:0];
                if (m_axis_rx_tdata[28:25]) rxchk_Mem_TLP    <= 0;    // Msg or MsgD
                else                     rxchk_Mem_TLP    <= 1;    // MWr, MRd or Cpl/D
                FSM_Rx_Fmt        <= 'H12;
            end
            else begin
                $display ("\n %t:\n !! trn_rsof_n error!", $time);
                Err_signal <= 1;
            end
         end


        'H12: begin
            if ( ~m_axis_rx_tvalid | ~m_axis_rx_tready) begin
              FSM_Rx_Fmt        <= 'H12;
            end
            else if (!trn_rsof_n) begin
              $display ("\n %t:\n !! trn_rsof_n error! should be 1.", $time);
              Err_signal <= 1;
            end
            else begin
              if (rxchk_TLP_4DW_Hdr & rxchk_TLP_Has_Data) begin
                if (~m_axis_rx_tlast) begin
                  Err_signal <= 0;
                  FSM_Rx_Fmt        <= 'H20;
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! m_axis_rx_tlast error (4-Header, with Payload)! should be 0.", $time);
                end
              end
              else if (rxchk_TLP_4DW_Hdr & !rxchk_TLP_Has_Data) begin
                if (~m_axis_rx_tlast) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! m_axis_rx_tlast error (4-Header, no Payload)! should be 1.", $time);
                end
                else if (m_axis_rx_tkeep=='HFF) begin
                    Err_signal <= 0;
                    FSM_Rx_Fmt        <= 'H10;
                end
                else begin
                    Err_signal <= 1;
                    $display ("\n %t:\n !! m_axis_rx_tkeep error (4-Header, no Payload)!", $time);
                end
              end
              else if (!rxchk_TLP_4DW_Hdr & !rxchk_TLP_Has_Data) begin
                if (~m_axis_rx_tlast) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! m_axis_rx_tlast error (3-Header, with Payload)! should be 1.", $time);
                end
                else if (m_axis_rx_tkeep=='H0f) begin
                  Err_signal <= 0;
                  FSM_Rx_Fmt        <= 'H10;
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! m_axis_rx_tkeep error (3-Header, no Payload)!", $time);
                end
              end
              else if (rxchk_TLP_Length=='H1) begin  // (!rxchk_TLP_4DW_Hdr & rxchk_TLP_Has_Data)
                if (~m_axis_rx_tlast) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! m_axis_rx_tlast error (3-Header, with Payload)! should be 1.", $time);
                end
                else if (m_axis_rx_tkeep=='Hff) begin
                  Err_signal <= 0;
                  FSM_Rx_Fmt        <= 'H10;
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! m_axis_rx_tkeep error (3-Header, no Payload)!", $time);
                end
              end
              else begin  // (!rxchk_TLP_4DW_Hdr & rxchk_TLP_Has_Data) & (rxchk_TLP_Length>'H1)
                if (~m_axis_rx_tlast) begin
                  Err_signal <= 0;
                  rxchk_TLP_Length      <= rxchk_TLP_Length - 1;
                  FSM_Rx_Fmt        <= 'H20;
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! m_axis_rx_tlast error (3-Header, no Payload)! should be 0.", $time);
                end
              end

              // Address-Length combination check
              if (rxchk_TLP_4DW_Hdr) begin
                if (({1'b0, m_axis_rx_tdata[11+32:2+32]} + rxchk_TLP_Length[9:0])>11'H400) begin
                  $display ("\n\n %t:\n !! Rx 4KB straddled !!", $time);
                  $display ("\n Address=%08X  Length=%04X (%04X bytes)\n\n", m_axis_rx_tdata[31+32:0+32], rxchk_TLP_Length, rxchk_TLP_Length<<2);
//                  Err_signal <= 1;
                end
                if (m_axis_rx_tdata[31:0]=='H0 && rxchk_Mem_TLP==1) begin
                  $display ("\n %t:\n !! Rx TLP should not be 4-DW headher !!", $time);
                  Err_signal <= 1;
                end
              end 
              else begin
                if (({1'b0, m_axis_rx_tdata[11:2]} + rxchk_TLP_Length[9:0])>11'H400) begin
                  $display ("\n\n %t:\n !! Rx 4KB straddled !!", $time);
                  $display ("\n Address=%08X  Length=%04X (%04X bytes)\n\n", m_axis_rx_tdata[31:0], rxchk_TLP_Length, rxchk_TLP_Length<<2);
//                  Err_signal <= 1;
                end
              end
            end
          end


        'H20: begin
            if ( ~m_axis_rx_tvalid | ~m_axis_rx_tready) begin
              FSM_Rx_Fmt        <= 'H20;
            end
            else if (rxchk_TLP_Length==2) begin
              if (m_axis_rx_tkeep=='Hff && m_axis_rx_tlast==1) begin
                FSM_Rx_Fmt        <= 'H10;
              end
              else begin
                $display ("\n %t:\n !! m_axis_rx_tlast/m_axis_rx_tkeep error !!", $time);
                Err_signal <= 1;
              end
            end
            else if (rxchk_TLP_Length==1) begin
              if (m_axis_rx_tkeep=='H0f && m_axis_rx_tlast==1) begin
                FSM_Rx_Fmt        <= 'H10;
              end
              else begin
                $display ("\n %t:\n !! m_axis_rx_tlast/m_axis_rx_tkeep error !!", $time);
                Err_signal <= 1;
              end
            end
            else if (rxchk_TLP_Length==0) begin
              $display ("\n %t:\n !! Rx TLP Length error !!", $time);
              Err_signal <= 1;
            end
            else if (m_axis_rx_tlast) begin
              $display ("\n %t:\n !! m_axis_rx_tlast too early !!", $time);
              Err_signal <= 1;
            end
            else begin
              rxchk_TLP_Length      <= rxchk_TLP_Length - 2;
              FSM_Rx_Fmt        <= 'H20;
            end
         end

        default: begin
           FSM_Rx_Fmt     <= 'H00;
         end

      endcase
   end




   // TLP format check by Tx
   reg [ 7: 0]   FSM_TLP_Fmt;
   reg [10: 0]   tx_TLP_Length;
   reg [12: 0]   tx_TLP_Address;
   reg           tx_TLP_Has_Data;
   reg           tx_TLP_is_CplD;
   reg           tx_TLP_4DW_Hdr;
   reg           tx_Mem_TLP;
   always @(negedge user_clk )
   if (user_reset) begin
      FSM_TLP_Fmt      <= 0;
   end
   else begin

      case (FSM_TLP_Fmt)

        'H00: begin
            FSM_TLP_Fmt    <= 'H010;
         end

        'H10: begin
            if ( ~s_axis_tx_tvalid | ~s_axis_tx_tready) begin
              FSM_TLP_Fmt        <= 'H10;
            end
            else if (s_axis_tx_tlast) begin
                  $display ("\n %t:\n !! Unexpected s_axis_tx_tlast !!", $time);
                  Err_signal <= 1;
            end
            else if (~trn_tsof_n & ~s_axis_tx_tlast) begin
                tx_TLP_Has_Data    <= s_axis_tx_tdata[30];
                tx_TLP_4DW_Hdr     <= s_axis_tx_tdata[29];
                tx_TLP_Length[10]  <= (s_axis_tx_tdata[9:0]=='H0);
                tx_TLP_Length[9:0] <= s_axis_tx_tdata[9:0];
                tx_TLP_is_CplD     <= s_axis_tx_tdata[27];
                if (s_axis_tx_tdata[28:25]) tx_Mem_TLP    <= 0;    // Msg or MsgD
                else                     tx_Mem_TLP    <= 1;    // MWr, MRd or Cpl/D
                FSM_TLP_Fmt        <= 'H12;
                if (s_axis_tx_tdata[31+32:16+32] == localID) begin
                   Err_signal <= 0;
                end
                else begin
                   $display ("\n %t:\n !! Tx Bad TLP ReqID for TLP !!", $time);
                   Err_signal <= 1;
                end
            end
            else begin
                $display ("\n %t:\n !! trn_tsof_n error!", $time);
                Err_signal <= 1;
            end
         end


        'H12: begin
            if ( ~s_axis_tx_tvalid | ~s_axis_tx_tready) begin
              FSM_TLP_Fmt        <= 'H12;
            end
            else if (!trn_tsof_n) begin
              $display ("\n %t:\n !! trn_tsof_n error! should be 1.", $time);
              Err_signal <= 1;
            end
            else begin
              if (tx_TLP_4DW_Hdr & tx_TLP_Has_Data) begin
                if (~s_axis_tx_tlast) begin
                  Err_signal   <= 0;
                  FSM_TLP_Fmt        <= 'H20;
                end
                else begin
                  Err_signal   <= 1;
                  $display ("\n %t:\n !! s_axis_tx_tlast error (4-Header, with Payload)! should be 0.", $time);
                end
              end
              else if (tx_TLP_4DW_Hdr & !tx_TLP_Has_Data) begin
                if (~s_axis_tx_tlast) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! s_axis_tx_tlast error (4-Header, no Payload)! should be 1.", $time);
                end
                else if (s_axis_tx_tkeep=='Hff) begin
                    Err_signal <= 0;
                    FSM_TLP_Fmt        <= 'H10;
                end
                else begin
                    Err_signal <= 1;
                    $display ("\n %t:\n !! s_axis_tx_tkeep error (4-Header, no Payload)!", $time);
                end
              end
              else if (!tx_TLP_4DW_Hdr & !tx_TLP_Has_Data) begin
                if (~s_axis_tx_tlast) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! s_axis_tx_tlast error (3-Header, with Payload)! should be 1.", $time);
                end
                else if (s_axis_tx_tkeep=='H0f) begin
                  Err_signal <= 0;
                  FSM_TLP_Fmt        <= 'H10;
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! s_axis_tx_tkeep error (3-Header, no Payload)!", $time);
                end
              end
              else if (tx_TLP_Length=='H1) begin  // (!tx_TLP_4DW_Hdr & tx_TLP_Has_Data)
                if (~s_axis_tx_tlast) begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! s_axis_tx_tlast error (3-Header, with Payload)! should be 1.", $time);
                end
                else if (s_axis_tx_tkeep=='Hff) begin
                  if (tx_TLP_is_CplD && (s_axis_tx_tdata[31:16]==`C_HOST_RDREQ_ID)) begin
                    Err_signal    <= 0;
                    FSM_TLP_Fmt      <= 'H10;
                  end
                  else if (tx_TLP_is_CplD) begin
                    Err_signal   <= 1;
                    $display ("\n %t:\n !! Tx CplD Requester ID Wrong (TLP Length ==1 )!! ", $time);
                    FSM_TLP_Fmt      <= 'H10;
                  end
                  else begin
                    Err_signal    <= 0;
                    FSM_TLP_Fmt      <= 'H10;
                  end
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! s_axis_tx_tkeep error (3-Header, no Payload)!", $time);
                end
              end
              else begin  // (!tx_TLP_4DW_Hdr & tx_TLP_Has_Data) & (tx_TLP_Length>'H1)
                if (~s_axis_tx_tlast) begin
                  if (tx_TLP_is_CplD && (s_axis_tx_tdata[31:16]==`C_HOST_RDREQ_ID)) begin
                    tx_TLP_Length      <= tx_TLP_Length - 1;
                    FSM_TLP_Fmt        <= 'H20;
                  end
                  else if (tx_TLP_is_CplD) begin
                    Err_signal   <= 1;
                    $display ("\n %t:\n !! Tx CplD Requester ID Wrong (TLP Length !=1 )!! ", $time);
                    FSM_TLP_Fmt        <= 'H20;
                  end
                  else begin
                    tx_TLP_Length      <= tx_TLP_Length - 1;
                    FSM_TLP_Fmt        <= 'H20;
                  end
                end
                else begin
                  Err_signal <= 1;
                  $display ("\n %t:\n !! s_axis_tx_tlast error (3-Header, no Payload)! should be 0.", $time);
                end
              end

              // Address-Length combination check
              if (tx_TLP_4DW_Hdr) begin
                if (({1'b0, s_axis_tx_tdata[11+32:2+32]} + tx_TLP_Length[9:0])>11'H400) begin
                  $display ("\n %t:\n !! Tx 4KB straddled !!", $time);
                  $display ("\n Address=%08X  Length=%04X (%04X bytes)\n", s_axis_tx_tdata[31+32:0+32], tx_TLP_Length, tx_TLP_Length<<2);
                  Err_signal <= 1;
                end
                if (s_axis_tx_tdata[31:0]=='H0 && tx_Mem_TLP==1) begin
                  $display ("\n %t:\n !! Tx TLP should not be 4-DW headher !!", $time);
                  Err_signal <= 1;
                end
              end 
              else begin
                if (({1'b0, s_axis_tx_tdata[11:2]} + tx_TLP_Length[9:0])>11'H400) begin
                  $display ("\n %t:\n !! Tx 4KB straddled !!", $time);
                  $display ("\n Address=%08X  Length=%04X (%04X bytes)\n", s_axis_tx_tdata[31:0], tx_TLP_Length, tx_TLP_Length<<2);
                  Err_signal <= 1;
                end
              end

            end
          end


        'H20: begin
            if ( ~s_axis_tx_tvalid | ~s_axis_tx_tready) begin
              FSM_TLP_Fmt        <= 'H20;
            end
            else if (tx_TLP_Length==2) begin
              if (s_axis_tx_tkeep=='Hff && s_axis_tx_tlast==1) begin
                FSM_TLP_Fmt        <= 'H10;
              end
              else begin
                $display ("\n %t:\n !! s_axis_tx_tlast/s_axis_tx_tkeep error !!\n", $time);
                Err_signal <= 1;
              end
            end
            else if (tx_TLP_Length==1) begin
              if (s_axis_tx_tkeep=='H0f && s_axis_tx_tlast==1) begin
                FSM_TLP_Fmt        <= 'H10;
              end
              else begin
                $display ("\n %t:\n !! s_axis_tx_tlast/s_axis_tx_tkeep error !!\n", $time);
                Err_signal <= 1;
              end
            end
            else if (tx_TLP_Length==0) begin
              $display ("\n %t:\n !! Tx TLP Length error !!", $time);
              Err_signal <= 1;
            end
            else if (s_axis_tx_tlast) begin
              $display ("\n %t:\n !! s_axis_tx_tlast too early !!", $time);
              Err_signal <= 1;
            end
            else begin
              tx_TLP_Length      <= tx_TLP_Length - 2;
              FSM_TLP_Fmt        <= 'H20;
            end
         end

        default: begin
           FSM_TLP_Fmt     <= 'H00;
         end

      endcase
   end




   //************************************************//
   //************************************************//
   //************************************************//

   reg  [ 7:00] FSM_Tx_Desc_MRd;
  // Descriptors MRd
   always @(negedge user_clk )
   if (user_reset) begin
      FSM_Tx_Desc_MRd        <= 0;
      Desc_tx_MRd_Valid      <= 0;
   end
   else begin

      case (FSM_Tx_Desc_MRd)

        'H00: begin
            FSM_Tx_Desc_MRd       <= 'H10;
         end

        'H10: begin
           case ({ ~s_axis_tx_tvalid
                 , ~s_axis_tx_tready
                 , trn_tsof_n
                 , s_axis_tx_tdata[15+32]
                 })

             'B0001:
                 if ( (s_axis_tx_tdata[31:24]=='H00 || s_axis_tx_tdata[31:24]=='H20)
                    &&(s_axis_tx_tdata[9:0]=='H8)) begin
                      Desc_tx_MRd_Leng[10]  <= (s_axis_tx_tdata[9:0]==0);
                      Desc_tx_MRd_Leng[9:0] <= s_axis_tx_tdata[9:0];
                      Desc_tx_MRd_TAG       <= s_axis_tx_tdata[15+32:8+32];
                      FSM_Tx_Desc_MRd <= 'H31;
                 end
                 else begin
                      FSM_Tx_Desc_MRd <= 'H10;
                 end

              default: begin
                 FSM_Tx_Desc_MRd <= 'H10;
              end

           endcase
         end


        'H31: begin   // Low 32 bits Address
           if (~s_axis_tx_tvalid | ~s_axis_tx_tready) begin
             FSM_Tx_Desc_MRd   <= 'H31;
           end
           else begin
               Desc_tx_MRd_Addr      <= s_axis_tx_tdata[31+32:00+32];
               Desc_tx_MRd_Valid     <= 1;
               FSM_Tx_Desc_MRd       <= 'H10;
           end
         end


        default: begin
           FSM_Tx_Desc_MRd <= 'H00;
         end

      endcase
   end



   // DMA MRd out of Tx
   reg [ 7: 0]   FSM_Tx_MRd;
   reg           tx_DMA_MRd_A64b;
   always @(negedge user_clk )
   if (user_reset) begin
      FSM_Tx_MRd      <= 0;
      tx_MRd_come     <= 0;
   end
   else begin

      case (FSM_Tx_MRd)

        'H00: begin
            FSM_Tx_MRd       <= 'H10;
         end

        'H10: begin
           case ({ ~s_axis_tx_tvalid
                 , ~s_axis_tx_tready
                 , trn_tsof_n
                 , s_axis_tx_tdata[15+32]
                 })

             'B0000:
                 case (s_axis_tx_tdata[31:24])
                   'H00: begin   // 3-dw header
                      tx_MRd_Length[9:0] <= s_axis_tx_tdata[9:0];
                      tx_MRd_Length[10]  <= (s_axis_tx_tdata[9:0]=='H0)?1:0;
                      tx_MRd_Tag         <= s_axis_tx_tdata[15+32:8+32];
                      FSM_Tx_MRd         <= 'H30;
                      tx_DMA_MRd_A64b    <= 0;
                    end

                   'H20: begin   // 4-dw header
                      tx_MRd_Length[9:0] <= s_axis_tx_tdata[9:0];
                      tx_MRd_Length[10]  <= (s_axis_tx_tdata[9:0]=='H0)?1:0;
                      tx_MRd_Tag         <= s_axis_tx_tdata[15+32:8+32];
                      FSM_Tx_MRd         <= 'H30;
                      tx_DMA_MRd_A64b    <= 1;
                    end

                   default: begin
                      FSM_Tx_MRd <= 'H10;   // Idle
                    end
                 endcase

              default: begin
                 FSM_Tx_MRd <= 'H10;
              end

           endcase
         end


        'H30: begin
           if (~s_axis_tx_tvalid | ~s_axis_tx_tready) begin
             FSM_Tx_MRd <= 'H30;
           end
           else if( s_axis_tx_tdata[1+32:0+32]==0) begin
             FSM_Tx_MRd <= 'H10;
             tx_MRd_come <= 'B1;
           end
           else begin
             $display ("\n %t:\n !! Bad TLP Address for Tx MRd !!", $time);
             Err_signal <= 1;
           end
        end

        default: begin
           FSM_Tx_MRd <= 'H00;
         end

      endcase
   end



   // Msg checking ...
   reg [7: 0] fsm_Tx_Msg;
   reg [3: 0] tx_Msg_Tag_Lo;
   always @(negedge user_clk )
   if (user_reset) begin
      fsm_Tx_Msg      <= 0;
      tx_Msg_Tag_Lo   <= 1;
   end

   else begin

      case (fsm_Tx_Msg)

        'H00: begin
            fsm_Tx_Msg    <= 'H10;
         end

        'H10: begin
           case ({ ~s_axis_tx_tvalid
                 , ~s_axis_tx_tready
                 , trn_tsof_n
                 })

             'B000:
                 if (s_axis_tx_tdata[31:28]=='H3) begin
                    fsm_Tx_Msg    <= 'H30;
                    if ( s_axis_tx_tdata[11+32:8+32] != tx_Msg_Tag_Lo ) begin
                      $display ("\n %t:\n !! Msg Tag bad !!", $time, s_axis_tx_tdata[11+32:8+32]);
                      Err_signal <= 1;
                    end
                    else if ( s_axis_tx_tdata[7+32:0+32] == `C_MSG_CODE_INTA ) begin
//                      fsm_Tx_Msg   <= 'H30;
                      Accum_Msg_INTA <= Accum_Msg_INTA + 1;
                    end
                    else if ( s_axis_tx_tdata[7+32:0+32] == `C_MSG_CODE_INTA_N ) begin
//                      fsm_Tx_Msg   <= 'H30;
                      Accum_Msg_INTA_n <= Accum_Msg_INTA_n + 1;
                    end
                    else begin
                      $display ("\n %t:\n !! Bad Msg code (0x%2x) !!", $time, s_axis_tx_tdata[7+32:0+32]);
                      Err_signal <= 1;
                    end
                 end
                 else begin
                      fsm_Tx_Msg    <= 'H10;
                 end

              default: begin
                 fsm_Tx_Msg    <= 'H10;
              end

           endcase
         end


        'H30: begin
           if (~s_axis_tx_tvalid | ~s_axis_tx_tready) begin
             fsm_Tx_Msg <= 'H30;
           end
           else if (s_axis_tx_tdata) begin
             $display ("\n %t:\n !! Msg data bad!!", $time);
             Err_signal <= 1;
           end
           else begin
             fsm_Tx_Msg <= 'H10;
             tx_Msg_Tag_Lo  <= tx_Msg_Tag_Lo + 1;
           end
         end


        default: begin
           fsm_Tx_Msg  <= 'H00;
         end

      endcase
   end



   // ================================================= //
   // =======     Interrupt uneven checking     ======= //
   // ================================================= //
   always @ Accum_Msg_INTA
     if (Accum_Msg_INTA>Accum_Msg_INTA_n+1) begin
        $display("\n\n  INTA overrun at %t\n\n", $time);
        Err_signal <= 1;
     end

   // 
   always @ Accum_Msg_INTA_n
     if (Accum_Msg_INTA_n>Accum_Msg_INTA) begin
        $display("\n\n  #INTA overrun at %t\n\n", $time);
        Err_signal <= 1;
     end




  // ***************************************** //
  //                   Tasks                   //
  // ***************************************** //

  ///////////////////////////////////////////////
  //   Wait for the next positive clock event  //
  ///////////////////////////////////////////////
  task To_the_next_Event;
  begin
    wait (!user_clk);
    wait (user_clk);
    # `T_DELAY_AFTER ;
  end
  endtask

  ///////////////////////////////////////////////
  //   Wait for the next negative clock event  //
  ///////////////////////////////////////////////
  task To_the_next_Tx_Data;
  begin
    wait (user_clk);
    wait (!user_clk);
    # `T_DELAY_AFTER ;
  end
  endtask


  ///////////////////////////////////////////////
  //   Insert GAP                              //
  ///////////////////////////////////////////////
  task Gap_Insert_Rx;
  begin
    To_the_next_Event;
    trn_rsof_n <= 1;
    m_axis_rx_tlast <= 0;
    m_axis_rx_tvalid <= 0;
    m_axis_rx_tbar_hit <= `C_NO_BAR_HIT;
    m_axis_rx_tdata <= -1;
    m_axis_rx_tkeep <= 'Hff;
  end
  endtask


  ///////////////////////////////////////////////
  //                                           //
  //   Feed TLP to Rx: MRd, MWr, Cpl/D, Msg    //
  //                                           //
  ///////////////////////////////////////////////
  task TLP_Feed_Rx;
    input         Use_Private_Array;   // Public or private
    input [11:0]  IndexA;              // Start point in the Array
    input [ 6:0]  BAR_Hit_N;           // Which BAR is hit

//    integer       hdr_Leng;
    reg           TLP_has_Payload;
    reg           TLP_hdr_4DW;
    reg   [10:0]  jr;
    reg   [10:0]  payload_Leng;

  begin

    // TLP format extraction
    TLP_has_Payload     <= Hdr_Array[0][30] ;
//    hdr_Leng            <= Hdr_Array[0][29] + 3;
    TLP_hdr_4DW         <= Hdr_Array[0][29];

    // Header #0
    To_the_next_Event;
    trn_rsof_n          <= 0;
    m_axis_rx_tlast          <= 0;
    m_axis_rx_tvalid      <= 1;
    m_axis_rx_tbar_hit      <= BAR_Hit_N;
    m_axis_rx_tdata              <= {Hdr_Array[1], Hdr_Array[0]};
    m_axis_rx_tkeep          <= 'Hff;

    payload_Leng        <= {Hdr_Array[0][9:0]?1'b0:1'b1, Hdr_Array[0][9:0]};

    // Header words # 1
    for (jr=1; jr<2; jr=jr+1) begin
      To_the_next_Event;
      m_axis_rx_tvalid  <= m_axis_rx_tvalid_seed;
      if (~m_axis_rx_tvalid_seed) begin
          trn_rsof_n    <= trn_rsof_n;
          m_axis_rx_tdata        <= m_axis_rx_tdata;
          m_axis_rx_tkeep    <= m_axis_rx_tkeep;
          m_axis_rx_tlast    <= m_axis_rx_tlast;
//          #0.1    jr    <= jr-1;
          jr             = jr-1;      // !! not <= !!
        end
      else begin
          trn_rsof_n    <= 1;
          if (TLP_hdr_4DW) begin
            m_axis_rx_tkeep    <= 'Hff;
            m_axis_rx_tdata        <= {Hdr_Array[3], Hdr_Array[2]};
          end
          else if (TLP_has_Payload) begin
            m_axis_rx_tkeep    <= 'Hff;
            if (Use_Private_Array)
              m_axis_rx_tdata        <= {Inv_Endian(Private_Array[IndexA]), Hdr_Array[2]};
            else
              m_axis_rx_tdata        <= {Inv_Endian(D_Array[IndexA]), Hdr_Array[2]};
          end
          else begin
            m_axis_rx_tkeep    <= 'H0f;
            m_axis_rx_tdata        <= {32'H0, Hdr_Array[2]};
          end
          if (payload_Leng<='H1 && TLP_hdr_4DW==0) begin
            m_axis_rx_tlast    <= 1;
          end
          else if (!TLP_has_Payload) begin
            m_axis_rx_tlast    <= 1;
          end
          else begin
            m_axis_rx_tlast    <= 0;
          end
        end
    end    // Header done.

    // Payload data ...
    if ((TLP_has_Payload && TLP_hdr_4DW) || (TLP_has_Payload && (payload_Leng>'H1) && !TLP_hdr_4DW))

       for (jr=(!TLP_hdr_4DW); jr<payload_Leng; jr=jr+2) begin
         To_the_next_Event;
         m_axis_rx_tvalid <= m_axis_rx_tvalid_seed;
         if (~m_axis_rx_tvalid_seed) begin
           m_axis_rx_tdata       <= m_axis_rx_tdata;
           m_axis_rx_tkeep   <= m_axis_rx_tkeep;
           m_axis_rx_tlast   <= m_axis_rx_tlast;
//           #0.1    jr   <= jr-1;
           jr            = jr-2;      // !! not <= !!
         end
         else begin
           if (jr==payload_Leng-1 || jr==payload_Leng-2) begin
             m_axis_rx_tlast   <= 1;
           end
           else begin
             m_axis_rx_tlast   <= 0;
           end

           if (jr==payload_Leng-1) begin
             m_axis_rx_tkeep   <= 'H0f;
             if (Use_Private_Array)
               m_axis_rx_tdata     <= {32'Hffff_ffff, Inv_Endian(Private_Array[IndexA+jr])};
             else
               m_axis_rx_tdata     <= {32'Hffff_ffff, Inv_Endian(D_Array[IndexA+jr])};
           end
           else begin
             m_axis_rx_tkeep   <= 'Hff;
             if (Use_Private_Array)
               m_axis_rx_tdata     <= {Inv_Endian(Private_Array[IndexA+jr+1]), Inv_Endian(Private_Array[IndexA+jr])};
             else
               m_axis_rx_tdata     <= {Inv_Endian(D_Array[IndexA+jr+1]), Inv_Endian(D_Array[IndexA+jr])};
           end


         end
       end
    // Payload done.

  end
  endtask


    /////////////////////////////////////////////
   //                                         //
  //   Function -  Endian Inversion 64-bit   //
 //                                         //
/////////////////////////////////////////////
   function [31:00] Inv_Endian;
   input [31:00] Data;
   begin
      Inv_Endian = {Data[ 7: 0], Data[15: 8], Data[23:16], Data[31:24]};
   end
   endfunction


endmodule
