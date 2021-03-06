
module text (
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,

   // --- sync singals 
   input  wire [9:0]  pixel_x,
   input  wire [9:0]  pixel_y,
   
   // --- datapath signal 
   input  wire [3:0]  dig0,
   input  wire [3:0]  dig1,
   input  wire [1:0]  ball_num,    
    
   // --- text output   
   output wire [2:0]  text_strings_on,     
   output reg         text_bit_on,
   output wire [2:0]  text_color      
);
   
`include "vga_color_def.vh" 


   reg [9:0]   pixel_x_r, pixel_y_r, pixel_x_r_1d, pixel_y_r_1d;
   reg   score_on_r, logo_on_r, over_on_r, text_on_r, text_on_r_1d ; 
   reg [2:0]   text_color_r ; 

   wire [10:0]  bitmap_addr ; 
   wire [7:0]   bitmap_byte ; 

   wire [3:0]   row_idx_for_score; 
   wire [3:0]   col_idx_for_score;  
   wire [2:0]   col_bit_for_score;
   reg  [6:0]   char_score; 

   wire [3:0]   row_idx_for_logo;  
   wire [2:0]   col_idx_for_logo;  
   wire [2:0]   col_bit_for_logo;
   reg  [6:0]   char_logo; 

   wire [3:0]   row_idx_for_over;  
   wire [3:0]   col_idx_for_over;  
   wire [2:0]   col_bit_for_over;
   reg [6:0]   char_over; 


   reg [6:0]   char_idx_r;  
   reg [3:0]   row_idx_r;  
   reg [2:0]   bit_idx_r, bit_idx_r_1d; 

   wire  [2:0] text_strings_on_r ; 
   reg   [2:0] text_strings_on_r_1d, text_strings_on_r_2d, text_strings_on_r_3d;      


   always @ (posedge clk ) begin 
      pixel_x_r      <= pixel_x;
      pixel_y_r      <= pixel_y;
      pixel_x_r_1d   <= pixel_x_r;
      pixel_y_r_1d   <= pixel_y_r;
   end
  
   //**********************************************************************//
   // Instatiate 16X8 font ROM   
   //**********************************************************************//
   asc16x8  asc16x8_inst (
      .clk          ( clk         ), //i
      .bitmap_addr  ( bitmap_addr ), //i
      .bitmap_byte  ( bitmap_byte )  //o
   );
   

   assign bitmap_addr   =  { char_idx_r, row_idx_r }  ; 

   assign text_strings_on_r[TEXT_LOGO_BIT]  = logo_on_r ; 
   assign text_strings_on_r[TEXT_SCORE_BIT] = score_on_r ; 
   assign text_strings_on_r[TEXT_OVER_BIT]  = over_on_r ; 


   assign text_strings_on  =  text_strings_on_r_3d ; 

   always @( posedge clk ) begin  
      text_on_r   <= 1'b0; 
      if ( score_on_r | logo_on_r | over_on_r ) begin  
         text_on_r   <= 1'b1 ; 
      end    
      text_on_r_1d    <= text_on_r ; 
      bit_idx_r_1d    <= bit_idx_r ; 
      text_strings_on_r_1d   <= text_strings_on_r ; 
      text_strings_on_r_2d   <= text_strings_on_r_1d ; 
      text_strings_on_r_3d   <= text_strings_on_r_2d ; 
   end

   always @( posedge clk ) begin  
      if ( rst ) begin 
         text_bit_on <= 1'b0 ; 
      end else begin    
         text_bit_on <= 1'b0 ; 
         if  ( text_on_r_1d )  begin  
            text_bit_on   <=  bitmap_byte[~ bit_idx_r_1d ] ;  
         end 
      end    
   end    
   



   //**********************************************************************//
   // Score region  
   //    -  Font size : 1X
   //**********************************************************************//
  
   always @( posedge clk ) begin  
      if ( ( pixel_x_r[9:5] < 8  ) && ( pixel_y_r[9:5] == 0  ) ) begin 
         score_on_r  <= 1'b1 ; 
      end else begin
         score_on_r  <= 1'b0 ; 
      end
   end   
   
   assign  row_idx_for_score = pixel_y_r_1d[4:1] ;  
   assign  col_idx_for_score = pixel_x_r[7:4] ; // Shoule be [9:4]. But score_on_r determines actual position   
   assign  col_bit_for_score = pixel_x_r_1d[3:1] ; // 2 bit for obe dot. That means 2 times  

   // code below is generated by perl command-line :
   // #perl -e '@aci = unpack("C*", "Score:xx  Ball:x" ); foreach (@aci) { printf "4h%1x :  char_s  =   7h%x; // %c\n", $i++, $_, $_ } '
   always @( posedge clk ) begin  
      case ( col_idx_for_score ) 
        4'h0 :  char_score  <=   7'h53; // S
        4'h1 :  char_score  <=   7'h63; // c
        4'h2 :  char_score  <=   7'h6f; // o
        4'h3 :  char_score  <=   7'h72; // r
        4'h4 :  char_score  <=   7'h65; // e
        4'h5 :  char_score  <=   7'h3a; // :
        4'h6 :  char_score  <=   { 3'b011, dig1 }; // digit 10  
        4'h7 :  char_score  <=   { 3'b011, dig0 }; // digit 1
        4'h8 :  char_score  <=   7'h20; //  
        4'h9 :  char_score  <=   7'h20; //  
        4'ha :  char_score  <=   7'h42; // B
        4'hb :  char_score  <=   7'h61; // a
        4'hc :  char_score  <=   7'h6c; // l
        4'hd :  char_score  <=   7'h6c; // l
        4'he :  char_score  <=   7'h3a; // :
        4'hf :  char_score  <=   { 5'b01100, ball_num}; // 
        default :  char_score  <=   7'h20; //  
      endcase 
   end

   //**********************************************************************//
   // Log region :   
   //    - Font size : 4X 
   //**********************************************************************//
   always @( posedge clk ) begin  
      if ( ( pixel_x_r[9:6] >= 3 ) && ( pixel_x_r[9:6] <= 6 ) &&  ( pixel_y_r[9:7] ==2 ) ) begin 
         logo_on_r  <= 1'b1 ; 
      end else begin
         logo_on_r  <= 1'b0 ; 
      end
   end   
   
   assign  row_idx_for_logo  = pixel_y_r_1d[6:3] ;  
   assign  col_idx_for_logo  = pixel_x_r[8:6] ;  
   assign  col_bit_for_logo  = pixel_x_r_1d[5:3] ; // 3 bit for one dot. That means 8 times  
   
   always @( posedge clk ) begin  
      case ( col_idx_for_logo ) 
         3'o3 :  char_logo  <=   7'h50; // P
         3'o4 :  char_logo  <=   7'h4f; // O
         3'o5 :  char_logo  <=   7'h4e; // N
         default  :  char_logo  <=   7'h47; // G
      endcase 
   end    


   //**********************************************************************//
   // Game over region :   
   //    -  Font size : 2X
   //**********************************************************************//
   always @( posedge clk ) begin  
      if ( ( pixel_x_r[9:5] >= 5 ) && ( pixel_x_r[9:5] <= 13 ) &&  ( pixel_y_r[9:6] ==3 ) ) begin 
         over_on_r  <= 1'b1 ; 
      end else begin
         over_on_r  <= 1'b0 ; 
      end
   end   
   
   assign  row_idx_for_over  = pixel_y_r_1d[5:2] ;  
   assign  col_idx_for_over  = pixel_x_r[8:5] ;  
   assign  col_bit_for_over  = pixel_x_r_1d[4:2] ; // 2  bit for one dot. That means 4 times  
   
   always @( posedge clk ) begin  
      case ( col_idx_for_over ) 
         4'h5 :  char_over  <=   7'h47; // G
         4'h6 :  char_over  <=   7'h61; // a
         4'h7 :  char_over  <=   7'h6d; // m
         4'h8 :  char_over  <=   7'h65; // e
         4'h9 :  char_over  <=   7'h20; //  
         4'ha :  char_over  <=   7'h4f; // O
         4'hb :  char_over  <=   7'h76; // v
         4'hc :  char_over  <=   7'h65; // e
         default  :  char_over  <=   7'h72; // r
      endcase 
   end    

   //**********************************************************************//
   // Mux for font ROM    
   //**********************************************************************//

   always @( posedge clk ) begin  
      text_color_r   <= CYAN  ; 
      if ( score_on_r ) begin
         char_idx_r  <= char_score ; 
         row_idx_r   <= row_idx_for_score ;  
         bit_idx_r   <= col_bit_for_score ; 
      end else if ( logo_on_r ) begin 
         char_idx_r  <= char_logo ;  
         row_idx_r   <= row_idx_for_logo ;  
         bit_idx_r   <= col_bit_for_logo ; 
      end else if ( over_on_r ) begin 
         char_idx_r  <= char_over ;
         row_idx_r   <= row_idx_for_over ;  
         bit_idx_r   <= col_bit_for_over ; 
      end   
   end


   assign   text_color  =  text_color_r ; 

endmodule 
