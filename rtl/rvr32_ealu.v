module rvr32_ealu (
    input wire [31:0]       data_in1,
    input wire [31:0]       data_in2,
    input wire [2:0]        ealuop,
    output wire [31:0]      data_out
);
    wire ealuop_0 = ealuop[0];
    wire ealuop_1 = ealuop[1];
    wire ealuop_2 = ealuop[2];
    wire signed[32:0] t_data1 = {(ealuop_0 & ealuop_1) ? 1'b0 : data_in1[31], data_in1};
    wire signed[32:0] t_data2 = {ealuop_1 ? 1'b0 : data_in2[31], data_in2};
    wire [65:0] t_data_out = t_data1 * t_data2;
    assign data_out = (ealuop_0 | ealuop_1) ? t_data_out[63:32] : t_data_out[31:0];          
endmodule