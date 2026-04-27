`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ID_EX (
    input clk, 
    input rst, 
    input stallE,
    input flushE,
    input RFWrite,
    input DMCtrl,
    input ALUSrcA,
    input [1:0] ALUSrcB,
    input [1:0] WDSel,
    input [3:0] ALUOp,
    input [31:0] RD1,
    input [31:0] RD2,
    input [31:0] Imm32,
    input [31:0] PC,
    input [4:0] WR,
    output reg RFWrite_E,
    output reg DMCtrl_E,
    output reg ALUSrcA_E,
    output reg [1:0] ALUSrcB_E,
    output reg [1:0] WDSel_E,
    output reg [3:0] ALUOp_E,
    output reg [4:0] WR_E,
    output reg [31:0] RD1_E,
    output reg [31:0] RD2_E,
    output reg [31:0] Imm32_E,
    output reg [31:0] PC_E
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RFWrite_E  <= 1'b0;
            DMCtrl_E   <= `DMCtrl_RD;
            ALUSrcA_E  <= `ALUSrcA_A;
            ALUSrcB_E  <= `ALUSrcB_B;
            WDSel_E    <= `WDSel_Else;
            ALUOp_E    <= `ALUOp_ADD;
            WR_E       <= 5'b0;
            RD1_E      <= 32'b0;
            RD2_E      <= 32'b0;
            Imm32_E    <= 32'b0;
            PC_E       <= 32'b0;
        end
        else if (flushE) begin
            RFWrite_E  <= 1'b0;
            DMCtrl_E   <= `DMCtrl_RD;
            ALUSrcA_E  <= `ALUSrcA_A;
            ALUSrcB_E  <= `ALUSrcB_B;
            WDSel_E    <= `WDSel_Else;
            ALUOp_E    <= `ALUOp_ADD;
            WR_E       <= 5'b0;
            RD1_E      <= 32'b0;
            RD2_E      <= 32'b0;
            Imm32_E    <= 32'b0;
            PC_E       <= 32'b0;
        end
        else if (!stallE) begin
            RFWrite_E  <= RFWrite;
            DMCtrl_E   <= DMCtrl;
            ALUSrcA_E  <= ALUSrcA;
            ALUSrcB_E  <= ALUSrcB;
            WDSel_E    <= WDSel;
            ALUOp_E    <= ALUOp;
            WR_E       <= WR;
            RD1_E      <= RD1;
            RD2_E      <= RD2;
            Imm32_E    <= Imm32;
            PC_E       <= PC;
        end
    end
    
endmodule