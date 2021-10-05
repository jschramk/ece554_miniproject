module tpuv1 #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8,
    parameter ADDRW=16,
    parameter DATAW=64
) (
    input clk, rst_n, r_w, // r_w=0 read, =1 write
    input [DATAW-1:0] dataIn,
    output [DATAW-1:0] dataOut,
    input [ADDRW-1:0] addr
);

logic Aen, Ben, SAen, AWrEn, SAWrEn, high;
logic [$clog2(DIM)-1:0] Arow;
logic [$clog2(DIM)-1:0] Crow;
logic signed [BITS_AB-1:0] Aout [DIM-1:0];
logic signed [BITS_AB-1:0] Bout [DIM-1:0];
logic [$clog2(3*DIM-2):0] count;
logic signed [BITS_AB-1:0] ABDataIn [DIM-1:0];
logic signed [BITS_AB-1:0] Bin [DIM-1:0];
logic signed [BITS_C-1:0] CDataIn [DIM-1:0];
logic signed [BITS_C-1:0] CDataOut [DIM-1:0];
logic signed [BITS_C-1:0] CHalf [(DIM/2) - 1:0];
logic signed [DATAW*2-1:0] COutRaw;


genvar i;
generate

	for (i = 0; i < DIM; i++)  begin
		assign ABDataIn[i] = dataIn[8*i+7:i*8];
		assign COutRaw[16*i + 15: 16*i] = CDataOut[i];
		assign Bin[i] = (count > 0) ? {DIM{1'b0}} : ABDataIn[i];
	end

	for (i = 0; i < DIM/2; i++) begin
		assign CHalf[i] = dataIn[16*i + 15: 16*i];
	end
	
endgenerate

assign AWrEn = (count == 0 || count > 3*DIM-2) && r_w && (addr >= 16'h100 && addr <= 16'h13f);
assign Arow = addr[7:3];
assign Ben = ((count == 0 || count > 3*DIM-2) && r_w && (addr >= 16'h200 && addr <= 16'h23f)) || (count > 0) || addr >= 16'h400;
assign Crow = addr[6:4];
assign high = addr[3];
assign SAWrEn = (count == 0 || count > 3*DIM-2) && r_w && (addr >= 16'h300 && addr <= 16'h37f);
assign CDataIn = high ? {CHalf, CDataOut[3:0]} : {CDataOut[7:4], CHalf};
assign dataOut = high ? COutRaw[127: 64] : COutRaw[63:0];
assign Aen = (count > 0) || addr >= 16'h400;
assign SAen = (count > 0 && count <= 3*DIM-2) || (r_w && addr == 16'h0400) || (!r_w && addr >= 16'h300 && addr <= 16'h37f);

memA #(
    .BITS_AB(BITS_AB),
    .DIM(DIM)
) MEMA (
    .clk(clk),
    .rst_n(rst_n),
    .en(Aen),
    .WrEn(AWrEn), 
	.Ain(ABDataIn), 
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
	.Bin(Bin), 
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
    .en(SAen),
    .A(Aout),
    .B(Bout),
    .Cin(CDataIn),
    .Crow(Crow),
    .Cout(CDataOut)
);

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
	end else if (count > 3*DIM-2) begin
		count <= 0;
	end else if (addr == 16'h0400 || count > 0) begin
		count++;
	end
end

/*
always @(posedge clk or negedge rst_n) begin

	if (!rst_n) begin
		count <= 0;
	end

	Aen <= 0;
	Ben <= 0;
	SAen <= 0;
	AWrEn <= 0;
	SAWrEn <= 0;
	high <= 0;

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
				Crow <= addr[6:4];
				high <= addr[3];
				SAWrEn <= 1;
				count <= 0;
				
				CDataIn <= high ? {CHalf, CDataOut[3:0]} : {CDataOut[7:4], CHalf};

			end else if(addr == 16'h400) begin
				
				// start computation
				count++;
				SAen <= 1;
				
			end

		end else begin
			if (addr >= 16'h300 && addr <= 16'h37f) begin
				
				// read from C
				Crow <= addr[6:4];
				high <= addr[3];
				SAen <= 1;
				dataOut <= high ? COutRaw[127: 64] : COutRaw[63:0];
				
			end
		end
	end else begin
		count++;
		SAen <= 1;
	end
end*/


endmodule