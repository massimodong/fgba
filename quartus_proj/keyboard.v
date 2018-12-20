module keyboard(
	input clk, ps2_clk, ps2_data,
	output [9:0] en
);
	
	wire ready, overflow;
	wire [7:0] data_tmp;
	
	ps2_keyboard kbd(clk, 1'b1, ps2_clk, ps2_data, data_tmp, ready, 1'b0, overflow);
	
	dispose_keyboard dsps(clk, ready, data_tmp, en);
	
endmodule

module dispose_keyboard(
	input clk, ready,
	input [7:0] data_kbd,
	output reg [9:0]en
);
	initial begin
		en = 10'h3ff;
	end
	reg [1:0] state = 1'b0;
	reg [3:0] data_num = 4'ha;
	
	always @(*) begin
		case (data_kbd)
			8'h3b: data_num = 4'h0; // A_button: key 'J'
			8'h42: data_num = 4'h1; // B_button: key 'K'
			8'h31, 8'h66: data_num = 4'h2; // Select: key 'N' or 'BACKSPACE'
			8'h3a, 8'h5a: data_num = 4'h3; // Start: key 'M' or 'ENTER'
			8'h23: data_num = 4'h4; // Right: key 'D'
			8'h1c: data_num = 4'h5; // Left: key 'A'
			8'h1d: data_num = 4'h6; // Up: key 'W'
			8'h1b: data_num = 4'h7; // Down: key 'S'
			8'h43: data_num = 4'h8; // Right_shoulder: key 'I'
			8'h3c: data_num = 4'h9; // Left_shoulder: key 'U'
			default: data_num = 4'ha;
		endcase
	end

	always @(posedge clk) begin
		if (ready) begin
			if (state == 0) begin
				if (data_kbd == 8'hf0) state = 1;
				else if (data_num < 4'ha) en[data_num] = 0;
			end else begin
				state = 0;
				if (data_num < 4'ha) en[data_num] = 1;
			end
		end
	end
	
endmodule

module ps2_keyboard(clk,clrn,ps2_clk,ps2_data,data,ready,nextdata_n,overflow);

	input clk,clrn,ps2_clk,ps2_data;
	input nextdata_n;
	output [7:0] data;
	output reg ready;
	output reg overflow; // fifo overflow
	// internal signal, for test
	reg [9:0] buffer; // ps2_data bits
	reg [7:0] fifo[7:0]; // data fifo
	reg [2:0] w_ptr,r_ptr; // fifo write and read pointers
	reg [3:0] count; // count ps2_data bits
	// detect falling edge of ps2_clk
	reg [2:0] ps2_clk_sync;
	
	
	always @(posedge clk) begin
		ps2_clk_sync <= {ps2_clk_sync[1:0],ps2_clk};
	end
	
	wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
	
	always @(posedge clk) begin
		if (clrn == 0) begin // reset
			count <= 0; w_ptr <= 0; r_ptr <= 0;
			overflow <= 0; ready<= 0; 
		end else if (sampling) begin
			 if (count == 4'd10) begin
				if ((buffer[0] == 0) && // start bit
					 (ps2_data) && // stop bit
					 (^buffer[9:1])) begin // odd parity
					 fifo[w_ptr] <= buffer[8:1]; // kbd scan code
					 w_ptr <= w_ptr+3'b1;
					 ready <= 1'b1;
					 overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
				end
				count <= 0; // for next
				end else begin
					buffer[count] <= ps2_data; // store ps2_data
					count <= count + 3'b1;
				end
		end
		if ( ready ) begin // read to output next data
			if(nextdata_n == 1'b0) begin //read next data
				r_ptr <= r_ptr + 3'b1;
				if(w_ptr==(r_ptr+1'b1)) //empty
					ready <= 1'b0;
			end
		end
	end
	
	assign data = fifo[r_ptr]; //always set output data
	
endmodule
