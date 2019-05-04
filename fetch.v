// Name: Mohammed Alsoughayer, Sean Brandenburg
// EC413 Project: Fetch Module

module fetch #(
  parameter ADDRESS_BITS = 16
) (
  input  clock,
  input  reset,
  input  next_PC_select,
  input  [ADDRESS_BITS-1:0] target_PC,
  output [ADDRESS_BITS-1:0] PC
);

reg [ADDRESS_BITS-1:0] PC_reg;

assign PC = PC_reg;

/******************************************************************************
*                      Start Your Code Here
******************************************************************************/

always@(posedge clock) begin
	
	if(reset) PC_reg <= 0;
	else if(next_PC_select) PC_reg <= target_PC;
	else PC_reg <= PC_reg + 16'b0000000000000100;

end

endmodule
