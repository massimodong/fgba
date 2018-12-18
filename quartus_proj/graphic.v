module graphic(
	input clk,
	
	output reg [15:0]vram_addr,
	output [7:0]palette_addr,
	output [7:0]v_addr,
	input [15:0]vram_data,
	input [15:0]palette_data,
	
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

wire mode3 = dispcnt[2:0] == 3'h3;
wire mode4 = dispcnt[2:0] == 3'h4;

always @(*) begin
	if(inframe) begin
		case (1'b1)
			mode3: vram_addr = {row_addr[7:0], 8'b0} - {row_addr, 4'b0} + col_addr;
			mode4: vram_addr = {row_addr, 7'b0} - {row_addr, 3'b0} + col_addr[9:1] + (dispcnt[4] ? 16'h5000: 16'b0);
			default: vram_addr = 16'h0;
		endcase
	end else vram_addr = 16'h0;
end

assign palette_addr = col_addr[0] ? vram_data[15:8] : vram_data[7:0]; //color[vram[row * 120 + col / 2][15:8 or 7:0]]

vgac vga1(
	//.d_in(inframe ? last_data : 15'b110111101111011), //grey if out of frame
	.d_in(mode4 ? palette_data[14:0] : vram_data[14:0]),
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
assign vga_clk = ~clk;
assign vga_black_n = 1'b1;
assign vga_sync_n = 1'b1;
assign v_addr = row_addr < 8'd227 ? row_addr[7:0] : 8'd227;

endmodule