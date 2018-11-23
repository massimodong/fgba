module admode2_shifter(
	input [31:0]instr,
	input [31:0]rm,
	input f_c,
	output reg [31:0]offset
);

task rotate;
input [31:0]a;
input [4:0]b;
output [31:0]o;
begin
	o = (a << (8'd32 - b)) | (a >> b); 
end
endtask

wire I = instr[25];
wire [4:0]shift_imm = instr[11:7];
wire [1:0]shift = instr[6:5];

always @(*) begin
	if(I == 1'b0) offset = {20'h0, instr[11:0]};
	else begin
		case(shift)
			2'b00: offset = rm << shift_imm;
			2'b01: begin
				if(shift_imm == 5'h0) offset = 32'h0;
				else offset = rm >> shift_imm;
			end
			2'b10: begin
				if(shift_imm == 5'h0) begin
					if(rm[31] == 1'b1) offset = 32'hffffffff;
					else offset = 32'h0;
				end else offset = $signed(rm) >>> shift_imm;
			end
			2'b11: begin
				if(shift_imm == 5'h0) offset = {f_c, rm[31:1]};
				else rotate(rm, shift_imm, offset);
			end
			default: offset = 32'h0;
		endcase
	end
end

endmodule