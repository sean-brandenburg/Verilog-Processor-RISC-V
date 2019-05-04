// Name: Mohammed Alsoughayer, Sean Brandenburg
// EC413 Project: Register File

module regFile (
  input clock,
  input reset,
  input wEn, // Write Enable
  input [31:0] write_data,
  input [4:0] read_sel1,
  input [4:0] read_sel2,
  input [4:0] write_sel,
  output [31:0] read_data1,
  output [31:0] read_data2
);

  reg   [31:0] reg_file[0:31];

  always@(posedge clock) begin
    if (reset) begin 
	   reg_file[0] <= 0;
	 end else begin 
	   if (wEn && (write_sel != 5'b00000)) begin 
		  reg_file[write_sel] <= write_data;
		end 
	 end
  end
  
  assign read_data1 = reg_file[read_sel1];
  assign read_data2 = reg_file[read_sel2];	 
endmodule 
