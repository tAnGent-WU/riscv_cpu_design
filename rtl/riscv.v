`timescale 1ns / 1ps

module risv(clk, rst);
    input clk,rst;

    wire RFWrite, DMCtrl, PCWrite, IRWrite, InsMemRW, ExtSel, zero, ALUSrcA;
    wire RFWrite_r1, RFWrite_r2, DMCtrl_r1;
    wire Flush;
    wire Stall;
    wire [1:0] ALUSrcB;
    wire [1:0] NPCOp, WDSel, RegSel;
    wire [1:0] WDSel, WDSel_r1, WDSel_r2;
    wire [3:0] ALUOp;
    wire [6:0] opcode, opcode_r;
    wire [2:0] Funct3, Funct3_r;
    wire [6:0] Funct7, Funct7_r;
    wire [31:0] PC, PC_r1, PC_r2, PC_r3; 
    wire [31:0] NPC;
    wire [31:0] PCA4, PCA4_r1, PCA4_r2, PCA4_r3, PCA4_r4;
    wire [31:0] in_ins, out_ins, RD, DR_out;
    wire [4:0] rs1, rs2, rd, rs1_r, rs2_r, rd_r;
    wire [11:0] Imm12;
    wire [31:0] Imm32;
    wire [20:1] Offset20, Offset20_r1, Offset20_r2;
    wire [11:0] Offset, Offset_r1, Offset_r2;
    wire [4:0] WR, WR_r1, WR_r2;
    wire [31:0] WD;
    wire [31:0] RD1, RD1_r, RD1_r1,
    wire [31:0] RD2, RD2_r, RD2_r1;
    wire [31:0] A_r, B_r, ALU_result, ALU_result_r, ALU_result_r1;

    assign opcode   = out_ins[6:0];
    assign Funct3   = out_ins[14:12];
    assign Funct7   = out_ins[31:25];
    assign rs1      = out_ins[19:15];
    assign rs2      = out_ins[24:20];
    assign rd       = out_ins[11:7];
    assign Imm12    = out_ins[31:20];
    assign Offset20 = {out_ins[31],out_ins[19:12],out_ins[20],out_ins[30:21]};
    assign Offset   = (opcode == `INSTR_BTYPE_OP) ? {out_ins[31],out_ins[7],out_ins[30:25],out_ins[11:8]} :
                      (opcode == `INSTR_SW_OP)    ? {out_ins[31:25],out_ins[11:7]}                        : Imm12;     

    ControlUnit U_ControlUnit(
        .clk(clk), .rst(rst), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3), .PCWrite(PCWrite), .InsMemRW(InsMemRW), 
        .IRWrite(IRWrite), .RFWrite(RFWrite), .DMCtrl(DMCtrl), .ExtSel(ExtSel), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB),
        .RegSel(RegSel), .WDSel(WDSel), .ALUOp(ALUOp), .Stall(Stall), //ControlUnit Logic
        .rd(rd), .PCA4_r1(PCA4_r1), .PC_r1(PC_r1), .rd_r(rd_r), .opcode_r(opcode_r), .Funct3_r(Funct3_r), .Funct7_r(Funct7_r), 
        .PC_r2(PC_r2), .PCA4_r2(PCA4_r2) //Flopr ID/EX
    );

    PC U_PC (
        .clk(clk), .rst(rst), .PCWrite(PCWrite), .NPC(NPC), .PC(PC)
    );

    NPC U_NPC(
        .PC(PC), .NPCOp(NPCOp), .Offset12(Offset_r2), .Offset20(Offset20_r2), .rs(RD1_r1[31:0]), .PCA4(PCA4),
        .NPC(NPC), .PC_r3(PC_r3)
    );

    IM U_IM (
        .clk(clk), .rst(rst), .PCA4(PCA4), .addr(PC[11:2]), .Ins(in_ins), .PCA4_r1(PCA4_r1), .InsMemRW(InsMemRW), .PCWrite(PCWrite),
        .PC(PC), .PC_r1(PC_r1) //Flopr IF/ID
    );

    IR U_IR (
        .IRWrite(IRWrite), .in_ins(in_ins), .out_ins(out_ins), .Flush(Flush)
    );

    RF U_RF (
        .RR1(rs1), .RR2(rs2), .WR(WR_r2), .WD(WD), .clk(clk),
        .RFWrite(RFWrite_r2), .RD1(RD1), .RD2(RD2),
        .RR1_r(rs1_r), .RR2_r(rs2_r) //Flopr ID/EX
    );

    MUX_3to1 U_MUX_3to1 (
        .X(rd_r), .Y(5'd0), .Z(5'd31),
        .control(RegSel), .out(WR)
    );

    MUX_3to1_LMD U_MUX_3to1_LMD (
        .X(ALU_result_r1), .Y(DR_out), .Z(PCA4_r4),
        .control(WDSel_r2), .out(WD)
    );

    Flopr U_A (
        .clk(clk), .rst(rst), .in_data(RD1), .out_data(RD1_r)
    );

    Flopr U_B (
        .clk(clk), .rst(rst), .in_data(RD2), .out_data(RD2_r)
    );

    EXT U_EXT (
        .clk(clk), .imm_in(Imm12), .ExtSel(ExtSel), .imm_out(Imm32),
        .Offset(Offset), .Offset_r1(Offset_r1), .Offset20(Offset20), .Offset20_r1(Offset20_r1) //Flopr ID/EX
    );

    MUX_2to1_A U_MUX_2to1_A (
        .X(RD1_r), .Y(5'd0), .control(ALUSrcA), .out(A_r)
    );

    MUX_3to1_B U_MUX_3to1_B (
        .X(RD2_r), .Y(Imm32), .Z(Offset_r1), .control(ALUSrcB), .out(B_r)
    );

    ALU U_ALU (
        .clk(clk), .rst(rst), .opcode_r(opcode_r), .Funct7_r(Funct7_r), .Funct3_r(Funct3_r), .NPCOp(NPCOp),
        .Flush(Flush), //determine when to flush ControlUnit, DM, ALU
        .RR1(rs1), .RR2(rs2), .opcode(opcode), .Stall(Stall), //determine when to stall the pipeline
        .RFWrite(RFWrite), .DMCtrl(DMCtrl), .WR(WR), .WDSel(WDSel), .RD2_r(RD2_r), .RD1_r(RD1_r), .PCA4_r2(PCA4_r2), .PCWrite(PCWrite),
        .Offset_r1(Offset_r1), .Offset20_r1(Offset20_r1), .PC_r2(PC_r2), .RFWrite_r1(RFWrite_r1), .DMCtrl_r1(DMCtrl_r1), 
        .WR_r1(WR_r1), .WDSel_r1(WDSel_r1), .RD1_r1(RD1_r1), .RD2_r1(RD2_r1), .PCA4_r3(PCA4_r3), .Offset_r2(Offset_r2), 
        .Offset20_r2(Offset20_r2), .PC_r3(PC_r3), //Flopr EX/MEM
        .RFWrite_r2(RFWrite_r2), .WR_r2(WR_r2), .RR1_r(rs1_r), .RR2_r(rs2_r), .ALUSrcB(ALUSrcB), .WD(WD), .ALU_result_r(ALU_result_r),
        .A_r(A_r), .B_r(B_r), //when and what to pass forward
        .ALUOp(ALUOp), .zero(zero), .ALU_result(ALU_result)
    );

    Flopr U_ALUOut (
        .clk(clk), .rst(rst), .in_data(ALU_result), .out_data(ALU_result_r)
    );

    DM U_DM (
        .rst(rst), .Addr(ALU_result_r[11:2]), .clk(clk), .WD(RD2_r1), .DMCtrl_r1(DMCtrl_r1), .RD(RD),
        .RFWrite_r1(RFWrite_r1), .WDSel_r1(WDSel_r1), .WR_r1(WR_r1), .PCA4_r3(PCA4_r3), .ALU_result_r(ALU_result_r),
        .RFWrite_r2(RFWrite_r2), .WDSel_r2(WDSel_r2), .WR_r2(WR_r2), .PCA4_r4(PCA4_r4), .ALU_result_r1(ALU_result_r1), //Flopr MEM/WB
        .Flush(Flush)
    );

    //Flopr U_DR (
    //    .clk(clk),
    //    .rst(rst),
    //    .in_data(RD),
    //    .out_data(DR_out)
    //);

    assign DR_out = RD;

endmodule