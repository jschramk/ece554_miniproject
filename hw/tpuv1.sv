module tpuv1 #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8,
    parameter ADDRW=16;
    parameter DATAW=64;
) (
    input clk, rst_n, r_w, // r_w=0 read, =1 write
    input [DATAW-1:0] dataIn,
    output [DATAW-1:0] dataOut,
    input [ADDRW-1:0] addr
);

memA #(
    .BITS_AB(),
    .DIM()
) MEMA (
    .clk(),
    .rst_n(),
    .en(),
    .WrEn(), 
	.Ain(), 
	.Arow(), 
	.Aout()
);

memB #(
    .BITS_AB(),
    .DIM()
) MEMB (
    .clk(),
    .rst_n(),
    .en(),
	.Bin(), 
	.Bout() 
);

systolic_array #(
    .BITS_AB(),
    .BITS_C(),
    .DIM()
) SYS_ARR (
    .clk(),
    .rst_n(),
    .WrEn(),
    .en(),
    .A(),
    .B(),
    .Cin(),
    .Crow(),
    .Cout()
);


endmodule;