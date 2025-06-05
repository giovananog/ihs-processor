// testbench.v
// Testbench para simular o processador.

`include "counter.v"
`include "register.v"
`include "signal_extender.v"
`include "alu.v"
`include "decoder.v"
`include "control_unit.v"
`include "processor.v" 

module testbench;
    // Sinais de entrada do processador
    reg clock = 1'b0;      
    reg [15:0] iin;        
    reg resetn = 1'b1;     
    wire [15:0] bus;       

    processor p(
        .clock(clock),
        .iin(iin),
        .resetn(resetn),
        .bus(bus)
    );

    always #1 clock = !clock;

    initial begin
        // GTKWave
        $dumpfile("testbench.vcd"); 
        $dumpvars(0, testbench);    

        resetn = 1'b0; 
        #8 resetn = 1'b1;

        // Instrução 1: ldi r0, #28 (101 000 0000011100)
        // Carregada em iin no tempo 8 (após o reset)
        iin = 16'b1010000000011100; 
        #8; 

        // Instrução 2: ldi r1, #10 (101 001 0000001010)
        // Carregada em iin no tempo 16
        iin = 16'b1010010000001010; 
        #8; 

        // Instrução 3: sub r0, r1 (001 000 001 0000000)
        // Carregada em iin no tempo 24
        iin = 16'b0010000010000000;
        #8; 

        // Instrução 4: out r0 (100 000 0000000000)
        // Carregada em iin no tempo 32
        iin = 16'b1000000000000000;
        #8;

        $finish; 
    end

endmodule