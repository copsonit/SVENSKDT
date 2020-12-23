	;            F�rsta angrepp: G�r kopia av hela TOS till RAM som sen kan patchas.
	;17.00-19.00 F�rberedande disassemblering av ROM-rutinerna som laddar RSC-filen
	;	D� det uppt�cktes att RSC-filen �nd� alltid ligger i RAM-minne:
	;	Andra angrepp: L�gg egen trap #1 som ers�tter initiering av RSC-fil
	;	till valfri RSC-fil oberoende av valt spr�k i cookie.
	;23.00-	Fungerande version 1.0 som l�gger in fransk RSC-fil i RAM.
	; -01.11-	Kom p� att vi redan har RSC-filen i minnet ju! Beh�ver inte
	;	flytta den till ett annat minne... (kan ev bli problem med en
	;	framtida Mfree av minnet som reserverades f�r ram-kopian av rsc-filen.
	;	med eftersom TOS 4.04 inte kan mfree:a rsc-filen s� ska det nog
	;	funka �nd�... P� $e27482 g�rs visserligen en mfree p� inneh�llet i a386... hmm...
	;	verkar �nd� funka hittils...)
	; -03.00-	Efter att jag satt mig in hur spr�kareorna var konstruerade, var det mycket
	;	enkelt att splitta upp det i tv� RSC-filer och en INF-fil. Gjorde detsamma
	;	p� TOS 3.06 s� jag hade en svensk �vers�ttning att utg� fr�n och b�rjade
	;	sedan editera filerna med hj�lp av Interface.
	; -05.00	�versatt alla dialogrutor, str�ngar och h�lften av alertrutorna.

	;11.00-	Fortsatt p� �vers�ttningen
	;-12.15-	�vers�ttning av RSC-fil 2 klar.
	;-12.48-	Klar med program som sparar i BIN-formatet
	;-12.58-	TOS 4.04 svenskt k�rs f�r f�rsta g�ngen
	;-13.28-	Sm�rre justeringar av meny och dialogboxar
	;-14.00	

	; 16.00-	Anpassat programmet f�r att kunna k�ras p� olika TOS-versioner.
	;	OBS! Det �r inte 100% s�kert att RSC-filerna passar alla versioner
	;	samtidigt. M�ste kolla att det funkar 100% i f�rg ocks�.
	; -17.30

	; 0.15-	Bugg i interface flyttade om menyval om de var l�nkade fel!
	;	Installeras bara en g�ng. Installeras inte under MT.	
	; -1.26

	; 11.00-	Anv�nder XBRA och beh�ver inte l�ngre ligga sist (om de
	;	efterf�ljande programmen f�ljer XBRA vill s�ga!)
	; -12.43	PC-relativt, f�rberett f�r cartridgeassemblering

	; Att g�ra:	 Kolla om programmet redan �r installerat.
	;	 Installera inte d� MultiTOS k�rs
	;	  Anpassning till fler TOS Beh�ver fler TOS.IMG!!!
	;	 Ska utnyttja XBRA f�r att inte beh�va ligga sist...
	;	 G�r en universal version som kan l�ggas p� cart!


*CART

	IFD	CART
*	org	$FA0000
ROMSTART
	dc.l	$ABCDEF42
	dc.l	0		; Pekare till n�sta program
	dc.l	$8000000+MAIN	; Intierings sekvens f�re Disk-Boot
	dc.l	ROMONSTART		; Start p� programmet ROMON.PRG
time1	equ	RAMSTART+*-ROMSTART
	dc	$7885
date1	equ	RAMSTART+*-ROMSTART
	dc	$1762
	dc.l	ROMONSLUT-ROMONSTART
	dc.b	"ROMP�.PRG",$0
	even

	ELSEIF
	output	c:\auto\svenska.prg
	ENDC
ownid	equ	"CDST"	Copson DATA Svenskt TOS

MAIN
*	IFND	CART
	move.l	4(a7),a3		base page
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
	bmi	.quit
