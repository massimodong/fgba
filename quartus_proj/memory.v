module memory(
	input clk,
	inout [31:0]addr,
	inout [31:0]data,
	input [1:0]width,
	input read,
	input write,
	output ok,
	
	
	input [15:0]vgac_addr,
	output [15:0]vgac_data
);

//ram & rom & registers
reg [31:0]bios_rom[4095:0];
reg [31:0]pak_ram[255:0];
//reg [7:0]cart_ram[65535:0];
reg [7:0]cart_ram[6:0];
initial begin
	$readmemh("mifs/bios.txt", bios_rom, 0, 4095);
	$readmemh("mifs/rgb.txt", pak_ram, 0, 255);
end

wire [3:0]select = addr[27:24];

wire rw_rom = select == 4'h0;
wire rw_pak = select == 4'h8 ||
              select == 4'h9 ||
              select == 4'ha ||
              select == 4'hb ||
              select == 4'hc ||
              select == 4'hd;
wire rw_cart = select == 4'he || select == 4'hf;
wire rw_v = select == 4'h6;

reg [31:0]out;
always @(*) begin
	case(1'b1)
		rw_rom: out = bios_rom[addr[13:2]] >> addr[1:0];
		rw_pak: out = pak_ram[addr[24:2]] >> addr[1:0];
		rw_cart: out = {24'h0, cart_ram[addr[15:0]]};
		default: out = 32'h0;
	endcase
end

/*
reg [31:0]store_val;
always @(*) begin
	case(width)
		2'h0: store_val = out & 32'hff;
		2'h1: store_val = out & 32'hffff;
		2'h2: store_val = out;
		default: store_val = out;
	endcase
end*/
always @(posedge clk) begin
	if(write) begin
		if(rw_pak) pak_ram[addr[24:2]] <= data;
		if(rw_cart) cart_ram[addr[15:0]] <= data[7:0];
	end
end

vram v_ram(
	.clock(clk),
	.data(data[15:0]),
	.rdaddress(vgac_addr),
	.wraddress({addr[16], addr[16]?1'b0:addr[15], addr[14:1]}),
	.wren(rw_v & write),
	.q(vgac_data)
);

assign data = read ? out : 32'bz;

assign ok = 1'b1;

endmodule