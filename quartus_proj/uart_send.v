module uart_send(
	input clk_uart16,
	input [7:0]data,
	input local_st,
	output reg remote_st = 1'b0,
	output reg tx
);

reg clk8 = 1'b1;
always @(posedge clk_uart16) clk8 <= ~clk8;

reg clk4 = 1'b1;
always @(posedge clk8) clk4 <= ~clk4;

reg clk2 = 1'b1;
always @(posedge clk4) clk2 <= ~clk2;

reg clk = 1'b1;
always @(posedge clk2) clk <= ~clk;

reg [1:0]state = 2'h0;
reg [2:0]cnt = 3'h0;

always @(posedge clk) begin
	if(state == 2'h0) begin
		if(local_st != remote_st) state <= 2'h1;
	end else if(state == 2'h1) begin
		state <= 2'h2;
		cnt <= 3'h0;
	end else begin
		cnt <= cnt + 3'h1;
		if(cnt == 3'h7) begin
			state <= 2'h0;
			remote_st <= remote_st ^ 1'b1;
		end
	end
end

always @(*) begin
	case (state)
		2'h0: tx = 1'b1;
		2'h1: tx = 1'b0;
		default: tx = data[cnt];
	endcase
end

endmodule