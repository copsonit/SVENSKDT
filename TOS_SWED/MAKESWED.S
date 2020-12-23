	; Utility som s„tter ihop 2 RSC-filer + INF-fil till spr†kblock f”r TOS

START
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

	pea	fil1(pc)
	jsr	LADDA_FIL(pc)
	addq	#4,sp
	bmi	.felladd
	move.l	d0,len1
	move.l	a0,fil1pnt
	pea	fil2(pc)
	jsr	LADDA_FIL(pc)
	addq	#4,sp
	bmi	.felladd
	move.l	d0,len2
	move.l	a0,fil2pnt
	pea	fil3(pc)
	jsr	LADDA_FIL(pc)
	addq	#4,sp
	bmi	.felladd
	move.l	d0,len3
	move.l	a0,fil3pnt
		

	move.l	len1(pc),d0
	add.l	len2(pc),d0
	add.l	len3(pc),d0
	add.l	#10,d0
	move.l	d0,d7
	move.l	d0,-(sp)
	move	#$48,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	bmi	.felladd
	move.l	d0,a5
	move.l	d0,a6
	move	d7,4(a6)
	moveq	#10,d0
	add.l	len1(pc),d0
	move	d0,(a6)
	add.l	len2(pc),d0
	move	d0,2(a6)
	clr.l	6(a6)
	lea	10(a6),a6
	move.l	fil1pnt(pc),a0
	move.l	len1(pc),d0
	jsr	flytta(pc)
	move.l	fil2pnt(pc),a0
	move.l	len2(pc),d0
	jsr	flytta(pc)
	move.l	fil3pnt(pc),a0
	move.l	len3(pc),d0
	jsr	flytta(pc)

	clr	-(sp)
	pea	output(pc)
	move	#$3c,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0
	bmi	.felladd
	move	d0,d7
	pea	0(a5)
	moveq	#0,d0
	move	4(a5),d0
	move.l	d0,d5
	move.l	d0,-(sp)
	move	d7,-(sp)
	move	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	.felladd
	sub.l	d5,d0
	bmi	.felladd
	move	d7,-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp
	tst.l	d0
	bmi	.felladd

.felladd
	clr	-(sp)
	trap	#1
flytta
	subq	#1,d0
.nxt
	move.b	(a0)+,(a6)+
	dbf	d0,.nxt
	rts

LADDA_FIL
	clr	-(sp)
	move.l	6(sp),-(sp)
	move	#$4e,-(sp)		Fsfirst
	trap	#1
	addq	#8,sp
	tst.l	d0
	bmi	.error

	move	#$2f,-(sp)		FGetdta
	trap	#1
	addq	#2,sp
	
	move.l	d0,a0
	move.l	26(a0),a6
	move.l	a6,d0

	move.l	d0,-(sp)
	move	#$48,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	beq	.error
	move.l	d0,a5

	clr	-(sp)
	move.l	6(sp),-(sp)
	move	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0
	bmi	.error
	move	d0,d7

	move.l	a5,-(sp)	Destination address
	move.l	a6,-(sp)	Filelen
	move	d7,-(sp)	Handle
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	.error
	sub.l	a6,d0
	bmi	.error

	move	d7,-(sp)
	move	#$3e,-(sp)	Fclose
	trap	#1
	addq	#4,sp
	tst.l	d0
	bmi	.error
	
	move.l	a5,a0
	move.l	a6,d0
.error
	rts
	


	bss
oldstack	ds.l	1
len1	ds.l	1
fil1pnt	ds.l	1
len2	ds.l	1
fil2pnt	ds.l	1
len3	ds.l	1
fil3pnt	ds.l	1
	ds.l	400
mystack	
	data
fil1	dc.b	'404SWE_1.RSC',0
fil2	dc.b	'404SWE_2.RSC',0
fil3	dc.b	'404SWE.INF',0
output	dc.b	'404SWE.BIN',0
	end