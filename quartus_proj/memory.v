module memory(
	input clk,
	input clk_25mhz,
	inout [31:0]mem_addr,
	inout [31:0]mem_data,
	input [1:0]mem_width,
	input mem_read,
	input mem_write,
	output ok,

	input [15:0]vgac_addr,
	output [15:0]vgac_data,

	input [7:0]vgac_palette_addr,
	output [15:0]vgac_palette_data,

	input rpg,
	input [22:0]rpg_addr,
	input [31:0]rpg_data,
	input rpg_write,

	output [23:0]io_addr,
	output [31:0]io_data_in,
	input [31:0]io_data_out,
	output io_read,
	output io_write,
	output [1:0]io_width
);

//`include "mem_init.txt"

wire [31:0]addr = rpg ? {7'b0000100, rpg_addr, 2'b00} : mem_addr;
wire [31:0]data = rpg ? rpg_data : mem_data;
wire [1:0]width = rpg ? 2'h2 : mem_width;
wire read = rpg ? 1'b0 : mem_read;
wire write = rpg ? rpg_write : mem_write;

wire [3:0]select = addr[27:24];

reg [31:0]raw_out;

wire rw_rom = select == 4'h0;
wire rw_ext = select == 4'h2;
wire rw_int = select == 4'h3;
wire rw_io = select == 4'h4;
wire rw_pal = select == 4'h5;
wire rw_pak = select == 4'h8 ||
              select == 4'h9 ||
              select == 4'ha ||
              select == 4'hb ||
              select == 4'hc ||
              select == 4'hd;
wire rw_cart = select == 4'he || select == 4'hf;
wire rw_v = select == 4'h6;

//handle unaligned read/write
//io_register handles unalignenment by itself, so we treat it as always aligned
reg unaligned_waiting = 1'b0;
reg unaligned_write_enable = 1'b0;
wire unaligned = (rw_int | rw_pak | rw_ext) & (width != 2'h2);
wire unaligned_write = unaligned & write;
wire [4:0]sr32 = {addr[1:0], 3'h0};
reg [31:0]mask;
always @(*) begin
	case (width)
		2'h0: mask = 32'hff;
		2'h1: mask = 32'hffff;
		default: mask = 32'hffffffff;
	endcase
	mask = mask << sr32;
end
wire [31:0]unaligned_write_data = ((data << sr32) & mask) | (raw_out & (~mask));

always @(posedge clk) begin
	if(unaligned_write) unaligned_waiting <= unaligned_waiting ^ 1'b1; //`unaligned_waiting` becomes positive for exactly one cycle
end
always @(negedge clk) begin
	unaligned_write_enable <= unaligned_waiting;
end
//handle unaligned read/write finish
wire aligned_write = unaligned ? unaligned_write_enable : write;
wire [31:0]aligned_data = unaligned ? unaligned_write_data : data;

wire [31:0]bios_out;
wire [31:0]pak_out;
wire [31:0]ext_out;
wire [31:0]int_out;
bios_rom bios_rom1(
	.address(addr[13:2]),
	.clock(clk),
	.q(bios_out)
);

external_ram external_ram1(
	.address(addr[17:2]),
	.clock(clk),
	.data(aligned_data),
	.wren(rw_ext && aligned_write),
	.q(ext_out)
);

internal_ram internal_ram1(
	.address(addr[14:2]),
	.clock(clk),
	.data(aligned_data),
	.wren(rw_int && aligned_write),
	.q(int_out)
);

pak_ram pak_ram1(
	.address(addr[24:2]),
	.clock(clk),
	.data(aligned_data),
	.wren(rw_pak && aligned_write),
	.q(pak_out)
);

palette_ram pal_ram1(
	.data(data[15:0]),
	.rdaddress(vgac_palette_addr),
	.rdclock(clk_25mhz),
	.wraddress(addr[8:1]),
	.wrclock(clk),
	.wren(rw_pal & write),
	.q(vgac_palette_data)
);

vram v_ram(
	.data(data[15:0]),
	.rdaddress(vgac_addr),
	.rdclock(clk_25mhz),
	.wraddress({addr[16], addr[16]?1'b0:addr[15], addr[14:1]}),
	.wrclock(clk),
	.wren(rw_v & write),
	.q(vgac_data)
);

assign io_addr = addr[23:0];
assign io_data_in = data;
assign io_read = rw_io & read;
assign io_write = rw_io & write;
assign io_width = width;

always @(*) begin
	case(1'b1)
		rw_rom: raw_out = bios_out;
		rw_pak: raw_out = pak_out;
		rw_ext: raw_out = ext_out;
		rw_int: raw_out = int_out;
		rw_io: raw_out = io_data_out;
		//rw_cart: out = {24'h0, cart_ram[addr[15:0]]};
		default: raw_out = 32'h0;
	endcase
end
wire [31:0]out = unaligned ? (raw_out >> sr32) : raw_out;

assign mem_data = read ? out : 32'bz;

assign ok = (rpg | unaligned_waiting) ? 1'b0 : 1'b1;

endmodule
