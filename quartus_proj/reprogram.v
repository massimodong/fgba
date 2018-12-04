module reprogram(
	input clk_50mhz,
	input rstn,
	input rx,
	
	output reg [12:0]addr = 13'h0,
	output reg [31:0]data = 32'h0
);

always @(negedge rstn or posedge clk_50mhz) begin
	if(!rstn) begin
	end else begin
	end
end

endmodule