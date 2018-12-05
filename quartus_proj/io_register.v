module io_register(
	input clk_mem,
	input [23:0]addr,
	input [31:0]data_in,
	output [31:0]data_out,
	input read,
	input write
);

integer i;

reg [1:0]time_tick = 2'h0;
reg [9:0]time_count[4];

reg [15:0]tmd[4]; //time value
reg [15:0]tmcnt[4]; //time controller


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

wire [31:0]register[4096];
assign register[12'h100] = {tmcnt[0], tmd[0]};
assign register[12'h104] = {tmcnt[1], tmd[1]};
assign register[12'h108] = {tmcnt[2], tmd[2]};
assign register[12'h10c] = {tmcnt[3], tmd[3]};

assign data_out = register[addr[23:2]];

always @(posedge clk_mem) begin
	update_timer();
	if(write) begin
		case(addr[11:0])
			12'h100: begin
				{tmcnt[0], tmd[0]} <= data_in;
				time_count[0] <= 10'h0;
			end
			12'h104: begin
				{tmcnt[1], tmd[1]} <= data_in;
				time_count[1] <= 10'h0;
			end
			12'h108: begin
				{tmcnt[2], tmd[2]} <= data_in;
				time_count[2] <= 10'h0;
			end
			12'h10c: begin
				{tmcnt[3], tmd[3]} <= data_in;
				time_count[3] <= 10'h0;
			end
			default: begin
			end
		endcase
	end
end

endmodule