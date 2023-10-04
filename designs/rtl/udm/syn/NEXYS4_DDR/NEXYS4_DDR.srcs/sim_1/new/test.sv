`timescale 1ns/1ps
module msb_test;
    integer i=0;
    logic [31:0] x;
    logic[31:0] result;
    logic clk,rst;
    lsb_pipeline test3(.clk(clk),.rst(rst),.argument(x),.lsb(result));
    initial
    begin
        clk = 1;
        forever #1 clk = ~clk;
    end
    initial begin    
        rst = 1;
        #2;
        rst = 0;
        #2;
        x=1;
        #2
        x=2;
        #2
        x=6;
        #2
        x=11;
        #2
        x=19;
        #2
        x=39;
        #2
        x=71;
        #2
        x=143;
        #2
        x=287;
        #2
        x=575;
        #2
        x=1087;
        #20
        $finish;
    end
endmodule
