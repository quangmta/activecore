/*
 * sigma.sv
 *
 *  Created on: 24.09.2017
 *      Author: Alexander Antonov <antonov.alex.alex@gmail.com>
 *     License: See LICENSE file for details
 */


`include "sigma_tile.svh"

module sigma
#(
	parameter CPU = "none"
	, UDM_BUS_TIMEOUT = (1024*1024*100)
	, UDM_RTX_EXTERNAL_OVERRIDE = "NO"
	, DEBOUNCER_FACTOR_POW = 20
	, delay_test_flag = 0
	, mem_init_type="elf"
	, mem_init_data = "data.elf"
	, mem_size = 1024
)
(
	input clk_i
	, input arst_i
	, input irq_btn_i
	, input rx_i
	, output tx_o
	, input [31:0] gpio_bi
	, output [31:0] gpio_bo
);

wire srst;
reset_sync reset_sync
(
	.clk_i(clk_i),
	.arst_i(arst_i),
	.srst_o(srst)
);

wire udm_reset;
wire cpu_reset;
assign cpu_reset = srst | udm_reset;

wire irq_btn_debounced;
debouncer
#(
    .FACTOR_POW(DEBOUNCER_FACTOR_POW)
) debouncer (
	.clk_i(clk_i)
	, .rst_i(srst)
	, .in(irq_btn_i)
	, .out(irq_btn_debounced)
);

MemSplit32 hif();
MemSplit32 xif();

sigma_tile #(
	.corenum(0)
	, .mem_init_type(mem_init_type)
	, .mem_init_data(mem_init_data)
	, .mem_size(mem_size)
	, .CPU(CPU)
	, .PATH_THROUGH("YES")
) sigma_tile (
	.clk_i(clk_i)
	, .rst_i(cpu_reset)

	, .irq_debounced_bi({0, irq_btn_debounced, 3'h0})
	
	, .hif(hif)
	, .xif(xif)
);
	
udm #(
    .BUS_TIMEOUT(UDM_BUS_TIMEOUT)
    , .RTX_EXTERNAL_OVERRIDE(UDM_RTX_EXTERNAL_OVERRIDE)
) udm (
	.clk_i(clk_i)
	, .rst_i(srst)

	, .rx_i(rx_i)
	, .tx_o(tx_o)

	, .rst_o(udm_reset)
	
	, .bus_req_o(hif.req)
	, .bus_we_o(hif.we)
	, .bus_addr_bo(hif.addr)
	, .bus_be_bo(hif.be)
	, .bus_wdata_bo(hif.wdata)
	, .bus_ack_i(hif.ack)
	, .bus_resp_i(hif.resp)
	, .bus_rdata_bi(hif.rdata)
);


localparam CSR_LED_ADDR         = 32'h80000000;
localparam CSR_SW_ADDR          = 32'h80000004;

logic [31:0] gpio_bo_reg;
assign gpio_bo = gpio_bo_reg;
logic [31:0] gpio_bi_reg;
always @(posedge clk_i) gpio_bi_reg <= gpio_bi;

assign xif.ack = xif.req;   // xif always ready to accept request
logic csr_resp;
logic [31:0] csr_rdata;

logic unsigned [0:9][31:0] elem;
//elem[] = {a,b,c,d,e,f,g,h,K,W}
logic unsigned [31:0] s0,s1,ch,t1,t2,maj;  
logic unsigned [31:0] sum0,sum1;
logic update;

always @*
    begin
    s1 = {elem[4][5:0],elem[4][31:6]}^{elem[4][10:0],elem[4][31:11]}^{elem[4][24:0],elem[4][31:25]};
    ch = (elem[4]&elem[5])^((~elem[4])&elem[6]);    
    t1 = elem[7] + s1 + ch + elem[8] + elem[9];
    end
always @*
    begin
    s0 = {elem[0][1:0],elem[0][31:2]}^{elem[0][12:0],elem[0][31:13]}^{elem[0][21:0],elem[0][31:22]};
    maj = (elem[0]&elem[1])^(elem[1]&elem[2])^(elem[2]&elem[0]);
    t2 = s0 + maj;
    end
// bus request
always @(posedge clk_i)
    begin
    
    csr_resp <= 1'b0;
    
    if (update == 1)
        begin
        elem[7] <= elem[6];
        elem[6] <= elem[5];
        elem[5] <= elem[4];
        elem[4] <= elem[3] + t1;
        elem[3] <= elem[2];
        elem[2] <= elem[1];
        elem[1] <= elem[0];
        elem[0] <= t1+t2; 
        update <= 0;        
        end
    
    if (xif.req && xif.ack)
        begin
        
        if (xif.we)     // writing
            begin
            if (xif.addr == CSR_LED_ADDR) gpio_bo_reg <= xif.wdata;
            
            if (xif.addr == 32'h80000100)
                begin
                sum0 <= {xif.wdata[6:0],xif.wdata[31:7]}^{xif.wdata[17:0],xif.wdata[31:18]}^(xif.wdata>>3);                
                end
            if (xif.addr == 32'h80000200)
                begin
                sum1 <= {xif.wdata[16:0],xif.wdata[31:17]}^{xif.wdata[18:0],xif.wdata[31:19]}^(xif.wdata>>10);                
                end  
                 
            if(xif.addr[15:12] == 4'h1)
                begin
                elem[xif.addr[11:8]] <=  xif.wdata;        
                if(xif.addr[11:8] == 4'h9) update <= 1;   
                end
                          
            end

        else            // reading
            begin
            if (xif.addr == CSR_LED_ADDR)
                begin
                csr_resp <= 1'b1;
                csr_rdata <= gpio_bo_reg;
                end
            if (xif.addr == CSR_SW_ADDR)
                begin
                csr_resp <= 1'b1;
                csr_rdata <= gpio_bi_reg;
                end
            if (xif.addr == 32'h80000300)
                begin
                csr_resp <= 1'b1;
                csr_rdata <= sum0+sum1;
                end
            if (xif.addr[15:12] == 4'h2)
                begin
                csr_resp <= 1'b1;
                csr_rdata <= elem[xif.addr[11:8]];
                end            
            end
        end
    end

// bus response
always @*
    begin
    xif.resp = csr_resp;
    xif.rdata = 0;
    if (csr_resp) xif.rdata = csr_rdata;
    end

endmodule
