
main.elf:     file format elf32-lm32


Disassembly of section .boot:

00000000 <_reset_handler>:
   0:	98 00 00 00 	xor r0,r0,r0
   4:	d0 00 00 00 	wcsr IE,r0
   8:	d0 20 00 00 	wcsr IM,r0
   c:	78 01 00 00 	mvhi r1,0x0
  10:	38 21 00 00 	ori r1,r1,0x0
  14:	d0 e1 00 00 	wcsr EBA,r1
  18:	f8 00 00 3a 	calli 100 <_crt0>
  1c:	34 00 00 00 	nop
	...

000000c0 <_interrupt_handler>:
  c0:	5b 9d 00 00 	sw (sp+0),ra
  c4:	f8 00 00 20 	calli 144 <_save_all>
  c8:	34 01 00 02 	mvi r1,2
  cc:	f8 00 00 4a 	calli 1f4 <_irq_entry>
  d0:	e0 00 00 30 	bi 190 <_restore_all_and_return>
  d4:	34 00 00 00 	nop
  d8:	34 00 00 00 	nop
  dc:	34 00 00 00 	nop
	...

00000100 <_crt0>:
 100:	98 00 00 00 	xor r0,r0,r0
 104:	78 1c 00 00 	mvhi sp,0x0
 108:	3b 9c ff fc 	ori sp,sp,0xfffc
 10c:	78 1a 00 00 	mvhi gp,0x0
 110:	3b 5a 85 90 	ori gp,gp,0x8590
 114:	78 01 00 00 	mvhi r1,0x0
 118:	38 21 05 98 	ori r1,r1,0x598
 11c:	34 02 00 00 	mvi r2,0
 120:	78 03 00 00 	mvhi r3,0x0
 124:	38 63 05 98 	ori r3,r3,0x598
 128:	c8 61 18 00 	sub r3,r3,r1
 12c:	f8 00 00 d7 	calli 488 <memset>
 130:	34 01 00 00 	mvi r1,0
 134:	34 02 00 00 	mvi r2,0
 138:	34 03 00 00 	mvi r3,0
 13c:	f8 00 00 2f 	calli 1f8 <main>

00000140 <loopf>:
 140:	e0 00 00 00 	bi 140 <loopf>

00000144 <_save_all>:
 144:	37 9c ff c4 	addi sp,sp,-60
 148:	5b 81 00 04 	sw (sp+4),r1
 14c:	5b 82 00 08 	sw (sp+8),r2
 150:	5b 83 00 0c 	sw (sp+12),r3
 154:	5b 84 00 10 	sw (sp+16),r4
 158:	5b 85 00 14 	sw (sp+20),r5
 15c:	5b 86 00 18 	sw (sp+24),r6
 160:	5b 87 00 1c 	sw (sp+28),r7
 164:	5b 88 00 20 	sw (sp+32),r8
 168:	5b 89 00 24 	sw (sp+36),r9
 16c:	5b 8a 00 28 	sw (sp+40),r10
 170:	5b 9e 00 34 	sw (sp+52),ea
 174:	5b 9f 00 38 	sw (sp+56),ba
 178:	2b 81 00 3c 	lw r1,(sp+60)
 17c:	5b 81 00 30 	sw (sp+48),r1
 180:	bb 80 08 00 	mv r1,sp
 184:	34 21 00 3c 	addi r1,r1,60
 188:	5b 81 00 2c 	sw (sp+44),r1
 18c:	c3 a0 00 00 	ret

00000190 <_restore_all_and_return>:
 190:	2b 81 00 04 	lw r1,(sp+4)
 194:	2b 82 00 08 	lw r2,(sp+8)
 198:	2b 83 00 0c 	lw r3,(sp+12)
 19c:	2b 84 00 10 	lw r4,(sp+16)
 1a0:	2b 85 00 14 	lw r5,(sp+20)
 1a4:	2b 86 00 18 	lw r6,(sp+24)
 1a8:	2b 87 00 1c 	lw r7,(sp+28)
 1ac:	2b 88 00 20 	lw r8,(sp+32)
 1b0:	2b 89 00 24 	lw r9,(sp+36)
 1b4:	2b 8a 00 28 	lw r10,(sp+40)
 1b8:	2b 9d 00 30 	lw ra,(sp+48)
 1bc:	2b 9e 00 34 	lw ea,(sp+52)
 1c0:	2b 9f 00 38 	lw ba,(sp+56)
 1c4:	2b 9c 00 2c 	lw sp,(sp+44)
 1c8:	34 00 00 00 	nop
 1cc:	c3 c0 00 00 	eret

