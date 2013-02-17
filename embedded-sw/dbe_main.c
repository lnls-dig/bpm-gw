#include "gpio.h"       // GPIO device funtions
#include "dma.h"          // DMA device functions
#include "fmc150.h"       // FMC150 device functions
#include "uart.h"         // UART device functions
#include "memmgr.h"       // memory pool functions
#include "board.h"        // board definitions
#include "int.h"          // LM32 interruption definitions
#include "pp-printf.h"    // printf-like function
#include "ethmac.h"       // ethmac headers
#include "eth-phy-mii.h"
#include "ethmac_adapt.h"
#include "icmp.h"
#include "ipv4.h"
#include "arp.h"
#include "util.h"         // util functions like memcmp and memcpy
#include "debug_print.h"

/*   Each loop iteration takes 4 cycles.
 *  It runs at 100MHz.
 *  Sleep 0.2 second.
 */
#define LED_DELAY (100000000/4/5)

// 1s delay
#define FMC150_DELAY (100000000/4)

#define NUM_LEDS 8
#define NUM_LED_ITER 4
#define NUM_FMC150_TRIES 5

/* Ethernet MAC + Etherbone testing */
//unsigned char myIP[]  = { 10, 0, 18, 100 };
//unsigned char myMAC[] = { ETH_MACADDR0, ETH_MACADDR1, ETH_MACADDR2, ETH_MACADDR3, ETH_MACADDR4, ETH_MACADDR5 };
//unsigned char allMAC[] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };

/* His info */
//volatile int sawARP = 0;
//volatile static int sawPING = 0;
//volatile static int hisBodyLen;
//static unsigned char hisBody[1516];
//unsigned char hisIP[4];
//unsigned char hisMAC[6];

static volatile int eb_done;

static void set_eb_done(void* arg) {
	eb_done = 1;
}

