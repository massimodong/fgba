module alu(
	input [3:0]opcode,
	input [31:0]a,
	input [31:0]b,
	input o_n, o_z, o_c, o_v,
	output reg [31:0]out,
	output reg n, z, c, v
);

wire i_mov = opcode == 4'b1101; // move
wire i_mvn = opcode == 4'b1111; // move not

wire i_and = opcode == 4'b0000; // and
wire i_eor = opcode == 4'b0001; // xor
wire i_orr = opcode == 4'b1100; // or
wire i_bic = opcode == 4'b1110; // bit clear / and not

wire i_add = opcode == 4'b0100; // add
wire i_adc = opcode == 4'b0101; // add with carry
wire i_sub = opcode == 4'b0010; // subtract
wire i_rsb = opcode == 4'b0011; // reverse subtract
wire i_sbc = opcode == 4'b0110; // subtract with carry
wire i_rsc = opcode == 4'b0111; // reverse subtract with carry

wire i_tst = opcode == 4'b1000; // test
wire i_teq = opcode == 4'b1001; // test equivalence
wire i_cmp = opcode == 4'b1010; // compare
wire i_cmn = opcode == 4'b1011; // compare negated

always @(*) begin
	case(1'b1)
		i_and, i_tst:	out = a & b;
		i_eor, i_teq:	out = a ^ b;
		i_sub, i_cmp:	out = a - b;
		i_rsb:			out = b - a;
		i_add, i_cmn:	out = a + b;
		i_adc:			out = a + b + o_c;
		i_sbc:			out = a - b - ~o_c;
		i_rsc:			out = b - a - ~o_c;
		i_orr:			out = a | b;
		i_mov:			out = b;
		i_bic:			out = a & (~b);
		i_mvn:			out = ~b;
		default: begin
			out = 32'h0;
			//TODO: undefined instruction
			//should reaise interrupt
		end
	endcase
	
	//TODO: cpsr flags. See page 50: A2-12
	n = out[31];
	z = out == 0;
	c = o_c;
	v = o_v;
end

endmodule