#include "board.h"
#include "inttypes.h"
#include "fmc150.h"

int fmc150_init()
{
  if (fmc150_devl->devices){
  //if (BASE_GPIO){
    // get first gpio device found
    fmc150 = (fmc150_t *)fmc150_devl->devices->base;//BASE_FMC150;
    return 1;
  }

  return 0; 
}

void update_fmc150_adc_delay(uint8_t adc_strobe_delay, uint8_t adc_cha_delay, uint8_t adc_chb_delay)
{
  uint32_t adc_delay;

  adc_delay = (uint32_t)adc_strobe_delay + 
              (uint32_t)adc_cha_delay << 8 +
              (uint32_t)adc_chb_delay << 16;

  fmc150->ADC_DLY = adc_delay;
  fmc150->FLGS_PULSE = 0x1;

  //return 1;
}

/* Check if 150 is busy */
int fmc150_poll(void)
{
  return fmc150->FLGS_OUT & FMC150_FLGS_OUT_SPI_BUSY;  
}

int read_fmc150_register(uint32_t cs, uint32_t addr, uint32_t* value)
{
  volatile u32 aux_value;

  if ((XIo_In32(FMC150_BASEADDR+
      OFFSET_FMC150_FLAGS_OUT_0*0x4) & MASK_AND_FLAGSOUT0_SPI_BUSY) != MASK_AND_FLAGSOUT0_SPI_BUSY)
  {
      aux_value = XIo_In32(FMC150_BASEADDR+OFFSET_FMC150_FLAGS_IN_0*0x4);
      XIo_Out32(FMC150_BASEADDR+OFFSET_FMC150_FLAGS_IN_0*0x4, aux_value | MASK_OR_FLAGSIN0_SPI_READ);
      XIo_Out32(FMC150_BASEADDR+OFFSET_FMC150_ADDR*0x4, addr);

      aux_value = XIo_In32(FMC150_BASEADDR+OFFSET_FMC150_CHIPSELECT*0x4) ^ chipselect;
      XIo_Out32(FMC150_BASEADDR+OFFSET_FMC150_CHIPSELECT*0x4, aux_value);

      /* Should test in order to see if this delay could be less than 10 */
      delay(10);

      *value = XIo_In32(FMC150_BASEADDR+OFFSET_FMC150_DATAOUT*0x4);

      return SUCCESS;
  }
  else
      return ERROR;
}
