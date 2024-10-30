module rvr32_cmp (
    input wire [31:0]   data_in1,
    input wire [31:0]   data_in2,
    input wire [2:0]    cmpop,
    output wire         data_out
);
    wire cmpop_2 = cmpop[2];
    wire cmpop_1 = cmpop[1];
    wire cmpop_0 = cmpop[0];
    wire [31:0] t_data1 = {(cmpop_1 ? data_in1[31] : ~data_in1[31]),data_in1[30:0]};
    wire [31:0] t_data2 = {(cmpop_1 ? data_in2[31] : ~data_in2[31]),data_in2[30:0]};
    wire t_data_out = cmpop_2 ? (t_data1 < t_data2) : (t_data1 == t_data2);
    assign data_out = cmpop_0 ? ~t_data_out : t_data_out;
endmodule