module tpuv1 #(
	parameter BITS_AB=8,
	parameter BITS_C=16,
	parameter DIM=8,
	parameter ADDRW=16,
	parameter DATAW=64
) (
	input clk, rst_n, r_w, // r_w=0 read, =1 write
	input [DATAW-1:0] dataIn,
	output logic [DATAW-1:0] dataOut,
	input [ADDRW-1:0] addr
);

logic computing;

logic Aen, Ben, AWrEn, SysArrWrEn, high, BWrEn;
logic [$clog2(DIM)-1:0] Arow;
logic [$clog2(DIM)-1:0] Crow;
logic [$clog2(3*DIM-2):0] count;
logic signed [BITS_AB-1:0] Ain [DIM-1:0];
logic signed [BITS_AB-1:0] memAOut [DIM-1:0];
logic signed [BITS_AB-1:0] Bin [DIM-1:0];
logic signed [BITS_AB-1:0] memBOut [DIM-1:0];
logic signed [BITS_C-1:0] Cin [DIM-1:0];
logic signed [BITS_C-1:0] CDataOut [DIM-1:0];
logic signed [BITS_C-1:0] Creg [DIM/2-1:0];
logic signed [DATAW*2-1:0] COutRaw;


genvar i;

generate

	for (i = 0; i < DIM; i++)  begin

		assign Bin[i] = BWrEn ? dataIn[8*i+7:8*i] : 0;
		assign Ain[i] = dataIn[8*i+7:8*i];

		assign COutRaw[16*i + 15: 16*i] = CDataOut[i];

	end

	for (i = 0; i < DIM/2; i++) begin

		assign Creg[i] = dataIn[16*i + 15: 16*i];

	end

endgenerate


//assign AWrEn = (count == 0 || count > 3*DIM-2) && r_w && (addr >= 16'h100 && addr <= 16'h13f);
assign Arow = addr[7:3];
assign Crow = addr[6:4];
assign high = addr[3];
/*
assign Ben = ((count == 0 || count > 3*DIM-2) && r_w && (addr >= 16'h200 && addr <= 16'h23f)) || (count > 0) || addr >= 16'h400;
assign SysArrWrEn = (count == 0 || count > 3*DIM-2) && r_w && (addr >= 16'h300 && addr <= 16'h37f);
assign Cin = high ? {Creg, CDataOut[3:0]} : {CDataOut[7:4], Creg};
assign dataOut = high ? COutRaw[127: 64] : COutRaw[63:0];
assign Aen = (count > 0) || addr >= 16'h400;
assign SAen = (count > 0 && count <= 3*DIM-2) || (r_w && addr == 16'h0400) || (!r_w && addr >= 16'h300 && addr <= 16'h37f);
*/

memA #(
	.BITS_AB(BITS_AB),
	.DIM(DIM)
) MEMA (
	.clk(clk),
	.rst_n(rst_n),
	.en(Aen),
	.WrEn(AWrEn), 
	.Ain(Ain), 
	.Arow(Arow), 
	.Aout(memAOut)
);

memB #(
	.BITS_AB(BITS_AB),
	.DIM(DIM)
) MEMB (
	.clk(clk),
	.rst_n(rst_n),
	.en(Ben),
	.Bin(Bin), 
	.Bout(memBOut) 
);

systolic_array #(
	.BITS_AB(BITS_AB),
	.BITS_C(BITS_C),
	.DIM(DIM)
) SYS_ARR (
	.clk(clk),
	.rst_n(rst_n),
	.WrEn(SysArrWrEn),
	.en(computing),
	.A(memAOut),
	.B(memBOut),
	.Cin(Cin),
	.Crow(Crow),
	.Cout(CDataOut)
);

int c;

always @(posedge clk or negedge rst_n) begin

	if (!rst_n) begin

		count <= 0;
		computing <= 0;

		for(c = 0; c <= DIM/2-1; c++) Creg[c] <= 0;

	end else begin

		Aen <= 0;
		Ben <= 0;
		AWrEn <= 0;
		BWrEn <= 0;
		SysArrWrEn <= 0;
		dataOut <= 0;

		if (!computing) begin
			
			if(r_w) begin // on write, load data based on addr
				
				if(addr >= 16'h100 && addr <= 16'h13f) begin
					
					// write into A
					AWrEn <= 1;

				end else if (addr >= 16'h200 && addr <= 16'h23f) begin
					
					// write into B
					Ben <= 1;
					BWrEn <= 1;

				end else if (addr >= 16'h300 && addr <= 16'h37f) begin
					
					// write into C
					SysArrWrEn <= 1;
					
					Cin <= high ? {Creg, CDataOut[3:0]} : {CDataOut[7:4], Creg};

				end else if(addr == 16'h400) begin
					
					// start computation
					computing <= 1;
					
				end

			end else begin // read

				if (addr >= 16'h300 && addr <= 16'h37f) begin
					
					// read from C
					dataOut <= high ? COutRaw[127:64] : COutRaw[63:0];
					
				end

			end

		end else begin

			if(count < DIM*3-2) begin

				Aen <= 1;
				Ben <= 1;

				count <= count + 1;

			end else begin

				computing <= 0;
				count <= 0;

			end



		end

	end
	
end


endmodule