Disassembly of section .text:

000001d0 <delay.clone.0>:
 1d0:	78 02 00 00 	mvhi r2,0x0
 1d4:	38 42 05 8c 	ori r2,r2,0x58c
 1d8:	28 41 00 00 	lw r1,(r2+0)
 1dc:	34 02 ff ff 	mvi r2,-1
 1e0:	e0 00 00 02 	bi 1e8 <delay.clone.0+0x18>
 1e4:	34 00 00 00 	nop
 1e8:	34 21 ff ff 	addi r1,r1,-1
 1ec:	5c 22 ff fe 	bne r1,r2,1e4 <delay.clone.0+0x14>
 1f0:	c3 a0 00 00 	ret

000001f4 <_irq_entry>:
 1f4:	c3 a0 00 00 	ret

000001f8 <main>:
 1f8:	37 9c ff f4 	addi sp,sp,-12
 1fc:	5b 8b 00 0c 	sw (sp+12),r11
 200:	5b 8c 00 08 	sw (sp+8),r12
 204:	5b 9d 00 04 	sw (sp+4),ra
 208:	78 02 00 00 	mvhi r2,0x0
 20c:	38 42 05 90 	ori r2,r2,0x590
 210:	28 41 00 00 	lw r1,(r2+0)
 214:	34 0b 00 00 	mvi r11,0
 218:	34 0c 00 07 	mvi r12,7
 21c:	f8 00 00 69 	calli 3c0 <uart_init>
 220:	78 02 00 00 	mvhi r2,0x0
 224:	38 42 05 90 	ori r2,r2,0x590
 228:	28 41 00 00 	lw r1,(r2+0)
 22c:	34 02 00 41 	mvi r2,65
 230:	f8 00 00 67 	calli 3cc <uart_write_byte>
 234:	fb ff ff e7 	calli 1d0 <delay.clone.0>
 238:	78 02 00 00 	mvhi r2,0x0
 23c:	38 42 05 90 	ori r2,r2,0x590
 240:	28 41 00 00 	lw r1,(r2+0)
 244:	34 02 00 42 	mvi r2,66
 248:	f8 00 00 61 	calli 3cc <uart_write_byte>
 24c:	fb ff ff e1 	calli 1d0 <delay.clone.0>
 250:	78 02 00 00 	mvhi r2,0x0
 254:	38 42 05 90 	ori r2,r2,0x590
 258:	28 41 00 00 	lw r1,(r2+0)
 25c:	34 02 00 43 	mvi r2,67
 260:	f8 00 00 5b 	calli 3cc <uart_write_byte>
 264:	fb ff ff db 	calli 1d0 <delay.clone.0>
 268:	78 02 00 00 	mvhi r2,0x0
 26c:	38 42 05 90 	ori r2,r2,0x590
 270:	28 41 00 00 	lw r1,(r2+0)
 274:	34 02 00 44 	mvi r2,68
 278:	f8 00 00 55 	calli 3cc <uart_write_byte>
 27c:	fb ff ff d5 	calli 1d0 <delay.clone.0>
 280:	78 02 00 00 	mvhi r2,0x0
 284:	38 42 05 90 	ori r2,r2,0x590
 288:	28 41 00 00 	lw r1,(r2+0)
 28c:	34 02 00 45 	mvi r2,69
 290:	f8 00 00 4f 	calli 3cc <uart_write_byte>
 294:	fb ff ff cf 	calli 1d0 <delay.clone.0>
 298:	78 02 00 00 	mvhi r2,0x0
 29c:	38 42 05 90 	ori r2,r2,0x590
 2a0:	28 41 00 00 	lw r1,(r2+0)
 2a4:	34 02 00 46 	mvi r2,70
 2a8:	f8 00 00 49 	calli 3cc <uart_write_byte>
 2ac:	fb ff ff c9 	calli 1d0 <delay.clone.0>
 2b0:	78 02 00 00 	mvhi r2,0x0
 2b4:	38 42 05 90 	ori r2,r2,0x590
 2b8:	28 41 00 00 	lw r1,(r2+0)
 2bc:	34 02 00 47 	mvi r2,71
 2c0:	f8 00 00 43 	calli 3cc <uart_write_byte>
 2c4:	fb ff ff c3 	calli 1d0 <delay.clone.0>
 2c8:	78 02 00 00 	mvhi r2,0x0
 2cc:	38 42 05 90 	ori r2,r2,0x590
 2d0:	28 41 00 00 	lw r1,(r2+0)
 2d4:	34 02 00 48 	mvi r2,72
 2d8:	f8 00 00 3d 	calli 3cc <uart_write_byte>
 2dc:	fb ff ff bd 	calli 1d0 <delay.clone.0>
 2e0:	78 02 00 00 	mvhi r2,0x0
 2e4:	38 42 05 94 	ori r2,r2,0x594
 2e8:	28 41 00 00 	lw r1,(r2+0)
 2ec:	34 03 00 01 	mvi r3,1
 2f0:	b9 60 10 00 	mv r2,r11
 2f4:	f8 00 00 0d 	calli 328 <gpio_out>
 2f8:	fb ff ff b6 	calli 1d0 <delay.clone.0>
 2fc:	78 02 00 00 	mvhi r2,0x0
 300:	38 42 05 94 	ori r2,r2,0x594
 304:	28 41 00 00 	lw r1,(r2+0)
 308:	34 03 00 00 	mvi r3,0
 30c:	b9 60 10 00 	mv r2,r11
 310:	f8 00 00 06 	calli 328 <gpio_out>
 314:	35 6b 00 01 	addi r11,r11,1
 318:	ed 8b 08 00 	cmpge r1,r12,r11
 31c:	c8 01 08 00 	sub r1,r0,r1
 320:	a1 61 58 00 	and r11,r11,r1
 324:	e3 ff ff ef 	bi 2e0 <main+0xe8>

