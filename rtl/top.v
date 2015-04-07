module top ( 


);      

wire  clk,  rst,  update_allow_frist_pluse,  update_allow_first_pluse_16dly,  up_en,  down_en;

wire  wall_on,  bar_on,  ball_on;

wire [ 9:0 ] pixel_x;
wire [ 9:0 ] pixel_y;
wire [ 9:0 ] wall_x_l;
wire [ 9:0 ] wall_x_r;
wire [ 9:0 ] wall_y_t;
wire [ 9:0 ] wall_y_b;
wire [ 2:0 ] wall_color;
wire [ 9:0 ] bar_x_l;
wire [ 9:0 ] bar_x_r;
wire [ 9:0 ] bar_y_t;
wire [ 9:0 ] bar_y_b;
wire [ 2:0 ] bar_color;
wire [ 9:0 ] ball_x_l;
wire [ 9:0 ] ball_x_r;
wire [ 9:0 ] ball_y_t;
wire [ 9:0 ] ball_y_b;
wire [ 2:0 ] ball_color;

wire text_bit_on; 

wire [ 2:0 ] text_color;

object  object_inst (
   .clk      ( clk      ), //i
   .rst      ( rst      ), //i
   .pixel_x  ( pixel_x  ), //i
   .pixel_y  ( pixel_y  ), //i
   .wall_x_l ( wall_x_l ), //i
   .wall_x_r ( wall_x_r ), //i
   .wall_y_t ( wall_y_t ), //i
   .wall_y_b ( wall_y_b ), //i
   .wall_on  ( wall_on  ), //o
   .bar_x_l  ( bar_x_l  ), //i
   .bar_x_r  ( bar_x_r  ), //i
   .bar_y_t  ( bar_y_t  ), //i
   .bar_y_b  ( bar_y_b  ), //i
   .bar_on   ( bar_on   ), //o
   .ball_x_l ( ball_x_l ), //i
   .ball_x_r ( ball_x_r ), //i
   .ball_y_t ( ball_y_t ), //i
   .ball_y_b ( ball_y_b ), //i
   .ball_on  ( ball_on  )  //o
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
   .wall_color                     ( wall_color                     ), //o
   .bar_x_l                        ( bar_x_l                        ), //o
   .bar_x_r                        ( bar_x_r                        ), //o
   .bar_y_t                        ( bar_y_t                        ), //o
   .bar_y_b                        ( bar_y_b                        ), //o
   .bar_color                      ( bar_color                      ), //o
   .ball_x_l                       ( ball_x_l                       ), //o
   .ball_x_r                       ( ball_x_r                       ), //o
   .ball_y_t                       ( ball_y_t                       ), //o
   .ball_y_b                       ( ball_y_b                       ), //o
   .ball_color                     ( ball_color                     )  //o
);

text  text_inst (
   .clk         ( clk         ), //i
   .rst         ( rst         ), //i
   .pixel_x     ( pixel_x     ), //i
   .pixel_y     ( pixel_y     ), //i
   .dig0        ( dig0        ), //i
   .dig1        ( dig1        ), //i
   .ball_num    ( ball_num    ), //i
   .text_bit_on ( text_bit_on ), //o
   .text_color  ( text_color  )  //o
);

endmodule
