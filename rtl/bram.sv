module bram #(
    parameter DATA_WIDTH = 128,
    parameter DEPTH = 256
) (
  input     logic                       clk,
  input     logic[$clog2(DEPTH)-1:0]    addr,
  input     logic[DATA_WIDTH-1:0]       data_in,
  input     logic                       we,
  input     logic                       re,
  output    logic[DATA_WIDTH-1:0]       data_out
);

  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  always @(posedge clk) begin
    if (we) begin
      mem[addr] <= data_in;
    end
    if (re) begin
      data_out <= mem[addr];
    end
  end

endmodule
