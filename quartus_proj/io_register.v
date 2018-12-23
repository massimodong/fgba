module io_register(
	input clk_mem,
	input clk_uart16,
	input [23:0]addr,
	input [31:0]data_in,
	output [31:0]data_out,
	input read,
	input write,
	input [1:0]width,
	
	input [7:0]vgac_v_addr,
	input [9:0]key_data,
	output reg [15:0]dispcnt,
	output reg [4:0]mult_wait_time,

	output tx
);

initial begin
	mult_wait_time = 5'd0;
end

integer i;

//timer start
reg [1:0] clk_count = 2'b0;
reg [15:0] tmctrl[3:0];
reg [15:0] tmd[3:0];
reg [9:0] tmcnt[3:0];

reg [15:0] c_tmd[3:0];
reg [9:0] c_tmcnt[3:0];

task update_timer;
	if (clk_count < 2) begin
		clk_count <= clk_count + 1'b1;
		for (i = 0; i < 4; i = i + 1) begin
			tmd[i] <= c_tmd[i];
			tmcnt[i] <= c_tmcnt[i];
		end
	end else clk_count <= 2'b0;
endtask

always @(*) begin
	for (i = 0; i < 4; i = i + 1) begin
		c_tmd[i] = tmd[i];
		c_tmcnt[i] = tmcnt[i];
		if (tmctrl[i][7]) begin
			if (i && tmctrl[i][2]) begin
				if (tmd[i - 1] == 16'hffff && c_tmd[i - 1] == 16'b0)
					c_tmd[i] = tmd[i] + 1'b1;
			end else begin
				c_tmcnt[i] = tmcnt[i] + 1'b1;
				if (c_tmcnt[i] == (tmctrl[i][1:0] == 2'b00 ? 10'b1 : tmctrl[i][1:0] == 2'b01 ? 10'd64 : tmctrl[i][1:0] == 2'b10 ? 10'd256 : 10'b0)) begin
					c_tmcnt[i] = 10'b0;
					c_tmd[i] = tmd[i] + 1'b1;
				end
			end
		end
	end
end
//timer end

//vga register start
//reg [15:0] dispcnt;
wire [15:0] vcount = {8'b0, vgac_v_addr};
reg [15:0] dispstat = 16'b0; //not complete
// vga register end

//key start
reg [15:0] keyinput = 16'b0, keycnt = 16'b0;
always @(*) begin
	keyinput = {6'b0, key_data};
end
//key finist

//uart send to pc (0x400)
reg [7:0]uart2pc_data = 8'b0;
reg uart2pc_local_st = 1'b0;
wire uart2pc_remote_st;
uart_send uart_send2pc(
	.clk_uart16(clk_uart16),
	.data(uart2pc_data),
	.local_st(uart2pc_local_st),
	.remote_st(uart2pc_remote_st),
	.tx(tx)
);
//uart send to pc finish

wire [4:0]shift_amount = {addr[1:0], 3'h0};

//prepare data_out
wire [31:0]register[1023:0];
assign register[12'h000 >> 2] = {16'b0, dispcnt};
assign register[12'h004 >> 2] = {vcount, dispstat};
assign register[12'h100 >> 2] = {tmctrl[0], tmd[0]};
assign register[12'h104 >> 2] = {tmctrl[1], tmd[1]};
assign register[12'h108 >> 2] = {tmctrl[2], tmd[2]};
assign register[12'h10c >> 2] = {tmctrl[3], tmd[3]};
assign register[12'h130 >> 2] = {keycnt, keyinput};
assign register[12'h400 >> 2] = {22'h0, uart2pc_remote_st, uart2pc_local_st, uart2pc_data};
assign register[12'h404 >> 2] = {27'h0, mult_wait_time};
wire [31:0]reg_out = register[addr[11:2]];
assign data_out = reg_out >> shift_amount;
//prepare data_out finish


//prepare new register value (a word) from data_in
reg [31:0]mask; //mask to the bit(s) to be changed
always @(*) begin
	case(width)
		2'b00: mask = 32'hff;
		2'b01: mask = 32'hffff;
		default: mask = 32'hffffffff;
	endcase

	mask = mask << shift_amount;
end
wire [31:0]masked_data = (data_in << shift_amount) & mask;
wire [31:0]newval = (reg_out & (~mask)) | (masked_data);
//prepare new register value finish

//write to io-register
//and update timer
always @(posedge clk_mem) begin
	update_timer();
	if(write) begin
		case({addr[11:2], 2'h0})
			12'h000: dispcnt <= newval[15:0];
			12'h004: dispstat <= newval[15:0];
			12'h100: begin
				{tmctrl[0], tmd[0]} <= newval;
				tmcnt[0] <= 10'h0;
			end
			12'h104: begin
				{tmctrl[1], tmd[1]} <= newval;
				tmcnt[1] <= 10'h0;
			end
			12'h108: begin
				{tmctrl[2], tmd[2]} <= newval;
				tmcnt[2] <= 10'h0;
			end
			12'h10c: begin
				{tmctrl[3], tmd[3]} <= newval;
				tmcnt[3] <= 10'h0;
			end
			12'h400: {uart2pc_local_st, uart2pc_data} <= newval[8:0];
			12'h404: mult_wait_time <= newval[4:0];
			default: begin
			end
		endcase
	end
end

endmodule