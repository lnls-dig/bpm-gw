#include "gpio.h"         // GPIO device funtions
#include "i2c.h"          // I2V device functions
#include "onewire.h"      // Onewire device functions
#include "dma.h"          // DMA device functions
//#include "fmc150.h"     // FMC150 device functions
#include "fmc516.h"       // FMC516 device functions
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
#include "debug_subsys.h"

/*   Each loop iteration takes 4 cycles.
 *  It runs at 100MHz.
 *  Sleep 0.2 second.
 */
#define LED_DELAY (100000000/4/5)

// 1s delay
#define FMC150_DELAY (100000000/4)

#define NUM_LEDS 8
#define NUM_LED_ITER 4
//#define NUM_FMC150_TRIES 5

#define NUM_BUTTONS 8
#define TEST_BUTTONS_MASK 0x00000003
#define TEST_BUTTONS_TRIES 10
#define TEST_BUTTONS_ITER 2
#define TEST_BUTTONS_DELAY (100000000/4/5)

static volatile int eb_done;

static void set_eb_done(void* arg) {
    eb_done = 1;
}

void user_recv(unsigned char* data, int length) {
    int iplen, i;

    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "user_recv:\n");

    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> mac: ");
    DBE_DEBUG_ARRAY(DBG_ETH | DBE_DBG_TRACE, "%2X ", (unsigned char*)(data), 6);

    /* If not for us or broadcast, ignore it */
    if (memcmp(data, allMAC, 6) && memcmp(data, myMAC, 6)) {
        DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> MAC does not match ours, ignoring packet\n");
        return;
    }

    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> destination MAC is correct\n");

    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> ethtype: ");
    DBE_DEBUG_ARRAY(DBG_ETH | DBE_DBG_TRACE, "%2X ", (unsigned char*)(data+ETH_TYPE), 2);

    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> arp_oper: ");
    DBE_DEBUG_ARRAY(DBG_ETH | DBE_DBG_TRACE, "%2X ", (unsigned char*)(data+ARP_OPER), 2);

    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> arp_tpa: ");
    DBE_DEBUG_ARRAY(DBG_ETH | DBE_DBG_TRACE, "%2X ", (unsigned char*)(data+ARP_TPA), 4);

    /* Is it ARP request targetting our IP? */
    if (data[ETH_TYPE+0] == 0x08 &&
            data[ETH_TYPE+1] == 0x06 &&
            data[ARP_OPER+0] == 0 &&
            data[ARP_OPER+1] == 1 &&
            !memcmp(data+ARP_TPA, myIP, 4)) {
        sawARP = 1;
        memcpy(hisMAC, data+ARP_SHA, 6);
        memcpy(hisIP,  data+ARP_SPA, 4);

        DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> ARP request\n");
    } else
        DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> no ARP request\n");

    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> ip version: ");
    DBE_DEBUG_ARRAY(DBG_ETH | DBE_DBG_TRACE,"%2X ", (unsigned char*)(data+IP_VERSION), 1);

    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> ip dest: ");
    DBE_DEBUG_ARRAY(DBG_ETH | DBE_DBG_TRACE, "%d ", (unsigned char*)(data+IP_DEST), 4);
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

                DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> PING request\n");
            }
        } else
            DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> no PING request\n");

        /* UDP etherbone? */
        if (data[IP_PROTOCOL] == 0x11) {
            memcpy(hisBody, data, 14); /* bytes 14-16 = garbage */
            memcpy(hisBody+16, data+14, iplen);

            eb_done = 0;
            //ethmac_adapt->length = iplen + 16;
            ethmac_adapt_set_length(0, iplen + 16);
            //ethmac_adapt->doit = 1;
            ethmac_adapt_go(0);
            while (!eb_done);

            DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> EBONE request\n");

            /* shift out the padding */
            for (i = 12; i >= 2; --i)
                hisBody[i] = hisBody[i-2];
            tx_packet(hisBody+2, iplen+14);
        } else
            DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> no EBONE request\n");
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
        return -1;
    }

    if(gpio_init() == -1){
        pp_printf("> error initializing GPIO! Exiting...\n");
        return -1;
    }

    // Ethernet MAC Initialization
    if(ethmac_init() == -1){
        pp_printf("> error initializing Ethernet MAC! Exiting...\n");
        return -1;
    }

    // Setup ethmac
    //ethmac_setup(ETH0_PHY); /* Configure MAC, TX/RX BDs and enable RX and TX in MODER */

    // Ethernet adapter initilization
    if(ethmac_adapt_init() == -1){
        pp_printf("> error initializing Ethernet MAC adapter! Exiting...\n");
        return -1;
    }

    // Initialize LM32 Interrupts
    if(int_init() == -1){
        pp_printf("> error initializing Interrupts! Exiting...\n");
        return -1;
    }

    return 0;
}

