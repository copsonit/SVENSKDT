	;            Fîrsta angrepp: Gîr kopia av hela TOS till RAM som sen kan patchas.
	;17.00-19.00 Fîrberedande disassemblering av ROM-rutinerna som laddar RSC-filen
	;	DÜ det upptÑcktes att RSC-filen ÑndÜ alltid ligger i RAM-minne:
	;	Andra angrepp: LÑgg egen trap #1 som ersÑtter initiering av RSC-fil
	;	till valfri RSC-fil oberoende av valt sprÜk i cookie.
	;23.00-	Fungerande version 1.0 som lÑgger in fransk RSC-fil i RAM.
	; -01.11-	Kom pÜ att vi redan har RSC-filen i minnet ju! Behîver inte
	;	flytta den till ett annat minne... (kan ev bli problem med en
	;	framtida Mfree av minnet som reserverades fîr ram-kopian av rsc-filen.
	;	med eftersom TOS 4.04 inte kan mfree:a rsc-filen sÜ ska det nog
	;	funka ÑndÜ... PÜ $e27482 gîrs visserligen en mfree pÜ innehÜllet i a386... hmm...
	;	verkar ÑndÜ funka hittils...)
	; -03.00-	Efter att jag satt mig in hur sprÜkareorna var konstruerade, var det mycket
	;	enkelt att splitta upp det i tvÜ RSC-filer och en INF-fil. Gjorde detsamma
	;	pÜ TOS 3.06 sÜ jag hade en svensk îversÑttning att utgÜ frÜn och bîrjade
	;	sedan editera filerna med hjÑlp av Interface.
	; -05.00	ôversatt alla dialogrutor, strÑngar och hÑlften av alertrutorna.

	;11.00-	Fortsatt pÜ îversÑttningen
	;-12.15-	ôversÑttning av RSC-fil 2 klar.
	;-12.48-	Klar med program som sparar i BIN-formatet
	;-12.58-	TOS 4.04 svenskt kîrs fîr fîrsta gÜngen
	;-13.28-	SmÑrre justeringar av meny och dialogboxar
	;-14.00	

	; 16.00-	Anpassat programmet fîr att kunna kîras pÜ olika TOS-versioner.
	;	OBS! Det Ñr inte 100% sÑkert att RSC-filerna passar alla versioner
	;	samtidigt. MÜste kolla att det funkar 100% i fÑrg ocksÜ.
	; -17.30

	; 0.15-	Bugg i interface flyttade om menyval om de var lÑnkade fel!
	;	Installeras bara en gÜng. Installeras inte under MT.	
	; -1.26

	; 11.00-	AnvÑnder XBRA och behîver inte lÑngre ligga sist (om de
	;	efterfîljande programmen fîljer XBRA vill sÑga!)
	; -12.43	PC-relativt, fîrberett fîr cartridgeassemblering
	; 940130:    Anpassning till TOS 4.02

	; Att gîra:	 Kolla om programmet redan Ñr installerat.
	;	 Installera inte dÜ MultiTOS kîrs
	;	 Anpassning till fler TOS Behîver fler TOS.IMG!!!
	;	 Ska utnyttja XBRA fîr att inte behîva ligga sist...
	;	 Gîr en universal version som kan lÑggas pÜ cart!
	;	 Kolla om det inte gÜr att lÑnka in smartare, innan AKP
	;	  och sedan i tabellen lÑggs adress in fîr AKP nr 6...
	;	 Gîr sedan en egen NVRAM-configger med alla nya sprÜk i
	;	 Gîr sÜ det funkar med GEMRAM, ROMRAM, VRAM och ROMSPEED.
	;	 Om dylika program anvÑnds patchas adress till rsc-tabell 
	;	  direkt in i koden pÜ offset magic9.
	;	 3D-knappar ska Ñndras frÜn ob_flags till extended object
	;	  fîr TOS 4.00/4.01
	;	 Ska Ñven funka med WINX!
	;	  Kolla upp med Martin Osieka om omskrivning till TKR Ñr mîjlig...?
		


*CART

	IFD	CART
*	org	$FA0000
	ELSEIF
	output	c:\auto\svenska.prg
	ENDC
ownid	equ	"CDSW"	Copson DATA Swedish TOS

	include	objects.s
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
	move.l	d0,a0
	move	#bsslen-1,d0
.nxt
	clr.b	(a0)+
	dbf	d0,.nxt	
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

