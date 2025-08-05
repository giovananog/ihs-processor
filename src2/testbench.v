`include "instruction_memory.v"
`include "register.v"
`include "signal_extender.v"
`include "alu.v"
`include "decoder.v"
`include "control_unit.v"
`include "processor.v" 

module testbench;
    reg clock = 1'b0; reg resetn = 1'b1; wire [15:0] bus;       
    processor p(.clock(clock), .resetn(resetn), .bus(bus));
    always #1 clock = !clock;
    initial begin
        $dumpfile("testbench_final.vcd"); $dumpvars(0, testbench);    
        resetn = 1'b0; #4; resetn = 1'b1;
        #300; $finish; 
    end
endmodule