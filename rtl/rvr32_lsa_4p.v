module rvr32_lsa_4p (
    input wire [31:0]    wdata0,
    input wire [31:0]    wdata1,
    input wire [31:0]    wdata2,
    input wire [31:0]    wdata3,
    input wire [31:0]    mem_rdata,
    input wire [3:0]     wstrb0,
    input wire [3:0]     wstrb1,
    input wire [3:0]     wstrb2,
    input wire [3:0]     wstrb3,
    input wire [31:0]    addr0,
    input wire [31:0]    addr1,
    input wire [31:0]    addr2,
    input wire [31:0]    addr3,
    input wire           valid0,
    input wire           valid1,
    input wire           valid2,
    input wire           valid3,
    input wire           mem_ready,
    input wire           clk,
    input wire           rst_n,
    output wire [31:0]   mem_wdata,
    output wire [31:0]   rdata,
    output wire [3:0]    mem_wstrb,
    output wire          mem_valid,
    output wire [31:0]   mem_addr,
    output wire          ready0,
    output wire          ready1,
    output wire          ready2,
    output wire          ready3
);
    assign mem_valid = valid0 | valid1 | valid2 | valid3;
    reg ctrl_sel_valid_regh;
    reg ctrl_sel_valid_regl;
    wire Q2;
    wire Q1;
    wire [1:0] ctrl_sel_valid;
    wire valid_sum[3:0];
    assign valid_sum[0] = valid0;
    assign valid_sum[1] = valid1;
    assign valid_sum[2] = valid2;
    assign valid_sum[3] = valid3;
    wire ctrl_sel = valid_sum[ctrl_sel_valid];
    always @(posedge clk or negedge (mem_valid & rst_n)) begin
        if(!(mem_valid & rst_n))
        ctrl_sel_valid_regh <= 0;
        else if(!ctrl_sel)
        ctrl_sel_valid_regh <= Q2;
        else
        ctrl_sel_valid_regh <= ctrl_sel_valid_regh;
    end
    always @(posedge clk or negedge (mem_valid & rst_n)) begin
        if(!(mem_valid & rst_n))
        ctrl_sel_valid_regl <= 0;
        else if(!ctrl_sel)
        ctrl_sel_valid_regl <= Q1;
        else
        ctrl_sel_valid_regl <= ctrl_sel_valid_regl;
    end
    assign ctrl_sel_valid[1] = ctrl_sel_valid_regh;
    assign ctrl_sel_valid[0] = ctrl_sel_valid_regl;
    wire [31:0] wdata_sum [3:0];
    assign wdata_sum[0] = wdata0;
    assign wdata_sum[1] = wdata1;
    assign wdata_sum[2] = wdata2;
    assign wdata_sum[3] = wdata3;
    assign mem_wdata = mem_valid ? wdata_sum[ctrl_sel_valid] : 32'b0;
    assign rdata = mem_rdata;
    wire [3:0] wstrb_sum [3:0];
    assign wstrb_sum[0] = wstrb0;
    assign wstrb_sum[1] = wstrb1;
    assign wstrb_sum[2] = wstrb2;
    assign wstrb_sum[3] = wstrb3;
    assign mem_wstrb = mem_valid ? wstrb_sum[ctrl_sel_valid] : 4'b0;
    wire [31:0] addr_sum [3:0];
    assign addr_sum[0] = addr0;
    assign addr_sum[1] = addr1;
    assign addr_sum[2] = addr2;
    assign addr_sum[3] = addr3;
    assign mem_addr = mem_valid ? addr_sum[ctrl_sel_valid] : 32'b0;
    assign ready0 = valid0 & (mem_valid ? (ctrl_sel_valid==2'b00 ? mem_ready : 0) : 0);
    assign ready1 = valid1 & (mem_valid ? (ctrl_sel_valid==2'b01 ? mem_ready : 0) : 0);
    assign ready2 = valid2 & (mem_valid ? (ctrl_sel_valid==2'b10 ? mem_ready : 0) : 0);
    assign ready3 = valid3 & (mem_valid ? (ctrl_sel_valid==2'b11 ? mem_ready : 0) : 0);
    assign Q2 = !(valid0 | valid1) | (valid1 & valid3 & ctrl_sel_valid_regh) 
                | ((ctrl_sel_valid_regh | ctrl_sel_valid_regl) & valid0 & !valid1 & valid3) 
                | (valid0 & valid2 & !valid1 & !ctrl_sel_valid_regh & ctrl_sel_valid_regl);
    assign Q1 = (!valid0 & !valid1 & !valid2) | (!valid0 & valid1) 
                | (valid0 & valid1 & valid3) | (valid0 & !valid1 & !valid2 & valid3);
endmodule