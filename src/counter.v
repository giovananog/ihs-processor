// counter.v

module counter(
    input wire clock, 
    input wire clear, 
    output reg [1:0] out = 2'b00 
);

    always @(posedge clock) begin
        if (clear == 1) begin
            out <= 2'b00; 
        end else begin
            out <= out + 1'b1; 
        end
    end

endmodule