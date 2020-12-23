	output	f:\svenskdt.prg
	include	set_nh.s
	include	objects.s
FMD_START	equ	0
FMD_FINISH	equ	3
AC_OPEN	equ	40

start
	move.l	a0,d0		Om a0=0 „r det PRG...
	seq	isprg
	beq.s	.prgstart
	lea	mystack,a7		ACC must have an own stack!
	move.l	d0,a3
	move.l	$1c(a3),d0
	lea	bsstart,a0
.igen
	clr.b	(a0)+
	subq.l	#1,d0
	bne	.igen	
	bra.s	.accstart
.prgstart
	move.l	4(a7),a3		base page
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
.accstart
	
	clr.l	global		* f”r MT och 4.01
	lea	contrl,a0
	move.l	#$0A000100,d0	APPL_INIT
	jsr	aes(pc)
	move.w	d0,ap_id		store the application id
	bmi	pterm0
	move	global,d0
	beq	pterm0		Inte fr†n AUTO!
	cmp	#$400,d0
	sge	aes40
 

	tst.b	isprg
	bne.s	.prgforts
	lea	contrl,a0
	move.l	#mymenu,addr_in-contrl(a0)
	move	ap_id,int_in-contrl(a0)
	move.l	#$23010101,d0	MENU_REGISTER
	jsr	aes(pc)
	move	d0,menu_id
.wait2open
	lea	contrl,a0
	move.l	#messagebuf,addr_in-contrl(a0)
	move.l	#$17000101,d0	EVNT_MESAG
	jsr	aes(pc)
	move	messagebuf,d0
	cmp	#AC_OPEN,d0
	bne	.wait2open
	bra.s	.menyklar
.prgforts
	jsr	ARROW(pc)
.menyklar
	
	lea	intin,a0
	moveq	#10-1,d0		; -1 for DBF
.fill	move.w	#1,(a0)+		; most params are 1
	dbf	d0,.fill
	move.w	#2,(a0)+		; use RC system

	lea	contrl,a0
	move.l	#$4d000500,d0	GRAF_HANDLE
	jsr	aes(pc)
	move	d0,handle		Ocks† current handle

	move.l	#$6400060B,d0	V_OPENVWK
	move	#45,vcontrl4	
	lea	vcontrl,a0
	jsr	vdi(pc)
	move	vcontrl6,handle	Aktuell handle f”r VDI-funktionen
	bmi	applexit

	pea	chk_mch(pc)
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp

	tst.b	nonvm
	beq.s	.finns
	pea	nofalcon(pc)
	move	#1,-(sp)
	jsr	form_alert(pc)
	addq.l	#6,sp
	bra	.mainexit	
.finns

	jsr	get_aesinfo(pc)

	jsr	init_rsc(pc)

	jsr	get_nvm(pc)

	beq	.allOK

	pea	nvmError(pc)
	move	#1,-(sp)
	jsr	form_alert(pc)
	addq.l	#6,sp
	bra	.mainexit	

.allOK
 	jsr	init_butts(pc)

	jsr	do_dialog(pc)

	jsr	deinit_aes(pc)

.mainexit
	move	handle,vcontrl6
	move.l	#$65000000,d0	V_CLSEVWK
	clr	vcontrl4	
	lea	vcontrl,a0
	jsr	vdi(pc)

	tst.b	isprg
	beq	.wait2open

applexit
	lea	contrl,a0
	move.l	#$13000100,d0	APPL_EXIT
	jsr	aes(pc)
pterm0
	clr	-(sp)
	trap	#1

get_nvm
	st	firstGet
.get_nvm_again
	pea	nvm
	move	#sizeof_nvm,-(sp)
	clr	-(sp)
	clr	-(sp)
	move	#$2e,-(sp)
	trap	#14
	lea	12(sp),sp
	tst.l	d0
	bpl.s	.allOK
	tst.b	firstGet
	beq	.errorExit
	pea	nvm
	move	#sizeof_nvm,-(sp)
	clr	-(sp)
	move	#2,-(sp)
	move	#$2e,-(sp)
	trap	#14
	lea	12(sp),sp
	sf	firstGet
	bra	get_nvm

.allOK
	lea	nvm,a0
