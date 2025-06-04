// processor.v

module processor(
    input wire clock,      // Sinal de clock
    input wire [15:0] iin, // Entrada da instrução (Instruction Input)
    input wire resetn,     // Sinal de reset (ativo baixo)
    output wire [15:0] bus // Barramento de saída do processador
);

    // --- Sinais internos de comunicação entre módulos ---

    // Sinais do Contador
    wire [1:0] counter_out;     // Saída do contador de ciclo (00, 01, 10, 11)
    wire clear_counter;         // Sinal para limpar o contador (da Unidade de Controle)

    // Sinais do Extensor de Sinal
    wire [15:0] immediate_value; // Valor imediato estendido (saída do signal_extender)

    // Sinais do Registrador A
    wire [15:0] reg_a_out;       // Saída do Registrador A
    wire reg_a_enable;          // Habilitação de escrita para o Registrador A (da UC)

    // Sinais do Registrador R (Registrador de Resultado Temporário)
    wire [15:0] r_reg_out;       // Saída do Registrador R
    wire reg_r_enable;          // Habilitação de escrita para o Registrador R (da UC)

    // Sinais da ULA
    wire [15:0] alu_result;      // Resultado da operação da ULA
    wire [2:0] alu_op_code;     // Seleção de operação da ULA (da UC)

    // Sinais para o Banco de Registradores (r0-r7)
    wire [15:0] reg_data_out[7:0]; // Saídas dos 8 registradores (r0 a r7) - array de wires
    wire [7:0] reg_file_write_enable_mask; // Máscara de habilitação de escrita para r0-r7 (da UC via decoder)
    wire [15:0] reg_file_data_in; // <-- DECLARAÇÃO COMO WIRE
    assign reg_file_data_in = r_reg_out; // <-- ATRIBUIÇÃO VIA ASSIGN (CORRETO PARA WIRE)

    // Sinais de endereços de registradores (da UC)
    wire [2:0] reg_read_addr_x;  // Endereço de Rx para leitura
    wire [2:0] reg_read_addr_y;  // Endereço de Ry para leitura
    wire [2:0] reg_write_addr;   // Endereço de Rx para escrita

    // Sinais de seleção de MUXes (da UC)
    wire mux_sel_op_a;          // Seleção para MUX que alimenta Reg A (0=Rx, 1=Immediate)
    wire mux_sel_op_b;          // Seleção para MUX que alimenta ULA B (0=Ry, 1=Immediate)
    wire bus_mux_select;        // Seleção para MUX que alimenta o Bus (0=Rx, 1=R)

    // Sinais de controle gerais (da UC)
    wire bus_output_enable;     // Habilita a saída no Bus
    wire current_state = counter_out; // Apenas um wire para legibilidade

    // --- Instanciação dos Módulos ---

    // 1. Contador de Ciclo
    counter cycle_counter (
        .clock(clock),
        .clear(clear_counter),
        .out(counter_out)
    );

    // 2. Extensor de Sinal (para valor imediato)
    signal_extender immediate_ext (
        .instruction(iin),
        .immediate_value(immediate_value)
    );

    // // 3. Registrador A
    // register #(16) reg_a (
    //     .clock(clock),
    //     .enable(reg_a_enable),
    //     .data_in(mux_op_a_out), // Entrada do Reg A vem do MUX_op_a
    //     .data_out(reg_a_out)
    // );

    // // 4. Registrador R (Registrador de Resultado Temporário)
    // register #(16) reg_r (
    //     .clock(clock),
    //     .enable(reg_r_enable),
    //     .data_in(alu_result), // Entrada do Reg R vem do resultado da ULA
    //     .data_out(r_reg_out)
    // );


    register #(16) reg_a (
    .clock(clock),
    .resetn(resetn), // <--- ADICIONE ESTA CONEXÃO
    .enable(reg_a_enable),
    .data_in(mux_op_a_out),
    .data_out(reg_a_out)
    );

    register #(16) reg_r (
        .clock(clock),
        .resetn(resetn), // <--- ADICIONE ESTA CONEXÃO
        .enable(reg_r_enable),
        .data_in(alu_result),
        .data_out(r_reg_out)
    );

    // 5. Unidade Lógica Aritmética (ULA)
    alu alu_unit (
        .op_a(reg_a_out),     // Operando A sempre do Registrador A
        .op_b(mux_op_b_out),  // Operando B vem do MUX_op_b
        .op_select(alu_op_code),
        .result(alu_result)
    );

    // 6. Banco de Registradores (r0 a r7)
    // Instancia 8 módulos 'register' usando um loop 'generate'
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : reg_file_instance
            register #(16) r (
                .clock(clock),
                .resetn(resetn), // <--- ADICIONE ESTA CONEXÃO
                .enable(reg_file_write_enable_mask[i]),
                .data_in(reg_file_data_in),
                .data_out(reg_data_out[i])
            );
        end
    endgenerate


    // 7. Unidade de Controle
    control_unit control_unit_inst (
        .clock(clock),
        .resetn(resetn),
        .instruction(iin),
        .current_state(counter_out),
        .reg_a_enable(reg_a_enable),
        .reg_r_enable(reg_r_enable),
        .reg_file_write_enable_mask(reg_file_write_enable_mask), // Saída do decoder (interno à UC)
        .alu_op_code(alu_op_code),
        .mux_sel_op_a(mux_sel_op_a),
        .mux_sel_op_b(mux_sel_op_b),
        .bus_mux_select(bus_mux_select),
        .reg_read_addr_x(reg_read_addr_x),
        .reg_read_addr_y(reg_read_addr_y),
        .reg_write_addr(reg_write_addr),
        .clear_counter(clear_counter),
        .bus_output_enable(bus_output_enable)
    );

    // --- Implementação dos Multiplexadores (MUXes) ---

    // MUX para a entrada do Registrador A (seleciona entre Rx e Imediato)
    wire [15:0] mux_op_a_out;
    assign mux_op_a_out = mux_sel_op_a ? immediate_value : reg_data_out[reg_read_addr_x];

    // MUX para a entrada B da ULA (seleciona entre Ry e Imediato)
    wire [15:0] mux_op_b_out;
    assign mux_op_b_out = mux_sel_op_b ? immediate_value : reg_data_out[reg_read_addr_y];

    // MUX para o Barramento de Saída (seleciona entre Rx e R para instrução OUT)
    wire [15:0] mux_bus_out;
    assign mux_bus_out = bus_mux_select ? r_reg_out : reg_data_out[reg_read_addr_x];

    // Conexão final do Barramento (Bus)
    // O barramento sai em alta impedência (Z) quando não está habilitado para escrita.
    assign bus = bus_output_enable ? mux_bus_out : 16'hZZZZ;

    // initial begin
    // $monitor("Time=%0t: alu_result=%h, reg_r_enable=%b, r_reg_out=%h",
    //          $time, alu_result, reg_r_enable, r_reg_out);
    // end

endmodule