void user_recv(unsigned char* data, int length) {
	int iplen, i;

	pp_printf("user_recv:\n");

	pp_printf("> mac: ");
	dbg_print2("%2X ", (unsigned char*)(data), 6);
	pp_printf("> mac: ");
	pp_printf("%2X %2X %2X %2X %2X %2X\n", data[0], data[1], data[2], data[3],
			data[4], data[5]);
	/* If not for us or broadcast, ignore it */
	if (memcmp(data, allMAC, 6) && memcmp(data, myMAC, 6)) {
		pp_printf("> MAC does not match ours, ignoring packet\n");
		//return;
	}

	pp_printf("> destination MAC is correct\n");

	pp_printf("> ethtype: ");
	dbg_print2("%2X ", (unsigned char*)(data+ETH_TYPE), 2);
	pp_printf("> ethtype: ");
	pp_printf("%2X %2X\n", data[ETH_TYPE], data[ETH_TYPE+1]);

	pp_printf("> arp_oper: ");
	dbg_print2("%2X ", (unsigned char*)(data+ARP_OPER), 2);
	pp_printf("> arp_oper: ");
	pp_printf("%2X %2X\n", data[ARP_OPER], data[ARP_OPER+1]);

	pp_printf("> ip: ");
	dbg_print2("%2X ", (unsigned char*)(data+ARP_TPA), 4);
	pp_printf("> ip: ");
	pp_printf("%2X %2X %2X %2X\n", data[ARP_TPA], data[ARP_TPA+1],
			data[ARP_TPA+2], data[ARP_TPA+3]);

	/* Is it ARP request targetting our IP? */
	if (data[ETH_TYPE+0] == 0x08 &&
			data[ETH_TYPE+1] == 0x06 &&
			data[ARP_OPER+0] == 0 &&
			data[ARP_OPER+1] == 1 &&
			!memcmp(data+ARP_TPA, myIP, 4)) {
		sawARP = 1;
		memcpy(hisMAC, data+ARP_SHA, 6);
		memcpy(hisIP,  data+ARP_SPA, 4);

		pp_printf("> ARP request\n");
	} else
		pp_printf("> no ARP request\n");

	pp_printf("> ip version: ");
	dbg_print2("%2X ", (unsigned char*)(data+IP_VERSION), 1);
	pp_printf("> ip version: ");
	pp_printf("%2X\n", data[IP_VERSION]);

	pp_printf("> ip dest: ");
	dbg_print2("%2X ", (unsigned char*)(data+IP_DEST), 1);
	pp_printf("> ip dest: ");
	pp_printf("%2X\n", data[IP_DEST]);

	/* Is it IP targetting us? */
	if (data[ETH_TYPE+0] == 0x08 &&
			data[ETH_TYPE+1] == 0x00 &&
			data[IP_VERSION] == 0x45 &&
			!memcmp(data+IP_DEST, myIP, 4)) {

		iplen = (data[IP_LEN+0] << 8 | data[IP_LEN+1]);
		/* An ICMP ECHO request? */
		if (data[IP_PROTOCOL] == 0x01 && data[ICMP_TYPE] == 0x08) {
			hisBodyLen = iplen - 24;
			if (hisBodyLen <= sizeof(hisBody)) {
				sawPING = 1;
				memcpy(hisMAC,    data+ETH_SOURCE,  6);
				memcpy(hisIP,     data+IP_SOURCE,   4);
				memcpy(hisBody,   data+ICMP_QUENCH, hisBodyLen);

				pp_printf("> PING request\n");
			}
		} else
			pp_printf("> no PING request\n");

		/* UDP etherbone? */
		if (data[IP_PROTOCOL] == 0x11) {
			memcpy(hisBody, data, 14); /* bytes 14-16 = garbage */
			memcpy(hisBody+16, data+14, iplen);

			eb_done = 0;
			//ethmac_adapt->length = iplen + 16;
			ethmac_adapt_set_length(iplen + 16);
			//ethmac_adapt->doit = 1;
			ethmac_adapt_go();
			while (!eb_done);

			pp_printf("> EBONE request\n");

			/* shift out the padding */
			for (i = 12; i >= 2; --i)
				hisBody[i] = hisBody[i-2];
			tx_packet(hisBody+2, iplen+14);
		} else
			pp_printf("> no EBONE request\n");
	}
}

/* Placeholder for IRQ vector */
//void _irq_entry(void){}
//void MicoISRHandler(unsigned int sig) {}

static void button(void* arg) {
	pp_printf("> button pushed!\n");
}

int dbe_init(void)
{
	// Initialize memory pool
	memmgr_init();

	// Fill SDB device structures
	sdb_find_devices();

	// Initialize specific components
	if(uart_init() == -1){
		return -1;
	}

	/* Output memory layout */
	sdb_print_devices();

	if(dma_init() == -1){
		pp_printf("> error initializing DMA! Exiting...\n");
		//return -1;
	}

	if(gpio_init() == -1){
		pp_printf("> error initializing GPIO! Exiting...\n");
		//return -1;
	}

	//if(fmc150_init() == -1){
	//  pp_printf("> Error initializing FMC150! Exiting...\n");
	//  return -1;
	//}

	//if(fmc516_init() == -1){
	//  pp_printf("> Error initializing FMC516! Exiting...\n");
	//  return -1;
	//}

	// Ethernet initilization
	if(ethmac_adapt_init() == -1){
		pp_printf("> error initializing Ethernet MAC adapter! Exiting...\n");
		//return -1;
	}

	// Initialize LM32 Interrupts
	if(int_init() == -1){
		pp_printf("> error initializing Interrupts! Exiting...\n");
		//return -1;
	}

	return 0;
}

void print_header(void)
{
	pp_printf("-------------------------------------------\n");
	pp_printf("|       DBE EXAMPLE APPLICATION           |\n");
	pp_printf("|                                         |\n");
	pp_printf("|  This application aims to demostrate    |\n");
	pp_printf("|  the capabilities of the DBE project    |\n");
	pp_printf("-------------------------------------------\n\n");
}

