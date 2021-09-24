// fifo_set.sv
// Implements delay buffer (fifo)
// On reset all entries are set to 0
// Shift causes fifo to shift out oldest entry to q, shift in d

// NEW TO fifo_set:
// set the top INPUT_DEPTH values to in_array on WrEn

module fifo_set #(
    parameter DEPTH=8,
    parameter BITS=64,
    parameter INPUT_DEPTH=8
)(
    input clk,rst_n,en,WrEn,
    input [BITS-1:0] in_array [INPUT_DEPTH-1:0],
    input [BITS-1:0] d,
    output [BITS-1:0] q
);

// shift register
reg [BITS-1:0] regs [DEPTH-1:0];

int i;

// shift on clock when enabled
always @(posedge clk or negedge rst_n) begin

    if(~rst_n) begin 
        
        for(i = 0; i < DEPTH; i++) regs[i] = 0;

    end else if(WrEn) begin // new WrEn condition 
    
        // set top INPUT_DEPTH entries to in_array, leaving other values unchanged (overwrite, no shift)
        regs[DEPTH-1:0] <= {in_array, regs[DEPTH-INPUT_DEPTH-1:0]};
    
    end else if(en) begin
    
        // shift in d from most significant end
        regs[DEPTH-1:0] <= {d, regs[DEPTH-1:1]};

    end

end

// output last entry (this version is fed backwards, so last entry is least significant index)
assign q = regs[0];


endmodule // fifo
