#include "cpu-utils.h"
#include "board.h"
#include "int.h"
#include "ethmac.h"
#include "eth-phy-mii.h"

struct EB_CTRL {
  unsigned int doit;
  unsigned int base_tx;
  unsigned int base_rx;
  unsigned int length;
};

struct EB_CTRL* ebctl = (struct EB_CTRL*)0xA0000000U;

static const unsigned char myIP[]  = { 192, 168, 3, 2 };
static const unsigned char myMAC[] = { ETH_MACADDR0, ETH_MACADDR1, ETH_MACADDR2, ETH_MACADDR3, ETH_MACADDR4, ETH_MACADDR5 };
static const unsigned char allMAC[] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };

/* His info */
volatile static int sawARP = 0;
volatile static int sawPING = 0;
volatile static int hisBodyLen;
static unsigned char hisIP[4];
static unsigned char hisMAC[6];
static unsigned char hisBody[1516];

#define ETH_DEST	0
#define	ETH_SOURCE	(ETH_DEST+6)
#define	ETH_TYPE	(ETH_SOURCE+6)
#define ETH_END		(ETH_TYPE+2)

#define ARP_HTYPE	(ETH_END)
#define ARP_PTYPE	(ARP_HTYPE+2)
#define ARP_HLEN	(ARP_PTYPE+2)
#define ARP_PLEN	(ARP_HLEN+1)
#define ARP_OPER	(ARP_PLEN+1)
#define ARP_SHA		(ARP_OPER+2)
#define ARP_SPA		(ARP_SHA+6)
#define ARP_THA		(ARP_SPA+4)
#define ARP_TPA		(ARP_THA+6)
#define ARP_END		(ARP_TPA+4)

#define IP_VERSION	(ETH_END)
#define IP_TOS		(IP_VERSION+1)
#define IP_LEN		(IP_TOS+1)
#define IP_ID		(IP_LEN+2)
#define IP_FLAGS	(IP_ID+2)
#define IP_TTL		(IP_FLAGS+2)
#define IP_PROTOCOL	(IP_TTL+1)
#define IP_CHECKSUM	(IP_PROTOCOL+1)
#define IP_SOURCE	(IP_CHECKSUM+2)
#define IP_DEST		(IP_SOURCE+4)
#define IP_END		(IP_DEST+4)

#define ICMP_TYPE	(IP_END)
#define ICMP_CODE	(ICMP_TYPE+1)
#define ICMP_CHECKSUM	(ICMP_CODE+1)
#define ICMP_QUENCH	(ICMP_CHECKSUM+2)

unsigned int checksum(unsigned short* buf, int shorts) {
  int i;
  unsigned int sum;
  
  sum = 0;
  for (i = 0; i < shorts; ++i)
    sum += buf[i];
  
  sum = (sum >> 16) + (sum & 0xffff);
  sum += (sum >> 16);
  
  return (~sum & 0xffff);
}

void sendARP() {
  unsigned char buf[ARP_END];

  // ------------- Ethernet ------------  
  // MAC address
  memcpy(buf+ETH_DEST,   hisMAC, 6);
  memcpy(buf+ETH_SOURCE, myMAC,  6);
  // ethertype ARP
  buf[ETH_TYPE+0] = 0x08; 
  buf[ETH_TYPE+1] = 0x06;
  
  // ------------- ARP ------------  
  // HW ethernet
  buf[ARP_HTYPE+0] = 0;
  buf[ARP_HTYPE+1] = 1;
  // proto IP
  buf[ARP_PTYPE+0] = 8;
  buf[ARP_PTYPE+1] = 0;
  // lengths
  buf[ARP_HLEN] = 6;
  buf[ARP_PLEN] = 4;
  // Response
  buf[ARP_OPER+0] = 0;
  buf[ARP_OPER+1] = 2;
  // my MAC+IP
  memcpy(buf+ARP_SHA, myMAC, 6);
  memcpy(buf+ARP_SPA, myIP,  4);
  // his MAC+IP
  memcpy(buf+ARP_THA, hisMAC, 6);
  memcpy(buf+ARP_TPA, hisIP,  4);

  tx_packet(buf, sizeof(buf));
  sawARP = 0;
}