fix_3dbutts
	lea	ownrsc(pc),a5
	lea	10(a5),a5
	jsr	.fixrsc(pc)
	lea	ownrsc(pc),a5
	add	(a5),a5
.fixrsc
	move	rsh_trindex(a5),d6
	move	rsh_ntree(a5),d7
	subq	#1,d7	
.nxttree
	move.l	a5,a0
	add.l	(a5,d6),a0
	pea	0(a0)
	move	ob_head(a0),-(sp)
	move	ob_next(a0),-(sp)
	jsr	.fix_type(pc)
	addq	#8,sp
	addq	#4,d6
	dbf	d7,.nxttree
	rts

.fix_type		; 4(sp)=parent
		; 6(sp)=obj
		; 8(sp)=tree
	move	6(sp),d0		; d0=obj
	move.l	8(sp),a3
	move	4(sp),d2		; d2=parent
.while	
	cmp	d0,d2
	beq	.end
	move	d0,d1
	mulu	#ob_sizeof,d1


	move	ob_flags(a3,d1),d5
	move	d5,d4
	and	#%11000000000,d4
	lsr	#8,d4		
	lsr	#1,d4		
	cmp	#1,d4
	bne	.noind
	or	#$0100,ob_type(a3,d1)
	bra	.noact
.noind
*	cmp	#2,d4
*	bne	.noback
*	cmp	#G_BOXCHAR,ob_type(a3,d1)
*	bne	.noback
*.okobj
*	or	#$0200,ob_type(a3,d1)
*	bra	.noact
*.noback	
	cmp	#3,d4
	bne	.noact
	cmp	#G_BOXCHAR,ob_type(a3,d1)
	bne	.nobox
	move.l	ob_spec(a3,d1),d5
	and.l	#$FF000000,d5
	or.l	#%00000000000000011001000101111000,d5
	move.l	d5,ob_spec(a3,d1)
.nobox
	or	#$0200,ob_type(a3,d1)
.noact
	cmp	#-1,ob_head(a3,d1)
	beq	.sluta
	
	move	d2,-(sp)
	move	d1,-(sp)
	pea	0(a3)		; tree
	move	ob_head(a3,d1),-(sp)
	move	d0,-(sp)
	jsr	.fix_type(pc)
	addq	#8,sp
	move	(sp)+,d1
	move	(sp)+,d2
.sluta
	move	ob_next(a3,d1),d0
	move	d0,d1
	mulu	#ob_sizeof,d1
	bra	.while
.end	
	rts



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
	cmp	#$401,2(a0)
	sle	fixrsc(a6)
	lea	tosdata(pc),a1
.letanext
	move	tosversion(a1),d0
	smi	stflg(a6)
	bmi	.exit
	cmp	2(a0),d0		JÑmfîr med TOS-version
	beq	.found
	lea	maglen(a1),a1
	bra	.letanext
.found
	move.l	#ownid,d0
	jsr	get_cookie(pc)
	spl	installerad(a6)
	bpl	.exit
	move.l	#"MOGR",d0		; GEMRAM?
	jsr	get_cookie(pc)
	bpl	.rominram
	move.l	#"VRAM",d0		; VRAM?
	jsr	get_cookie(pc)
	bpl	.rominram
	move.l	#"USRS",d0		; ROMSPEED?
	jsr	get_cookie(pc)
	bpl	.rominram
	move.l	#"PTOS",d0		; ROMRAM?
	jsr	get_cookie(pc)
	bmi	.notinram
.rominram
	move.l	$4f2.w,a0
	move.l	$14(a0),a0
	cmp.l	#$87654321,(a0)
	bne	.notinram
	move.l	8(a0),d0
	cmp.l	$42e.w,d0		Under mtop blir i RAM
	bcc	.notinram
	move.l	d0,a0
	add.l	magic9(a1),a0
	lea	ownrsctab(a6),a2
	move.l	a2,(a0)
	bra	.tosinramcont
.notinram
	
	IFD	CART
	lea	o_trap1(a6),a0
	ELSEIF
	lea	o_trap1(pc),a0
	ENDC
	move.l	$84.w,(a0)
	lea	my_trap1(pc),a0
	move.l	a0,$84.w
