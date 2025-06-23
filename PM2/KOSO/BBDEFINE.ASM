; "BBDEFINE.ASM" PC-9801UV11 make by R.H 1991/10/16
;
;
;	princess  B A S I C    define.
;
;
; command routine.

INCLUDE	TSTSETC.INC
INCLUDE	BBEXTRN.INC

TCHRSEG	SEGMENT	PUBLIC	'TCHRSEG'
TCHRSEG	ENDS

TCHRADR	SEGMENT	PUBLIC	'TCHRADR'
TCHRADR	ENDS


CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

PUBLIC	BBDEFINE		; define.
PUBLIC	BBDEFCLEAR		; define clear.

EXTRN	BBLKSKP:NEAR		; ブランクスキップ
EXTRN	BBSYMBGET:NEAR		; シンボル取得
EXTRN	BBVALUE_GET:NEAR	; 右辺数値取り出し

EXTRN	BBCMDSTR:NEAR		; 文字列の取り出し

EXTRN	c_STRLENGTH:NEAR	; 文字列長さ
EXTRN	c_STRSETZ:NEAR		; 文字列バッファセット

; *********************************************************
;	define.
;	-I/O- TEXTPSEG : text segment pointer.
;	      TEXTPOFS : text offset pointer.
;
;	sample.
;
;	.NSYAT	= 1400		;誘導弾の射程
;	.NSMIN	= 400		;
;
;	.ESYAT	= 1200		;敵の射程
;	.ESMIN	= 400		;
;
;	.ENPDIM	= 5		;
;	.ENPX   [ENPDIM]	;敵のＸ座標
;	.ENPY   [ENPDIM]	;敵のＹ座標
;	.ENPDP  [ENPDIM]	;敵の深度
;	.ENPMXHP[ENPDIM]	;敵のＭＡＸ耐久力
;
;	.EMPT0[10]=0,0,0,0,0,2,2,2,2,2	;敵の行動
;	.NAME="ABCDEFG"
;	.ENAME[3]="GORFISH-A","GORFISH-B","GORFISH-C"	; 敵名前表示
;
;	TCHRSEG
;		[byte:length1][dup:symbol string1]
;		[byte:length2][dup:symbol string2]
;		[byte:length3][dup:symbol string3]
;		[byte:length4][dup:symbol string4]
;		....
;	TCHRADR
;		[word:data offset1][word:SEG DATA]
;		[word:data offset2][word:SEG DATA]
;		[word:data offset3][word:SEG DATA]
;		[word:data offset4][word:SEG DATA]
;		....
; *********************************************************

BBDEFINE	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	AL,ES:[DI]		;
	CMP	AL,MARKDEF		; define.
	JMPNE	BBDEFINE_EXIT		;

	MOV	SETUP_VALUE,0		; setup value.
	MOV	SETUP_WORDSIZE,1	; setup word size.

	INC	TEXTPOFS		; text offset pointer.

	CALL	BBLKSKP			; ブランクスキップ

	CALL	BBSYMBGET		; シンボル取得

	MOVX	ES,DS			;
	MOV	SI,STRSYMBOL		; symbol string.
	MOV	DI,DEFSYMBOL		; define symbol string.
	MOV	CX,STRSYMLEN		; symbol length.
	MOV	DEFSYMLEN,CX		; define symbol length.
	REP	MOVSB			; copy.
	MOV	BYTE PTR ES:[DI],0	; eos

	CALL	BBLKSKP			; ブランクスキップ

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	AL,ES:[DI]		;

	CMP	AL,EOT			; end of text.
	JE	BBDEFINE_SETUP		;

	CMP	AL,MARKCOMMENT		; ';' comment mark.
	JE	BBDEFINE_SETUP		;

	CMP	AL,MARKCOMMENT2		; ':' comment mark.
	JE	BBDEFINE_SETUP		;

	CMP	AL,CHR_CR		; CR
	JE	BBDEFINE_SETUP		;

	CMP	AL,"="			;
	JE	BBDEFINE_EQU		;

	CMP	AL,MARKDIMI		; [ begin mark.
	JE	BBDEFINE_DIM		;

	CMP	AL,MARKDEF		; define.
	JE	BBDEFINE_SETUP		;

	JMP	BBDEFINE_ERROR		;

BBDEFINE_EQU:
;*;	INC	TEXTPOFS		; text offset pointer.
;*;	CALL	BBLKSKP			; ブランクスキップ
;*;
;*;	CALL	BBVALUE_GET		; 右辺数値取り出し
;*;	MOV	SETUP_VALUE,DX		; 取り出し数字(ないときは０)
;*;
	JMP	BBDEFINE_SETUP		;
BBDEFINE_DIM:
	INC	TEXTPOFS		; text offset pointer.

	CALL	BBLKSKP			; ブランクスキップ

	CALL	BBVALUE_GET		; 右辺数値取り出し
	MOV	SETUP_WORDSIZE,DX	; 取り出し数字(ないときは０)

	CALL	BBLKSKP			; ブランクスキップ

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	AL,ES:[DI]		;
	CMP	AL,MARKDIMO		; ] end mark.
	JNE	BBDEFINE_7		;
	INC	TEXTPOFS		; text offset pointer.
