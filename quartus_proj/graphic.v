module graphic(
	input clk,
	output [15:0]addr,
	output [7:0]color_num,
	input [15:0]data,
	input [15:0]color,
	
	input [15:0]dispcnt,
	
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
reg [15:0]vga_addr;

wire mode3 = dispcnt[2:0] == 3'h3;
wire mode4 = dispcnt[2:0] == 3'h4;

always @(posedge clk) begin
	case (1'b1)
		mode3: vga_addr = {row_addr[7:0], 8'b0} - {row_addr, 4'b0} + col_addr; 
		mode4: vga_addr = {row_addr, 7'b0} - {row_addr, 4'b0} + col_addr[9:1] + (dispcnt[4] ? 16'ha000: 16'b0);
		default: ;
	endcase
end

assign addr = inframe ? vga_addr : 16'b0; //vram[row * 240 + col]
assign color_num = col_addr[0] ? data[15:8] : data[7:0]; //color[vram[row * 120 + col / 2][15:8 or 7:0]]

vgac vga1(
	//.d_in(inframe ? last_data : 15'b110111101111011), //grey if out of frame
	.d_in(mode4 ? color[14:0] : data[14:0]),
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