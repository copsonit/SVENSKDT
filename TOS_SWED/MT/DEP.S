	move.l	4(a7),a3		base page
	move.l	sp,oldstack
	lea	mystack,a7
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			shrink memory
	lea	12(sp),sp

	lea	rscmt,a0
	move.l	a0,LDECD4
	jsr	decomp(pc)
	clr	-(sp)
	trap	#1

decomp
	movem.l	d2/d6-d7/a4-a5,-(a7)
	movea.l	LDECD4,a0
	move.l	2(a0),d7
	move.l	6(a0),d6
	move.l	d7,d0
	addi.l	#$1000,d0
	moveq	#3,d1
	move.w	d1,-(a7)
	move.l	d0,-(a7)
	jsr	L9498A	GEMDOS nr 44...?
	addq.w	#6,a7
	move.l	d0,LDECC2
	bne.s	l8A9A4
	; Unable to install AES Resource!
*	pea	$B1C18
*	bsr.s	$8A92C
*	addq.w	#4,a7
	nop
l8A9A4	movea.l	LDECD4,a0
	adda.w	#$A,a0
	movea.l	a0,a5
	movea.l	LDECC2,a4
	movea.l	LDECD4,a0
	tst.w	(a0)
	bne.s	l8A9CC
	bra.s	l8A9C6
l8A9C2	move.b	(a5)+,(a4)+
	subq.l	#1,d7
l8A9C6	tst.l	d7
	bne.s	l8A9C2
	bra.s	l8AA06
L8a9cc
	movea.l	LDECD4,a0
	cmpi.w	#$AB08,(a0)
	beq.s	l8A9E4
	; inte komprimerat
*	pea	$B1C3A
*	bsr	$8A92C
*	addq.w	#4,a7
l8A9E4	move.l	d7,-(a7)
	move.l	a4,-(a7)
	move.l	d6,-(a7)
	move.l	a5,-(a7)
	bsr	L8AC44
	lea	$10(a7),a7
	tst.w	d0
	bne.s	l8AA06
	; Decompression failure
*	pea	$B1C60
*	bsr	$8A92C
*	addq.w	#4,a7
	bra.s	l8AA4C
l8AA06	movea.l	LDECC2,a0
	move.l	(a0),d0
	move.l	4(a0),d1
	move.l	8(a0),LDED06
	moveq	#$C,d2
	add.l	LDECC2,d2
	move.l	d2,LDECCA
	add.l	d0,d2
	move.l	d2,LDECFA
	add.l	d1,d2
	move.l	d2,LDECFE
	move.w	#1,LDECCE
	move.l	d0,LDECD0
	move.l	d1,LDED02
l8AA4C	movem.l	(a7)+,d2/d6-d7/a4-a5
	rts

l8AB66	link	a6,#-6
	movem.l	d5-d7/a3-a5,-(a7)
	movea.l	$26(a7),a5
	move.l	$2A(a7),d7
	movea.l	$2E(a7),a4
	moveq	#0,d5
	moveq	#3,d0
	move.w	d0,-(a7)
	pea	$400.w
	jsr	L9498A
	addq.w	#6,a7
	moveq	#1,d6
	movea.l	d0,a0
	lea	4(a0),a3
	move.l	d0,$18(a7)
	bra.s	l8ABB2
l8AB9A	move.l	a5,(a3)+
	moveq	#0,d0
	move.b	(a5),d0
	addq.w	#1,d0
	move.w	d0,$1C(a7)
	ext.l	d0
	sub.l	d0,d7
	move.w	$1C(a7),d0
	adda.w	d0,a5
	addq.w	#1,d6
l8ABB2	cmp.w	LDED1A,d6
	blt.s	l8AB9A
	bra.s	l8AC28
l8ABBC	moveq	#0,d6
	move.b	(a5)+,d6
	subq.l	#1,d7
	move.w	LDED18,d0
	cmp.w	d0,d6
	bne.s	l8AC1C
	moveq	#0,d6
	move.b	(a5)+,d6
	subq.l	#1,d7
	tst.w	d6
	bne.s	l8ABE2
	movea.l	d5,a0
	addq.l	#1,d5
	move.l	a0,d1
	move.b	d0,0(a4,d1.l)
	bra.s	l8AC28
