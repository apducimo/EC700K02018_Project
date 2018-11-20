/** @module : fetch_unit
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

module fetch_unit #(
  parameter CORE = 0,
  parameter DATA_WIDTH = 32,
  parameter INDEX_BITS = 6,
  parameter OFFSET_BITS = 3,
  parameter ADDRESS_BITS = 20,
  parameter PROGRAM = "../software/applications/binaries/<your_program>",
  parameter PRINT_CYCLES_MIN = 1,
  parameter PRINT_CYCLES_MAX = 1000
) (
  input clock,
  input reset,
  input start,
  input stall,
  input [1:0] next_PC_select_execute,
  input [ADDRESS_BITS-1:0] inst_PC_decode,
  input [ADDRESS_BITS-1:0] program_address,
  input [ADDRESS_BITS-1:0] JAL_target,
  input [ADDRESS_BITS-1:0] JALR_target,
  input branch,
  input [ADDRESS_BITS-1:0] branch_target,

  // Instruction Memory Interface (Fetch unit only reads)
  input [DATA_WIDTH-1:0] i_mem_out_data,
  // the address associated with current i_mem_out_data
  input [ADDRESS_BITS-1:0] i_mem_out_addr,
  input i_mem_valid,
  input i_mem_ready, output i_mem_read,
  output [ADDRESS_BITS-1:0] i_mem_read_address,


  output [DATA_WIDTH-1:0] instruction,
  output [ADDRESS_BITS-1:0] inst_PC,
  output valid,
  output ready,

  input report
);

localparam NOP = 32'h00000013;

reg fetch;
reg [ADDRESS_BITS-1:0] PC_reg;

reg [ADDRESS_BITS-1:0] addr0, addr1;
reg req0, req1;
reg [DATA_WIDTH-1 : 0] data0, data1;
reg data0_valid, data1_valid;
reg [ADDRESS_BITS-1:0] data0_addr, data1_addr;

wire [ADDRESS_BITS-1:0] PC_plus4;
wire [ADDRESS_BITS-1:0] PC_reg_temp;
wire [ADDRESS_BITS-1 : 0] inst_PC_from_mem;

assign PC_reg_temp = (next_PC_select_execute == 2'b11)           ? JALR_target   :
                     (next_PC_select_execute == 2'b10)           ? JAL_target    :
                     (next_PC_select_execute == 2'b01) & branch  ? branch_target :
                     PC_plus4;

assign i_mem_read         = fetch & ready & ~stall;
assign PC_plus4           = PC_reg + 4;
assign i_mem_read_address = PC_reg >> 2;

assign inst_PC_from_mem = i_mem_out_addr << 2;
assign inst_PC          = data1_valid ? addr1 : inst_PC_from_mem;
assign instruction      = data1_valid ? data1 : i_mem_out_data;

always @ (posedge clock) begin
  if (reset) begin
    fetch  <= 1'b0;
    PC_reg <= program_address;
  end else if (start) begin
    fetch  <= 1'b1;
    PC_reg <= program_address;
  end else if((next_PC_select_execute == 2'b11) | (next_PC_select_execute == 2'b10) |
  ((next_PC_select_execute == 2'b01) & branch))begin
    fetch  <= 1'b1;
    PC_reg <= PC_reg_temp;
  end else if(stall)begin  
    fetch  <= fetch;       
    PC_reg <= PC_reg;      
  end else begin
    if(ready)begin
      fetch  <= 1'b1;
      PC_reg <= PC_reg_temp;
    end else begin
      fetch  <= fetch;  
      PC_reg <= PC_reg;
    end
  end
end

always @ (posedge clock)begin
  if(reset)begin
    req0        <= 1'b0;
    req1        <= 1'b0;
    addr0       <= {ADDRESS_BITS{1'b0}};
    addr1       <= {ADDRESS_BITS{1'b0}};
    data0_valid <= 1'b0;
    data1_valid <= 1'b0;
    data0       <= 0;
    data1       <= 0;
  end else if (start) begin
    req0        <= 1'b0;
    req1        <= 1'b1;
    addr0       <= {ADDRESS_BITS{1'b0}};
    addr1       <= program_address;
    data0_valid <= 1'b0;
    data1_valid <= 1'b0;
    data0       <= 0;
    data1       <= 0;
  end else if((next_PC_select_execute == 2'b11) | (next_PC_select_execute == 2'b10) |
  ((next_PC_select_execute == 2'b01) & branch))begin
    req0        <= 1'b0;
    req1        <= 1'b1;
    addr0       <= {ADDRESS_BITS{1'b0}};
    addr1       <= PC_reg_temp;
    data0_valid <= 1'b0;
    data1_valid <= 1'b0;
    data0       <= 0;
    data1       <= 0;
  end else if(stall)begin
    req0  <= req0;
    req1  <= req1;          
    addr0 <= addr0;
    addr1 <= addr1;
    if(i_mem_valid & (inst_PC_from_mem == addr1) & req1)begin
      data1       <= i_mem_out_data;
      data1_valid <= 1'b1;
    end
    else if(i_mem_valid & (inst_PC_from_mem == addr0) & req0)begin
      data0       <= i_mem_out_data;
      data0_valid <= 1'b1;
    end
  end else begin    //normal operation
    if(data1_valid & data0_valid)begin  
      data1       <= data0;            
      data0       <= 0;
      data0_valid <= 1'b0;
	  data1_valid <= 1'b1;
      addr1       <= addr0;
      addr0       <= {ADDRESS_BITS{1'b0}};
      req0        <= 1'b0;
	  req1        <= 1'b1;
    end
    else if(data1_valid & ~data0_valid)begin 
      if(i_mem_valid & (inst_PC_from_mem == addr0) & req0)begin
        data1       <= i_mem_out_data;
		data0       <= 0;
		data1_valid <= 1'b1;
		data0_valid <= 1'b0;
		addr1       <= addr0;
        addr0       <= {ADDRESS_BITS{1'b0}};
        req1        <= 1'b1;
		req0        <= 1'b0;
      end
      else begin
        if(req0)begin
		  addr1       <= addr0;
          req1        <= 1'b1;
		  data1       <= 0;
		  data0       <= 0;
          data1_valid <= 1'b0;
		  data0_valid <= 1'b0;
		  if((PC_reg != addr0) & fetch)begin 
		    req0  <= 1'b1;
			addr0 <= PC_reg;
		  end
		  else begin 
		    req0  <= 0;
			addr0 <= {ADDRESS_BITS{1'b0}};
		  end
        end
        else begin 
          data1_valid <= 1'b0;
		  data0_valid <= 1'b0;
		  data1       <= 0;
		  data0       <= 0;
		  req0        <= 1'b0;
		  addr0       <= {ADDRESS_BITS{1'b0}};
		  if((PC_reg != addr1) & fetch)begin
			req1  <= 1'b1;
			addr1 <= PC_reg;
		  end
		  else begin 
			req1  <= 1'b0;
			addr1 <= {ADDRESS_BITS{1'b0}};
		  end
        end
      end
    end
    else if(~data1_valid & ~data0_valid)begin 
      if(~req1 & ~req0 & fetch)begin
        req0  <= 1'b0;
        req1  <= 1'b1;
        addr0 <= {ADDRESS_BITS{1'b0}};
        addr1 <= PC_reg;
      end else
	  if(i_mem_valid & (inst_PC_from_mem == addr1))begin
        if(req0)begin
		  req0  <= (addr0 != PC_reg) ? fetch : 0;
          req1  <= 1'b1;
          addr0 <= (addr0 != PC_reg) ? PC_reg : 0;
          addr1 <= addr0;
		end
		else begin
		  req0  <= 1'b0;
          req1  <= (addr1 != PC_reg) ? fetch : 0;
          addr0 <= addr0;
          addr1 <= (addr1 != PC_reg) ? PC_reg : 0;
		end
	  end
	  else begin
	    if(fetch & PC_reg != addr0 & PC_reg != addr1)begin
		  if(req0)begin
		    req0  <= 1'b1;
            req1  <= 1'b1;
            addr0 <= PC_reg;
            addr1 <= addr0;
		  end
		  else begin
		    req0  <= 1'b1;
            addr0 <= PC_reg;
		  end
		end
	  end
    end
  end
end


assign valid = reset ? 0 : data1_valid | (i_mem_valid & (req1 & (inst_PC == addr1)));
               
assign ready = reset ? 0 : i_mem_ready;


reg [31: 0] cycles;
always @ (posedge clock) begin
    cycles <= reset? 0 : cycles + 1;
    //if (report & ((cycles >=  PRINT_CYCLES_MIN) & (cycles < PRINT_CYCLES_MAX +1)))begin
    if (report)begin
        $display ("------ Core %d Fetch Unit - Current Cycle %d --------", CORE, cycles);
        $display ("| Prog_Address[%h]", program_address);
        $display ("| next_PC_select_execute[%b]", next_PC_select_execute);
        $display ("| PC_reg      [%h]", PC_reg);
        $display ("| PC_plus4    [%h]", PC_plus4);
        $display ("| JAL_target  [%h]", JAL_target);
        $display ("| JALR_target [%h]", JALR_target);
        $display ("| Branch      [%b]", branch);
        $display ("| branchTarget[%h]", branch_target);
        $display ("| Read        [%b]", fetch);
        $display ("| instruction [%h]", instruction);
        $display ("| inst_PC     [%h]", inst_PC);
        $display ("| Ready       [%b]", ready);
        $display ("| Valid       [%b]", valid);
        $display ("----------------------------------------------------------------------");
    end
end

endmodule
