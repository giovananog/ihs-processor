initial begin
  $dumpfile("testbench.vcd");
  $dumpvars(0, testbench);

  resetn = 1'b0;
  #2 resetn = 1'b1;

  #8 iin = 16'b1011100000001111;  // ldi r6, #15
  #8 iin = 16'b1011110011110000;  // ldi r7, #240
  #8 iin = 16'b0100001110000000;  // nan r0, r7
  #8 iin = 16'b1000000000000000;  // out r0
  #8 $finish;
end
