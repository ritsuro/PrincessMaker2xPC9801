; "KS2MAIN.ASM" PC-9801UV11 make by R.H 1992/05/06
;
;
;	P R I N C E S S   M A K E R   2.
;
;	main loop.
;
;
; sub program.

INCLUDE	TSTSETC.INC
INCLUDE	DEBUGX.INC

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

PUBLIC	KS2LOOP			; main loop.
PUBLIC	KS2LOOP_REWRITE		; main window rewrite.

; *********************************************************
;	main loop.
; *********************************************************

KS2LOOP	PROC	NEAR
	CALLE	BBLOOP			; main loop.
	RET
KS2LOOP	ENDP


; *********************************************************
;	main window rewrite.
; *********************************************************

KS2LOOP_REWRITE	PROC	NEAR
	RET
KS2LOOP_REWRITE	ENDP



CODE	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'


EXTRN	VX1:WORD		; source point x1.
EXTRN	VY1:WORD		; source point y1.
EXTRN	VX2:WORD		; length x2.
EXTRN	VY2:WORD		; length y2.
EXTRN	VCOL:WORD		; color.

EXTRN	GX1:WORD
EXTRN	GY1:WORD
EXTRN	GX2:WORD
EXTRN	GY2:WORD
EXTRN	GMODE:WORD
EXTRN	GCLR:WORD

DATA	ENDS

	END
;
;	end of "KS2MAIN.ASM"
;
