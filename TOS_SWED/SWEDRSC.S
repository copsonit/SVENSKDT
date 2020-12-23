	;            F”rsta angrepp: G”r kopia av hela TOS till RAM som sen kan patchas.
	;17.00-19.00 F”rberedande disassemblering av ROM-rutinerna som laddar RSC-filen
	;	D† det uppt„cktes att RSC-filen „nd† alltid ligger i RAM-minne:
	;	Andra angrepp: L„gg egen trap #1 som ers„tter initiering av RSC-fil
	;	till valfri RSC-fil oberoende av valt spr†k i cookie.
	;23.00-	Fungerande version 1.0 som l„gger in fransk RSC-fil i RAM.
	; -01.11-	Kom p† att vi redan har RSC-filen i minnet ju! Beh”ver inte
	;	flytta den till ett annat minne... (kan ev bli problem med en
	;	framtida Mfree av minnet som reserverades f”r ram-kopian av rsc-filen.
	;	med eftersom TOS 4.04 inte kan mfree:a rsc-filen s† ska det nog
	;	funka „nd†... P† $e27482 g”rs visserligen en mfree p† inneh†llet i a386... hmm...
	;	verkar „nd† funka hittils...)
	; -03.00-	Efter att jag satt mig in hur spr†kareorna var konstruerade, var det mycket
	;	enkelt att splitta upp det i tv† RSC-filer och en INF-fil. Gjorde detsamma
	;	p† TOS 3.06 s† jag hade en svensk ”vers„ttning att utg† fr†n och b”rjade
	;	sedan editera filerna med hj„lp av Interface.
	; -05.00	™versatt alla dialogrutor, str„ngar och h„lften av alertrutorna.

	;11.00-	Fortsatt p† ”vers„ttningen
	;-12.15-	™vers„ttning av RSC-fil 2 klar.
	;-12.48-	Klar med program som sparar i BIN-formatet
	;-12.58-	TOS 4.04 svenskt k”rs f”r f”rsta g†ngen
	;-13.28-	Sm„rre justeringar av meny och dialogboxar
	;-14.00	
	
	output	c:\auto\svenska.prg
ownid	equ	"CDSW"




MAIN
	pea	super(pc)
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp
	tst.b	stflg
	bne	.quitst
	pea	message(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	4(sp),a0
	move.l	12(a0),a1
	add.l	20(a0),a1
	add.l	28(a0),a1
	lea	$100(a1),a1
	add.l	#$1000,a1
	clr	-(sp)
	pea	(a1)
	move	#49,-(sp)
	trap	#1
.quitst
	pea	nof030(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
.quit
	clr	-(sp)
	trap	#1

super
	move.l	$5a0.w,d0
	seq	stflg
	beq	.exit
	move.l	d0,a0
.loop	movem.l	(a0)+,d0-d1
	tst.l	d0
	beq	.exit
	cmp.l	#"_MCH",d0
	bne	.loop
	cmp.l	#$00030000,d1	;F030?
	sne	stflg
	bne	.exit
	move.l	$4f2.w,a0		_sysbase
	cmp	#$0404,2(a0)		Vi funkar just nu bara f”r TOS 4.04
	sne	stflg
	bne	.exit
	move.l	$84.w,o_trap1
	move.l	#my_trap1,$84.w
.exit
	rts

	data

magic1	dc.l	$e34a26
magic2	dc.l	$e27624
magic3	dc.l	$e2762e
magic4	dc.l	$e2768c
magic5	dc.l	$9120
magic6	dc.l	$a386



message	dc.b	$0d,$0a
	dc.b	"Svensk Desktop v1.1 installerat"
	dc.b	$0d,$0a
	dc.b	"™versatt av Copson DATA f”r AdAstra AB"
	dc.b	$0d,$0a,$00
nof030	dc.b	$0d,$0a
	dc.b	"Svenskt Desktop fungerar bara p†"
	dc.b	"en Falcon 030 med TOS 4.04"
	dc.b	$0d,$0a,$00
	bss
stflg	ds.b	1
	text


	;Own TRAP #1 BIOS

reglist	reg	d0-d7/a0-a6

	dc.l	"XBRA"
	dc.l	ownid
o_trap1	ds.l	1
my_trap1	move.l	sp,a0
	move.l	a6,-(sp)	Save a6
	move.l	a0,a6
	addq	#6,a6	skip SR and PC
	tst	$59e.w	test _longframe, other than MC68000?
	beq.s	.mc68000	no...
	addq	#2,a6	skip the extra word
.mc68000
	move	(a0),d0	get SR
	and	#$2000,d0	super?
	bne.s	.super	yes...
	move.l	usp,a6	use user stack
.super	movem.l	reglist,-(sp)
	cmp	#$48,(a6)	Malloc?
	bne	.not_mine	no...
	move.l	magic1(pc),d0
	cmp.l	-6(a6),d0	V†r rutin?
	bne	.not
	move.l	magic2(pc),d0
	cmp.l	6(a6),d0
	bne	.not
	moveq	#0,d0
	move	ownrsc+4,d0
	move.l	d0,4(a6)		Modifiera minne som ska mallokeras till
				;aktuellt minne fr†n egen rsc-fil
	move.l	#owncont,6(a6)	L„nka in mig i returnadress efter malloc...
	move.l	o_trap1,$84.w	St„ng av mig nu...
.not
	movem.l	(sp)+,reglist
	move.l	(sp)+,a6
	move.l	o_trap1,-(sp)	forts„tt med trap #1 l„nken
	rts
.not_mine	
	movem.l	(sp)+,reglist
	move.l	(sp)+,a6
	move.l	o_trap1,-(sp)	do old trap...
	rts
owncont
	bne	.x
	move.l	magic3(pc),a0
	jmp	(a0)
.x
	move.l	d0,-(sp)		Sl„pp genast reservat minne (!)
	move	#$49,-(sp)
	trap	#1
	addq	#6,sp
	move.l	#ownrsc,d0		H„r ligger ju redan v†r RSC-fil :-)
	move.l	magic5(pc),a0
	move.l	d0,(a0)		Patcha in v†r egen RSC-fil
	move.l	magic6(pc),a0
	move.l	d0,(a0)		H„r ligger RSC-filen i RAM
	move.l	magic4(pc),a0
	jmp	(a0)
	data
ownrsc	incbin	f:\tmp\tos_swed\404swe.bin
	end