*	move.b	vmode(a0),d0
*	move	d0,d1
*	and	#7,d1
*	move	d1,n_col
*	move	d0,d1
*	and	#COL80,d1
*	sne	n_col80	; $00:COL40, $FF:COL80
*	move	d0,d1
*	and	#PAL,d1
*	sne	n_pal	; $00: NTSC $FF:PAL
*	move	d0,d1
*	and	#VGA,d1
*	sne	n_vga	; $00: TV, $FF:VGA
*	move	d0,d1
*	and	#VERTFLAG,d1
*	sne	n_vertflag
*	move	d0,d1
*	and	#OVERSCAN,d1
*	sne	n_overscan
*	move	d0,d1
*	and	#STMODES,d1
	
	move.b	language(a0),d0
	cmp.b	#6,d0
	seq	svenska
	cmp.b	#16,d0
	bls.s	.ok
	clr.b	d0
.ok
	lea	ctl,a1
	move.b	(a1,d0),d0
	add	lang_omn+omn_menu,d0
	move	d0,lang_omn+omn_item

	move.b	keyboard(a0),d0
	cmp.b	#16,d0
	bls.s	.ok1
	clr.b	d0
.ok1
	lea	ctk,a1
	move.b	(a1,d0),d0
	add	tang_omn+omn_menu,d0
	move	d0,tang_omn+omn_item

	move.b	datetime(a0),d0
	lsr	#4,d0
*	and	#15,d0
	and	#1,d0
	addq	#1,d0
	add	ur_omn+omn_menu,d0
	move	d0,ur_omn+omn_item

	move.b	datetime(a0),d0
*	and	#15,d0
	and	#3,d0
	addq	#1,d0
	add	date_omn+omn_menu,d0
	move	d0,date_omn+omn_item

	lea	n_sep,a1
	move.b	separator(a0),(a1)+
	clr.b	(a1)+

	moveq	#0,d0
	rts
.errorExit
	moveq	#-1,d0
	rts

set_nvm
	lea	nvm,a0
	move	lang_omn+omn_item,d0
	sub	lang_omn+omn_menu,d0
	subq	#1,d0
	lea	ltc(pc),a1
	move.b	(a1,d0),language(a0)

	move	tang_omn+omn_item,d0
	sub	tang_omn+omn_menu,d0
	subq	#1,d0
	lea	ktc(pc),a1
	move.b	(a1,d0),keyboard(a0)

	move	ur_omn+omn_item,d0
	sub	ur_omn+omn_menu,d0
	subq	#1,d0
	lsl	#4,d0
	move	d0,d1

	move	date_omn+omn_item,d0
	sub	date_omn+omn_menu,d0
	subq	#1,d0
	or	d0,d1
	move.b	d1,datetime(a0)
	move.b	n_sep,separator(a0)

	pea	set_cookies(pc)
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp

	pea	nvm
	move	#sizeof_nvm,-(sp)
	clr	-(sp)
	move	#1,-(sp)
	move	#$2e,-(sp)
	trap	#14
	lea	12(sp),sp

	rts

usa	equ	0
frg	equ	1
fra	equ	2
uk	equ	3
spa	equ	4
ita	equ	5
swe	equ	6
swf	equ	7
swg	equ	8
tur	equ	9
fin	equ	10
nor	equ	11
den	equ	12
sau	equ	13
hol	equ	14
cze	equ	15
hun	equ	16


ltc	dc.b	usa,frg,fra,spa,ita,swe,fra,frg
	dc.b	tur,fin,nor,den,sau,hol,cze,hun

ktc	dc.b	usa,frg,fra,spa,ita,swe,swf,swg
	dc.b	tur,fin,nor,den,sau,hol,cze,hun

	; NVM till menyvariabler
ctl	dc.b	1,2,3,1,4,5,6,7,8,9,10,11,12,13,14,15,16

	; NVM till menyvariabler
ctk	dc.b	1,2,3,1,4,5,6,7,8,9,10,11,12,13,14,15,16


set_cookies
	move.l	#"_AKP",d0
	jsr	get_cookie(pc)
	bmi	.skip
	move	nvm+language,-(a0)
.skip
	move.l	#"_IDT",d0
	jsr	get_cookie(pc)
	bmi	.skip2
	move	nvm+datetime,-(a0)
.skip2
	rts

chk_mch
	move.l	#"_MCH",d0
	jsr	get_cookie(pc)
	smi	nonvm
	bmi.s	.exit
	cmp.l	#$30000,d2
	sne	nonvm
.exit	
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


check_butt
	lea	butlist,a0
.nxtbutt
	move	(a0)+,d1
	beq.s	dc_jmp
	move	(a0)+,d2
	cmp	d0,d1
	bne.s	.nxtbutt
	jmp	dc_jmp(pc,d2)	I d1 och d0 ligger knappen...
