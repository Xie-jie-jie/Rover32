module rvr32_cu (
    input wire          clk,
    input wire [31:0]   inst_data,
    input wire          rst_n,
    input wire [29:0]   cuid,
    input wire          inst_ready,
    input wire          start,
    input wire [31:0]   glb_rdata,
    input wire          glb_ready,
    input wire [31:0]   loc_rdata0,
    input wire [31:0]   loc_rdata1,
    input wire [31:0]   loc_rdata2,
    input wire [31:0]   loc_rdata3,
    input wire          loc_ready0,
    input wire          loc_ready1,
    input wire          loc_ready2,
    input wire          loc_ready3,
    input wire          sync_ready,
    output wire [31:0]  loc_addr0,
    output wire [31:0]  loc_wdata0,
    output wire [3:0]   loc_wstrb0,
    output wire         loc_valid0,
    output wire [31:0]  loc_addr1,
    output wire [31:0]  loc_wdata1,
    output wire [3:0]   loc_wstrb1,
    output wire         loc_valid1,
    output wire [31:0]  loc_addr2,
    output wire [31:0]  loc_wdata2,
    output wire [3:0]   loc_wstrb2,
    output wire         loc_valid2,
    output wire [31:0]  loc_addr3,
    output wire [31:0]  loc_wdata3,
    output wire [3:0]   loc_wstrb3,
    output wire         loc_valid3,
    output wire [31:0]  glb_addr,
    output wire [31:0]  glb_wdata,
    output wire [3:0]   glb_wstrb,
    output wire         glb_valid,
    output wire         wfi,
    output wire         wfs,
    output wire [31:0]  inst_addr
);
// sp
    wire clk_n = !clk;
    wire sp_rst_n = rst_n;
    wire sp_inst_ready = inst_ready;
    wire sp_start = start;
    wire [14:0] rsd;
    wire [23:0] uop;
    wire [31:0] imm;
    wire sp_sync_ready = wfs & (!wfs_glb | sync_ready);
    wire [31:0] sharedpc;
    wire [31:0] glb_rdata0;
    wire [31:0] glb_rdata1 = glb_rdata0;
    wire [31:0] glb_rdata2 = glb_rdata0;
    wire [31:0] glb_rdata3 = glb_rdata0;
    wire addr0_31 = loc_addr0[31];
    wire addr1_31 = loc_addr1[31];
    wire addr2_31 = loc_addr2[31];
    wire addr3_31 = loc_addr3[31];
    wire glb_ready0;
    wire glb_ready1;
    wire glb_ready2;
    wire glb_ready3;
    wire wfi0;
    wire wfs0;
    wire exec0;
    wire brc0;
    wire [31:0] glb_addr0 = loc_addr0;
    wire [31:0] glb_wdata0 = loc_wdata0;
    wire [3:0]  glb_wstrb0 = loc_wstrb0;
    wire glb_valid0 = mem_valid0 & !addr0_31;
    wire mem_valid0;
    assign loc_valid0 = mem_valid0 & addr0_31;
    wire [31:0] pc0;
    wire wfi1;
    wire wfs1;
    wire exec1;
    wire brc1;
    wire [31:0] glb_addr1 = loc_addr1;
    wire [31:0] glb_wdata1 = loc_wdata1;
    wire [3:0]  glb_wstrb1 = loc_wstrb1;
    wire glb_valid1 = mem_valid1 & !addr1_31;
    wire mem_valid1;
    assign loc_valid1 = mem_valid1 & addr1_31;
    wire [31:0] pc1;
    wire wfi2;
    wire wfs2;
    wire exec2;
    wire brc2;
    wire [31:0] glb_addr2 = loc_addr2;
    wire [31:0] glb_wdata2 = loc_wdata2;
    wire [3:0]  glb_wstrb2 = loc_wstrb2;
    wire glb_valid2 = mem_valid2 & !addr2_31;
    wire mem_valid2;
    assign loc_valid2 = mem_valid2 & addr2_31;
    wire [31:0] pc2;
    wire wfi3;
    wire wfs3;
    wire exec3;
    wire brc3;
    wire [31:0] glb_addr3 = loc_addr3;
    wire [31:0] glb_wdata3 = loc_wdata3;
    wire [3:0]  glb_wstrb3 = loc_wstrb3;
    wire glb_valid3 = mem_valid3 & !addr3_31;
    wire mem_valid3;
    assign loc_valid3 = mem_valid3 & addr3_31;
    wire [31:0] pc3;
