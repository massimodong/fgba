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

	input rpg,
	input [22:0]rpg_addr,
	input [31:0]rpg_data,
	input rpg_write
);

//`include "mem_init.txt"

wire [31:0]addr = rpg ? {7'b0000100, rpg_addr, 2'b00} : mem_addr;
wire [31:0]data = rpg ? rpg_data : mem_data;
wire [1:0]width = rpg ? 2'h2 : mem_width;
wire read = rpg ? 1'b0 : mem_read;
wire write = rpg ? rpg_write : mem_write;

wire [3:0]select = addr[27:24];

wire rw_rom = select == 4'h0;
wire rw_int = select == 4'h3;
wire rw_pak = select == 4'h8 ||
              select == 4'h9 ||
              select == 4'ha ||
              select == 4'hb ||
              select == 4'hc ||
              select == 4'hd;
wire rw_cart = select == 4'he || select == 4'hf;
wire rw_v = select == 4'h6;

wire [31:0]bios_out;
wire [31:0]pak_out;
wire [31:0]int_out;
bios_rom bios_rom1(
	.address(addr[13:2]),
	.clock(clk),
	.q(bios_out)
);

internal_ram internal_ram1(
	.address(addr[14:2]),
	.clock(clk),
	.data(data),
	.wren(rw_int && write),
	.q(int_out)
);

pak_ram pak_ram1(
	.address(addr[24:2]),
	.clock(clk),
	.data(data),
	.wren(rw_pak && write),
	.q(pak_out)
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

wire [4:0]sr32 = {addr[1:0], 3'h0};

reg [31:0]out;
always @(*) begin
	case(1'b1)
		rw_rom: out = bios_out >> sr32;
		rw_pak: out = pak_out >> sr32;
		rw_int: out = int_out >> sr32;
		//rw_cart: out = {24'h0, cart_ram[addr[15:0]]};
		default: out = 32'h0;
	endcase
end

assign mem_data = read ? out : 32'bz;

assign ok = rpg ? 1'b0 : 1'b1;

endmodule
