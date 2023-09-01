`timescale 1ns / 1ps

module sr_latch #(
    parameter t_pd = 1.0
)(
    input wire S,
    input wire R,
    input wire E,
    output wire Q,
    output wire QB
);
    wire SB, RB;
    wire Q_i, QB_i;

    // Continuous assignments with (inertial) delays
    assign #(t_pd) SB = ~(S & E);       // NAND2
    assign #(t_pd) RB = ~(R & E);       // NAND2

    assign #(t_pd) Q_i  = ~(SB & QB_i); // NAND2
    assign #(t_pd) QB_i = ~(RB & Q_i);  // NAND2

    assign Q  = Q_i;
    assign QB = QB_i;
endmodule

