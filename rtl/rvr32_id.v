module rvr32_id (
    input wire [31:0]       inst,
    output wire [23:0]      uop,
    output wire [14:0]      rsd,
    output wire             type_s,
    output wire             type_b,
    output wire             type_u,
    output wire             type_j,
    output wire             wfs_glb,
    output wire             br_f,
    output wire             br_b,
    output wire             jal,
    output wire             jalr
);
    wire [6:0] op = inst[6:0];
    wire [4:0] rd = inst[11:7];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rs1 = inst[19:15];
    wire [4:0] rs2 = inst[24:20];
    wire [6:0] funct7 = inst[31:25];
    wire funct7_0 = funct7[0];
    wire funct7_5 = funct7[5];
    wire funct7_6 = funct7[6];
    wire rs1_0 = rs1[0];
    wire rs1_2 = rs1[2];
    assign rsd = {rs2,rs1,rd};
    wire op_2 = op[2];
    wire op_3 = op[3];
    wire op_4 = op[4];
    wire op_5 = op[5];
    wire op_6 = op[6];
    assign type_s = !op_4 & op_5 & !op_6;
    assign type_b = !op_2 & !op_4 & op_5 & op_6;
    assign type_u = op_2 & !op_3 & op_4;
    assign type_j = op_2 & op_3 & !op_4 & op_5;
    wire [3:0] lsuop;
    wire [2:0] cmpop;
    wire [2:0] ealuop;
    wire [3:0] aluop;
    wire [9:0] spop;
    assign uop = {spop,aluop,ealuop,cmpop,lsuop};
    assign ealuop = funct3;
    assign cmpop[2] = funct3[2] | funct3[1];
    assign cmpop[1] = (funct3[2] & funct3[1]) | (funct3[1] & funct3[0]);
    assign cmpop[0] = (!funct3[1] & funct3[0]) | (funct3[0] & funct3[2]);
    assign lsuop = {op_5,funct3};
    assign aluop[3] = !((funct3[2] ^ funct3[1]) | (op_2));
    assign aluop[2] = (((!funct3[1] & funct7_5 & funct3[0]) | (funct7_5 & op_5)) | (funct3[2] & !(funct3[1] ^ funct3[0])))
                       & (!op_2 & op_4);
    assign aluop[1] = (((funct3[1]) | (funct3[2] & !funct3[0])) & (!op_2 & op_4)) | (op_2 & op_4 & op_5);
    assign aluop[0] = (((!funct3[1] & funct3[0]) | (funct3[2])) & (!op_2 & op_4)) | (op_2 & op_4 & op_5);
    assign spop[9] = op_2 & !op_4 & op_5 & op_6;
    assign spop[8] = !op_2 & !op_4 & op_5 & op_6;
    assign spop[7] = !op_2 & op_4 & op_5 & !op_6 & funct7_0;
    assign spop[6] = !(!op_2 & !op_4 & op_5);
    assign spop[5] = op_6;
    assign spop[4] = op_4;
    assign spop[3] = (op_4 | op_6) & !op_2 & op_5;
    assign spop[2] = !((op_3 | !op_5) & op_2);
    assign spop[1] = (op_4 & op_5 & op_6) & (funct7_5 & !funct7_6) & rs1_0;
    assign spop[0] = (op_4 & op_5 & op_6) & !(funct3[0] | funct3[1] | funct3[2]);
    assign wfs_glb = (op_4 & op_5 & op_6) & (funct7_5 & !funct7_6) & rs1_2;
    assign br_f = (!funct7_6) & spop[8];
    assign br_b = funct7_6 & spop[8];
    assign jal = spop[9] & op_3;
    assign jalr = spop[9] & !op_3;
endmodule