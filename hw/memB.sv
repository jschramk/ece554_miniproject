module memB  
  #( 
	parameter BITS_AB=8,
	parameter DIM=8 
  ) ( 
	input clk,rst_n,en, 
	input signed [BITS_AB-1:0] Bin [DIM-1:0], 
	output signed [BITS_AB-1:0] Bout [DIM-1:0] 
  );
  logic [BITS_AB-1:0] fifoFeeder [DIM-1:0];
  logic [$clog2(DIM)-1:0] count;
  
  assign fifoFeeder = (count < DIM) ? Bin : 0;
  
  generate begin
	for (int i = 0; i < DIM; i++) begin
		fifo #(.DEPTH(DIM + i), .BITS(BITS_AB)) f (.d(fifoFeeder[i]), .q(Bout[i]), .clk(clk), .rst_n(rst_n), .en(en));
	end
  endgenerate
  
  
  assign Bout = fifoFeeder[location];
  
  always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count = 0;
	else if (en) begin
		if count < DIM
			count++;
	end
  end
  
endmodule