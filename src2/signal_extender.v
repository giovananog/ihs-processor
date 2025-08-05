module signal_extender(
    input wire [15:0] instruction,
    output wire [15:0] immediate_value
);
    assign immediate_value = {{6{instruction[9]}}, instruction[9:0]};
endmodule