void print_end_header(void)
{
	pp_printf("-------------------------------------------\n");
	pp_printf("|       END OF TEST APPLICATION           |\n");
	pp_printf("-------------------------------------------\n\n");
}

void memmgr_test(void)
{
	/* Simple Memory Pool Test */
	char *p = (char *)memmgr_alloc(100*sizeof(char));

	pp_printf("-------------------------------------------\n");
	pp_printf("|            Memory pool test             |\n");
	pp_printf("-------------------------------------------\n\n");

	pp_printf("memmgr_test:\n");

	if(p){
		strcpy(p, "> dynamic allocated string with memory pool\n\n");
		pp_printf(p);
		pp_printf("> test passed!\n");
	}
	else
		pp_printf("> test failed. Could not allocate memory!\n");

	memmgr_print_stats();

	memmgr_free(p);
}

void leds_test(void)
{
	/* Simple LEDs test */
	int i, j;

	pp_printf("-------------------------------------------\n");
	pp_printf("|                Leds test                |\n");
	pp_printf("-------------------------------------------\n\n");

	pp_printf("leds_test:\n");
	/* Rotate the LEDs  */
	for ( j = 0; j < NUM_LED_ITER; ++j)
		for (i = 0; i < NUM_LEDS; ++i){
			// Set led at position i
			gpio_out(i, 1);

			/* Each loop iteration takes 4 cycles.
			 * It runs at 100MHz.
			 * Sleep 0.2 second.
			 */
			delay(LED_DELAY);

			// Clear led at position i
			gpio_out(i, 0);
		}

	pp_printf("> testing leds\n");
	// End test with 4 leds set
	gpio_out(0, 1);
	gpio_out(2, 1);
	gpio_out(4, 1);
	gpio_out(6, 1);
}

//void fmc150_test()
//{
//  pp_printf("-------------------------------------------\n");
//  pp_printf("|                FMC150 test              |\n");
//  pp_printf("-------------------------------------------\n\n");
//
//  pp_printf("> Testing FMC150 CDCE72010 regs...\n");
//
//  if (init_cdce72010() < 0){
//    pp_printf("> Error initializing FMC150!\n");
//    return -1;
//  }
//
//  pp_printf("> FMC150 CDCE72010 initialized\n");
//}

int main(void)
{
	// Board initialization
	if(board_init() == -1)
		return -1;

	// General initialization
	if(dbe_init() == -1){
		pp_printf("> error initializing DBE Board! Exiting...\n");
		return -1;
	}

	pp_printf("main:\n");

	/* Install ethernet interrupt handler, it is enabled here too */
	int_add(ETH0_IRQ, oeth_interrupt, 0);
	pp_printf("> after int_add() ETH0_IRQ\n");
	int_add(2, &button, 0);
	pp_printf("> after int_add() 2\n");

	ethmac_setup(ETH0_PHY, ETH0_BUF); /* Configure MAC, TX/RX BDs and enable RX and TX in MODER */
	pp_printf("> after ethmac_setup() \n");

	/* clear tx_done, the tx interrupt handler will set it when it's been transmitted */

	/* Configure EB DMA */
	ethmac_adapt_set_base((unsigned int)hisBody, (unsigned int)hisBody);
	pp_printf("> after ethmac_adapt_set_base() \n");
	int_add(4, &set_eb_done, 0);
	pp_printf("> after int_add() 4\n");

	print_header();

	/* Test memory pool */
	memmgr_test();

	/* Test leds */
	leds_test();

	/* FMC150 test */
	//fmc150_test();

	/* FMC516 test */
	//fmc516_test();

	print_end_header();

	// Waiting for ARP or ICMP request
	pp_printf("> waiting for ARP or ICMP request\n");
	while (1) {
		if (sawARP){
			pp_printf("> saw ARP request\n");
			sendARP();
		}
		if (sawPING){
			pp_printf("> saw PING request\n");
			sendECHO();
		}
	}

	return 0;
}
