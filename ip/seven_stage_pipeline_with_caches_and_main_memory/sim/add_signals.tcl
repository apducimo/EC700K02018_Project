add wave sim:/tb_RISC_V_Core/clock
add wave sim:/tb_RISC_V_Core/reset
add wave sim:/tb_RISC_V_Core/start
add wave sim:/tb_RISC_V_Core/CORE/stall
add wave sim:/tb_RISC_V_Core/CORE/stall_mem
add wave sim:/tb_RISC_V_Core/CORE/stall_wb

add wave sim:/tb_RISC_V_Core/CORE/IF/inst_PC
add wave sim:/tb_RISC_V_Core/CORE/IF/instruction

add wave sim:/tb_RISC_V_Core/CORE/IF_ID/inst_PC_decode
add wave sim:/tb_RISC_V_Core/CORE/IF_ID/instruction_decode

add wave sim:/tb_RISC_V_Core/CORE/ID_EU/PC_execute
add wave sim:/tb_RISC_V_Core/CORE/ID_EU/instruction_execute

add wave sim:/tb_RISC_V_Core/CORE/EU_MU/PC_memory1
add wave sim:/tb_RISC_V_Core/CORE/EU_MU/instruction_memory1
add wave sim:/tb_RISC_V_Core/CORE/EU_MU/ALU_result_memory1
add wave sim:/tb_RISC_V_Core/CORE/EU_MU/store_data_memory1
add wave sim:/tb_RISC_V_Core/CORE/EU_MU/memRead_memory1
add wave sim:/tb_RISC_V_Core/CORE/EU_MU/memWrite_memory1
add wave sim:/tb_RISC_V_Core/CORE/EU_MU/regWrite_memory1

add wave sim:/tb_RISC_V_Core/CORE/MU_WB/PC_memory2
add wave sim:/tb_RISC_V_Core/CORE/MU_WB/instruction_memory2
add wave sim:/tb_RISC_V_Core/CORE/MU_WB/ALU_result_memory2
add wave sim:/tb_RISC_V_Core/CORE/MU_WB/opwrite_memory2
add wave sim:/tb_RISC_V_Core/CORE/MU_WB/opReg_memory2
add wave sim:/tb_RISC_V_Core/CORE/MU_WB/opSel_memory2

add wave sim:/tb_RISC_V_Core/CORE/MU_WB/PC_writeback
add wave sim:/tb_RISC_V_Core/CORE/MU_WB/instruction_writeback
add wave sim:/tb_RISC_V_Core/CORE/MU_WB/ALU_result_writeback
add wave sim:/tb_RISC_V_Core/CORE/MU_WB/load_data_writeback
add wave sim:/tb_RISC_V_Core/CORE/MU_WB/opSel_writeback
add wave sim:/tb_RISC_V_Core/CORE/MU_WB/opwrite_writeback
add wave sim:/tb_RISC_V_Core/CORE/MU_WB/opReg_writeback












