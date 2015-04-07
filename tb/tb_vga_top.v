`timescale 1ns / 100ps


module testbench () ; 

   logic    clk, rst ; 
   logic    up_en,  down_en;
   logic    vga_hsync,  vga_vsync;
   logic [2:0] vga_rgb;

  //*******************************************************************//
  //     Instatiation                                                  // 
  //*******************************************************************//

  ping_pong_top  ping_pong_top_inst (
      .clk       ( clk       ), //i
      .rst       ( rst       ), //i
      .up_en     ( up_en     ), //i
      .down_en   ( down_en   ), //i
      .vga_hsync ( vga_hsync ), //o
      .vga_vsync ( vga_vsync ), //o
      .vga_rgb   ( vga_rgb   )  //o
  );


  //*******************************************************************//
  //     clock                                                         // 
  //*******************************************************************//

  always #10ns clk = ~ clk ; 


  //*******************************************************************//
  //     Main test                                                     // 
  //*******************************************************************//

  initial begin 
      rst   =  1'b1; clk   =  1'b0; 

     //reset dut 
     repeat (8) @(posedge clk ) ; 
     #5 rst = 1'b0;   
     repeat (20) @(posedge clk ) ; 

      
     #1s  $finish ; 
      
  end 


  //*******************************************************************//
  //     FSDB dumper                                                   // 
  //*******************************************************************//

  initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
  end


endmodule 


