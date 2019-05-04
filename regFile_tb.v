// Name: Mohammed Alsoughayer, Sean Brandenburg
// EC413 Project: Register File Test Bench

module regFile_tb();

reg clock, reset;
reg wEn;
reg [4:0] read_sel1, read_sel2, write_sel;
wire [31:0] read_data1, read_data2;
reg [31:0] write_data;
integer x;
// Fill in port connections
regFile uut (
  .clock(clock),
  .reset(reset),
  .wEn(wEn), // Write Enable
  .write_data(write_data),
  .read_sel1(read_sel1),
  .read_sel2(read_sel2),
  .write_sel(write_sel),
  .read_data1(read_data1),
  .read_data2(read_data2)
);


always #5 clock = ~clock;

initial begin
  clock = 1'b1;
  reset = 1'b1;
  read_sel1 = 0;
  read_sel2 = 0;
  write_sel = 0;
  write_data = 0;
  #20;
  reset = 1'b0;
  wEn = 1'b1;
  write_sel = 5'b00001;
  write_data = 32'b00000000000000000000000000000001;
  for( x=0; x<32; x=x+1) begin
    $display("Register %d: %h", x, uut.reg_file[x]);
  end
  #20
  write_sel = 5'b11111;
  write_data = 32'b00000000000000000000000000111111;
  for( x=0; x<32; x=x+1) begin
    $display("Register %d: %h", x, uut.reg_file[x]);
  end
  #20
  read_sel1 = 5'b00001;
  read_sel2 = 5'b11111;


end
endmodule 