int dbe_exit()
{
    gpio_exit();
    uart_exit();
    fmc516_exit();

    //always succeeds
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
    pp_printf("> blinking leds\n");
    /* Rotate the LEDs  */
    for ( j = 0; j < NUM_LED_ITER; ++j)
        for (i = 0; i < NUM_LEDS; ++i){
            // Set led at position i
            gpio_out(0, i, 1);

            /* Each loop iteration takes 4 cycles.
             * It runs at 100MHz.
             * Sleep 0.2 second.
             */
            delay(LED_DELAY);

            // Clear led at position i
            gpio_out(0, i, 0);
        }

    // End test with 4 leds set
    gpio_out(0, 0, 1);
    gpio_out(0, 2, 1);
    gpio_out(0, 4, 1);
    gpio_out(0, 6, 1);

    pp_printf("> test passed!\n");
}

void button_test()
{
    int i, j;
    unsigned int button_pressed = 0;

    pp_printf("-------------------------------------------\n");
    pp_printf("|               Button test               |\n");
    pp_printf("-------------------------------------------\n\n");

    pp_printf("buttons_test:\n");
    pp_printf("> press (switch) buttons ");

    for (i = 0; i < TEST_BUTTONS_ITER-1; ++i)
        pp_printf("%d, ", i);

    pp_printf("%d\n", TEST_BUTTONS_ITER);

    for (i = 0; i < TEST_BUTTONS_TRIES; ++i) {
        for (j = 0; j < TEST_BUTTONS_ITER; ++j) {
            if ((!(button_pressed & (0x1 << j))) & gpio_in(1, j)) {
                button_pressed |= 1 << j;
                pp_printf("button%d pressed!\n", j);
            }
        }

        if (button_pressed == TEST_BUTTONS_MASK) {
            pp_printf("> test passed!\n");
            return;
        }

        pp_printf("> remaining time to press buttons: %ds\n", (TEST_BUTTONS_TRIES-i));
        delay(TEST_BUTTONS_DELAY);
    }

    pp_printf("> test failed!\n");
}

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

    print_header();

    /* Test memory pool */
    memmgr_test();

    /* Test leds */
    leds_test();

    /* Test button */
    button_test();

    print_end_header();

    /* Install ethernet interrupt handler, it is enabled here too */
    int_add(ETH0_IRQ, oeth_interrupt, 0);
    int_add(2, &button, 0);

    //ethmac_setup(ETH0_PHY, ETH0_BUF); /* Configure MAC, TX/RX BDs and enable RX and TX in MODER */
    ethmac_setup(ETH0_PHY); /* Configure MAC, TX/RX BDs and enable RX and TX in MODER */

    /* clear tx_done, the tx interrupt handler will set it when it's been transmitted */

    /* Install ethernet interrupt handler, it is enabled here too */
    int_add(ETH0_IRQ, oeth_interrupt, 0);

    /* Configure EB DMA */
    ethmac_adapt_set_base(0, (unsigned int)hisBody, (unsigned int)hisBody);
    int_add(4, &set_eb_done, 0);

    // Waiting for ARP or ICMP request
    DBE_DEBUG(DBG_GENERIC | DBE_DBG_INFO, "> waiting for ARP or ICMP request\n");
    pp_printf("> waiting for ARP or ICMP request\n");
    while (1) {
        if (sawARP){
             DBE_DEBUG(DBG_GENERIC | DBE_DBG_INFO, "> saw ARP request\n");

            sendARP();
        }
        if (sawPING){
             DBE_DEBUG(DBG_GENERIC | DBE_DBG_INFO, "> saw PING request\n");
            sendECHO();
        }
    }

    dbe_exit();

    return 0;
}
