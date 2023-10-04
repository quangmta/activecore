//module anlz_byte
//(
//    input logic[7:0] src_byte,
//    output logic[7:0] msb,
//    output logic msb_detected
//);
//    logic[7:0] wrk_byte;
//    always @*
//        begin
//            wrk_byte = src_byte;
//            msb_detected = 0;
//            msb = 0;
//            for (int i = 0; i<8;i++)
//            begin
//                if(((src_byte[i] & 8'h1) != 0) )
//                begin
//                    msb_detected = 1;
//                    msb = i;
//                end
//                wrk_byte = wrk_byte >> 1;
//            end
//        end
//endmodule

//module msb_comb
//(
//    input logic [31:0] x,
//    output logic [31:0] msb
//);
//    logic [7:0] byte_msb [0:3] = {0,0,0,0};
//    logic [3:0] byte_msb_detected = {0,0,0,0};
//    anlz_byte anlz_1(.src_byte((x>>0) & 8'hff),.msb(byte_msb[0]),.msb_detected((byte_msb_detected[0])));
//    anlz_byte anlz_2(.src_byte((x>>8) & 8'hff),.msb(byte_msb[1]),.msb_detected((byte_msb_detected[1])));
//    anlz_byte anlz_3(.src_byte((x>>16) & 8'hff),.msb(byte_msb[2]),.msb_detected((byte_msb_detected[2])));
//    anlz_byte anlz_4(.src_byte((x>>24) & 8'hff),.msb(byte_msb[3]),.msb_detected((byte_msb_detected[3])));
//    always @*
//    begin
//       msb = 0;
//       for(int i=0;i<4;i++)
//       begin
//            if(byte_msb_detected[i] != 0)
//                msb = byte_msb[i]+(i<<3);             
//       end        
//    end    
//endmodule

//module msb_comb
//(
//    input logic [31:0] argument,
//    output logic [31:0] msb
//);
//    logic found;
//    always @*
//        begin            
//            msb = 0;
//            found = 0;
//            for (int i = 31; i>=0;i--)
//            begin
//                if((argument[i] == 1'h1) & ~found)
//                begin
//                    found = 1'b1;
//                    msb = i;
//                end
//            end
//        end    
//endmodule

module msb_comb
(
    input logic [31:0] argument,
    output logic [31:0] msb
);
    logic found;
    logic [5:0] i;
    always @*
        begin            
            msb = 0;
            found = 0;
            i=32;
            do
            begin
                i--;
                if(argument[i] == 1'h1)
                begin
                    found = 1'b1;
                    msb = i;
                end
            end while(i && ~found);
        end    
endmodule