00000328 <gpio_out>:
 328:	44 60 00 05 	be r3,r0,33c <gpio_out+0x14>
 32c:	34 03 00 01 	mvi r3,1
 330:	bc 62 10 00 	sl r2,r3,r2
 334:	58 22 00 04 	sw (r1+4),r2
 338:	c3 a0 00 00 	ret
 33c:	34 03 00 01 	mvi r3,1
 340:	bc 62 10 00 	sl r2,r3,r2
 344:	58 22 00 00 	sw (r1+0),r2
 348:	c3 a0 00 00 	ret

0000034c <gpio_dir>:
 34c:	44 60 00 06 	be r3,r0,364 <gpio_dir+0x18>
 350:	28 23 00 08 	lw r3,(r1+8)
 354:	34 04 00 01 	mvi r4,1
 358:	bc 82 10 00 	sl r2,r4,r2
 35c:	b8 43 10 00 	or r2,r2,r3
 360:	e0 00 00 06 	bi 378 <gpio_dir+0x2c>
 364:	34 04 00 01 	mvi r4,1
 368:	28 23 00 08 	lw r3,(r1+8)
 36c:	bc 82 10 00 	sl r2,r4,r2
 370:	a4 40 10 00 	not r2,r2
 374:	a0 43 10 00 	and r2,r2,r3
 378:	58 22 00 08 	sw (r1+8),r2
 37c:	c3 a0 00 00 	ret

00000380 <gpio_in>:
 380:	28 21 00 0c 	lw r1,(r1+12)
 384:	34 03 00 01 	mvi r3,1
 388:	bc 62 10 00 	sl r2,r3,r2
 38c:	a0 41 08 00 	and r1,r2,r1
 390:	7c 21 00 00 	cmpnei r1,r1,0
 394:	c3 a0 00 00 	ret

00000398 <read_is_addr>:
 398:	28 21 00 00 	lw r1,(r1+0)
 39c:	c3 a0 00 00 	ret

000003a0 <write_is_addr>:
 3a0:	58 22 00 04 	sw (r1+4),r2
 3a4:	c3 a0 00 00 	ret

