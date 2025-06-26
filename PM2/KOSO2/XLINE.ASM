; "XLINE.ASM" 486/50 make by R.H 1992/07/05
;
;
;	line.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA


PUBLIC	XLINE			; line.

EXTRN	XLINEMASK:NEAR		; MASK line.
EXTRN	XLINEOR:NEAR		; OR line.
EXTRN	XLINEVGA:NEAR		; VGA line.

EXTRN	C1VV_BANK_XCG_ES:NEAR	; vram bank check & chenge.(READ/WRITE) ES
EXTRN	C1VV_BANK_CHK:NEAR	; vram bank check. DX
EXTRN	C1VV_MODE_PIXEL:NEAR	; vram pixel set mode.
EXTRN	C1VV_MODE_PIXEL_STOP:NEAR ; vram pixel set mode stop.


;	line.
;	-I- VX1,VY1 : start point.
;	    VX2,VY2 : end point.
;	    VCOL    : color.

XLINE	PROC	NEAR
	MOV	DX,SSDES0		; ES=visual data segment plean 0
	CALL	C1VV_BANK_CHK		; vram bank check. DX
	CMP	AX,0			; 0=normal,1=video memory.
	JE	XLINE_NORMAL		;
	MOV	ES,DX			; visual data segment plean 0
	MOV	DX,VCOL			; pixel color.
	CALL	C1VV_MODE_PIXEL		; vram pixel set mode.
	CALL	XLINEVGA		; VGA line.
	CALL	C1VV_MODE_PIXEL_STOP	; vram pixel set mode stop.
	RET

XLINE_NORMAL:
	MOV	ES,SSDES0		; ES=visual data segment plean 0
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.(READ/WRITE) ES

	TEST	VCOL,0001B		; color.
	JZ	XLINE_1			;
	CALL	XLINEOR			; OR line.
	JMP	XLINE_12		;
XLINE_1:				;
	CALL	XLINEMASK		; MASK line.
XLINE_12:				;
	MOV	ES,SSDES1		; ES=visual data segment plean 1
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.(READ/WRITE) ES

	TEST	VCOL,0010B		; color.
	JZ	XLINE_2			;
	CALL	XLINEOR			; OR line.
	JMP	XLINE_22		;
XLINE_2:				;
	CALL	XLINEMASK		; MASK line.
XLINE_22:				;
	MOV	ES,SSDES2		; ES=visual data segment plean 2
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.(READ/WRITE) ES

	TEST	VCOL,0100B		; color.
	JZ	XLINE_3			;
	CALL	XLINEOR			; OR line.
	JMP	XLINE_32		;
XLINE_3:				;
	CALL	XLINEMASK		; MASK line.
XLINE_32:				;

	MOV	ES,SSDES3		; ES=visual data segment plean 3
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.(READ/WRITE) ES

	TEST	VCOL,1000B		; color.
	JZ	XLINE_4			;
	CALL	XLINEOR			; OR line.
	JMP	XLINE_42		;
XLINE_4:				;
	CALL	XLINEMASK		; MASK line.
XLINE_42:				;

	RET
XLINE	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SSDES0:WORD		; visual data segment plean 0
EXTRN	SSDES1:WORD		; visual data segment plean 1
EXTRN	SSDES2:WORD		; visual data segment plean 2
EXTRN	SSDES3:WORD		; visual data segment plean 3
EXTRN	SSDESW:WORD		; visual data plean width.

EXTRN	VX1:WORD		; source point x1.
EXTRN	VY1:WORD		; source point y1.
EXTRN	VX2:WORD		; length x2.
EXTRN	VY2:WORD		; length y2.
EXTRN	VCOL:WORD		; color.

DATA	ENDS

	END
;
;	end of "XLINE.ASM"
;