.tosinramcont
	move.l	a6,d1		LÑgg in basadress i cookie
	move.l	#ownid,d0
	jsr	insert_cookie(pc)
	slt	stflg(a6)
	blt	.exit
	move.l	a1,magbase(a6)

	lea	tosversion(a1),a0
	lea	tosver(a6),a2
	move	(a0),d0
	rol	#4,d0
	jsr	.makenum(pc)
	move.b	#".",(a2)+
	jsr	.makenum(pc)
	jsr	.makenum(pc)
*	moveq	#3,d0
*	lea	magverstr(a1),a0
*.movestr
*	move.b	(a0)+,(a2)+
*	dbf	d0,.movestr
	move.b	#$0d,(a2)+
	move.b	#$0a,(a2)+
	clr.b	(a2)+
	lea	ownrsctab(a6),a0
	move.l	magic3(a1),a2
	move.l	a0,a3
	moveq	#5,d0
.nxttab
	move.l	(a2)+,(a0)+
	dbf	d0,.nxttab
	lea	ownrsc(pc),a0
	move.l	a0,6*4(a3)		; SWE Ñr cookienr 6
	tst.b	fixrsc(a6)
	beq	.exit
	jsr	fix_3dbutts(pc)
.exit
	rts
.makenum
	rol	#4,d0
	move	d0,d2
	and	#$F,d2
	add.b	#"0",d2
	move.b	d2,(a2)+
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
.ich	addq	#1,D4	;Slotanzahl erhîhen
	movem.l	(A1)+,D2-D3	;Namen und Wert eines Cookies holen
	tst.l	D2	;leeren Cookie gefunden?
	bne.s	.ich	;Nein => weiter suchen
	cmp.l	D3,D4	;alle Slots belegt?
	beq.s	.icn	;Ja! => neue Liste anlegen
	movem.l	D0-D4,-8(A1)	;neuen Cookie & Listenende einfÅgen
	moveq	#0,D0	;alles ok!
	bra.s	.exit	;und raus

.icn
	move.l	$5a0.w,a1
.icn2
	movem.l	(a1)+,d2-d3
	tst.l	d2
	bne	.icn2
	move.l	d3,d5
	addq	#8,d5	; ôka pÜ med 8 till ny cookie-jar
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
	move.l	d0,a0	; Ny plats fîr cookie

	cmp.l	D5,D4	;reicht der Platz?
	ble.s	.exit	;Nein => Fehler und raus
	movea.l	$5a0.w,A1	;Anfang der Liste erneut holen
	move.l	A0,$5a0.w	;neuen Cookie Jar eintragen
	subq	#2,D4	;Ende nicht kopieren (-1 fÅr DBRA)
.icm
	move.l	(A1)+,(A0)+	;EintrÑge der Liste kopieren
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
	move.l	d2,a4
	move.l	magbase(a4),a5
	move.l	-6(a6),d0
	cmp.l	$42e.w,d0		Under mtop blir i RAM
	bcs	.iram1
	cmp.l	#$e7ffff,d0		Inte îver ROM!
	bcc	.not
	cmp.l	#$e00000,d0		Och inte under heller!
	bcs	.not
.iram1
	move.l	d0,a0
	cmp.l	#$5c4f4a80,(a0)	RÑtt malloc?
	bne	.not
	move.l	6(a6),d0
	cmp.l	$42e.w,d0		Ogiltig adress
	bcs	.iram2
	cmp.l	#$ffffff,d0
	bcc	.not
	cmp.l	#$e00000,d0
	bcs	.not
.iram2
	move.l	d0,modmag2(a4)
	exg	d0,a0
	sub.l	a0,d0		BerÑkna offset
	cmp.l	magic8(a5),d0	RÑtt offset?
	bne	.not
	bchg	#0,first(a4)
	bne	.not
	move.l	#-1,2(a6)		; Returnera ledigt minne t ex...
	lea	owncont(pc),a0
	move.l	a0,6(a6)	LÑnka in mig i returnadress efter malloc...
	move.l	$84.w,a0
	cmp.l	#ownid,-8(a0)	Vi ligger sist!
	beq	.bruten
	lea	my_trap1(pc),a1
.xbraigen
	cmp.l	#"XBRA",-12(a0)
	bne.s	.not		LÜt ligga kvar om det ligger icke-XBRA-kompatibla program efter...
	move.l	-4(a0),d0
	cmp.l	a1,d0		My_trap?
	beq.s	.hittad
	move.l	d0,a0
	bra	.xbraigen
.hittad
	IFD	CART
*	move.l	o_trap1(a5),-4(a0)
	ELSEIF
