database -open -shm wave -default -event
probe -create -database wave arch_aes_cipher_block_128_TB -all -depth all
run
exit
