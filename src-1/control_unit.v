// control_unit.v
module control_unit(
    input wire clock,             
    input wire resetn,            
    input wire [15:0] instruction, // input wire diretamente
    input wire [1:0] current_state, 

    output reg reg_a_enable,         
    output reg reg_r_enable,         
    output wire [7:0] reg_file_write_enable_mask, 
    output reg [2:0] alu_op_code,    
    output reg mux_sel_op_a,         
    output reg mux_sel_op_b,         
    output reg bus_mux_select,       
    output reg [2:0] reg_read_addr_x,  
    output reg [2:0] reg_read_addr_y,  
    output reg [2:0] reg_write_addr,   
    output reg clear_counter,        
    output reg bus_output_enable     
);

    // Opcodes e ALU_OP_CODES
    parameter OP_ADD = 3'b000; parameter OP_SUB = 3'b001; parameter OP_NAN = 3'b010;
    parameter OP_OUT = 3'b100; parameter OP_LDI = 3'b101; parameter OP_REP = 3'b111;
    parameter ALU_ADD = 3'b000; parameter ALU_SUB = 3'b001; parameter ALU_NAN = 3'b010;
    parameter ALU_PASS_A = 3'b011; parameter ALU_PASS_B = 3'b100;

    wire [2:0] opcode = instruction[15:13]; // Deriva opcode diretamente do input wire

    decoder write_decoder_inst (
        .reg_addr(reg_write_addr),
        .enable_mask(reg_file_write_enable_mask)
    );

    // always @(posedge clock or negedge resetn) begin
    //     if (!resetn) begin 
    //         // Reset de todos os outputs regs e regs internos
    //         reg_a_enable = 1'b0; reg_r_enable = 1'b0; alu_op_code = ALU_ADD; 
    //         mux_sel_op_a = 1'b0; mux_sel_op_b = 1'b0; bus_mux_select = 1'b0;
    //         reg_read_addr_x = 3'b0; reg_read_addr_y = 3'b0; reg_write_addr = 3'b0; 
    //         clear_counter = 1'b0; bus_output_enable = 1'b0;
    //         // Não há opcode_reg, pois opcode é wire
    //     end else begin
    //         // Default para cada output reg em cada ciclo
    //         reg_a_enable = 1'b0; reg_r_enable = 1'b0; clear_counter = 1'b0;
    //         bus_output_enable = 1'b0; bus_mux_select = 1'b0; 
    //         alu_op_code = ALU_ADD; // Valor padrão para ULA (neutro, será sobrescrito no Ciclo 2)
    //         mux_sel_op_a = 1'b0; mux_sel_op_b = 1'b0; // Default para MUXes

    //         // Atribuições combinacionais de endereços
    //         reg_read_addr_x = instruction[12:10];
    //         reg_write_addr = instruction[12:10];
    //         reg_read_addr_y = instruction[9:7]; 

    //         case (current_state)
    //             2'b00: begin // Ciclo 0
    //                 // $display("Time=%0t (Ciclo 0): instruction=%b, opcode=%b.", $time, instruction, opcode); 
    //             end

    //             2'b01: begin // Ciclo 1: Carrega o primeiro operando no Registrador A
    //                 reg_a_enable = 1'b1; // ATIVADO
    //                 case (opcode)
    //                     OP_LDI: mux_sel_op_a = 1'b1; // LDI: Seleciona Imediato
    //                     default: mux_sel_op_a = 1'b0; // Outros: Seleciona Rx
    //                 endcase
    //                 //$display("Time=%0t (Ciclo 1): mux_sel_op_a=%b, opcode=%b.", $time, mux_sel_op_a, opcode); 
    //             end

    //             2'b10: begin // Ciclo 2: Executa a ULA e armazena o resultado no Registrador R
    //                 reg_r_enable = 1'b1; // Habilita a escrita no Registrador R (será desabilitado para OP_OUT)

    //                 //$display("Time=%0t (Ciclo 2): current_state=%b, instruction=%b, opcode=%b.", $time, current_state, instruction, opcode); 

    //                 case (opcode) // AGORA o opcode é o wire diretamente do instruction input
    //                     OP_ADD:  begin alu_op_code = ALU_ADD; mux_sel_op_b = 1'b0; /*$display("  -> OP_ADD");*/ end 
    //                     OP_SUB:  begin alu_op_code = ALU_SUB; mux_sel_op_b = 1'b0; /*$display("  -> OP_SUB");*/ end 
    //                     OP_NAN:  begin alu_op_code = ALU_NAN; mux_sel_op_b = 1'b0; /*$display("  -> OP_NAN");*/ end 
    //                     OP_LDI:  begin alu_op_code = ALU_PASS_A; mux_sel_op_b = 1'b1; /*$display("  -> OP_LDI (mux_sel_op_b=1)");*/ end 
    //                     OP_REP:  begin alu_op_code = ALU_PASS_B; mux_sel_op_b = 1'b0; /*$display("  -> OP_REP");*/ end 
    //                     OP_OUT:  begin // OP_OUT não usa R nem a ULA para resultado
    //                         reg_r_enable = 1'b0; 
    //                         alu_op_code = ALU_ADD; // Valor neutro
    //                         mux_sel_op_b = 1'b0;   // Valor neutro
    //                         //$display("  -> OP_OUT"); 
    //                     end
    //                     default: begin 
    //                         alu_op_code = 3'b111; // DEBUG: Valor distinto para default
    //                         mux_sel_op_b = 1'b0; 
    //                         reg_r_enable = 1'b0; 
    //                         //$display("  -> DEFAULT opcode: %b", opcode); 
    //                     end
    //                 endcase
    //             end

    //             2'b11: begin // Ciclo 3: Escreve o resultado final no registrador de destino ou no Bus
    //                 clear_counter = 1'b1; // Limpa o contador
    //                 // $display("Ciclo 3: Time=%0t: reg_r_enable=%b, reg_file_write_enable_mask=%h", $time, reg_r_enable, reg_file_write_enable_mask);    

    //                 case (opcode)
    //                     OP_ADD, OP_SUB, OP_NAN, OP_LDI, OP_REP: begin 
    //                         // Escrita no RegFile já é habilitada
    //                     end
    //                     OP_OUT: begin
    //                         bus_output_enable = 1'b1; 
    //                         bus_mux_select = 1'b0; 
    //                         // $display("Time=%0t (Ciclo 3): OP_OUT. bus_output_enable=%b.", $time, bus_output_enable);
    //                     end
    //                     default: begin bus_output_enable = 1'b0; end       
    //                 endcase
    //             end
    //         endcase
    //     end
    // end

    
    // control_unit.v
