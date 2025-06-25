; "GETFONT.ASM" PS55Z/J14 make by R.H 1991/07/01
;
;
;	get text font.
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	C1GETFONT		; get text font.
PUBLIC	C1GETFONTZ		; get zenkaku text font.


;	get text font.
;	-I- DX : shift JIS character code.
;	    ES : patturn buffer segment.
;	    DI : pattern buffer offset.

C1GETFONT	PROC	NEAR
	MOV	SHTJISCODE,DX		; shift JIS character code.

	MOV	BUFSEG,ES		; patturn buffer segment.
	MOV	BUFOFS,DI		; pattern buffer offset.

	MOV	DATSTYLE,0		; data style 0=8x16,1=16x16
	CALL	DOSVFGET		; DOS/V font get.
	RET
C1GETFONT	ENDP


;	get zenkaku text font.
;	-I- DX : shift JIS character code.
;	    ES : patturn buffer segment.
;	    DI : pattern buffer offset.

C1GETFONTZ	PROC	NEAR
	MOV	SHTJISCODE,DX		; shift JIS character code.

	MOV	BUFSEG,ES		; patturn buffer segment.
	MOV	BUFOFS,DI		; pattern buffer offset.

	MOV	DATSTYLE,1		; data style 0=8x16,1=16x16
	CALL	DOSVFGET		; DOS/V font get.
	RET
C1GETFONTZ	ENDP


;	DOS/V font get.
;	-I- SHTJISCODE: shift JIS character code.
;	    DATSTYLE : data style 0=8x16,1=16x16
;	    BUFSEG   : patturn buffer segment.
;	    BUFOFS   : pattern buffer offset.
;	-O- AX       : 0=normal,1=error.

DOSVFGET	PROC	NEAR
	CMP	DATSTYLE,1		; data style 0=8x16,1=16x16
	JE	DOSVFGET_16WD		;

DOSVFGET_8WD:
	MOV	BH,BYTE PTR DATSTYLE	; data style 0=8x16,1=16x16
	MOV	DH,8			; wide.
	MOV	DL,16			; hight.
	JMP	DOSVFGET_SET
DOSVFGET_16WD:
	MOV	BH,BYTE PTR DATSTYLE	; data style 0=8x16,1=16x16
	MOV	DH,16			; wide.
	MOV	DL,16			; hight.
DOSVFGET_SET:
	MOV	BL,0			; reseave.
	MOV	BP,0			; code page.
	MOV	AX,5000H		; font read.
	INT	15H			; system service i/o.
	JC	DOSVFGET_ERROR		;

	MOV	READ_DBCS_FONT_OFS,BX	; function offset.
	MOV	READ_DBCS_FONT_SEG,ES	; function segment.

	MOV	CX,SHTJISCODE		; shift JIS character code.

	MOV	ES,BUFSEG		; patturn buffer segment.
	MOV	SI,BUFOFS		; pattern buffer offset.
	CALL	DWORD PTR READ_DBCS_FONT	; function address.

	RET
DOSVFGET_ERROR:
;*;CODE_IN
;*;	LC	40,26
;*;	PRVH	"ERROR:",AX
;*;CODE_OUT
	RET
DOSVFGET	ENDP



CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

SHTJISCODE		DW	0	; shift JIS character code.
DATSTYLE		DW	0	; data style 0=8x16,1=16x16

BUFSEG			DW	0	; patturn buffer segment.
BUFOFS			DW	0	; pattern buffer offset.

READ_DBCS_FONT		LABEL	DWORD	; function address.
READ_DBCS_FONT_OFS	DW	0	; function offset.
READ_DBCS_FONT_SEG	DW	0	; function segment.

DATA	ENDS

	END
;
;	end of "GETFONT.ASM"
;
