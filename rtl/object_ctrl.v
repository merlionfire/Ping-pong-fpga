module object_ctrl
(
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,

   // --- VGA synchronizer 
   input  wire        update_allow_frist_pluse, 
   input  wire        update_allow_first_pluse_16dly, 
    
   // --- outside control signals 
   input  wire        up_en, 
   input  wire        down_en, 
   
   // --- wall singals
   output wire [10:0]  wall_x_l,
   output wire [10:0]  wall_x_r,
   output wire [10:0]  wall_y_t,
   output wire [10:0]  wall_y_b,

   // --- bar singals
   output wire [10:0]  bar_x_l,
   output wire [10:0]  bar_x_r,
   output wire [10:0]  bar_y_t,
   output wire [10:0]  bar_y_b,

   // --- ball  singals
   output wire [10:0]  ball_x_l,
   output wire [10:0]  ball_x_r,
   output wire [10:0]  ball_y_t,
   output wire [10:0]  ball_y_b,
    
   // --- ball status  
   output wire        hit,
   output wire        miss

); 


   // Global properties
   parameter MAX_Y   =  480;
   parameter MAX_X   =  640;  

   // Wall properties
   parameter WALL_X_L = 32;
   parameter WALL_X_R = 35;
   parameter WALL_Y_T = 0;
   parameter WALL_Y_B = 479; 

   // Bar properties 
   parameter BAR_X_L = 600; 
   parameter BAR_X_R = 604; 
   parameter BAR_Y_V = 3 ; // bar moving velocity 
   parameter BAR_Y_SIZE = 72; 

   // Ball properties 
   parameter BALL_X_V = 2 ; // ball X-moving velocity 
   parameter BALL_Y_V = 2 ; // ball Y-moving velocity 
   parameter BALL_SIZE = 8; 

   reg [10:0]  bar_y_b_reg, bar_y_t_r, bar_y_b_r;   

   reg [10:0]  ball_y_offset, ball_x_offset; 
   reg [10:0]  ball_y_b_reg, ball_y_t_r, ball_y_b_r;   
   reg [10:0]  ball_x_r_reg, ball_x_l_r, ball_x_r_r;   

   reg        v_hit_r, h_hit_r, hit_r, miss_r ; 

   //**********************************************************************//
   //  Wall boundry  
   //    -- position is fixed
   //**********************************************************************//
   assign wall_x_l = WALL_X_L;
   assign wall_x_r = WALL_X_R;
   assign wall_y_t = WALL_Y_T;
   assign wall_y_b = WALL_Y_B;

   
   //**********************************************************************//
   //  Bar boundry  
   //    -- x is fixed
   //    -- y can move up/down
   //**********************************************************************//
   assign bar_x_l = BAR_X_L;
   assign bar_x_r = BAR_X_R;
   assign bar_y_t = bar_y_t_r; 
   assign bar_y_b = bar_y_b_r; 

   always @( posedge clk ) begin 
      if ( rst ) begin 
         bar_y_b_reg <= BAR_Y_SIZE - 1'b1 ;   
      end else if ( update_allow_frist_pluse ) begin 
         if ( up_en ) begin
            if ( bar_y_b_reg > ( BAR_Y_SIZE + BAR_Y_V -1 ) ) begin 
               bar_y_b_reg  <= bar_y_b_reg - BAR_Y_V ; 
            end else begin
               bar_y_b_reg  <= BAR_Y_SIZE - 1 ; 
            end
         end else if ( down_en ) begin
            if ( bar_y_b_reg  < ( MAX_Y - BAR_Y_V ) ) begin 
               bar_y_b_reg  <= bar_y_b_reg + BAR_Y_V ; 
            end else begin 
               bar_y_b_reg  <= MAX_Y - 1 ; 
            end
         end 
      end
   end   

   always @( posedge clk ) begin 
      if (  update_allow_first_pluse_16dly ) begin  
         bar_y_t_r  <= bar_y_b_reg - BAR_Y_SIZE + 1'b1 ; 
         bar_y_b_r  <= bar_y_b_reg ; 
      end   
   end 

   //**********************************************************************//
   //  Ball boundry  
   //    -- x can move let/right 
   //    -- y can move up/down
   //**********************************************************************//

         
   assign ball_x_l = ball_x_l_r;
   assign ball_x_r = ball_x_r_r;
   assign ball_y_t = ball_y_t_r; 
   assign ball_y_b = ball_y_b_r; 

   // pipeline to update y positions
   // stage 1 : update moving offset 
   always @( posedge clk ) begin 
      if ( rst ) begin 
         ball_y_offset <= -BALL_Y_V ;                  // Defaul move is up    
         v_hit_r       <= 1'b0;  
      end else begin 
         v_hit_r         <= 1'b0;  
         if ( ball_y_b_reg <  BALL_SIZE ) begin     // Touch top
            ball_y_offset <= BALL_Y_V ;                   // Move down 
         end else if ( ball_y_b_reg >= ( MAX_Y - 1 ) ) begin     // Touch bottom 
            ball_y_offset <= -BALL_Y_V ;                  // Move up
         end else if (  ( ball_x_l_r  >= ( bar_x_l - 5 ) ) && ( ball_x_r_r <= ( bar_x_r + 5 ) ) )  begin 
            if ( ( ball_y_b_r >= bar_y_t_r ) && ( ball_y_b_r <= bar_y_t_r + BALL_SIZE ) ) begin 
               ball_y_offset <= -BALL_Y_V ;                  // Defaul move is up    
               v_hit_r       <= 1'b1;  
            end else if ( ( ball_y_t_r <= bar_y_b_r ) && ( ball_y_t_r >=  bar_y_b_r - BALL_SIZE ) ) begin 
               ball_y_offset <= BALL_Y_V ;                   // Move down 
               v_hit_r       <= 1'b1;  
            end  
         end   
      end    
   end 

   // stage 2 : update postion register with offset 
   always @( posedge clk ) begin 
      if ( rst ) begin 
         ball_y_b_reg <= MAX_Y/2  ;  
      end else if ( update_allow_frist_pluse ) begin 
         ball_y_b_reg <= ball_y_b_reg + ball_y_offset ;  
      end
   end   

   // stage 3 : update 2 postion registers 
   always @( posedge clk ) begin 
      if (  update_allow_first_pluse_16dly ) begin  
         ball_y_t_r  <= ball_y_b_reg - BALL_SIZE + 1'b1 ; 
         ball_y_b_r  <= ball_y_b_reg ; 
      end   
   end 

   // pipeline to update x positions
   // stage 1 : update moving offset 
   always @( posedge clk ) begin 
      if ( rst ) begin 
         ball_x_offset <= -BALL_X_V ;                  // Defaul move is left    
         h_hit_r       <= 1'b0 ;   
         miss_r        <= 1'b0 ; 
      end else begin 
         h_hit_r       <= 1'b0 ;   
         miss_r        <= 1'b0 ; 
         if ( ball_x_r_reg <  BALL_SIZE ) begin     // Touch left
            ball_x_offset <= BALL_X_V ;                   // Move right 
         end else if ( ball_x_r_reg > ( MAX_X - 1 ) ) begin     // Touch right 
            ball_x_offset <= -BALL_X_V ;                  // Move left
            miss_r        <= 1'b1 ; 
         end else if (  ( ( ball_y_b_r -3 )  >= bar_y_t_r ) && ( ( ball_y_t_r + 3 ) <= bar_y_b_r ) )  begin 
            if ( ( ball_x_l_r <= ( bar_x_r + 1 ) ) && ( ball_x_l_r >=  ( bar_x_r - 1 ) ) ) begin 
               ball_x_offset <= BALL_X_V ;                   // Move right 
               h_hit_r       <= 1'b1 ;   
            end else if ( ( ball_x_r_r <= ( bar_x_l + 1 ) ) && ( ball_x_r_r >=  ( bar_x_l - 1 ) ) ) begin 
               ball_x_offset <= -BALL_X_V ;                  // Move left
               h_hit_r       <= 1'b1 ;   
            end   
         end    
      end
   end 

   // stage 2 : update postion register with offset 
   always @( posedge clk ) begin 
      if ( rst ) begin 
         ball_x_r_reg <= MAX_X  ;  
      end else if ( update_allow_frist_pluse ) begin 
         ball_x_r_reg <= ball_x_r_reg + ball_x_offset ;  
      end
   end   

   // stage 3 : update 2 postion registers 
   always @( posedge clk ) begin 
      if ( update_allow_first_pluse_16dly ) begin  
         ball_x_l_r  <= ball_x_r_reg - BALL_SIZE + 1'b1 ; 
         ball_x_r_r  <= ball_x_r_reg ; 
      end   
   end 


   always @( posedge clk ) begin  
      if ( v_hit_r | h_hit_r ) begin 
         hit_r   <= 1'b1 ; 
      end else begin 
         hit_r   <= 1'b0 ; 
      end
   end

   assign   hit   =  hit_r ; 
   assign   miss  =  miss_r;

endmodule 