dc_jmp	
	rts

	rsreset
	; struct {
omn_menu	rs	1	; Objektnummer f”r menyn
omn_item	rs	1	; Senast vald menyentry
omn_mnobj	rs	1	; knappen med submenyn
omn_butobj	rs	1	; sidoknapp med ð
omn_selobj	rs	1	; tillh”rande text till menyn
sizeof_omn	rs.b	0
	; } OWN_MENU

lang_omn
	dc	S_DESKTOP
	dc	0
	dc	R_LANG
	dc	R_LANGB
	dc	R_TLANG

tang_omn
	dc	S_TANGENT
	dc	0
	dc	R_TANG
	dc	R_TANGB
	dc	R_TTANG

ur_omn
	dc	S_UR
	dc	0
	dc	R_UR
	dc	0
	dc	R_TUR

date_omn
	dc	S_DATUM
	dc	0
	dc	R_DATE
	dc	0
	dc	R_TDATE





butlist	
	dc	R_SWED,.swed-dc_jmp
	dc	R_ENG,.eng-dc_jmp
	dc	R_LANG,.lang-dc_jmp
	dc	R_LANGB,.lang-dc_jmp
	dc	R_TANG,.tang-dc_jmp
	dc	R_TANGB,.tang-dc_jmp
	dc	R_UR,.ur-dc_jmp
	dc	R_DATE,.date-dc_jmp
	dc	R_INSTALL,.install-dc_jmp
	dc	R_AVBRYT,.avbryt-dc_jmp
	dc	0



.swed
	move	d0,-(sp)
	pea	swetab
	bra	.setdeflang

.eng	
	move	d0,-(sp)
	pea	engtab
.setdeflang
	jsr	set_deflang(pc)
	addq	#4,sp
	move	(sp)+,d0
	bra	.unselbutt

.lang
	lea	lang_omn,a4
	bra	.sub_meny
.tang
	lea	tang_omn,a4
	bra	.sub_meny
.ur
	lea	ur_omn,a4
	bra	.sub_meny
.date
	lea	date_omn,a4
	bra	.sub_meny
.install
	move	d0,-(sp)	; OBS! f”r chgobstate!

	pea	n_sep
	move	#R_SKILJ,-(sp)
	jsr	GET_TEXT(pc)
	addq	#6,sp	
	jsr	set_nvm(pc)

	jsr	clr_checks(pc)
	jsr	get_nvm(pc)
	jsr	init_butts(pc)
	jsr	draw_butts(pc)

	; objektnummer redan pushat p† stacken
	move	#-1,-(sp)
	clr	-(sp)
	jsr	CHGOBSTATE(pc)
	addq	#6,sp
	tst.b	svenska
	beq.s	.intesv
	jsr	CHECK_SVENSKA(pc)
.intesv	
	pea	installed(pc)
	move	#1,-(sp)
	jsr	form_alert(pc)
	addq.l	#6,sp
	st	quit
	bra	dc_jmp
.avbryt
	st	quit
.unselbutt
	move	d0,-(sp)
	move	#-1,-(sp)
	clr	-(sp)
	jsr	CHGOBSTATE(pc)
	addq	#6,sp
	bra	dc_jmp

.sub_meny
	lea	ome_tree,a0
	move.l	d_subs,mn_tree(a0)	Tr„dadressen
	move	omn_item(a4),mn_item(a0)	L„gg in vald knapp
	move	omn_menu(a4),mn_menu(a0)	Objektnummer p† menyn
	move	omn_item(a4),d0
	addq	#8,d0
	move	#0,mn_scroll(a0)
	tst	omn_butobj(a4)
	beq.s	.nomelist
	tst.b	aes40
	beq.s	.nomelist
	move	#-1,mn_scroll(a0)	Dropdownlist
.nomelist
	move	omn_selobj(a4),-(sp)
	clr	-(sp)
	clr	-(sp)
	jsr	CHGOBSTATE(pc)
	addq	#6,sp

	move	omn_mnobj(a4),-(sp)
	clr	-(sp)
	clr	-(sp)
	jsr	CHGOBSTATE(pc)
	addq	#6,sp

	lea	contrl,a0
	move	omn_mnobj(a4),d0	Knapp ”ver menyn
	mulu	#ob_sizeof,d0
	lea	(a3,d0),a1
	move	ob_x(a1),d0
	add	fo_cx,d0
	addq	#3,d0
	move	d0,int_in-contrl(a0)
	move	ob_y(a1),d0
	add	fo_cy,d0
	addq	#3,d0
	move	omn_butobj(a4),d1
	beq.s	.ingenlist
	tst.b	aes40
	beq.s	.ingenlist
	add	#16,d0
