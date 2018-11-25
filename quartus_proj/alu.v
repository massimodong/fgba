module alu(
	input [3:0]opcode,
	input [31:0]a,
	input [31:0]b,
	output reg [31:0]out
);

wire i_mov = opcode == 4'b1101;
wire i_mvn = opcode == 4'b1111; // move not

wire i_and = opcode == 4'b0000;
wire i_eor = opcode == 4'b0101; // xor
wire i_orr = opcode == 4'b1100; // or
wire i_bic = opcode == 4'b1110; // bit clear / and not

wire i_adc = opcode == 4'b0101;
wire i_add = opcode == 4'b0100;
wire i_sbc = opcode == 4'b0110;
wire i_sub = opcode == 4'b0010;
wire i_rsb = opcode == 4'b0011; // reverse subtract
wire i_rsc = opcode == 4'b0111; // reverse subtract with carry

// cmn cmp teq tst

always @(*) begin
	case(1'b1)
		i_mov: out = b;
		i_add: begin
			out = a+b;
			//TODO: cpsr flags
		end
		default: begin
			out = 32'h0;
			//TODO: undefined instruction
			//should reaise interrupt
		end
	endcase
end

endmodule