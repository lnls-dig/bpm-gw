#ifndef _ICMP_H_
#define _ICMP_H_

#include "proto.h"

extern volatile int sawPING;
extern volatile int hisBodyLen;
extern unsigned char hisBody[1516];

#endif
