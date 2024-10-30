module rvr32_lsa_2p (
    input wire [31:0]    wdata0,
    input wire [31:0]    wdata1,
    input wire [31:0]    mem_rdata,
    input wire [3:0]     wstrb0,
    input wire [3:0]     wstrb1,
    input wire [31:0]    addr0,
    input wire [31:0]    addr1,
    input wire           valid0,
    input wire           valid1,
    input wire           mem_ready,
    input wire           clk,
    input wire           rst_n,
    output wire [31:0]   mem_wdata,
    output wire [31:0]   rdata,
    output wire [3:0]    wstrb,
    output wire          mem_valid,
    output wire [31:0]   mem_addr,
    output wire          ready0,
    output wire          ready1
);
    assign mem_valid = valid0 | valid1;
    reg ctrl_sel_valid_reg;
    wire ctrl_sel_valid;
    wire ctrl_sel = ctrl_sel_valid ? valid1 : valid0;
    always @(posedge clk or negedge (mem_valid & rst_n)) begin
        if(!(mem_valid & rst_n))
        ctrl_sel_valid_reg <= 0;
        else if(!ctrl_sel)
        ctrl_sel_valid_reg <= !valid0;
        else
        ctrl_sel_valid_reg <= ctrl_sel_valid_reg;
    end
    assign ctrl_sel_valid = ctrl_sel_valid_reg;
    assign mem_wdata = mem_valid ? (ctrl_sel_valid ? wdata1 : wdata0) : 32'b0;
    assign rdata = mem_rdata;
    assign wstrb = mem_valid ? (ctrl_sel_valid ? wstrb1 : wstrb0) : 4'b0;
    assign mem_addr = mem_valid ? (ctrl_sel_valid ? addr1 : addr0) : 32'b0;
    assign ready0 = valid0 & (mem_valid ? (ctrl_sel_valid ? 0 : mem_ready) : 0);
    assign ready1 = valid1 & (mem_valid ? (ctrl_sel_valid ? mem_ready : 0) : 0);
endmodule