module alu(
	input [3:0]opcode,
	input [31:0]a,
	input [31:0]b,
	output reg [31:0]out
);

wire i_mov = opcode == 4'b1101;

always @(*) begin
	case(1'b1)
		i_mov: out = b;
		default: begin
			out = 32'h0;
			//TODO: undefined instruction
			//should reaise interrupt
		end
	endcase
end

endmodule