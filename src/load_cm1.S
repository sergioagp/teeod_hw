.section	.text.cm1_bin.bin, "a"

.global __cm1_bin_start__
.global __cm1_bin_end__

__cm1_bin_start__:
	.incbin "/home/spereira/Projects/TEEOD/ta_dev/build/aes-test.bin"
	//.incbin "/home/spereira/Projects/TEEOD-final/teeod-demo/teeod-proj/enclave_sw/build/minimal.bin"
	//.incbin "/home/spereira/Projects/TEEOD-final/teeod-proj/enclave_sw/build/enclave_sw.bin"
__cm1_bin_end__:
