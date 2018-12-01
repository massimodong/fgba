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

task priority_encoder16_4;
input [15:0]a;
output reg [3:0]b;
begin
	case(1'b1)
		a[0]: b = 4'h0;
		a[1]: b = 4'h1;
		a[2]: b = 4'h2;
		a[3]: b = 4'h3;
		a[4]: b = 4'h4;
		a[5]: b = 4'h5;
		a[6]: b = 4'h6;
		a[7]: b = 4'h7;
		a[8]: b = 4'h8;
		a[9]: b = 4'h9;
		a[10]: b = 4'ha;
		a[11]: b = 4'hb;
		a[12]: b = 4'hc;
		a[13]: b = 4'hd;
		a[14]: b = 4'he;
		a[15]: b = 4'hf;
		default: b = 4'h0;
	endcase
end
endtask

parameter s_init = 3'h0;
parameter s_if = 3'h1;
parameter s_id = 3'h2;
parameter s_ex = 3'h3;
parameter s_lsm = 3'h4; //load store multiple

parameter msr_UnallocMask = 32'h0fffff00;
parameter msr_UserMask = 32'hf0000000;
parameter msr_PrivMask = 32'h0000000f;
parameter msr_StateMask = 32'h00000020;

parameter [4:0]NFb = 5'd31;
parameter [4:0]ZFb = 5'd30;
parameter [4:0]CFb = 5'd29;
parameter [4:0]VFb = 5'd28;

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

reg [31:0]lsm_address;
reg [15:0]lsm_rgs;
reg lsm_L;
reg [3:0]lsm_rd;

//base controls
reg [2:0]c_next_state;
reg [31:0]c_saved_instr;

reg [31:0]c_regf[7:0];
reg [31:0]c_regf_bank2[1:0][12:8];
reg [31:0]c_regf_bank6[5:0][14:13];
reg [31:0]c_reg_pc;
reg [31:0]c_cpsr;
reg [31:0]c_reg_spsr[5:1];

reg [31:0]c_lsm_address;
reg [15:0]c_lsm_rgs;
reg c_lsm_L;
reg [3:0]c_lsm_rd;
always @(*) priority_encoder16_4(c_lsm_rgs, c_lsm_rd);

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

	reg_cpsr <= c_cpsr;
	for(i=1;i<6;i=i+1) reg_spsr[i] <= c_reg_spsr[i];

	lsm_address <= c_lsm_address;
	lsm_rgs <= c_lsm_rgs;
	lsm_L <= c_lsm_L;
	lsm_rd <= c_lsm_rd;
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

wire admode4;
wire mode4_S;
wire mode4_ST;

wire m_user = f_m == 5'b10000 || (admode4 == 1'b1 && mode4_S == 1'b1 && mode4_ST == 1'b0);
wire m_fiq = f_m == 5'b10001 && ~m_user;
wire m_irq = f_m == 5'b10010 && ~m_user;
wire m_supv = f_m == 5'b10011 && ~m_user;
wire m_abort = f_m == 5'b10111 && ~m_user;
wire m_undf = f_m == 5'b11011 && ~m_user;
wire m_sys = f_m == 5'b11111 && ~m_user;

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
reg cr_spsrw;

