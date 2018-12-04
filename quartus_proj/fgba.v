module fgba(
	input clk_50mhz,
	input rstn,
	
	output [7:0]R,
	output [7:0]G,
	output [7:0]B,
	output vga_clk,
	output vga_black_n,
	output HS,
	output VS,
	output vga_sync_n
);

reg clk_25mhz = 1'b0;
always @(posedge clk_50mhz) clk_25mhz = ~clk_25mhz;

reg clk_12_5mhz = 1'b0;
always @(posedge clk_25mhz) clk_12_5mhz = ~clk_12_5mhz;

wire [31:0]cpu_mem_addr;
wire [31:0]cpu_mem_data;
wire [1:0]cpu_mem_width;
wire cpu_mem_read, cpu_mem_write, cpu_mem_ok;

wire [15:0]vgac_addr;
wire [15:0]vgac_data;

memory mem(
	.clk(~clk_12_5mhz),
	.clk_25mhz(clk_25mhz),
	.addr(cpu_mem_addr),
	.data(cpu_mem_data),
	.width(cpu_mem_width),
	.read(cpu_mem_read),
	.write(cpu_mem_write),
	.ok(cpu_mem_ok),
	
	.vgac_addr(vgac_addr),
	.vgac_data(vgac_data)
);

cpu_armv4t cpu(
	.clk(clk_12_5mhz),
	.rstn(rstn),
	.mem_addr(cpu_mem_addr),
	.mem_data(cpu_mem_data),
	.mem_width(cpu_mem_width),
	.mem_read(cpu_mem_read),
	.mem_write(cpu_mem_write),
	.mem_ok(cpu_mem_ok)
);

graphic grp(
	.clk(clk_25mhz),
	.addr(vgac_addr),
	.data(vgac_data),
	
	.R(R),
	.G(G),
	.B(B),
	.vga_clk(vga_clk),
	.vga_black_n(vga_black_n),
	.HS(HS),
	.VS(VS),
	.vga_sync_n(vga_sync_n)
);

endmodule
