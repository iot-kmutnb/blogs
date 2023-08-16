module top(
   input  wire clk,
   output wire LED_R, 
   output wire LED_G, 
   output wire LED_B
);

reg [24:0] counter = 0;

assign LED_R = ~counter[21];
assign LED_G = ~counter[22];
assign LED_B = ~counter[23];

always @(posedge clk) begin
      counter <= counter + 1; // increment the counter value
end

endmodule // top

