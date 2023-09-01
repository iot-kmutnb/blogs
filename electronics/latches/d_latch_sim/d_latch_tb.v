`timescale 1ns/1ps

module d_latch_tb;
    // Test inputs and outputs
    reg t_D, t_E;
    wire t_Q, t_QB;

    d_latch dut (
        .D(t_D),
        .E(t_E),
        .Q(t_Q),
        .QB(t_QB)
    );


    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, d_latch_tb);
        for (integer i=0; i < 100; i=i+1) begin
           t_D  = $random;
           t_E  = $random;
           #10; // Wait for 10 time units
        end
        #20;
        $finish; // End simulation
    end

endmodule
