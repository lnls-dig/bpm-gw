#ifndef _ICMP_H_
#define _ICMP_H_

#include "ipv4.h"

#define ICMP_TYPE (IP_END)
#define ICMP_CODE (ICMP_TYPE+1)
#define ICMP_CHECKSUM (ICMP_CODE+1)
// compatibility with test code
#define ICMP_QUENCH (ICMP_CHECKSUM+2)
#define ICMP_END  (ICMP_CHECKSUM+2)

extern volatile int sawPING;
extern volatile int hisBodyLen;
extern unsigned char hisBody[1516];

#endif