// other signal
    wire all_wait = !(exec0 | exec1 | exec2 | exec3);
    wire [31:0] minpc;
    wire req_pca = jalr | wfi_sp | wfs_cu;
    wire cu_exec;
    wire req_mem = !(uop[18] | uop[19]);
    wire pca_ready;
    wire cu_work = !wfi;
    wire req_brj = jal | (br_b & ((exec0 & brc0) | (exec1 & brc1) | (exec2 & brc2) | (exec3 & brc3)))
                     | (br_f & ((!exec0 | brc0) & (!exec1 | brc1) & (!exec2 | brc2) & (!exec3 | brc3)));
    wire idle0 = wfi0 | wfs0 | (jalr & !exec0);
    wire idle1 = wfi1 | wfs1 | (jalr & !exec1);
    wire idle2 = wfi2 | wfs2 | (jalr & !exec2);
    wire idle3 = wfi3 | wfs3 | (jalr & !exec3);
    wire wfs_glb;
    assign wfi = wfi0 & wfi1 & wfi2 & wfi3;
    assign wfs = wfs0 & wfs1 & wfs2 & wfs3;
    assign inst_addr = sharedpc;
    reg [31:0] r_inst;
    reg r_cu_exec;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        r_inst <= 0;
        else if(inst_ready)
        r_inst <= inst_data;
        else
        r_inst <= r_inst;
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
        r_cu_exec <= 0;
        else
        r_cu_exec <= inst_ready & cu_work;
    end
    assign cu_exec = r_cu_exec;
    wire br_f;
    wire br_b;
    wire jal;
    wire jalr;
    wire t_type_s;
    wire t_type_b;
    wire t_type_u;
    wire t_type_j;
    wire wfi_sp = uop[14];
    wire wfs_cu = uop[15];
    
