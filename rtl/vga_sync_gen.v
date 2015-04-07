//`define VGA_640X480_60HZ 
//`define VGA_800X600_72HZ 
`define VGA_1024X768_70HZ

module vga_sync_gen #( parameter 
   X_PIXEL_N_BITS = 11 ,    
   Y_PIXEL_N_BITS = 11
) (            
   input wire       clk,
   input wire       rst,
   output reg       h_sync_r,
   output reg       v_sync_r,
   output reg       vga_on_r,
   output reg       ref_tick, 
   output reg [X_PIXEL_N_BITS-1 : 0 ] pixel_x_r,
   output reg [Y_PIXEL_N_BITS-1 : 0 ] pixel_y_r
);      

`ifdef VGA_640X480_60HZ 
   localparam HLB = 48  ; 
   localparam HD  = 640 ; 
   localparam HRB = 16  ; 
   localparam HTR = 96  ; 
   localparam HALL = HLB + HD + HRB + HTR ; 
   localparam VTB = 33  ;
   localparam VD  = 480 ;
   localparam VBB = 10  ;
   localparam VTR = 2   ;
   localparam VALL = VTB + VD + VBB + VTR ;
`endif

`ifdef VGA_800X600_72HZ 
   localparam HLB = 64  ; 
   localparam HD  = 800 ; 
   localparam HRB = 56  ; 
   localparam HTR = 120  ; 
   localparam HALL = HLB + HD + HRB + HTR ; 
   localparam VTB = 23  ;
   localparam VD  = 600 ;
   localparam VBB = 37  ;
   localparam VTR = 6   ;
   localparam VALL = VTB + VD + VBB + VTR ;
`endif

`ifdef VGA_1024X768_70HZ
   localparam HLB = 144  ; 
   localparam HD  = 1024 ; 
   localparam HRB = 24  ; 
   localparam HTR = 136  ; 
   localparam HALL = HLB + HD + HRB + HTR ; 
   localparam VTB = 29  ;
   localparam VD  = 768 ;
   localparam VBB = 3   ;
   localparam VTR = 6   ;
   localparam VALL = VTB + VD + VBB + VTR ;
`endif

   reg [X_PIXEL_N_BITS-1 : 0 ] h_sync_cnt;
   reg [Y_PIXEL_N_BITS-1 : 0 ] v_sync_cnt;

   wire h_sync_end, v_sync_end ; 


   // Horizon sync signals generation 
   assign h_sync_end = ( h_sync_cnt == ( HALL - 1 ) ) ;

   always @( posedge clk ) begin 
      if ( rst ) begin 
         h_sync_cnt <= 'd0;  
      end else begin
         if ( h_sync_end ) begin 
            h_sync_cnt  <= 'd0 ; 
         end else begin 
            h_sync_cnt <= h_sync_cnt + 1'b1 ;  
         end   
      end    
   end 

   always @( posedge clk ) begin 
      if ( rst ) begin 
         h_sync_r <= 1'b0 ; 
      end else begin 
         if ( ( h_sync_cnt >= ( HD + HRB ) ) && ( h_sync_cnt <= ( HD + HRB + HTR - 1 ) ) ) begin 
            h_sync_r <= 1'b1; 
         end else begin  
            h_sync_r <= 1'b0;
         end 
      end 
   end 


   // Vertical sync signals generation 
   assign v_sync_end = ( v_sync_cnt == ( VALL - 1 ) ) ;

   always @( posedge clk ) begin 
      if ( rst ) begin 
         v_sync_cnt <= 'd0;  
      end else if ( h_sync_end ) begin
         if ( v_sync_end ) begin 
            v_sync_cnt  <= 'd0 ; 
         end else begin 
            v_sync_cnt <= v_sync_cnt + 1'b1 ;  
         end   
      end      
   end 

   always @( posedge clk ) begin 
      if ( rst ) begin 
         v_sync_r <= 1'b0 ; 
      end else begin 
         if ( ( v_sync_cnt >= ( VD + VBB ) ) && ( v_sync_cnt <= ( VD + VBB + VTR - 1 ) ) ) begin 
            v_sync_r <= 1'b1; 
         end else begin  
            v_sync_r <= 1'b0;
         end 
      end 
   end 


   // signal allowing pixels are shown  
   always @( posedge clk ) begin 
      if ( rst ) begin 
         vga_on_r <= 1'b0 ; 
      end else begin 
         if ( ( h_sync_cnt < HD ) && ( v_sync_cnt < VD ) )
            vga_on_r <= 1'b1 ; 
         else    
            vga_on_r <= 1'b0 ; 
      end 
   end 

   always @( posedge clk ) begin 
      pixel_x_r      <= h_sync_cnt ; 
      pixel_y_r      <= v_sync_cnt ; 
   end 
   
   always @( posedge clk ) begin  
      if ( rst ) begin 
         ref_tick <= 1'b0;
      end else if ( ( h_sync_cnt == 0 ) && ( v_sync_cnt == VD ) ) begin 
         ref_tick <= 1'b1 ; 
      end else begin  
         ref_tick <= 1'b0 ; 
      end 
   end      

endmodule 
