`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ALU (
    input clk, 
    input rst, 

    input [6:0] opcode_r,
    input [6:0] Funct7_r,
    input [2:0] Funct3_r,
    output reg [1:0] NPCOp,
    output reg Flush, //determine when to flush ctrl_unit and ir

    input RFWrite, 
    input DMCtrl, 
    input [4:0] WR, 
    input [1:0] WDSel, 
    input [31:0] RD2_r,
    input [31:0] RD1_r,
    input [31:0] PCA4_r2,
    input [11:0] Offset_r1,
    input [20:1] Offset20_r1,
    input [31:0] PC_r2,
    output reg RFWrite_r1,
    output reg DMCtrl_r1,
    output reg [4:0] WR_r1, 
    output reg [1:0] WDSel_r1,
    output reg [31:0] RD1_r1,
    output reg [31:0] RD2_r1,
    output reg [31:0] PCA4_r3,
    output reg [11:0] Offset_r2,
    output reg [20:1] Offset20_r2,
    output reg [31:0] PC_r3,  //Flopr EX

    input RFWrite_r2,
    input [4:0] WR_r2,
    input [4:0] RR1,
    input [4:0] RR2,
    input [1:0] ALUSrcB,
    input [31:0] WD,
    input [31:0] ALU_result_r,
    input signed [31:0] A_r, 
    input signed [31:0] B_r, //when and what to pass forward
    
    input [3:0] ALUOp,
    output zero,
    output reg signed [31:0] ALU_result
);
    reg signed [31:0] A;
    reg signed [31:0] B;
    reg [31:0] RD2_temp;

    always @(*) begin
        if (RFWrite_r1 && (WR_r1 == RR1) && (WR_r1 != 0) && (RR1 != 0)) begin
            A = ALU_result_r;
        end
        else if (RFWrite_r2 && (WR_r2 == RR1) && (WR_r2 != 0) && (RR1 != 0)) begin
            A = WD;
        end
        else begin
            A = A_r;
        end
    end

    always @(*) begin
        if (RFWrite_r1 && (WR_r1 == RR2) && (WR_r1 != 0) && 
        (RR2 != 0) && (ALUSrcB == `ALUSrcB_B)) begin
            B = ALU_result_r;
        end
        else if (RFWrite_r2 && (WR_r2 == RR2) && (WR_r2 != 0) && 
        (RR2 != 0) && (ALUSrcB == `ALUSrcB_B)) begin
            B = WD;
        end
        else begin
            B = B_r;
        end
    end

    always @(*) begin
        if (RFWrite_r1 && (WR_r1 == RR2) && (WR_r1 != 0) && (RR2 != 0)) begin
            RD2_temp = ALU_result_r;
        end
        else if (RFWrite_r2 && (WR_r2 == RR2) && (WR_r2 != 0) && (RR2 != 0)) begin
            RD2_temp = WD;
        end
        else begin
            RD2_temp = RD2_r;
        end
    end

    always @(*) begin
        case (ALUOp)
            `ALUOp_ADD : ALU_result = A + B;
            `ALUOp_SUB : ALU_result = A - B;
            `ALUOp_AND : ALU_result = A & B;
            `ALUOp_OR  : ALU_result = A | B;
            `ALUOp_XOR : ALU_result = A ^ B;
            `ALUOp_SRL : ALU_result = A >> B[4:0];
            `ALUOp_SLL : ALU_result = A << B[4:0];
            `ALUOp_SRA : ALU_result = ($signed(A)) >>> B[4:0];
            `ALUOp_BR  : ALU_result = A - B;
            default    : ALU_result = 32'b0;
        endcase
    end

    assign zero = (ALU_result == 32'b0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            NPCOp    <= `NPC_PC;
        end
        else begin
            case(opcode_r)
                `INSTR_RTYPE_OP: NPCOp    <= `NPC_PC;
                `INSTR_ITYPE_OP: NPCOp    <= `NPC_PC;
                `INSTR_BTYPE_OP: begin
                    if ((Funct3_r == `INSTR_BEQ_FUNCT && zero) || (Funct3_r == `INSTR_BNE_FUNCT && !zero))
                        NPCOp <= `NPC_Offset12;
                    else
                        NPCOp <= `NPC_PC;
                end
                `INSTR_LW_OP: NPCOp    <= `NPC_PC;
                `INSTR_SW_OP: NPCOp    <= `NPC_PC;
                `INSTR_JAL_OP: NPCOp    <= `NPC_Offset20;
                `INSTR_JALR_OP: NPCOp    <= `NPC_rs;
                default: NPCOp    <= `NPC_PC;
            endcase
        end

        Flush <= (NPCOp != `NPC_PC);
    end

    always @(posedge clk or posedge rst) begin
        if (rst || Flush) begin
            RFWrite_r1    <= 1'b0;
            DMCtrl_r1     <= `DMCtrl_RD;
            WDSel_r1      <= `WDSel_Else;
            WR_r1         <= 5'h0;
            RD1_r1        <= 32'h0;
            RD2_r1        <= 32'h0;
            PCA4_r3       <= 32'h0;
            Offset_r2     <= 12'h0;
            Offset20_r2   <= 20'h0;
            PC_r3         <= 32'h0;
        end
        else begin
            RFWrite_r1    <= RFWrite;
            DMCtrl_r1     <= DMCtrl;
            WDSel_r1      <= WDSel;
            WR_r1         <= WR;
            RD1_r1        <= RD1_r;
            RD2_r1        <= RD2_temp;
            PCA4_r3       <= PCA4_r2;
            Offset_r2     <= Offset_r1;
            Offset20_r2   <= Offset20_r1;
            PC_r3         <= PC_r2;
        end
    end



endmodule