// sp connect
rvr32_sp u_sp0(
    .rsd(rsd),       
    .start(sp_start),            
    .clk(clk_n),              
    .rst_n(sp_rst_n),            
    .sp_uop(uop),    
    .imm(imm),       
    .sync_ready(sp_sync_ready),       
    .inst_ready(sp_inst_ready),       
    .shared_pc(sharedpc), 
    .mem_rdata(addr0_31 ? loc_rdata0 : glb_rdata0), 
    .spid({cuid,2'b00}),      
    .mem_ready((loc_ready0 & addr0_31) | (glb_ready0 & !addr0_31)),        
    .wfi(wfi0),              
    .wfs(wfs0),              
    .brc(brc0),              
    .exec(exec0),             
    .mem_addr(loc_addr0),  
    .mem_wdata(loc_wdata0), 
    .mem_wstrb(loc_wstrb0),  
    .mem_valid(mem_valid0),        
    .pc(pc0)
);
rvr32_sp u_sp1(
    .rsd(rsd),       
    .start(sp_start),            
    .clk(clk_n),              
    .rst_n(sp_rst_n),            
    .sp_uop(uop),    
    .imm(imm),       
    .sync_ready(sp_sync_ready),       
    .inst_ready(sp_inst_ready),       
    .shared_pc(sharedpc), 
    .mem_rdata(addr1_31 ? loc_rdata1 : glb_rdata1), 
    .spid({cuid,2'b01}),      
    .mem_ready((loc_ready1 & addr1_31) | (glb_ready1 & !addr1_31)),        
    .wfi(wfi1),              
    .wfs(wfs1),              
    .brc(brc1),              
    .exec(exec1),             
    .mem_addr(loc_addr1),  
    .mem_wdata(loc_wdata1), 
    .mem_wstrb(loc_wstrb1),  
    .mem_valid(mem_valid1),        
    .pc(pc1)
);
rvr32_sp u_sp2(
    .rsd(rsd),       
    .start(sp_start),            
    .clk(clk_n),              
    .rst_n(sp_rst_n),            
    .sp_uop(uop),    
    .imm(imm),       
    .sync_ready(sp_sync_ready),       
    .inst_ready(sp_inst_ready),       
    .shared_pc(sharedpc), 
    .mem_rdata(addr2_31 ? loc_rdata2 : glb_rdata2), 
    .spid({cuid,2'b10}),      
    .mem_ready((loc_ready2 & addr2_31) | (glb_ready2 & !addr2_31)),        
    .wfi(wfi2),              
    .wfs(wfs2),              
    .brc(brc2),              
    .exec(exec2),             
    .mem_addr(loc_addr2),  
    .mem_wdata(loc_wdata2), 
    .mem_wstrb(loc_wstrb2),  
    .mem_valid(mem_valid2),        
    .pc(pc2)
);
rvr32_sp u_sp3(
    .rsd(rsd),       
    .start(sp_start),            
    .clk(clk_n),              
    .rst_n(sp_rst_n),            
    .sp_uop(uop),    
    .imm(imm),       
    .sync_ready(sp_sync_ready),       
    .inst_ready(sp_inst_ready),       
    .shared_pc(sharedpc), 
    .mem_rdata(addr3_31 ? loc_rdata3 : glb_rdata3), 
    .spid({cuid,2'b11}),      
    .mem_ready((loc_ready3 & addr3_31) | (glb_ready3 & !addr3_31)),        
    .wfi(wfi3),              
    .wfs(wfs3),              
    .brc(brc3),              
    .exec(exec3),             
    .mem_addr(loc_addr3),  
    .mem_wdata(loc_wdata3), 
    .mem_wstrb(loc_wstrb3),  
    .mem_valid(mem_valid3),        
    .pc(pc3)
);
// lsa connect
rvr32_lsa_4p u_lsa(
    .wdata0(glb_wdata0),
    .wdata1(glb_wdata1),
    .wdata2(glb_wdata2),
    .wdata3(glb_wdata3),
    .mem_rdata(glb_rdata),
    .wstrb0(glb_wstrb0),
    .wstrb1(glb_wstrb1),
    .wstrb2(glb_wstrb2),
    .wstrb3(glb_wstrb3),
    .addr0(glb_addr0),
    .addr1(glb_addr1),
    .addr2(glb_addr2),
    .addr3(glb_addr3),
    .valid0(glb_valid0),
    .valid1(glb_valid1),
    .valid2(glb_valid2),
    .valid3(glb_valid3),
    .mem_ready(glb_ready),
    .clk(clk),
    .rst_n(rst_n),
    .mem_wdata(glb_wdata),
    .rdata(glb_rdata0),
    .mem_wstrb(glb_wstrb),
    .mem_valid(glb_valid),
    .mem_addr(glb_addr),
    .ready0(glb_ready0),
    .ready1(glb_ready1),
    .ready2(glb_ready2),
    .ready3(glb_ready3)
);
// sharedpc connect
rvr32_sharedpc u_shared_pc(
    .jdata(minpc),
    .jmp(req_pca),
    .we((cu_exec) & (!req_mem | all_wait) & (!req_pca | pca_ready)),
    .clk(clk_n),
    .rst_n(cu_work),
    .bjimm(imm),
    .brj(req_brj),
    .pc(sharedpc)
);
// pca connect
rvr32_pca_4p u_pca(
    .idle0(idle0),
    .idle1(idle1),
    .idle2(idle2),
    .idle3(idle3),
    .pc0(pc0),
    .pc1(pc1),
    .pc2(pc2),
    .pc3(pc3),
    .req(req_pca),
    .clk(clk_n),
    .rst_n(cu_exec),
    .min_pc(minpc),
    .ready(pca_ready)
);
// id connect
rvr32_id u_id(
    .inst(r_inst),
    .uop(uop),
    .rsd(rsd),
    .type_s(t_type_s),
    .type_b(t_type_b),
    .type_u(t_type_u),
    .type_j(t_type_j),
    .wfs_glb(wfs_glb),
    .br_f(br_f),
    .br_b(br_b),
    .jal(jal),
    .jalr(jalr)
);
// immgen connect
rvr32_immgen u_immgen(
    .data_inst(r_inst),
    .type_s(t_type_s),
    .type_b(t_type_b),
    .type_u(t_type_u),
    .type_j(t_type_j),
    .data_out(imm)
);
endmodule