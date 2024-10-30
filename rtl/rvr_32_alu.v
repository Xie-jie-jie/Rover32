module rvr_32_alu (
    input wire [31:0]       data_in1,
    input wire [31:0]       data_in2,
    input wire [3:0]        aluop,
    input wire              data_cmp,
    output wire [31:0]      data_out
);
    wire [1:0]  aluop_1_0 = aluop[1:0];
    wire [1:0]  aluop_3_2 = aluop[3:2];
    wire aluop_2 = aluop[2];
    wire aluop_3 = aluop[3];
    wire [31:0] result0;
    wire [31:0] result1;
    wire [31:0] result2;
    wire [31:0] result3;
// 加减法
    assign result0 = data_in1 + (aluop_2 ? ~data_in2 : data_in2) + aluop_2;
// 移位
    wire [31:0] rev_data_in1;
    genvar gi;
    generate
        for (gi=0; gi<32; gi=gi+1)
        begin : genl
            assign rev_data_in1[gi] = data_in1[31-gi];
            assign result1[gi] = aluop_3 ? t_result1[31-gi] : t_result1[gi];
        end
    endgenerate
    wire [31:0] t_data_in1 = aluop_3 ? rev_data_in1 : data_in1;
    wire signed [32:0] t_data_in1_signed;
    assign t_data_in1_signed = aluop_2 ? {t_data_in1[31],t_data_in1} : {1'b0,t_data_in1};
    wire [4:0] t_num = data_in2[4:0];
    wire [32:0] t_result1 = t_data_in1_signed >>> t_num;
// 比较
    assign result2 = {30'b0,data_cmp};
// 位运算
    wire [31:0] t_result3 [3:0];
    assign t_result3[0] = data_in2;
    assign t_result3[1] = data_in1 ^ data_in2;
    assign t_result3[2] = data_in1 | data_in2;
    assign t_result3[3] = data_in1 & data_in2;
    assign result3 = t_result3[aluop_3_2];
// 输出
    wire [31:0] t_result [3:0];
    assign t_result[0] = result0;
    assign t_result[1] = result1;
    assign t_result[2] = result2;
    assign t_result[3] = result3;
    assign data_out = t_result[aluop_1_0];
endmodule