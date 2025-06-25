; "CONSOLE.ASM" PC-9801UV11 make by R.H 1989/11/04
;
;
;	E X E L O A D    c o n s o l e  I/O.
;
;
;
; public subroutine.

INCLUDE	MACHINEX.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	CCCIN			; console in.
PUBLIC	CCCOUT			; print character.
PUBLIC	CCCRD			; read key buffer.
PUBLIC	CCCLOC			; locate.
PUBLIC	CCCCOL			; text color.
PUBLIC	CCCCLS			; text screen clear.
PUBLIC	CCCCON			; cursole on.
PUBLIC	CCCCOFF			; cursole off.
PUBLIC	CCCINP			; input 1char.

EXTRN	CPCCIN:NEAR		; console in.
EXTRN	CPCCOUT:NEAR		; print character.
EXTRN	CPCCRD:NEAR		; read key buffer.
EXTRN	CPCCLOC:NEAR		; locate.
EXTRN	CPCCCOL:NEAR		; text color.

EXTRN	C98CIN:NEAR		; console in.
EXTRN	C98COUT:NEAR		; print character.
EXTRN	C98CRD:NEAR		; read key buffer.
EXTRN	C98CLOC:NEAR		; locate.
EXTRN	C98CCOL:NEAR		; text color.


;	console in.

CCCIN	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	CCCIN_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	CCCIN_PC98		;
	RET
CCCIN_PCAT:
	CALL	CPCCIN			; console in.
	RET
CCCIN_PC98:
	CALL	C98CIN			; console in.
	RET
CCCIN	ENDP

;	print character.

CCCOUT	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	CCCOUT_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	CCCOUT_PC98		;
	RET
CCCOUT_PCAT:
	CALL	CPCCOUT			; print character.
	RET
CCCOUT_PC98:
	CALL	C98COUT			; print character.
	RET
CCCOUT	ENDP

;	read key buffer.

CCCRD	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	CCCRD_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	CCCRD_PC98		;
	RET
CCCRD_PCAT:
	CALL	CPCCRD			; read key buffer.
	RET
CCCRD_PC98:
	CALL	C98CRD			; read key buffer.
	RET
CCCRD	ENDP

;	locate.

CCCLOC	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	CCCLOC_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	CCCLOC_PC98		;
	RET
CCCLOC_PCAT:
	CALL	CPCCLOC			; locate.
	RET
CCCLOC_PC98:
	CALL	C98CLOC			; locate.
	RET
CCCLOC	ENDP


;	text color.

CCCCOL	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	CCCCOL_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	CCCCOL_PC98		;
	RET
CCCCOL_PCAT:
	CALL	CPCCCOL			; text color.
	RET
CCCCOL_PC98:
	CALL	C98CCOL			; text color.
	RET
CCCCOL	ENDP


;	text screen clear.

CCCCLS	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	CCCCLS_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	CCCCLS_PC98		;
	RET
CCCCLS_PCAT:
	PUSH	AX
	PUSH	DX

	MOV	CH,0		; up line.
	MOV	CL,0		; left side.
	MOV	DH,24		; under line.
	MOV	DL,79		; right side.
	;MOV	BH,00001111B	; attrbute.
	MOV	BH,00000000B	; attrbute.
	MOV	AL,0		; 1 line.
	MOV	AH,06H		; window scroll up.
	INT	10H		; IBM bios.

	MOV	AX,0		; x
	MOV	BX,0		; y
	CALL	CCCLOC		; locate.

	MOV	DL,' '		; ascii code
	CALL	CPCCOUT		; print character.

	MOV	AX,0		; x
	MOV	BX,0		; y
	CALL	CCCLOC		; locate.

	POP	DX
	POP	AX
	RET
CCCCLS_PC98:
	PUSH	AX
	PUSH	DX

	MOV	AH,16H
	MOV	DH,0E1H	; attribute.
	MOV	DL,20H	; text.
	INT	18H

	MOV	AX,0		; x
	MOV	BX,0		; y
	CALL	CCCLOC		; locate.

	POP	DX
	POP	AX
	RET
CCCCLS	ENDP


;	cursole on.

CCCCON	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	CCCCON_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	CCCCON_PC98		;
	RET
CCCCON_PCAT:
	PUSH	AX
		;  FEDCBA9876543210.
	MOV	CX,0100000000001111B
	MOV	AH,01H		; cursole type set.
	INT	10H		; IBM bios.
	POP	AX
	RET
CCCCON_PC98:
	PUSH	AX
	MOV	AH,11H
	INT	18H
	POP	AX
	RET
CCCCON	ENDP


;	cursole off.

CCCCOFF	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	CCCCOFF_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	CCCCOFF_PC98		;
	RET
CCCCOFF_PCAT:
	PUSH	AX
		;  FEDCBA9876543210.
	MOV	CX,0010000000000000B
	MOV	AH,01H		; cursole type set.
	INT	10H		; IBM bios.
	POP	AX
	RET
CCCCOFF_PC98:
	PUSH	AX
	MOV	AH,12H
	INT	18H
	POP	AX
	RET
CCCCOFF	ENDP


;	input 1char.

CCCINP	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	CCCINP_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	CCCINP_PC98		;
	RET
CCCINP_PCAT:
	PUSH	AX
	MOV	AH,00H		; char read.
	INT	16H		; IBM bios.
	MOV	DL,AL
	MOV	DH,0
	POP	AX
	RET
CCCINP_PC98:
	PUSH	AX
	MOV	AH,0		; key data read.
	INT	18H
	MOV	DL,AL
	MOV	DH,0
	POP	AX
	RET
CCCINP	ENDP


CODE01	ENDS



DATA	SEGMENT	PUBLIC	'DATA'
DATA	ENDS

	END
;
;	end of "CONSOLE.ASM"
;
