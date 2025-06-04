// register.v
module register #(parameter WIDTH = 16) (
    input wire clock,
    input wire resetn,      // <--- ADICIONE ESTA PORTA
    input wire enable,
    input wire [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    always @(posedge clock or negedge resetn) begin // <--- MODIFIQUE ESTA LINHA
        if (!resetn) begin // <--- ADICIONE ESTE BLOCO DE RESET
            data_out <= {WIDTH{1'b0}}; // Inicializa com zeros no reset
        end else if (enable == 1) begin
            data_out <= data_in;
        end
    end
endmodule