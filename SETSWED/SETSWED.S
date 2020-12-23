start
	subq	#2,sp
	move	#$0606,(sp)
	pea	0(sp)
	move.l	#$00060002,-(sp)
	move.l	#$002e0001,-(sp)
	trap	#14
	lea	12+2(sp),sp
	tst.l	d0
	bne.s	.err
	pea	.super(pc)
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp
	lea	.text(pc),a0
.print
	pea	0(a0)
	move	#$9,-(sp)
	trap	#1
	addq	#6,sp
	clr	-(sp)
	trap	#1
.err
	pea	0(sp)
	move.l	#$00000000,-(sp)
	move.l	#$002e0002,-(sp)
	trap	#14
	lea	12(sp),sp
	lea	.text(pc),a0
	move.b	#$20,.tend-.text(a0)
	bra	.print
	; Errors: -12 : checksum error i nvmram
	;         -5  : parameter error
.super
	move.l	#"_AKP",d0
	jsr	.get_cookie(pc)
	bmi	.skip
	move	#$0606,-(a0)
.skip
	rts

.get_cookie
	move.l	$5a0.w,d1
	beq	.nf
	move.l	d1,a0
.find	movem.l	(a0)+,d1-d2
	tst.l	d1
	beq	.nf
	cmp.l	d0,d1
	bne	.find
	moveq	#1,d0
	rts
.nf
	moveq	#-1,d0
	rts

	bss
.kb	ds	1
	data
.text	dc.b	27,'p'
	dc.b	'     Set_Swed v1.2     ',27,'q',13,10
	dc.b	' Ω 1994 av Copson DATA',13,10
	dc.b	' Svenska installerat!',13,10
.tend	dc.b	0
	dc.b	'Ett fel har uppstÜtt!',13,10
	dc.b	' èterinitierar NV-RAM...',13,10
	dc.b	0
