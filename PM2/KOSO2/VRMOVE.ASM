; "VRMOVE.ASM" 1989/3/21 PC-9801UV11 make by R.H 1989
;		modify 1991/11/15
;		rename 1992/05/15 "ADVMOV.ASM" -> "VRMOVE.ASM"
;
;	
;
;
; public subroutine.

;
;	SSDES0			; visual data segment plean 0
;	SSDES1			; visual data segment plean 1
;	SSDES2			; visual data segment plean 2
;	SSDES3			; visual data segment plean 3
;	SSDESW			; visual data plean width.
;
;	SSSOU0			; visual data segment plean 0
;	SSSOU1			; visual data segment plean 1
;	SSSOU2			; visual data segment plean 2
;	SSSOU3			; visual data segment plean 3
;	SSSOUW			; visual data plean width.
;
;	VX1:WORD		; source point x1.
;	VY1:WORD		; source point y1.
;	VX2:WORD		; length x2.
;	VY2:WORD		; length y2.
;	VX3:WORD		; destination point x3.
;	VY3:WORD		; destination point y3.
;

INCLUDE	TSTSET.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	MOVEVR		; vram to vram move.
PUBLIC	MOV1VR		; vram to vram move 1 plean.

EXTRN	C1VV_BANK_CHG_ES:NEAR	; vram bank check & chenge.(WRITE) ES
EXTRN	C1VV_BANK_PLN_DS:NEAR	; vram bank check & chenge.(READ) DS

;	vram to vram move.
;	-i- SSSOU0-3,W : source data segment.
;	    SSDES0-3,W : destination data segment.
;	    VX1,VY1  : source point.
;	    VX2,VY2  : data size.
;	    VX3,VY3  : dest point.

MOVEVR	PROC	NEAR
	CMP	WORD PTR VX2,0	;
	JZ	MOVEVR99	; if vx2=0 or vy2=0 then exit.
	CMP	WORD PTR VY2,0	;
	JZ	MOVEVR99	;
	JMP	MOVEVR00	;
MOVEVR99:			;
	RET			;
MOVEVR00:
	MOV	AX,VY1		; source point.
	MOV	CX,SSSOUW	; visual data plean width.
	MUL	CX		;
	MOV	BX,AX		; bx = vy1 * 80 + vx1
	ADD	BX,VX1		; source point.

	MOV	AX,VY3		; destination point.
	MOV	CX,SSDESW	; visual data plean width.
	MUL	CX		;
	MOV	DX,AX		; dx = vy3 * 80 + vx3
	ADD	DX,VX3		; dest point.

	MOV	AX,VX2		; x counter.
	MOV	BP,VY2		; y counter.
MOVEVR1:
	PUSH	DS

	PUSH	SSSOU3		; visual data segment plean 3
	PUSH	SSDES3		; visual data segment plean 3
	PUSH	SSSOU2		; visual data segment plean 2
	PUSH	SSDES2		; visual data segment plean 2
	PUSH	SSSOU1		; visual data segment plean 1
	PUSH	SSDES1		; visual data segment plean 1
	PUSH	SSSOU0		; visual data segment plean 0
	PUSH	SSDES0		; visual data segment plean 0

	POP	ES		; dest.		0.
	POP	DS		; source.	0.

	CALL	C1VV_BANK_CHG_ES ; vram bank check & chenge.(WRITE) ES
	CALL	C1VV_BANK_PLN_DS ; vram bank check & chenge.(READ) DS

	MOV	SI,BX		; source.
	MOV	DI,DX		; dest.
	MOV	CX,AX		; x counter.
	REP	MOVSB		; moving!

	POP	ES		; dest.		1.
	POP	DS		; source.	1.

	CALL	C1VV_BANK_CHG_ES ; vram bank check & chenge.(WRITE) ES
	CALL	C1VV_BANK_PLN_DS ; vram bank check & chenge.(READ) DS

	MOV	SI,BX		; source.
	MOV	DI,DX		; dest.
	MOV	CX,AX		; x counter.
	REP	MOVSB		; moving!

	POP	ES		; dest.		2.
	POP	DS		; source.	2.

	CALL	C1VV_BANK_CHG_ES ; vram bank check & chenge.(WRITE) ES
	CALL	C1VV_BANK_PLN_DS ; vram bank check & chenge.(READ) DS

	MOV	SI,BX		; source.
	MOV	DI,DX		; dest.
	MOV	CX,AX		; x counter.
	REP	MOVSB		; moving!

	POP	ES		; dest.		3.
	POP	DS		; source.	3.

	CALL	C1VV_BANK_CHG_ES ; vram bank check & chenge.(WRITE) ES
	CALL	C1VV_BANK_PLN_DS ; vram bank check & chenge.(READ) DS

	MOV	SI,BX		; source.
	MOV	DI,DX		; dest.
	MOV	CX,AX		; x counter.
	REP	MOVSB		; moving!

	POP	DS		;

	ADD	BX,SSSOUW	; visual data plean width.
	ADD	DX,SSDESW	; visual data plean width.

	DEC	BP		;
	JNZ	MOVEVR1		; loop next.

	RET
