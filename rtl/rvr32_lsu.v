module rvr32_lsu (
    input wire [31:0]       addr,
    input wire [31:0]       wdata,
    input wire [3:0]        lsuop,
    input wire [31:0]       mem_rdata,
    input wire              req,
    input wire              clk,
    input wire              rst_n,
    input wire              mem_ready,
    output wire [31:0]      mem_addr,
    output wire [31:0]      mem_wdata,
    output wire [3:0]       mem_wstrb,
    output wire [31:0]      rdata,
    output wire             mem_valid,
    output wire             ready
);
    wire [1:0] addr_1_0 = addr[1:0];
    wire addr_0 = addr[0];
    wire addr_1 = addr[1];
    assign mem_addr = {addr[31:2],2'b0};
    wire [7:0] wdata_7_0 = wdata[7:0];
    wire [7:0] wdata_15_8 = wdata[15:8];
    wire [7:0] wdata_23_16 = wdata[23:16];
    wire [7:0] wdata_31_24 = wdata[31:24];
    wire [7:0] mem_wdata_7_0 = wdata_7_0;
    wire [7:0] mem_wdata_15_8 = (lsuop_0 | lsuop_1) ? wdata_15_8 : wdata_7_0;
    wire [7:0] mem_wdata_23_16 = lsuop_1 ? wdata_23_16 : wdata_7_0;
    wire [7:0] mem_wdata_31_24 = lsuop_1 ? wdata_31_24 : (lsuop_0 ? wdata_15_8 : wdata_7_0);
    assign mem_wdata = {mem_wdata_31_24,mem_wdata_23_16,mem_wdata_15_8,mem_wdata_7_0};
    wire lsuop_0 = lsuop[0];
    wire lsuop_1 = lsuop[1];
    wire lsuop_2 = lsuop[2];
    wire lsuop_3 = lsuop[3];
    wire mem_wstrb_0 = !(addr_0 | addr_1);
    wire mem_wstrb_1 = (addr_0 & !addr_1) | (!addr_1 & lsuop_0) | lsuop_1;
    wire mem_wstrb_2 = (!addr_0 & addr_1) | (addr_1 & lsuop_0) | lsuop_1;
    wire mem_wstrb_3 = (addr_0 & addr_1) | (addr_1 & lsuop_0) | lsuop_1;
    assign mem_wstrb = {mem_wstrb_3 & lsuop_3,mem_wstrb_2 & lsuop_3,mem_wstrb_1 & lsuop_3,mem_wstrb_0 & lsuop_3};
    wire [7:0] t_rdata [3:0];
    assign t_rdata[0] = mem_rdata[7:0];
    assign t_rdata[1] = mem_rdata[15:8];
    assign t_rdata[2] = mem_rdata[23:16];
    assign t_rdata[3] = mem_rdata[31:24];
    wire [7:0] rdata_7_0 = t_rdata[addr_1_0];
    wire [7:0] rdata_15_8 = (lsuop_0 | lsuop_1) ? (addr_1 ? mem_rdata[31:24] : mem_rdata[15:8]) : ext8;
    wire [7:0] rdata_23_16 = lsuop_1 ? mem_rdata[23:16] : ext8;
    wire [7:0] rdata_31_24 = lsuop_1 ? mem_rdata[31:24] : ext8;
    wire t_ext8 [3:0];
    assign t_ext8[0] = mem_rdata[7];
    assign t_ext8[1] = mem_rdata[15];
    assign t_ext8[2] = mem_rdata[23];
    assign t_ext8[3] = mem_rdata[31];
    wire [1:0] t_sel_ext8 = {addr_1,(addr_0 | lsuop_0)};
    wire [7:0] ext8 = lsuop_2 ? 8'b0 : {8{t_ext8[t_sel_ext8]}};
    assign rdata = {rdata_31_24,rdata_23_16,rdata_15_8,rdata_7_0};
    reg r_req;
    reg r_req_past;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        r_req <= 0;
        else
        r_req <= (req & !ready);
    end
    always @(negedge clk or negedge rst_n) begin
        if(!rst_n)
        r_req_past <= 0;
        else
        r_req_past <= r_req;
    end
    assign mem_valid = r_req | r_req_past;
    assign ready = r_req_past & mem_ready;
endmodule