.ingenlist
	move	d0,int_in-contrl+2(a0)
	move.l	#ome_tree,addr_in-contrl(a0)
	move.l	#ome_mdata,addr_in-contrl+4(a0)		
	move.l	#$24020102,d0	MENU_POPUP
	jsr	aes(pc)
	tst	d0
	beq	.notlang
	lea	contrl,a0
	move	omn_item(a4),int_in-contrl(a0)
	clr	int_in-contrl+2(a0)
	move.l	d_subs,addr_in-contrl(a0)
	move.l	#$1f020101,d0	OBJC_CHANGE
	jsr	aes(pc)

	lea	ome_mdata,a1
	move	mn_item(a1),omn_item(a4)
	
.notlang
	jsr	SET_MENYBUTT(pc)
	move	omn_selobj(a4),-(sp)
	move	#-1,-(sp)
	clr	-(sp)
	jsr	CHGOBSTATE(pc)
	addq	#6,sp
	move	omn_mnobj(a4),-(sp)
	move	#-1,-(sp)
	clr	-(sp)
	jsr	CHGOBSTATE(pc)
	addq	#6,sp
	move	omn_mnobj(a4),-(sp)
	clr	-(sp)
	jsr	OBJC_DRAW(pc)
	addq	#4,sp
	rts

get_bootdr
	move	$446.w,bootdev
	rts
CHECK_SVENSKA
	pea	get_bootdr(pc)
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp
	move	bootdev,d0
	add.b	#"A",d0
	move.b	d0,svenskfil
	move.b	d0,automapp
	pea	svenskfil(pc)
	jsr	fileexist(pc)
	addq	#4,sp
	bpl	.ok
	pea	ejsvenska(pc)
	move	#1,-(sp)
	jsr	form_alert(pc)
	addq.l	#6,sp
	cmp	#1,d0
	bne	.ok
	jsr	BEE(pc)
	move	#16,-(sp)
	pea	automapp
	move	#$4e,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0
	bpl	.autofinns	
	pea	automapp
	move	#$39,-(sp)
	trap	#1
	addq	#6,sp
	tst.l	d0
	bmi	.filerror
.autofinns
	move	#0,-(sp)		Skrivning
	pea	svenskfil(pc)
	move	#$3c,-(sp)		FCREATE
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	.filerror
	move	d0,d7
	
	pea	svenskaprg(pc)
	move.l	#sv_end-svenskaprg,-(sp)
	move	d7,-(sp)
	move	#$40,-(sp)		FWRITE
	trap	#1
	lea	12(sp),sp
	cmp.l	-8(sp),d0
	bmi	.filerror
	tst.l	d0
	bmi	.filerror

	move	d7,-(sp)
	move	#$3e,-(sp)		FCLOSE
	trap	#1
	addq	#4,sp
	tst.l	d0
	bmi	.filerror
	jsr	ARROW(pc)
	pea	filok(pc)
	move	#1,-(sp)
	jsr	form_alert(pc)
	addq.l	#6,sp

.ok	
	rts
.filerror
	jsr	ARROW(pc)
	pea	filfel(pc)
	move	#1,-(sp)
	jsr	form_alert(pc)
	addq.l	#6,sp
	rts
fileexist
*	move	#$2f,-(sp)
*	trap	#1
*	addq	#2,sp
	clr	-(sp)
	move.l	6(sp),-(sp)
	move	#$4e,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0
	rts

SET_MENYBUTT
	move.l	a3,-(sp)
	move.l	d_subs,a3
	move	omn_item(a4),d0
	mulu	#ob_sizeof,d0
	lea	(a3,d0),a1
	move.l	ob_spec(a1),a0
	move	omn_mnobj(a4),d0
	mulu	#ob_sizeof,d0
	move.l	(sp)+,a3
	lea	(a3,d0),a1
	move.l	ob_spec(a1),a1
	addq	#2,a0
.nxtchar
	tst.b	(a1)
	beq	.end
	move.b	(a0)+,(a1)+
	bra	.nxtchar	
.end
	lea	contrl,a0
	move	omn_item(a4),int_in-contrl(a0)
	move	#1,int_in-contrl+2(a0)
	move.l	d_subs,addr_in-contrl(a0)
	move.l	#$1f020101,d0	MENU_ICHECK
	jsr	aes(pc)
	rts


