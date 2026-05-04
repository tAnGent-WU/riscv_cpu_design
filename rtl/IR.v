`include "ctrl_signal_def.v"

module IR (in_ins, IRWrite, out_ins, Flush);
    input IRWrite;
    input [31:0] in_ins;
    input Flush;
    output reg [31:0] out_ins;

    always @(*) begin
        if (IRWrite) begin
            if (Flush) begin
                out_ins <= 32'h0000e013;
            end
            else begin
                out_ins <= in_ins;
            end
        end
    end
endmodule