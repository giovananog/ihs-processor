// decoder.v

module decoder(
    input wire [2:0] reg_addr,     
    output reg [7:0] enable_mask   
);

    always @(*) begin 
        case (reg_addr)
            3'b000: enable_mask = 8'b00000001; // r0 - bit 0
            3'b001: enable_mask = 8'b00000010; // r1 - bit 1
            3'b010: enable_mask = 8'b00000100; // r2 - bit 2
            3'b011: enable_mask = 8'b00001000; // r3 - bit 3
            3'b100: enable_mask = 8'b00010000; // r4 - bit 4
            3'b101: enable_mask = 8'b00100000; // r5 - bit 5
            3'b110: enable_mask = 8'b01000000; // r6 - bit 6
            3'b111: enable_mask = 8'b10000000; // r7 - bit 7
            default: enable_mask = 8'b00000000; // invalid
        endcase
    end

endmodule