reg [31:0]cr_regd[15:0];
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
	
	for(i=1;i<6;i=i+1) c_reg_spsr[i] = reg_spsr[i];
	//initialize complete
	
	for(i=0;i<8;i=i+1) if(cr_regw[i]) c_regf[i] = cr_regd[i];
	for(i=8;i<13;i=i+1) if(cr_regw[i]) begin
		if(m_fiq) c_regf_bank2[1][i] = cr_regd[i];
		else c_regf_bank2[0][i] = cr_regd[i];
	end
	for(i=13;i<15;i=i+1) if(cr_regw[i]) c_regf_bank6[bank6id][i] = cr_regd[i];
	
	if(cr_regw[15]) c_reg_pc = cr_regd[15];
	
	if(cr_spsrw && bank6id != 3'h0) c_reg_spsr[bank6id] = cr_spsrd;
end

//process
reg [31:0]addr_load;
reg [31:0]data_load;
wire [3:0]cond = f_t ? instr[11:8] : instr[31:28];
wire [2:0]itype = instr[27:25];
wire [3:0]opcode = instr[24:21];
wire [3:0]rn = instr[19:16];
wire [3:0]rd = instr[15:12];
wire [3:0]rm = instr[3:0];
wire update_cpsr = instr[20];
wire cond_pass;
cond_check cond_check1(f_n, f_z, f_c, f_v, cond, cond_pass);
wire [4:0]lsm_cnt = c_lsm_rgs[0] + c_lsm_rgs[1] + c_lsm_rgs[2] + c_lsm_rgs[3] + c_lsm_rgs[4] + c_lsm_rgs[5] + c_lsm_rgs[6] + c_lsm_rgs[7] +
                    c_lsm_rgs[8] + c_lsm_rgs[9] + c_lsm_rgs[10] + c_lsm_rgs[11] + c_lsm_rgs[12] + c_lsm_rgs[13] + c_lsm_rgs[14] + c_lsm_rgs[15];

//decode addressing mode 1
wire admode1 = (~f_t) && (instr[27:26] == 2'b00) && ({instr[25],instr[4],instr[7]} != 3'b011);
wire [4:0]rotate_amount = {instr[11:8], 1'b0};
wire [31:0]immed_8 = {24'b0, instr[7:0]};
reg [7:0]shift_amount;
reg [31:0]shifter_operand;
reg shifter_carry_out;

wire [31:0]admode1_shifter_operand;
wire admode1_shifter_carry_out;

shifter admode1_shifter1(r[rm], shift_amount, instr[4], f_c, instr[6:5], admode1_shifter_operand, admode1_shifter_carry_out);

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
wire admode2 = (~f_t) && (instr[27:26] == 2'b01);
wire admode3 = (~f_t) && (instr[27:25] == 3'b0) && (instr[6:5] != 2'b0);
wire admode23 = admode2 | admode3;

wire mode23_P = instr[24];
wire mode23_U = instr[23];
wire mode23_W = instr[21];
wire mode23_L = instr[20];
wire mode23_S = admode3 ? instr[6] : 1'b0;
wire [1:0]mode23_len = admode3 ? {1'b0, instr[5]} : (instr[22] ? 2'h0 : 2'h2); // 2: word, 1: halfword, 0: byte.

wire [31:0]mode2_offset;
admode2_shifter admode2_shifter1(instr, r[rm], f_c, mode2_offset);
wire [31:0]mode3_offset = instr[22] ? {24'b0, instr[11:8], instr[3:0]} : r[rm];
wire [31:0]mode23_offset = admode2 ? mode2_offset : mode3_offset;
wire [31:0]mode23_address_offset = mode23_U ? (r[rn] + mode23_offset) : (r[rn] - mode23_offset);
wire [31:0]mode23_address = mode23_P ? mode23_address_offset : r[rn];
//decode addressing mode 23 finish

//decode addressing mode 4
assign admode4 = (~f_t) && (instr[27:25] == 3'b100); //declared previosly

wire mode4_P = instr[24];
wire mode4_U = instr[23];
assign mode4_S = instr[22]; //declared previosly
wire mode4_W = instr[21];
wire mode4_L = instr[20];
assign mode4_ST = mode4_L & instr[15]; // When S == 1, S_type is 1 means CPSR loaded from SPSR, 0 means use Ri_usr.
//decode addressing mode 4 finish

//decode thumb
reg [3:0]t_rd;
reg [31:0]t_src1;
reg [31:0]t_src2;
reg [3:0]t_opcode; //opcode of specific ARM instruction

reg tm_loadstore = 1'b0;
reg tm_ls_L = 1'b0;
reg tm_ls_S = 1'b0;
reg [31:0]tm_ls_address = 32'h0;
reg [1:0]tm_ls_len = 2'h2; //default 32bit

reg tm_shift;
reg tm_shift_isrg;

reg t_alu; //perfrom an ARM style instuction
reg t_alu_update_cpsr;
reg ti_cb; //conditional branch
reg ti_b; //some branches
reg ti_lsm; //load store multiple
reg ti_push_pop;
reg ti_bx;
always @(*) begin
	t_rd = 4'h0;
	t_src1 = 32'h0;
	t_src2 = 32'h0;
	t_opcode = 4'h0;

	tm_loadstore = 1'b0;
	tm_ls_L = 1'b0;
	tm_ls_S = 1'b0;
	tm_ls_address = 32'h0;
	tm_ls_len = 2'h2;

	tm_shift = 1'b0;
	tm_shift_isrg = 1'b0;

	t_alu = 1'b0;
	t_alu_update_cpsr = 1'b1; //default update cpsr
	ti_cb = 1'b0;
	ti_b = 1'b0;
	ti_lsm = 1'b0;
	ti_push_pop = 1'b0;
	ti_bx = 1'b0;

	if(instr[15:11] == 5'b00011) begin
		t_rd = {1'b0, instr[2:0]};
		t_src1 = r[{1'b0, instr[5:3]}];
		t_src2 = instr[10] ? {29'h0, instr[8:6]} : r[{1'b0, instr[8:6]}];
		t_opcode = instr[9] ? 4'b0010 : 4'b0100;
		t_alu = 1'b1;
	end else if(instr[15:13] == 3'h0) begin //Shift by immediate
		tm_shift = 1'b1;
		t_rd = {1'b0, instr[2:0]};
		t_src1 = r[{1'b0, instr[5:3]}];
		t_src2 = {27'h0, instr[10:6]};
		t_opcode[1:0] = instr[12:11];
	end else if(instr[15:13] == 3'b001) begin //Add/subtract/compare/move immediate
		t_rd = {1'b0, instr[10:8]};
		t_src1 = r[t_rd];
		t_src2 = {24'h0, instr[7:0]};
		case(instr[12:11])
			2'b00: t_opcode = 4'b1101;//mov
			2'b01: t_opcode = 4'b1010;//cmp
			2'b10: t_opcode = 4'b0100;//add
			2'b11: t_opcode = 4'b0010;//sub
		endcase
		t_alu = 1'b1;
	end else if(instr[15:10] == 6'b010000) begin //Data processing register
		t_rd = {1'b0, instr[2:0]};
		t_src1 = r[t_rd];
		t_src2 = r[{1'b0, instr[5:3]}];
		t_opcode = instr[9:6];
		t_alu = 1'b1;
		case(t_opcode) //special opcodes
			4'b1001: begin //neg
				t_src1 = 32'h0;
				t_opcode = 4'b0010; //sub
			end
			4'b1101: begin //mul
				t_alu = 1'b0;
				//TODO
			end
			4'b0010: begin //lsl
				t_alu = 1'b0;
				tm_shift = 1'b1;
				tm_shift_isrg = 1'b1;
				t_opcode[1:0] = 2'b00;
			end
			4'b0011: begin //lsr
				t_alu = 1'b0;
				tm_shift = 1'b1;
				tm_shift_isrg = 1'b1;
				t_opcode[1:0] = 2'b01;
			end
			4'b0100: begin //asr
				t_alu = 1'b0;
				tm_shift = 1'b1;
				tm_shift_isrg = 1'b1;
				t_opcode[1:0] = 2'b10;
			end
			4'b0111: begin //ror
				t_alu = 1'b0;
				tm_shift = 1'b1;
				tm_shift_isrg = 1'b1;
				t_opcode[1:0] = 2'b11;
			end
			default: begin
			end
		endcase
	end else if(instr[15:7] == 9'b010001110) begin //bx
		ti_bx = 1'b1;
		t_rd = instr[6:3];
	end else if(instr[15:11] == 5'b01001) begin //load from literal pool
		t_rd = {1'b0, instr[10:8]};
		tm_loadstore = 1'b1;
		tm_ls_L = 1'b1;
		tm_ls_address = (r[15] & 32'hfffffffc) + {instr[7:0], 2'h0};
	end else if(instr[15:12] == 4'b0101) begin //Load/store register offset
		t_rd = {1'b0, instr[2:0]};
		tm_loadstore = 1'b1;
		tm_ls_L = instr[11];
		tm_ls_S = 1'b0;
		tm_ls_address = r[{1'b0, instr[8:6]}] + r[{1'b0, instr[5:3]}]; //rm + rn
		tm_ls_len = 2'h2 - instr[10:9];
	end else if(instr[15:12] == 4'b1011) begin //miscellaneous
		if(instr[11:8] == 4'h0) begin //Adjust stack pointer
			t_alu = 1'b1;
			t_opcode = instr[7] ? 4'b0010 : 4'b0100; // sub/add
			t_src1 = r[13];
			t_src2 = {23'h0, instr[6:0], 2'h0};
			t_rd = 4'd13;
			t_alu_update_cpsr = 1'b0;
		end else if(instr[10:9] == 2'b10) begin //push/pop register list
			ti_push_pop = 1'b1;
		end
	end else if(instr[15:12] == 4'b1100) begin //load store multiple
		ti_lsm = 1'b1;
		t_rd = {1'b0, instr[10:8]};
	end else if(instr[15:12] == 4'b1101) begin //Conditional branch
		ti_cb = 1'b1;
		t_src1 = r[15] + {{23{instr[7]}}, instr[7:0], 1'b0};
	end else if(instr[15:13] == 3'b111) begin //some branches
		ti_b = 1'b1;
		t_src1 = {21'h0, instr[10:0]};
	end
end
//decode thumb end

//load store
wire loadstore = admode23 | tm_loadstore;
wire ls_L = admode23 ? mode23_L : tm_ls_L;
wire ls_S = admode23 ? mode23_S : tm_ls_S;
wire [31:0]ls_address = admode23 ? mode23_address : tm_ls_address;
wire [1:0]ls_len = admode23 ? mode23_len : tm_ls_len;
wire [3:0]ls_rd = admode23 ? rd : t_rd;
//load store end


wire i_b = (~f_t) && itype == 3'b101;
wire i_bx = (~f_t) && instr[27:4] == 24'h12fff1; //bx seems to be in addressing mode 1
wire i_msr = (~f_t) && admode1 && (instr[24:23] == 2'b10) && (instr[21] == 1'b1) && ~i_bx; //msr is special

wire [31:0]alu_out;
wire alu_out_n, alu_out_z, alu_out_c, alu_out_v, alu_wrd;
alu alu1(f_t ? t_opcode : opcode,
			f_t ? t_src1 : r[rn],
			f_t ? t_src2 : shifter_operand,
			f_n, f_z, f_c, f_v, shifter_carry_out,
			alu_out, alu_out_n, alu_out_z, alu_out_c, alu_out_v, alu_wrd);

wire [31:0]shifter_out;
wire shifter_co;
shifter ex_shifter(t_src1, t_src2[7:0], tm_shift_isrg, f_c, t_opcode[1:0], shifter_out, shifter_co);

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
	
	c_lsm_address = lsm_address;
	c_lsm_rgs = lsm_rgs;
	c_lsm_L = lsm_L;

	for(i=0;i<16;i=i+1) begin
		cr_regw[i] = 1'b0;
		cr_regd[i] = 32'h0;
	end
	cr_spsrw = 1'b0;
	cr_spsrd = 32'h0;
	
	c_cpsr = cpsr;

	case (cpu_state)
		s_init: begin
			cr_regw[15] = 1'b1;
			cr_regd[15] = 32'h08000000;
			
			c_cpsr = 32'h13; //Supervisor mode

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
			c_next_state = s_ex;
			if(f_t || cond_pass) begin
				if(admode23 && (mode23_P == 1'b0 || mode23_W == 1'b1)) begin
					cr_regw[rn] = 1'b1;
					cr_regd[rn] = mode23_address_offset;
				end else if(admode4) begin
					c_lsm_L = mode4_L;
					c_lsm_address = r[rn] - (mode4_U ? {lsm_cnt, 2'b00} : 32'b0) + (mode4_P == mode4_U ? 32'h4 : 32'b0);
					c_lsm_rgs = instr[15: 0];
					c_next_state = s_lsm;
					if(mode4_W) begin
						cr_regw[rn] = 1'b1;
						cr_regd[rn] = mode4_U ? (r[rn] + {lsm_cnt, 2'b00}) : (r[rn] - {lsm_cnt, 2'b00});
					end
				end else if(f_t && ti_lsm) begin
					c_lsm_L = instr[11];
					c_lsm_address = r[t_rd];
					c_lsm_rgs = {8'h0, instr[7:0]};
					c_next_state = s_lsm;
					cr_regw[t_rd] = 1'b1;
					cr_regd[t_rd] = r[t_rd] - {lsm_cnt, 2'b0};
				end else if(f_t && ti_push_pop) begin
					c_lsm_L = instr[11];
					c_lsm_address = r[13] - {lsm_cnt, 2'h0};
					c_lsm_rgs = {1'b0, instr[8], 6'h0, instr[7:0]};
					c_next_state = s_lsm;
					cr_regw[13] = 1'b1;
					cr_regd[13] = c_lsm_address;
				end
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
							c_cpsr = msr_new_cpsr;
						end else begin //change spsr
							cr_spsrw = 1'b1;
							cr_spsrd = msr_new_spsr;
						end
					end else if(i_bx) begin //branch and exchange (into thumb mode)
						if(r[rm][0]) begin //to thumb mode
							c_cpsr[5] = 1'b1;
						end
						cr_regd[15] = r[rm] & 32'hfffffffe;
					end else begin //change a general register
						if(alu_wrd) begin
							cr_regw[rd] = 1'b1;
							cr_regd[rd] = alu_out;
						end
						if(update_cpsr) begin
							if(rd == 4'd15) c_cpsr = spsr;
							else begin
								c_cpsr[NFb] = alu_out_n;
								c_cpsr[ZFb] = alu_out_z;
								c_cpsr[CFb] = alu_out_c;
								c_cpsr[VFb] = alu_out_v;
							end
						end
					end
				end
				loadstore: begin
					addr_load = ls_address;
					if(ls_L) begin
						mem_read = 1'b1;
						cr_regw[ls_rd] = 1'b1;
						case({ls_S, ls_len})
							3'b000: cr_regd[ls_rd] = {24'b0, mem_data[7:0]};
							3'b001: cr_regd[ls_rd] = {16'b0, mem_data[15:0]};
							3'b010: cr_regd[ls_rd] = mem_data;
							3'b100: cr_regd[ls_rd] = {24'hff, mem_data[7:0]}; //TODO: real sign extend
							3'b101: cr_regd[ls_rd] = {16'hffff, mem_data[15:0]};
							default: ; // undefined
						endcase
					end else begin
						data_load = r[ls_rd];
						mem_width = ls_len;
						mem_write = 1'b1;
					end
				end
				t_alu: begin
					cr_regw[t_rd] = 1'b1;
					cr_regd[t_rd] = alu_out;
					if(t_alu_update_cpsr) begin
						c_cpsr[NFb] = alu_out_n;
						c_cpsr[ZFb] = alu_out_z;
						c_cpsr[CFb] = alu_out_c;
						c_cpsr[VFb] = alu_out_v;
					end
				end
				tm_shift: begin
					cr_regw[t_rd] = 1'b1;
					cr_regd[t_rd] = shifter_out;
					c_cpsr[NFb] = shifter_out[31];
					c_cpsr[ZFb] = shifter_out == 32'h0 ? 1'b1 : 1'b0;
					c_cpsr[CFb] = shifter_co;
				end
				ti_cb: begin //conditional branch
					if(cond_pass) cr_regd[15] = t_src1;
				end
				ti_b: begin //some brances
					case(instr[12:11])
						2'b00: cr_regd[15] = r[15] + {{20{t_src1[10]}}, t_src1[10:0], 1'b0};
						2'b10: begin
							cr_regw[14] = 1'b1;
							cr_regd[14] = r[15] + {{9{t_src1[10]}}, t_src1[10:0], 12'h0};
						end
						2'b11: begin
							cr_regd[15] = r[14] + {20'h0, instr[10:0], 1'b0};
							cr_regw[14] = 1'b1;
							cr_regd[14] = seq_pc | 1;
						end
						default: begin//armv5t instruction, should not reach here
						end
					endcase
				end
				ti_bx: begin //bx
					c_cpsr[5] = r[t_rd][0];
					cr_regd[15] = {r[t_rd][31:1], 1'b0};
				end
				default: begin
				// undefined instruction
				// TODO: should raise interrupt
				end
			endcase
			
			if((!loadstore) || mem_ok) begin
				c_next_state = s_if;
			end else begin //wait for memory
				for(i=0;i<16;i=i+1) cr_regw[i] = 1'b0;
				c_cpsr = cpsr;
				cr_spsrw = 1'b0;
				c_next_state = s_ex;
			end
		end
		s_lsm: begin
			addr_load = lsm_address;
			if(lsm_L) begin
				mem_read = 1'b1;
				cr_regw[lsm_rd] = 1'b1;
				cr_regd[lsm_rd] = mem_data;
			end else begin
				mem_write = 1'b1;
				data_load = r[lsm_rd];
			end

			c_lsm_address = lsm_address + 32'h4;
			c_lsm_rgs = lsm_rgs;
			c_lsm_rgs[lsm_rd] = 1'b0;

			if(c_lsm_rgs == 16'h0) begin
				cr_regw[15] = 1'b1;
				cr_regd[15] = seq_pc;
				if(admode4) begin // admode4
					if(mode4_S && mode4_ST) c_cpsr = spsr;
					if(lsm_rd == 4'hf && mode4_L && mode4_S) cr_regd[15] = cr_regd[15] & 32'hfffffffc;
				end
				c_next_state = s_if;
			end else c_next_state = s_lsm;
		end
		default: begin
			//should not reach here
			c_next_state = s_init;
		end
	endcase
	
	if(!rstn) c_next_state = s_init;
end

endmodule
