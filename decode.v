// Name: Mohammed Alsoughayer, Sean Brandenburg
// EC413 Project: Decode Module

module decode #(
  parameter ADDRESS_BITS = 16
) (
  // Inputs from Fetch
  input [ADDRESS_BITS-1:0] PC,
  input [31:0] instruction,

  // Inputs from Execute/ALU
  input [ADDRESS_BITS-1:0] JALR_target,
  input branch,

  // Outputs to Fetch
  output reg next_PC_select,
  output [ADDRESS_BITS-1:0] target_PC,

  // Outputs to Reg File
  output [4:0] read_sel1,
  output [4:0] read_sel2,
  output [4:0] write_sel,
  output reg wEn,

  // Outputs to Execute/ALU
  output reg branch_op, // Tells ALU if this is a branch instruction
  output [31:0] imm32,
  output reg [1:0] op_A_sel,
  output reg op_B_sel,
  output reg [5:0] ALU_Control,

  // Outputs to Memory
  output reg mem_wEn,

  // Outputs to Writeback
  output reg wb_sel

);

localparam [6:0]R_TYPE  = 7'b0110011,
                I_TYPE  = 7'b0010011,
                STORE   = 7'b0100011,
                LOAD    = 7'b0000011,
                BRANCH  = 7'b1100011,
                JALR    = 7'b1100111,
                JAL     = 7'b1101111,
                AUIPC   = 7'b0010111,
                LUI     = 7'b0110111;


// These are internal wires that I used. You can use them but you do not have to.
// Wires you do not use can be deleted.
wire[6:0]  s_imm_msb;
wire[4:0]  s_imm_lsb;
wire[19:0] u_imm;
wire[11:0] i_imm_orig;
wire[20:0] uj_imm;
wire[11:0] s_imm_orig;
wire[12:0] sb_imm_orig;
wire[4:0] shamt;

wire[31:0] sb_imm_32;
wire[31:0] u_imm_32;
wire[31:0] i_imm_32;
wire[31:0] s_imm_32;
wire[31:0] uj_imm_32; // sign extend and and assign the right one 
wire[31:0] shamt_32;

wire [6:0] opcode;
wire [6:0] funct7;
wire [2:0] funct3;
wire [1:0] extend_sel;
wire [ADDRESS_BITS-1:0] branch_target;
wire [ADDRESS_BITS-1:0] JAL_target;


// Read registers
assign read_sel2  = instruction[24:20];
assign read_sel1  = instruction[19:15];

/* Instruction decoding */
assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];

/* Write register */
assign write_sel = instruction[11:7];

