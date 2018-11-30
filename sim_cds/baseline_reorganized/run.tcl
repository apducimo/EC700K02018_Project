database -open -shm wave -default -event
probe -create -database wave tb_RISC_V_Core -all -memories -depth all
run
exit
