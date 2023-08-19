module rgb_leds (
  output wire [2:0] rgb_leds
);

localparam N = 26; // the bit width of the counter

wire clk; // on-chip clock
reg  [N-1:0] counter;
wire [1:0]   selected_bits;
wire [2:0]   rgb_ctrl;

// Use the High-Frequency Internal Oscillator
SB_HFOSC osc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

defparam osc.CLKHF_DIV = "0b01"; 
// 00=48MHz, 01=24MHz, 10=12MHZ, 11=6MHz
 
// Counter
always @(posedge clk) begin
   counter <= counter + 1'b1;
end

assign selected_bits = { counter[N-1], counter[N-2] };
// RGB control signals are active-high.
assign rgb_ctrl[0] = (selected_bits == 2'b01); // Blue
assign rgb_ctrl[1] = (selected_bits == 2'b10); // Red
assign rgb_ctrl[2] = (selected_bits == 2'b11); // Green

// Instantiate RGB_DRIVER primitive
SB_RGBA_DRV driver (
    .RGBLEDEN(1'b1),           // enable control for LEDs
    .RGB0PWM ( rgb_ctrl[0] ),  // RGB LED control signal 0
    .RGB1PWM ( rgb_ctrl[1] ),  // RGB LED control signal 1
    .RGB2PWM ( rgb_ctrl[2] ),  // RGB LED control signal 2
    .CURREN  ( 1'b1 ),         // power up
    .RGB0    ( rgb_leds[0] ),  // RGB_LED output 0 // Pin 39 (B)
    .RGB1    ( rgb_leds[1] ),  // RGB_LED output 1 // Pin 40 (R)
    .RGB2    ( rgb_leds[2] )   // RGB_LED output 2 // Pin 41 (G)
);

// Drive strength options:
//   "0b000000" = 0mA
//   "0b000001" = 4mA
//   "0b000011" = 8mA
//   "0b000111" = 12mA
//   "0b001111" = 16mA
//   "0b011111" = 20mA
defparam driver.RGB0_CURRENT = "0b000011";
defparam driver.RGB1_CURRENT = "0b000011";
defparam driver.RGB2_CURRENT = "0b000011";
defparam driver.CURRENT_MODE = "0b0"; // "0"=full, "1"=half

endmodule
