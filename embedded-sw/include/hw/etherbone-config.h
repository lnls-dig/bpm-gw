#ifndef ETHERBONE_CONFIG
#define ETHERBONE_CONFIG

/* These values are taken directly from the Etherbone specification */
#define ERROR_STATUS_HIGH	0
#define ERROR_STATUS_LOW	4
#define SDB_ADDRESS_HIGH	8
#define SDB_ADDRSES_LOW		12

/* These are implementation specific */
#define EB_MAC_HIGH16		16
#define EB_MAC_LOW32		20
#define EB_IPV4			24
#define EB_PORT			28

#endif
