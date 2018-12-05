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
	output vga_sync_n,

	input RPG_RX, //gpio[8]
	output RPG_TX, //gpio[9]

	input RPG, //sw[0]

	output [9:0]LED
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
wire [7:0]vgac_color_num;
wire [15:0]vgac_color;

wire [22:0]rpg_addr;
wire [31:0]rpg_data;
wire rpg_write;
wire [7:0]rpg_xorc;

wire [23:0]io_addr;
wire [31:0]io_data_in;
wire [31:0]io_data_out;
wire io_read, io_write;
wire [1:0]io_width;

wire [15:0]reg_dispcnt;

memory mem(
	.clk(~clk_50mhz),
	.clk_25mhz(clk_25mhz),
	.mem_addr(cpu_mem_addr),
	.mem_data(cpu_mem_data),
	.mem_width(cpu_mem_width),
	.mem_read(cpu_mem_read),
	.mem_write(cpu_mem_write),
	.ok(cpu_mem_ok),

	.vgac_addr(vgac_addr),
	.vgac_data(vgac_data),

	.rpg(RPG),
	.rpg_addr(rpg_addr),
	.rpg_data(rpg_data),
	.rpg_write(rpg_write),

	.io_addr(io_addr),
	.io_data_in(io_data_in),
	.io_data_out(io_data_out),
	.io_read(io_read),
	.io_write(io_write),
	.io_width(io_width)
);

cpu_armv4t cpu(
	.clk(clk_50mhz),
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
	.color_num(vgac_color_num),
	.data(vgac_data),
	.color(vgac_color),//TODO: read from vgac_color_num
	
	.dispcnt(reg_dispcnt),

	.R(R),
	.G(G),
	.B(B),
	.vga_clk(vga_clk),
	.vga_black_n(vga_black_n),
	.HS(HS),
	.VS(VS),
	.vga_sync_n(vga_sync_n)
);

assign LED[7:0] = rpg_xorc;
reprogram rpg1(
	.clk_50mhz(clk_50mhz),
	.rstn(rstn),
	.rx(RPG_RX),
	.addr(rpg_addr),
	.data(rpg_data),
	.write(rpg_write),
	.xorc(rpg_xorc)
);
assign RPG_TX = 1'b1;

io_register iorgst(
	.clk_mem(~clk_50mhz),
	.addr(io_addr),
	.data_in(io_data_in),
	.data_out(io_data_out),
	.read(io_read),
	.write(io_write),
	.width(io_width),
	
	.dispcnt(reg_dispcnt)
);

assign LED[9:8] = 2'b0;
endmodule
