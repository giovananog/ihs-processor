// test2.v

`include "../src/counter.v"
`include "../src/register.v"
`include "../src/signal_extender.v"
`include "../src/alu.v"
`include "../src/decoder.v"
`include "../src/control_unit.v"
`include "../src/processor.v" 

module testbench;
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

      #8 iin = 16'b1010000000101010;  // ldi r0, #42
      #8 iin = 16'b1110010000000000;  // rep r1, r0
      #8 iin = 16'b1000010000000000;  // out r1
      #8 $finish;
    end


endmodule