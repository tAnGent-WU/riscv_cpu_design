`include "ctrl_signal_def.v"

module EXT(
    clk,
    imm_in,
    Offset,
    Offset20,
    ExtSel,
    imm_out,
    Offset_r1,
    Offset20_r1
);
    input [11:0] imm_in;
    input [12:1] Offset;
    input [20:1] Offset20;
    input ExtSel, clk;
    output reg [31:0] imm_out;
    output reg [12:1] Offset_r1;
    output reg [20:1] Offset20_r1;

    always @(posedge clk) begin
        case(ExtSel)
            `ExtSel_ZERO    :imm_out = {20'b0, imm_in[11:0]};
            `ExtSel_SIGNED  :imm_out = {imm_in[11] ? 20'hfffff : 20'b00000, imm_in[11:0]};
            default         :imm_out = 32'b0;
        endcase
    end

    always @(posedge clk) begin
        Offset_r1   <= Offset;
        Offset20_r1 <= Offset20;
    end

endmodule