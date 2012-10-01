/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x8ddf5b5d */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
extern char *IEEE_P_2592010699;



int work_p_3157354128_sub_1165966991973796083_2599174331(char *t1, int t2)
{
    char t4[8];
    int t0;
    char *t5;
    int t6;
    int t7;
    int t8;
    unsigned char t9;

LAB0:    t5 = (t4 + 4U);
    *((int *)t5) = t2;
    t6 = 1;
    t7 = 64;

LAB2:    if (t6 <= t7)
        goto LAB3;

LAB5:    t0 = 63;

LAB1:    return t0;
LAB3:    t8 = xsi_vhdl_pow(2, t6);
    t9 = (t8 >= t2);
    if (t9 != 0)
        goto LAB6;

LAB8:
LAB7:
LAB4:    if (t6 == t7)
        goto LAB5;

LAB10:    t8 = (t6 + 1);
    t6 = t8;
    goto LAB2;

LAB6:    t0 = t6;
    goto LAB1;

LAB9:    goto LAB7;

LAB11:;
}

char *work_p_3157354128_sub_15107438780999777091_2599174331(char *t1, char *t2, unsigned char t3, int t4)
{
    char t5[128];
    char t6[16];
    char t10[16];
    char *t0;
    int t7;
    int t8;
    unsigned int t9;
    int t11;
    char *t12;
    char *t13;
    int t14;
    unsigned int t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;
    char *t23;
    int t24;
    int t25;
    int t26;
    char *t27;
    char *t28;
    int t29;
    char *t30;
    int t31;
    int t32;
    char *t33;
    int t34;
    unsigned int t35;
    unsigned int t36;
    char *t37;

LAB0:    t7 = (t4 - 1);
    t8 = (0 - t7);
    t9 = (t8 * -1);
    t9 = (t9 + 1);
    t9 = (t9 * 1U);
    t11 = (t4 - 1);
    t12 = (t10 + 0U);
    t13 = (t12 + 0U);
    *((int *)t13) = t11;
    t13 = (t12 + 4U);
    *((int *)t13) = 0;
    t13 = (t12 + 8U);
    *((int *)t13) = -1;
    t14 = (0 - t11);
    t15 = (t14 * -1);
    t15 = (t15 + 1);
    t13 = (t12 + 12U);
    *((unsigned int *)t13) = t15;
    t13 = (t5 + 4U);
    t16 = ((IEEE_P_2592010699) + 4000);
    t17 = (t13 + 88U);
    *((char **)t17) = t16;
    t18 = (char *)alloca(t9);
    t19 = (t13 + 56U);
    *((char **)t19) = t18;
    xsi_type_set_default_value(t16, t18, t10);
    t20 = (t13 + 64U);
    *((char **)t20) = t10;
    t21 = (t13 + 80U);
    *((unsigned int *)t21) = t9;
    t22 = (t6 + 4U);
    *((unsigned char *)t22) = t3;
    t23 = (t6 + 5U);
    *((int *)t23) = t4;
    t24 = (t4 - 1);
    t25 = 0;
    t26 = t24;

LAB2:    if (t25 <= t26)
        goto LAB3;

LAB5:    t12 = (t13 + 56U);
    t16 = *((char **)t12);
    t12 = (t10 + 12U);
    t9 = *((unsigned int *)t12);
    t9 = (t9 * 1U);
    t0 = xsi_get_transient_memory(t9);
    memcpy(t0, t16, t9);
    t17 = (t10 + 0U);
    t7 = *((int *)t17);
    t19 = (t10 + 4U);
    t8 = *((int *)t19);
    t20 = (t10 + 8U);
    t11 = *((int *)t20);
    t21 = (t2 + 0U);
    t27 = (t21 + 0U);
    *((int *)t27) = t7;
    t27 = (t21 + 4U);
    *((int *)t27) = t8;
    t27 = (t21 + 8U);
    *((int *)t27) = t11;
    t14 = (t8 - t7);
    t15 = (t14 * t11);
    t15 = (t15 + 1);
    t27 = (t21 + 12U);
    *((unsigned int *)t27) = t15;

LAB1:    return t0;
LAB3:    t27 = (t13 + 56U);
    t28 = *((char **)t27);
    t27 = (t10 + 0U);
    t29 = *((int *)t27);
    t30 = (t10 + 8U);
    t31 = *((int *)t30);
    t32 = (t25 - t29);
    t15 = (t32 * t31);
    t33 = (t10 + 4U);
    t34 = *((int *)t33);
    xsi_vhdl_check_range_of_index(t29, t34, t31, t25);
    t35 = (1U * t15);
    t36 = (0 + t35);
    t37 = (t28 + t36);
    *((unsigned char *)t37) = t3;

LAB4:    if (t25 == t26)
        goto LAB5;

LAB6:    t7 = (t25 + 1);
    t25 = t7;
    goto LAB2;

LAB7:;
}


extern void work_p_3157354128_init()
{
	static char *se[] = {(void *)work_p_3157354128_sub_1165966991973796083_2599174331,(void *)work_p_3157354128_sub_15107438780999777091_2599174331};
	xsi_register_didat("work_p_3157354128", "isim/isim_proj.sim/work/p_3157354128.didat");
	xsi_register_subprogram_executes(se);
}
