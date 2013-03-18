// Parts taken from pts (http://www.ohwr.org/projects/pts/repository)
// Parts taken from wr-switch-sw (http://www.ohwr.org/projects/wr-switch-sw/repository)

#include <inttypes.h>

#include "board.h"      // Board definitions: SPI device structure
#include "i2c.h"        // SPI device functions
#include "memmgr.h"     // malloc and free clones
#include "debug_print.h"

// Global SPI handler.
i2c_t **i2c;

int i2c_init(void)
{
	int i;
	struct dev_node *dev_p = 0;

	if (!i2c_devl->devices)
		return -1;

	// get all base addresses
	i2c = (i2c_t **) memmgr_alloc(sizeof(i2c)*i2c_devl->size);

	//dbg_print("> i2c size: %d\n", i2c_devl->size);

	for (i = 0, dev_p = i2c_devl->devices; i < i2c_devl->size;
			++i, dev_p = dev_p->next) {
		i2c[i] = (i2c_t *) dev_p->base;
		// Default configuration
		i2c[i]->CTR = 0;
		i2c[i]->PREL = DEFAULT_I2C_PRESCALER & 0xFF;
		i2c[i]->PREH = (DEFAULT_I2C_PRESCALER >> 8) & 0xFF;
		// Enbale core
		i2c[i]->CTR = I2C_CTR_EN;

		// Check if the core is indeed enabled
		if (!(i2c[i]->CTR & I2C_CTR_EN))
			return -1;

		//dbg_print("> i2c addr[%d]: %08X\n", i, i2c[i]);
	}
	//i2c = (i2c_t *)i2c_devl->devices->base;;
	return 0;
}

void i2c_exit(void)
{
	memmgr_free(i2c);
}

int oc_i2c_poll(unsigned int id)
{
	return (i2c[id]->SR & I2C_SR_TIP) ? 1 : 0;
}

int oc_i2c_start(unsigned int id, int addr, int read)
{
	uint32_t i2c_addr;

	// shift addr bits as the last one represents rw bit (read = 1, write = 0)
	i2c_addr = I2C_ADDR(addr);

	if (read == 1)
		i2c_addr |= I2C_TXR_READ;

	i2c[id]->TXR = i2c_addr;

	// Start transaction. Generates repeated start condition and write to slave
	i2c[id]->CR = I2C_CR_STA | I2C_CR_WR;

	// Wait for completion
	while(oc_i2c_poll(id));

	// Check if we received an ACK from slave
	if (i2c[id]->SR & I2C_SR_RXACK) {
		dbg_print("> no ack received from slave at addr 0X%2X\n", addr);
		return -1;
	}

	return 0;
}

int oc_i2c_rx(unsigned int id, uint32_t *out, int last)
{
	uint32_t i2c_cmd;

	i2c_cmd = I2C_CR_RD;

	// Generates STOP condition and send NACK on completion
	if(last)
		i2c_cmd |= I2C_CR_STO | I2C_CR_ACK;

	i2c[id]->CR = i2c_cmd;

	// Wait for completion
	while(oc_i2c_poll(id));

	// Check if we received an ACK from slave
	if (i2c[id]->SR & I2C_SR_RXACK) {
		dbg_print("> no ack received from slave at rx transaction\n");
		return -1;
	}

	*out = i2c[id]->RXR & 0xFF;

	return 0;
}

int oc_i2c_tx(unsigned int id, uint32_t in, int last)
{
	uint32_t i2c_cmd;

	// We don't really care about sizes here as only the 8 LSB
	// are effectivelly written to the I2C core and no harm is inflicted
	// by doing this.
	i2c[id]->TXR = in;

	// Write command
	i2c_cmd = I2C_CR_WR;

	// Generates STOP condition
	if(last)
		i2c_cmd |= I2C_CR_STO;

	i2c[id]->CR = i2c_cmd;

	// Wait for completion
	while(oc_i2c_poll(id));

	// Check if we received an ACK from slave
	if (i2c[id]->SR & I2C_SR_RXACK) {
		dbg_print("> no ack received from slave at tx transaction\n");
		return -1;
	}

	return 0;
}

// This just prints if devices have been found at specified addresses
int oc_i2c_scan(unsigned int id)
{
	int i;
	uint32_t i2c_addr;

	for (i = 0; i < 128; ++i) {
		i2c_addr = I2C_ADDR(i) | I2C_TXR_READ;

		i2c[id]->TXR = i2c_addr;
		i2c[id]->CR = I2C_CR_STA | I2C_CR_WR;

		// Wait for completion
		while(oc_i2c_poll(id));

		// Check if we received an ACK from slave
		if (!(i2c[id]->SR & I2C_SR_RXACK)) {
			dbg_print("> device found at addr 0X%02X\n", i);

			i2c[id]->TXR = 0;
			i2c[id]->CR = I2C_CR_STO | I2C_CR_WR;
			while(oc_i2c_poll(id));
		}
	}

	return 0;
}
