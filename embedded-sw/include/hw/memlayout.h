#ifndef _MEM_LAYOUT_H_
#define _MEM_LAYOUT_H_
//TODO: Implement a simple memory pool in order to use with
// a malloc and free clone!!

// TODO: Automate this!
//#define NUM_DMA_DEVS 1
//#define NUM_FMC150_DEVS 1
//#define NUM_UART_DEVS 1
//#define NUM_GPIO_DEVS 2

/* Simple device nodes for supporting various instances
	of the same component */
struct dev_node{
	unsigned char *base;
	struct dev_node *next;
};

/* List of devices of the same kind (same devid).
	Note the use of flexible array member. Space is allocated
	only when instanciated */
struct dev_list{
	unsigned int devid;
	//unsigned int size;
	struct dev_node *devices;
};

/* Automate the address peripheral discover. use SDB */
#define SDB_ADDRESS 0x20000000

//unsigned char *BASE_DMA;
//unsigned char *BASE_FMA150;
//unsigned char *BASE_UART;
//unsigned char *BASE_GPIO;

struct dev_list *dma_devl;
struct dev_list *fmc150_devl;
struct dev_list *uart_devl;
struct dev_list *gpio_devl;

//#define FMC_EEPROM_ADR 0x50

void sdb_find_devices(void);
void sdb_print_devices(void);

/*************************/
/*		Base addresses		 */
/*************************/

/* RAM Definitions */
/* First RAM port */
//#define BASE_RAM_PORT_0 0x00000000
/* Second RAM port */
//#define BASE_RAM_PORT_1 0x10000000

/* DMA definitions */
//#define BASE_DMA_ADDR 0x20000400

/* FMC definitions */
//#define BASE_FMC150_ADDR 0x20000500

/* Simple UART definitions */
//#define BASE_UART_ADDR 0x20000600

/* Simple LED GPIO definitions */
//#define BASE_LEDS_ADDR 0x20000700

/* Simple Button GPIO definitions */
//#define BASE_BUTTONS_ADDR 0x20000800

#endif
