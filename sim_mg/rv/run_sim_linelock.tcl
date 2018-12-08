add wave sim:/tb_RISC_V_Core/CORE/CU/userMode
run -all
mem save -o L2cache.mem -f hex -wordsperline 1 {/tb_RISC_V_Core/CORE/mem_hierarchy_inst/L2_0/BRAM[0]/way_bram/mem}
