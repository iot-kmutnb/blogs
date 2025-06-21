module leds_running #(
  parameter CLK_HZ   = 27000000,
  parameter NUM_LEDS = 6
)(
  input  wire CLK,    // system clock
  input  wire nRST,   // global asynchronous reset (active-low)
  output wire [NUM_LEDS-1:0] LEDS // LED Pins
);

  localparam COUNT_PERIOD = (CLK_HZ / 20);
  localparam COUNT_MIN = 0;
  localparam COUNT_MAX = COUNT_PERIOD - 1;

  reg [31:0] count = COUNT_MIN;
  reg [NUM_LEDS-1:0] leds_reg = 1;
  reg shift_en  = 0;
  reg shift_dir = 0;
  wire shift_reverse;

  always @(posedge CLK or negedge nRST) begin
    if (nRST == 1'b0) begin
      count <= COUNT_MIN;
      shift_en <= 1'b0;
    end
    else begin
      if (count == COUNT_MAX) begin
        count <= COUNT_MIN;
        shift_en <= 1'b1;
      end
      else begin
        count <= count + 1;
        shift_en <= 1'b0;
      end
    end
  end

  always @(shift_dir or leds_reg) begin
     if (  (!shift_dir && leds_reg[NUM_LEDS-1])
        || ( shift_dir && leds_reg[0]) )
       shift_reverse <= 1'b1;
     else
       shift_reverse <= 1'b0;
  end

  always @(posedge CLK or negedge nRST) begin
    if (nRST == 1'b0) begin
      shift_dir   <= 1'b0;
      leds_reg[0] <= 1'b1;
      leds_reg[NUM_LEDS-1:1] <= {NUM_LEDS-1{1'b0}};
    end
    else begin
      if (shift_en == 1'b1) begin
         if (shift_reverse)
            shift_dir <= !shift_dir;
         else begin
           if (!shift_dir)
             leds_reg <= {leds_reg[NUM_LEDS-2:0],1'b0};
           else 
             leds_reg <= {1'b0,leds_reg[NUM_LEDS-1:1]};
         end
      end
    end
  end

  assign LEDS = ~leds_reg;

endmodule
