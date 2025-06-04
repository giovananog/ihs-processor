// signal_extender.v

module signal_extender(
    input wire [15:0] instruction, 
    output wire [15:0] immediate_value 
);

    assign immediate_value = {7'b0, instruction[8:0]};

endmodule