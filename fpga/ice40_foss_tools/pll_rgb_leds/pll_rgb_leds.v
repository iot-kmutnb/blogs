module pll_rgb_leds ( 
  input  wire clk,
  output wire [2:0] rgb_leds
);

localparam N = 26; // bit width of the counter

reg  [N-1:0] counter = 0;
wire [1:0]   selected_bits;
wire [2:0]   rgb_ctrl;
wire clk_in, clk_out, pll_locked;

assign clk_in = clk;

SB_PLL40_PAD #(
  .FEEDBACK_PATH("SIMPLE"),
  .DIVR(0),        // DIVR =  0
  .DIVF(63),       // DIVF = 63
  .DIVQ(4),        // DIVQ =  4
  .FILTER_RANGE(1) // FILTER_RANGE = 1
) pll_inst ( 
  .LOCK(pll_locked),
  .RESETB(1'b1),
  .BYPASS(1'b0),
  .PACKAGEPIN(clk_in),
  .PLLOUTCORE(clk_out)
);

// Counter
always @(posedge clk_out) begin
   counter <= counter + 1'b1;
end

assign selected_bits = { counter[N-1], counter[N-2] };
assign rgb_ctrl[0] = (selected_bits == 2'b01); // Red
assign rgb_ctrl[1] = (selected_bits == 2'b10); // Green
assign rgb_ctrl[2] = (selected_bits == 2'b11); // Blue

// All three LEDs are active-low.
assign rgb_leds = ~rgb_ctrl;
 
endmodule
