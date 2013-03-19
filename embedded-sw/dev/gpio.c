#include "board.h"      // Board definitions: GPIO device structure
#include "gpio.h"      // GPIO device functions
#include "memmgr.h"
#include "debug_print.h"

// Global GPIO handler.
gpio_t **gpio;

int gpio_init()
{
    int i;
    struct dev_node *dev_p = 0;

    if (!gpio_devl->devices)
        return -1;

    // get all base addresses
    gpio = (gpio_t **) memmgr_alloc(sizeof(gpio_t *)*gpio_devl->size);

    for (i = 0, dev_p = gpio_devl->devices; i < gpio_devl->size;
            ++i, dev_p = dev_p->next) {
        gpio[i] = (gpio_t *) dev_p->base;
        dbg_print("> gpio addr[%d]: %08X\n", i, dev_p->base);
    }

    dbg_print("> gpio size: %d\n", gpio_devl->size);
    //gpio = (gpio_t *)gpio_devl->devices->base;//BASE_GPIO;
    return 0;
}

int gpio_exit()
{
    // free gpio structure
    memmgr_free(gpio);

    return 0;
}

/* GPIO user interface definition */
void gpio_out(unsigned int id, int pin, int val)
{
    if(val)
        gpio[id]->SODR = (1<<pin);
    else
        gpio[id]->CODR = (1<<pin);
}

void gpio_dir(unsigned int id, int pin, int val)
{
    if(val)
        gpio[id]->DDR |= (1<<pin);
    else
        gpio[id]->DDR &= ~(1<<pin);
}

int gpio_in(unsigned int id, int pin)
{
    return gpio[id]->PSR & (1<<pin) ? 1 : 0;
}
