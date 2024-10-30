module rvr32_sharedpc (
    input wire [31:0]       jdata,
    input wire              jmp,
    input wire              we,
    input wire              clk,
    input wire              rst_n,
    input wire [31:0]       bjimm,
    input wire              brj,
    output wire [31:0]      pc
);
    reg [31:0] r_pc;
    wire [31:0] t_data;
    assign t_data = pc + (brj ? bjimm : 32'd4);
    wire [31:0] t_data_in;
    assign t_data_in = jmp ? jdata : t_data;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        r_pc <= 0;
        else if(we)
        r_pc <= t_data_in;
        else
        r_pc <= r_pc;
    end
    assign pc = r_pc;
endmodule