`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"

module MEM_WB (
    input clk,
    input rst,
    input RFWrite_M,
    input [1:0] WDSel_M,
    input [4:0] WR_E,
    input [31:0] ALU_result_M,
    input [31:0] RD,
    input [31:0] PCA4,
    output reg RFWrite_W,
    output reg [1:0] WDSel_W,
    output reg [4:0] WR_W,
    output reg [31:0] ALU_result_W,
    output reg [31:0] RD_W,
    output reg [31:0] PCA4_W
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RFWrite_W    <= 1'b0;
            WDSel_W      <= `WDSel_Else;
            WR_W         <= 5'b0;
            ALU_result_W <= 32'b0;
            RD_W         <= 32'b0;
            PCA4_W       <= 32'b0;
        end
        else begin
            RFWrite_W    <= RFWrite_M;
            WDSel_W      <= WDSel_M;
            WR_W         <= WR_E;
            ALU_result_W <= ALU_result_M;
            RD_W         <= RD;
            PCA4_W       <= PCA4;
        end
    end

endmodule 