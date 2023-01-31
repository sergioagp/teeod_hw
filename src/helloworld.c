/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

#define TAMB_ENCLV_ADDR				0x00A0020000
#define ITCM_ENCLV_ADDR				0x00A0000000

#define RST_ENCLV_ADDR				0x00A0010000
#define TAMB_ENCLV__INT_ADDR		0x00A00200FC
#define TAMB_ENCLV__DONE_ADDR		0x00A00200FC

extern char __cm1_bin_start__;
extern char __cm1_bin_end__;

struct enclave_tcb {
	uint32_t * addr_rst;
	uint32_t * addr_itcm;
	uint32_t * addr_tamb;
};


static void write32(uintptr_t Addr, uint32_t Value)
{
	volatile uint32_t *LocalAddr = (volatile uint32_t *)Addr;
	*LocalAddr = Value;
}

static uint32_t read32(uintptr_t Addr)
{
	return *(volatile uint32_t *)Addr;
}

static void enclave_update(volatile uint32_t * addr_itcm, volatile uint32_t * addr_bin, size_t size)
{
	for(int i=0;i<size;i++) {
		//printf("0x%08X\n\r",addr_itcm+i);
		*(addr_itcm+i) = *(addr_bin+i);
	}

	write32(RST_ENCLV_ADDR, 0x0);
	write32(RST_ENCLV_ADDR, 0x1);
}

static void write_mailbox(volatile uint32_t * addr_mb, size_t size)
{
	*(addr_mb) = 2;
	for(int i=1;i<size;i++) {
		printf("0x%08X<-0x%08X\n\r",addr_mb+i, 0xAA00+i);
		*(addr_mb+i) = 0xAA00+i;
	}

	printf("send intr to tamb\n\r");
	printf("0x%08X<-0x%08X\n\r",TAMB_ENCLV__INT_ADDR, (uint32_t) *((volatile uint32_t *)TAMB_ENCLV__INT_ADDR));
	write32(TAMB_ENCLV__INT_ADDR, 0x0);
	printf("0x%08X<-0x%08X\n\r",TAMB_ENCLV__INT_ADDR, (uint32_t) *((volatile uint32_t *)TAMB_ENCLV__INT_ADDR));
}

typedef struct {
	uint32_t timeLow;
	uint16_t timeMid;
	uint16_t timeHiAndVersion;
	uint8_t clockSeqAndNode[8];
} TEE_UUID;
typedef union {
	struct {
		void *buffer;
		uint32_t size;
	} memref;
	struct {
		uint32_t a;
		uint32_t b;
	} value;
} TEE_Param;

typedef uint32_t TEE_Result;

typedef struct {
  int type;
  union {
    uint32_t session_id;
    TEE_UUID tee_uuid;
  } ctx;
} TEE_Operation_ctx;

typedef struct {
  uint32_t cmd_id;
  uint32_t param_types;
  TEE_Param params[4];
} TEE_Operation_params;

typedef struct {
  int type;
  union {
    uint32_t session_id;
    TEE_UUID tee_uuid;
  } ctx;
  TEE_Operation_params par;
  TEE_Result ret;
} TEE_Operation;

void parse_TEE_Operation(TEE_Operation *op) {
  printf("addr: 0x%8x::", &op->type);
  printf("type: %d\r\n", op->type);
  printf("addr: 0x%8x::", &op->ctx.session_id);
  printf("ctx.session_id: %u\r\n", op->ctx.session_id);
  printf("addr: 0x%8x::", &op->par.cmd_id);
  printf("par.cmd_id: %u\r\n", op->par.cmd_id);
  printf("addr: 0x%8x::", &op->par.param_types);
  printf("par.param_types: %u\r\n", op->par.param_types);
  for (int i = 0; i < 4; i++) {
	printf("addr: 0x%8x::\r\n", &op->par.params[i].value.a);
    printf("par.params[%d].a: %u", i, op->par.params[i].value.a);
	printf("addr: 0x%8x::\r\n", &op->par.params[i].value.b);
    printf("par.params[%d].b: %u", i, op->par.params[i].value.b);
  }
  printf("addr: 0x%8x::", &op->ret);
  printf("ret: %u\r\n", op->ret);
}


int main()
{
    init_platform();

//    print("Starting the load of new bin to the enclave...\n\r");
//
//	struct enclave_tcb  enclave_0 = {.addr_rst = RST_ENCLV_ADDR, .addr_itcm=ITCM_ENCLV_ADDR, .addr_tamb=TAMB_ENCLV_ADDR};
//	uint32_t *addr_bin=(uint32_t *) &__cm1_bin_start__;
//	const uint32_t bin_size = &__cm1_bin_end__ - &__cm1_bin_start__;
//	printf("Addr bin= 0x%08x, Size = %d bytes\n\r", addr_bin, bin_size);
//	enclave_update(enclave_0.addr_itcm, addr_bin, bin_size>>2);
//
//	print("Load done!\n\r");
  TEE_Operation *op = 0x00A0000000, *op2 = 0x00A0010000;
  op->type = 6;
  op->ctx.session_id = 12345;
  op->par.cmd_id = 67890;
  op->par.param_types = 0x2;
  for (int i = 0; i < 4; i++) {
  op->par.params[i].value.a = i;
  op->par.params[i].value.b = i+10;
  }
  op->ret = 0;

  parse_TEE_Operation(op2);


//	print("Testing mailbox..\n\r");
//	write_mailbox(enclave_0.addr_tamb, 32);
//
//	while(read32(TAMB_ENCLV__DONE_ADDR)!=0xBEEF);
//	for(int i=0;i<32;i++) {
//		printf("0x%08X<-0x%08X\n\r",enclave_0.addr_tamb+i, *(enclave_0.addr_tamb+i));
//	}
//	print("Test mailbox done!\n\r");

    cleanup_platform();
    return 0;
}
