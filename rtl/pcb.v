`define  RST   1'b0 
`define  UART  1'b1 

module pcb  ( 
    input         CLK_50M,
    input         BTN_SOUTH , 
    input         BTN_WEST , 
    input         BTN_NORTH , 
    inout         PS2_CLK1,
    inout         PS2_DATA1,
    inout         PS2_CLK2,
    inout         PS2_DATA2,
    input [3:0]   SW,
`ifdef UART     
    input         RS232_DCE_RXD,
    output        RS232_DCE_TXD, 
`endif    
    output [3:0]  VGA_B,
    output [3:0]  VGA_G,
    output [3:0]  VGA_R,
    output        VGA_HSYNC,
    output        VGA_VSYNC
);

   wire clk_25m, clk_50m_i, clk_50m_o, clk_75m,  dcm_locked ; 

   wire  ping_pong_clk,  ping_pong_rst, frame_start, btn_up_en, btn_down_en, key_up_en, key_down_en,  vga_h_sync,  vga_v_sync;
   wire [2:0] vga_rgb;

   wire  pcb_clk ; 
   wire  btn_south_io, btn_south_io_filter;
   wire  btn_west_io , btn_west_io_filter ;
   wire  btn_north_io, btn_north_io_filter;
   wire  sw_0_filter ; 

   wire keyboard_clk, keyboard_rst;    
   wire ps2_clk, ps2_data;          
   wire ps2_rx_en ;  
   wire      ps2_rddata_valid;
   wire [7:0] ps2_rd_data; 

`ifdef UART   
   wire  uart_clk, uart_rst, uart_rx,  uart_tx ; 
   wire  uart_tx_full, uart_tx_half_full,  uart_wr_en, uart_rd_en,  uart_rddata_valid, uart_rx_full, uart_rx_half_full ; 
   wire  [7:0] uart_wr_data,  uart_rd_data;
`endif    

   reg  up_en,  down_en ; 

   clock_gen clock_gen_inst (
       .CLKIN_IN        (  CLK_50M    ), 
       .CLKDV_OUT       (  clk_25m    ), 
       .CLKFX_OUT       (  clk_75m    ), 
       .CLKIN_IBUFG_OUT (  clk_50m_i  ), 
       .CLK0_OUT        (  clk_50m_o  ), 
       .LOCKED_OUT      (  dcm_locked )
    );
	 
   btn_filter  #(.PIN_NUM (4 ) ) top_btn_filter_inst (
     .clk     ( pcb_clk   ),
     .pin_in  ( { btn_south_io, btn_west_io, btn_north_io, SW[0]  } ),
     .pin_out ( { btn_south_io_filter, btn_west_io_filter, btn_north_io_filter, sw_0_filter  } ) 
   );

   (* keep_hierarchy ="yes" *)  keyboard  keyboard_inst (
      .clk           ( keyboard_clk  ), //i
      .rst           ( keyboard_rst  ), //i
      .ps2_clk       ( PS2_CLK1      ), //i
      .ps2_data      ( PS2_DATA1     ), //i
      .ps2_rx_en     ( ps2_rx_en     ), //i
      .ps2_rddata_valid ( ps2_rddata_valid ), // o 
      .ps2_rd_data   ( ps2_rd_data   ), //o
      .key_up_en     ( key_up_en     ), //o
      .key_down_en   ( key_down_en   )  //o
   );

   // for 25mhz, 2**12 = 163 us 
   //defparam keyboard_inst.ps2_host_rxtx_inst.ps2_host_tx_inst.NUM_OF_BITS_FOR_100US = 12 ;  
   defparam keyboard_inst.ps2_host_rxtx_inst.ps2_host_tx_inst.NUM_OF_BITS_FOR_100US = 13 ;  


   wire [ 9:0 ] pixel_x , pixel_y ; 

   ping_pong_top  ping_pong_top_inst (
      .clk       ( ping_pong_clk  ), //i
      .rst       ( ping_pong_rst  ), //i
      .up_en     ( up_en     ), //i
      .down_en   ( down_en   ), //i
      .vga_hsync ( vga_h_sync ), //o
      .frame_start   ( frame_start ), //o 
      .vga_vsync ( vga_v_sync ), //o
      .vga_rgb   ( vga_rgb   ),  //o
      .pixel_x   ( pixel_x   ), 
      .pixel_y   ( pixel_y   )
   );

