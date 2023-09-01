`timescale 1ns/1ps

module jk_latch_tb;
    // Test inputs and outputs
    reg  t_J, t_K;
    wire t_Q, t_QB;

    jk_latch #( .t_pd(1) ) dut (
        .J(t_J),
        .K(t_K),
        .Q(t_Q),
        .QB(t_QB)
    );

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, jk_latch_tb);
        t_J <= 0; t_K <= 0;
        force dut.Q_i  = 0;
        force dut.QB_i = 1;
        force dut.SB = 1;
        force dut.RB = 1;
        #2
        release dut.Q_i;
        release dut.QB_i;
        release dut.SB;
        release dut.RB;

        #20;
        t_J <= 1; t_K <= 0;
        #20;
        t_J <= 0; t_K <= 1;
        #20;
        t_J <= 1; t_K <= 1;
        #20;
        $finish; // End simulation
    end

endmodule

