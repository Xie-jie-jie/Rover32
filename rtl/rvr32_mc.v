module rvr32_mc
(
    input   clk,
    input   valid,
    input   wire[31:0] addr,
    input   wire[31:0] wdata,
    input   wire[3:0] wstrb,
    input   wire[31:0] rdata,
    output  ready,
    //mem interface
    input   clk_mem,
    input   wire[31:0] mem_rdata,
    output  wire[31:0] mem_wdata,
    output  wire mem_we,
    output  wire mem_ce
);

wire clk_n = ~clk;
reg[31:0] r_data;

assign mem_addr = addr;
assign mem_wdata[ 7: 0] = wstrb[0] ? wdata[ 7: 0] : r_data[ 7: 0];
assign mem_wdata[15: 8] = wstrb[1] ? wdata[15: 8] : r_data[15: 8];
assign mem_wdata[23:16] = wstrb[2] ? wdata[23:16] : r_data[23:16];
assign mem_wdata[31:24] = wstrb[3] ? wdata[31:24] : r_data[31:24];

wire we = |wstrb;
wire shb = we & ~(&wstrb);

assign mem_rdata = rdata;
assign mem_ce = valid;

reg r_valid0, r_valid1;
reg r_whb0, r_whb1;
wire whb0 = r_whb0;
wire whb1 = r_whb1;
wire mem_ready = r_valid1;

//Reg r_data
always @(posedge clk or negedge valid) begin
    if (~valid) r_data <= 32'b0;
    else if (shb & ~whb1) r_data <= mem_rdata;
end

//Reg r_whb0
always @(posedge clk or negedge valid) begin
    if (~valid) r_whb0 <= 1'b0;
    else if (mem_ready & shb) r_whb0 <= ~r_whb0;
end

//Reg r_whb1
always @(posedge clk_n or negedge valid) begin
    if (~valid) r_whb1 <= 1'b0;
    else r_whb1 <= r_whb0;
end

assign ready = shb ? (mem_ready & whb0 & whb1) : mem_ready;
assign mem_we = shb ? whb0 : we;

wire t_valid_rst_n = valid & ~(whb0 ^ whb1);

//Reg r_valid0, r_valid1
always @(posedge clk_mem or negedge t_valid_rst_n) begin
    if (~t_valid_rst_n) begin
        r_valid0 <= 1'b0; 
        r_valid1 <= 1'b0;
    end
    else begin
        r_valid1 <= r_valid0;
        r_valid0 <= 1'b1;
    end
end

endmodule