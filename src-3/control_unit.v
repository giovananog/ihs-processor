// control_unit.v

module control_unit(
    input wire clock,             
    input wire resetn,            
    input wire [15:0] instruction, 

    output wire reg_file_master_enable, 
    output wire reg_a_enable,         
    output wire reg_r_enable,         
    output wire [7:0] reg_file_write_enable_mask, 
    output wire [2:0] alu_op_code,    
    output wire mux_sel_op_a,         
    output wire mux_sel_op_b,         
    output wire bus_mux_select,       
    output wire mux_sel_reg_file_data_in, 
    
    output wire [2:0] reg_read_addr_x,  
    output wire [2:0] reg_read_addr_y,  
    output wire [2:0] reg_write_addr,   
    output wire clear_counter,        
    output wire bus_output_enable     
);

    // Opcodes e ALU_OP_CODES
    parameter OP_ADD = 3'b000; parameter OP_SUB = 3'b001; parameter OP_NAN = 3'b010;
    parameter OP_OUT = 3'b100; parameter OP_LDI = 3'b101; parameter OP_REP = 3'b111;
    parameter ALU_ADD = 3'b000; parameter ALU_SUB = 3'b001; parameter ALU_NAN = 3'b010;
    parameter ALU_PASS_A = 3'b011; parameter ALU_PASS_B = 3'b100;

    // Sinais internos: registrador de estado (contador de ciclo)
    reg [1:0] current_state_reg; 

    // Lógica do Contador de Ciclo (agora interna à UC)
    always @(posedge clock or negedge resetn) begin
        if (!resetn) begin
            current_state_reg <= 2'b00;
        end else if (clear_counter_internal) begin 
            current_state_reg <= 2'b00;
        end else begin
            current_state_reg <= current_state_reg + 1'b1;
        end
    end

    // Derivação de opcode e endereços 
    wire [2:0] opcode = instruction[15:13];
    assign reg_read_addr_x = instruction[12:10];
    assign reg_write_addr = instruction[12:10];
    assign reg_read_addr_y = instruction[9:7];

    // Instanciação do decoder 
    decoder write_decoder_inst (
        .reg_addr(reg_write_addr),
        .enable_mask(reg_file_write_enable_mask)
    );

    assign reg_a_enable = (current_state_reg == 2'b01);
    assign reg_r_enable = (current_state_reg == 2'b10) ? ((opcode != OP_OUT) ? 1'b1 : 1'b0) : 1'b0;

    assign alu_op_code = (current_state_reg == 2'b10) ? (
                            (opcode == OP_ADD) ? ALU_ADD :
                            (opcode == OP_SUB) ? ALU_SUB :
                            (opcode == OP_NAN) ? ALU_NAN :
                            (opcode == OP_LDI) ? ALU_PASS_A :
                            (opcode == OP_REP) ? ALU_PASS_B :
                            ALU_ADD // Default para OP_OUT ou outros não definidos
                         ) : 3'b000; // Default para outros ciclos

    assign mux_sel_op_a = (current_state_reg == 2'b01) ? ((opcode == OP_LDI) ? 1'b1 : 1'b0) : 1'b0;
    assign mux_sel_op_b = (current_state_reg == 2'b10) ? (
                            (opcode == OP_LDI) ? 1'b1 : 
                            1'b0 // 
                         ) : 1'b0;

    assign bus_output_enable = (current_state_reg == 2'b11 && opcode == OP_OUT);
    assign bus_mux_select = (current_state_reg == 2'b11 && opcode == OP_OUT) ? 1'b0 : 1'b0; 

    assign reg_file_master_enable = (current_state_reg == 2'b11 && opcode != OP_OUT);
    assign mux_sel_reg_file_data_in = (current_state_reg == 2'b11 && opcode == OP_LDI);

    wire clear_counter_internal = (current_state_reg == 2'b11); 

endmodule