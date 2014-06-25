/* LM32 JTAG relocatable debug ROM
 *
 * Load this code anywhere in memory and point DEBA at it.
 * When DC=1 it chain loads the exception handlers at EBA.
 * User exception handlers must save to the stack.
 *
 * Copyright (C) 2011 by Wesley W. Terpstra <w.terpstra@gsi.de>
 */


.section    .boot, "ax", @progbits
.global     _debug_unit
.align      256

_debug_unit:
_reset_handler:
	ori	r0, ra, 0			/* Save RA before destroying it */
	calli	_find0
_find0: addi	ra, ra, _registers-_find0	/* RA now points to _registers */
	sw	(ra+_gp-_registers), gp		/* Save user GP */
	ori	gp, ra, 0			/* GP now points to _registers */
	calli	save_all
_eid_offset:
	calli	handle_debug_trap
	bi	_e_restore_and_return

_breakpoint_handler:
	ori	r0, ra, 0			/* Save RA before destroying it */
	calli	_find1
_find1: addi	ra, ra, _registers-_find1	/* RA now points to _registers */
	sw	(ra+_gp-_registers), gp		/* Save user GP */
	ori	gp, ra, 0			/* GP now points to _registers */
	calli	save_all
	calli	handle_debug_trap
	bi	_b_restore_and_return

_instruction_bus_error_handler:
	ori	r0, ra, 0			/* Save RA before destroying it */
	calli	_find2
_find2: addi	ra, ra, _registers-_find2	/* RA now points to _registers */
	sw	(ra+_gp-_registers), gp		/* Save user GP */
	ori	gp, ra, 0			/* GP now points to _registers */
	calli	save_all
	calli	handle_debug_trap
	bi	_e_restore_and_return

_watchpoint_handler:
	ori	r0, ra, 0			/* Save RA before destroying it */
	calli	_find3
_find3: addi	ra, ra, _registers-_find3	/* RA now points to _registers */
	sw	(ra+_gp-_registers), gp		/* Save user GP */
	ori	gp, ra, 0			/* GP now points to _registers */
	calli	save_all
	calli	handle_debug_trap
	bi	_b_restore_and_return

_data_bus_error_handler:
	ori	r0, ra, 0			/* Save RA before destroying it */
	calli	_find4
_find4: addi	ra, ra, _registers-_find4	/* RA now points to _registers */
	sw	(ra+_gp-_registers), gp		/* Save user GP */
	ori	gp, ra, 0			/* GP now points to _registers */
	calli	save_all
	calli	handle_debug_trap
	bi	_e_restore_and_return

_divide_by_zero_handler:
	ori	r0, ra, 0			/* Save RA before destroying it */
	calli	_find5
_find5: addi	ra, ra, _registers-_find5	/* RA now points to _registers */
	sw	(ra+_gp-_registers), gp		/* Save user GP */
	ori	gp, ra, 0			/* GP now points to _registers */
	calli	save_all
	calli	handle_debug_trap
	bi	_e_restore_and_return

_interrupt_handler:
	ori	r0, ra, 0			/* Save RA before destroying it */
	calli	_find6
_find6: addi	ra, ra, _registers-_find6	/* RA now points to _registers */
	sw	(ra+_gp-_registers), gp		/* Save user GP */
	ori	gp, ra, 0			/* GP now points to _registers */
	calli	save_all
	calli	handle_debug_trap
	bi	_e_restore_and_return

_system_call_handler:
	ori	r0, ra, 0			/* Save RA before destroying it */
	calli	_find7
_find7: addi	ra, ra, _registers-_find7	/* RA now points to _registers */
	sw	(ra+_gp-_registers), gp		/* Save user GP */
	ori	gp, ra, 0			/* GP now points to _registers */
	calli	save_all
	calli	handle_debug_trap
	bi	_e_restore_and_return

/* Restore registers and return from breakpoint */
_b_restore_and_return:
	/* first restore gp registers */
	calli	restore_gp
	/* load the last two registers */
	lw	ra, (gp+_ra-_registers)
	lw	gp, (gp+_gp-_registers)
	bret

/* Restore registers and chain execution to the user exception handler */
_e_restore_and_return:
	/* first restore gp registers */
	calli	restore_gp
	lw	ba, (gp+_eid-_registers)
	rcsr	ra, EBA
	add	ba, ba, ra
	/* load the last two registers */
	lw	ra, (gp+_ra-_registers)
	lw	gp, (gp+_gp-_registers)
	b	ba

