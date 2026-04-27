`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"

module EX_MEM (
    input clk,
    input rst,
    input RFWrite_E,
    input DMCtrl_E,
    input [1:0] RegSel_E,
    input [1:0] WDSel_E,
    input [31:0] ALU_result,
    input [31:0] PC_E,
    input [31:0] RD2_E,
    output reg RFWrite_M,
    output reg DMCtrl_M,
    output reg [1:0] RegSel_M,
    output reg [1:0] WDSel_M,
    output reg [31:0] ALU_result_M,
    output reg [31:0] PC_M,
    output reg [31:0] RD2_M 
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RFWrite_M    <= 1'b0;
            DMCtrl_M     <= `DMCtrl_RD;
            RegSel_M     <= `RegSel_else;
            WDSel_M      <= `WDSel_Else;
            ALU_result_M <= 32'b0;
            PC_M         <= 32'b0;
            RD2_M        <= 32'b0;
        end
        else begin
            RFWrite_M    <= RFWrite_E;
            DMCtrl_M     <= DMCtrl_E;
            RegSel_M     <= RegSel_E;
            WDSel_M      <= WDSel_E;
            ALU_result_M <= ALU_result_E;
            PC_M         <= PC_E;
            RD2_M        <= RD2_E;
        end
    end

endmodule