000003a8 <read_strd>:
 3a8:	28 21 00 08 	lw r1,(r1+8)
 3ac:	c3 a0 00 00 	ret

000003b0 <write_strd>:
 3b0:	58 22 00 0c 	sw (r1+12),r2
 3b4:	c3 a0 00 00 	ret

000003b8 <read_tr_count>:
 3b8:	28 21 00 10 	lw r1,(r1+16)
 3bc:	c3 a0 00 00 	ret

000003c0 <uart_init>:
 3c0:	34 02 02 5c 	mvi r2,604
 3c4:	58 22 00 04 	sw (r1+4),r2
 3c8:	c3 a0 00 00 	ret

000003cc <uart_write_byte>:
 3cc:	37 9c ff f4 	addi sp,sp,-12
 3d0:	5b 8b 00 0c 	sw (sp+12),r11
 3d4:	5b 8c 00 08 	sw (sp+8),r12
 3d8:	5b 9d 00 04 	sw (sp+4),ra
 3dc:	b8 40 60 00 	mv r12,r2
 3e0:	34 02 00 0a 	mvi r2,10
 3e4:	b8 20 58 00 	mv r11,r1
 3e8:	5d 82 00 03 	bne r12,r2,3f4 <uart_write_byte+0x28>
 3ec:	34 02 00 0d 	mvi r2,13
 3f0:	fb ff ff f7 	calli 3cc <uart_write_byte>
 3f4:	29 61 00 00 	lw r1,(r11+0)
 3f8:	20 21 00 01 	andi r1,r1,0x1
 3fc:	5c 20 ff fe 	bne r1,r0,3f4 <uart_write_byte+0x28>
 400:	59 6c 00 08 	sw (r11+8),r12
 404:	2b 9d 00 04 	lw ra,(sp+4)
 408:	2b 8b 00 0c 	lw r11,(sp+12)
 40c:	2b 8c 00 08 	lw r12,(sp+8)
 410:	37 9c 00 0c 	addi sp,sp,12
 414:	c3 a0 00 00 	ret

00000418 <uart_write_string>:
 418:	37 9c ff f4 	addi sp,sp,-12
 41c:	5b 8b 00 0c 	sw (sp+12),r11
 420:	5b 8c 00 08 	sw (sp+8),r12
 424:	5b 9d 00 04 	sw (sp+4),ra
 428:	b8 20 60 00 	mv r12,r1
 42c:	b8 40 58 00 	mv r11,r2
 430:	e0 00 00 04 	bi 440 <uart_write_string+0x28>
 434:	b9 80 08 00 	mv r1,r12
 438:	35 6b 00 01 	addi r11,r11,1
 43c:	fb ff ff e4 	calli 3cc <uart_write_byte>
 440:	41 62 00 00 	lbu r2,(r11+0)
 444:	5c 40 ff fc 	bne r2,r0,434 <uart_write_string+0x1c>
 448:	2b 9d 00 04 	lw ra,(sp+4)
 44c:	2b 8b 00 0c 	lw r11,(sp+12)
 450:	2b 8c 00 08 	lw r12,(sp+8)
 454:	37 9c 00 0c 	addi sp,sp,12
 458:	c3 a0 00 00 	ret

0000045c <uart_poll>:
 45c:	28 21 00 00 	lw r1,(r1+0)
 460:	20 21 00 02 	andi r1,r1,0x2
 464:	c3 a0 00 00 	ret

00000468 <uart_read_byte>:
 468:	28 23 00 00 	lw r3,(r1+0)
 46c:	b8 20 10 00 	mv r2,r1
 470:	34 01 ff ff 	mvi r1,-1
 474:	20 63 00 02 	andi r3,r3,0x2
 478:	44 60 00 03 	be r3,r0,484 <uart_read_byte+0x1c>
 47c:	28 41 00 0c 	lw r1,(r2+12)
 480:	20 21 00 ff 	andi r1,r1,0xff
 484:	c3 a0 00 00 	ret

