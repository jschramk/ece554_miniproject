// authors: Jacob Schramkowski, Christopher D'Amico, Thomas Antonacci

module tpumac_tb;

logic 
clk,
rst_n,
WrEn,
en;

logic signed [7:0]
Ain,
Bin,
Aout,
Bout;

logic signed [15:0]
Cin,
Cout,
ExpSum;

tpumac DUT(
    .clk(clk),
    .rst_n(rst_n),
    .WrEn(WrEn),
    .en(en),
    .Ain(Ain),
    .Bin(Bin),
    .Cin(Cin),
    .Aout(Aout),
    .Bout(Bout),
    .Cout(Cout)
);

int errors = 0;

initial begin

    clk = 0;
    en = 0;
    WrEn = 0;
    rst_n = 1;
    ExpSum = 0;

    @(negedge clk) rst_n = 0;
    @(negedge clk) rst_n = 1;

    if (Aout !== 0 || Bout !== 0 || Cout != 0) begin
        errors++;
        $display("Error! Reset was not conducted properly. Expected: Aout = 0, Bout = 0, Cout = 0, \
        Got: Aout = %d, Bout = %d, Cout = %d",Aout, Bout, Cout ); 
	end
		
    Ain = 0;
    Bin = 0;
    Cin = 0;
    
    @(posedge clk)

    en <= 1;
    rst_n <=1;
    
    // BEGIN SEQUENTIAL TESTING
    for (int i = 1; i <= 10; i++) begin

        for (int j = 1; j <= 10; j++) begin

            @(posedge clk);
            @(negedge clk);
            
            if (Aout !== Ain) begin
                errors++;
                $display("Error! Reset was not conducted properly. Expected: Aout = %d, Got Aout = %d", Ain, Aout);
            end

            if (Bout !== Bin) begin
                errors++;
                $display("Error! Reset was not conducted properly. Expected: Bout = %d, Got Bout = %d", Bin, Bout);
            end

            if (Cout !== ExpSum) begin
                errors++;
                $display("Error! Reset was not conducted properly. Expected: Cout = %d, Got Cout = %d", ExpSum, Cout);
            end
        
            Ain <= i;
            Bin <= j;
            
            ExpSum <= ExpSum + (i * j);

        end

    end

    WrEn = 0;
    en = 0;
    rst_n = 1;

    @(negedge clk) rst_n = 0;
    @(negedge clk) rst_n = 1;

    ExpSum = 0;

    // BEGIN RANDOM TESTING
    for(int i = 0; i < 500; i++) begin

        // randomly assert enable to make sure the module is not updating when it is not enabled
        en = $random;
        // assert write enable every few loops
        WrEn = i % 20 == 0;

        // when enabled, set random inputs and update expected result
        if(en) begin
            Ain = $random;
            Bin = $random;
            Cin = $random;
            // expected value should just be the rolling sum of each iteration of A * B
            ExpSum = WrEn ? Cin : ExpSum + Ain * Bin; 
        end

        // wait for computation
        @(posedge clk)
        @(negedge clk)

        // check that Aout matches the expected result
        if(en && Aout !== Ain) begin
            $display("ERROR: Expected Aout: %h, got %h", Ain, Aout);
            errors++;
        end

        // check that Bout matches the expected result
        if(en && Bout !== Bin) begin
            $display("ERROR: Expected Bout: %h, got %h", Bin, Bout);
            errors++;
        end

        // check that Cout matches the expected result
        if(Cout !== ExpSum) begin
            $display("ERROR: Expected Cout: %h, got %h", ExpSum, Cout);
            errors++;
        end

    end

    // display errors if there are any or display tests passed
    if(errors) begin
        $display("Tests failed with %d errors.", errors);
    end else begin
        $display("YAHOO!!! All tests passed.");
    end

    $stop;

end

always
    #5 clk = ~clk;

endmodule