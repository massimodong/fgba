module admode1_shifter(
	input [31:0]base,
	input [7:0]amount,
	input rg,
	input f_c,
	input [1:0]typ,
	output reg [31:0]operand,
	output reg co
);

task rotate;
input [31:0]a;
input [4:0]b;
output [31:0]o;
begin
	o = (a << (8'd32 - b)) | (a >> b); 
end
endtask

always @(*) begin
if(rg || amount != 8'h0) begin
	case (typ)
		2'b00: begin
			if(amount == 8'h0) begin
				operand = base;
				co = f_c;
			end else if (amount < 8'd32) begin
				operand = base << amount;
				co = base[8'd32 - amount];
			end else if(amount == 8'd32) begin
				operand = 32'h0;
				co = base[0];
			end else begin
				operand = 32'h0;
				co = 1'b0;
			end
		end
		2'b01: begin
			if(amount == 8'h0) begin
				operand = base;
				co = f_c;
			end else if(amount < 8'd32) begin
				operand = base >> amount;
				co = base[amount - 8'd1];
			end else if(amount == 8'd32) begin
				operand = 32'h0;
				co = base[31];
			end else begin
				operand = 32'h0;
				co = 1'b0;
			end
		end
		2'b10: begin
			if(amount == 8'h0) begin
				operand = base;
				co = f_c;
			end else if(amount < 8'd32) begin
				operand = $signed(base) >>> amount;
				co = base[amount - 8'd1];
			end else begin
				if(base[31] == 1'b0) begin
					operand = 32'h0;
					co = 1'b0;
				end else begin
					operand = 32'hffffffff;
					co = 1'b1;
				end
			end
		end
		2'b11: begin
			if(amount == 8'h0) begin
				operand = base;
				co = f_c;
			end else if(amount[4:0] == 5'h0) begin
				operand = base;
				co = base[31];
			end else begin
				rotate(base, amount[4:0], operand);
				co = base[amount[4:0] - 5'd1];
			end
		end
	endcase
end else begin
	case (typ)
		2'b00: begin
			operand = base;
			co = f_c;
		end
		2'b01: begin
			operand = 0;
			co = base[31];
		end
		2'b10: begin
			if(base[31] == 1'b0) begin
				operand = 32'h0;
				co = 1'b0;
			end else begin
				operand = 32'hffffffff;
				co = 1'b1;
			end
		end
		2'b11: begin
			operand = {f_c, base[31:1]};
			co = base[0];
		end
	endcase
end
end

endmodule