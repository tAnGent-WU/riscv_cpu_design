`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
module IM(
    clk,
    rst,
    InsMemRW,
    PCA4,
    PC,
    addr,
    PCA4_r1,
    PC_r1,
    Ins
);
    input clk, InsMemRW, rst;
    input [11:2] addr;
    input [31:0] PCA4;
    output reg [31:0] PCA4_r1;
    output reg [31:0] Ins;
    reg [31:0] memory [0:1023];

    always @(posedge clk) begin
        if (InsMemRW) begin
            Ins <= memory[addr];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC_r1   <= 32'h0;
            PCA4_r1 <= 32'h0;
        end
        else begin
            PC_r1   <= PC;
            PCA4_r1 <= PCA4;
        end
    end

endmodule