CHGOBSTATE
	; SP: 
	;     8(sp)=object
	;     6(sp)=$FF eller $00, $FF enable,  $00 disable
	;     4(sp)=bit som ska „ndras

	move	8(sp),d0
	move	d0,-(sp)	OBS! vi „ndrar stackordningen!
	mulu	#ob_sizeof,d0
	add	#ob_state,d0
	move	(a3,d0),d2
	moveq	#1,d0
	move	6(sp),d1	f.d. 4(sp)
	lsl	d1,d0	
	move	8(sp),d1	f.d. 6(sp)
	eor	#-1,d1
	and	d0,d1
	eor	#$ffff,d0
	and	d0,d2
	or	d1,d2
	move	d2,-(sp)	
	jsr	OBJC_CHANGE(pc)
	addq	#4,sp
	rts


OBJC_CHANGE
	lea	contrl,a0
	move	6(sp),int_in-contrl(a0)
	clr	int_in-contrl+2(a0)
	move	fo_cx,int_in-contrl+4(a0)
	move	fo_cy,int_in-contrl+6(a0)
	move	fo_cw,int_in-contrl+8(a0)
	move	fo_ch,int_in-contrl+10(a0)
	move	4(sp),int_in-contrl+12(a0)
*	clr	int_in-contrl+14(a0)
*	tst.b	draw
*	beq.s	.nodraw
	move	#1,int_in-contrl+14(a0)
.nodraw
	move.l	a3,addr_in-contrl(a0)
	move.l	#$2f080101,d0	OBJC_CHANGE
	jsr	aes(pc)
	rts


CHGOBFLAGS
	; SP: 
	;     8(sp)=object
	;     6(sp)=$FF eller $00, $FF enable,  $00 disable
	;     4(sp)=bit som ska „ndras
	move	8(sp),d0
	move	d0,-(sp)	OBS! vi „ndrar stackordningen!
	mulu	#ob_sizeof,d0
	add	#ob_flags,d0
	move	(a3,d0),d2
	moveq	#1,d0
	move	6(sp),d1	f.d. 4(sp)
	lsl	d1,d0	
	move	8(sp),d1	f.d. 6(sp)
	eor	#-1,d1
	and	d0,d1
	eor	#$ffff,d0
	and	d0,d2
	or	d1,d2
	move	d2,-(sp)	
	jsr	SET_OBFLAGS(pc)
	addq	#4,sp
	rts

SET_OBFLAGS
	move	6(sp),d0	
	mulu	#ob_sizeof,d0
	add	#ob_flags,d0
	move	4(sp),(a3,d0)
	move	6(sp),-(sp)
	clr	-(sp)
	jsr	OBJC_DRAW(pc)
	addq	#4,sp
	rts

SET_TEXT
	; S„tt text till object av typ TEXT, BOXTEXT, FTEXT el FBOXTEXT
	; SP:	stringaddress.L, objectnr.W
	; Trashar a0,a1,d0
	move.l	6(sp),a1
	move	4(sp),d0
	mulu	#ob_sizeof,d0
	add	#ob_spec,d0
	move.l	(a3,d0),a0
	move	te_txtlen(a0),d0
	subq	#2,d0
	move.l	te_ptext(a0),a0
.nxtchar
	move.b	(a1)+,(a0)+
	dbf	d0,.nxtchar
	clr.b	(a0)+
	rts

GET_TEXT
	; Flytta text fr†n object av typ TEXT, BOXTEXT, FTEXT el FBOXTEXT
	; SP:	stringadress.L, objectnr.W
	move.l	6(sp),a1
	move	4(sp),d0
	mulu	#ob_sizeof,d0
	add	#ob_spec,d0
	move.l	(a3,d0),a0
	move	te_txtlen(a0),d0
	subq	#2,d0
	move.l	te_ptext(a0),a0
.nxtchar
	move.b	(a0)+,(a1)+
	dbf	d0,.nxtchar
;	clr.b	(a1)		Slut p† str„ngen
	rts


do_dialog
	move.l	d_main,a3
	lea	contrl,a0
	move.l	a3,addr_in-contrl(a0)
	move.l	#$36000501,d0	FORM_CENTER
	jsr	aes(pc)
	move	2(a0),fo_cx
	move	4(a0),fo_cy
	move	6(a0),fo_cw
	move	8(a0),fo_ch

	lea	contrl,a0
	move	#FMD_START,int_in-contrl(a0)
	move	fo_cx,int_in-contrl+2(a0)
	move	fo_cy,int_in-contrl+4(a0)
	move	fo_cw,int_in-contrl+6(a0)
	move	fo_ch,int_in-contrl+8(a0)
	move	fo_cx,int_in-contrl+10(a0)
	move	fo_cy,int_in-contrl+12(a0)
	move	fo_cw,int_in-contrl+14(a0)
	move	fo_ch,int_in-contrl+16(a0)
	move.l	#$33090100,d0
	jsr	aes(pc)

	clr	-(sp)
	move	#R_AVBRYT,-(sp)
	jsr	OBJC_DRAW(pc)
	addq	#4,sp

