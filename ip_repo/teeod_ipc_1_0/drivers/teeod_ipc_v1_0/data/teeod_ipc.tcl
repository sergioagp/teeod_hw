

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "teeod_ipc" "NUM_INSTANCES" "DEVICE_ID"  "C_TEE_AXI_BASEADDR" "C_TEE_AXI_HIGHADDR" "C_ENCL_AXI_BASEADDR" "C_ENCL_AXI_HIGHADDR"
}
