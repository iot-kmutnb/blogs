module d_latch (
    input wire D,
    input wire E,
    output reg Q,
    output reg QB
);
    initial begin
       Q  <= 0;
       QB <= 1;
    end

    always @(*) begin
      if (E) begin
        Q  <=  D;
        QB <= ~D;
      end
    end

endmodule