.dialog
	lea	contrl,a0
	move.l	a3,addr_in-contrl(a0)
	clr	int_in-contrl(a0)
	move.l	#$32010101,d0	FORM_DO
	jsr	aes(pc)
	; d0=exitbutton
	jsr	check_butt(pc)
	tst.b	quit
	beq	.dialog
.klar
	sf	quit
	lea	contrl,a0
	move	#FMD_FINISH,int_in-contrl(a0)
	move	fo_cx,int_in-contrl+2(a0)
	move	fo_cy,int_in-contrl+4(a0)
	move	fo_cw,int_in-contrl+6(a0)
	move	fo_ch,int_in-contrl+8(a0)
	move	fo_cx,int_in-contrl+10(a0)
	move	fo_cy,int_in-contrl+12(a0)
	move	fo_cw,int_in-contrl+14(a0)
	move	fo_ch,int_in-contrl+16(a0)
	move.l	#$33090100,d0
	jsr	aes(pc)

	rts


init_rsc
	tst.b	initierad
	bne	.klar
	pea	rsc		istf RSRC_LOAD
	jsr	fix_rsc(pc)
	addq	#4,sp
	move	#NVM_MAIN,d0
	jsr	get_rscaddr(pc)
	move.l	a0,d_main
	move	#NVM_SUBS,d0
	jsr	get_rscaddr(pc)
	move.l	a0,d_subs
	move.l	d_main,-(sp)
	jsr	fix_3dbutts(pc)
	move.l	d_subs,(sp)
	jsr	fix_3dbutts(pc)
	addq	#4,sp
.klar
	move.l	d_main,a3
	st	initierad
	rts

fix_3dbutts
	move.l	4(sp),a3
	pea	0(a3)		; tree
	move	#1,-(sp)
	move	#-1,-(sp)
	jsr	.fix_type(pc)
	addq	#8,sp
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


	move	ob_flags(a3,d1),d7
	move	d7,d6
	and	#%11000000000,d6
	lsr	#8,d6		
	lsr	#1,d6		
	cmp	#1,d6
	bne	.noind
	or	#$0100,ob_type(a3,d1)
	bra	.noact
.noind
	cmp	#2,d6
	bne	.noback
	cmp	#G_BOX,ob_type(a3,d1)
	beq	.okobj
	cmp	#G_IBOX,ob_type(a3,d1)
	beq	.okobj
	cmp	#G_BOXCHAR,ob_type(a3,d1)
	bne	.noback
.okobj
*	move.l	#%00000000000000011001000101111000,ob_spec(a3,d1)
*	move	#%00110000,ob_state(a3,d1)
	bra	.noact
.noback	
	cmp	#3,d6
	bne	.noact
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



inittab	dc.l	lang_omn,tang_omn,ur_omn,date_omn
engtab	dc	0,0,0,0,"."
swetab	dc	5,5,1,2,"-"

clr_checks
	lea	inittab,a5
	moveq	#3,d7
.nxt
	move.l	(a5)+,a4
	lea	contrl,a0
	move	omn_item(a4),int_in-contrl(a0)
	clr	int_in-contrl+2(a0)
	move.l	d_subs,addr_in-contrl(a0)
	move.l	#$1f020101,d0	MENU_ICHECK
	jsr	aes(pc)
	dbf	d7,.nxt
	rts

set_deflang
	jsr	clr_checks(pc)
	move.l	4(sp),a6
	lea	inittab(pc),a5
	moveq	#3,d7
.nxt
	move.l	(a5)+,a4
	move	(a6)+,d0
	add	omn_menu(a4),d0
	addq	#1,d0
	move	d0,omn_item(a4)
	dbf	d7,.nxt
	move	(a6)+,d0
	move.b	d0,n_sep
	jsr	init_butts(pc)
	jsr	draw_butts(pc)
	rts


init_butts
	move.l	a3,-(sp)
	move.l	d_main,a3
	lea	inittab,a5
	moveq	#3,d7
.nxt
	move.l	(a5)+,a4
	jsr	SET_MENYBUTT(pc)
	dbf	d7,.nxt	
	pea	n_sep
	move	#R_SKILJ,-(sp)
	jsr	SET_TEXT(pc)
	addq	#6,sp	
	move.l	(sp)+,a3
	rts

draw_butts
	lea	inittab,a5
	moveq	#3,d7
