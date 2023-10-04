/*
 * tb.v
 *
 *  Created on: 17.10.2019
 *      Author: Alexander Antonov <antonov.alex.alex@gmail.com>
 *     License: See LICENSE file for details
 */


`timescale 1ns / 1ps

`define HALF_PERIOD			5						//external 100 MHZ
`define DIVIDER_115200		32'd8680
`define DIVIDER_19200		32'd52083
`define DIVIDER_9600		32'd104166
`define DIVIDER_4800		32'd208333
`define DIVIDER_2400		32'd416666


module tb ();
//
logic CLK_100MHZ, RST, rx;
logic [15:0] SW;
logic [15:0] LED;

//logic [31:0] len;
//logic [7:0] data_q0;
//logic ap_done;
//logic [4 : 0] hash_address0;
//logic [4 : 0] hash_address1;
//logic [7 : 0] hash_d0;
//logic [7 : 0] hash_d1;
//logic hash_ce0;
//logic hash_ce1;
//logic hash_we0;
//logic hash_we1;  
//logic data_ce0;
//logic ap_start;
//logic ap_idle,ap_ready;
//logic [7:0] data_address0;

always #`HALF_PERIOD CLK_100MHZ = ~CLK_100MHZ;

always #1000 SW = SW + 8'h1;
	
NEXYS4_DDR
#(
	.SIM("YES")
) DUT (
	.CLK100MHZ(CLK_100MHZ)
    , .CPU_RESETN(!RST)
    
    , .SW(SW)
    , .LED(LED)

    , .UART_TXD_IN(rx)
    , .UART_RXD_OUT()
//    ,  .len(len),
//        .ap_done(ap_done),
//        .ap_ready(ap_ready),
//        .ap_idle(ap_idle),
//        .ap_start(ap_start),
//        .hash_d0(hash_d0),
//        .hash_d1(hash_d1),
//        .hash_address0(hash_address0),
//        .hash_address1(hash_address1),
//        .hash_ce0(hash_ce0),
//        .hash_ce1(hash_ce1),
//        .hash_we0(hash_we0),
//        .hash_we1(hash_we1),
//        .data_ce0(data_ce0),
//        .data_q0(data_q0),
//        .data_address0(data_address0)
);

////reset all////
task RESET_ALL ();
    begin
    CLK_100MHZ = 1'b0;
    RST = 1'b1;
    rx = 1'b1;
    #(`HALF_PERIOD/2);
    RST = 1;
    #(`HALF_PERIOD*6);
    RST = 0;
    while (DUT.srst) WAIT(10);
    end
endtask

////wait////
task WAIT
    (
     input logic [15:0] periods
     );
    begin
    integer i;
    for (i=0; i<periods; i=i+1)
        begin
        #(`HALF_PERIOD*2);
        end
    end
endtask

`define UDM_RX_SIGNAL rx
`define UDM_BLOCK DUT.udm
`include "udm.svh"
udm_driver udm;

/////////////////////////
// main test procedure //
localparam CSR_LED_ADDR         = 32'h00000000;
localparam CSR_SW_ADDR          = 32'h00000004;
localparam TESTMEM_ADDR         = 32'h80000000;

string data;
logic [32:0]strlen;

initial
    begin
    logic [31:0] wrdata [];
    integer ARRSIZE=10;
    
	$display ("### SIMULATION STARTED ###");
	
	SW = 8'h30;
	RESET_ALL();
	WAIT(100);

	udm.cfg(`DIVIDER_115200, 2'b00);
	udm.check();
	udm.hreset();
	WAIT(100);
	
	// memory initialization
//	udm.wr32(32'h80000000, 32'h112233cc);
//	udm.wr32(32'h80000004, 32'h55aa55aa);
//	udm.wr32(32'h80000008, 32'h01010202);
//	udm.wr32(32'h8000000C, 32'h44556677);
//	udm.wr32(32'h80000010, 32'h00000003);
//	udm.wr32(32'h80000014, 32'h00000004);
//	udm.wr32(32'h80000018, 32'h00000005);
//	udm.wr32(32'h8000001C, 32'h00000006);
//	udm.wr32(32'h80000020, 32'h00000007);
//	udm.wr32(32'h80000024, 32'hdeadbeef);
//	udm.wr32(32'h80000028, 32'hfefe8800);
//	udm.wr32(32'h8000002C, 32'h23344556);
//	udm.wr32(32'h80000030, 32'h05050505);
//	udm.wr32(32'h80000034, 32'h07070707);
//	udm.wr32(32'h80000038, 32'h99999999);
//	udm.wr32(32'h8000003C, 32'hbadc0ffe);
	//write data 0x00000155
	
	data = "Hello";
	strlen = data.len();
	
	udm.wr32(32'h10000000, strlen);
	WAIT(2);
	for(int i=0;i<strlen;i++)
	begin
	   udm.wr32(32'h20000000, data[i]);
	   WAIT(2);	   
	end

	// writing to LED
	//udm.wr32(32'h00000000, 32'h5a5a5a5a);
	
	// reading SW
	//udm.rd32(32'h00000004);
	//read mem
	
	WAIT(500);
	for(int i=0;i<32;i++)
	begin
		udm.rd32(32'h30000000);
		WAIT(2);
    end    
    
    WAIT(500);
    
    data = "Hello World!";
	strlen = data.len();
	
	udm.wr32(32'h10000000, strlen);
	WAIT(2);
	for(int i=0;i<strlen;i++)
	begin
	   udm.wr32(32'h20000000, data[i]);
	   WAIT(2);	   
	end
    
    WAIT(500);
	for(int i=0;i<32;i++)
	begin
		udm.rd32(32'h30000000);
		WAIT(2);
    end  
    
	WAIT(10);
	
	

	$display ("### TEST PROCEDURE FINISHED ###");
	$stop;
    end


endmodule
