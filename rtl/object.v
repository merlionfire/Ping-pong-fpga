
module object (
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,

   // --- sync singals 
   input  wire [9:0]  pixel_x,
   input  wire [9:0]  pixel_y,

   // --- wall onject interface 
   input  wire [9:0]  wall_x_l,
   input  wire [9:0]  wall_x_r,
   input  wire [9:0]  wall_y_t,
   input  wire [9:0]  wall_y_b,

   // --- bar onject interface 
   input  wire [9:0]  bar_x_l,
   input  wire [9:0]  bar_x_r,
   input  wire [9:0]  bar_y_t,
   input  wire [9:0]  bar_y_b,
    
   // --- ball onject interface 
   input  wire [9:0]  ball_x_l,
   input  wire [9:0]  ball_x_r,
   input  wire [9:0]  ball_y_t,
   input  wire [9:0]  ball_y_b,
    
   // --- ball onject interface 
   output reg         object_on,
   output reg [2:0]   object_color      
);   

`include "vga_color_def.vh" 

   // Global properties
   parameter MAX_Y   =  480;
   parameter MAX_X   =  640;  

   reg  [9:0]   pixel_x_r, pixel_y_r;
   reg  [9:0]   pixel_x_wall, pixel_y_wall;
   reg  [9:0]   pixel_x_bar, pixel_y_bar;
   reg  [9:0]   pixel_x_ball, pixel_y_ball;
   reg  [9:0]   pixel_x_line, pixel_y_line;
   
   reg  wall_x_on_l, wall_x_on_r, wall_y_on_t, wall_y_on_b,  wall_on_r ; 
   reg  bar_x_on_l, bar_x_on_r, bar_y_on_t, bar_y_on_b,  bar_on_r ; 
   reg  ball_x_on_l, ball_x_on_r, ball_y_on_t, ball_y_on_b,  ball_on_r ; 
   reg  line_x_on_l, line_x_on_r, line_y_on_t, line_y_on_b, line_on_r ;  

   reg  [2:0]  ball_x_pixel_offset ; 
   wire [2:0]  ball_y_pixel_offset; 
   reg  [7:0]  ball_y_pixel_on;
   wire        ball_pixel_on ; 

   wire [2:0]  wall_color, bar_color, ball_color, line_color, background_color  ; 

   always @ (posedge clk ) begin 
      pixel_x_r      <= pixel_x;
      pixel_y_r      <= pixel_y;
      pixel_x_wall   <= pixel_x_r ; 
      pixel_y_wall   <= pixel_y_r ; 
      pixel_x_bar    <= pixel_x_r ; 
      pixel_y_bar    <= pixel_y_r ; 
      pixel_x_ball   <= pixel_x_r ; 
      pixel_y_ball   <= pixel_y_r ; 
      pixel_x_line   <= pixel_x_r ; 
      pixel_y_line   <= pixel_y_r ;
   end
 
   assign   background_color  =  BLACK ; 
  

   //**********************************************************************//
   //  Line  generation
   //**********************************************************************//
   //**********************************************************************//
   assign line_color = WHITE;  

   always @( posedge clk ) begin  
      if ( pixel_x_line == 0 ) begin 
         line_x_on_l <= 1'b1 ; 
      end else begin 
         line_x_on_l <= 1'b0 ; 
      end

      if ( pixel_x_line == (MAX_X-1) ) begin 
         line_x_on_r <= 1'b1 ; 
      end else begin 
         line_x_on_r <= 1'b0 ; 
      end

      if ( pixel_y_line == 0 ) begin 
         line_y_on_t <= 1'b1 ; 
      end else begin 
         line_y_on_t <= 1'b0 ; 
      end

      if ( pixel_y_line == ( MAX_Y-1)  ) begin 
         line_y_on_b <= 1'b1 ; 
      end else begin 
         line_y_on_b <= 1'b0 ; 
      end
   end


   always @( posedge clk ) begin    
      if ( line_x_on_l | line_x_on_r | line_y_on_t | line_y_on_b ) begin  
         line_on_r   <= 1'b1 ; 
      end else begin 
         line_on_r   <= 1'b0 ; 
      end
   end
    
   //**********************************************************************//
   //  Wall generation
   //**********************************************************************//
   assign wall_color = BLUE;  

   always @( posedge clk ) begin  
      if ( wall_x_l  <= pixel_x_wall ) 
         wall_x_on_l <= 1'b1; 
      else    
         wall_x_on_l <= 1'b0; 
         
      if ( pixel_x_wall <= wall_x_r )    
         wall_x_on_r <= 1'b1; 
      else    
         wall_x_on_r <= 1'b0; 

      if ( wall_y_t  <= pixel_y_wall )     
         wall_y_on_t <= 1'b1; 
      else    
         wall_y_on_t <= 1'b0; 

      if ( pixel_y_wall <= wall_y_b )    
         wall_y_on_b <= 1'b1; 
      else    
         wall_y_on_b <= 1'b0; 
   end 

   always @ (posedge clk ) begin 
      if ( rst ) begin
         wall_on_r  <= 1'b0;
      end else if ( wall_x_on_l & wall_x_on_r & wall_y_on_t & wall_y_on_b ) begin 
         wall_on_r  <= 1'b1; 
      end else begin   
         wall_on_r  <= 1'b0; 
      end   
   end 


   //**********************************************************************//
   //  Bar generation 
   //**********************************************************************//
   assign bar_color = GREEN;  
    
   always @( posedge clk ) begin  
      if ( bar_x_l  <= pixel_x_bar ) 
         bar_x_on_l <= 1'b1; 
      else    
         bar_x_on_l <= 1'b0; 
         
      if ( pixel_x_bar <= bar_x_r )    
         bar_x_on_r <= 1'b1; 
      else    
         bar_x_on_r <= 1'b0; 

      if ( bar_y_t  <= pixel_y_bar )     
         bar_y_on_t <= 1'b1; 
      else    
         bar_y_on_t <= 1'b0; 

      if ( pixel_y_bar <= bar_y_b )    
         bar_y_on_b <= 1'b1; 
      else    
         bar_y_on_b <= 1'b0; 
   end 

   always @ (posedge clk ) begin 
      if ( rst ) begin
         bar_on_r  <= 1'b0;
      end else if ( bar_x_on_l  & bar_x_on_r & bar_y_on_t & bar_y_on_b ) begin 
         bar_on_r  <= 1'b1; 
      end else begin   
         bar_on_r  <= 1'b0; 
      end   
   end 

   //**********************************************************************//
   //  Ball generation 
   //**********************************************************************//

   assign ball_color = YELLOW;  

   always @( posedge clk ) begin  
      if ( ball_x_l  <= pixel_x_ball ) 
         ball_x_on_l <= 1'b1; 
      else    
         ball_x_on_l <= 1'b0; 
         
      if ( pixel_x_ball <= ball_x_r )    
         ball_x_on_r <= 1'b1; 
      else    
         ball_x_on_r <= 1'b0; 

      if ( ball_y_t  <= pixel_y_ball )     
         ball_y_on_t <= 1'b1; 
      else    
         ball_y_on_t <= 1'b0; 

      if ( pixel_y_ball <= ball_y_b )    
         ball_y_on_b <= 1'b1; 
      else    
         ball_y_on_b <= 1'b0; 
   end 
    

   always @( posedge clk ) begin  
      ball_x_pixel_offset <= pixel_x_ball[2:0] - ball_x_l[2:0] ; 
   end

   assign   ball_y_pixel_offset = pixel_y_ball[2:0] - ball_y_t[2:0] ; 

   always @( posedge clk ) begin  
      case ( ball_y_pixel_offset ) 
         0  : ball_y_pixel_on <= 8'b00111100 ; 
         1  : ball_y_pixel_on <= 8'b01111110 ; 
         2  : ball_y_pixel_on <= 8'b11111111 ; 
         3  : ball_y_pixel_on <= 8'b11111111 ; 
         4  : ball_y_pixel_on <= 8'b11111111 ; 
         5  : ball_y_pixel_on <= 8'b11111111 ; 
         6  : ball_y_pixel_on <= 8'b01111110 ; 
         7  : ball_y_pixel_on <= 8'b00111100 ; 
         default : ball_y_pixel_on <= 8'b00000000 ; 
      endcase 
   end    


   assign ball_pixel_on =  ball_y_pixel_on[ ball_x_pixel_offset ] ;   

   always @ (posedge clk ) begin 
      if ( rst ) begin
         ball_on_r  <= 1'b0;
      end else if ( ball_x_on_l & ball_x_on_r & ball_y_on_t & ball_y_on_b  & ball_pixel_on ) begin 
         ball_on_r  <= 1'b1; 
      end else begin   
         ball_on_r  <= 1'b0; 
      end   
   end 


   //**********************************************************************//
   //  Mux all oject  
   //**********************************************************************//

   always @( posedge clk ) begin  
      if ( rst ) begin 
            object_color   <= background_color ;
      end else begin
         if ( ball_on_r )  
            object_color   <= ball_color ;
         else if ( bar_on_r )  
            object_color   <= bar_color ;
         else if ( wall_on_r )  
            object_color   <= wall_color ;
         else if ( line_on_r )  
            object_color   <= line_color ;
         else 
            object_color   <= background_color ;
      end 
   end 

   always @( posedge clk ) begin  
      if ( rst )  
         object_on   <= 1'b0; 
      else if ( ball_on_r | bar_on_r | wall_on_r | line_on_r )  
         object_on   <= 1'b1; 
      else    
         object_on   <= 1'b0; 
   end       
         
endmodule 


