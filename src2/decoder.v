module decoder(input wire [2:0] reg_addr, output reg [7:0] enable_mask);
    always @(*) begin
        case (reg_addr)
            3'b000: enable_mask = 8'b10000000; 3'b001: enable_mask = 8'b01000000;
            3'b010: enable_mask = 8'b00100000; 3'b011: enable_mask = 8'b00010000;
            3'b100: enable_mask = 8'b00001000; 3'b101: enable_mask = 8'b00000100;
            3'b110: enable_mask = 8'b00000010; 3'b111: enable_mask = 8'b00000001;
            default: enable_mask = 8'b00000000;
        endcase
    end
endmodule