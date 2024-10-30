module rvr32_regfile (
    input wire [4:0]    addr_a,
    input wire [4:0]    addr_b,
    input wire [4:0]    addr_c,
    input wire [31:0]   wdata_a,
    input wire          we_a,
    input wire          clk,
    input wire          rst_n,
    output wire [31:0]  rdata_b,
    output wire [31:0]  rdata_c
);
    wire rst = !rst_n;
    wire [31:0] data_a = wdata_a;
    reg[31:0] r_general_reg [31:1];
    assign rdata_b = addr_b==5'b0 ? 32'b0 : r_general_reg[addr_b];
    assign rdata_c = addr_c==5'b0 ? 32'b0 : r_general_reg[addr_c];
    integer i;
always @ (posedge clk or posedge rst) begin
        if(rst) begin
            for ( i = 1; i < 32; i = i + 1) begin  
            r_general_reg[i] <= 32'b0;  
        end  
        end
        else if (we_a) begin
            if (addr_a != 5'b0) r_general_reg[addr_a] <= data_a;
end
end
endmodule