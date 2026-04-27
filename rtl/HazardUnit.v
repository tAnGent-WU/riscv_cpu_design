`include "ctrl_signal_def.v"
`include "instruction_def.v"

module HazardUnit (
    input PCWrite,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    output stallF,
    output stallD,
    output flushD,
    output flushE
);
    
endmodule