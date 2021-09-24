// authors: Jacob Schramkowski, Christopher D'Amico, Thomas Antonacci

module memA #(
	parameter BITS_AB=8,
	parameter DIM=8
) (
	input clk, rst_n, en, WrEn, 
	input signed [BITS_AB-1:0] Ain [DIM-1:0], 
	input [$clog2(DIM)-1:0] Arow, 
	output signed [BITS_AB-1:0] Aout [DIM-1:0]
);

logic [$clog2(DIM)-1:0] count;

genvar row;

generate

	for (row = 0; row < DIM; row++) begin

		// using modified fifo with ability to overwrite INPUT_DEPTH entries
		fifo_set #(
			.DEPTH(DIM + row),
			.BITS(BITS_AB),
			.INPUT_DEPTH(DIM)
		) FIFO(
			.clk(clk),
			.rst_n(rst_n),
			.en(en),
			.WrEn(WrEn && (Arow == row)),
			.in_array(Ain),
			.d(0), // since this is written to using WrEn, always shift in zeroes
			.q(Aout[row])
		);

	end

endgenerate

// doesn't look like this was being used
// assign Bout = fifoFeeder[location];

// use a counter to determine when to load zeroes, set to 0 on reset
always @(posedge clk or negedge rst_n) begin

if (!rst_n) begin

	count = 0;

end else if (en) begin

	if (count < DIM) count++;

end

end

endmodule