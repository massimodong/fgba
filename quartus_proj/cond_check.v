module cond_check(
	input t, n, z, c, v,
	input [3:0]cond,
	output reg o
);

always @(*) begin
	if(t) o = 1'b1;
	else begin
	//TODO
	case(cond)
		default: o = 1'b1;
	endcase
	end
end

endmodule