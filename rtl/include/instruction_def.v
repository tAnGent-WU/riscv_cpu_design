`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// 
// Create Date: 2024/11/20 19:50:15
// Design Name:
// Module Name: instruction_def
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
// 
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// OPCODE 定义
`define INSTR_RTYPE_OP       7'b0110011 // R-Type OPCODE
`define INSTR_ITYPE_OP       7'b0010011 // I-Type OPCODE
`define INSTR_BTYPE_OP       7'b1100011 // B-Type OPCODE
`define INSTR_LW_OP          7'b0000011 // LW OPCODE
`define INSTR_SW_OP          7'b0100011 // SW OPCODE
`define INSTR_JAL_OP         7'b1101111 // JAL OPCODE
`define INSTR_JALR_OP        7'b1100111 // JALR OPCODE

// R-Type Funct 定义
`define INSTR_ADD_FUNCT      10'b0000000_000 // ADD Funct
`define INSTR_SUB_FUNCT      10'b0100000_000 // SUB Funct
`define INSTR_SUBU_FUNCT     6'b100011       // SUBU Funct
`define INSTR_AND_FUNCT      10'b0000000_111 // AND Funct
`define INSTR_OR_FUNCT       10'b0000000_110 // OR Funct
`define INSTR_XOR_FUNCT      10'b0000000_100 // XOR Funct
`define INSTR_NOR_FUNCT      6'b100111       // NOR Funct
`define INSTR_SLL_FUNCT      10'b0000000_001 // SLL Funct
`define INSTR_SRL_FUNCT      10'b0000000_101 // SRL Funct
`define INSTR_SRA_FUNCT      10'b0100000_101 // SRA Funct
`define INSTR_SRLV_FUNCT     6'b000110       // SRLV Funct
`define INSTR_SRAV_FUNCT     6'b000111       // SRAV Funct
`define INSTR_SLLV_FUNCT     6'b000100       // SLLV Funct
`define INSTR_JR_FUNCT       6'b001000       // JR Funct

// B-Type Funct 定义
`define INSTR_BEQ_FUNCT      3'b000 // BEQ Funct
`define INSTR_BNE_FUNCT      3'b001 // BNE Funct

// I-Type Funct 定义
`define INSTR_ADDI_FUNCT     3'b000 // ADDI Funct
`define INSTR_ORI_FUNCT      3'b110 // ORI Funct