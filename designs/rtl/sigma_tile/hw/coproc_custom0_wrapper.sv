`include "coproc_if.svh"

module coproc_custom0_wrapper (
	input logic unsigned [0:0] clk_i
	, input logic unsigned [0:0] rst_i
	, output logic unsigned [0:0] stream_resp_bus_genfifo_req_o
	, output resp_struct stream_resp_bus_genfifo_wdata_bo
	, input logic unsigned [0:0] stream_resp_bus_genfifo_ack_i
	, input logic unsigned [0:0] stream_req_bus_genfifo_req_i
	, input req_struct stream_req_bus_genfifo_rdata_bi
	, output logic unsigned [0:0] stream_req_bus_genfifo_ack_o
);

assign stream_req_bus_genfifo_ack_o = stream_req_bus_genfifo_req_i;

logic unsigned [0:9][31:0] elem;
//elem[] = {a,b,c,d,e,f,g,h,K,W}
logic unsigned [31:0] s0,s1,ch,t1,t2,maj;
logic update1, update2;  
logic unsigned [31:0] sum0,sum1;
logic unsigned [4:0] index;  
always @*
    begin
    if (update1 == 1)
        begin
        stream_resp_bus_genfifo_wdata_bo = sum0+sum1;
        update1 = 0;
        end
    end        
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

always @(posedge clk_i)
    begin
    if (rst_i)
        begin
        stream_resp_bus_genfifo_req_o <= 1'b0;
        for (index=0;index<10;index=index+1)
            begin
            elem[index]<=0;
            end
        s0 <= 0;
        s1 <= 0;
        ch <= 0;
        t1 <= 0;
        t2 <= 0;
        maj <= 0;
        update1<=0;
        update2<=0;
        sum0<=0;
        sum1<=0;
        end
    else
        if(update2 == 1)
            begin
            elem[7] <= elem[6];
            elem[6] <= elem[5];
            elem[5] <= elem[4];
            elem[4] <= elem[3] + t1;
            elem[3] <= elem[2];
            elem[2] <= elem[1];
            elem[1] <= elem[0];
            elem[0] <= t1+t2;
            update2 <= 0; 
            end
        begin
        if(stream_req_bus_genfifo_rdata_bi.instr_code[31:25] == 7'h0)
            begin
            sum0 <= {stream_req_bus_genfifo_rdata_bi.src0_data[6:0],stream_req_bus_genfifo_rdata_bi.src0_data[31:7]}^
                {stream_req_bus_genfifo_rdata_bi.src0_data[17:0],stream_req_bus_genfifo_rdata_bi.src0_data[31:18]}^
                (stream_req_bus_genfifo_rdata_bi.src0_data>>3);
            sum1 <= {stream_req_bus_genfifo_rdata_bi.src1_data[16:0],stream_req_bus_genfifo_rdata_bi.src1_data[31:17]}^
                {stream_req_bus_genfifo_rdata_bi.src1_data[18:0],stream_req_bus_genfifo_rdata_bi.src1_data[31:19]}^
                (stream_req_bus_genfifo_rdata_bi.src1_data>>10);
            update1 <= 1;
            stream_resp_bus_genfifo_req_o <= 1'b1;         
            end
        else if(stream_req_bus_genfifo_rdata_bi.instr_code[31:25] <= 7'h5)
            begin
            elem[(stream_req_bus_genfifo_rdata_bi.instr_code[31:25]<<1) - 2] <=  stream_req_bus_genfifo_rdata_bi.src0_data;
            elem[(stream_req_bus_genfifo_rdata_bi.instr_code[31:25]<<1) - 1] <=  stream_req_bus_genfifo_rdata_bi.src1_data;      
            if(stream_req_bus_genfifo_rdata_bi.instr_code[31:25] == 7'h5) update2 <= 1;
            stream_resp_bus_genfifo_req_o <= 1'b1;
            end   
        else if (stream_req_bus_genfifo_rdata_bi.instr_code[31:25] > 7'h5)
            begin
            stream_resp_bus_genfifo_wdata_bo <= elem[stream_req_bus_genfifo_rdata_bi.instr_code[31:25]-6];
            stream_resp_bus_genfifo_req_o <= 1'b1;
            end                      
        end
    end
    
endmodule

//logic unsigned [31:0] s0,s1;
//assign stream_resp_bus_genfifo_wdata_bo = s0+s1;
//always @(posedge clk_i)
//    begin
//    if (rst_i)
//        begin
//        s0<=0;
//        s1<=1;
//        end
//    else
//        begin
//        s0 <= {stream_req_bus_genfifo_rdata_bi.src0_data[6:0],stream_req_bus_genfifo_rdata_bi.src0_data[31:7]}^
//            {stream_req_bus_genfifo_rdata_bi.src0_data[17:0],stream_req_bus_genfifo_rdata_bi.src0_data[31:18]}^
//            (stream_req_bus_genfifo_rdata_bi.src0_data>>3);
//        s1 <= {stream_req_bus_genfifo_rdata_bi.src1_data[16:0],stream_req_bus_genfifo_rdata_bi.src1_data[31:17]}^
//            {stream_req_bus_genfifo_rdata_bi.src1_data[18:0],stream_req_bus_genfifo_rdata_bi.src1_data[31:19]}^
//            (stream_req_bus_genfifo_rdata_bi.src1_data>>10);
//         stream_resp_bus_genfifo_req_o <= 1'b1;
//        end       
//    end
//endmodule
