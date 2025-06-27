; "ICON.ASM" 486/50 make by R.H 1992/05/22
;
;
;	ICON.
;
;	ICON01   PT1      4566 92-09-09    1:45
;	ICON16   PT1      8994 92-09-09    1:45
;	ICON39   PT1      1536 92-09-09    1:45
;	ICON43   PT1      4800 92-09-09    1:45
;	ICON54   PT1      4900 92-09-09    1:45
;	ICON64   PT1      6826 92-09-09    1:45
;	ICON78   PT1      3036 92-09-09    1:45
;	ICON84   PT1      1674 92-09-09    1:45
;	ICON88   PT1      4176 92-09-09    1:45
;
; sub program.

INCLUDE	TSTSET.INC

PATBANK_ICON88	EQU	100		; ICON88 pattan bank number.
PATBANK_ICON	EQU	102		; ICON pattan bank number.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	ICON_PUT		; ICON put.


;	ICON put.
;	-I- DX : ICON number.
;	    AX : put x.
;	    BX : put y.

ICON_PUT	PROC	NEAR
	MOV	NUM1,DX			; ICON number.
	MOV	XX1,AX			; put x.
	MOV	YY1,BX			; put y.

	CMP	NUM1,0			; ICON number.
	JE	ICON_PUT_EXIT

	CMP	NUM1,98			; ICON number.98=武者修行・西
	JB	ICON_PUT_ICON_5		;

	SUB	NUM1,98-88		; ICON number.
	JMP	ICON_PUT_ICON_LD	;

ICON_PUT_ICON_5:			;
	CMP	NUM1,88			; ICON number.88=太陽
	JNB	ICON_PUT_ICON88		;

ICON_PUT_ICON_LD:			;
	CALLE	CHILD_PROCESS_ICON	; (*.com) child process ICON set.

	MOV	DX,PATBANK_ICON		; ICON pattan bank number.
	CALLE	C1PATBNK		; バンクチェンジ

	MOVX	VRX,XX1			; x point.
	MOVX	VRY,YY1			; y point.
	MOV	CX,NUM1			; パーツ番号
	DEC	CX			; -1
	CALLE	C1PATPTX		; パーツＰＵＴ座標指定
	JMP	ICON_PUT_EXIT		;

ICON_PUT_ICON88:			;
	MOV	DX,PATBANK_ICON88	; ICON88 pattan bank number.
	CALLE	C1PATBNK		; バンクチェンジ

	MOVX	VRX,XX1			; x point.
	MOVX	VRY,YY1			; y point.
	MOV	CX,NUM1			; パーツ番号
	SUB	CX,88			; - 88
	CALLE	C1PATPTX		; パーツＰＵＴ座標指定
ICON_PUT_EXIT:
	RET
ICON_PUT	ENDP

CODE01	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	VRX:WORD		; x point.
EXTRN	VRY:WORD		; y point.
EXTRN	VRLENX:WORD		; x length.
EXTRN	VRLENY:WORD		; y length.

XX1		DW	0		; ＰＵＴＸ座標
YY1		DW	0		; ＰＵＴＹ座標
NUM1		DW	0		;

DATA	ENDS

	END
;
;	end of "ICON.ASM"
;
