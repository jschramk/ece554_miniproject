// systolic array testbench

`include "systolic_array_tc.svh"

module mem_tb();

   localparam BITS_AB=8;
   localparam DIM=8;
   localparam ROWBITS = $clog2(DIM);
   
   localparam TESTS=10;
   
   // Clock
   logic clk;
   logic rst_n;
   logic en;
   logic WrEn;
   logic [ROWBITS-1:0] Arow;
   logic signed [BITS_AB-1:0] Ain [DIM-1:0];
   logic signed [BITS_AB-1:0] Bin [DIM-1:0];
   logic signed [BITS_AB-1:0] Aout [DIM-1:0];
   logic signed [BITS_AB-1:0] Bout [DIM-1:0];
   logic signed [BITS_AB-1:0] AoutReg [DIM-1:0];
   logic signed [BITS_AB-1:0] BoutReg [DIM-1:0];
   
   bit signed [BITS_AB-1:0] expectedB[DIM-1:0];
   bit signed [BITS_AB-1:0] expectedA[DIM-1:0];

   always #5 clk = ~clk; 

   integer errors,mycycle;

   memA #(.BITS_AB(BITS_AB),
          .DIM(DIM)
         ) DUT_A (.*);
		 
   memB #(.BITS_AB(BITS_AB),
		  .DIM(DIM)
		 ) DUT_B (.*);
					
   systolic_array_tc #(.BITS_AB(BITS_AB),
                       .BITS_C(16),
                       .DIM(DIM)
                       ) satc;


   // register Cout values
   always @(posedge clk) begin
      AoutReg <= Aout;
	  BoutReg <= Bout;
   end
   
   initial begin
	  clk = 1'b0;
	  rst_n = 1'b1;
	  en = 1'b0;
	  WrEn = 1'b0;
	  errors = 0;
      Arow = {ROWBITS{1'b0}};
      for(int rowcol=0;rowcol<DIM;++rowcol) begin
         Ain[rowcol] = {BITS_AB{1'b0}};
         Bin[rowcol] = {BITS_AB{1'b0}};
      end
      
	  // reset and check Cout
	  @(posedge clk) begin end
	  rst_n = 1'b0; // active low reset
      @(posedge clk) begin end
      rst_n = 1'b1; // reset finished
	  @(posedge clk) begin end

      // check that C was properly reset
      for(int Row=0;Row<DIM;++Row) begin
         Arow = {Row[ROWBITS-1:0]};
         @(posedge clk) begin end
         for(int Col=0;Col<DIM;++Col) begin
            if(BoutReg[Col] !== 0) begin
		         errors++;
		         $display("Error! B reset was not conducted properly. Expected: 0, Got: %d for Row %d Col %d", BoutReg[Col],Row, Col); 
	          end
			if(AoutReg[Row] !== 0) begin
				errors++;
				$display("Error! A reset was not conducted properly. Expected: 0, Got: %d for Row %d Col %d", AoutReg[Row],Row, Col); 
           end
		 end
      end
      

      for(int test=0;test<TESTS;++test) begin

         // instantiate test case
         satc = new();
         @(posedge clk) begin end
		 for (int i = 0; i < DIM; i++) begin
			
			for (int j = 0; j < DIM; j++) begin
				Bin[j] = satc.B[i][j];
			end
			en = 1'b1;
			@(posedge clk) begin end
		 end
		 en = 1'b0;

		@(posedge clk) begin end
		 for (int i = 0; i < DIM; i++) begin
			Arow = {i[ROWBITS-1:0]};
			for (int j = 0; j < DIM; j++) begin
				Ain[j] = satc.A[i][j];
			end
			
			WrEn = 1'b1;
			@(posedge clk) begin end
		 end
		 WrEn = 1'b0;
		 en = 1'b1;
		 
		 for (int i = 0; i < 3*DIM - 2; i++) begin
			for (int j = 0; j < DIM; j++) begin
				expectedB[j] = satc.get_next_B(j);
				expectedA[j] = satc.get_next_A(j);
			end
			@(posedge clk) begin end
			for (int j = 0; j < DIM; j++) begin
				if (Bout[j] !== expectedB[j]) begin
					$display("Error! Incorrect value. Expected: %d, Got: %d for Row %d Col %d", expectedB[j], Bout[j], i, j);
					errors++;
				end
				if (Aout[j] !== expectedA[j]) begin
					$display("Error! Incorrect value. Expected: %d, Got: %d for Row %d Col %d", expectedA[j], Aout[j], i, j);
					errors++;
				end
			end
			satc.next_cycle();
		 end
		 if (errors == 0) begin
			$display("No errors, testcase passed\n");
		 end else begin
			$display("\n");
		 end
		 
		 en = 1'b0;
		 @(posedge clk) begin end
		rst_n = 1'b0; // active low reset
		@(posedge clk) begin end
		rst_n = 1'b1; // reset finished
		@(posedge clk) begin end
		
		 satc = null;
	  end
	  
	  
	  $stop;
   end // initial begin

endmodule // mem_tb

   