00000488 <memset>:
 488:	20 25 00 03 	andi r5,r1,0x3
 48c:	b8 20 20 00 	mv r4,r1
 490:	44 a0 00 0b 	be r5,r0,4bc <memset+0x34>
 494:	44 60 00 2c 	be r3,r0,544 <memset+0xbc>
 498:	34 63 ff ff 	addi r3,r3,-1
 49c:	20 46 00 ff 	andi r6,r2,0xff
 4a0:	e0 00 00 03 	bi 4ac <memset+0x24>
 4a4:	44 60 00 28 	be r3,r0,544 <memset+0xbc>
 4a8:	34 63 ff ff 	addi r3,r3,-1
 4ac:	30 86 00 00 	sb (r4+0),r6
 4b0:	34 84 00 01 	addi r4,r4,1
 4b4:	20 85 00 03 	andi r5,r4,0x3
 4b8:	5c a0 ff fb 	bne r5,r0,4a4 <memset+0x1c>
 4bc:	34 05 00 03 	mvi r5,3
 4c0:	50 a3 00 1a 	bgeu r5,r3,528 <memset+0xa0>
 4c4:	20 45 00 ff 	andi r5,r2,0xff
 4c8:	3c a6 00 08 	sli r6,r5,8
 4cc:	34 0a 00 0f 	mvi r10,15
 4d0:	b8 c5 28 00 	or r5,r6,r5
 4d4:	3c a6 00 10 	sli r6,r5,16
 4d8:	b8 80 40 00 	mv r8,r4
 4dc:	b8 c5 30 00 	or r6,r6,r5
 4e0:	b8 60 38 00 	mv r7,r3
 4e4:	b8 80 28 00 	mv r5,r4
 4e8:	34 09 00 0f 	mvi r9,15
 4ec:	54 6a 00 17 	bgu r3,r10,548 <memset+0xc0>
 4f0:	34 04 00 00 	mvi r4,0
 4f4:	34 07 00 03 	mvi r7,3
 4f8:	b5 04 28 00 	add r5,r8,r4
 4fc:	34 84 00 04 	addi r4,r4,4
 500:	58 a6 00 00 	sw (r5+0),r6
 504:	c8 64 28 00 	sub r5,r3,r4
 508:	54 a7 ff fc 	bgu r5,r7,4f8 <memset+0x70>
 50c:	34 63 ff fc 	addi r3,r3,-4
 510:	00 64 00 02 	srui r4,r3,2
 514:	20 63 00 03 	andi r3,r3,0x3
 518:	34 84 00 01 	addi r4,r4,1
 51c:	3c 84 00 02 	sli r4,r4,2
 520:	b5 04 40 00 	add r8,r8,r4
 524:	b9 00 20 00 	mv r4,r8
 528:	44 60 00 07 	be r3,r0,544 <memset+0xbc>
 52c:	20 42 00 ff 	andi r2,r2,0xff
 530:	34 05 00 00 	mvi r5,0
 534:	b4 85 30 00 	add r6,r4,r5
 538:	30 c2 00 00 	sb (r6+0),r2
 53c:	34 a5 00 01 	addi r5,r5,1
 540:	5c 65 ff fd 	bne r3,r5,534 <memset+0xac>
 544:	c3 a0 00 00 	ret
 548:	58 a6 00 00 	sw (r5+0),r6
 54c:	58 a6 00 04 	sw (r5+4),r6
 550:	58 a6 00 08 	sw (r5+8),r6
 554:	58 a6 00 0c 	sw (r5+12),r6
 558:	34 e7 ff f0 	addi r7,r7,-16
 55c:	34 a5 00 10 	addi r5,r5,16
 560:	54 e9 ff fa 	bgu r7,r9,548 <memset+0xc0>
 564:	34 63 ff f0 	addi r3,r3,-16
 568:	00 68 00 04 	srui r8,r3,4
 56c:	20 63 00 0f 	andi r3,r3,0xf
 570:	35 08 00 01 	addi r8,r8,1
 574:	3d 08 00 04 	sli r8,r8,4
 578:	b4 88 40 00 	add r8,r4,r8
 57c:	34 04 00 03 	mvi r4,3
 580:	54 64 ff dc 	bgu r3,r4,4f0 <memset+0x68>
 584:	b9 00 20 00 	mv r4,r8
 588:	e3 ff ff e8 	bi 528 <memset+0xa0>
