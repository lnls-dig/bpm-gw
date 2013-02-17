#include <string.h>

#include "ipv4.h"
#include "hw/memlayout.h"
#include "hw/etherbone-config.h"
#include "board.h"

//int needIP = 1;
//static uint8_t myIP[4];

unsigned char myIP[]  = { 10, 0, 18, 136 };
unsigned char myMAC[] = { ETH_MACADDR0, ETH_MACADDR1, ETH_MACADDR2, ETH_MACADDR3, ETH_MACADDR4, ETH_MACADDR5 };
unsigned char allMAC[] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
unsigned char hisIP[4];
unsigned char hisMAC[6];

unsigned int ipv4_checksum(unsigned short *buf, int shorts)
{
    int i;
    unsigned int sum;

    sum = 0;
    for (i = 0; i < shorts; ++i)
        sum += buf[i];

    sum = (sum >> 16) + (sum & 0xffff);
    sum += (sum >> 16);

    return (~sum & 0xffff);
}

//static int bootp_retry = 0;
//static int bootp_timer = 0;

//void getIP(unsigned char *IP)
//{
//    memcpy(IP, myIP, 4);
//}
//
//void setIP(unsigned char *IP)
//{
//    volatile unsigned int *eb_ip =
//            (unsigned int *)(BASE_ETHERBONE_CFG + EB_IPV4);
//    unsigned int ip;
//
//    memcpy(myIP, IP, 4);
//
//    ip = (myIP[0] << 24) | (myIP[1] << 16) | (myIP[2] << 8) | (myIP[3]);
//    while (*eb_ip != ip)
//        *eb_ip = ip;
//
//    needIP = (ip == 0);
//    if (!needIP) {
//        bootp_retry = 0;
//        bootp_timer = 0;
//    }
//}