l8ABE2	move.l	d6,d0
	ext.l	d0
	asl.l	#2,d0
	movea.l	$18(a7),a0
	movea.l	0(a0,d0.l),a3
	move.l	a3,d0
	bne.s	l8AC02
	pea	$B1C8C
	bsr	L8A92C
	moveq	#0,d0
	bra.s	l8AC3A
l8AC02	moveq	#0,d6
	move.b	(a3)+,d6
	bra.s	l8AC12
l8AC08	movea.l	d5,a0
	addq.l	#1,d5
	move.l	a0,d0
	move.b	(a3)+,0(a4,d0.l)
l8AC12	move.l	d6,d0
	subq.w	#1,d6
	tst.w	d0
	bgt.s	l8AC08
	bra.s	l8AC28
l8AC1C	movea.l	d5,a0
	addq.l	#1,d5
	move.l	d6,d0
	move.l	a0,d1
	move.b	d0,0(a4,d1.l)
l8AC28	tst.l	d7
	bgt.s	l8ABBC
	move.l	$18(a7),d0
	move.l	d0,-(a7)
	jsr	L94A16
	move.l	d5,d0
l8AC3A	movem.l	-$1E(a6),d5-d7/a3-a5
	unlk	a6
	rts
L8AC44	link	a6,#-$10
	movem.l	d2-d7/a4-a5,-(a7)
	move.l	$C(a6),d7
	movea.l	$10(a6),a5
	move.l	$14(a6),d6
	move.l	d6,d0
	addi.l	#$1000,d0
	moveq	#3,d1
	move.w	d1,-(a7)
	move.l	d0,-(a7)
	jsr	L9498A
	addq.w	#6,a7
	movea.l	d0,a4
	move.l	a4,d0
	bne.s	l8AC84
	pea	$B1CA6
	bsr	L8A92C
	moveq	#0,d0
	bra	l8ADEE
l8AC84	moveq	#0,d0
	movea.l	8(a6),a0
	move.b	(a0),d0
	moveq	#0,d1
	move.b	1(a0),d1
	moveq	#0,d2
	move.b	2(a0),d2
	move.w	d0,LDED0A
	moveq	#0,d0
	move.b	3(a0),d0
	move.w	d0,LDED10
	moveq	#0,d0
	move.b	4(a0),d0
	move.w	d0,LDED12
	moveq	#0,d0
	move.b	5(a0),d0
	move.w	d0,LDED14
	moveq	#0,d0
	move.b	6(a0),d0
	move.w	d0,LDED16
	moveq	#0,d0
	move.b	7(a0),d0
	move.w	d0,LDED18
	moveq	#0,d0
	move.b	8(a0),d0
	addq.w	#1,d0
	lea	9(a0),a1
	move.w	d0,LDED1A
	move.l	d7,d0
	move.w	d1,LDED0C
	moveq	#9,d1
	sub.l	d1,d0
	move.l	a4,-(a7)
	move.l	d0,-(a7)
	move.l	a1,-(a7)
	move.w	d2,LDED0E
	bsr	l8AB66
	lea	$C(a7),a7
	move.l	d0,d7
	moveq	#0,d3
	clr.l	-$10(a6)
	bra	l8ADDC
l8AD18	movea.l	d3,a0
	addq.l	#1,d3
	moveq	#0,d5
	move.l	a0,d0
	move.b	0(a4,d0.l),d5
	moveq	#0,d4
	cmp.w	LDED12,d5
	bne.s	l8AD42
	movea.l	a4,a0
	adda.l	d3,a0
	moveq	#0,d5
	move.b	(a0),d5
	addq.l	#2,d3
	moveq	#0,d4
	move.b	1(a0),d4
	bra	l8ADC2
l8AD42	cmp.w	LDED0A,d5
	bne.s	l8AD50
	moveq	#0,d5
	moveq	#1,d4
	bra.s	l8ADC2
l8AD50	cmp.w	LDED0C,d5
	bne.s	l8AD60
	move.w	#$FF,d5
	moveq	#1,d4
	bra.s	l8ADC2
