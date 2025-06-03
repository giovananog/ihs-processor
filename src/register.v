// register.v

module register #(parameter WIDTH = 16) (
    input wire clock,    
    input wire enable,   
    input wire [WIDTH-1:0] data_in, 
    output reg [WIDTH-1:0] data_out 
);

    always @(posedge clock) begin
        if (enable == 1) begin
            data_out <= data_in;
        end
    end

endmodule