save_all:
	/* Save registers */
	sw	(gp+_r1 -_registers), r1
	sw	(gp+_r2 -_registers), r2
	sw	(gp+_r3 -_registers), r3
	sw	(gp+_r4 -_registers), r4
	sw	(gp+_r5 -_registers), r5
	sw	(gp+_r6 -_registers), r6
	sw	(gp+_r7 -_registers), r7
	sw	(gp+_r8 -_registers), r8
	sw	(gp+_r9 -_registers), r9
	sw	(gp+_r10-_registers), r10
	sw	(gp+_r11-_registers), r11
	sw	(gp+_r12-_registers), r12
	sw	(gp+_r13-_registers), r13
	sw	(gp+_r14-_registers), r14
	sw	(gp+_r15-_registers), r15
	sw	(gp+_r16-_registers), r16
	sw	(gp+_r17-_registers), r17
	sw	(gp+_r18-_registers), r18
	sw	(gp+_r19-_registers), r19
	sw	(gp+_r20-_registers), r20
	sw	(gp+_r21-_registers), r21
	sw	(gp+_r22-_registers), r22
	sw	(gp+_r23-_registers), r23
	sw	(gp+_r24-_registers), r24
	sw	(gp+_r25-_registers), r25
	/* GP already saved by handler */
	sw	(gp+_fp -_registers), fp
	sw	(gp+_sp -_registers), sp
	sw	(gp+_ra -_registers), r0 /* handler saved RA in R0 */
	sw	(gp+_ea -_registers), ea
	sw	(gp+_ba -_registers), ba

	/* Calculate EID*32 = ra - _eid_offset */
	sub	r1, ra, gp
	addi	r1, r1, _registers-_eid_offset
	sw	(gp+_eid-_registers), r1

	/* Start saving the CSRs */
	rcsr	r1, EBA
	sw	(gp+_eba-_registers), r1
	rcsr	r1, DEBA
	sw	(gp+_deba-_registers), r1
	rcsr	r1, IE
	sw	(gp+_ie-_registers), r1
	rcsr	r1, IM
	sw	(gp+_im-_registers), r1
	rcsr	r1, IP
	sw	(gp+_ip-_registers), r1
	rcsr	r1, CC
	sw	(gp+_cc-_registers), r1
	rcsr	r1, CFG
	sw	(gp+_cfg-_registers), r1

	/* Prep R0 for normal work */
	xor	r0, r0, r0
	ret

/* Restore gp registers */
restore_gp:
	/* Write CSRs */
	lw	r1, (gp + _eba-_registers)
	wcsr	EBA, r1
	lw	r1, (gp + _deba-_registers)
	wcsr	DEBA, r1
	lw	r1, (gp + _ie-_registers)
	wcsr	IE, r1
	lw	r1, (gp + _im-_registers)
	wcsr	IM, r1
	lw	r1, (gp + _dc-_registers)
	wcsr	DC, r1
	lw	r1, (gp + _bp0-_registers)
	wcsr	BP0, r1
	lw	r1, (gp + _bp1-_registers)
	wcsr	BP1, r1
	lw	r1, (gp + _bp2-_registers)
	wcsr	BP2, r1
	lw	r1, (gp + _bp3-_registers)
	wcsr	BP3, r1
	lw	r1, (gp + _wp0-_registers)
	wcsr	WP0, r1
	lw	r1, (gp + _wp1-_registers)
	wcsr	WP1, r1
	lw	r1, (gp + _wp2-_registers)
	wcsr	WP2, r1
	lw	r1, (gp + _wp3-_registers)
	wcsr	WP3, r1

	/* Write registers */
	lw	r1,  (gp+_r1 -_registers)
	lw	r2,  (gp+_r2 -_registers)
	lw	r3,  (gp+_r3 -_registers)
	lw	r4,  (gp+_r4 -_registers)
	lw	r5,  (gp+_r5 -_registers)
	lw	r6,  (gp+_r6 -_registers)
	lw	r7,  (gp+_r7 -_registers)
	lw	r8,  (gp+_r8 -_registers)
	lw	r9,  (gp+_r9 -_registers)
	lw	r10, (gp+_r10-_registers)
	lw	r11, (gp+_r11-_registers)
	lw	r12, (gp+_r12-_registers)
	lw	r13, (gp+_r13-_registers)
	lw	r14, (gp+_r14-_registers)
	lw	r15, (gp+_r15-_registers)
	lw	r16, (gp+_r16-_registers)
	lw	r17, (gp+_r17-_registers)
	lw	r18, (gp+_r18-_registers)
	lw	r19, (gp+_r19-_registers)
	lw	r20, (gp+_r20-_registers)
	lw	r21, (gp+_r21-_registers)
	lw	r22, (gp+_r22-_registers)
	lw	r23, (gp+_r23-_registers)
	lw	r24, (gp+_r24-_registers)
	lw	r25, (gp+_r25-_registers)
	/* Restore GP later */
	lw	fp,  (gp+_fp -_registers)
	/* Restore RA later */
	lw	sp,  (gp+_sp -_registers)
	lw	ea,  (gp+_ea -_registers)
	lw	ba,  (gp+_ba -_registers)
	ret

jtag_get_byte:
	rcsr	r2, JRX
	andi	r1, r2, 0x100
	be	r1, r0, jtag_get_byte
	wcsr	JRX, r0
	andi	r1, r2, 0xff
	ret

