#include "gpio.h"         // GPIO device funtions
#include "i2c.h"          // I2V device functions
#include "onewire.h"      // Onewire device functions
#include "dma.h"          // DMA device functions
#include "uart.h"         // UART device functions
#include "timer.h"        // timer device functions
#include "memmgr.h"       // memory pool functions
#include "board.h"        // board definitions
#include "int.h"          // LM32 interruption definitions
#include "pp-printf.h"    // printf-like function
#include "ethmac.h"       // ethmac headers
#include "eth-phy-mii.h"
#include "ethmac_adapt.h"
//#include "icmp.h"
//#include "ipv4.h"
//#include "arp.h"
#include "util.h"         // util functions like memcmp and memcpy
#include "debug_print.h"
#include "debug_subsys.h"

/* lwIP includes */
#include "ethernet_config.h"    /* Application Ethernet Configuration File */
#include "lwip/memp.h"
#include "netif/etharp.h"
#include "lwip/ip.h"
#include "lwip/netif.h"
#include "lwip/sys.h"
#include "netif/ethernetif.h"

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

/* Placeholder for IRQ vector */
//void _irq_entry(void){}

static void button(void* arg)
{
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

    if(timer_init() == -1){
        pp_printf("> error initializing TIMER! Exiting...\n");
        return -1;
    }

    /* Initialized within lwIP functions */
    // Ethernet MAC Initialization
    //if(ethmac_init() == -1){
    //    pp_printf("> error initializing Ethernet MAC! Exiting...\n");
    //    return -1;
    //}

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
    timer_exit();
    ethmac_exit();

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

struct netif netif;

static int init_netifs(void)
{
    struct ip_addr ipaddr, netmask, gw;
#if PPP_SUPPORT
    pppInit();
#if PPP_PTY_TEST
    ppp_sio = sio_open(2);
#else
    ppp_sio = sio_open(0);
#endif
    if(!ppp_sio)
    {
        perror("Error opening device: ");
        exit(1);
    }

#ifdef LWIP_PPP_CHAP_TEST
    pppSetAuth(PPPAUTHTYPE_CHAP, "lwip", "mysecret");
#endif

  pppOpen(ppp_sio, pppLinkStatusCallback, NULL);
#endif /* PPP_SUPPORT */

    DBE_DEBUG(DBG_GENERIC | DBE_DBG_TRACE, "> initializing lwip netifs...\n");

#if LWIP_DHCP
    DBE_DEBUG(DBG_GENERIC | DBE_DBG_TRACE, "> using dynamic (DHCP) ip address\n");

    IP4_ADDR(&gw, 0,0,0,0);
    IP4_ADDR(&ipaddr, 0,0,0,0);
    IP4_ADDR(&netmask, 0,0,0,0);

    netif_add(&netif, &ipaddr, &netmask, &gw, NULL, tapif_init,
              tcpip_input);
    netif_set_default(&netif);
    dhcp_start(&netif);
#else
    DBE_DEBUG(DBG_GENERIC | DBE_DBG_TRACE, "> using static ip address\n");
    /* Not using DHCP, so fix IP addresses */
    /* host */
    IP4_ADDR( &ipaddr,
              HST_IP_ADDR_0,
              HST_IP_ADDR_1,
              HST_IP_ADDR_2,
              HST_IP_ADDR_3 );

    /* gateway */
    IP4_ADDR( &gw,
              GW_IP_ADDR_0,
              GW_IP_ADDR_1,
              GW_IP_ADDR_2,
              GW_IP_ADDR_3 );

    /* subnet mask */
    IP4_ADDR( &netmask,
              SUBNET_MASK_0,
              SUBNET_MASK_1,
              SUBNET_MASK_2,
              SUBNET_MASK_3 );

    netif_add(&netif, &ipaddr, &netmask, &gw, 0, ethernetif_init, ethernet_input);

    /* declare this netif as the default interface */
    netif_set_default(&netif);

    /* ask lwIP to setup the network interface */
    netif_set_up(&netif);

#endif

#if LWIP_TCP
    /*tcpecho_init();
    shell_init();
    httpd_init();*/
#endif
#if LWIP_UDP
    /*udpecho_init();*/
#endif
  /*  sys_timeout(5000, tcp_debug_timeout, NULL);*/

  return 0;
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

    // lwIP initilization
    lwip_init();

    /* lwIP netif initilization */
    if(init_netifs() == -1){
        pp_printf("> error initializing lwIP netif! Exiting...\n");
        return -1;
    }

    /* Testing functions */
    print_header();
    /* Test memory pool */
    memmgr_test();
    /* Test leds */
    leds_test();
    /* Test button */
    button_test();
    print_end_header();

    /* Install ethernet interrupt handler, it is enabled here too */
    int_add(ETH0_IRQ, oeth_interrupt, &netif);
    int_add(2, &button, 0);

    //ethmac_setup(ETH0_PHY, ETH0_BUF); /* Configure MAC, TX/RX BDs and enable RX and TX in MODER */
    //ethmac_setup(ETH0_PHY); /* Configure MAC, TX/RX BDs and enable RX and TX in MODER */

    /* clear tx_done, the tx interrupt handler will set it when it's been transmitted */

    /* Configure EB DMA */
    //ethmac_adapt_set_base(0, (unsigned int)hisBody, (unsigned int)hisBody);
    //int_add(4, &set_eb_done, 0);

    /* Enable interrupts */
    //enable_irq();

    DBE_DEBUG(DBG_GENERIC | DBE_DBG_TRACE, "> begin main lwip loop\n");
    // Main loop
    while (1) {
      /* lwIP checkfor timeouts */
      sys_check_timeouts();
    }

    dbe_exit();

    return 0;
}
