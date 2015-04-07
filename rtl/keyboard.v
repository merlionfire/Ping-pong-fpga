`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Merlionfire
// 
// Create Date:    06:53:21 02/01/2015 
// Design Name: 
// Module Name:    keyboard_decoder 
// Project Name:   ping-pong-fpga  
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module keyboard(
   // Clock and reset    
   input wire       clk,
   input wire       rst,
   // PS/2 interface 
   inout wire       ps2_clk,
   inout wire       ps2_data,
   input wire       ps2_rx_en, 
   // 
   output wire       ps2_rddata_valid,
   output wire [7:0] ps2_rd_data, 
   // Ping-pong interface
   output reg       key_up_en,   
   output reg       key_down_en 
 );


   parameter KEY_W  =   8'h1D ; 
   parameter KEY_S  =   8'h1B ; 
   parameter KEY_BREAK  =   8'hF0 ; 

   localparam 
      RX_IDLE  =  2'b00,
      RX_WAIT_BREAK  =  2'b01,
      RX_WAIT_LAST   =  2'b11;

   parameter IDLE = 3'b000 ,
             WAIT_FOR_COMPLETE   =  3'b001,
             WAIT_FOR_ACK        =  3'b010,
             WAIT_FOR_CHAR_1     =  3'b011,
             WAIT_FOR_CHAR_2     =  3'b100,
             WAIT_FOR_CHAR_3     =  3'b101,
             DONE = 3'b110 ; 

   wire  ps2_tx_done,  ps2_tx_ready,  ps2_rx_ready; 
   reg [7:0] ps2_wr_data ;
   reg       ps2_wr_stb; 

   reg   [1:0] rx_state_r ; 
   reg   key_up_tick, key_down_tick, key_break_tick, key_other_tick ; 
   
   reg   [2:0] state_r;    
   //reg [2:0]   state_r ; 
   (* keep = "yes" *) reg [7:0]   char_xy ; 
   (* keep = "yes" *) reg         done_tick ; 

   // synthesis attribute keep of state_r is "true"    

   ps2_host_rxtx  ps2_host_rxtx_inst (
      .clk               ( clk               ), //i
      .rst               ( rst               ), //i
      .ps2_clk           ( ps2_clk           ), //i
      .ps2_data          ( ps2_data          ), //i
      .ps2_wr_stb        ( ps2_wr_stb        ), //i
      .ps2_wr_data       ( ps2_wr_data       ), //i
      .ps2_tx_done       ( ps2_tx_done       ), //o
      .ps2_tx_ready      ( ps2_tx_ready      ), //o
      .ps2_rddata_valid  ( ps2_rddata_valid  ), //o
      .ps2_rd_data       ( ps2_rd_data       ), //o
      .ps2_rx_ready      ( ps2_rx_ready      )  //o
   );


   always @( posedge clk ) begin  
      key_up_tick    <= 1'b0;   
      key_down_tick  <= 1'b0; 
      key_break_tick <= 1'b0; 
      key_other_tick <= 1'b0 ; 
      if ( ps2_rddata_valid ) begin 
         case ( ps2_rd_data ) 
            KEY_W  :  key_up_tick   <= 1'b1 ; 
            KEY_S  :  key_down_tick <= 1'b1 ; 
            KEY_BREAK  :  key_break_tick <= 1'b1 ; 
            default : key_other_tick   <= 1'b1 ; 
         endcase 
      end  
   end



   always @( posedge clk ) begin  
      if ( rst ) begin 
         rx_state_r  <= RX_IDLE ;  
         key_up_en   <= 1'b0 ;
         key_down_en <= 1'b0 ;
      end else begin 
         case ( rx_state_r ) 
           RX_IDLE : begin 
               if ( key_up_tick ) begin 
                  key_up_en   <= 1'b1 ;
                  rx_state_r  <= RX_WAIT_BREAK;  
               end 

               if ( key_down_tick ) begin  
                  key_down_en <= 1'b1 ; 
                  rx_state_r  <= RX_WAIT_BREAK;  
               end 
           end
           RX_WAIT_BREAK : begin 
               if ( key_break_tick ) begin 
                  rx_state_r  <= RX_WAIT_LAST;  
               end
           end
           RX_WAIT_LAST : begin 
               if ( key_other_tick ) begin 
                  rx_state_r  <= RX_WAIT_BREAK ;  
               end

               if ( key_up_en & key_up_tick ) begin  
                  key_up_en   <= 1'b0 ;
                  rx_state_r  <= RX_IDLE ;  
               end 
               
               if ( key_down_en & key_down_tick ) begin  
                  key_down_en   <= 1'b0 ;
                  rx_state_r  <= RX_IDLE ;  
               end 
            end
            default  : begin 
               rx_state_r  <= RX_IDLE ;  
               key_up_en   <= 1'b0 ;
               key_down_en <= 1'b0 ;
            end
         endcase
      end
   end




   always @( posedge clk ) begin  
      if ( rst ) begin 
         state_r  <= IDLE ; 
         ps2_wr_stb  <= 1'b0 ; 
         ps2_wr_data <= 8'h00 ; 
         done_tick   <= 1'b0;  
      end else begin    
         ps2_wr_stb  <= 1'b0 ; 
         done_tick   <= 1'b0;  
         case ( state_r ) 
            IDLE : begin 
               if ( ps2_rx_en ) begin 
                  ps2_wr_stb  <= 1'b1 ; 
                  ps2_wr_data <= 8'hF4 ; 
                  state_r     <= WAIT_FOR_COMPLETE ; 
               end
            end
            WAIT_FOR_COMPLETE : begin 
               if ( ps2_tx_done ) begin 
                  state_r  <= WAIT_FOR_ACK ; 
               end
            end
            WAIT_FOR_ACK : begin 
               if ( ps2_rddata_valid ) begin 
                  state_r  <= WAIT_FOR_CHAR_1 ; 
               end
            end   
            WAIT_FOR_CHAR_1 : begin 
               if ( ps2_rddata_valid ) begin 
                  state_r  <= WAIT_FOR_CHAR_2 ; 
                  char_xy  <= ps2_rd_data ; 
               end
            end   
            WAIT_FOR_CHAR_2 : begin 
               if ( ps2_rddata_valid ) begin 
                  state_r  <= WAIT_FOR_CHAR_3 ; 
                  char_xy  <= ps2_rd_data ; 
               end
            end   
            WAIT_FOR_CHAR_3 : begin 
               if ( ps2_rddata_valid ) begin 
                  state_r  <= DONE ; 
                  char_xy  <= ps2_rd_data ; 
               end
            end   
            DONE : begin  
               done_tick <= 1'b1 ; 
               state_r   <=  WAIT_FOR_CHAR_1 ; 
            end   
         endcase 
      end
   end


endmodule
