module memA 
  #(
	parameter BITS_AB=8,
	parameter DIM=8
  ) (
	input clk, rst_n, en, WrEn, 
	input signed [BITS_AB-1:0] Ain [DIM-1:0], 
	input [$clog2(DIM)-1:0] Arow, 
	output signed [BITS_AB-1:0] Aout [DIM-1:0]
	);
	
	logic [BITS_AB-1:0] fifoFeeder [DIM-1:0];
	
	
	generate begin
		for (int i = 0; i < DIM; i++) begin
			
		end
	
	endgenerate
	
endmodule