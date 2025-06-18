initial begin
  $dumpfile("testbench.vcd");
  $dumpvars(0, testbench);

  resetn = 1'b0;
  #2 resetn = 1'b1;

  #8 iin = 16'b1010110000000100;  // ldi r3, #4
  #8 iin = 16'b1011000000001010;  // ldi r4, #10
  #8 iin = 16'b0011010000110000;  // sub r5, r4
  #8 iin = 16'b1001010000000000;  // out r5
  #8 $finish;
end
