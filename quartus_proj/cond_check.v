module cond_check(
	input n, z, c, v,
	input [3:0]cond,
	output reg o
);

always @(*) begin
		case(cond)
			4'b0000: o = z;	// equal
			4'b0001: o = ~z;	// not equal
			4'b0010: o = c;	// carry set/unsigned higher or same
			4'b0011: o = ~c;	// carry clear/unsigned lower
			4'b0100: o = n;	// minus/negative 
			4'b0101: o = ~n;	// plus/positive or zero 
			4'b0110: o = v;	// overflow
			4'b0111: o = ~v;	// no overflow
			4'b1000: o = c & ~z;	// unsigned higher
			4'b1001: o = ~c | z;	// unsigned lower or same
			4'b1010: o = n == v;	// signed greater than or equal
			4'b1011: o = n != v;	// signed less than
			4'b1100: o = ~z & (n == v);	// signed greater than
			4'b1101: o = z | (n != v);	// signed less than or equal
			4'b1110: o = 1'b1;	// always(unconditional)
			4'b1111: o = 1'b0;	// should not reach here
			default: o = 1'b0;	// should not reach here
		endcase
end

endmodule