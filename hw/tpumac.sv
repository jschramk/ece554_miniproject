// authors: Jacob Schramkowski, Christopher D'Amico, Thomas Antonacci

// Spec v1.1
module tpumac
#(
    parameter BITS_AB=8,
    parameter BITS_C=16)
(
    input clk, rst_n, WrEn, en,
    input signed [BITS_AB-1:0] Ain,
    input signed [BITS_AB-1:0] Bin,
    input signed [BITS_C-1:0] Cin,
    output reg signed [BITS_AB-1:0] Aout,
    output reg signed [BITS_AB-1:0] Bout,
    output reg signed [BITS_C-1:0] Cout
);
// Modelsim prefers "reg signed" over "signed reg"

// update outputs on en or set value of Cout on WrEn
always @(posedge clk or negedge rst_n) begin
    
    if(~rst_n) begin
        
        Aout <= 0;
        Bout <= 0;
        Cout <= 0;

    end else if (WrEn) begin
        
        Cout <= Cin;

    end else if(en) begin
        
        Aout <= Ain;
        Bout <= Bin;
        Cout <= Ain * Bin + Cout;

    end

end

endmodule