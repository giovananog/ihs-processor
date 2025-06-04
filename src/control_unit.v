// control_unit.v

module control_unit(
    input wire clock,             
    input wire resetn,            
    input wire [15:0] instruction, 
    input wire [1:0] current_state, 

    // Sinais de habilitação de registradores
    output reg reg_a_enable,         
    output reg reg_r_enable,         
    output wire [7:0] reg_file_write_enable_mask, // Máscara de habilitação para r0-r7 (SAÍDA do decoder)

    // Sinais da ULA
    output reg [2:0] alu_op_code,    // Seleção de operação da ULA (3 bits)

    // Sinais de seleção para MUXes
    output reg mux_sel_op_a,         // 0=RegX, 1=Immediate (para entrada do Reg A)
    output reg mux_sel_op_b,         // 0=RegY, 1=Immediate (para entrada B da ULA)
    output reg bus_mux_select,       // 0=RegX, 1=RegR (para Bus na instrução OUT)

    // Endereços de registradores para leitura e escrita
    output reg [2:0] reg_read_addr_x,  // Endereço de Rx (primeiro operando/destino)
    output reg [2:0] reg_read_addr_y,  // Endereço de Ry (segundo operando)
    output reg [2:0] reg_write_addr,   // Endereço do registrador de destino para escrita

    // Sinais de controle do contador e bus
    output reg clear_counter,        // Limpa o contador de ciclo
    output reg bus_output_enable     // Habilita a saída no Bus
);

    // Opcodes das instruções (bits 15:13 da instrução)
    parameter OP_ADD = 3'b000;
    parameter OP_SUB = 3'b001;
    parameter OP_NAN = 3'b010;
    parameter OP_OUT = 3'b100;
    parameter OP_LDI = 3'b101;
    parameter OP_REP = 3'b111;

    // Códigos de operação da ULA (definidos em alu.v)
    parameter ALU_ADD   = 3'b000;
    parameter ALU_SUB   = 3'b001;
    parameter ALU_NAN   = 3'b010;
    parameter ALU_PASS_A = 3'b011;
    parameter ALU_PASS_B = 3'b100;

    // Decodifica o opcode da instrução
    wire [2:0] opcode = instruction[15:13];

    // Instância do decoder para o registrador de escrita (reg_file_write_enable_mask é a saída)
    // A saída 'enable_mask' do decoder vai para o 'wire' reg_file_write_enable_mask.
    decoder write_decoder_inst (
        .reg_addr(reg_write_addr),
        .enable_mask(reg_file_write_enable_mask)
    );

    always @(posedge clock or negedge resetn) begin
        if (!resetn) begin // Reset Assíncrono (ativo baixo)
            // Define todos os sinais de controle para seus estados padrão/inativos
            reg_a_enable = 1'b0;
            reg_r_enable = 1'b0;
            // reg_file_write_enable_mask = 8'b0; // ESTA LINHA CAUSARIA PROBLEMA se reg_file_write_enable_mask fosse um reg.
                                               // Como agora é um wire, ele é guiado pelo decoder.
                                               // O reg_write_addr deve ser definido para 3'b000 no reset para que o decoder produza 10000000.
                                               // Para garantir que a máscara esteja toda em zero no reset,
                                               // o decoder precisaria de uma entrada de reset ou ser mais inteligente.
                                               // Por enquanto, vamos confiar que ao não habilitar nada, nenhum registrador escreverá.
            alu_op_code = ALU_ADD; // Valor padrão, pode ser qualquer um
            mux_sel_op_a = 1'b0;
            mux_sel_op_b = 1'b0;
            bus_mux_select = 1'b0;
            reg_read_addr_x = 3'b0;
            reg_read_addr_y = 3'b0;
            reg_write_addr = 3'b0; // Garante que o decoder veja um endereço válido no reset
            clear_counter = 1'b0;
            bus_output_enable = 1'b0;
        end else begin

            $display("DEBUG: OP_OUT value: %b (binary) / %0d (decimal)", OP_OUT, OP_OUT);
            // Por padrão, todos os enables e o clear_counter são desativados em cada ciclo,
            // e ativados apenas se necessário na lógica de 'case' abaixo.
            reg_a_enable = 1'b0;
            reg_r_enable = 1'b0;
            // reg_file_write_enable_mask = 8'b0; // REMOVIDO: Este é um wire guiado pelo decoder
            clear_counter = 1'b0;
            bus_output_enable = 1'b0;

            // Definir endereços de registradores lidos e escritos
            // Rx geralmente é o destino ou o primeiro operando
            reg_read_addr_x = instruction[12:10];
            reg_write_addr = instruction[12:10];

            // Ry geralmente é o segundo operando
            reg_read_addr_y = instruction[9:7]; // Para ADD, SUB, NAN, REP

            case (current_state)
                2'b00: begin // Ciclo 0: Decodificação da Instrução
                    
                end
                2'b01: begin // Ciclo 1: Carrega o primeiro operando no Registrador A
                    reg_a_enable = 1'b1; 
                    case (opcode)
                        OP_LDI: mux_sel_op_a = 1'b1; // Seleciona o valor imediato para o Reg A
                        OP_ADD, OP_SUB, OP_NAN, OP_REP, OP_OUT: mux_sel_op_a = 1'b0; // Seleciona Rx para o Reg A
                        default: mux_sel_op_a = 1'b0; // Default para segurança
                    endcase
                end
                2'b10: begin // Ciclo 2: Executa a ULA e armazena o resultado no Registrador R
                    reg_r_enable = 1'b1; 
                    $display("Time=%0t: Ciclo 2, Opcode=%b. Setting ALU_OP_CODE.", $time, opcode);

                    case (opcode)

                        3'b000: begin alu_op_code = ALU_ADD; mux_sel_op_b = 1'b0; end // OP_ADD
                        3'b001: begin alu_op_code = ALU_SUB; mux_sel_op_b = 1'b0; end // OP_SUB
                        3'b010: begin alu_op_code = ALU_NAN; mux_sel_op_b = 1'b0; end // OP_NAN
                        3'b101: begin alu_op_code = ALU_PASS_A; mux_sel_op_b = 1'b1; end // OP_LDI (mux_sel_op_b = 1'b1 CORRIGIDO)
                        3'b111: begin alu_op_code = ALU_PASS_B; mux_sel_op_b = 1'b0; end // OP_REP
                        3'b100: begin alu_op_code = ALU_PASS_A; mux_sel_op_b = 1'b0; end // OP_OUT
                        default: begin alu_op_code = 3'b111; mux_sel_op_b = 1'b0; end // 111
                        
                    endcase
                end
                2'b11: begin // Ciclo 3: Escreve o resultado final no registrador de destino ou no Bus
                    clear_counter = 1'b1; 

                    case (opcode)
                        OP_ADD, OP_SUB, OP_NAN, OP_LDI, OP_REP: begin end
                        OP_OUT: begin
                            bus_output_enable = 1'b1; 
                            bus_mux_select = 1'b0; 
                        end
                        default: begin end
                    endcase
                end
            endcase
        end
    end
endmodule