// Name: Mohammed Alsoughayer, Sean Brandenburg
// EC413 Project: Top Level Module

module top #(
  parameter ADDRESS_BITS = 16
) (
  input clock,
  input reset,

  output [31:0] wb_data
);


/******************************************************************************
*                      Start Your Code Here
******************************************************************************/

// Fetch Wires //
	wire next_PC_select;
	wire [ADDRESS_BITS-1:0]target_PC;
	wire [ADDRESS_BITS-1:0]PC;

// Decode Wires
	
	//Inputs
	//wire [ADDRESS_BITS-1:0] PC;
	wire [31:0] instruction;
	//From Execute/ALU
	wire [ADDRESS_BITS-1:0] JALR_target;
	wire branch;

	// Outputs to Execute/ALU
	wire branch_op;
	wire signed [31:0] imm32;
	wire [1:0] op_A_sel;
	wire op_B_sel;
	//wire [5:0] ALU_Control;
	
	wire [4:0] read_sel2;

// Reg File Wires //
	
	//INPUTS
	wire wEn;
	wire [31:0] write_data;
	wire [4:0] read_sel1;
	wire [4:0] read_sel2_mux;
	wire [4:0] write_sel;
	
	//OUTPUTS
	wire [31:0] read_data1;
	wire [31:0] read_data2;

// ALU Wires //
	//wire branch_op;
	wire [5:0]ALU_Control;
	wire [31:0]operand_A; //Mux output
	wire [31:0]operand_B; //Mux output
	wire [31:0]ALU_result;
	//wire branch;

// Memory Wires //

	// Instruction Port
	//wire [15:0]PC;
	//wire [31:0]instruction;

	// Data Port
	wire mem_wEn;
	//wire [31:0]ALU_result;
	//wire [31:0]read_data2;
	wire [31:0]d_read_data;

// Writeback wires //
	wire wb_sel;
	
//Muxes
	assign write_data = (wb_sel)? d_read_data:ALU_result;
	
	assign operand_A = (op_A_sel == 2'b00) ? read_data1:
							 (op_A_sel == 2'b01) ? PC:
							 (op_A_sel == 2'b10) ? (PC + 16'd4):
							 (0);
							 
	assign operand_B = (op_B_sel) ? imm32:read_data2;
							 

	assign wb_data = write_data;
	
	//Read_select2 mux 
	assign read_sel2_mux = (instruction[6:0] == 7'b1100111 && instruction[14:12] == 3'b000) ? 0 : read_sel2;
	
//JALR passthrough

	assign JALR_target = imm32 + read_data1;
	


fetch #(
  .ADDRESS_BITS(ADDRESS_BITS)
) fetch_inst (
  .clock(clock),
  .reset(reset),
  .next_PC_select(next_PC_select),
  .target_PC(target_PC),
  .PC(PC)
);


decode #(
  .ADDRESS_BITS(ADDRESS_BITS)
) decode_unit (

  // Inputs from Fetch
  .PC(PC),
  .instruction(instruction),

  // Inputs from Execute/ALU
  .JALR_target(JALR_target),
  .branch(branch),

  // Outputs to Fetch
  .next_PC_select(next_PC_select),
  .target_PC(target_PC),

  // Outputs to Reg File
  .read_sel1(read_sel1),
  .read_sel2(read_sel2),
  .write_sel(write_sel),
  .wEn(wEn),

  // Outputs to Execute/ALU
  .branch_op(branch_op),
  .imm32(imm32),
  .op_A_sel(op_A_sel), 
  .op_B_sel(op_B_sel), 
  .ALU_Control(ALU_Control),

  // Outputs to Memory
  .mem_wEn(mem_wEn),

  // Outputs to Writeback
  .wb_sel(wb_sel)

);


regFile regFile_inst (
  .clock(clock),
  .reset(reset),
  .wEn(wEn),
  .write_data(write_data), 
  .read_sel1(read_sel1),
  .read_sel2(read_sel2_mux),
  .write_sel(write_sel),
  .read_data1(read_data1), 
  .read_data2(read_data2) 
);


ALU alu_inst(
  .branch_op(branch_op),
  .ALU_Control(ALU_Control),
  .operand_A(operand_A),
  .operand_B(operand_B), 
  .ALU_result(ALU_result),
  .branch(branch)
);


ram #(
  .ADDR_WIDTH(ADDRESS_BITS)
) main_memory (
  .clock(clock),

  // Instruction Port
  .i_address(PC),
  .i_read_data(instruction),

  // Data Port
  .wEn(mem_wEn),
  .d_address(ALU_result[ADDRESS_BITS-1:0]), 
  .d_write_data(read_data2),
  .d_read_data(d_read_data)
);

endmodule
