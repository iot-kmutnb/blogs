`timescale 1ns/1ps

module sr_latch_tb;
    // Test inputs and outputs
    reg t_S, t_R, t_E;
    wire t_Q, t_QB;

    sr_latch #( .t_pd(1) ) dut (
        .S(t_S),
        .R(t_R),
        .E(t_E),
        .Q(t_Q),
        .QB(t_QB)
    );

    reg [2:0] bits;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, sr_latch_tb);
        t_E <= 0; t_S <=0; t_R <= 0;
        force dut.SB   = 1;
        force dut.RB   = 0;
        force dut.Q_i  = 0;
        force dut.QB_i = 1;
        #2
        release dut.Q_i;
        release dut.QB_i;
        release dut.SB;
        release dut.RB;

        for (integer i=0; i < 16; i=i+1) begin
           bits = $unsigned(i);
           t_E  = bits[2];
           t_S  = bits[1];
           t_R  = bits[0];
           #20; // Wait for 20 time units
        end
        #20;
        $finish; // End simulation
    end

endmodule