*	move.l	o_trap1(pc),-4(a0)
	ENDC
	bra	.not
.bruten
	IFD	CART
*	move.l	o_trap1(a5),$84.w	StÑng av mig nu...
	ELSEIF
*	move.l	o_trap1(pc),$84.w	StÑng av mig nu...
	ENDC
.not
	movem.l	(sp)+,reglist
	move.l	(sp)+,a6
	IFD	CART
	move.l	o_trap1(a5),-(sp)	fortsÑtt med trap #1 lÑnken
	ELSEIF
	move.l	o_trap1(pc),-(sp)	fortsÑtt med trap #1 lÑnken
	ENDC
	rts
.not_mine	
	movem.l	(sp)+,reglist
	move.l	(sp)+,a6
	IFD	CART
	move.l	o_trap1(a5),-(sp)	fortsÑtt med trap #1 lÑnken
	ELSEIF
	move.l	o_trap1(pc),-(sp)	fortsÑtt med trap #1 lÑnken
	ENDC
	rts
owncont
	move.l	#ownid,d0
	jsr	get_cookie(pc)	OBS! FîrutsÑtter att den finns!
	move.l	d2,a4
	move.l	magbase(a4),a5	
	move.l	magic7(a5),a0
	move.l	2(a0),a0
	move	(a0),a0
	add.l	a0,a0
	add.l	a0,a0
	add.l	d2,a0
	lea	ownrsctab(a0),a0
	move.l	modmag2(a4),a1
	jmp	-$1e(a1)


	rsreset
tosversion	rs	1
magic2	rs.l	1
magic3	rs.l	1
magic7	rs.l	1
magic8	rs.l	1
magic9	rs.l	1
maglen	rs.b	0


	DATA

TOSDATA
	dc	$400	TOS 4.00	OBS! KOLLAS! (EJ TESTAT...)
	dc.l	$e25a0a	;2
	dc.l	$e4b7ea	;3
	dc.l	$e259dc	;7
	dc.l	$e31d86-$e25a0a	;#
	dc.l	$8004	;9
	dc	$401	TOS 4.01	OK!
	dc.l	$e25d24	;2
	dc.l	$e4c84c	;3
	dc.l	$e25cf6	;7
	dc.l	$e32bf2-$e25d24	;8
	dc.l	$81fe	;9
	dc	$402	TOS 4.02	OK! KOLLAS!
	dc.l	$e275c4	; 2
	dc.l	$e509c6	; 3
	dc.l	$e27596	; 7
	dc.l	$e349c6-$e275c4	; 8
	dc.l	$8278	; 9
	dc	$404	TOS 4.04	OK!
	dc.l	$e27624	; 2
	dc.l	$e50a26	; 3
	dc.l	$e275f6	; 7
	dc.l	$e34a26-$e27624	; 8
	dc.l	$8278	; 9
	dc	-1		End mark

message	dc.b	$0d,$0a
	dc.b	27,"p"
	dc.b	"        Svensk Desktop v1.0        ",27,"q",$0d,$0a
	dc.b	"Ω 1994 Conny Pettersson, Copson DATA",$0d,$0a
	dc.b	"Distributîr: AdAstra Electronics AB",$0d,$0a
	dc.b	$0d,$0a
	dc.b	"Installerad i TOS ",0
instmess	dc.b	$0d,$0a,$07
	dc.b	"Svensk Desktop Ñr redan",$0d,$0a
	dc.b	"installerad!",$0d,$0a
	dc.b	0
norommess	dc.b	$0d,$0a,$07
	dc.b	"Svensk Desktop fungerar INTE",$0d,$0a
	dc.b	"pÜ MultiTOS!",$0d,$0a
	dc.b	$0
nof030	dc.b	$0d,$0a,$07
	dc.b	"Svensk Desktop fungerar BARA pÜ",$0d,$0a
	dc.b	"Falcon 030!",$0d,$0a
	dc.b	0
	even
ownrsc	incbin	404swe.bin

	rsreset
magbase	rs.l	1
modmag2	rs.l	1
ownrsctab	rs.l	16	; Reservera fîr 16 sprÜk
	IFD	CART
o_trap1	rs.l	1
	ENDC
stflg	rs.b	1
installerad	rs.b	1
norom	rs.b	1
first	rs.b	1
fixrsc	rs.b	1
tosver	rs.b	4+2+1
bsslen	rs.b	1
	end