BBDEFINE_7:
	JMP	BBDEFINE_SETUP		;

BBDEFINE_SETUP:
	CALL	DEF_ALLOC		; define allocation.
	CMP	AX,1			; 1=size over.
	JMPEQ	BBDEFINE_ERROR_SIZEOVER	;
	CMP	AX,2			; 2=symbol S table over.
	JMPEQ	BBDEFINE_ERROR_S_TBLOVER
	CMP	AX,3			; 3=symbol A table over.
	JMPEQ	BBDEFINE_ERROR_A_TBLOVER
BBDEFINE_DIMSET:
	CALL	BBLKSKP			; ブランクスキップ

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	AL,ES:[DI]		;
	CMP	AL,"="			;
	JNE	BBDEFINE_8		;
	JMP	BBDEFINE_INTER		;
BBDEFINE_LOOP:
	CALL	BBLKSKP			; ブランクスキップ

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	AL,ES:[DI]		;
	CMP	AL,","			;
	JNE	BBDEFINE_8		;
BBDEFINE_INTER:
	INC	TEXTPOFS		; text offset pointer.
	CALL	BBLKSKP			; ブランクスキップ

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	AL,ES:[DI]		;
	CMP	AL,'"'			;
	JE	BBDEFINE_STR		;
	CMP	AL,"'"			;
	JE	BBDEFINE_STR		;
	JMP	BBDEFINE_VAL		;

BBDEFINE_STR:				;
	CALL	DEF_STRING_GET		; string get.
	MOV	DX,SETUP_STRADRS	; setup string address.
	JMP	BBDEFINE_SET		;

BBDEFINE_VAL:
	CALL	BBVALUE_GET		; 右辺数値取り出し

BBDEFINE_SET:
	MOVX	ES,DS			;
	MOV	DI,SETUP_TOPOFFSET	; user free area offset.
	MOV	ES:[DI],DX		; 取り出し数字(ないときは０)
	ADD	SETUP_TOPOFFSET,2	; user free area offset.

	JMP	BBDEFINE_LOOP		;
BBDEFINE_8:				;

BBDEFINE_EXIT:
	RET
BBDEFINE_ERROR:
	BBERROR	112			; error message.
	RET
BBDEFINE_ERROR_SIZEOVER:
	BBERROR	113			; error message.
	RET
BBDEFINE_ERROR_S_TBLOVER:
	BBERROR	114			; error message.
	RET
BBDEFINE_ERROR_A_TBLOVER:
	BBERROR	115			; error message.
	RET
BBDEFINE	ENDP


; *********************************************************
;	define clear.
; *********************************************************

