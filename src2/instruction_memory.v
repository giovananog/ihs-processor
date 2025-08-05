module instruction_memory(input wire [15:0] address, output reg [15:0] instruction);
    reg [15:0] rom [0:15]; 
    initial begin
        rom[0] <= 16'b101_000_0000000101; // 0: ldi r0, #5
        rom[1] <= 16'b101_001_0000000011; // 1: ldi r1, #3
        rom[2] <= 16'b101_010_0000000000; // 2: ldi r2, #0
        rom[3] <= 16'b000_010_000_0000000; // 3: add r2, r0
        rom[4] <= 16'b101_011_0000000001; // 4: ldi r3, #1
        rom[5] <= 16'b001_001_011_0000000; // 5: sub r1, r3
        rom[6] <= 16'b110_001_1111111101; // 6: bne r1, #-3
        rom[7] <= 16'b100_010_0000000000; // 7: out r2
        rom[8] <= 16'b110_000_1111111111; // 8: bne r0, #-1
        rom[9]  <= 16'h0000; rom[10] <= 16'h0000; rom[11] <= 16'h0000;
        rom[12] <= 16'h0000; rom[13] <= 16'h0000; rom[14] <= 16'h0000; rom[15] <= 16'h0000;
    end
    always @(*) instruction = rom[address];
endmodule