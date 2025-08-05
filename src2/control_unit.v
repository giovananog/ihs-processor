module control_unit(
    input wire clock, input wire resetn, input wire [15:0] instruction, input wire zero_flag_from_alu,
    output wire reg_file_master_enable, output wire reg_a_enable, output wire reg_r_enable,         
    output wire [7:0] reg_file_write_enable_mask, output wire [2:0] alu_op_code, output wire mux_sel_op_a,         
    output wire mux_sel_op_b, output wire bus_mux_select, output wire mux_sel_reg_file_data_in, 
    output wire [2:0] reg_read_addr_x, output wire [2:0] reg_read_addr_y, output wire [2:0] reg_write_addr,   
    output wire bus_output_enable, output wire pc_write_enable, output wire pc_source_mux_select
);
    parameter OP_ADD = 3'b000, OP_SUB = 3'b001, OP_NAN = 3'b010, OP_OUT = 3'b100, OP_LDI = 3'b101, OP_BNE = 3'b110, OP_REP = 3'b111;
    parameter ALU_ADD = 3'b000, ALU_SUB = 3'b001, ALU_NAN = 3'b010, ALU_PASS_A = 3'b011, ALU_PASS_B = 3'b100;
    reg [1:0] current_state_reg; 
    always @(posedge clock or negedge resetn) if (!resetn) current_state_reg <= 2'b00; else current_state_reg <= current_state_reg + 1'b1;
    wire [2:0] opcode = instruction[15:13];
    assign reg_read_addr_x = instruction[12:10]; assign reg_write_addr = instruction[12:10]; assign reg_read_addr_y = instruction[9:7];
    decoder write_decoder_inst (.reg_addr(reg_write_addr), .enable_mask(reg_file_write_enable_mask));
    wire branch_condition_met = (opcode == OP_BNE) && (zero_flag_from_alu == 1'b0);
    assign reg_a_enable = (current_state_reg == 2'b01);
    assign reg_r_enable = (current_state_reg == 2'b10) && (opcode != OP_OUT) && (opcode != OP_BNE);
    assign alu_op_code = (current_state_reg == 2'b10) ? ((opcode == OP_ADD) ? ALU_ADD : (opcode == OP_SUB) ? ALU_SUB : (opcode == OP_NAN) ? ALU_NAN : (opcode == OP_REP) ? ALU_PASS_B : (opcode == OP_BNE) ? ALU_PASS_A : ALU_PASS_A ) : 3'b000; 
    assign mux_sel_op_a = (current_state_reg == 2'b01) && (opcode == OP_LDI);
    assign mux_sel_op_b = (current_state_reg == 2'b10) && (opcode == OP_LDI);
    assign bus_output_enable = (current_state_reg == 2'b11 && opcode == OP_OUT);
    assign bus_mux_select = 1'b0;
    assign reg_file_master_enable = (current_state_reg == 2'b11) && (opcode != OP_OUT) && (opcode != OP_BNE);
    assign mux_sel_reg_file_data_in = 1'b0; 
    assign pc_write_enable = (current_state_reg == 2'b11);
    assign pc_source_mux_select = branch_condition_met;
endmodule