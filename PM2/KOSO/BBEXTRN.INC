; "BBEXTRN.INC" PC-9801UV11 make by R.H 1991/10/16
;
;
;	princess  B A S I C    exturn symboles.
;
;
; exturn symboles.

; *********************************************************
;	const.
; *********************************************************

EOT		EQU	0	; end of text.
EOS		EQU	0	; end of string.
CHR_CR		EQU	0DH	; CR
CHR_LF		EQU	0AH	; LF
CHR_TAB		EQU	09H	; TAB
TAG_NOTCOM	EQU	0EH	; not compile.
TAG_COMPILE	EQU	0FH	; compiled.
CHR_SPACE	EQU	' '	; space.
CHR_COMMA	EQU	','	; , comma.
MARKLABEL	EQU	'*'	; label mark.
MARKCOMMENT	EQU	3BH	;';'	; comment mark.
MARKCOMMENT2	EQU	3AH	;':'	: comment mark.
MARKBEGIN	EQU	'('	; ( begin mark.
MARKEND		EQU	')'	; ) end mark.
MARKIF		EQU	'?'	; ? if mark.
MARKDIMI	EQU	'['	; [ begin mark.
MARKDIMO	EQU	']'	; ] end mark.
MARKDEF		EQU	'.'	; define.

OFFF		EQU	-1	; OFF

; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	ARAVRM:WORD		; vram plean.

EXTRN	SSGRV0:WORD		; visual data segment plean 0
EXTRN	SSGRV1:WORD		; visual data segment plean 1
EXTRN	SSGRV2:WORD		; visual data segment plean 2
EXTRN	SSGRV3:WORD		; visual data segment plean 3
EXTRN	SSGRVW:WORD		; visual data plean width.

EXTRN	TEXTPSIZ:WORD		; text buffer size.
EXTRN	TEXTPLEN:WORD		; text length.
EXTRN	TEXTPSEG:WORD		; text segment pointer.
EXTRN	TEXTPOFS:WORD		; text offset pointer.
EXTRN	TEXTPSTARTOFS:WORD	; text start offset.
EXTRN	TEXTPCMNDOFS:WORD	; text command start offset.
EXTRN	TEXTPTAG:WORD		; text tag offset.

EXTRN	STRSYMLEN:WORD		; symbol length.
EXTRN	STRSYMMAX:WORD		; symbol max length.
EXTRN	STRSYMBOL:WORD		; symbol string.

EXTRN	DEFSYMLEN:WORD		; define symbol length.
EXTRN	DEFSYMMAX:WORD		; define symbol max length.
EXTRN	DEFSYMBOL:WORD		; define symbol string.

EXTRN	SYMNUMBER:WORD		; symbol number.
EXTRN	SYMFARLABEL:DWORD	; far label.(SYMOFST+SYMSEGM)(dword)
EXTRN	SYMOFST:WORD		; offset of symbol.
EXTRN	SYMSEGM:WORD		; segment of symbol.

EXTRN	SOUSYMNUMBER:WORD	; source symbol number.
EXTRN	SOUSYMFARLABEL:DWORD	; far.(SOUSYMOFST+SOUSYMSEGM)(dword)
EXTRN	SOUSYMOFST:WORD		; offset of source symbol.
EXTRN	SOUSYMSEGM:WORD		; segment of source symbol.

EXTRN	REG_TABLE:WORD		; registar value table.
EXTRN	REG_AX:WORD		; registar value AX.
EXTRN	REG_BX:WORD		; registar value BX.
EXTRN	REG_CX:WORD		; registar value CX.
EXTRN	REG_DX:WORD		; registar value DX.
EXTRN	REG_SI:WORD		; registar value SI.
EXTRN	REG_DI:WORD		; registar value DI.
EXTRN	REG_BP:WORD		; registar value BP.
EXTRN	REG_ES:WORD		; registar value ES.

EXTRN	COMPLINESIZE:WORD	; comp line buffer size.
EXTRN	COMPLINESOU:WORD	; comp line buffer source.
EXTRN	COMPLINEBIN:WORD	; comp line buffer binary.

EXTRN	NEST_TBL_CNT:WORD	; nest count.
EXTRN	NEST_TBL_CMAX:WORD	; nest count max.
EXTRN	NEST_TBL_ADRS:WORD	; nest table.

EXTRN	TEXTSTACK:WORD		; text stack.
EXTRN	TEXTSTACK_MXP:WORD	; text stack max point.
EXTRN	TEXTSTACKPNT:WORD	; text stack pointer.

EXTRN	NESTINGLVL:WORD		; nesting level.

EXTRN	JMPTBLSIZE:WORD		; jump table size.
EXTRN	JMPTBLDLEN:WORD		; jump table data length.
EXTRN	JMPTBLSEG:WORD		; jump label table segment.
EXTRN	JMPTBLOFS:WORD		; jump label table offset.
EXTRN	JMPADTBLDIM:WORD	; jump adrs table dimension.
EXTRN	JMPADTBLCNT:WORD	; jump adrs table count.
EXTRN	JMPADTBLSEG:WORD	; jump adrs table segment.
EXTRN	JMPADTBLOFS:WORD	; jump adrs table offset.

EXTRN	FLTEXTNOWLEN:WORD	; now text file path length.
EXTRN	FLTEXTNOW:WORD		; now text file path.

EXTRN	DIM_OFST:WORD		; dimension offset.
EXTRN	MESSAGE_SPEED:WORD	; message speed.
EXTRN	MESSAGE_WAIT:WORD	; message wait.
EXTRN	INLINECOMPDBG:WORD	; inline compile debug.
EXTRN	FLAGERROR:WORD		; error flag.
EXTRN	FLAGEXIT:WORD		; exit flag.

EXTRN	USERSTRING:WORD		; user string.

EXTRN	STRINGSTACKPNT:WORD	; string stack pointer.
EXTRN	STRINGSTACKMAX:WORD	; string stack max.
EXTRN	STRINGSTACKBUF:WORD	; string stack buffer.

EXTRN	NULSTRING:WORD		; null string buffer.

EXTRN	STR_BUFF:BYTE		; 文字列バッファ
EXTRN	STR_VAL_BUFF:BYTE	; 表示値文字列バッファ

DATA	ENDS


; *********************************************************
;	macro.
; *********************************************************

BBERROR	MACRO	NUM
	MOV	FLAGERROR,NUM	; error flag.
	EXTRN	BBERRORPR:NEAR	; error message.
	CALL	BBERRORPR	; error message.
	ENDM

BBERROR_FAR	MACRO	NUM
CODE	SEGMENT	PUBLIC	'CODE'
ASSUME	CS:CODE
	EXTRN	FAR_BBERRORPR:FAR	; error message.
CODE	ENDS
ASSUME	CS:CODE01
	MOV	FLAGERROR,NUM		; error flag.
	CALL	FAR_BBERRORPR		; error message.
	ENDM

MOVX	MACRO	DEST,SOU
	MOV	AX,SOU
	MOV	DEST,AX
	ENDM

ADDX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	ADD	DEST,AX
	ENDM

SUBX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	SUB	DEST,AX
	ENDM

CMPX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	CMP	DEST,AX
	ENDM

MOV_ID2	MACRO	DESTID,SOUID
	MOV	AX,DS
	MOV	ES,AX
	MOV	SI,OFFSET SOUID
	MOV	DI,OFFSET DESTID
	MOVSW
	MOVSW
	MOVSW
	MOVSW
	MOVSW
	ENDM

;
;	end of "BBEXTRN.INC"
;