*	ENDC
	pea	bsslen
	move	#$48,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	beq	.quit
	move.l	d0,a6
	pea	super(pc)
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp
	tst.b	norom(a6)
	beq	.nxttst2
	pea	norommess(pc)
	bra	.errprint
.nxttst2
	tst.b	installerad(a6)
	beq	.nxttst
	pea	instmess(pc)
	bra	.errprint
.nxttst
	tst.b	stflg(a6)
	beq	.allok
	pea	nof030(pc)
.errprint
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
	bra	.quit
.allok
	pea	message(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	pea	tosver(a6)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

*	IFND	CART
	move.l	4(sp),a0
	move.l	12(a0),a1
	add.l	20(a0),a1
	add.l	28(a0),a1
	lea	$100(a1),a1
	clr	-(sp)
	pea	(a1)
	move	#49,-(sp)
	trap	#1
.quit
	clr	-(sp)
	trap	#1
*	ELSEIF
*.quit
*	rts
*	ENDC

get_cookie
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
	
super
	move.l	$5a0.w,d0
	seq	stflg(a6)
	beq	.exit
	move.l	#"_MCH",d0
	jsr	get_cookie(pc)
	cmp.l	#$00030000,d2	;F030?
	sne	stflg(a6)
	bne	.exit
	move.l	#"MiNT",d0
	jsr	get_cookie(pc)
	spl	norom(a6)
	bpl	.exit
	move.l	$4f2.w,a0		_sysbase
	lea	tosdata(pc),a1
.letanext
	move	tosversion(a1),d0
	smi	stflg(a6)
	bmi	.exit
	cmp	2(a0),d0		J�mf�r med TOS-version
	beq	.found
	lea	maglen(a1),a1
	bra	.letanext
.found
	move.l	magic6(a1),a0
	tst.l	(a0)		Redan installerad?
	sne	installerad(a6)
	bne	.exit
	move.l	a6,d1		L�gg in basadress i cookie
	move.l	#ownid,d0
	jsr	insert_cookie(pc)
	slt	stflg(a6)
	blt	.exit
	
	IFD	CART
	lea	o_trap1(a6),a0
	ELSEIF
	lea	o_trap1(pc),a0
	ENDC
	move.l	$84.w,(a0)
	lea	my_trap1(pc),a0
	move.l	a0,$84.w
	move.l	a1,magbase(a6)
	moveq	#3,d0
	lea	magverstr(a1),a0
	lea	tosver(a6),a2
.movestr
	move.b	(a0)+,(a2)+
	dbf	d0,.movestr
	move.b	#$0d,(a2)+
	move.b	#$0a,(a2)+
	clr.b	(a2)+
.exit
	rts

;eigenen Cookie in das Cookie jar
;Parameter:  D0.l : Name des Cookies
;            D1.l : Wert des Cookies
;            D0.w : 0 - alles ok, Cookie wurde eingetragen
;                    1 - wie (1), aber nun resetfest, d.h. resident bleiben
;                    2 - wie (2), aber nicht resetfest eingeklinkt
;                   <0 - Fehler aufgetreten, Cookie nicht eingetragen

insert_cookie
	movem.l	D2-D5/A1,-(SP)
	move.l	$5a0.w,A1	;Zeiger auf das Cookie Jar holen
	moveq	#0,D4	;Anzahl der Slots
.ich	addq	#1,D4	;Slotanzahl erh�hen
	movem.l	(A1)+,D2-D3	;Namen und Wert eines Cookies holen
	tst.l	D2	;leeren Cookie gefunden?
	bne.s	.ich	;Nein => weiter suchen
	cmp.l	D3,D4	;alle Slots belegt?
	beq.s	.icn	;Ja! => neue Liste anlegen
	movem.l	D0-D4,-8(A1)	;neuen Cookie & Listenende einf�gen
	moveq	#0,D0	;alles ok!
	bra.s	.exit	;und raus

.icn
	move.l	$5a0.w,a1
.icn2
	movem.l	(a1)+,d2-d3
	tst.l	d2
	bne	.icn2
	move.l	d3,d5
	addq	#8,d5	; �ka p� med 8 till ny cookie-jar
	move.l	d5,d2
	add.l	d2,d2
	add.l	d2,d2
	add.l	d2,d2
	add.l	d2,d2	; *8
	movem.l	d0/d1/d4/d5,-(sp)
	move.l	d2,-(sp)
	move	#$48,-(sp)
	trap	#1
	addq	#6,sp
	movem.l	(sp)+,d0/d1/d4/d5
	tst.l	d0
	bne	.mallocok
	moveq	#-1,d0
	bra	.exit
.mallocok
	move.l	d0,a0	; Ny plats f�r cookie

	cmp.l	D5,D4	;reicht der Platz?
	ble.s	.exit	;Nein => Fehler und raus
	movea.l	$5a0.w,A1	;Anfang der Liste erneut holen
	move.l	A0,$5a0.w	;neuen Cookie Jar eintragen
	subq	#2,D4	;Ende nicht kopieren (-1 f�r DBRA)
.icm
	move.l	(A1)+,(A0)+	;Eintr�ge der Liste kopieren
	move.l	(A1)+,(A0)+
	dbra	D4,.icm
	move.l	D5,D3	;Anzahl der Slots
	movem.l	D0-D3,(A0)	;eigenes Element eintragen + Listenende
	moveq	#2,D0	;alles ok, resident bleiben
.exit
	movem.l	(SP)+,D2-D5/A1
	rts



	;Own TRAP #1 BIOS

reglist	reg	d0-d7/a0-a6

	IFND	CART
	dc.l	"XBRA"
	dc.l	ownid
o_trap1	ds.l	1
	ENDC
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
	move.l	#ownid,d0
	jsr	get_cookie(pc)
	ble	.not_mine
	move.l	d2,a5
	move.l	magbase(a5),a5
	move.l	magic1(a5),d0
	cmp.l	-6(a6),d0	V�r rutin?
	bne	.not
	move.l	magic2(a5),d0
	cmp.l	6(a6),d0
	bne	.not
	moveq	#0,d0
	move	ownrsc+4(pc),d0
	move.l	d0,2(a6)		Modifiera minne som ska mallokeras till
				;aktuellt minne fr�n egen rsc-fil
	lea	owncont(pc),a0
	move.l	a0,6(a6)	L�nka in mig i returnadress efter malloc...
	move.l	$84.w,a0
	cmp.l	#ownid,-8(a0)	Vi ligger sist!
	beq	.bruten
	lea	my_trap1(pc),a1
.xbraigen
	cmp.l	#"XBRA",-12(a0)
	bne.s	.not		L�t ligga kvar om det ligger icke-XBRA-kompatibla program efter...
	move.l	-4(a0),d0
	cmp.l	a1,d0		My_trap?
	beq.s	.hittad
	move.l	d0,a0
	bra	.xbraigen
.hittad
	IFD	CART
	move.l	o_trap1(a5),-4(a0)
	ELSEIF
	move.l	o_trap1(pc),-4(a0)
	ENDC
	bra	.not
.bruten
	IFD	CART
	move.l	o_trap1(a5),$84.w	St�ng av mig nu...
	ELSEIF
	move.l	o_trap1(pc),$84.w	St�ng av mig nu...
	ENDC
.not
	movem.l	(sp)+,reglist
	move.l	(sp)+,a6
	IFD	CART
	move.l	o_trap1(a5),-(sp)	forts�tt med trap #1 l�nken
	ELSEIF
	move.l	o_trap1(pc),-(sp)	forts�tt med trap #1 l�nken
	ENDC
	rts
.not_mine	
	movem.l	(sp)+,reglist
	move.l	(sp)+,a6
	IFD	CART
	move.l	o_trap1(a5),-(sp)	forts�tt med trap #1 l�nken
	ELSEIF
	move.l	o_trap1(pc),-(sp)	forts�tt med trap #1 l�nken
	ENDC
	rts
owncont
	move.l	d0,-(sp)
	move.l	#ownid,d0
	jsr	get_cookie(pc)	OBS! F�ruts�tter att den finns!
	move.l	d2,a5
	move.l	magbase(a5),a5	
	move.l	(sp)+,d0
*	tst.l	d0
	bne	.x
	move.l	magic3(a5),a0
	jmp	(a0)
.x
*	move.l	d0,-(sp)		Sl�pp genast reservat minne (!)
*	move	#$49,-(sp)
*	trap	#1
*	addq	#6,sp
	
	lea	ownrsc(pc),a0
	move.l	d0,a1
	move	4(a0),d1
	subq	#1,d1
.nxtbyte
	move.b	(a0)+,(a1)+
	dbf	d1,.nxtbyte
*	move.l	#ownrsc,d0		H�r ligger ju redan v�r RSC-fil :-)
	move.l	magic5(a5),a0
	move.l	d0,(a0)		Patcha in v�r egen RSC-fil
	move.l	magic6(a5),a0
	move.l	d0,(a0)		H�r ligger RSC-filen i RAM

	move.l	magic4(a5),a0
	jmp	(a0)

	rsreset
tosversion	rs	1
magic1	rs.l	1
magic2	rs.l	1
magic3	rs.l	1
magic4	rs.l	1
magic5	rs.l	1
magic6	rs.l	1
magverstr	rs.b	4
maglen	rs.b	0


	DATA

TOSDATA
	dc	$400	TOS 4.00	OBS! KOLLAS! (EJ TESTAT...)
	dc.l	$e31d86
	dc.l	$e25a0a
	dc.l	$e25a14
	dc.l	$e25a72
	dc.l	$9120
	dc.l	$a4f9
	dc.b	"4.00"
	dc	$401	TOS 4.01	OBS! KOLLAS! (REN CHANS...)
	dc.l	$e31d86
	dc.l	$e25a0a
	dc.l	$e25a14
	dc.l	$e25a72
	dc.l	$9120
	dc.l	$a4f9
	dc.b	"4.01"
	dc	$402	TOS 4.02	OBS! KOLLAS! (REN CHANS...)
	dc.l	$e34a26
	dc.l	$e27624
	dc.l	$e2762e
	dc.l	$e2768c
	dc.l	$9120
	dc.l	$a386
	dc.b	"4.02"
	dc	$404	TOS 4.04	OK!
	dc.l	$e34a26
	dc.l	$e27624
	dc.l	$e2762e
	dc.l	$e2768c
	dc.l	$9120
	dc.l	$a386
	dc.b	"4.04"
	dc	-1		End mark

message	dc.b	$0d,$0a
	dc.b	27,"p"
	dc.b	"        Svensk Desktop v0.91�        ",27,"q",$0d,$0a
	dc.b	"� 1994 Conny Pettersson, Copson DATA",$0d,$0a
	dc.b	"Distribut�r: AdAstra Electronics AB",$0d,$0a
	dc.b	$0d,$0a
	dc.b	"Installerad i TOS ",0
instmess	dc.b	$0d,$0a,$07
	dc.b	"Svensk Desktop �r redan",$0d,$0a
	dc.b	"installerad!",$0d,$0a
	dc.b	0
norommess	dc.b	$0d,$0a,$07
	dc.b	"Svensk Desktop fungerar INTE",$0d,$0a
	dc.b	"p� MultiTOS!",$0d,$0a
	dc.b	$0
nof030	dc.b	$0d,$0a,$07
	dc.b	"Svensk Desktop fungerar BARA p�",$0d,$0a
	dc.b	"Falcon 030!",$0d,$0a
	dc.b	0
	even
ownrsc	incbin	404swe.bin

	rsreset
magbase	rs.l	1
	IFD	CART
o_trap1	rs.l	1
	ENDC
stflg	rs.b	1
installerad	rs.b	1
norom	rs.b	1
tosver	rs.b	4+2+1
bsslen	rs.b	1
	end