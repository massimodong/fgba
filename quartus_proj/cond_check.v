module cond_check(
	input n, z, c, v,
	input [3:0]cond,
	output reg o
);

always @(*) begin
	//TODO
	case(cond)
		default: o = 1'b1;
	endcase
end

endmodule