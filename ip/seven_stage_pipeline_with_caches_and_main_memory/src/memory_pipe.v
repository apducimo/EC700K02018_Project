/** @module : memory_pipe_unit
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


module memory_pipe_unit #(
  parameter DATA_WIDTH   = 32,
  parameter ADDRESS_BITS = 20
) (
  input clock,
  input reset,
  input stall_mem, //stall signal for from previous stage (dcache not ready)

  input [DATA_WIDTH-1:0] ALU_result_memory1, 
  input [DATA_WIDTH-1:0] load_data_memory2,  
  input [ADDRESS_BITS-1:0] load_data_addr,   
  input load_data_valid,                     
  input opwrite_memory1,
  input opSel_memory1,                      
  input [4:0] opReg_memory1,                 
  input [1:0] next_PC_select_memory1,        
  input [DATA_WIDTH-1:0] instruction_memory1,
  input [ADDRESS_BITS-1:0] PC_memory1,
  input [6:0] opcode_memory1,

  output reg [DATA_WIDTH-1:0] ALU_result_writeback, 
  output reg [DATA_WIDTH-1:0] load_data_writeback,
  output reg opwrite_writeback,                     
  output reg opSel_writeback,                       
  output reg [4:0] opReg_writeback,                 
  output reg [1:0] next_PC_select_writeback,        
  output reg [DATA_WIDTH-1:0] instruction_writeback,
  output reg [6:0] opcode_writeback,

  output [DATA_WIDTH-1:0] bypass_data_memory2,
  output reg [1:0] next_PC_select_memory2,
  output reg opwrite_memory2,
  output reg [4:0] opReg_memory2,
  output reg [6:0] opcode_memory2,
  output stall_wb
);

localparam NOP = 32'h00000013;

reg opSel_memory2;
reg [DATA_WIDTH-1:0] ALU_result_memory2;
reg [DATA_WIDTH-1:0] instruction_memory2;
reg mem2_valid, writeback_valid;
reg [ADDRESS_BITS-1:0] wb_data_addr; 
reg [ADDRESS_BITS-1:0] PC_memory2;
reg [ADDRESS_BITS-1:0] PC_writeback;

assign bypass_data_memory2 = opSel_memory2 ? load_data_memory2 : ALU_result_memory2;

always @(posedge clock) begin
  if(reset) begin
    ALU_result_memory2     <= {DATA_WIDTH{1'b0}};
    opwrite_memory2        <= 1'b0;
    opSel_memory2          <= 1'b0;
    opReg_memory2          <= 5'b0;
    next_PC_select_memory2 <= 2'b00;
    instruction_memory2    <= NOP;
    mem2_valid             <= 1'b0;
    PC_memory2             <= {ADDRESS_BITS{1'b0}};
    opcode_memory2         <= 7'h13; //ADDI
  end else if(stall_wb)begin
    ALU_result_memory2     <= ALU_result_memory2;
    opwrite_memory2        <= opwrite_memory2;
    opSel_memory2          <= opSel_memory2;
    opReg_memory2          <= opReg_memory2;
    next_PC_select_memory2 <= next_PC_select_memory2;
    instruction_memory2    <= instruction_memory2;
    mem2_valid             <= mem2_valid;
    PC_memory2             <= PC_memory2;
    opcode_memory2         <= opcode_memory2;
  end else if(~stall_wb)begin
    if(stall_mem)begin
      ALU_result_memory2     <= {DATA_WIDTH{1'b0}};
      opwrite_memory2        <= 1'b0;
      opSel_memory2          <= 1'b0;
      opReg_memory2          <= 5'b0;
      next_PC_select_memory2 <= 2'b00;
      instruction_memory2    <= NOP;
      mem2_valid             <= 1'b0;
      PC_memory2             <= {ADDRESS_BITS{1'b0}};
      opcode_memory2         <= 7'h13;
    end
    else begin
      ALU_result_memory2     <= ALU_result_memory1;
      opwrite_memory2        <= opwrite_memory1;
      opSel_memory2          <= opSel_memory1;
      opReg_memory2          <= opReg_memory1;
      next_PC_select_memory2 <= next_PC_select_memory1;
      instruction_memory2    <= instruction_memory1;
      mem2_valid             <= 1'b1;
      PC_memory2             <= PC_memory1;
      opcode_memory2         <= opcode_memory1;
    end
  end
end

always @(posedge clock)begin
  if(reset)begin
    ALU_result_writeback     <= {DATA_WIDTH{1'b0}};
    load_data_writeback      <= {DATA_WIDTH{1'b0}};
    opwrite_writeback        <= 1'b0;
    opSel_writeback          <= 1'b0;
    opReg_writeback          <= 5'b0;
    next_PC_select_writeback <= 2'b00;
    instruction_writeback    <= NOP;
    wb_data_addr             <= {ADDRESS_BITS{1'b0}};
    writeback_valid          <= 1'b0;
    PC_writeback             <= {ADDRESS_BITS{1'b0}};
    opcode_writeback         <= 7'h13;
  end else if(stall_wb)begin
    ALU_result_writeback     <= ALU_result_writeback;
    load_data_writeback      <= load_data_valid ? load_data_memory2 : load_data_writeback;
    opwrite_writeback        <= opwrite_writeback;
    opSel_writeback          <= opSel_writeback;
    opReg_writeback          <= opReg_writeback;
    next_PC_select_writeback <= next_PC_select_writeback;
    instruction_writeback    <= instruction_writeback;
    writeback_valid          <= writeback_valid;
    wb_data_addr             <= load_data_valid ? load_data_addr : wb_data_addr;
    PC_writeback             <= PC_writeback;
    opcode_writeback         <= opcode_writeback;
  end else begin
    ALU_result_writeback     <= ALU_result_memory2;
    load_data_writeback      <= load_data_memory2;
    opwrite_writeback        <= opwrite_memory2;
    opSel_writeback          <= opSel_memory2;
    opReg_writeback          <= opReg_memory2;
    next_PC_select_writeback <= next_PC_select_memory2;
    instruction_writeback    <= instruction_memory2;
    writeback_valid          <= mem2_valid;
    wb_data_addr             <= opSel_memory2 ? load_data_valid ? load_data_addr : 
                                wb_data_addr : {ADDRESS_BITS{1'b0}};
    PC_writeback             <= PC_memory2;
    opcode_writeback         <= opReg_memory2;
  end
end

assign stall_wb = (writeback_valid & opSel_writeback & (ALU_result_writeback != wb_data_addr));

endmodule
