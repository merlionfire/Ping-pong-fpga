`default_nettype none

module ping_pong_top ( 
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,

   // --- User control signals 
   input wire         up_en,
   input wire         down_en,
   output wire        frame_start,   
   // ---- VGA interface 
   output reg         vga_hsync,
   output reg         vga_vsync,
   output reg [2:0]   vga_rgb,
   output wire [ 10:0 ] pixel_x,
   output wire [ 10:0 ] pixel_y
);      

`include "vga_color_def.vh" 

   parameter BACK_COLOR    =  BLACK ; 
   parameter INIT_BALL_NUM =  4'h3 ;    

   parameter IDLE =  2'b00, 
             PLAY =  2'b01,
             OVER =  2'b10; 

   wire  h_sync_r, v_sync_r, vga_on_r, ref_tick ; 
   wire  update_allow_frist_pluse,  update_allow_first_pluse_16dly;   
   wire  object_on, text_bit_on ;
//   wire [ 10:0 ] pixel_x;
//   wire [ 10:0 ] pixel_y;
   wire [ 10:0 ] wall_x_l;
   wire [ 10:0 ] wall_x_r;
   wire [ 10:0 ] wall_y_t;
   wire [ 10:0 ] wall_y_b;
   wire [ 10:0 ] bar_x_l;
   wire [ 10:0 ] bar_x_r;
   wire [ 10:0 ] bar_y_t;
   wire [ 10:0 ] bar_y_b;
   wire [ 10:0 ] ball_x_l;
   wire [ 10:0 ] ball_x_r;
   wire [ 10:0 ] ball_y_t;
   wire [ 10:0 ] ball_y_b;
   wire         hit, miss; 
   wire [ 2:0 ] object_color;
   wire [ 2:0 ] text_color;
   wire [ 2:0 ] text_strings_on ;   
   reg  [ 7:0 ] v_sync_end_shift_r, hsync_shift_reg, vsync_shift_reg ; 
   reg  [3:0]  dig0, dig1 ; 
   reg  [1:0]  ball_num ;  

   reg  [1:0]  state_r ; 
   reg  start_game, start_timer, win_play, win_init, win_over ;  
   reg  clk_64k_tick ,timer_out ; 
   reg [6:0] timer_cnt ; 
   wire   start_en,  soft_rst; 

   vga_sync_gen  vga_sync_gen_inst (
      .clk          ( clk          ), //i
      .rst          ( rst          ), //i
      .h_sync_r     ( h_sync_r     ), //o
      .v_sync_r     ( v_sync_r     ), //o
      .vga_on_r     ( vga_on_r     ), //o
      .ref_tick     ( ref_tick     ), //o
      .pixel_x_r    ( pixel_x      ), //o
      .pixel_y_r    ( pixel_y      )  //o
   );
   
   object_ctrl  object_ctrl_inst (
      .clk                            ( clk                            ), //i
      .rst                            ( rst                            ), //i
      .update_allow_frist_pluse       ( update_allow_frist_pluse       ), //i
      .update_allow_first_pluse_16dly ( update_allow_first_pluse_16dly ), //i
      .up_en                          ( up_en                          ), //i
      .down_en                        ( down_en                        ), //i
      .wall_x_l                       ( wall_x_l                       ), //o
      .wall_x_r                       ( wall_x_r                       ), //o
      .wall_y_t                       ( wall_y_t                       ), //o
      .wall_y_b                       ( wall_y_b                       ), //o
      .bar_x_l                        ( bar_x_l                        ), //o
      .bar_x_r                        ( bar_x_r                        ), //o
      .bar_y_t                        ( bar_y_t                        ), //o
      .bar_y_b                        ( bar_y_b                        ), //o
      .ball_x_l                       ( ball_x_l                       ), //o
      .ball_x_r                       ( ball_x_r                       ), //o
      .ball_y_t                       ( ball_y_t                       ), //o
      .ball_y_b                       ( ball_y_b                       ), //o
      .hit                            ( hit                            ), //o
      .miss                           ( miss                           )  //o
   );
         
   object  object_inst (
      .clk          ( clk          ), //i
      .rst          ( rst          ), //i
      .pixel_x      ( pixel_x      ), //i
      .pixel_y      ( pixel_y      ), //i
      .wall_x_l     ( wall_x_l     ), //i
      .wall_x_r     ( wall_x_r     ), //i
      .wall_y_t     ( wall_y_t     ), //i
      .wall_y_b     ( wall_y_b     ), //i
      .bar_x_l      ( bar_x_l      ), //i
      .bar_x_r      ( bar_x_r      ), //i
      .bar_y_t      ( bar_y_t      ), //i
      .bar_y_b      ( bar_y_b      ), //i
      .ball_x_l     ( ball_x_l     ), //i
      .ball_x_r     ( ball_x_r     ), //i
      .ball_y_t     ( ball_y_t     ), //i
      .ball_y_b     ( ball_y_b     ), //i
      .object_on    ( object_on    ), //o
      .object_color ( object_color )  //o
   );

   text  text_inst (
      .clk               ( clk             ), //i
      .rst               ( rst             ), //i
      .pixel_x           ( pixel_x         ), //i
      .pixel_y           ( pixel_y         ), //i
      .dig0              ( dig0            ), //i
      .dig1              ( dig1            ), //i
      .ball_num          ( ball_num        ), //i
      .text_strings_on   ( text_strings_on ), //i         
      .text_bit_on       ( text_bit_on     ), //o
      .text_color        ( text_color      )  //o
   );
   
   
   assign update_allow_frist_pluse       =  ref_tick;  
   assign update_allow_first_pluse_16dly =  v_sync_end_shift_r[7];     
   
   always @( posedge clk ) begin  
      v_sync_end_shift_r <= { v_sync_end_shift_r[6:0], ref_tick } ;      
   end    
   
   always @( posedge clk ) begin  
      
      vga_rgb   <= BACK_COLOR ; 

      if ( win_init ) begin 
         if ( text_strings_on[ TEXT_LOGO_BIT ] & text_bit_on ) begin 
            vga_rgb   <= text_color ; 
         end 
      end    

      if ( win_play ) begin 
         if ( object_on ) begin 
            vga_rgb   <= object_color ; 
         end else if (  text_strings_on[ TEXT_SCORE_BIT ] & text_bit_on ) begin  
            vga_rgb   <= text_color ; 
         end    
      end 

      if ( win_over ) begin 
         if ( ( text_strings_on[ TEXT_SCORE_BIT ] | text_strings_on[ TEXT_OVER_BIT ] ) & text_bit_on ) begin 
            vga_rgb   <= text_color ; 
         end   
      end
   end      


   // Delay 5 cycle to sync with VGA show 
   always @( posedge clk ) begin  
      hsync_shift_reg <= { hsync_shift_reg[6:0],  h_sync_r } ; 
      vsync_shift_reg <= { vsync_shift_reg[6:0],  v_sync_r } ; 
      vga_hsync       <= ~ hsync_shift_reg[4] ; 
      vga_vsync       <= ~ vsync_shift_reg[4] ; 
   end 




   //**********************************************************************//
   //  Game top level controller   
   //  -- 
   //**********************************************************************//
   assign   start_en  = up_en | down_en ; 
   assign   soft_rst  = start_game  | rst ;   

   always @( posedge clk ) begin  
      if ( rst ) begin 
         state_r   <= IDLE; 
         start_game <= 1'b0 ;  
         start_timer <= 1'b0 ; 
         win_play   <= 1'b0 ; 
         win_init   <= 1'b0 ; 
         win_over   <= 1'b0 ; 
      end else begin 
         start_game <= 1'b0 ;  
         start_timer <= 1'b0 ; 
         win_play   <= 1'b0 ; 
         win_init   <= 1'b0 ; 
         win_over   <= 1'b0 ; 
         case ( state_r ) 
            IDLE : begin 
               win_init    <= 1'b1 ; 
               if ( start_en ) begin   
                  state_r  <= PLAY ; 
                  start_game  <= 1'b1 ; 
               end
            end 
            PLAY : begin 
               win_play     <= 1'b1 ; 
               if ( ball_num  == 2'b00 ) begin 
                  state_r  <= OVER ; 
                  start_timer <= 1'b1 ; 
               end    
            end
            OVER  : begin 
               win_over    <= 1'b1 ; 
               if ( timer_out ) begin 
                  state_r  <= IDLE ; 
               end    
            end 
         endcase 
      end
   end


   //**********************************************************************//
   //  Timer    
   //  -- 
   //**********************************************************************//

   assign   frame_start =  clk_64k_tick ; 
   always @( posedge clk ) begin  
      if ( ( pixel_x == 0 ) && ( pixel_y == 0 ) ) begin 
         clk_64k_tick  <=  1'b1 ; 
      end else begin  
         clk_64k_tick  <=  1'b0 ; 
      end 
   end

   always @( posedge clk ) begin  
      if ( start_timer ) begin 
            timer_cnt   <=  7'h7F ; 
      end else if ( win_over & clk_64k_tick ) begin 
            timer_cnt   <=  timer_cnt - 1'b1 ; 
      end 
   end

   always @( posedge clk ) begin  
      if ( win_init ) begin   
         timer_out <= 1'b0;
      end else if ( timer_cnt == 7'h01  ) begin 
         timer_out <= 1'b1; 
      end else begin 
         timer_out <= 1'b0;
      end
   end


   always @( posedge clk ) begin  
      if ( soft_rst ) begin 
         dig0     <= 4'h0; 
         dig1     <= 4'h0; 
         ball_num <= INIT_BALL_NUM ; 
      end else if ( update_allow_frist_pluse ) begin        
         if ( hit ) begin 
            if ( dig0 == 4'h9 ) begin 
              dig0   <= 4'h0 ; 
              dig1   <= dig1  + 1'b1; 
            end else begin    
               dig0  <= dig0 + 1'b1; 
            end    
         end 
         
         if ( miss ) begin 
            ball_num <= ball_num - 1'b1 ; 
         end
      end 
   end   

`ifdef SVA
   /*assert property ( @( posedge clk ) 
      $rose( vga_hsync ) |-> object_on 
   );     
   */
`endif

endmodule
   
   
   

