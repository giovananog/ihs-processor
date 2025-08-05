module processor( input wire clock, input wire resetn, output wire [15:0] bus );
    wire [15:0] pc_out, pc_in, instruction_from_mem, iin, immediate_value, reg_a_out, mux_op_a_out;
    wire pc_write_enable, pc_source_mux_select, reg_a_enable;

    register #(16) pc_reg (.clock(clock), .enable(pc_write_enable), .resetn(resetn), .data_in(pc_in), .data_out(pc_out));
    instruction_memory inst_mem (.address(pc_out), .instruction(iin));

    assign pc_in = pc_source_mux_select ? (pc_out + immediate_value) : (pc_out + 1);

    signal_extender immediate_ext (.instruction(iin), .immediate_value(immediate_value));
    register #(16) reg_a (.clock(clock), .enable(reg_a_enable), .resetn(resetn), .data_in(mux_op_a_out), .data_out(reg_a_out));

    wire [15:0] alu_result, mux_op_b_out, r_reg_out;
    wire zero_flag_from_alu, reg_r_enable;
    wire [2:0] alu_op_code;

    alu alu_unit (.op_a(reg_a_out), .op_b(mux_op_b_out), .op_select(alu_op_code), .result(alu_result), .zero_flag(zero_flag_from_alu));
    register #(16) reg_r (.clock(clock), .enable(reg_r_enable), .resetn(resetn), .data_in(alu_result), .data_out(r_reg_out));

    wire [15:0] reg_file_data_in = r_reg_out;
    wire [15:0] r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out;
    wire [7:0] reg_file_write_enable_mask;
    wire reg_file_master_enable;

    register #(16) r0_inst (.clock(clock), .enable(reg_file_write_enable_mask[7] & reg_file_master_enable), .resetn(resetn), .data_in(reg_file_data_in), .data_out(r0_out));
    register #(16) r1_inst (.clock(clock), .enable(reg_file_write_enable_mask[6] & reg_file_master_enable), .resetn(resetn), .data_in(reg_file_data_in), .data_out(r1_out));
    register #(16) r2_inst (.clock(clock), .enable(reg_file_write_enable_mask[5] & reg_file_master_enable), .resetn(resetn), .data_in(reg_file_data_in), .data_out(r2_out));
    register #(16) r3_inst (.clock(clock), .enable(reg_file_write_enable_mask[4] & reg_file_master_enable), .resetn(resetn), .data_in(reg_file_data_in), .data_out(r3_out));
    register #(16) r4_inst (.clock(clock), .enable(reg_file_write_enable_mask[3] & reg_file_master_enable), .resetn(resetn), .data_in(reg_file_data_in), .data_out(r4_out));
    register #(16) r5_inst (.clock(clock), .enable(reg_file_write_enable_mask[2] & reg_file_master_enable), .resetn(resetn), .data_in(reg_file_data_in), .data_out(r5_out));
    register #(16) r6_inst (.clock(clock), .enable(reg_file_write_enable_mask[1] & reg_file_master_enable), .resetn(resetn), .data_in(reg_file_data_in), .data_out(r6_out));
    register #(16) r7_inst (.clock(clock), .enable(reg_file_write_enable_mask[0] & reg_file_master_enable), .resetn(resetn), .data_in(reg_file_data_in), .data_out(r7_out));
    
    wire [2:0] reg_read_addr_x, reg_read_addr_y, reg_write_addr;
    wire mux_sel_op_a, mux_sel_op_b, bus_mux_select, mux_sel_reg_file_data_in, bus_output_enable;

    control_unit control_unit_inst ( .clock(clock), .resetn(resetn), .instruction(iin), .zero_flag_from_alu(zero_flag_from_alu), .reg_file_master_enable(reg_file_master_enable), .reg_a_enable(reg_a_enable), .reg_r_enable(reg_r_enable), .reg_file_write_enable_mask(reg_file_write_enable_mask), .alu_op_code(alu_op_code), .mux_sel_op_a(mux_sel_op_a), .mux_sel_op_b(mux_sel_op_b), .bus_mux_select(bus_mux_select), .mux_sel_reg_file_data_in(mux_sel_reg_file_data_in), .reg_read_addr_x(reg_read_addr_x), .reg_read_addr_y(reg_read_addr_y), .reg_write_addr(reg_write_addr), .bus_output_enable(bus_output_enable), .pc_write_enable(pc_write_enable), .pc_source_mux_select(pc_source_mux_select));
    
    assign mux_op_a_out = mux_sel_op_a ? immediate_value : (reg_read_addr_x == 3'b000 ? r0_out : reg_read_addr_x == 3'b001 ? r1_out : reg_read_addr_x == 3'b010 ? r2_out : reg_read_addr_x == 3'b011 ? r3_out : reg_read_addr_x == 3'b100 ? r4_out : reg_read_addr_x == 3'b101 ? r5_out : reg_read_addr_x == 3'b110 ? r6_out : r7_out);
    assign mux_op_b_out = mux_sel_op_b ? immediate_value : (reg_read_addr_y == 3'b000 ? r0_out : reg_read_addr_y == 3'b001 ? r1_out : reg_read_addr_y == 3'b010 ? r2_out : reg_read_addr_y == 3'b011 ? r3_out : reg_read_addr_y == 3'b100 ? r4_out : reg_read_addr_y == 3'b101 ? r5_out : reg_read_addr_y == 3'b110 ? r6_out : r7_out);
    wire [15:0] mux_bus_out = (reg_read_addr_x == 3'b000 ? r0_out : reg_read_addr_x == 3'b001 ? r1_out : reg_read_addr_x == 3'b010 ? r2_out : reg_read_addr_x == 3'b011 ? r3_out : reg_read_addr_x == 3'b100 ? r4_out : reg_read_addr_x == 3'b101 ? r5_out : reg_read_addr_x == 3'b110 ? r6_out : r7_out);
    assign bus = bus_output_enable ? mux_bus_out : 16'hZZZZ;
    
endmodule