jtag_get_word:
	ori	r27, ra, 0
	calli	jtag_get_byte
	sb	(gp+_scratch-_registers+0), r1
	calli	jtag_get_byte
	sb	(gp+_scratch-_registers+1), r1
	calli	jtag_get_byte
	sb	(gp+_scratch-_registers+2), r1
	calli	jtag_get_byte
	sb	(gp+_scratch-_registers+3), r1
	lw	r1, (gp+_scratch-_registers)
	ori	ra, r27, 0
	ret

jtag_put_byte:
	rcsr	r2, JTX
	bne	r2, r0, jtag_put_byte
	andi	r2, r1, 0xff
	wcsr	JTX, r2
	ret

jtag_put_word:
	ori	r27, ra, 0
	sw	(gp+_scratch-_registers), r1
	lbu	r1, (gp+_scratch-_registers+0)
	calli	jtag_put_byte
	lbu	r1, (gp+_scratch-_registers+1)
	calli	jtag_put_byte
	lbu	r1, (gp+_scratch-_registers+2)
	calli	jtag_put_byte
	lbu	r1, (gp+_scratch-_registers+3)
	calli	jtag_put_byte
	ori	ra, r27, 0
	ret

handle_debug_trap:
	ori	r28, ra, 0

	/* Report the debug ROM version */
	mvi	r1, 0x80 + 'B'
	calli	jtag_put_byte

_get_command:
	/* Input: [Wxxxxxxx]
         *   W=0, x=0:  quit debug trap
         *   W=1, x=0:  report register dump location
         *   W=0, x>0:  read 'x' bytes
         *   W=1, x>0:  write 'x' bytes
         */
	calli	jtag_get_byte
	be	r1, r0, _done_debug_trap

	/* Setup args: r10=write, r11=base, r12=length */
	andi	r10, r1, 0x80
	andi	r12, r1, 0x7f
	be	r12, r0, _read_registers

	/* Load memory access address */
	calli	jtag_get_word
	mv	r11, r1

	/* Either read or write */
	bne	r10, r0, _read_mem

_write_mem:
	be	r12, r0, _write_end
	calli	jtag_get_byte
	sb	(r11+0), r1
	addi	r11, r11, 1
	addi	r12, r12, -1
	bi	_write_mem
_write_end:
	bi	_get_command

_read_mem:
	be	r12, r0, _read_end
	lbu	r1, (r11+0)
	calli	jtag_put_byte
	addi	r11, r11, 1
	addi	r12, r12, -1
	bi	_read_mem
_read_end:
	bi	_get_command

_read_registers:
	/* Report the offset of the registers */
	mv	r1, gp
	calli	jtag_put_word
	bi	_get_command

_done_debug_trap:
	wcsr	DCC, r0
	wcsr	ICC, r0
	nop
	nop
	nop
	nop
	ori	ra, r28, 0
	ret

_registers:
_r0:	/* Never used */
	.space 4
_r1:
	.space 4
_r2:
	.space 4
_r3:
	.space 4
_r4:
	.space 4
_r5:
	.space 4
_r6:
	.space 4
_r7:
	.space 4
_r8:
	.space 4
_r9:
	.space 4
_r10:
	.space 4
_r11:
	.space 4
_r12:
	.space 4
_r13:
	.space 4
_r14:
	.space 4
_r15:
	.space 4
_r16:
	.space 4
_r17:
	.space 4
_r18:
	.space 4
_r19:
	.space 4
_r20:
	.space 4
_r21:
	.space 4
_r22:
	.space 4
_r23:
	.space 4
_r24:
	.space 4
_r25:
	.space 4
_gp:
	.space 4
_fp:
	.space 4
_sp:
	.space 4
_ra:
	.space 4
_ea:
	.space 4
_ba:
	.space 4

/* Never used -- but matches gdb layout (filled in by lm32-rom.cpp) */
_pc:
	.space 4
/* What exception happened *32 */
_eid:
	.space 4

/* CSRs */
_eba:	/* RW */
	.space 4
_deba:	/* RW */
	.space 4
_ie:	/* RW */
	.space 4
_im:	/* RW */
	.space 4
_ip:	/* R */
	.space 4
/* ICC and DCC flushed on continue */
_cc:	/* R */
	.space 4
_cfg:	/* R */
	.space 4
_dc:	/* W */
	.space 4
/* JTX and JRX used by ROM */
_bp0:	/* W */
	.space 4
_bp1:	/* W */
	.space 4
_bp2:	/* W */
	.space 4
_bp3:	/* W */
	.space 4
_wp0:	/* W */
	.space 4
_wp1:	/* W */
	.space 4
_wp2:	/* W */
	.space 4
_wp3:	/* W */
	.space 4

/* used for assembling a word from bytes */
_scratch:
	.space 4
