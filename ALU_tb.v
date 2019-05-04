// Name: Mohammed Alsoughayer, Sean Brandenburg
// EC413 Project: ALU Test Bench

module ALU_tb();
reg branch_op;
reg [5:0] ctrl;
reg [31:0] opA, opB;

wire [31:0] result;
wire branch;

ALU dut (
  .branch_op(branch_op),
  .ALU_Control(ctrl),
  .operand_A(opA),
  .operand_B(opB),
  .ALU_result(result),
  .branch(branch)
);

initial begin
  branch_op = 1'b0;
  ctrl = 6'b000000;
  opA = 4;
  opB = 5;

  #10
  $display("ALU Result 4 + 5: %d",result);
  #10
  ctrl = 6'b000010;
  #10
  $display("ALU Result 4 < 5: %d",result);
  #10
  opB = 32'hffffffff;
  #10
  $display("ALU Result 4 < -1: %d",result);

  branch_op = 1'b1;
  opB = 32'hffffffff;
  opA = 32'hffffffff;
  ctrl = 6'b010_000; // BEQ
  #10
  $display("ALU Result (BEQ): %d",result);
  $display("Branch (should be 1): %b", branch);

/******************************************************************************
*                      Add Test Cases Here
******************************************************************************/

  opA = 32'h00000020;
  opB = 32'h0000000f;
  branch_op = 0;
  ctrl = 6'b000000;
  #10
  $display("ALU Result 36 + 15: %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'h00000020;
  opB = 32'h0000000f;
  branch_op = 0;
  ctrl = 6'b001000;
  #10
  $display("ALU Result 36 - 15: %d",result);
  $display("Branch Op(0): %d",branch);

  
  opA = 32'hfffffffe;
  opB = 32'h0000000f;
  branch_op = 0;
  ctrl = 6'b000010;
  #10
  $display("ALU Result -1 < 15 (signed): %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'hfffffffe;
  opB = 32'h0000000f;
  branch_op = 1;
  ctrl = 6'b000010;
  #10
  $display("ALU Result -1 < 15 (signed): %d",result);
  $display("Branch Op(1): %d",branch);
  
  opA = 32'h00000010;
  opB = 32'h0000000f;
  branch_op = 1;
  ctrl = 6'b000010;
  #10
  $display("ALU Result 16 < 15 (signed): %d",result);
  $display("Branch Op(1): %d",branch);

  opA = 32'hfffffffe;
  opB = 32'h0000000f;
  branch_op = 0;
  ctrl = 6'b010110;
  #10
  $display("ALU Result fffffffe < 15 (unsigned): %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'hfffffffe;
  opB = 32'h0000000f;
  branch_op = 1;
  ctrl = 6'b010110;
  #10
  $display("ALU Result fffffffe < 15 (unsigned): %d",result);
  $display("Branch Op(1): %d",branch);
  
  opA = 32'h00000001;
  opB = 32'h0000000f;
  branch_op = 1;
  ctrl = 6'b010110;
  #10
  $display("ALU Result 1 < 15 (unsigned): %d",result);
  $display("Branch Op(1): %d",branch);
  
  opA = 32'hfffffffd;
  opB = 32'h00000001;
  branch_op = 0;
  ctrl = 6'b010101;
  #10
  $display("ALU Result -2 >= 1 (signed): %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'h00000010;
  opB = 32'h00000001;
  branch_op = 1;
  ctrl = 6'b010101;
  #10
  $display("ALU Result 16 >= 1 (signed): %d",result);
  $display("Branch Op(1): %d",branch);
  
  opA = 32'hfffffffd;
  opB = 32'h00000001;
  branch_op = 1;
  ctrl = 6'b010101;
  #10
  $display("ALU Result -2 >= 1 (signed): %d",result);
  $display("Branch Op(1): %d",branch);
    
  opA = 32'hfffffffd;
  opB = 32'h00000001;
  branch_op = 0;
  ctrl = 6'b010111;
  #10
  $display("ALU Result fffffffd >= 1 (unsigned): %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'hfffffffd;
  opB = 32'h00000001;
  branch_op = 1;
  ctrl = 6'b010111;
  #10
  $display("ALU Result fffffffd >= 1 (unsigned): %d",result);
  $display("Branch Op(1): %d",branch);
  
  opA = 32'h00000000;
  opB = 32'h00000001;
  branch_op = 1;
  ctrl = 6'b010111;
  #10
  $display("ALU Result 0 >= 1 (unsigned): %d",result);
  $display("Branch Op(1): %d",branch);
  
  opA = 32'b00000000000000000000000000000101;
  opB = 32'b00000000000000000000000000000010;
  branch_op = 0;
  ctrl = 6'b000110;
  #10
  $display("ALU Result Bitwise OR of 00000000000000000000000000000101 and 00000000000000000000000000000010: %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'b00000000000000000000000000000101;
  opB = 32'b00000000000000000000000000000010;
  branch_op = 0;
  ctrl = 6'b000100;
  #10
  $display("ALU Result Bitwise XOR of 00000000000000000000000000000101 and 00000000000000000000000000000010: %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'b00000000000000000000000000000101;
  opB = 32'b00000000000000000000000000000011;
  branch_op = 0;
  ctrl = 6'b000111;
  #10
  $display("ALU Result Bitwise AND of 00000000000000000000000000000101 and 00000000000000000000000000000011: %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'b10000000000000000000000000000101;
  opB = 32'b00000000000000000000000000000010;
  branch_op = 0;
  ctrl = 6'b000001;
  #10
  $display("ALU Result 10000000000000000000000000000101 left shifted by 2: %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'b10000000000000000000000000000101;
  opB = 32'b00000000000000000000000000000010;
  branch_op = 0;
  ctrl = 6'b000101;
  #10
  $display("ALU Result 10000000000000000000000000000101 right shifted by 2: %d",result);
  $display("Branch Op(0): %d",branch);

  opA = 32'b10000000000000000000000000000101;
  opB = 32'b00000000000000000000000000000010;
  branch_op = 0;
  ctrl = 6'b001101;
  #10
  $display("ALU Result 10000000000000000000000000000101 arithmetically right shifted by 2: %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'h00000001;
  opB = 32'h00000001;
  branch_op = 0;
  ctrl = 6'b010000;
  #10
  $display("ALU Result 1 == 1: %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'h00000001;
  opB = 32'h00000001;
  branch_op = 1;
  ctrl = 6'b010000;
  #10
  $display("ALU Result 1 == 1: %d",result);
  $display("Branch Op(1): %d",branch);
  
  opA = 32'h00000001;
  opB = 32'h00000011;
  branch_op = 1;
  ctrl = 6'b010000;
  #10
  $display("ALU Result 1 == 3: %d",result);
  $display("Branch Op(1): %d",branch);

  
  opA = 32'h00000001;
  opB = 32'h00000001;
  branch_op = 0;
  ctrl = 6'b010001;
  #10
  $display("ALU Result 1 != 1: %d",result);
  $display("Branch Op(0): %d",branch);
  
  opA = 32'h00000001;
  opB = 32'h00000001;
  branch_op = 1;
  ctrl = 6'b010001;
  #10
  $display("ALU Result 1 != 1: %d",result);
  $display("Branch Op(1): %d",branch);
  
  opA = 32'h00000001;
  opB = 32'h00000011;
  branch_op = 1;
  ctrl = 6'b010001;
  #10
  $display("ALU Result 1 != 3: %d",result);
  $display("Branch Op(1): %d",branch);
  
  opA = 32'h00000001;
  opB = 32'h00000001;
  branch_op = 0;
  ctrl = 6'b111111;
  #10
  $display("ALU Result 1 passed through: %d",result);
  $display("Branch Op(0): %d",branch);  
  
  #10
  $stop();
end

endmodule 
