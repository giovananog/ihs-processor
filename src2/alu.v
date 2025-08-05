module alu(
    input wire [15:0] op_a, input wire [15:0] op_b, input wire [2:0] op_select,  
    output reg [15:0] result, output wire zero_flag
);
    parameter ADD_OP = 3'b000, SUB_OP = 3'b001, NAN_OP = 3'b010, PASS_A_OP = 3'b011, PASS_B_OP = 3'b100; 
    always @(*) begin 
        case (op_select)
            ADD_OP:  result = op_a + op_b; SUB_OP:  result = op_a - op_b;
            NAN_OP:  result = ~(op_a & op_b); PASS_A_OP: result = op_a;         
            PASS_B_OP: result = op_b; default: result = 16'bx;          
        endcase
    end
    assign zero_flag = (result == 16'b0);
endmodule