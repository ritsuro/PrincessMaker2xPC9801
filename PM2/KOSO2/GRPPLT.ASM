; "GRPPLT.ASM" 486/33 make by R.H 1992/04/09
;
;
;	palet set subroutines.
;
;
; subroutine.

INCLUDE	MACHINEX.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	C1SETCLR		; color table set.
PUBLIC	C1CLRVSET		; color palet table disply.

EXTRN	VGASETCLR:NEAR		; color set.
EXTRN	VGACLRVSET:NEAR		; color palet table disply.

EXTRN	V98SETCLR:NEAR		; color table set.


;	color table set.
;	-i- CLRCDE : color code.
;	    CLRVEW : color.
;	    CLRCNS : contrast.
;	    CLRBRI : brightness.

C1SETCLR	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	C1SETCLR_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	C1SETCLR_PC98		;
	RET
C1SETCLR_PCAT:
	CALL	VGASETCLR		; color set.
	RET
C1SETCLR_PC98:
	CALL	V98SETCLR		; color table set.
	RET
C1SETCLR	ENDP


;	color palet table disply.

C1CLRVSET	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	C1CLRVSET_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	C1CLRVSET_PC98		;
	RET
C1CLRVSET_PCAT:
	CALL	VGACLRVSET		; color palet table disply.
	RET
C1CLRVSET_PC98:
	RET
C1CLRVSET	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'
DATA	ENDS

	END
;
;	end of "GRPPLT.ASM"
;
