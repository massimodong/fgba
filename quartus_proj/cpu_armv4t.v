module cpu_armv4t(
	input clk,
	input rstn,
	
	inout [31:0]mem_addr,
	inout [31:0]mem_data,
	output reg [1:0]mem_width,
	output reg mem_read,
	output reg mem_write,
	input mem_ok
);

task rotate;
input [31:0]a;
input [4:0]b;
output [31:0]o;
begin
	o = (a << (8'd32 - b)) | (a >> b); 
end
endtask

parameter s_init = 3'h0;
parameter s_if = 3'h1;
parameter s_id = 3'h2;
parameter s_ex = 3'h3;

parameter msr_UnallocMask = 32'h0fffff00;
parameter msr_UserMask = 32'hf0000000;
parameter msr_PrivMask = 32'h0000000f;
parameter msr_StateMask = 32'h00000020;

integer i, j;

//sequential
reg [2:0]cpu_state = s_init;
reg [31:0]saved_instr = 32'h0;

reg [31:0]regf[7:0];
reg [31:0]regf_bank2[1:0][12:8];
reg [31:0]regf_bank6[5:0][14:13];
reg [31:0]reg_pc = 32'h08000000;
reg [31:0]reg_cpsr = 32'h0;
reg [31:0]reg_spsr[5:1];

//base controls
reg [2:0]c_next_state;
reg [31:0]c_saved_instr;

reg [31:0]c_regf[7:0];
reg [31:0]c_regf_bank2[1:0][12:8];
reg [31:0]c_regf_bank6[5:0][14:13];
reg [31:0]c_reg_pc;
reg [31:0]c_reg_cpsr;
reg [31:0]c_reg_spsr[5:1];

always @(posedge clk) begin
	cpu_state <= c_next_state;
	saved_instr <= c_saved_instr;
	
	for(i=0;i<8;i=i+1)  regf[i] <= c_regf[i];
	
	for(i=0;i<2;i=i+1) begin
		for(j=8;j<13;j=j+1) regf_bank2[i][j] <= c_regf_bank2[i][j];
	end
	
	for(i=0;i<6;i=i+1) begin
		for(j=13;j<15;j=j+1) regf_bank6[i][j] <= c_regf_bank6[i][j];
	end
	
	reg_pc <= c_reg_pc;
	
	reg_cpsr <= c_reg_cpsr;
	for(i=1;i<6;i=i+1) reg_spsr[i] <= c_reg_spsr[i];
end

//wires
wire [31:0]instr = saved_instr;

wire [31:0]cpsr = reg_cpsr;
wire f_n = cpsr[31];
wire f_z = cpsr[30];
wire f_c = cpsr[29];
wire f_v = cpsr[28];
wire f_q = cpsr[27];
wire f_j = cpsr[24];
wire [3:0]f_ge = cpsr[23:20];
wire f_e = cpsr[9];
wire f_a = cpsr[8];
wire f_i = cpsr[7];
wire f_f = cpsr[6];
wire f_t = cpsr[5];
wire [4:0]f_m = cpsr[4:0];

wire m_user = f_m == 5'b10000;
wire m_fiq = f_m == 5'b10001;
wire m_irq = f_m == 5'b10010;
wire m_supv = f_m == 5'b10011;
wire m_abort = f_m == 5'b10111;
wire m_undf = f_m == 5'b11011;
wire m_sys = f_m == 5'b11111; 

reg [2:0]bank6id;
always @(*) begin
	case (1'b1)
		m_user: bank6id = 0;
		m_sys: bank6id = 0;
		m_supv: bank6id = 1;
		m_abort: bank6id = 2;
		m_undf: bank6id = 3;
		m_irq: bank6id = 4;
		m_fiq: bank6id = 5;
		default: bank6id = 0;
	endcase
end

wire [31:0]spsr = (bank6id == 3'h0) ? 32'h0 : reg_spsr[bank6id];

//registers read by instructions:
reg [31:0]r[15:0];
always @(*) begin
	for(i=0;i<8;i=i+1) r[i] = regf[i];
	for(i=8;i<13;i=i+1) begin
		if(m_fiq) r[i] = regf_bank2[1][i];
		else r[i] = regf_bank2[0][i];
	end
	for(i=13;i<15;i=i+1) begin
		r[i] = regf_bank6[bank6id][i];
	end
	r[15] = reg_pc + (f_t ? 32'h4 : 32'h8);
end

//register control signals by instruction execution
reg cr_regw[15:0];
reg cr_cpsrw;
reg cr_spsrw;

reg [31:0]cr_regd[15:0];
reg [31:0]cr_cpsrd;
reg [31:0]cr_spsrd;

//wires
wire [31:0]seq_pc = reg_pc + (f_t ? 32'h2 : 32'h4);
wire [31:0]next_pc = cr_regd[15];

//actual register control signals
always @(*) begin
	//initialize
	for(i=0;i<8;i=i+1)  c_regf[i] = regf[i];
	
	for(i=0;i<2;i=i+1) begin
		for(j=8;j<13;j=j+1) c_regf_bank2[i][j] = regf_bank2[i][j] ;
	end
	
	for(i=0;i<6;i=i+1) begin
		for(j=13;j<15;j=j+1) c_regf_bank6[i][j] = regf_bank6[i][j];
	end
	
	c_reg_pc = reg_pc;
	
	c_reg_cpsr = reg_cpsr;
	for(i=1;i<6;i=i+1) c_reg_spsr[i] = reg_spsr[i];
	//initialize complete
	
	for(i=0;i<8;i=i+1) if(cr_regw[i]) c_regf[i] = cr_regd[i];
	for(i=8;i<13;i=i+i) if(cr_regw[i]) begin
		if(m_fiq) c_regf_bank2[1][i] = cr_regd[i];
		else c_regf_bank2[0][i] = cr_regd[i];
	end
	for(i=13;i<15;i=i+1) if(cr_regw[i]) c_regf_bank6[bank6id][i] = cr_regd[i];
	
	if(cr_regw[15]) c_reg_pc = cr_regd[15];
	
	if(cr_cpsrw) c_reg_cpsr = cr_cpsrd;
	if(cr_spsrw && bank6id != 3'h0) c_reg_spsr[bank6id] = cr_spsrd;
end

//process
reg [31:0]addr_load;
reg [31:0]data_load;
wire [3:0]cond = instr[31:28];
wire [2:0]itype = instr[27:25];
wire [3:0]opcode = instr[24:21];
wire [3:0]rn = instr[19:16];
wire [3:0]rd = instr[15:12];
wire update_cpsr = instr[20];
wire cond_pass;
cond_check cond_check1(f_n, f_z, f_c, f_v, cond, cond_pass);

//decode addressing mode 1
wire admode1 = (instr[27:26] == 2'b00) && ({instr[25],instr[4],instr[7]} != 3'b011);
wire [4:0]rotate_amount = {instr[11:8], 1'b0};
wire [31:0]immed_8 = {24'b0, instr[7:0]};
reg [7:0]shift_amount;
reg [31:0]shifter_operand;
reg shifter_carry_out;

wire [31:0]admode1_shifter_operand;
wire admode1_shifter_carry_out;

admode1_shifter admode1_shifter1(r[instr[3:0]], shift_amount, instr[4], f_c, instr[6:5], admode1_shifter_operand, admode1_shifter_carry_out);

always @(*) begin
	shift_amount = 8'h0;
	shifter_operand = 32'h0;
	shifter_carry_out = 1'b0;
	
	if(instr[25]) begin
		rotate(immed_8, rotate_amount, shifter_operand);
		if(rotate_amount == 32'h0) shifter_carry_out = f_c;
		else shifter_carry_out = shifter_operand[31];
	end else begin
		if(instr[4]==1'b0) shift_amount = {3'h0, instr[11:7]};
		else shift_amount = r[instr[11:8]][7:0];
		shifter_operand = admode1_shifter_operand;
		shifter_carry_out = admode1_shifter_carry_out;
	end
end

//msr instruction
//Table A4-1
wire [31:0]msr_bytemask = (instr[16] ? 32'h000000ff : 32'h0) |
                          (instr[17] ? 32'h0000ff00 : 32'h0) |
						        (instr[18] ? 32'h00ff0000 : 32'h0) |
						        (instr[19] ? 32'hff000000 : 32'h0);
reg [31:0]msr_mask;
always @(*) begin
	msr_mask = 32'h0;
	if(instr[22] == 1'b0) begin
		if(!m_user) msr_mask = msr_bytemask & (msr_UserMask | msr_PrivMask);
		else msr_mask = msr_bytemask & msr_UserMask;
	end else msr_mask = msr_bytemask & (msr_UserMask | msr_PrivMask | msr_StateMask);
end
wire [31:0]msr_new_cpsr = (cpsr & ~msr_mask) | (shifter_operand & msr_mask);
wire [31:0]msr_new_spsr = (spsr & ~msr_mask) | (shifter_operand & msr_mask);
//decode addressing mode 1 finish

//decode addressing mode 2 / 3
wire admode2 = instr[27:26] == 2'b01;
wire admode3 = instr[27:25] == 3'b0 && instr[6:5] != 2'b0;
wire admode23 = admode2 | admode3;

wire mode23_P = instr[24];
wire mode23_U = instr[23];
wire mode23_W = instr[21];
wire mode23_L = instr[20];
wire mode23_S = admode3 ? instr[6] : 0;
wire [1:0]mode23_LEN = admode3 ? instr[5] : instr[22] ? 0 : 2; // 2: word, 1: halfword, 0: byte.

wire [31:0]mode2_offset;
admode2_shifter admode2_shifter1(instr, r[instr[3:0]], f_c, mode2_offset);
wire [31:0]mode3_offset = instr[22] ? {instr[11:8], instr[3:0]} : r[instr[3:0]];
wire [31:0]mode23_offset = admode2 ? mode2_offset : mode3_offset;
wire [31:0]mode23_address_offset = mode23_U ? (r[rn] + mode23_offset) : (r[rn] - mode23_offset);
wire [31:0]mode23_address = mode23_P ? mode23_address_offset : r[rn];
//decode addressing mode 23 finish

wire i_b = itype == 3'b101;
wire i_msr = admode1 && (instr[24:23] == 2'b10) && (instr[21] == 1'b1); //msr is special

wire [31:0]alu_out;
alu alu1(opcode, r[rn], shifter_operand, alu_out);

assign mem_addr = addr_load; //addr only used as output
assign mem_data = (mem_write ? data_load : 32'bz);
always @(*) begin
	c_next_state = s_init;
	c_saved_instr = saved_instr;
	
	addr_load = 32'b0;
	data_load = 32'b0;
	mem_width = 2'h2; //default width is 2^2 = 4
	mem_read = 1'b0;
	mem_write = 1'b0;
	
	for(i=0;i<16;i=i+1) begin
		cr_regw[i] = 1'b0;
		cr_regd[i] = 32'h0;
	end
	cr_cpsrw = 1'b0;
	cr_cpsrd = 32'h0;
	cr_spsrw = 1'b0;
	cr_spsrd = 32'h0;
	
	case (cpu_state)
		s_init: begin
			cr_regw[15] = 1'b1;
			cr_regd[15] = 32'h08000000;
			
			cr_cpsrw = 1'b1;
			cr_cpsrd = 32'h13; //Supervisor mode

			c_next_state = s_if;
		end
		
		s_if: begin
			addr_load = reg_pc;
			mem_read = 1'b1;
			if(mem_ok) begin
				c_next_state = s_id;
				c_saved_instr = mem_data;
			end else begin
				c_next_state = s_if;
			end
		end
		
		s_id: begin
			if(cond_pass) begin
				if(admode23) begin
					addr_load = mode23_address;
					if(mode23_L == 1'b0) begin
						data_load = r[rd] & (mode23_LEN == 2 ? 32'hffffffff : mode23_LEN ? 32'hffff : 32'hff);
						mem_write = 1'b1;
					end
				
					if(mode23_P == 1'b0 || mode23_W == 1'b1) begin
						cr_regw[rn] = 1'b1;
						cr_regd[rn] = mode23_address_offset;
					end
				end
				c_next_state = s_ex;
			end else begin
				cr_regw[15] = 1'b1;
				cr_regd[15] = seq_pc;
				c_next_state = s_if;
			end
		end
		
		s_ex: begin
			cr_regw[15] = 1'b1;
			cr_regd[15] = seq_pc;
				
			case(1'b1)
				i_b: begin
					//cr_regw[15] = 1'b1;
					cr_regd[15] = r[15] + {{6{instr[23]}}, instr[23:0], 2'b0};
					if(instr[24] == 1'b1) begin //BL
						cr_regw[14] = 1'b1;
						cr_regd[14] = seq_pc;
					end
				end
				admode1: begin //addressing mode 1 instructions
					if(i_msr) begin //msr instruction changes cpsr or spsr, not a general register
						if(instr[22] == 1'b0) begin //change cpsr
							cr_cpsrw = 1'b1;
							cr_cpsrd = msr_new_cpsr;
						end else begin //change spsr
							cr_spsrw = 1'b1;
							cr_spsrd = msr_new_spsr;
						end
					end else begin //change a general register
						cr_regw[rd] = 1'b1;
						cr_regd[rd] = alu_out;
					end
					if(update_cpsr) begin
						//TODO
					end
				end
				admode23: begin	
					addr_load = mode23_address;
					if(mode23_L) begin
						mem_read = 1'b1;
						cr_regw[rd] = 1'b1;
						case({mode23_S, mode23_LEN})
							3'b000: cr_regd[rd] = {24'b0, mem_data[7:0]};
							3'b001: cr_regd[rd] = {16'b0, mem_data[15:0]};
							3'b010: cr_regd[rd] = mem_data;
							3'b100: cr_regd[rd] = {24'hff, mem_data[7:0]};
							3'b101: cr_regd[rd] = {16'hffff, mem_data[15:0]};
							default: ; // undefined
						endcase
					end else begin
						data_load = r[rd] & (mode23_LEN == 2 ? 32'hffffffff : mode23_LEN ? 32'hffff : 32'hff);
						mem_write = 1'b1;
					end
				end
				default: begin
				// undefined instruction
				// TODO: should raise interrupt
				end
			endcase
			
			if((!admode2) || mem_ok) begin
				c_next_state = s_if;
			end else begin //wait for memory
				for(i=0;i<16;i=i+1) cr_regw[i] = 1'b0;
				cr_cpsrw = 1'b0;
				cr_spsrw = 1'b0;
				c_next_state = s_ex;
			end
		end
		
		default: begin
			//should not reach here
			c_next_state = s_init;
		end
	endcase
	
	if(!rstn) c_next_state = s_init;
end

endmodule