//immediates calculations 
assign s_imm_msb = instruction[31:25];
assign s_imm_lsb = instruction[11:7];
assign s_imm_orig = {s_imm_msb, s_imm_lsb};
assign s_imm_32 = { {20{s_imm_orig[11]}},s_imm_orig}; // S-Type
assign i_imm_orig = instruction[31:20];
assign i_imm_32 = { {20{i_imm_orig[11]}}, i_imm_orig}; // I-type
assign u_imm = instruction[31:12];
assign u_imm_32 = {u_imm, 12'b000000000000}; // U-type
assign sb_imm_orig = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
assign sb_imm_32 = { {19{sb_imm_orig[12]}}, sb_imm_orig}; //SB-type
assign uj_imm = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
assign uj_imm_32 = { {11{uj_imm[20]}}, uj_imm}; // UJ-type 
assign shamt = instruction[24:20];
assign shamt_32 = {27'b000000000000000000000000000, shamt};

assign imm32 =  (opcode == 7'b0010011 && funct3 == 3'b001)? shamt_32:  //SLLI
				    (opcode == 7'b0010011 && funct3 == 3'b101)? shamt_32:  //SRLI
					 (opcode == 7'b0010011)? i_imm_32:  //I-type
					 (opcode == 7'b0000011)? i_imm_32:  //Load
					 (opcode == 7'b0100011)? s_imm_32:  //S-type
					 (opcode == 7'b1100011)? sb_imm_32: //Branches
					 (opcode == 7'b1101111)? uj_imm_32: //JAL
					 (opcode == 7'b1100111)? i_imm_32:  //JALR
					 (opcode == 7'b0010111)? u_imm_32:  //Auipc
					 (opcode == 7'b0110111)? u_imm_32:  //Lui
					 0;  //default 

//target PC calculations 					 
assign target_PC = (opcode == 7'b1100011)? (PC + sb_imm_32[15:0]): //branch instructions 
						 (opcode == 7'b1101111)? (PC + uj_imm_32[15:0]): //jal instruction
						 (opcode == 7'b1100111)? JALR_target:				 //jalr instruction 
						 0; //default 
						 
//signal calculations for most wires 
  always @(*) begin 
    case (opcode) 
	   7'b0110011: begin // R-type
		  next_PC_select = 0;
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b00;
		  op_B_sel = 0;
		  wb_sel = 0;
		  wEn = 1;
		  if (funct3 == 3'b000) begin 
		    if (funct7 == 7'b0000000) begin 
			   ALU_Control = 6'b000000; //add
			 end else begin 
			   ALU_Control = 6'b001000; //sub
			 end 
		  end else if (funct3 == 3'b010) begin 
		    ALU_Control = 6'b000010; //slt
		  end else if (funct3 == 3'b100) begin 
		    ALU_Control = 6'b000100; //xor
		  end else if (funct3 == 3'b111) begin 
		    ALU_Control = 6'b000111; //and
		  end else if (funct3 == 3'b001) begin
		    ALU_Control = 6'b000001; //sll
		  end else if (funct3 == 3'b011) begin
		    ALU_Control = 6'b000010; //sltu
		  end else if (funct3 == 3'b110) begin
		    ALU_Control = 6'b000110; //or
		  end else if (funct3 == 3'b101) begin
		    if (funct7 == 7'b0000000) begin
			   ALU_Control = 6'b000101; //srl
			 end else begin 
			   ALU_Control = 6'b001101; //sra
			 end 
		  end 
      end 		  
		7'b0010011: begin //I-type
		  next_PC_select = 0;
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b00;
		  op_B_sel = 1;
		  wb_sel = 0;
		  wEn = 1;
		  if (funct3 == 3'b000) begin
		    ALU_Control = 6'b000000; //addi 
		  end else if (funct3 == 3'b001) begin
			 ALU_Control = 6'b000001; //slli
		  end else if (funct3 == 3'b010) begin
			 ALU_Control = 6'b000011; //slti
		  end else if (funct3 == 3'b011) begin
			 ALU_Control = 6'b000011; //sltiu
		  end else if (funct3 == 3'b100) begin 
			 ALU_Control = 6'b000100; //xori
		  end else if (funct3 == 3'b101) begin 
		    if (funct7 == 7'b0000000) begin 
			   ALU_Control = 6'b000101; //srli
			 end else begin 
			   ALU_Control = 6'b001101; //srai
			 end
		  end else if (funct3 == 3'b110) begin
		    ALU_Control = 6'b000110; //ori
		  end else if (funct3 == 3'b111) begin 
		    ALU_Control = 6'b000111; //andi
		  end
		end
      7'b0000011: begin //Load
		  next_PC_select = 0;
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b00;
		  op_B_sel = 1;
		  wb_sel = 1;
		  wEn = 1;
		  ALU_Control = 6'b000000;
		end 
      7'b0100011: begin //Store
		  next_PC_select = 0;
		  branch_op = 0;
		  mem_wEn = 1;
		  op_A_sel = 2'b00;
		  op_B_sel = 1;
		  wb_sel = 0;
		  wEn = 0;
		  ALU_Control = 6'b000000;
		end
		7'b1100011: begin //Branch 
		  branch_op = 1;
		  mem_wEn = 0;
		  op_A_sel = 2'b00;
		  op_B_sel = 0;
		  wb_sel = 0;
		  wEn = 0;
		  if (branch) begin 
		    next_PC_select = 1;
		  end else begin 
		    next_PC_select = 0;
		  end
		  if (funct3 == 3'b000) begin 
		    ALU_Control = 6'b010000; //beq
		  end else if (funct3 == 3'b001) begin 
		    ALU_Control = 6'b010001; //bne
        end else if (funct3 == 3'b100) begin 
		    ALU_Control = 6'b000010; //blt
        end else if (funct3 == 3'b101) begin 
		    ALU_Control = 6'b010101; //bge
        end else if (funct3 == 3'b110) begin 
		    ALU_Control = 6'b010110; //bltu
        end else if (funct3 == 3'b111) begin 
		    ALU_Control = 6'b010111; //bgeu
        end 
		end
		7'b1100111: begin //Jalr
		  next_PC_select = 1;
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b10; // PC + 4
		  op_B_sel = 0;
		  wb_sel = 0;
		  wEn = 1;
		  ALU_Control = 6'b111111;
		end
		7'b1101111: begin //Jal
		  next_PC_select = 1;
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b10;  // PC + 4 
		  op_B_sel = 0;
		  wb_sel = 0;
		  wEn = 1;
		  ALU_Control = 6'b011111;
		end
		7'b0010111: begin //Auipc//
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b01; // PC
		  op_B_sel = 1;
		  wb_sel = 0;
		  wEn = 1;
		  ALU_Control = 6'b000000;
		end
		7'b0110111: begin //Lui
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b11; // hard code zero  
		  op_B_sel = 1;
		  wb_sel = 0;
		  wEn = 1;
		  ALU_Control = 6'b000000;
		end
    endcase 
  end	 



endmodule
