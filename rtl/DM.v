`include "ctrl_signal_def.v"

module DM (Addr, WD, clk, DMCtrl, RD, rst, ALU_result_r 
    ALU_result_r1, RFWrite_r1, WDSel_r1, WR_r1, PCA4_r2, 
    RFWrite_r2, WDSel_r2, WR_r2, PCA4_r3, Flush);
    input [11:2] Addr;
    input [31:0] WD;
    input clk, rst;
    input DMCtrl_r1;
    output reg [31:0] RD;

    input       RFWrite_r1;
    input [1:0] WDSel_r1;
    input [4:0] WR_r1;
    input [31:0] PCA_r3;
    input [31:0] ALU_result_r;
    output reg RFWrite_r2,
    output reg [1:0] WDSel_r2
    output reg [4:0] WR_r2;
    output reg [31:0] PCA4_r4;
    output reg [31:0] ALU_result_r1; //Flopr MEM/WB

    input Flush; //flush signal

    reg [31:0] memory [0:1023];
    always @(posedge clk) begin
        if (DMCtrl_r1) begin
            memory[Addr] <= WD;
        end 
        else begin
            RD <= memory[Addr];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst || Flush) begin
            RFWrite_r2    <= 1'b0;
            WDSel_r2      <= `WDSel_Else;
            WR_r2         <= 5'b0;
            PCA4_r4       <= 32'h0;
            ALU_result_r1 <= 32'h0;
        end
        else begin
            RFWrite_r2    <= RFWrite_r1;
            WDSel_r2      <= WDSel_r1;
            WR_r2         <= WR_r1;
            PCA4_r4       <= PCA4_r3;
            ALU_result_r1 <= ALU_result_r;
        end
    end
endmodule