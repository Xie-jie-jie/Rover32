module rvr32_rover (
    input wire          start,
    input wire          clk,
    input wire          rst_n,
    input wire [31:0]   dram_rdata,
    input wire [31:0]   irom_data0,
    input wire [31:0]   irom_data1,
    output wire [31:0]  dram_addr,
    output wire [31:0]  irom_addr0,
    output wire [31:0]  irom_addr1,
    output wire         dram_ce,
    output wire         dram_we,
    output wire         dram_clk,
    output wire [31:0]  dram_wdata,
    output wire         wfi
);
    wire clk_2x = clk;
    wire clk_2x_n = !clk;
    reg r_clk;
    wire clk_1x;
    assign clk_1x = r_clk;
    wire clk_1x_n = !clk_1x;
    always @(posedge clk_2x or negedge rst_n) begin
        if(!rst_n)
        r_clk <= 0;
        else
        r_clk <= clk_1x_n;
    end
    assign dram_clk = clk_2x_n;
    wire [31:0] t_rdata;
    wire t_ready0;
    wire t_ready1;
    wire t_wfs0;
    wire t_wfs1;
    wire t_valid0;
    wire t_valid1;
    wire [31:0] t_addr0;
    wire [31:0] t_addr1;
    wire [3:0]  t_wstrb0;
    wire [3:0]  t_wstrb1;
    wire [31:0] t_wdata0;
    wire [31:0] t_wdata1;
    wire t_wfi0;
    wire t_wfi1;
    assign wfi = t_wfi0 & t_wfi1;
    wire [31:0] t_mem_rdata;
    wire t_mem_ready;
    wire [31:0] t_mem_addr;
    wire t_mem_valid;
    wire [3:0] t_mem_wstrb;
    wire [31:0] t_mem_wdata;
rvr32_core u_core0(
    .clk_2x(clk_2x),
    .clk_1x(clk_1x),
    .inst_data(irom_data0),
    .rst_n(rst_n),
    .cuid(30'd0),
    .inst_ready(1'b1),
    .start(start),
    .glb_rdata(t_rdata),
    .glb_ready(t_ready0),
    .sync_ready(t_wfs1),
    .glb_valid(t_valid0),
    .glb_addr(t_addr0),
    .glb_wstrb(t_wstrb0),
    .glb_wdata(t_wdata0),
    .wfi(t_wfi0),
    .wfs(t_wfs0),
    .inst_addr(irom_addr0)
);
rvr32_core u_core1(
    .clk_2x(clk_2x),
    .clk_1x(clk_1x),
    .inst_data(irom_data1),
    .rst_n(rst_n),
    .cuid(30'd1),
    .inst_ready(1'b1),
    .start(start),
    .glb_rdata(t_rdata),
    .glb_ready(t_ready1),
    .sync_ready(t_wfs0),
    .glb_valid(t_valid1),
    .glb_addr(t_addr1),
    .glb_wstrb(t_wstrb1),
    .glb_wdata(t_wdata1),
    .wfi(t_wfi1),
    .wfs(t_wfs1),
    .inst_addr(irom_addr1)
);
rvr32_lsa_2p u_glblsa(
    .wdata0(t_wdata0),
    .wdata1(t_wdata1),
    .mem_rdata(t_mem_rdata),
    .wstrb0(t_wstrb0),
    .wstrb1(t_wstrb1),
    .addr0(t_addr0),
    .addr1(t_addr1),
    .valid0(t_valid0),
    .valid1(t_valid1),
    .mem_ready(t_mem_ready),
    .clk(clk_1x),
    .rst_n(rst_n),
    .mem_wdata(t_mem_wdata),
    .rdata(t_rdata),
    .wstrb(t_mem_wstrb),
    .mem_valid(t_mem_valid),
    .mem_addr(t_mem_addr),
    .ready0(t_ready0),
    .ready1(t_ready1)
);
rvr32_mc u_glbmc(
    .addr(t_mem_addr),
    .wdata(t_mem_wdata),
    .wstrb(t_mem_wstrb),
    .mem_rdata(dram_rdata),
    .clk(clk_1x_n),
    .valid(t_mem_valid),
    .clk_mem(clk_2x_n),
    .mem_addr(dram_addr),
    .mem_wdata(dram_wdata),
    .rdata(t_mem_rdata),
    .ready(t_mem_ready),
    .mem_we(dram_we),
    .mem_ce(dram_ce)
);
endmodule