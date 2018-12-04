module uart_recv(
	input clk,
	input rx,
	
	input read,
	
	output ready,
	output [7:0]data,
	output reg ok = 1'b0
);

reg [7:0]fifo[7:0];
reg [2:0]w_ptr = 3'h0;
reg [2:0]r_ptr = 3'h0;

reg [15:0]sampling;
reg [7:0]record;

reg state = 1'b0;
reg [3:0]cnt_sampling;
reg [3:0]cnt_record;

wire [4:0]cnt1 = sampling[0] +
                 sampling[1] +
					  sampling[2] +
					  sampling[3] +
					  sampling[4] +
					  sampling[5] +
					  sampling[6] +
					  sampling[7] +
					  sampling[8] +
					  sampling[9] +
					  sampling[10] +
					  sampling[11] +
					  sampling[12] +
					  sampling[13] +
					  sampling[14] +
					  sampling[15];

wire b = cnt1 >= 5'h8;
assign ready = w_ptr != r_ptr;
assign data = fifo[r_ptr];

always @(posedge clk) begin
	if(state == 1'b0) begin //waiting
		if(sampling[0] == 1'b0 && ~b) begin
			state <= 1'b1;
			cnt_sampling <= 4'h0;
			cnt_record <= 4'h0;
		end
	end else begin
		if(cnt_sampling == 4'hf) begin
			if(cnt_record == 4'h8) begin
				state <= 1'b0;
				fifo[w_ptr] <= record;
				w_ptr <= w_ptr + 3'h1;
			end
			cnt_record <= cnt_record + 4'h1;
			record <= {b, record[7:1]};
		end
		cnt_sampling <= cnt_sampling + 4'h1;
	end
	sampling <= {rx, sampling[15:1]};
	
	if(read && (w_ptr != r_ptr)) begin
		r_ptr <= r_ptr + 3'h1;
		ok <= ~ok;
	end
end

endmodule