MOVEVR	ENDP


;	vram to vram move 1 plean.
;	-i- DX       : source data segment.
;	    ES       : destination data segment.
;	    SSSOUW   : visual data plean width.
;	    SSDESW   : visual data plean width.
;	    VX1,VY1  : source point.
;	    VX2,VY2  : data size.
;	    VX3,VY3  : dest point.

MOV1VR	PROC	NEAR
;*;PRV "DX=",DX
;*;PRV "ES=",ES
;*;PRV "SSSOUW=",SSSOUW
;*;PRV "SSDESW=",SSDESW
;*;PRV "VX1=",VX1
;*;PRV "VY1=",VY1
;*;PRV "VX2=",VX2
;*;PRV "VY2=",VY2
;*;PRV "VX3=",VX3
;*;PRV "VY3=",VY3
	CMP	WORD PTR VX2,0	;
	JZ	MOV1VR99	; if vx2=0 or vy2=0 then exit.
	CMP	WORD PTR VY2,0	;
	JZ	MOV1VR99	;
	JMP	MOV1VR00	;
MOV1VR99:			;
	RET			;
MOV1VR00:
	PUSH	DS		;

	PUSH	SSSOUW		; visual data plean width.
	PUSH	SSDESW		; visual data plean width.
	PUSH	DX		; source data segment.

	MOV	AX,VY1		; source point.
	MOV	CX,SSSOUW	; visual data plean width.
	MUL	CX		;
	MOV	BX,AX		; bx = vy1 * 80 + vx1
	ADD	BX,VX1		; source point.

	MOV	AX,VY3		; destination point.
	MOV	CX,SSDESW	; visual data plean width.
	MUL	CX		;
	MOV	DX,AX		; dx = vy3 * 80 + vx3
	ADD	DX,VX3		; dest point.

	MOV	AX,VX2		; x counter.
	MOV	BP,VY2		; y counter.

	POP	DS		; source data segment.

	CALL	C1VV_BANK_CHG_ES ; vram bank check & chenge.(WRITE) ES
	CALL	C1VV_BANK_PLN_DS ; vram bank check & chenge.(READ) DS
MOV1VR1:
	MOV	SI,BX		; source.
	MOV	DI,DX		; dest.
	MOV	CX,AX		; x counter.
	REP	MOVSB		; moving!

	POP	DI		;
	POP	SI		;
	ADD	BX,SI		; visual data plean width.
	ADD	DX,DI		; visual data plean width.
	PUSH	SI		; visual data plean width.
	PUSH	DI		; visual data plean width.

	DEC	BP		;
	JNZ	MOV1VR1		; loop next.

	POP	AX
	POP	AX

	POP	DS
	RET
MOV1VR	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SSDES0:WORD		; visual data segment plean 0
EXTRN	SSDES1:WORD		; visual data segment plean 1
EXTRN	SSDES2:WORD		; visual data segment plean 2
EXTRN	SSDES3:WORD		; visual data segment plean 3
EXTRN	SSDESW:WORD		; visual data plean width.

EXTRN	SSSOU0:WORD		; visual data segment plean 0
EXTRN	SSSOU1:WORD		; visual data segment plean 1
EXTRN	SSSOU2:WORD		; visual data segment plean 2
EXTRN	SSSOU3:WORD		; visual data segment plean 3
EXTRN	SSSOUW:WORD		; visual data plean width.

EXTRN	VX1:WORD		; source point x1.
EXTRN	VY1:WORD		; source point y1.
EXTRN	VX2:WORD		; length x2.
EXTRN	VY2:WORD		; length y2.
EXTRN	VX3:WORD		; destination point x3.
EXTRN	VY3:WORD		; destination point y3.

DATA	ENDS

	END
;
;	end of "VRMOVE.ASM"
;