l8AD60	cmp.w	LDED0E,d5
	bne.s	l8AD78
	moveq	#0,d5
	movea.l	d3,a0
	addq.l	#1,d3
	moveq	#0,d4
	move.l	a0,d0
	move.b	0(a4,d0.l),d4
	bra.s	l8ADC2
l8AD78	cmp.w	LDED10,d5
	bne.s	l8AD92
	move.w	#$FF,d5
	movea.l	d3,a0
	addq.l	#1,d3
	moveq	#0,d4
	move.l	a0,d0
	move.b	0(a4,d0.l),d4
	bra.s	l8ADC2
l8AD92	cmp.w	LDED14,d5
	bne.s	l8ADA0
	moveq	#0,d5
	moveq	#3,d4
	bra.s	l8ADC2
l8ADA0	cmp.w	LDED16,d5
	bne.s	l8ADC2
	move.w	#$FF,d5
	moveq	#3,d4
	bra.s	l8ADC2
l8ADB0	movea.l	-$10(a6),a0
	addq.l	#1,-$10(a6)
	move.l	d5,d0
	move.l	a0,d1
	move.b	d0,0(a5,d1.l)
	subq.w	#1,d4
l8ADC2	tst.w	d4
	bpl.s	l8ADB0
	move.l	-$10(a6),d0
	cmp.l	d6,d0
	ble.s	l8ADDC
	pea	$B1CB6
	bsr	L8A92C
	moveq	#0,d0
	bra.s	l8ADEE
l8ADDC	cmp.l	d7,d3
	blt	l8AD18
	move.l	a4,d0
	move.l	d0,-(a7)
	jsr	L94A16
	moveq	#1,d0
l8ADEE	movem.l	-$30(a6),d2-d7/a4-a5
	unlk	a6
	rts

l8A92C	link	a6,#0
	move.l	8(a6),-(a7)
	moveq	#9,d0
	move.w	d0,-(a7)
	jsr	L9BE86
	pea	$B1BFC
	moveq	#9,d0
	move.w	d0,-(a7)
	jsr	L9BE86
	lea	$C(a7),a7
l8A952	moveq	#2,d0
	move.w	d0,-(a7)
	moveq	#1,d1
	move.w	d1,-(a7)
	jsr	L9BEAC
	addq.w	#4,a7
	tst.l	d0
	beq.s	l8A952
	unlk	a6
	rts

L9498A	link	a6,#0
	move.l	d7,-(a7)
	move.w	$C(a6),d7
	tst.w	LE0516
	bne.s	l949A0
	andi.w	#3,d7
l949A0	move.w	d7,-(a7)
	move.l	8(a6),-(a7)
	moveq	#$48,d0		; F.d. #$44...
	move.w	d0,-(a7)
	jsr	L9BE86
	move.l	-4(a6),d7
	unlk	a6
	rts

L94A16	link	a6,#0
	move.l	8(a6),-(a7)
	moveq	#$49,d0
	move.w	d0,-(a7)
	jsr	L9BE86
	unlk	a6
	rts

L9BE86	movem.l	d2/a2,-(a7)
	clr.w	LDFA20
	movem.l	$C(a7),d0-d2/a0-a2
	movem.l	d0-d2/a0-a2,-(a7)
	trap	#1
	adda.w	#$18,a7
	move.w	d0,LDFA20
	movem.l	(a7)+,d2/a2
	rts
L9BEAC	movem.l	d2/a2,-(a7)
	movem.l	$C(a7),d0-d2/a0-a2
	movem.l	d0-d2/a0-a2,-(a7)
	trap	#13
	adda.w	#$18,a7
	movem.l	(a7)+,d2/a2
	rts
LDECC2	ds.l	1
LDECCA	ds.l	1
LDECCE	ds	1
LDECD0	ds.l	1
LDECD4	ds.l	1	Adress till RSC-fil
LDECFA	ds.l	1
LDECFE	ds.l	1
LDED02	ds.l	1
LDED06	ds.l	1
LDED0A	ds	1
LDED0C	ds	1
LDED0E	ds	1
LDED10	ds	1
LDED12	ds	1
LDED14	ds	1
LDED16	ds	1
LDED18	ds	1
LDED1A	ds	1
LDFA20	ds	1
LE0516	ds	1
oldstack	ds.l	1
	ds	400
mystack
rscmt	incbin	f:\rscmt.bin