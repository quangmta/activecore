//module anlz_byte_mul
//(
//    input logic clk,
//    input logic rst,
//    input logic[31:0] src_byte,
//    output logic[5:0] msb,
//    output logic msb_detected
//);
//    localparam CSTEP_NUM = 8;
//    logic[31:0] wrk_byte;
//    logic [5:0] msb_next;
//    logic msb_detected_next;
//    logic [2:0] cstep_counter,cstep_counter_next;
//    logic [4:0] current_msb,current_msb_next;
//    logic current_msb_detected,current_msb_detected_next;

//    always @(posedge clk)
//    begin
//        if(rst)
//            begin
//                cstep_counter <= 0;
//                current_msb <= 0 ;
//                current_msb_detected <= 0;
//                msb <= 0;
//                msb_detected <= 0;  
//            end
//        else
//            begin
//                cstep_counter <= cstep_counter_next;
//                current_msb <= current_msb_next;
//                current_msb_detected <= current_msb_detected_next;
//                msb <= msb_next;
//                msb_detected <= msb_detected_next;                
//            end
//    end
//    always @*
//        begin
//            //default values assignments
//            cstep_counter_next = cstep_counter;
//            current_msb_next = current_msb;
//            current_msb_detected_next = current_msb_detected;
//            msb_next = msb;
//            msb_detected_next = msb_detected; 
//            if (cstep_counter_next == 0)
//                wrk_byte = src_byte;                   

//            //subcomputation on current cstep
//            if((wrk_byte & 4'h1) != 0)
//            begin
//                current_msb_detected_next = 1;
//                current_msb_next = cstep_counter_next;
//            end
            
//            //cstep processing
//            if (cstep_counter_next == (CSTEP_NUM-1))
//                begin
//                    msb_next = current_msb_next;
//                    msb_detected_next = current_msb_detected_next;
////                    current_msb_next = 0;
////                    current_msb_detected_next = 0;
//                    cstep_counter_next = 0;
//                end
//            else
//                begin
//                    cstep_counter_next = cstep_counter_next + 1;  
//                    wrk_byte = wrk_byte >> 1;                  
//                end
//        end
//endmodule

//module msb_mul
//(
//    input logic clk,
//    input logic rst,    
//    input logic [31:0] x,
//    output logic [5:0] msb
//);
//    logic [5:0] byte_msb [0:3] = {0,0,0,0};
//    logic [3:0] byte_msb_detected = {0,0,0,0};
//    localparam CSTEP_NUM = 4;
//    logic [5:0] msb_next;
//    logic [1:0] cstep_counter,cstep_counter_next;
//    logic [4:0] current_msb,current_msb_next;
//    anlz_byte_mul anlz_1(.clk(clk),.rst(rst),.src_byte((x>>0) & 32'hff),.msb(byte_msb[0]),.msb_detected((byte_msb_detected[0])));
//    anlz_byte_mul anlz_2(.clk(clk),.rst(rst),.src_byte((x>>8) & 32'hff),.msb(byte_msb[1]),.msb_detected((byte_msb_detected[1])));
//    anlz_byte_mul anlz_3(.clk(clk),.rst(rst),.src_byte((x>>16) & 32'hff),.msb(byte_msb[2]),.msb_detected((byte_msb_detected[2])));
//    anlz_byte_mul anlz_4(.clk(clk),.rst(rst),.src_byte((x>>24) & 32'hff),.msb(byte_msb[3]),.msb_detected((byte_msb_detected[3])));
    
//    always @*
//        begin
//            //default values assignments
//            cstep_counter_next = cstep_counter;
//            current_msb_next = current_msb;
//            msb_next = msb;
////            if(cstep_counter_next == 0)
////                msb = 0;               

//            //subcomputation on current cstep
//            if(byte_msb_detected[cstep_counter_next] != 0)
//                current_msb_next = byte_msb[cstep_counter_next]+(cstep_counter_next<<3);
            
//            //cstep processing
//            if (cstep_counter_next == (CSTEP_NUM-1))
//                begin
//                    msb_next = current_msb_next;
//                    cstep_counter_next = 0;
//                end
//            else
//                begin
//                    cstep_counter_next = cstep_counter_next + 1;                   
//                end
//        end
    
//    always @(posedge clk)
//    begin
//        if(rst)
//            begin
//                cstep_counter <= 0;
//                current_msb <= 0 ;
//                msb <= 0; 
//            end
//        else
//            begin
//                cstep_counter <= cstep_counter_next;
//                current_msb <= current_msb_next;
//                msb <= msb_next;              
//            end
//    end    
//endmodule

module msb_multi
(
    input logic clk,
    input logic rst,    
    input logic [31:0] argument,
    output logic [31:0] msb
);
    localparam CSTEP_NUM = 32;
    logic [31:0] msb_next;
    logic [4:0] cstep_counter,cstep_counter_next;
    logic[31:0] wrk_byte;

    always @*
        begin
            //default values assignments
            cstep_counter_next = cstep_counter;
            msb_next = msb;
            if (cstep_counter_next == CSTEP_NUM-1)
                wrk_byte = argument;                   

            //subcomputation on current cstep
            if(wrk_byte[cstep_counter_next] == 1'h1)
            begin               
                msb_next = cstep_counter_next;
                cstep_counter_next = CSTEP_NUM-1;
            end
            else
                if(cstep_counter_next==0)
                    cstep_counter_next = CSTEP_NUM-1;
                else
                    cstep_counter_next = cstep_counter_next - 1;                
        end
    always @(posedge clk)
    begin
        if(rst)
            begin
                cstep_counter <= CSTEP_NUM-1;
                msb <= 0; 
            end
        else
            begin
                cstep_counter <= cstep_counter_next;
                msb <= msb_next;              
            end
    end    
endmodule