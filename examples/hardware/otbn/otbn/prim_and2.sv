module prim_and2 #(
    parameter int Width = 1
) (
    input [Width-1:0] in0_i,
    input [Width-1:0] in1_i,
    output logic [Width-1:0] out_o
);

prim_generic_and2 #(
    .Width(Width)
) u_impl_generic (
    .*
);

endmodule
