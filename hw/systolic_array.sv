// authors: Jacob Schramkowski, Christopher D'Amico, Thomas Antonacci

module systolic_array
#(
   parameter BITS_AB=8,
   parameter BITS_C=16,
   parameter DIM=8
)
(
   input clk,rst_n,WrEn,en,
   input signed [BITS_AB-1:0] A [DIM-1:0],
   input signed [BITS_AB-1:0] B [DIM-1:0],
   input signed [BITS_C-1:0] Cin [DIM-1:0],
   input [$clog2(DIM)-1:0] Crow,
   output signed [BITS_C-1:0] Cout [DIM-1:0]
);

// grid conector from each A column to the next flowing left to right
// 9 rows, 8 cols, sampled inversely to swap orientation
wire signed [BITS_AB-1:0] A_conn [DIM:0] [DIM-1:0];

// grid connector from each B row to the next flowing top to bottom
// 9 rows, 8 cols, sampled normally
wire signed [BITS_AB-1:0] B_conn [DIM:0] [DIM-1:0];

wire signed [BITS_C-1:0] C_conn [DIM-1:0] [DIM-1:0];

assign A_conn[0] = A;
assign B_conn[0] = B;
assign Cout = C_conn[Crow];

genvar row, col;

generate;
    
    for(row = 0; row < DIM; row++) begin

        for(col = 0; col < DIM; col++) begin

            tpumac #(
                .BITS_AB(BITS_AB),
                .BITS_C(BITS_C)
            ) DUT(
                .clk( clk ),
                .rst_n( rst_n ),
                .WrEn( WrEn & (row == Crow) ),
                .en( en ),
                .Ain( A_conn[col][row] ),
                .Bin( B_conn[row][col] ),
                .Cin( Cin[col] ),
                .Aout( A_conn[col+1][row] ),
                .Bout( B_conn[row+1][col] ),
                .Cout( C_conn[row][col] )
            );

        end

    end

endgenerate

endmodule