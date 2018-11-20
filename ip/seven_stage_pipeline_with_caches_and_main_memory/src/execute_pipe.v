/** @module : execute_pipe_unit
 *  @author : Adaptive & Secure Computing Systems (ASCS) Laboratory

 *  Copyright (c) 2018 BRISC-V (ASCS/ECE/BU)
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.

 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */
//////////////////////////////////////////////////////////////////////////////////


module execute_pipe_unit #(
  parameter DATA_WIDTH = 32,
  parameter ADDRESS_BITS = 20
) (
  input clock,
  input reset,
  input dcache_ready,
  input stall_wb,
  input stall,  //stall signal for previous stages (not used)

  input [DATA_WIDTH-1:0] ALU_result_execute,
  input [DATA_WIDTH-1:0] store_data_execute,
  input [4:0] rd_execute,
  input [6:0] opcode_execute,
  input [1:0] next_PC_select_execute,
  input memRead_execute,
  input memWrite_execute,
  input regWrite_execute,
  input [DATA_WIDTH-1:0] instruction_execute,
  input [ADDRESS_BITS-1:0] PC_execute,

  output reg [DATA_WIDTH-1:0] ALU_result_memory1,
  output reg [DATA_WIDTH-1:0] store_data_memory1,
  output reg [4:0] rd_memory1,
  output reg [6:0] opcode_memory1,
  output reg [1:0] next_PC_select_memory1,
  output reg memRead_memory1,
  output reg memWrite_memory1,
  output reg regWrite_memory1,
  output stall_mem,
  output reg [DATA_WIDTH-1:0] instruction_memory1,
  output reg [ADDRESS_BITS-1:0] PC_memory1
);

localparam NOP = 32'h00000013;

always @(posedge clock) begin
  if(reset) begin
    ALU_result_memory1     <= {DATA_WIDTH{1'b0}};
    store_data_memory1     <= {DATA_WIDTH{1'b0}};
    rd_memory1             <= 5'b0;
    opcode_memory1         <= 7'b0;
    memRead_memory1        <= 1'b0;
    memWrite_memory1       <= 1'b0;
    next_PC_select_memory1 <= 2'b0;
    regWrite_memory1       <= 1'b0;
    instruction_memory1    <= NOP;
    PC_memory1             <= {ADDRESS_BITS{1'b0}};
  end else if(stall_mem | stall_wb)begin
    ALU_result_memory1     <= ALU_result_memory1;
    store_data_memory1     <= store_data_memory1;
    rd_memory1             <= rd_memory1;
    opcode_memory1         <= opcode_memory1;
    memRead_memory1        <= memRead_memory1; 
    memWrite_memory1       <= 1'b0;
    next_PC_select_memory1 <= next_PC_select_memory1;
    regWrite_memory1       <= regWrite_memory1;
    instruction_memory1    <= instruction_memory1;
    PC_memory1             <= PC_memory1;
  end else begin
    ALU_result_memory1     <= ALU_result_execute;
    store_data_memory1     <= store_data_execute;
    rd_memory1             <= rd_execute;
    opcode_memory1         <= opcode_execute;
    memRead_memory1        <= memRead_execute;
    memWrite_memory1       <= memWrite_execute;
    next_PC_select_memory1 <= next_PC_select_execute;
    regWrite_memory1       <= regWrite_execute;
    instruction_memory1    <= instruction_execute;
    PC_memory1             <= PC_execute;
  end
end

assign stall_mem = ~dcache_ready & (memRead_execute | memWrite_execute);

endmodule
