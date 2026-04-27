`timescale 1ns / 1ps

module IF_ID (clk, rst, stallD, flushD, IF_PC, IF_ins, ID_PC, ID_ins);
    input clk, rst, stallD, flushD;
    input [31:0] IF_PC, IF_ins;
    output reg [31:0] ID_PC, ID_ins;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ID_PC <= 32'b0;
            ID_ins <= 32'h00000013;
        end
        else if (flushD) begin
            ID_PC <= 32'b0;
            ID_ins <= 32'h00000013;
        end
        else if (!stallD) begin
            ID_PC <= IF_PC;
            ID_ins <= IF_ins;
        end
    end

endmodule

//有东西要改一下，这里的stallD是不是IRWrite信号，到时候把这个信号换成IRWrite?
