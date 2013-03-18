// Parts taken from pts (http://www.ohwr.org/projects/pts/repository)
// Parts taken from wr-switch-sw (http://www.ohwr.org/projects/wr-switch-sw/repository)

#include <inttypes.h>

#include "board.h"      // Board definitions: SPI device structure
#include "onewire.h"        // SPI device functions
#include "memmgr.h"     // malloc and free clones
#include "debug_print.h"

// Global SPI handler.
owr_t **owr;

int owr_init(void)
{
    int i;
    struct dev_node *dev_p = 0;

    if (!owr_devl->devices)
        return -1;

    // get all base addresses
    owr = (owr_t **) memmgr_alloc(sizeof(owr)*owr_devl->size);

    //dbg_print("> owr size: %d\n", owr_devl->size);

    for (i = 0, dev_p = owr_devl->devices; i < owr_devl->size;
            ++i, dev_p = dev_p->next) {
        owr[i] = (owr_t *) dev_p->base;
        // Default configuration
        owr[i]->CDR = (OWR_CDR_NOR(DEFAULT_OWR_DIVIDER_NOR)) |
                        (OWR_CDR_OVD(DEFAULT_OWR_DIVIDER_OVD));
        dbg_print("> owr addr[%d]: %08X\n", i, owr[i]);
    }

    dbg_print("> owr size: %d\n", owr_devl->size);
    //owr = (owr_t *)owr_devl->devices->base;
    return 0;
}

void owr_exit(void)
{
    memmgr_free(owr);
}

int oc_owr_poll(unsigned int id)
{
    return (owr[id]->CSR & OWR_CSR_CYC) ? 1 : 0;
}

int oc_owr_reset(unsigned int id, int port)
{
    // Request reset
    owr[id]->CSR = OWR_CSR_SEL(port) | OWR_CSR_CYC | OWR_CSR_RST;

    // Wait for completion
    while(oc_owr_poll(id));

    // Read presence status. 0 -> presence detected, 1 -> presence NOT detected
    //return (owr[id]->CSR & OWR_CSR_DAT) ? 0 : 1;
    return (~(owr[id]->CSR) & OWR_CSR_DAT);
}

int oc_owr_slot(unsigned int id, int port, uint32_t in_bit, uint32_t *out_bit)
{
    uint32_t rval;

    // Avoid breaking the code when just issuing a read command (out_bit can be null).
    // This is the case when in_bit = 0 (write 0 slot), but not for in_bit = 1
    // (write 1 and/or read slot)
    if (!out_bit)
        out_bit = &rval;

    owr[id]->CSR = OWR_CSR_SEL(port) | OWR_CSR_CYC | (in_bit & OWR_CSR_DAT);

    // Wait for completion
    while(oc_owr_poll(id));

    *out_bit = owr[id]->CSR & OWR_CSR_DAT;

    return 0;
}

int oc_owr_read_bit(unsigned int id, int port, uint32_t *out_bit)
{
    return oc_owr_slot(id, port, 0x1, out_bit);
}

int oc_owr_write_bit(unsigned int id, int port, uint32_t in_bit, uint32_t *out_bit)
{
    return oc_owr_slot(id, port, in_bit, out_bit);
}

int read_byte(unsigned int id, int port, uint32_t *out_byte)
{
    int i;
    uint32_t owr_data = 0;
    uint32_t owr_bit = 0;

    for (i = 0; i < 8; ++i) {
        oc_owr_read_bit(id, port, &owr_bit);
        owr_data |= owr_bit << i;
    }

    *out_byte = owr_data;

    return 0;
}

int write_byte(unsigned int id, int port, uint32_t in_byte)
{
    int i;
    uint32_t owr_data = 0;
    uint32_t owr_byte = in_byte;
    uint32_t owr_bit;

    for (i = 0; i < 8; ++i) {
        oc_owr_write_bit(id, port, owr_byte & 0x1, &owr_bit);
        owr_data |= owr_bit << i;
        owr_byte >>= 1;
    }

    if(owr_data == in_byte)
        return 0;
    else
        return -1;
}
