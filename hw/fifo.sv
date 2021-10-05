// fifo.sv
// Implements delay buffer (fifo)
// On reset all entries are set to 0
// Shift causes fifo to shift out oldest entry to q, shift in d

module fifo #(
    parameter DEPTH=8,
    parameter BITS=64
)(
    input clk,rst_n,en,
    input [BITS-1:0] d,
    output [BITS-1:0] q
);

// shift register
reg [BITS-1:0] regs [DEPTH-1:0];

int i;

// shift on clock when enabled
always @(posedge clk or negedge rst_n) begin

    if(~rst_n) begin

        for(i = 0; i < DEPTH; i=i+1) regs[i] <= 0;

    end else if(en) begin
        
        regs[DEPTH-1:0] <= {regs[DEPTH-2:0], d};

    end


end

// output last entry
assign q = regs[DEPTH-1];

endmodule // fifo
