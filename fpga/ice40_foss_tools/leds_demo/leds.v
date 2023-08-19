module leds(
   input  wire clk,
   output wire led_r, 
   output wire led_g, 
   output wire led_b
);

localparam N = 24;

reg [N-1:0] counter = 0; // N-bit register
wire [1:0]  selected_bits;

assign selected_bits = { counter[N-1], counter[N-2] };
assign led_r = ~(selected_bits == 2'b01);
assign led_g = ~(selected_bits == 2'b10);
assign led_b = ~(selected_bits == 2'b11);

always @(posedge clk) begin
      counter <= counter + 1'b1; // increment the counter value
end

endmodule

