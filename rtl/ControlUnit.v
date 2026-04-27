`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ControlUnit (
    input rst,              //
    input clk,              //
    input zero,             //
    input [6:0] opcode,     //
    input [6:0] Funct7,     //
    input [2:0] Funct3,     //
    output reg PCWrite,     //
    output reg InsMemRW,    //    
    output reg IRWrite,     //
    output reg RFWrite,     //
    output reg DMCtrl,      //
    output reg ExtSel,      //
    output reg ALUSrcA,     //
    output reg [1:0] ALUSrcB,
    output reg [1:0] RegSel,
    output reg [1:0] NPCOp,
    output reg [1:0] WDSel,
    output reg [3:0] ALUOp
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
        PCWrite  <= 1'b1;
        InsMemRW <= 1'b1;
        IRWrite  <= 1'b1;
        RFWrite  <= 1'b1;
        DMCtrl   <= `DMCtrl_RD;
        ExtSel   <= `ExtSel_ZERO;
        ALUSrcA  <= `ALUSrcA_A;
        ALUSrcB  <= `ALUSrcB_B;
        RegSel   <= `RegSel_else;
        NPCOp    <= `NPC_PC;
        WDSel    <= `WDSel_Else;
        ALUOp    <= `ALUOp_ADD;
        end
        else begin
        case (opcode)
            `INSTR_RTYPE_OP: begin //Register-Register compute
                PCWrite  <= 1'b1;
                InsMemRW <= 1'b1;
                IRWrite  <= 1'b1;
                RFWrite  <= 1'b1;
                DMCtrl   <= `DMCtrl_RD;
                ExtSel   <= `ExtSel_ZERO;
                ALUSrcA  <= `ALUSrcA_A;
                ALUSrcB  <= `ALUSrcB_B;
                RegSel   <= `RegSel_rd;
                NPCOp    <= `NPC_PC;
                WDSel    <= `WDSel_FromALU;
                case({Funct7,Funct3})
                    `INSTR_ADD_FUNCT: ALUOp <= `ALUOp_ADD;
                    `INSTR_SUB_FUNCT: ALUOp <= `ALUOp_SUB;
                    `INSTR_AND_FUNCT: ALUOp <= `ALUOp_AND;
                    `INSTR_OR_FUNCT : ALUOp <= `ALUOp_OR;
                    `INSTR_XOR_FUNCT: ALUOp <= `ALUOp_XOR;
                    `INSTR_SLL_FUNCT: ALUOp <= `ALUOp_SLL;
                    `INSTR_SRL_FUNCT: ALUOp <= `ALUOp_SRL;
                    `INSTR_SRA_FUNCT: ALUOp <= `ALUOp_SRA;
                    default;
                endcase
            end
            `INSTR_ITYPE_OP: begin //Register-Immediate compute
                PCWrite  <= 1'b1;
                InsMemRW <= 1'b1;
                IRWrite  <= 1'b1;
                RFWrite  <= 1'b1;
                DMCtrl   <= `DMCtrl_RD;
                ExtSel   <= `ExtSel_SIGNED;
                ALUSrcA  <= `ALUSrcA_A;
                ALUSrcB  <= `ALUSrcB_Imm;
                RegSel   <= `RegSel_rd;
                NPCOp    <= `NPC_PC;
                WDSel    <= `WDSel_FromALU;
                case(Funct3)
                    `INSTR_ADDI_FUNCT: ALUOp <= `ALUOp_ADD;
                    `INSTR_ORI_FUNCT : ALUOp <= `ALUOp_OR;
                    default;
                endcase
            end
            `INSTR_BTYPE_OP: begin //Branch (decided by zero)
                PCWrite  <= 1'b1;
                InsMemRW <= 1'b1;
                IRWrite  <= 1'b1;
                RFWrite  <= 1'b0;
                DMCtrl   <= `DMCtrl_RD;
                ExtSel   <= `ExtSel_SIGNED;
                ALUSrcA  <= `ALUSrcA_A;
                ALUSrcB  <= `ALUSrcB_B;
                RegSel   <= `RegSel_else;
                WDSel    <= `WDSel_Else;
                ALUOp    <= `ALUOp_BR;
                if (Funct3 == `INSTR_BEQ_FUNCT & zero)
                    NPCOp <= `NPC_Offset12;
                else
                    NPCOp <= `NPC_PC;
            end
            `INSTR_LW_OP: begin //Load (use addition to calculate the address)
                PCWrite  <= 1'b1;
                InsMemRW <= 1'b1;
                IRWrite  <= 1'b1;
                RFWrite  <= 1'b1;
                DMCtrl   <= `DMCtrl_RD;
                ExtSel   <= `ExtSel_SIGNED;
                ALUSrcA  <= `ALUSrcA_A;
                ALUSrcB  <= `ALUSrcB_Imm;
                RegSel   <= `RegSel_rd;
                NPCOp    <= `NPC_PC;
                WDSel    <= `WDSel_FromMEM;
                ALUOp    <= `ALUOp_ADD;
            end
            `INSTR_SW_OP: begin //Store (unnecessary to load in register)
                PCWrite  <= 1'b1;
                InsMemRW <= 1'b1;
                IRWrite  <= 1'b1;
                RFWrite  <= 1'b0;
                DMCtrl   <= `DMCtrl_WR;
                ExtSel   <= `ExtSel_SIGNED;
                ALUSrcA  <= `ALUSrcA_A;
                ALUSrcB  <= `ALUSrcB_Offset;
                RegSel   <= `RegSel_else;
                NPCOp    <= `NPC_PC;
                WDSel    <= `WDSel_Else;
                ALUOp    <= `ALUOp_ADD;
            end
            `INSTR_JAL_OP: begin //save and give back the address to register
                PCWrite  <= 1'b1;
                InsMemRW <= 1'b1;
                IRWrite  <= 1'b1;
                RFWrite  <= 1'b1;
                DMCtrl   <= `DMCtrl_RD;
                ExtSel   <= `ExtSel_SIGNED;
                ALUSrcA  <= `ALUSrcA_A;
                ALUSrcB  <= `ALUSrcB_Offset;
                RegSel   <= `RegSel_31;
                NPCOp    <= `NPC_Offset20;
                WDSel    <= `WDSel_FromPC;
                ALUOp    <= `ALUOp_ADD;
            end
            `INSTR_JALR_OP: begin //jump between register
                PCWrite  <= 1'b1;
                InsMemRW <= 1'b1;
                IRWrite  <= 1'b1;
                RFWrite  <= 1'b1;
                DMCtrl   <= `DMCtrl_RD;
                ExtSel   <= `ExtSel_SIGNED;
                ALUSrcA  <= `ALUSrcA_A;
                ALUSrcB  <= `ALUSrcB_Offset;
                RegSel   <= `RegSel_rd;
                NPCOp    <= `NPC_rs;
                WDSel    <= `WDSel_FromPC;
                ALUOp    <= `ALUOp_ADD;
            end
            default;
        endcase
        end
    end

endmodule