BBDEFCLEAR	PROC	NEAR
	MOVX	TCHR_SYM_FSIZ,TCHR_SYM_SIZ	; user symbol area size.
	MOVX	TCHR_ADR_FMAX,TCHR_ADR_MAX	; user symbol address max.

	MOVX	TCHR_SYM_FOFST,TCHR_SYM_OFST	; user symbol area offset.
	MOVX	TCHR_ADR_FOFST,TCHR_ADR_OFST	; user symbol adrs offset.

	MOVX	USER_FREE_OFST,USER_FREE_AREA	; user free area.
	MOVX	USER_FREE_FWORD,USER_FREE_WORD	; user area word size.

	MOV	ES,SEGTCHRSEG			; symbol segment.
	MOV	DI,TCHR_SYM_FOFST		; user symbol area offset.
	MOV	WORD PTR ES:[DI],0		; end of table.

	RET
BBDEFCLEAR	ENDP


; *********************************************************
;	string get.
;	-I/O- TEXTPSEG : text segment pointer.
;	      TEXTPOFS : text offset pointer.
;	-O-   SETUP_STRADRS : setup string address.
; *********************************************************

DEF_STRING_GET	PROC	NEAR
	MOV	DI,USERSTRING		; user string.
	CALL	BBCMDSTR		; 文字列の取り出し
	CMP	AX,1			; 0=正常,1=文字列が無い
	JE	DEF_STRING_GET_NONE	;

	MOVX	ES,DS			;
	MOV	DI,USERSTRING		; user string.
	CALL	c_STRLENGTH		; 文字列長さ
	CMP	CX,0			; 表示単語長さ
	JE	DEF_STRING_GET_NONE	;

	MOV	STR_LEN,CX		; string length.

	INC	CX			; +1 (eos)
	SHR	CX,1			; 表示単語長さ
	JNC	DEF_STRING_GET_5	;
	INC	CX			;
DEF_STRING_GET_5:			; word count.
	CMP	CX,USER_FREE_FWORD	; user area free word size.
	JNBE	DEF_STRING_GET_NONE	;

	SUB	USER_FREE_FWORD,CX	; user area free word size.

	MOVX	SETUP_STRADRS,USER_FREE_OFST	; setup string address.

	MOV	DI,USER_FREE_OFST	; user free area offset.
	SHL	CX,1			;
	ADD	USER_FREE_OFST,CX	; user free area offset.
	MOV	SI,USERSTRING		; user string.
	MOV	CX,STR_LEN		; string length.
	INC	CX			;;;;;;;;;;;;;;;;;;;;
	MOVX	ES,DS			;
	CALL	c_STRSETZ		; 文字列バッファセット

DEF_STRING_GET_EXIT:
	RET
DEF_STRING_GET_NONE:
	BBERROR	118			; error message.
	MOV	SETUP_STRADRS,OFFSET DMY ; setup string address.
	RET
DEF_STRING_GET	ENDP


; *********************************************************
;	define allocation.
;	-I-   DEFSYMBOL     : define symbol string.
;	      DEFSYMLEN     : define symbol length.
;	      SETUP_VALUE   : setup value.
;	      SETUP_WORDSIZE: setup word size.
;	-O-   AX            : 0=normal, 1=size over.
;					2=symbol S table over.
;					3=symbol A table over.
;	      SETUP_TOPOFFSET: user free area offset.
; *********************************************************

