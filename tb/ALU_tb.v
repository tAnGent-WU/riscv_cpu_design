`timescale 1ns / 1ps
`include "ctrl_signal_def.v"

module ALU_tb();

    // 1. 声明信号
    reg  signed [31:0] A;
    reg  signed [31:0] B;
    reg         [3:0]  ALUOp;
    wire               zero;
    wire signed [31:0] ALU_result;

    // 2. 实例化被测模块 (DUT)
    ALU dut (
        .A(A),
        .B(B),
        .ALUOp(ALUOp),
        .zero(zero),
        .ALU_result(ALU_result)
    );

    // 3. 激励产生逻辑
    initial begin
        // 初始化输入
        A = 32'd0;
        B = 32'd0;
        ALUOp = 4'b0000;

        // 等待 100ns 观察初始化状态
        #100;

        // --- 测试加法 (ADD) ---
        A = 32'd10; B = 32'd20; ALUOp = `ALUOp_ADD;
        #20; // 预期: ALU_result = 30, zero = 0

        // --- 测试减法 (SUB) 并触发 zero 标志 ---
        A = 32'd50; B = 32'd50; ALUOp = `ALUOp_SUB;
        #20; // 预期: ALU_result = 0, zero = 1

        // --- 测试逻辑与 (AND) ---
        A = 32'hAAAA_AAAA; B = 32'h5555_5555; ALUOp = `ALUOp_AND;
        #20; // 预期: ALU_result = 0, zero = 1

        // --- 测试逻辑或 (OR) ---
        A = 32'hF0F0_F0F0; B = 32'h0F0F_0F0F; ALUOp = `ALUOp_OR;
        #20; // 预期: ALU_result = 32'hFFFF_FFFF, zero = 0

        // --- 测试算术右移 (SRA) ---
        // A 为负数时，SRA 应该在高位补 1
        A = 32'h8000_0000; B = 32'd1; ALUOp = `ALUOp_SRA;
        #20; // 预期: ALU_result = 32'hC000_0000

        // --- 测试逻辑右移 (SRL) ---
        // 即使 A 是负数，SRL 也会在高位补 0
        A = 32'h8000_0000; B = 32'd1; ALUOp = `ALUOp_SRL;
        #20; // 预期: ALU_result = 32'h4000_0000

        // --- 测试逻辑左移 (SLL) ---
        A = 32'd1; B = 32'd2; ALUOp = `ALUOp_SLL;
        #20; // 预期: ALU_result = 4

        // 停止仿真
        #100;
        $stop;
    end

    // 4. (可选) 打印结果到控制台
    initial begin
        $monitor("Time=%0t | A=%d, B=%d, Op=%b | Result=%d, Zero=%b", 
                 $time, A, B, ALUOp, ALU_result, zero);
    end

endmodule