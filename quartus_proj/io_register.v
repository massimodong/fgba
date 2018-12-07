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

	output tx
);

integer i;
// vga register start
//reg [15:0] dispcnt;
wire [15:0] vcount = {8'b0, vgac_v_addr};
reg [15:0] dispstat = 16'b0; //not complete
// vga register end

// timer start
reg [1:0]time_tick = 2'h0;
reg [9:0]time_count[3:0];

reg [15:0]tmd[3:0]; //time value
reg [15:0]tmcnt[3:0]; //time controller

task update_timer;
	if(time_tick == 2'h2) begin //(50Mhz / 3) = 16.67MHz ~ 16.78MHz
		time_tick <= 2'h0;
		for(i=0;i<4;i=i+1) begin
			if(tmcnt[i][7]) begin // timer enabled
				if(i>0 && tmcnt[i][2]) begin //Count-up Timing
					if(tmd[i-1] == 16'hffff) tmd[i] <= tmd[i] + 16'h1;
				end else begin
					case(tmcnt[i][1:0])
						2'b00: begin
							tmd[i] <= tmd[i] + 16'h1;
						end
						2'b01: begin
							if(time_count[i] == 10'd63) begin
								tmd[i] <= tmd[i] + 16'h1;
								time_count[i] <= 10'h0;
							end else time_count[i] <= time_count[i] + 10'h1;
						end
						2'b10: begin
							if(time_count[i] == 10'd255) begin
								tmd[i] <= tmd[i] + 16'h1;
								time_count[i] <= 10'h0;
							end else time_count[i] <= time_count[i] + 10'h1;
						end
						2'b11: begin
							if(time_count[i] == 10'd1023) tmd[i] <= tmd[i] + 16'h1;
							time_count[i] <= time_count[i] + 10'h1; //overflow to 0
						end
					endcase
				end
			end
		end
	end else time_tick <= time_tick + 2'h1;
endtask
//timer finish

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
assign register[12'h100 >> 2] = {tmcnt[0], tmd[0]};
assign register[12'h104 >> 2] = {tmcnt[1], tmd[1]};
assign register[12'h108 >> 2] = {tmcnt[2], tmd[2]};
assign register[12'h10c >> 2] = {tmcnt[3], tmd[3]};
assign register[12'h132 >> 2] = {keycnt, keyinput};
assign register[12'h400 >> 2] = {22'h0, uart2pc_remote_st, uart2pc_local_st, uart2pc_data};
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
			12'h004: dispstat <= newval[31:16];
			12'h100: begin
				{tmcnt[0], tmd[0]} <= newval;
				time_count[0] <= 10'h0;
			end
			12'h104: begin
				{tmcnt[1], tmd[1]} <= newval;
				time_count[1] <= 10'h0;
			end
			12'h108: begin
				{tmcnt[2], tmd[2]} <= newval;
				time_count[2] <= 10'h0;
			end
			12'h10c: begin
				{tmcnt[3], tmd[3]} <= newval;
				time_count[3] <= 10'h0;
			end
			12'h400: {uart2pc_local_st, uart2pc_data} <= newval[8:0];
			default: begin
			end
		endcase
	end
end

endmodule