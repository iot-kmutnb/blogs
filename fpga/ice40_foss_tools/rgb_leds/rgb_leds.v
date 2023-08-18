module rgb_leds (
  output wire [2:0] rgb_leds // Red, Blue, Green
);

wire clk; // on-chip clock
reg  [25:0] counter;
wire [2:0]  rgb_ctrl;

// Use Internal Oscillator
SB_HFOSC OSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

defparam OSC.CLKHF_DIV = "0b01"; 
// 00=48MHz, 01=24MHz, 10=12MHZ, 11=6MHz
 
// Counter
always @(posedge clk) begin
   counter <= counter + 1'b1;
end

assign rgb_ctrl[0] =  counter[25] &  counter[24];
assign rgb_ctrl[1] =  counter[25] & ~counter[24];
assign rgb_ctrl[2] = ~counter[25] &  counter[24];

// Instantiate RGB_DRIVER primitive
SB_RGBA_DRV RGB_DRIVER (
    .RGBLEDEN(1'b1),           // enable control for LEDs
    .RGB0PWM ( rgb_ctrl[0] ),  // RGB LED control signal 0
    .RGB1PWM ( rgb_ctrl[1] ),  // RGB LED control signal 1
    .RGB2PWM ( rgb_ctrl[2] ),  // RGB LED control signal 2
    .CURREN  ( 1'b1 ),         // power up
    .RGB0    ( rgb_leds[0] ),  // RGB_LED output 0
    .RGB1    ( rgb_leds[1] ),  // RGB_LED output 1
    .RGB2    ( rgb_leds[2] )   // RGB_LED output 2
);

defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";

endmodule