DEF_ALLOC	PROC	NEAR
	MOVX	SETUP_TOPOFFSET,USER_FREE_OFST	; user free area offset.

	MOV	AX,DEFSYMLEN			; define symbol length.
	INC	AX				; +1
	CMP	AX,TCHR_SYM_FSIZ		; user symbol free area size.
	JNB	DEF_ALLOC_S_TABLE		;

	CMP	TCHR_ADR_FMAX,0			; user symbol free address max.
	JE	DEF_ALLOC_A_TABLE		;

	CMPX	SETUP_WORDSIZE,USER_FREE_FWORD	; setup word size.
	JNBE	DEF_ALLOC_SIZE_OEVR		;

	; (1) symbol set.

	MOV	ES,SEGTCHRSEG			; symbol segment.
	MOV	DI,TCHR_SYM_FOFST		; user symbol area free offset.
	MOV	AX,DEFSYMLEN			; define symbol length.
	STOSB					;
	MOV	SI,DEFSYMBOL			; define symbol string.
	MOV	CX,DEFSYMLEN			; define symbol length.
	REP	MOVSB				;
	MOV	TCHR_SYM_FOFST,DI		; user symbol area free offset.
	MOV	BYTE PTR ES:[DI],0		; end of table.

	MOV	AX,DEFSYMLEN			; define symbol length.
	INC	AX				; +1
	SUB	TCHR_SYM_FSIZ,AX		; user symbol free area size.

	; (2) address set.

	MOV	ES,SEGTCHRADR			; symbol address segment.
	MOV	DI,TCHR_ADR_FOFST		; user symbol adrs free offset.
	MOV	AX,USER_FREE_OFST		; user free area offset.
	STOSW					;
	MOV	AX,SEGUSERAREA			; user area segment.
	STOSW					;
	MOV	TCHR_ADR_FOFST,DI		; user symbol adrs free offset.

	DEC	TCHR_ADR_FMAX			; user symbol free address max.

	; (3) user area set.

	MOV	CX,SETUP_WORDSIZE		; setup word size.
	JCXZ	DEF_ALLOC_EXIT			;

	MOV	ES,SEGUSERAREA			; user area segment.
	MOV	DI,USER_FREE_OFST		; user free area offset.
	MOV	AX,SETUP_VALUE			; setup value.
	REP	STOSW				;

	MOV	AX,SETUP_WORDSIZE		; setup word size.
	SUB	USER_FREE_FWORD,AX		; user area free word size.
	SHL	AX,1				; word -> byte.
	ADD	USER_FREE_OFST,AX		; user free area offset.

DEF_ALLOC_EXIT:
	MOV	AX,0			; 0=normal.
	RET
DEF_ALLOC_SIZE_OEVR:
	MOV	AX,1			; 1=size over.
	RET
DEF_ALLOC_S_TABLE:
	MOV	AX,2			; 2=symbol S table over.
	RET
DEF_ALLOC_A_TABLE:
	MOV	AX,3			; 3=symbol A table over.
	RET
DEF_ALLOC	ENDP


CODE	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SEGTCHRSEG:WORD			; symbol segment.
EXTRN	SEGTCHRADR:WORD			; symbol address segment.
EXTRN	SEGUSERAREA:WORD		; user area segment.

EXTRN	TCHR_SYM_SIZ:WORD		; user symbol area size.
EXTRN	TCHR_SYM_FSIZ:WORD		; user symbol free area size.

EXTRN	TCHR_SYM_OFST:WORD		; user symbol area offset.
EXTRN	TCHR_SYM_FOFST:WORD		; user symbol area free offset.

EXTRN	TCHR_ADR_MAX:WORD		; user symbol address max.
EXTRN	TCHR_ADR_FMAX:WORD		; user symbol free address max.

EXTRN	TCHR_ADR_OFST:WORD		; user symbol adrs offset.
EXTRN	TCHR_ADR_FOFST:WORD		; user symbol adrs free offset.

EXTRN	USER_FREE_AREA:WORD		; user free area.
EXTRN	USER_FREE_OFST:WORD		; user free area offset.

EXTRN	USER_FREE_WORD:WORD		; user area word size.
EXTRN	USER_FREE_FWORD:WORD		; user area free word size.

SETUP_VALUE	DW	0		; setup value.
SETUP_WORDSIZE	DW	0		; setup word size.
SETUP_TOPOFFSET	DW	0		; setup top offset.
SETUP_STRADRS	DW	0		; setup string address.
STR_LEN		DW	0		; string length.

DMY		DB	0,0		; dummy string.

DATA	ENDS

	END
;
;	end of "BBDEFINE.ASM"
;
