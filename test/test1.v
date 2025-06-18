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
      $dumpfile("testbench.vcd");
      $dumpvars(0, testbench);

      resetn = 1'b0;
      #2 resetn = 1'b1;

      #8 iin = 16'b1010000000001010;  // ldi r0, #10
      #8 iin = 16'b1010010000000101;  // ldi r1, #5
      #8 iin = 16'b0000100001000000;  // add r2, r0
      #8 iin = 16'b1000100000000000;  // out r2
      #8 $finish;
    end


endmodule