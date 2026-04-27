`include "global_def.v"
`include "ctrl_signal_def.v"

module RF(
    input  [4:0]  RR1,      // 读寄存器1地址 (rs1)
    input  [4:0]  RR2,      // 读寄存器2地址 (rs2)
    input  [4:0]  WR,       // 写寄存器地址 (rd)
    input  [31:0] WD,       // 写寄存器数据 (Write Data)
    input         RFWrite,  // 寄存器堆写使能信号
    input         clk,      // 时钟信号
    output [31:0] RD1,      // 读出的数据1
    output [31:0] RD2       // 读出的数据2
);

    // 定义 32 个 32 位的通用寄存器
    reg [31:0] register [0:31];

    // 初始化 x0 寄存器始终为 0
    always @(clk) begin
        register[0] = 32'h0;
    end

    // 时钟上升沿写入数据
    always @(posedge clk) begin
        // RISC-V 规定 x0 寄存器不能被写入 (WR != 0)
        if ((WR != 0) && (RFWrite == 1)) begin
            register[WR] <= WD;
            
            // 调试用打印信息 (可选)
            `ifdef DEBUG
                $display("R[00-07]=%8X %8X %8X %8X %8X %8X %8X %8X", 0, register[1], register[2], register[3], register[4], register[5], register[6], register[7]);
                $display("R[08-15]=%8X %8X %8X %8X %8X %8X %8X %8X", register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15]);
                $display("R[16-23]=%8X %8X %8X %8X %8X %8X %8X %8X", register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23]);
                $display("R[24-31]=%8X %8X %8X %8X %8X %8X %8X %8X", register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
            `endif
        end
    end

    // 组合逻辑输出：异步读取寄存器数据
    assign RD1 = register[RR1];
    assign RD2 = register[RR2];

endmodule