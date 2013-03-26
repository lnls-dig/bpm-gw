////////////////////////////////////////////////////////////////////////////////
// Company:  ziti, Uni. HD
// Engineer:  wgao
//            weng.ziti@gmail.com
//            (2012-) Adrian Byszuk <adrian.byszuk@gmail.com>
// 
// Create Date:   16:54:18 04 Nov 2008
// Design Name:   tlpControl
// Module Name:   tf64_pcie_axi.v
// Project Name:  PCIE_SG_DMA
// Target Device:  
// Tool versions:  
// Description:  PIO and DMA are both simulated.
//
// Verilog Test Fixture attached to top module
//
// Dependencies: Root port simulation model generated with Xilinx PCIe Core
// 
// Revision:
// Revision 0.01 - File Created
// 
// Revision 1.00 - Released to OpenCores.org   14.09.2011
// Revision 2.00 - Ported to fit with the simulation code provided by Xilinx 14.12.2012
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////


  //  Simulation procedure
else if (testname == "tf64_pcie_axi")
begin

    TSK_SIMULATION_TIMEOUT(10000);

    // Simulation Initialization
    board.DMA_bar               = 'H1;
    board.Rx_MWr_Tag            = 'H80;
    board.Rx_MRd_Tag            = 'H10;
    board.localID = 'H01a0;

    board.RP.tx_usrapp.TSK_SIMULATION_TIMEOUT(11000);
    board.RP.tx_usrapp.TSK_SYSTEM_INITIALIZATION;
    board.RP.tx_usrapp.TSK_BAR_INIT;

  //set MEM+IO access, enable Bus Master mode
    board.RP.cfg_usrapp.TSK_READ_CFG_DW(32'h00000001);
    board.RP.cfg_usrapp.TSK_WRITE_CFG_DW(32'h00000001, 32'h00000007, 4'b1110);
    board.RP.cfg_usrapp.TSK_READ_CFG_DW(32'h00000001);

    $display("\n%d ns: ####  Starting test...  ####\n", $time);
    // Initialization: TLP
    # 400
      board.Rx_TLP_Length    = 'H01;

        // reset TX module
      $display("   reset TX module\n");
      board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
      board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
      board.Hdr_Array[2] = `C_ADDR_TX_CTRL;
      dword_pack_data_store('H0000000A, 0);
    
      TLP_Feed_Rx(`C_BAR0_HIT);
      board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;


         // Test MRd with 4-DW header  BAR[0]
      $display("%d ns:   Test MRd with 3-DW header  BAR[0]", $time);
      board.Hdr_Array[0] = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
      board.Hdr_Array[1] = {`C_HOST_RDREQ_ID, 8'HA1, 4'Hf, 4'Hf};
      board.Hdr_Array[3] = -1;
      board.Hdr_Array[2] = `C_ADDR_VERSION;
    
      TLP_Feed_Rx(`C_BAR0_HIT);
      board.Rx_MRd_Tag       = board.Rx_MRd_Tag + 1;
  board.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;
  
  
      board.Rx_TLP_Length    = 'H01;
        // reset upstream DMA channel
      $display("%d ns:   reset upstream DMA channel", $time);
      board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
      board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
      board.Hdr_Array[2] = `C_ADDR_DMA_US_CTRL;
      dword_pack_data_store(`C_DMA_RST_CMD, 0);
    
      TLP_Feed_Rx(`C_BAR0_HIT);
      board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

        // reset downstream DMA channel
      $display("%d ns:   reset downstream DMA channel", $time);
      board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
      board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
      board.Hdr_Array[3] = -1;
      //board.Hdr_Array[3] = `C_ADDR_DMA_DS_CTRL;
      dword_pack_data_store(`C_DMA_RST_CMD, 0);
    
      TLP_Feed_Rx(`C_BAR0_HIT);
      board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;


        // reset Event Buffer FIFO
      $display("%d ns:   reset Event Buffer FIFO", $time);
      board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
      board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
      board.Hdr_Array[2] = `C_ADDR_EB_STACON;
      dword_pack_data_store('H0000000A, 0);
    
      TLP_Feed_Rx(`C_BAR0_HIT);
      board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;


        // Enable INTerrupts
      $display("%d ns:   Enable INTerrupts", $time);
      board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
      board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
      board.Hdr_Array[2] = `C_ADDR_IRQ_EN;
      dword_pack_data_store('H0000_0003, 0);
    
      TLP_Feed_Rx(`C_BAR0_HIT);
      board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

    /////////////////////////////////////////////////////////////////////
    //                       PIO simulation                            //
    /////////////////////////////////////////////////////////////////////

   $display("\n%d ns: #### PIO simulation ####\n", $time);
   
     # `T_PIO_INTERVAL;

    //  ///////////////////////////////////////////////////////////////////
    //  PIO write & read BAR[0]
      $display("\n%d ns:   PIO write & read BAR[0]", $time);
       board.PIO_Addr         = `C_ADDR_DMA_US_PAH + 'H8;
       board.PIO_1st_BE       = 4'Hf;
       board.Hdr_Array[0]     = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1]     = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, board.PIO_1st_BE};
       board.Hdr_Array[2]     = {board.PIO_Addr[31:2], 2'b00};
       dword_pack_data_store('HF000_8888, 0);
       board.Rx_TLP_Length    = 'H01;
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

     
       board.Hdr_Array[0]     = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1]     = {`C_HOST_RDREQ_ID, 3'H3, board.Rx_MRd_Tag, 4'Hf, board.PIO_1st_BE};
       board.Hdr_Array[2]     = {board.PIO_Addr[31:2], 2'b00};
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MRd_Tag       = board.Rx_MRd_Tag + 1;
  board.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;

    //  ///////////////////////////////////////////////////////////////////
    //  PIO write & read BAR[1]
      $display("\n%d ns:   PIO write & read BAR[1]", $time);
       board.PIO_Addr         = 'H8000;
       board.PIO_1st_BE       = 4'Hf;
       board.Hdr_Array[0]     = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1]     = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, board.PIO_1st_BE};
       board.Hdr_Array[2]     = {board.PIO_Addr[31:2], 2'b00};
       dword_pack_data_store('HA1111111, 0);
       board.Rx_TLP_Length    = 'H01;
     
       TLP_Feed_Rx(`C_BAR1_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;


     
       board.Hdr_Array[0]     = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1]     = {`C_HOST_RDREQ_ID, 3'H3, board.Rx_MRd_Tag, 4'Hf, board.PIO_1st_BE};
       board.Hdr_Array[2]     = {board.PIO_Addr[31:2], 2'b00};
     
       TLP_Feed_Rx(`C_BAR1_HIT);
       board.Rx_MRd_Tag       = board.Rx_MRd_Tag + 1;
  board.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;

    //  ///////////////////////////////////////////////////////////////////
    //  PIO write & read BAR[2]
    //  NOTE:  FIFO address is 64-bit aligned, only the lower 32-bit is
    //         accessible by BAR[2] PIO write and is returned in BAR[2] 
    //         PIO read.
      $display("\n%d ns:   PIO write & read BAR[2]", $time);
       board.PIO_Addr         = 'H0;
       board.PIO_1st_BE       = 4'Hf;
       board.Hdr_Array[0]     = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1]     = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, board.PIO_1st_BE};
       board.Hdr_Array[2]     = {board.PIO_Addr[31:2], 2'b00};
       dword_pack_data_store('HB222_2222, 0);
       board.Rx_TLP_Length    = 'H01;
     
       TLP_Feed_Rx(`C_BAR2_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;


     
       board.Hdr_Array[0]     = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1]     = {`C_HOST_RDREQ_ID, 3'H3, board.Rx_MRd_Tag, 4'Hf, board.PIO_1st_BE};
       board.Hdr_Array[2]     = {board.PIO_Addr[31:2], 2'b00};
     
       TLP_Feed_Rx(`C_BAR2_HIT);
       board.Rx_MRd_Tag       = board.Rx_MRd_Tag + 1;
  board.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;

    $display("%d ns: ### End PIO simulation\n", $time);

    //  ///////////////////////////////////////////////////////////////////
    //  DMA write & read BAR[1]
    //  Single-descriptor case
      $display("\n%d ns: ### DMA write & read BAR[1], Single-descriptor case###\n", $time);
       board.DMA_PA   = 'H1234;
       board.DMA_HA   = 'H5000;
       board.DMA_BDA  = 'Hffff;
       board.DMA_Leng = 'H0100;
       board.DMA_bar  = 'H1;
       board.DMA_ds_is_Last  = 'B1;

     

       //  DMA write
      $display("\n%d ns: >> DMA write", $time);
      board.Rx_TLP_Length    = 'H01;

     
       board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_DS_PAH;
       dword_pack_data_store(-1, 0);
       //  Write PA_H
       $display("%d ns:   Write PA_H", $time);
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write PA_L
       $display("%d ns:   Write PA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_PA[31:00], 0);       //'H0300, 0
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write HA_H
       $display("%d ns:   Write HA_H", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_HA[63:32], 0);       // 0,
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;
      
       //  Write HA_L
       $display("%d ns:   Write HA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_HA[31:00], 0);     // 'H4000
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write BDA_H
       $display("%d ns:   Write BDA_H", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_BDA[63:32], 0);      // 0
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write BDA_L
       $display("%d ns:   Write BDA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_BDA[31:00], 0); //'H0BDA0090
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write LENG
       $display("%d ns:   Write LENG", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_Leng, 0);            //'H100
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write CTRL and start the DMA
       $display("%d ns:   Write CTRL and start the DMA", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store({4'H0
                            ,3'H1, board.DMA_ds_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, board.DMA_bar
                            ,1'B1
                            ,15'H0
                            }, 0);
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

          // Polling the DMA status
     $display("%d ns:   Polling the DMA status", $time);
       board.Hdr_Array[0] = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_RDREQ_ID, 3'H3, board.Rx_MRd_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_DS_STA;
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MRd_Tag       = board.Rx_MRd_Tag + 1;

       board.Tx_MRd_Leng  = board.DMA_Leng>>2;
       board.Tx_MRd_Addr  = board.DMA_HA[31:0];
       board.tx_MRd_Tag = 'H0;
       board.tx_MRd_Tag_k = board.tx_MRd_Tag;
       board.CplD_Index   = 'H0;
       board.Rx_TLP_Length = 'H10;
     
       
  fork
    board.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;

    board.RP.com_usrapp.TSK_EXPECT_MEMRD(3'b000, 1'b0, 1'b0, 2'b00,
					board.Tx_MRd_Leng,
					board.localID,
					7'h0,
					4'hf,
					4'hf,
					board.Tx_MRd_Addr[31:2],
          expect_status);
  join

       if (expect_status == 0) begin
         $display("[%t]: got unexpected TLP !!!", $realtime);
         $finish(1);
       end

       // feeding the payload CplD
       $display("%d ns:   feeding the payload CplD", $time);
     
       board.Hdr_Array[0] = `HEADER0_CPLD | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_CPLD_ID, 4'H0, board.Tx_MRd_Leng[9:0], 2'b00};
       board.Hdr_Array[2] = {board.localID, board.tx_MRd_Tag_k, 1'b0, board.Tx_MRd_Addr[6:0]};
       board.Tx_MRd_Leng  = board.Tx_MRd_Leng - board.Rx_TLP_Length;
       board.Tx_MRd_Addr  = board.Tx_MRd_Addr + board.Rx_TLP_Length;
     
       Copy_rnd_data;
       TLP_Feed_Rx(`C_NO_BAR_HIT);
       board.CplD_Index   = board.CplD_Index + board.Rx_TLP_Length;

       board.Hdr_Array[0] = `HEADER0_CPLD | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_CPLD_ID, 4'H0, board.Tx_MRd_Leng[9:0], 2'b00};
       board.Hdr_Array[2] = {board.localID, board.tx_MRd_Tag_k, 1'b0, board.Tx_MRd_Addr[6:0]};
       board.Tx_MRd_Leng  = board.Tx_MRd_Leng - board.Rx_TLP_Length;
       board.Tx_MRd_Addr  = board.Tx_MRd_Addr + board.Rx_TLP_Length;
     
       Copy_rnd_data;
       TLP_Feed_Rx(`C_NO_BAR_HIT);
       board.CplD_Index   = board.CplD_Index + board.Rx_TLP_Length;

       board.Hdr_Array[0] = `HEADER0_CPLD | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_CPLD_ID, 4'H0, board.Tx_MRd_Leng[9:0], 2'b00};
       board.Hdr_Array[2] = {board.localID, board.tx_MRd_Tag_k, 1'b0, board.Tx_MRd_Addr[6:0]};
       board.Tx_MRd_Leng  = board.Tx_MRd_Leng - board.Rx_TLP_Length;
       board.Tx_MRd_Addr  = board.Tx_MRd_Addr + board.Rx_TLP_Length;
     
       Copy_rnd_data;
       TLP_Feed_Rx(`C_NO_BAR_HIT);
       board.CplD_Index   = board.CplD_Index + board.Rx_TLP_Length;

       board.Hdr_Array[0] = `HEADER0_CPLD | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_CPLD_ID, 4'H0, board.Tx_MRd_Leng[9:0], 2'b00};
       board.Hdr_Array[2] = {board.localID, board.tx_MRd_Tag_k, 1'b0, board.Tx_MRd_Addr[6:0]};
       board.Tx_MRd_Leng  = board.Tx_MRd_Leng - board.Rx_TLP_Length;
       board.Tx_MRd_Addr  = board.Tx_MRd_Addr + board.Rx_TLP_Length;
     
       Copy_rnd_data;
       TLP_Feed_Rx(`C_NO_BAR_HIT);
       board.CplD_Index   = board.CplD_Index + board.Rx_TLP_Length;


       board.Rx_TLP_Length    = 'H01;
       while (P_READ_DATA[0] != 'b1) begin
        $display("%d ns:   Polling DMA status", $time);
         board.Hdr_Array[0] = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
         board.Hdr_Array[1] = {`C_HOST_RDREQ_ID, 3'H3, board.Rx_MRd_Tag, 4'Hf, 4'Hf};
         board.Hdr_Array[2] = `C_ADDR_DMA_DS_STA;
     
         TLP_Feed_Rx(`C_BAR0_HIT);
         board.Rx_MRd_Tag       = board.Rx_MRd_Tag + 1;
         
         TSK_WAIT_FOR_READ_DATA;
       end


       //  DMA read
      $display("\n%d ns: >DMA read", $time);
       board.Rx_TLP_Length    = 'H01;

       board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_US_PAH;
       dword_pack_data_store(-1, 0);
       //  Write PA_H
       $display("%d ns:   Write PA_H", $time);
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write PA_L
       $display("%d ns:   Write PA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_PA[31:00], 0);       //'H0300,
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write HA_H
       $display("%d ns:   Write HA_H", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_HA[63:32], 0);       // 0
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;
      
       //  Write HA_L
       $display("%d ns:   Write HA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_HA[31:00], 0);     // 'H4000
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write BDA_H
       $display("%d ns:   Write BDA_H", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_BDA[63:32], 0);      // 0
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write BDA_L
       $display("%d ns:   Write BDA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_BDA[31:00], 0); //'H0BDA0090
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write LENG
       $display("%d ns:   Write LENG", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_Leng, 0);            //'H100
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write CTRL and start the DMA
       $display("%d ns:   Write CTRL and start the DMA", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store({4'H0
                            ,3'H1, board.DMA_ds_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, board.DMA_bar
                            ,1'B1
                            ,15'H0
                            }, 0);
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;


       board.Rx_TLP_Length    = 'H01;
     $display("%d ns:   Polling DMA status", $time);
       board.Hdr_Array[0] = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_RDREQ_ID, 3'H3, board.Rx_MRd_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_US_STA;
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MRd_Tag      = board.Rx_MRd_Tag + 1;
       TSK_WAIT_FOR_READ_DATA;
       
       while (P_READ_DATA[0] != 'b1) begin
        $display("%d ns:   Polling DMA status", $time);
         board.Hdr_Array[0] = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
         board.Hdr_Array[1] = {`C_HOST_RDREQ_ID, 3'H3, board.Rx_MRd_Tag, 4'Hf, 4'Hf};
         board.Hdr_Array[2] = `C_ADDR_DMA_US_STA;
     
         TLP_Feed_Rx(`C_BAR0_HIT);
         board.Rx_MRd_Tag       = board.Rx_MRd_Tag + 1;
         
         TSK_WAIT_FOR_READ_DATA;
       end
  //////////////////////////////////////////////////////////////////////////////////

       board.Rx_TLP_Length    = 'H01;
         // reset downstream DMA channel
     $display("%d ns:   reset downstream DMA channel", $time);
       board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_DS_CTRL;
       dword_pack_data_store(`C_DMA_RST_CMD, 0);
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;


       board.Rx_TLP_Length    = 'H01;
         // reset upstream DMA channel
     $display("%d ns:   reset upstream DMA channel", $time);
       board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_US_CTRL;
       dword_pack_data_store(`C_DMA_RST_CMD, 0);

     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

  //////////////////////////////////////////////////////////////////////////////////


    //  ///////////////////////////////////////////////////////////////////
    //  DMA write & read BAR[2]
    //  Multiple-descriptor case
    //  
      $display("\n### DMA write & read BAR[2], Multiple-descriptor case ###\n");
       board.DMA_PA   = 'H789AB8;
       board.DMA_HA   = 'HDF0000;
       board.DMA_BDA  = 'H0BDABDA0;
       board.DMA_Leng = 'H0208;
       board.DMA_L1   = 'H0100;
       board.DMA_L2   = board.DMA_Leng - board.DMA_L1;
       board.DMA_bar  = 'H2;
       board.DMA_ds_is_Last  = 'B0;


       board.Rx_TLP_Length    = 'H01;

       board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_DS_PAH;
       dword_pack_data_store(0, 0);
       //  Write PA_H
       $display("%d ns:   Write PA_H", $time);
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write PA_L
       $display("%d ns:   Write PA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_PA[31:00], 0);       //'H0300
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write HA_H
       $display("%d ns:   Write HA_H", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_HA[63:32], 0);       // 0
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;
      
       //  Write HA_L
       $display("%d ns:   Write HA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_HA[31:00], 0);     // 'H4000
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write BDA_H
       $display("%d ns:   Write BDA_H", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_BDA[63:32], 0);      // 0
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write BDA_L
       $display("%d ns:   Write BDA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_BDA[31:00], 0); //'H0BDA0090
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write LENG
       $display("%d ns:   Write LENG", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_L1, 0);            //'H100
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write CTRL and start the DMA
       $display("%d ns:   Write CTRL and start the DMA", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store({4'H0
                            ,3'H1, board.DMA_ds_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, board.DMA_bar
                            ,1'B1
                            ,15'H0
                            }, 0);
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;
  
       
       board.Desc_tx_MRd_TAG = 'hC0;
       board.Tx_MRd_Leng  = board.DMA_L1>>2;
       board.Tx_MRd_Addr  = board.DMA_HA[31:0];
       board.tx_MRd_Tag = 'h40;
       board.tx_MRd_Tag_k = board.tx_MRd_Tag;
       board.CplD_Index   = 'H0;

       fork
         begin
         board.RP.com_usrapp.TSK_EXPECT_MEMRD(3'b000, 1'b0, 1'b0, 2'b00,
            'h8, //descriptor size
            board.localID,
            board.Desc_tx_MRd_TAG,
            4'hf,
            4'hf,
            board.DMA_BDA[31:2],
            expect_status);
           if (expect_status == 0) begin
             $display("[%t]: got unexpected TLP !!!", $realtime);
             $finish(1);
           end 
         end
         
         begin
         board.RP.com_usrapp.TSK_EXPECT_MEMRD(3'b000,	1'b0, 1'b0, 2'b00,
            board.Tx_MRd_Leng,
            board.localID,
            board.tx_MRd_Tag,
            4'hf,
            4'hf,
            board.Tx_MRd_Addr[31:2],
            expect_status);
           if (expect_status == 0) begin
             $display("[%t]: got unexpected TLP !!!", $realtime);
             $finish(1);
           end 
         end
       join

       // Second DMA descriptor
       board.DMA_ds_is_Last    = 'B1;
       dword_pack_data_store(0, 0);
       dword_pack_data_store(board.DMA_PA[31:00] + 'H500, 1);
       dword_pack_data_store(board.DMA_HA[63:32], 2);          // 0
       dword_pack_data_store(board.DMA_HA[31:00] + 'H500, 3);
       dword_pack_data_store(-1, 4);                     // dont-car
       dword_pack_data_store(-1, 5);                     // dont-car
       dword_pack_data_store(board.DMA_L2, 6);
       dword_pack_data_store({4'H0
                            ,3'H1, board.DMA_ds_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, board.DMA_bar
                            ,1'B1
                            ,15'H0
                            }, 7);
       // feeding the descriptor CplD
       $display("%d ns:   feeding the descriptor CplD", $time);
       board.Rx_TLP_Length    = 'H08;
       board.Hdr_Array[0] = `HEADER0_CPLD | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_CPLD_ID, 4'H0, board.Rx_TLP_Length[9:0], 2'b00};
       board.Hdr_Array[2] = {board.localID, board.Desc_tx_MRd_TAG, 1'b0, board.DMA_BDA[6:0]};
       TLP_Feed_Rx(`C_NO_BAR_HIT);

       $display("%d ns:   feeding the payload CplD", $time);

       board.Rx_TLP_Length    = 'H10;
       while (board.Tx_MRd_Leng >= board.Rx_TLP_Length) begin
         board.Hdr_Array[0] = `HEADER0_CPLD | board.Rx_TLP_Length[9:0];
         board.Hdr_Array[1] = {`C_HOST_CPLD_ID, 4'H0, board.Tx_MRd_Leng[9:0], 2'b00};
         board.Hdr_Array[2] = {board.localID, board.tx_MRd_Tag_k, 1'b0, board.Tx_MRd_Addr[6:0]};
         board.Tx_MRd_Leng  = board.Tx_MRd_Leng - board.Rx_TLP_Length;
         board.Tx_MRd_Addr  = board.Tx_MRd_Addr + board.Rx_TLP_Length;
       
         Copy_rnd_data;
         TLP_Feed_Rx(`C_NO_BAR_HIT);
         board.CplD_Index   = board.CplD_Index + board.Rx_TLP_Length;
       end
       //check for last, non-full TLP to send
       if (board.Tx_MRd_Leng > 'h0) begin
         board.Hdr_Array[0] = `HEADER0_CPLD | board.Tx_MRd_Leng[9:0];
         board.Hdr_Array[1] = {`C_HOST_CPLD_ID, 4'H0, board.Tx_MRd_Leng[9:0], 2'b00};
         board.Hdr_Array[2] = {board.localID, board.tx_MRd_Tag_k, 1'b0, board.Tx_MRd_Addr[6:0]};
         board.Tx_MRd_Leng  = board.Tx_MRd_Leng - board.Rx_TLP_Length;
       
         Copy_rnd_data;
         TLP_Feed_Rx(`C_NO_BAR_HIT);
         board.CplD_Index   = board.CplD_Index + board.Rx_TLP_Length;
       end

       TSK_TX_CLK_EAT(50); //wait a bit to distinguish payloads in waveform dump

       // feeding the payload CplD (2nd descriptor)
       $display("%d ns:   feeding the payload CplD (2nd descriptor)", $time);
       board.Tx_MRd_Leng  = (board.DMA_L2>>2) - 'h2;
       board.Tx_MRd_Addr  = board.DMA_HA[31:0] + 'H500;
       board.tx_MRd_Tag_k = board.tx_MRd_Tag_k + 'H1;
       board.CplD_Index   = 'H40;
       board.Rx_TLP_Length    = 'H10;
       
       while (board.Tx_MRd_Leng >= board.Rx_TLP_Length) begin
         board.Hdr_Array[0] = `HEADER0_CPLD | board.Rx_TLP_Length[9:0];
         board.Hdr_Array[1] = {`C_HOST_CPLD_ID, 4'H0, board.Tx_MRd_Leng[9:0], 2'b00};
         board.Hdr_Array[2] = {board.localID, board.tx_MRd_Tag_k, 1'b0, board.Tx_MRd_Addr[6:0]};
         board.Tx_MRd_Leng  = board.Tx_MRd_Leng - board.Rx_TLP_Length;
         board.Tx_MRd_Addr  = board.Tx_MRd_Addr + board.Rx_TLP_Length;
       
         Copy_rnd_data;
         TLP_Feed_Rx(`C_NO_BAR_HIT);
         board.CplD_Index   = board.CplD_Index + board.Rx_TLP_Length;
       end
       //check for last, non-full TLP to send
       if (board.Tx_MRd_Leng > 'h0) begin
         board.Hdr_Array[0] = `HEADER0_CPLD | board.Tx_MRd_Leng[9:0];
         board.Hdr_Array[1] = {`C_HOST_CPLD_ID, 4'H0, board.Tx_MRd_Leng[9:0], 2'b00};
         board.Hdr_Array[2] = {board.localID, board.tx_MRd_Tag_k, 1'b0, board.Tx_MRd_Addr[6:0]};
         board.Tx_MRd_Leng  = board.Tx_MRd_Leng - board.Rx_TLP_Length;
       
         Copy_rnd_data;
         TLP_Feed_Rx(`C_NO_BAR_HIT);
         board.CplD_Index   = board.CplD_Index + board.Rx_TLP_Length;
       end

//TODO: fix this to an automatic, generic way
//feed the 2nd read request
       board.Tx_MRd_Leng  = 'h2;
       board.Tx_MRd_Addr  = board.DMA_HA[31:0] + 'H600;
       board.tx_MRd_Tag_k = board.tx_MRd_Tag_k + 'H1;
       board.Rx_TLP_Length    = 'H2;
       
       board.Hdr_Array[0] = `HEADER0_CPLD | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_CPLD_ID, 4'H0, board.Tx_MRd_Leng[9:0], 2'b00};
       board.Hdr_Array[2] = {board.localID, board.tx_MRd_Tag_k, 1'b0, board.Tx_MRd_Addr[6:0]};
       board.Tx_MRd_Leng  = board.Tx_MRd_Leng - board.Rx_TLP_Length;
       board.Tx_MRd_Addr  = board.Tx_MRd_Addr + board.Rx_TLP_Length;
     
       Copy_rnd_data;
       TLP_Feed_Rx(`C_NO_BAR_HIT);
       board.CplD_Index   = board.CplD_Index + board.Rx_TLP_Length;
       
       board.Rx_TLP_Length    = 'H01;
     $display("%d ns:   Polling DMA status", $time);
       board.Hdr_Array[0] = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_RDREQ_ID, 3'H3, board.Rx_MRd_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_DS_STA;
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MRd_Tag      = board.Rx_MRd_Tag + 1;
       TSK_WAIT_FOR_READ_DATA;
       
       while (P_READ_DATA[0] != 'b1) begin
        $display("%d ns:   Polling DMA status", $time);
         board.Hdr_Array[0] = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
         board.Hdr_Array[1] = {`C_HOST_RDREQ_ID, 3'H3, board.Rx_MRd_Tag, 4'Hf, 4'Hf};
         board.Hdr_Array[2] = `C_ADDR_DMA_DS_STA;
     
         TLP_Feed_Rx(`C_BAR0_HIT);
         board.Rx_MRd_Tag       = board.Rx_MRd_Tag + 1;
         
         TSK_WAIT_FOR_READ_DATA;
       end
       
       
       $display("\n%d ns: >DMA Read", $time);
       board.DMA_us_is_Last   = 'B0;

       board.Rx_TLP_Length    = 'H01;

       board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_US_PAH;
       dword_pack_data_store(0, 0);
       //  Write PA_H
       $display("%d ns:   Write PA_H", $time);
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write PA_L
       $display("%d ns:   Write PA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_PA[31:00], 0);       //'H0300
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write HA_H
       $display("%d ns:   Write HA_H", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_HA[63:32], 0);       // 0
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;
      
       //  Write HA_L
       $display("%d ns:   Write HA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_HA[31:00], 0);     // 'H4000
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write BDA_H
       $display("%d ns:   Write BDA_H", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_BDA[63:32], 0);      // 0
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write BDA_L
       $display("%d ns:   Write BDA_L", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_BDA[31:00] + 'h10000, 0);
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write LENG
       $display("%d ns:   Write LENG", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store(board.DMA_L1, 0);            //'H100
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       //  Write CTRL and start the DMA
       $display("%d ns:   Write CTRL and start the DMA", $time);
       board.Hdr_Array[2] = board.Hdr_Array[2] + 'H4;
       dword_pack_data_store({4'H0
                            ,3'H1, board.DMA_us_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, board.DMA_bar
                            ,1'B1
                            ,15'H0
                            }, 0);
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

      board.Desc_tx_MRd_TAG = 'hE0;
      board.RP.com_usrapp.TSK_EXPECT_MEMRD(3'b000, 1'b0, 1'b0, 2'b00,
					'h8,
					board.localID,
					board.Desc_tx_MRd_TAG,
					4'hf,
					4'hf,
					board.DMA_BDA[31:2] + 'h4000,
          expect_status);
       if (expect_status == 0) begin
         $display("[%t]: got unexpected TLP !!!", $realtime);
         $finish(1);
       end
       
       
       // feeding the descriptor CplD
       $display("%d ns:   feeding the descriptor CplD", $time);
       board.DMA_us_is_Last   = 'B1;
       // Second DMA descriptor
       dword_pack_data_store(0, 0);
       dword_pack_data_store(board.DMA_PA[31:00] + 'H500, 1);
       dword_pack_data_store(board.DMA_HA[63:32], 2);          // 0
       dword_pack_data_store(board.DMA_HA[31:00] + 'H500, 3);
       dword_pack_data_store(-1, 4);                     // dont-car
       dword_pack_data_store(-1, 5);                     // dont-car
       dword_pack_data_store(board.DMA_L2, 6);
       dword_pack_data_store({4'H0
                            ,3'H1, board.DMA_us_is_Last
                            ,3'H0, 1'B1
                            ,1'B0, board.DMA_bar
                            ,1'B1
                            ,15'H0
                            }, 7);

       board.Rx_TLP_Length    = 'H08;

       board.Hdr_Array[0] = `HEADER0_CPLD | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_CPLD_ID, 4'H0, board.Rx_TLP_Length[9:0], 2'b00};
       board.Hdr_Array[2] = {board.localID, board.Desc_tx_MRd_TAG, 1'b0, board.DMA_BDA[6:0]};
     
       TLP_Feed_Rx(`C_NO_BAR_HIT);


       board.Rx_TLP_Length    = 'H01;
     $display("%d ns:   Polling DMA status", $time);
       board.Hdr_Array[0] = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_RDREQ_ID, 3'H3, board.Rx_MRd_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_US_STA;
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MRd_Tag      = board.Rx_MRd_Tag + 1;
       TSK_WAIT_FOR_READ_DATA;
       
       while (P_READ_DATA[0] != 'b1) begin
        $display("%d ns:   Polling DMA status", $time);
         board.Hdr_Array[0] = `HEADER0_MRD3_ | board.Rx_TLP_Length[9:0];
         board.Hdr_Array[1] = {`C_HOST_RDREQ_ID, 3'H3, board.Rx_MRd_Tag, 4'Hf, 4'Hf};
         board.Hdr_Array[2] = `C_ADDR_DMA_US_STA;
         TLP_Feed_Rx(`C_BAR0_HIT);
         board.Rx_MRd_Tag       = board.Rx_MRd_Tag + 1;
         
         TSK_WAIT_FOR_READ_DATA;
       end
  
  //////////////////////////////////////////////////////////////////////////////////

       board.Rx_TLP_Length    = 'H01;
         // reset downstream DMA channel
     $display("%d ns:   reset DS DMA channel", $time);
       board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_DS_CTRL;
       dword_pack_data_store(`C_DMA_RST_CMD, 0);
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

       board.Rx_TLP_Length    = 'H01;
         // reset upstream DMA channel
     $display("%d ns:   reset US DMA channel", $time);
       board.Hdr_Array[0] = `HEADER0_MWR3_ | board.Rx_TLP_Length[9:0];
       board.Hdr_Array[1] = {`C_HOST_WRREQ_ID, board.Rx_MWr_Tag, 4'Hf, 4'Hf};
       board.Hdr_Array[2] = `C_ADDR_DMA_US_CTRL;
       dword_pack_data_store(`C_DMA_RST_CMD, 0);
     
       TLP_Feed_Rx(`C_BAR0_HIT);
       board.Rx_MWr_Tag   = board.Rx_MWr_Tag + 1;

  //////////////////////////////////////////////////////////////////////////////////


      TSK_TX_CLK_EAT(100);
      $display("### Simulation FINISHED ###\n");
      $finish(2);

end

