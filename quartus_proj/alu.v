module alu(
	input [3:0]opcode,
	input [31:0]a,
	input [31:0]b,
	input n, z, c, v, shifter_carry_out,
	output reg [31:0]out,
	output reg out_n, out_z, out_c, out_v,
	output wrd
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

assign wrd = ~(i_tst | i_teq | i_cmp | i_cmn);

always @(*) begin
	out_c = c;
	out_v = v;
	case(1'b1)
		i_add, i_cmn:	{out_c, out} = a + b;
		i_adc:			{out_c, out} = a + b + c;
		i_sub, i_cmp:	{out_c, out} = {1'b1, a} - b;
		i_sbc:			{out_c, out} = {1'b1, a} - b - ~c;
		i_rsb:			{out_c, out} = {1'b1, b} - a;
		i_rsc:			{out_c, out} = {1'b1, b} - a - ~c;
		i_and, i_tst:	out = a & b;
		i_bic:			out = a & (~b);
		i_eor, i_teq:	out = a ^ b;
		i_orr:			out = a | b;
		i_mov:			out = b;
		i_mvn:			out = ~b;
		default: begin
			out = 32'h0;
			//TODO: undefined instruction
			//should reaise interrupt
		end
	endcase

	case(1'b1)
		i_add, i_cmn, i_adc:	out_v = a[31] == b[31] && a[31] != out[31];
		i_sub, i_cmp, i_sbc:	out_v = a[31] != b[31] && a[31] != out[31];
		i_rsb, i_rsc:			out_v = a[31] != b[31] && b[31] != out[31];
		default:					out_c = shifter_carry_out;
	endcase
end

endmodule