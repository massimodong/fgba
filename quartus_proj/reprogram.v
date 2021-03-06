module reprogram(
	input clk_50mhz,
	input clk_uart16,
	input rstn,
	input rx,
	
	output reg [22:0]addr,
	output reg [31:0]data,
	output write,
	
	output reg [7:0]xorc = 8'h0 //xor of all received bytes
);

parameter INIT_ADDR = 23'h7fffff;

initial begin
	addr = INIT_ADDR;
	data = 32'h0;
	cnt = 2'h0;
end

assign write = addr != INIT_ADDR;

//uart receiver
wire [7:0]uart_data;
wire uart_ready, uart_ok;
wire read;
uart_recv uart_recv1(clk_uart16, rx, read, uart_ready, uart_data, uart_ok);

//shifter
reg [31:0]data_shifter;
reg [1:0]cnt = 2'h0;

//fifo reader
reg old_ok;
reg [1:0]state = 2'h0;
assign read = state == 2'h2;
always @(negedge rstn or posedge clk_50mhz) begin
	if(!rstn) begin
		addr <= INIT_ADDR;
		data <= 32'h0;
		cnt <= 2'h0;
	end else begin
		if(state == 2'h0) begin
			if(uart_ready) state <= 2'h1;
		end else if(state == 2'h1) begin
			state <= 2'h2;
			old_ok <= uart_ok;
			xorc <= xorc ^ uart_data;
			data_shifter <= {uart_data, data_shifter[31:8]}; //little endian
			cnt <= cnt + 2'h1;
			if(cnt == 2'd3) begin
				data <= {uart_data, data_shifter[31:8]};
				addr <= addr + 23'h1;
			end
		end else if(state == 2'h2) begin
			if(uart_ok != old_ok) state <= 2'h0;
		end else begin
			state <= 2'h0;
		end
	end
end

endmodule