`ifdef UART 
   uart  uart_inst (
      .clk           ( uart_clk          ), //i
      .rst           ( uart_rst          ), //i
      .rx            ( uart_rx           ), //i 
      .tx            ( uart_tx           ), //o
      .wr_en         ( uart_wr_en        ), //i
      .wr_data       ( uart_wr_data      ), //i
      .tx_full       ( uart_tx_full      ), //o
      .tx_half_full  ( uart_tx_half_full ), //o
      .rd_data_valid ( uart_rddata_valid ), //o
      .rd_data       ( uart_rd_data      ), //o
      .rd_en         ( uart_rd_en        ), //i
      .rx_full       ( uart_rx_full      ), //o
      .rx_half_full  ( uart_rx_half_full )  //o
   );

   defparam uart_inst.N_CLK_DIV_BAUD = 81 ; 

`endif // UART 



   //assign   ping_pong_clk = clk_25m ;  
   //assign   ping_pong_clk = clk_50m_o ;  
   assign   ping_pong_clk = clk_75m ;  


   // Button singals connection 
   //assign   pcb_clk       = clk_25m ; 
   //assign   pcb_clk       = clk_50m_o ; 
   assign   pcb_clk       = clk_75m  ; 
   assign   btn_south_io  = BTN_SOUTH ;  
   assign   btn_west_io   = BTN_WEST  ;  
   assign   btn_north_io  = BTN_NORTH ;  
   assign   btn_up_en     = btn_south_io_filter; 
   assign   btn_down_en   = btn_west_io_filter ;  
   assign   ping_pong_rst = btn_north_io_filter ;    

   // Keyboard signals connection 
   //assign   keyboard_clk =  clk_25m ; 
   //assign   keyboard_clk =  clk_50m_o ; 
   assign   keyboard_clk =  clk_75m ; 
   assign   keyboard_rst =  btn_north_io_filter ;    
   assign   ps2_clk       = PS2_CLK1 ; 
   assign   ps2_data      = PS2_DATA1 ; 
   assign   ps2_rx_en     = sw_0_filter  ;   

   // VGA singals connection 
   assign   VGA_HSYNC     = vga_h_sync ; 
   assign   VGA_VSYNC     = vga_v_sync ; 
   assign   VGA_B         = { 4{vga_rgb[0]} } ; 
   assign   VGA_G         = { 4{vga_rgb[1]} } ; 
   assign   VGA_R         = { 4{vga_rgb[2]} } ; 

`ifdef UART   
   assign   uart_clk      = clk_25m ; 
   assign   uart_rx       = RS232_DCE_RXD ;
   assign   RS232_DCE_TXD = uart_tx ;

   assign   uart_wr_en    = ps2_rddata_valid ; 
   assign   uart_wr_data  = ps2_rd_data ;  

`endif 

   always @( posedge ping_pong_clk ) begin  
      if ( ping_pong_rst ) begin  
          up_en   <= 1'b0 ;   
      end else if ( btn_up_en | key_up_en ) begin 
          up_en <=   1'b1 ; 
      end else if ( frame_start ) begin 
          up_en <=   1'b0 ; 
      end
   end

   always @( posedge ping_pong_clk ) begin  
      if ( ping_pong_rst ) begin  
          down_en   <= 1'b0 ;   
      end else if ( btn_down_en | key_down_en ) begin 
          down_en <=   1'b1 ; 
      end else if ( frame_start ) begin 
          down_en <=   1'b0 ; 
      end
   end

 endmodule 
