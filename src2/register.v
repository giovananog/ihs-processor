module register #(parameter WIDTH = 16) (
    input wire clock,    
    input wire enable,   
    input wire resetn,
    input wire [WIDTH-1:0] data_in, 
    output reg [WIDTH-1:0] data_out 
);
    always @(posedge clock or negedge resetn) begin
        if (!resetn) begin 
            data_out <= {WIDTH{1'b0}}; 
        end else if (enable) begin
            data_out <= data_in; 
        end
    end
endmodule