.nxt
	move.l	(a5)+,a0
	move	omn_mnobj(a0),-(sp)
	clr	-(sp)
	jsr	OBJC_DRAW(pc)
	addq	#4,sp
	dbf	d7,.nxt	
	move	#R_SKILJ,-(sp)
	clr	-(sp)
	jsr	OBJC_DRAW(pc)
	addq	#4,sp
	rts

get_rscaddr
	move.l	rsc,a0		rsc  is   your   immedded  resource
	*			location (a0  now contains the tree
	*			list address)
	lsl	#2,d0
	move.l	(a0,d0),a0
	rts


fix_rsc	movem.l	a3-a4,-(sp)
	move.l	12(sp),a4
	move.l	(a4),a4
.loop	move.l	(a4)+,d0
	beq.s	.quit
	move.l	d0,a3
	bsr	fix_trees
	bra.s	.loop
.quit	movem.l	(sp)+,a3-a4
	rts
fix_trees	movem.l	d3/a4,-(sp)
	move.l	a3,a4
	clr	d3
.loop	
	lea	contrl,a0
	move.l	a3,addr_in-contrl(a0)
	move	d3,int_in-contrl(a0)
	move.l	#$72010101,d0	RSRC_OBFIX
	jsr	aes(pc)

	btst.b	#5,9(a4)
	bne.s	.quit
	lea	24(a4),a4
	addq	#1,d3
	bra.s	.loop
.quit	movem.l	(sp)+,d3/a4
	rts



get_aesinfo
	move	#2,-(sp)	; kolla menysupport
	jsr	appl_getinfo(pc)
	addq	#2,sp

	lea	omn_set,a4
	lea	contrl,a0
	clr	int_in-contrl(a0)
	move.l	a4,addr_in-contrl(a0)
	move.l	#$27010101,d0	;menu_settings
	jsr	aes(pc)
	move	height(a4),oldheight

	move	#12,height(a4)
	lea	contrl,a0
	move	#1,int_in-contrl(a0)
	move.l	a4,addr_in-contrl(a0)
	move.l	#$27010101,d0	;menu_settings
	jsr	aes(pc)
	rts	

deinit_aes
	lea	omn_set,a4
	move	oldheight,height(a4)
	lea	contrl,a0
	move	#1,int_in-contrl(a0)
	move.l	a4,addr_in-contrl(a0)
	move.l	#$27010101,d0	;menu_settings
	jsr	aes(pc)
	rts


appl_getinfo
	lea	contrl,a0
	move	4(sp),d0
	tst.b	aes40
	bne	.finns
	clr	d0
	rts	
.finns
	move	d0,int_in-contrl(a0)
	move.l	#$82010500,d0	;appl_getinfo
	jsr	aes(pc)
	move	(a0),d0
	rts

OBJC_DRAW
	; 4(sp)	deep
	; 6(sp)	object
	
	lea	contrl,a0
	move.l	a3,addr_in-contrl(a0)
	move	6(sp),int_in-contrl(a0)
	move	4(sp),int_in-contrl+2(a0)
	move	fo_cx,int_in-contrl+4(a0)
	move	fo_cy,int_in-contrl+6(a0)
	move	fo_cw,int_in-contrl+8(a0)
	move	fo_ch,int_in-contrl+10(a0)
	move.l	#$2A060101,d0	OBJC_DRAW
	jsr	aes(pc)
	rts


form_alert
	lea	contrl,a0
	move	4(sp),int_in-contrl(a0)
	move.l	6(sp),addr_in-contrl(a0)
	move.l	#$34010101,d0
	jsr	aes(pc)
	move	(a0),d0
	rts

BEE
	move	#2,-(sp)
	jsr	GRAF_MOUSE(pc)
	addq	#2,sp
	rts

ARROW
	clr	-(sp)
	jsr	GRAF_MOUSE(pc)
	addq	#2,sp
	rts

GRAF_MOUSE
	lea	contrl,a0
	move	4(sp),int_in-contrl(a0)
	move.l	#$4e010101,d0
	jsr	aes(pc)
	rts


* call an AES routine
* in:	d0.l=contrl[0] - contrl[3]
* out	none
* uses	d0-d2/a0-a2
* OBS! Cannot be used for rsrc_gaddr because addr_out is set to 0!

aes
	movep.l	d0,1(a0)
	clr	8(a0)
	move.l	#aespb,d1
	move	#200,d0
	trap	#2
	lea	int_out,a0
	move	(a0),d0
	rts

