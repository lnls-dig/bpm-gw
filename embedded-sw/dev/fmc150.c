#include "board.h"
#include "inttypes.h"
#include "fmc150.h"

/* Register values for cdce72010 */
uint32_t cdce72010_regs[CDCE72010_NUMREGS] = {
//internal reference clock. Default config.
	/*0x683C0310,
	0x68000021,
	0x83040002,
	0x68000003,
	0xE9800004,
	0x68000005,
	0x68000006,
	0x83800017,
	0x68000098,
	0x68050CC9,
	0x05FC270A,
	0x0280044B,
	0x0000180C*/

//3.84MHz ext clock. Does not lock.
	/*0x682C0290,
	0x68840041,
	0x83840002,
	0x68400003,
	0xE9800004,
	0x68000005,
	0x68000006,
	0x83800017,
	0x68000098,
	0x68000C49,
	0x0BFC02FA,
	0x8000050B,
	0x0000180C*/

//61.44MHz ext clock. LOCK.
	/*0x682C0290,
	0x68840041,
	0x83040002,
	0x68400003,
	0xE9800004,
	0x68000005,
	0x68000006,
	0x83800017,
	0x68000098,
	0x68000049,
	0x0024009A,
	0x8000050B,
	0x0000180C*/

//7.68MHz ext clock. Lock.
// Use with Libera RF & clock generator. RF = 291.840MHz, MCf = 7.680MHz, H = 38
// DDS = 3.072MHz -> Phase increment = 2048d
	0x682C0290,
	0x68840041,
	0x83860002, 	//divide by 5
	//0x83840002,		//divide by 4
	0x68400003,
	0xE9800004,
	0x68000005,
	0x68000006,
	0x83800017,
	0x68000098,
	0x68000049,
	0x007C003A, // PFD_freq = 1.92MHz
	0x8000050B,
	0x0000180C

//15.36MHz ext clock.
	/*0x682C0290,
	0x68840041,
	0x83840002,
	/*;83020002,;divide by 6
	;83860002,	;divide by 5
	;83800002,	;divide by 2
	;83840002,	;divide by 4
	;83060002,	;divide by 8
	0x68400003,
	0xE9800004,
	0x68000005,
	0x68000006,
	0x83800017,
	0x68000098,
	0x68000049,
	0x003C003A,
	0x8000050B,
	0x0000180C*/

//9.6MHz ext clock.
	/*0x682C0290,
	0x68840041,
	0x83860002,//;divide by 5
	0x68400003,
	0xE9800004,
	0x68000005,
	0x68000006,
	0x83800017,
	0x68000098,
	0x68000049,
	0x007C004A,
	0x8000050B,
	0x0000180C*/

	//9.250MHz ext clock. No lock
	/*0x682C0290,
	0x68840041,
	0x83860002,
	0x68400003,
	0xE9800004,
	0x68000005,
	0x68000006,
	0x83800017,
	0x68000098,
	0x68000049,
	0x5FFC39CA,
	//0x8000390B,	// DIvide by 32
	0x8000050B, //Divide by 8
	0x0000180C*/

	//10.803 (originally 10.803 actually) ext clock.
	//Could it be something related to the lock window? see cdce72010 datasheet
	/*0x682C0290,
	0x68840041,
	0x83840002,
	0x68400003,
	0xE9800004,
	0x68000005,
	0x68000006,
	0x83800017,
	0x68000098,
	0x68000049,
	0x03FC02CA,
	0x8000050B,
	0x0000180C*/
};

// Global FMC150 handler.
fmc150_t *fmc150;

int fmc150_init(void)
{
  if (fmc150_devl->devices){
  //if (BASE_GPIO){
    // get first gpio device found
    fmc150 = (fmc150_t *)fmc150_devl->devices->base;//BASE_FMC150;
    return 0;
  }

  return -1; 
}

void update_fmc150_adc_delay(uint8_t adc_strobe_delay, uint8_t adc_cha_delay, uint8_t adc_chb_delay)
{
  fmc150->ADC_DLY = (uint32_t) FMC150_ADC_DLY_STR_W(adc_strobe_delay) + 
										(uint32_t) FMC150_ADC_DLY_CHA_W(adc_cha_delay) + 
										(uint32_t) FMC150_ADC_DLY_CHB_W(adc_chb_delay); 
  fmc150->FLGS_PULSE = 0x1;
}

/* Check if 150 is busy */
int fmc150_poll(void)
{
  return fmc150->FLGS_OUT & FMC150_FLGS_OUT_SPI_BUSY;  
}

int read_fmc150_register(uint32_t cs, uint32_t addr, uint32_t* data)
{
	// Test if SPI interface is busy
	if (!fmc150_poll())
		return -1;

	// Set bit to read from SPI
	fmc150->FLGS_IN |= FMC150_FLGS_IN_SPI_RW;

	// Set address to read from
	fmc150->ADDR = addr;

	// Toggle chipselect
	fmc150->CS ^= cs;	

	// Sleeps 10*4 processor cycles. Is that enough? */
	delay(10);

	// Get data from register
	*data = fmc150->DATA_OUT;

	return 0;
}

int write_fmc150_register(uint32_t cs, uint32_t addr, uint32_t data)
{
	// Test if SPI interface is busy
	if (!fmc150_poll())
		return -1;

	// Set bit to write from SPI
	fmc150->FLGS_IN &= ~FMC150_FLGS_IN_SPI_RW;

	// Set address to write to
	fmc150->ADDR = addr;

	// Set value to write to
	fmc150->DATA_IN = data;
	
	// Toggle chipselect
	fmc150->CS ^= cs;	

	return 0;
}

int init_cdce72010()
{
	int i;
	uint32_t reg;

	/* Write regs to cdce72010 statically */
	for(i = 0; i < CDCE72010_NUMREGS; ++i){
		if (!fmc150_poll())
			return -1;

//#ifdef FMC150_DEBUG
		mprintf("init_cdce72010: writing data: %08X at byte offset: %08X\n", cdce72010_regs[i], i*0x4);
//#endif
		
		// This core is byte addressed , hence the i*0x4
		write_fmc150_register(FMC150_CS_CDCE72010, i*0x4, cdce72010_regs[i]);

//#ifdef FMC150_DEBUG
		// Do a write-read cycle in order to ensure that we wrote the correct value
		delay(20);

		if (!fmc150_poll())
			return -1;

		read_fmc150_register(FMC150_CS_CDCE72010, i*0x4, &reg);
		mprintf("init_cdce72010: reading data: %08X at byte offset: %08X\n", reg, i*0x4);
//#endif
	}

	return 0;
}
