`timescale 1ns/1ps

module jk_latch #(
    parameter t_pd = 1
)(
    input wire  J,
    input wire  K,
    output wire Q,
    output wire QB
);
    wire SB, RB;
    wire Q_i, QB_i;

    assign #(t_pd) SB   = ~(J & QB_i);  // NAND2
    assign #(t_pd) RB   = ~(K & Q_i);   // NAND2
    assign #(t_pd) Q_i  = ~(SB & QB_i); // NAND2
    assign #(t_pd) QB_i = ~(RB & Q_i);  // NAND2
   
    assign Q  = Q_i;
    assign QB = QB_i;

endmodule