* call a VDI routine
* in:	d0.w=VDI function number
* out	none
* uses	d0-d2/a0-a2
* uses the current handle
vdi
	movep.l	d0,1(a0)
	move.w	handle(pc),vcontrl6
	move.l	#vdipb,d1
	move.w	#115,d0			function number
	trap	#2
	lea	intout,a0
	move	(a0),d0		initout(0) -> d0
	rts
handle	ds	1




	rsreset
	; struct {
mn_tree	rs.l	1
mn_menu	rs	1
mn_item	rs	1
mn_scroll	rs	1
mn_keystate	rs	1
sizeof_menu	rs.b	0
	; }MENU;

	rsreset
	; struct _mn_set {
display	rs.l	1	; Display; - the submenu display delay
drag	rs.l	1	; Drag;    - the submenu drag delay
delay	rs.l	1	; Delay;   - the single-click scroll delay
speed	rs.l	1	; Speed;   - the continuous scroll delay
height	rs	1	; Height;  - the menu scroll height
sizeof_mnset	rs.b	0
	; }MN_SET;


	rsreset
	; struct {
bootpref	rs	1
reserved1	rs.b	4
language	rs.b	1
keyboard	rs.b	1
datetime	rs.b	1
separator	rs.b	1
reserved2	rs.b	5
vmode	rs.b	1
sizeof_nvm	rs.b	0
	; } nvm



	data
aespb	dc.l	contrl
	dc.l	global
	dc.l	int_in
	dc.l	int_out
	dc.l	addr_in
	dc.l	addr_out

vdipb	dc.l	vcontrl
	dc.l	intin
	dc.l	ptsin
	dc.l	intout
	dc.l	ptsout
mymenu	dc.b	'  NVM-Inst„llning 1.1',0
nofalcon	dc.b	"[3][SET_NVM fungerar bara|p† Falcon!][Avbryt]",0
installed	dc.b	"[1][Spr†k och tangentbord|„r nu installerat!][ OK ]",0
ejsvenska	dc.b	"[1][Du m†ste ocks† installera filen|SVENSKA.PRG i din AUTO-mapp|f”r att f† svensk desktop!|Vill du g”ra det?][ Ja | Nej ]",0
filfel	dc.b	"[3][Ett fel har uppst†tt vid|kopieringen. Kontrollera att|du har plats p† din enhet.][ Avbryt ]",0
filok	dc.b	"[1][Filen SVENSKA.PRG har nu|kopierats till din AUTO-mapp.|Starta om datorn f”r att|aktivera „ndringarna.][ OK ]",0
nvmError	dc.b	"[3][Felaktigt NV-RAM!][Avbryt]",0
svenskfil	dc.b	"C:\AUTO\SVENSKA.PRG",0
automapp	dc.b	"C:\AUTO",0
	even
rsc	include	set_nrsc.s
	even
*svenskaprg	incbin	..\tos_swed\svenska.prg
svenskaprg	incbin	f:\svenska.prg
	even
sv_end
	bss
bsstart	ds.b	0
d_main	ds.l	1
d_subs	ds.l	1
exitbutt	ds	1
oldheight	ds	1
bootdev	ds	1
n_sep	ds.b	2
svenska	ds.b	1
initierad	ds.b	1
firstGet	ds.b	1
	even
nvm	ds.b	sizeof_nvm
ome_tree	ds.b	sizeof_menu
ome_mdata	ds.b	sizeof_menu
omn_set	ds.b	sizeof_mnset
isprg	ds.b	1	;0=ACC, $FF=PRG
aes40	ds.b	1	;0=1-3, $FF=4.00 och ”ver
nonvm	ds.b	1	;0=nvm finns, $FF inget nvm
quit	ds.b	1
	even
contrl	ds.w	5
global	ds.w	14
chk	ds.w	1		Checksumma f”r namnet
int_in	ds.w	16
int_out	ds.w	7
addr_in	ds.l	3
addr_out	ds.l	1

vcontrl	ds.w	1
vcontrl1	ds.w	1
vcontrl2	ds.w	1
vcontrl3	ds.w	1
vcontrl4	ds.w	1
vcontrl5	ds.w	1
vcontrl6	ds.w	1
vcontrl7	ds.w	1
vcontrl8	ds.w	1
vcontrl9	ds.w	1
vcontrl10	ds.w	1
vcontrl11	ds.w	1

intin	ds.w	30		min 30
intout	ds.w	45		min 45
ptsin	ds.w	256
ptsout	ds.w	12		min 12

fo_cx	ds	1
fo_cy	ds	1
fo_cw	ds	1
fo_ch	ds	1
ap_id	ds	1
menu_id	ds	1
aeshandle	ds	1

messagebuf	ds.b	16
sendbuf	ds.b	16
	ds	400
mystack