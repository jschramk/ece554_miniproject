module tpuv1
  #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8,
    parameter ADDRW=16,
    parameter DATAW=64
   )
   (
    input clk, rst_n, r_w, // r_w=0 read, =1 write
    input [DATAW-1:0] dataIn,
    output [DATAW-1:0] dataOut,
    input [ADDRW-1:0] addr
   );

	//Interconnects
	wire signed [BITS_AB-1:0] memAIn  [DIM-1:0];
	wire signed [BITS_AB-1:0] memBIn  [DIM-1:0];

	wire signed [BITS_AB-1:0] memAOut [DIM-1:0];
	wire signed [BITS_AB-1:0] memBOut [DIM-1:0];

	wire signed [BITS_C-1:0]  macCIn  [DIM-1:0];
	wire signed [BITS_C-1:0]  macCOut [DIM-1:0];

   	logic [DATAW-1:0] readC;
   	assign dataOut = readC;

	// Reg for counter
   	reg [($clog2(4*DIM))-1:0] counter;

	// Control Sigs
   	logic write_a, write_b, write_c, en, start;

	// Row Selections
	wire [($clog2(DIM))-1:0] aRow;
	wire [($clog2(DIM))-1:0] cRow;
	assign aRow = addr[5:3];
	assign cRow = addr[6:4];

	// ---------------------------------------------------------------------------------

	//Generating Interconnects for inputs
	// A and B
	genvar i;
	generate
		for (i = 0; i < DIM; i++) begin
			assign memAIn[i] = dataIn[((i+1) * BITS_AB) - 1:(i * BITS_AB)];
			assign memBIn[i] = en ? 0 : dataIn[((i+1) * BITS_AB) - 1:(i * BITS_AB)];
		end
	endgenerate

	// think this is working
	// C
	generate
		for (i = 0; i < DIM; i++) begin
			if (i < DIM/2) begin
				assign macCIn[i] = (addr[3:0] == 'h0) ? dataIn[((i + 1) * BITS_C) - 1 : i * BITS_C] :macCOut[i];
			end
			else begin
				assign macCIn[i] = (addr[3:0] == 'h8) ? dataIn[(((i - DIM/2) + 1) * BITS_C) - 1 : (i - DIM/2) * BITS_C] :macCOut[i];
			end
		end
	endgenerate
   
	// ---------------------------------------------------------------------------------------

	// Modules
	memA #(.BITS_AB(BITS_AB), .DIM(DIM)) iMEMA(
		.clk(clk),
		.rst_n(rst_n),
		.en(en),
		.WrEn(write_a),
		.Ain(memAIn),
		.Arow(aRow),
		.Aout(memAOut)
		);

	memB #(.BITS_AB(BITS_AB), .DIM(DIM)) iMEMB(
		.clk(clk),
		.rst_n(rst_n),
		.en(en | write_b),
		.Bin(memBIn),
		.Bout(memBOut)
		);
	
	systolic_array #(.BITS_AB(BITS_AB), .BITS_C(BITS_C), .DIM(DIM)) iSYSARRY(
		.clk(clk),
		.rst_n(rst_n),
		.WrEn(write_c),
		.en(en),
		.A(memAOut),
		.B(memBOut),
		.Cin(macCIn),
		.Crow(cRow),
		.Cout(macCOut)
		);

	// ------------------------------------------------------------------------------

	// Control logic
	always_comb begin
		write_a <= 0;
		write_b <= 0;
		write_c <= 0;
		start <= 0;
		readC <= 0;

		casex(addr)
			'h1xx:
				write_a <= r_w;

			'h2xx:
				write_b <= r_w;

			'h3x0:
				if (r_w) begin
					write_c <= 1;
				end else begin
					for (integer i = 0; i < DIM / 2; i++) begin
						readC |= (macCOut[i] << (i * BITS_C));
					end
				end

			'h3x8:
				if (r_w) begin
					write_c <= 1;
				end else begin
					for (integer i = 0; i < DIM / 2; i++) begin
						readC |= (macCOut[i + DIM/2] << (i * BITS_C));
					end
				end

			'h400:
				start <= r_w;
		endcase

	end

	assign en = |counter;
	always_ff @(posedge clk) begin
		if (~rst_n) begin
			counter <= 0;
		end
		else if (start || en) begin
			counter <= counter + 1;
		end
	end

endmodule