// ... (rest of the code)

always @(posedge clock or negedge resetn) begin
    if (!resetn) begin
        // Reset mais completo
        reg_a_enable <= 1'b0;
        reg_r_enable <= 1'b0;
        alu_op_code <= 3'b000;
        mux_sel_op_a <= 1'b0;
        mux_sel_op_b <= 1'b0;
        bus_mux_select <= 1'b0;
        reg_read_addr_x <= 3'b000;
        reg_read_addr_y <= 3'b000;
        reg_write_addr <= 3'b000;
        clear_counter <= 1'b0;
        bus_output_enable <= 1'b0;
    end
    else begin
        // Valores padrão para cada ciclo
        reg_a_enable <= 1'b0;
        reg_r_enable <= 1'b0;
        clear_counter <= 1'b0;
        bus_output_enable <= 1'b0;
        
        // Atualiza endereços dos registradores
        reg_read_addr_x <= instruction[12:10];
        reg_write_addr <= instruction[12:10];
        reg_read_addr_y <= instruction[9:7];
        
        case (current_state)
            2'b00: begin // Ciclo 0 - Fetch
                // Nada a fazer além de decodificar
            end
            
            2'b01: begin // Ciclo 1 - Decode/Operand Fetch
                reg_a_enable <= 1'b1;
                mux_sel_op_a <= (opcode == OP_LDI) ? 1'b1 : 1'b0;
            end
            
            2'b10: begin // Ciclo 2 - Execute
                reg_r_enable <= (opcode != OP_OUT);
                
                case (opcode)
                    OP_ADD: begin alu_op_code <= ALU_ADD; mux_sel_op_b <= 1'b0; end
                    OP_SUB: begin alu_op_code <= ALU_SUB; mux_sel_op_b <= 1'b0; end
                    OP_NAN: begin alu_op_code <= ALU_NAN; mux_sel_op_b <= 1'b0; end
                    OP_LDI: begin alu_op_code <= ALU_PASS_A; mux_sel_op_b <= 1'b1; end
                    OP_REP: begin alu_op_code <= ALU_PASS_B; mux_sel_op_b <= 1'b0; end
                    OP_OUT: begin alu_op_code <= ALU_ADD; mux_sel_op_b <= 1'b0; end // Não usado
                    default: begin alu_op_code <= 3'b000; mux_sel_op_b <= 1'b0; end
                endcase
            end
            
            2'b11: begin // Ciclo 3 - Write Back
                clear_counter <= 1'b1;
                if (opcode == OP_OUT) begin
                    bus_output_enable <= 1'b1;
                    bus_mux_select <= 1'b0;
                end
            end
        endcase
    end
end

endmodule