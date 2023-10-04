`timescale 1ns/1ps
module msb_test;
    integer i=0;
    logic [31:0] x;
    logic[31:0] result;
    logic clk,rst;
    logic detected;
    //msb_comb test1(.x(x), .msb(result));
    //msb_multi test2(.clk(clk),.rst(rst),.x(x),.msb(result));
    msb_pipeline test3(.clk(clk),.rst(rst),.argument(x),.msb(result));
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
        x=4;
        #2
        x=8;
        #2
        x=16;
        #2
        x=32;
        #2
        x=64;
        #2
        x=128;
        #2
        x=256;
        #2
        x=512;
        #2
        x=1024;
        #20
        
//        for(int i=0;i<16;i=i+1)
//        begin
//            x = i*i;
//            #2000 $monitor("value: %d,msb: %d, detected: %b",x, result,detected);            
//        end        
        //$monitor("value: %d,msb: %d, detected: %b",x, result,detected);
//       #100 
//        $monitor("value: %d,msb: %d",x, result);
//        #10;
//        #10 rst = 1;
//        #100 rst = 0;
        $finish;
    end
endmodule