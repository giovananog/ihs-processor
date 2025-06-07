16bit processor implementation with verilog



-------
runnning:

cd src
iverilog -o a.out testbench.v
vvp a.out
gtkwave testbench.vcd