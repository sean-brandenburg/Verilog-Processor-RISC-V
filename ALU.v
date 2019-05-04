// Name: Mohammed Alsoughayer, Sean Brandenburg
// EC413 Project: ALU

module ALU (
  input branch_op,
  input [5:0]  ALU_Control,
  input [31:0] operand_A,
  input [31:0] operand_B,
  output [31:0] ALU_result,
  output branch
);

wire signed [31:0]s_op_a, s_op_b, SLT;

//Signed operands
assign s_op_a = operand_A;
assign s_op_b = operand_B;

assign SLT = s_op_a < s_op_b;
assign SGTE = s_op_a >= s_op_b;

//Determine output of ALU
assign ALU_result = (ALU_Control == 6'b000000) ? (operand_A + operand_B): //Add (LUI,AUIPC,LW,SW,ADDI,ADD)
						  (ALU_Control == 6'b001000) ? (operand_A - operand_B): //Sub (SUB)
						  
						  (ALU_Control == 6'b000010) ? (SLT): // Signed Less Than (SLTI,SLT,BLT)
						  (ALU_Control == 6'b010110 || ALU_Control == 6'b000011) ? (operand_A < operand_B): //Unsigned Less Than (BLTU,SLTIU,SLTU)
						  (ALU_Control == 6'b010101) ? (SGTE): // Signed Greater Than or Equal To (BGE)
						  (ALU_Control == 6'b010111) ? (operand_A >= operand_B): //Unsigned Greater Than or Equal To (BGEU)
						  
						  (ALU_Control == 6'b000110) ? (operand_A | operand_B): //Or (OR,ORI)
						  (ALU_Control == 6'b000100) ? (operand_A ^ operand_B): //Xor (XORI,XOR)
						  (ALU_Control == 6'b000111) ? (operand_A & operand_B): //And (ANDI,AND)
						  
						  (ALU_Control == 6'b000001) ? (operand_A << operand_B): //Logical Shift Left (SLLI,SLL)
						  (ALU_Control == 6'b000101) ? (operand_A >> operand_B): //Logical Shift Right (SRLI,SRL)
						  (ALU_Control == 6'b001101) ? (operand_A >>> operand_B): //Arithmetic Shift Right (SRAI,SRA)
						  
						  (ALU_Control == 6'b010000) ? (operand_A == operand_B): //Equals	(BEQ)
						  (ALU_Control == 6'b010001) ? (operand_A != operand_B): //Not Equals (BNE)
						  
						  (ALU_Control == 6'b011111 || ALU_Control == 6'b111111) ? (operand_A): //Passthrough (JAL,JALR)
							
							1'b0; //Default Case


//Determines whether a branch should be taken
assign branch = (branch_op == 0) ? 1'b0:
					 ((ALU_Control == 6'b010000) && (operand_A == operand_B)) ? 1'b1: //BEQ
					 ((ALU_Control == 6'b010001) && (operand_A != operand_B)) ? 1'b1: //BNE
					 ((ALU_Control == 6'b000010) && (SLT)) ? 1'b1: //BLT
					 ((ALU_Control == 6'b010101) && (SGTE)) ? 1'b1: //BGE
					 ((ALU_Control == 6'b010110) && (operand_A < operand_B)) ? 1'b1: //BLTU
					 ((ALU_Control == 6'b010111) && (operand_A >= operand_B)) ? 1'b1: // BGEU
					 1'b0; //Default Case 
					 

endmodule
