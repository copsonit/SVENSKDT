	rsset	0
rsh_vrsn	rs.w	1
rsh_object	rs.w	1
rsh_tedinfo	rs.w	1
rsh_iconblk	rs.w	1
rsh_bitblk	rs.w	1
rsh_frstr	rs.w	1
rsh_string	rs.w	1
rsh_imdata	rs.w	1
rsh_frimg	rs.w	1
rsh_trindex	rs.w	1
rsh_nobs	rs.w	1
rsh_ntree	rs.w	1
rsh_nted	rs.w	1
rsh_nib	rs.w	1
rsh_nbb	rs.w	1
rsh_nstrings	rs.w	1
rsh_numages	rs.w	1
rsh_rssize	rs.w	1
rsh_sizeof	rs.b	0

	rsset	0
ob_next	rs.w	1
ob_head	rs.w	1
ob_tail	rs.w	1
ob_type	rs.w	1
ob_flags	rs.w	1
ob_state	rs.w	1
ob_spec	rs.l	1
ob_x	rs.w	1
ob_y	rs.w	1
ob_w	rs.w	1
ob_h	rs.w	1
ob_sizeof	rs.w	0
	rsset	0
te_ptext	rs.l	1
te_ptmplt	rs.l	1
te_pvalid	rs.l	1
te_font	rs.w	1
te_resvd1	rs.w	1
te_just	rs.w	1
te_color	rs.w	1
te_resvd2	rs.w	1
te_thickness	rs.w	1
te_txtlen	rs.w	1
te_tmplen	rs.w	1
te_sizeof	rs.w	0
	rsset	0
ib_pmask	rs.l	1
ib_pdata	rs.l	1
ib_ptext	rs.l	1
ib_char	rs.w	1
ib_xchar	rs.w	1
ib_ychar	rs.w	1
ib_xicon	rs.w	1
ib_yicon	rs.w	1
ib_wicon	rs.w	1
ib_hicon	rs.w	1
ib_xtext	rs.w	1
ib_ytext	rs.w	1
ib_wtext	rs.w	1
ib_htext	rs.w	1
ib_sizeof	rs.w	0
	rsset	0
bi_pdata	rs.l	1
bi_wb	rs.w	1
bi_hi	rs.w	1
bi_x	rs.w	1
bi_y	rs.w	1
bi_color	rs.w	1
bi_sizeof	rs.w	0
	rsset	0
ab_code	rs.l	1
ab_param	rs.l	1
ab_sizeof	rs.w	0
	rsset	0
pb_tree	rs.l	1
pb_obj	rs.w	1
pb_prevstate	rs.w	1
pb_currstate	rs.w	1
pb_x	rs.w	1
pb_y	rs.w	1
pb_w	rs.w	1
pb_h	rs.w	1
pb_xc	rs.w	1
pb_yc	rs.w	1
pb_wc	rs.w	1
pb_hc	rs.w	1
pb_param	rs.l	1
pb_sizeof	rs.w	0
* OBJECT TYPES
G_BOX	EQU	20
G_TEXT	EQU	21
G_BOXTEXT	EQU	22
G_IMAGE	EQU	23
G_PROGDEF	EQU	24
G_IBOX	EQU	25
G_BUTTON	EQU	26
G_BOXCHAR	EQU	27
G_STRING	EQU	28
G_FTEXT		EQU	29
G_FBOXTEXT	EQU	30
G_ICON	EQU	31
G_TITLE	EQU	32
* OBJECT FLAGS masks
SELECTABLE	EQU	1
DEFAULT	EQU	2
EXIT	EQU	4
EDITABLE	EQU	8
RBUTTON	EQU	16
LASTOB	EQU	32
TOUCHEXIT	EQU	64
HIDETREE	EQU	128
INDIRECT	EQU	256
* OBJECT STATE masks
SELECTED	EQU	1
CROSSED	EQU	2
CHECKED	EQU	4
DISABLED	equ	8
OUTLINED	equ	16
SHADOWED	equ	32
* STANDARD COLOR NAMES
WHITE	EQU	0
BLACK	EQU	1
RED	EQU	2
GREEN	EQU	3
BLUE	EQU	4
CYAN	EQU	5
YELLOW	EQU	6
MAGENTA	EQU	7
LWHITE	EQU	8
LBLACK	EQU	9
LRED	EQU	10
LGREEN	EQU	11
LBLUE	EQU	12
LCYAN	EQU	13
LYELLO	EQU	14
LMAGENTA	EQU	15

color_word	macro	border,text,xo,fillp,fillc
	dc.w	((\1&$ff)<<12)+((\2&$ff)<<8)+((\3&1)<<7)+((\4&7)<<4)+(\5&15)
	endm




