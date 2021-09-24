// authors: Jacob Schramkowski, Christopher D'Amico, Thomas Antonacci

module memB #( 
	parameter BITS_AB=8,
	parameter DIM=8 
) ( 
	input clk,rst_n,en, 
	input signed [BITS_AB-1:0] Bin [DIM-1:0], 
	output signed [BITS_AB-1:0] Bout [DIM-1:0] 
);

logic [$clog2(DIM):0] count;

genvar col;

generate

	for (col = 0; col < DIM; col++) begin

		fifo #(
			.DEPTH(DIM + col),
			.BITS(BITS_AB)
		) FIFO(
			.clk(clk),
			.rst_n(rst_n),
			.en(en),
			.d(count < DIM ? Bin[col] : {BITS_AB{1'b0}}),
			.q(Bout[col])
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