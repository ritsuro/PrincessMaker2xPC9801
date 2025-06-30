; "PRNTEXT.ASM" 486/50 make by R.H 1993/02/16
;
;
;	テキスト表示
;
;
; public subroutine.

INCLUDE	TSTSET.INC

CHR_CR		EQU	0DH	; CR
CHR_LF		EQU	0AH	; LF
CHR_TAB		EQU	09H	; TAB

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	PRNTX_PRN		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧ表示
PUBLIC	PRNTX_HI_SET		; ﾃｷｽﾄ高さｾｯﾄ
PUBLIC	PRNTX_TP_SET		; ﾃｷｽﾄﾀｲﾌﾟｾｯﾄ
PUBLIC	PRNTX_LC_SET		; ﾃｷｽﾄ位置ｾｯﾄ

; ****************************************************
;	ﾃｷｽﾄ編集ﾊﾞｯﾌｧ表示
; ****************************************************

PRNTX_PRN	PROC	NEAR
	CALL	TX2PRN			; text print.
	RET
PRNTX_PRN	ENDP


; *********************************************************
;	ﾃｷｽﾄ高さｾｯﾄ
;	-I- AX : character hight.
; *********************************************************

PRNTX_HI_SET	PROC	NEAR
	MOV	CHR_HIGHT,AX		; character hight.
	RET
PRNTX_HI_SET	ENDP


; *********************************************************
;	ﾃｷｽﾄﾀｲﾌﾟｾｯﾄ
;	-I- AX : 0=pset,1=OR,2=fuchi.
; *********************************************************

PRNTX_TP_SET	PROC	NEAR
	MOV	CHR_TYPE,AX		; 0=pset,1=OR,2=fuchi.
	RET
PRNTX_TP_SET	ENDP


; *********************************************************
;	ﾃｷｽﾄ位置ｾｯﾄ
;	-I- AX : start x.
;	    BX : start y.
; *********************************************************

PRNTX_LC_SET	PROC	NEAR
	MOV	STARTXX,AX		; start x.
	MOV	STARTYY,BX		; start y.
	RET
PRNTX_LC_SET	ENDP


; *********************************************************
;	text print.
; *********************************************************

TX2PRN	PROC	NEAR
	MOV	ES,EDTEXTSEG		; edit text buffer segment.
	MOV	DI,EDTEXTOFS		; edit text buffer offset.

	MOVX	STRXX,STARTXX		; start x.
	MOVX	STRYY,STARTYY		; start y.
TX2PRN_LOOP:
	MOV	DX,ES:[DI]		; character code.
	CALL	BBSJISCHK		; シフトＪＩＳチェック
	CMP	AX,1			; 0=normal,1=shift jis code.
	JE	TX2PRN_KANJI		;

	CMP	DL,CHR_CR		; CR
	JE	TX2PRN_LF		;

	CMP	DL,CHR_TAB		; TAB
	JE	TX2PRN_SKIP		;

	CMP	DL,0			;
	JE	TX2PRN_EXIT		;

TX2PRN_ANK:
	MOV	STRBUFF2W,DL		; 2byte string buffer.
	MOV	STRBUFF2W[1],0		;
	MOV	STRWIDE,1		; string wide.
	INC	DI			;
	JMP	TX2PRN_PRINT		;

TX2PRN_KANJI:
	MOV	WORD PTR STRBUFF2W,DX	; 2byte string buffer.
	MOV	STRBUFF2W[2],0		;
	MOV	STRWIDE,2		; string wide.
	ADD	DI,2			;
	JMP	TX2PRN_PRINT		;

TX2PRN_LF:
	MOVX	STRXX,STARTXX		; start x.
	ADDX	STRYY,CHR_HIGHT		; character hight.
	ADD	DI,2			;
	JMP	TX2PRN_NEXT		;
TX2PRN_SKIP:
	INC	DI			;
	JMP	TX2PRN_NEXT		;

TX2PRN_PRINT:
	CALL	PR_STR			; print string.
	ADDX	STRXX,STRWIDE		; string wide.
TX2PRN_NEXT:
	JMP	TX2PRN_LOOP
TX2PRN_EXIT:
	RET
TX2PRN	ENDP


; *********************************************************
;	print string.
; *********************************************************

PR_STR	PROC	NEAR
	PUSH	ES
	PUSH	DI

	MOV	AX,STRXX		; string x.
	MOV	BX,STRYY		; string y.
	MOV	SI,OFFSET STRBUFF2W	; 2byte string buffer.

	CMP	CHR_TYPE,0		; 0=pset.
	JE	PR_STR_00N		;
	CMP	CHR_TYPE,1		; 1=OR.
	JE	PR_STR_01N		;
	CMP	CHR_TYPE,2		; 2=fuchi.
	JE	PR_STR_02N		;
	JMP	PR_STR_EXIT		;

PR_STR_00N:
	CALLE	VTXPRN			; vram text print.
	JMP	PR_STR_EXIT		;
PR_STR_01N:
	CALLE	VTXPOR			; vram text print OR.
	JMP	PR_STR_EXIT		;
PR_STR_02N:
	CALLE	VTXPFC			; vram text print fuchi.
	JMP	PR_STR_EXIT		;

PR_STR_EXIT:
	POP	DI
	POP	ES
	RET
PR_STR	ENDP


; *********************************************************
;	シフトＪＩＳチェック
;	-I- DX : character code.
;	-O- AX : 0=normal,1=shift jis code.
; *********************************************************

BBSJISCHK	PROC	NEAR
	MOV	AX,0
	CMP	DL,081H
	JB	BBSJISCHK_3
	CMP	DL,09FH
	JNBE	BBSJISCHK_3
	MOV	AX,1		; shift jis code.
	RET
BBSJISCHK_3:
	CMP	DL,0E0H
	JB	BBSJISCHK_8
	CMP	DL,0FCH
	JNBE	BBSJISCHK_8
	MOV	AX,1		; shift jis code.
BBSJISCHK_8:
	RET
BBSJISCHK	ENDP


; ****************************************************
;	data.
; ****************************************************

EXTRN	EDTEXTSEG:WORD			; edit text buffer segment.
EXTRN	EDTEXTOFS:WORD			; edit text buffer offset.

CHR_HIGHT	DW	20		; character hight.
CHR_TYPE	DW	0		; 0=pset,1=OR,2=fuchi.

STARTXX		DW	0		; start x.
STARTYY		DW	0		; start y.
STRXX		DW	0		; string x.
STRYY		DW	0		; string y.
STRWIDE		DW	0		; string wide.

STRBUFF2W	DB	0,0,0,0		; 2byte string buffer.

CODE	ENDS
	END
;
;	end of "PRNTEXT.ASM"
;
