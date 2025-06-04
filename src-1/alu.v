// alu.v

module alu(
    input wire [15:0] op_a,      
    input wire [15:0] op_b,      
    input wire [2:0] op_select,  
    output reg [15:0] result     
);

    parameter ADD_OP   = 3'b000; 
    parameter SUB_OP   = 3'b001; 
    parameter NAN_OP   = 3'b010; 
    parameter PASS_A_OP = 3'b011; 
    parameter PASS_B_OP = 3'b100; 

    always @(*) begin 
        $display("Time=%0t (ALU 1): op_a=%b, op_b=%b, op_select:%b", $time, op_a, op_b, op_select); 

        case (op_select)
            ADD_OP:  result = op_a + op_b;
            SUB_OP:  result = op_a - op_b;
            NAN_OP:  result = ~(op_a & op_b); 
            PASS_A_OP: result = op_a;         
            PASS_B_OP: result = op_b;         
            default: result = 16'bx;          
        endcase

        $display("Time=%0t (ALU 2): result=%b", $time, result); 
    end

endmodule