module lsb_pipeline
(
    input logic clk,
    input logic rst,
    input logic[31:0] argument,
    output logic[31:0] lsb  
);   
    logic [4:0] position;    
    logic [4:0] position_stage [0:7];
    logic [4:0] position_stage_next [0:7];    
    logic [31:0] argument_stage [0:7];
    
    always @*
    begin 
        position = ~argument[7:0]?0:(~argument[15:8]?8:(~argument[23:16]?16:24));
        for(int i=0;i<8;i++)
        begin
            position_stage_next[i] = !(~argument_stage[i][position_stage[i]] && argument_stage[i])? position_stage[i]+1:position_stage[i]; 
        end
    end
    
    always @(posedge clk)
    begin
        if(rst)
        begin
            for(int i=0;i<8;i++)
            begin
                position_stage[i] <= 0;
                argument_stage[i] <= 0;
            end            
            lsb <= 0; 
        end
        else 
        begin
            position_stage[0] <= position;
            argument_stage[0] <= argument;
            
            for(int i=1;i<8;i++)
            begin
                position_stage[i] <= position_stage_next[i-1];
                argument_stage[i] <= argument_stage[i-1];
            end
                             
            lsb <= position_stage_next[7];
        end
    end    
endmodule