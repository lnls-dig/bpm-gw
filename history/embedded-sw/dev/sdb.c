#include "hw/memlayout.h"
#include "pp-printf.h"
#include "memmgr.h"      // malloc clone (memory pool)
#include "util.h"

#define SDB_INTERCONNET 0x00
#define SDB_DEVICE      0x01
#define SDB_BRIDGE      0x02
#define SDB_EMPTY      0xFF

typedef struct pair64 {
  uint32_t high;
  uint32_t low;
} pair64_t;

struct sdb_empty {
  int8_t reserved[63];
  uint8_t record_type;
};

struct sdb_product {
  pair64_t vendor_id;
  uint32_t device_id;
  uint32_t version;
  uint32_t date;
  int8_t name[19];
  uint8_t record_type;
};

struct sdb_component {
  pair64_t addr_first;
  pair64_t addr_last;
  struct sdb_product product;
};

struct sdb_device {
  uint16_t abi_class;
  uint8_t abi_ver_major;
  uint8_t abi_ver_minor;
  uint32_t bus_specific;
  struct sdb_component sdb_component;
};

struct sdb_bridge {
  pair64_t sdb_child;
  struct sdb_component sdb_component;
};

struct sdb_interconnect {
  uint32_t sdb_magic;
  uint16_t sdb_records;
  uint8_t sdb_version;
  uint8_t sdb_bus_type;
  struct sdb_component sdb_component;
};

typedef union sdb_record {
  struct sdb_empty empty;
  struct sdb_device device;
  struct sdb_bridge bridge;
  struct sdb_interconnect interconnect;
} sdb_record_t;

static unsigned char *find_device_deep(unsigned int base, unsigned int sdb,
    unsigned int devid)
{
  sdb_record_t *record = (sdb_record_t *) sdb;
  int records = record->interconnect.sdb_records;
  int i;

  for (i = 0; i < records; ++i, ++record) {
    if (record->empty.record_type == SDB_BRIDGE) {
      unsigned char *out =
        find_device_deep(base +
            record->bridge.sdb_component.
            addr_first.low,
            record->bridge.sdb_child.low,
            devid);
      if (out)
        return out;
    }
    if (record->empty.record_type == SDB_DEVICE &&
        record->device.sdb_component.product.device_id == devid) {
      break;
    }
  }

  if (i == records)
    return 0;

  return (unsigned char *)(base +
      record->device.sdb_component.addr_first.low);
}

static void find_device_deep_all_rec(struct dev_node **dev, unsigned int *size,
    unsigned int base, unsigned int sdb, unsigned int devid)
{
  sdb_record_t *record = (sdb_record_t *) sdb;
  int records = record->interconnect.sdb_records;
  int i;

  for (i = 0; i < records; ++i, ++record) {
    if (record->empty.record_type == SDB_BRIDGE) {
      find_device_deep_all_rec(dev, size, base +
          record->bridge.sdb_component.addr_first.low,
          record->bridge.sdb_child.low,
          devid);
    }
    if (record->empty.record_type == SDB_DEVICE &&
        record->device.sdb_component.product.device_id == devid) {
      // Alloc new node device
      *dev = (struct dev_node *)memmgr_alloc(sizeof(struct dev_node));
      (*dev)->base = (unsigned char *)(base +
          record->device.sdb_component.addr_first.low);
      // Ensure a null pointer on end of list
      (*dev)->next = 0;
      // Pass new node address
      dev = &(*dev)->next;
      (*size)++;
    }
  }
}

static struct dev_list *find_device_deep_all(unsigned int base, unsigned int sdb,
    unsigned int devid)
{
  // Device structure list
  struct dev_list *dev = (struct dev_list *)memmgr_alloc(sizeof(struct dev_list));

  // Initialize structure
  dev->devid = devid;
  dev->size = 0;
  dev->devices = 0;

  // Fill device list with the appropriate nodes
  find_device_deep_all_rec(&(dev->devices), &(dev->size), base, sdb, devid);

  return dev;
}

static void print_devices_deep(unsigned int base, unsigned int sdb)
{
  sdb_record_t *record = (sdb_record_t *) sdb;
  int records = record->interconnect.sdb_records;
  int i;
  char buf[20];

  for (i = 0; i < records; ++i, ++record) {
    if (record->empty.record_type == SDB_BRIDGE)
      print_devices_deep(base +
          record->bridge.sdb_component.
          addr_first.low,
          record->bridge.sdb_child.low);

    if (record->empty.record_type != SDB_DEVICE)
      continue;

    memcpy(buf, record->device.sdb_component.product.name, 19);
    buf[19] = 0;
    pp_printf("%8x:%8x 0x%8x %s\n",
        record->device.sdb_component.product.vendor_id.low,
        record->device.sdb_component.product.device_id,
        base + record->device.sdb_component.addr_first.low,
        buf);
  }
}

static unsigned char *find_device(unsigned int devid)
{
  return find_device_deep(0, SDB_ADDRESS, devid);
}

static struct dev_list *find_device_all(unsigned int devid)
{
  return find_device_deep_all(0, SDB_ADDRESS, devid);
}

void sdb_print_devices(void)
{
  pp_printf("-------------------------------------------\n");
  pp_printf("|            SDB memory map               |\n");
  pp_printf("-------------------------------------------\n\n");
  print_devices_deep(0, SDB_ADDRESS);
}

void sdb_find_devices(void)
{
  // Enumerate devices
  mem_devl = find_device_all(0x66cfeb52);
  dma_devl = find_device_all(0xcababa56);
  ethmac_devl = find_device_all(0xf8cfeb16);
  ethmac_adapt_devl = find_device_all(0x2ff9a28e);
  ebone_cfg_devl = find_device_all(0x68202b22);

  fmc516_devl = find_device_all(0x27b95341);
  spi_devl = find_device_all(0x40286417);
  i2c_devl = find_device_all(0x97b6323d);
  owr_devl = find_device_all(0x525fbb09);

  uart_devl = find_device_all(0x8a5719ae);
  gpio_devl = find_device_all(0x35aa6b95);
  tics_devl = find_device_all(0xfdafb9dd);
}
