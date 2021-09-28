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
    .BITS_AB(BITS_AB),
    .DIM(DIM)
) MEMA (
    .clk(clk),
    .rst_n(rst_n),
    .en(Aen),
    .WrEn(AWrEn), 
	.Ain(dataIn), 
	.Arow(Arow), 
	.Aout(Aout)
);

memB #(
    .BITS_AB(BITS_AB),
    .DIM(DIM)
) MEMB (
    .clk(clk),
    .rst_n(rst_n),
    .en(Ben),
	.Bin(dataIn), 
	.Bout(Bout) 
);

systolic_array #(
    .BITS_AB(BITS_AB),
    .BITS_C(BITS_C),
    .DIM(DIM)
) SYS_ARR (
    .clk(clk),
    .rst_n(rst_n),
    .WrEn(SAWrEn),
    .en(SAEn),
    .A(Aout),
    .B(Bout),
    .Cin(dataIn),
    .Crow(Crow),
    .Cout(dataOut)
);

logic Aen, Ben, SAen, AWrEn, SAWrEn;
logic [$clog2(DIM)-1:0] Arow;
logic [$clog2(DIM)-1:0] Crow;
logic signed [BITS_AB-1:0] Aout [DIM-1:0];
logic signed [BITS_AB-1:0] Bout [DIM-1:0];
logic [$clog2(3*DIM-2):0] count;

always @(posedge clk) begin

	Aen <= 0;
	Ben <= 0;
	SAen <= 0;
	AWrEn <= 0;
	SAWrEn <= 0;	

	if (count == 0 || count > 3*DIM-2) begin
		if(r_w) begin // on write, load data based on addr
			
			if(addr >= 16'h100 && addr <= 16'h13f) begin
				
				// write into A
				Arow <= addr[7:0] / 8;
				AWrEn <= 1;
				count <= 0;

			end else if (addr >= 16'h200 && addr <= 16'h23f) begin
				
				// write into B
				Ben <= 1;
				count <= 0;

			end else if (addr >= 16'h300 && addr <= 16'h37f) begin
				
				// write into C
				Crow <= addr[7:0] / 8;
				SAWrEn <= 1;
				count <= 0;

			end else if(addr == 16'h400) begin
				
				// start computation
				count++;
				SAEn <= 1;
				
			end

		end else begin
			if (addr >= 16'h300 && addr <= 16'h37f) begin
				
				// read from C
				Crow <= addr[7:0] / 8;
				SAEn <= 1;
				
			end
		end
	end else begin
		count++;
		SAEn <= 1;
	end
end


endmodule;