void sendECHO() {
  unsigned char buf[500];
  unsigned int sum;

  // ------------- Ethernet ------------  
  // MAC address
  memcpy(buf+ETH_DEST,   hisMAC, 6);
  memcpy(buf+ETH_SOURCE, myMAC,  6);
  // ethertype IP
  buf[ETH_TYPE+0] = 0x08; 
  buf[ETH_TYPE+1] = 0x00;
  
  // ------------ IP --------------
  buf[IP_VERSION] = 0x45;
  buf[IP_TOS] = 0;
  buf[IP_LEN+0] = (hisBodyLen+24) >> 8;
  buf[IP_LEN+1] = (hisBodyLen+24) & 0xff;
  buf[IP_ID+0] = 0;
  buf[IP_ID+1] = 0;
  buf[IP_FLAGS+0] = 0;
  buf[IP_FLAGS+1] = 0;
  buf[IP_TTL] = 63;
  buf[IP_PROTOCOL] = 1; /* ICMP */
  buf[IP_CHECKSUM+0] = 0;
  buf[IP_CHECKSUM+1] = 0;
  memcpy(buf+IP_SOURCE, myIP, 4);
  memcpy(buf+IP_DEST, hisIP, 4);
  
  // ------------ ICMP ---------
  buf[ICMP_TYPE] = 0x0; // echo reply
  buf[ICMP_CODE] = 0;
  buf[ICMP_CHECKSUM+0] = 0;
  buf[ICMP_CHECKSUM+1] = 0;
  memcpy(buf+ICMP_QUENCH, hisBody, hisBodyLen);
  if ((hisBodyLen & 1) != 0)
    buf[ICMP_QUENCH+hisBodyLen] = 0;
  
  sum = checksum((unsigned short*)(buf+ICMP_TYPE), (hisBodyLen+4+1)/2);
  buf[ICMP_CHECKSUM+0] = sum >> 8;
  buf[ICMP_CHECKSUM+1] = sum & 0xff;
  
  sum = checksum((unsigned short*)(buf+IP_VERSION), 10);
  buf[IP_CHECKSUM+0] = sum >> 8;
  buf[IP_CHECKSUM+1] = sum & 0xff;
  
  tx_packet(buf, hisBodyLen+ICMP_QUENCH);
  sawPING = 0;
}

static volatile int eb_done;
static void set_eb_done(void* arg) {
  eb_done = 1;
}

void user_recv(unsigned char* data, int length) {
  int iplen, i;
  
  /* If not for us or broadcast, ignore it */
  if (memcmp(data, allMAC, 6) && memcmp(data, myMAC, 6)) {
    return;
  }
  
  /* Is it ARP request targetting our IP? */
  if (data[ETH_TYPE+0] == 0x08 && 
      data[ETH_TYPE+1] == 0x06 && 
      data[ARP_OPER+0] == 0 &&
      data[ARP_OPER+1] == 1 &&
      !memcmp(data+ARP_TPA, myIP, 4)) {
    sawARP = 1;
    memcpy(hisMAC, data+ARP_SHA, 6);
    memcpy(hisIP,  data+ARP_SPA, 4);
  }
  
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
      }
    }
    /* UDP etherbone? */
    if (data[IP_PROTOCOL] == 0x11) {
      memcpy(hisBody, data, 14); /* bytes 14-16 = garbage */
      memcpy(hisBody+16, data+14, iplen);
      
      eb_done = 0;
      ebctl->length = iplen + 16;
      ebctl->doit = 1;
      while (!eb_done) { }
      
      /* shift out the padding */
      for (i = 12; i >= 2; --i)
        hisBody[i] = hisBody[i-2];
      tx_packet(hisBody+2, iplen+14);
    }
  }
}

int main ()
{
  /* Initialise handler vector */
  int_init();

  /* Install ethernet interrupt handler, it is enabled here too */
  int_add(ETH0_IRQ, oeth_interrupt, 0);

  ethmac_setup(ETH0_PHY, ETH0_BUF); /* Configure MAC, TX/RX BDs and enable RX and TX in MODER */

  /* clear tx_done, the tx interrupt handler will set it when it's been transmitted */
  
  /* Configure EB DMA */
  ebctl->base_tx = (unsigned int)hisBody;
  ebctl->base_rx = (unsigned int)hisBody;
  int_add(3, &set_eb_done, 0);

  while (1) {
    if (sawARP)
      sendARP();
    if (sawPING)
      sendECHO();
  }
  
  exit(0x8000000d);
}
