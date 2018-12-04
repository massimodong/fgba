module graphic(
	input clk,
	output [15:0]addr,
	input [15:0]data,
	
	output [7:0]R,
	output [7:0]G,
	output [7:0]B,
	output vga_clk,
	output vga_black_n,
	output HS,
	output VS,
	output vga_sync_n
);

wire [8:0]row_addr;
wire [9:0]col_addr;
wire rdn;
wire inframe = (row_addr < 160) && (col_addr < 240);

//240 = 256 - 16
assign addr = inframe ? ({row_addr[7:0], 8'b00000000} - {row_addr, 4'b0000} + col_addr) : 16'b0;

vgac vga1(
	//.d_in(inframe ? last_data : 15'b110111101111011), //grey if out of frame
	.d_in(data[14:0]),
	.vga_clk(clk),
	.clrn(1'b1),
	.row_addr(row_addr),
	.col_addr(col_addr),
	.r(R[7:3]),
	.g(G[7:3]),
	.b(B[7:3]),
	.rdn(rdn),
	.hs(HS),
	.vs(VS)
);

assign R[2:0] = 3'h0;
assign G[2:0] = 3'h0;
assign B[2:0] = 3'h0;
assign vga_clk = clk;
assign vga_black_n = 1'b1;
assign vga_sync_n = 1'b1;

endmodule