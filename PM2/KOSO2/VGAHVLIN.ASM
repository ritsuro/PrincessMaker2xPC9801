; "VGAHVLINE.ASM" 1990/04/18 PC-9801UV11 make by R.H
;		modify PS/55Z  1991/06/25
;		modify 486/33  1992/05/08
;
;
;	ècâ°ÉâÉCÉìï`âÊ
;
;
;	SSDES0			; visual data segment plean 0
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'
	
	ASSUME	CS:CODE01,DS:DATA

PUBLIC	VGADLINEH		; êÖïΩÉâÉCÉìï`âÊ
PUBLIC	VGADLINEHBT		; êÖïΩÉâÉCÉìï`âÊì_ê¸
PUBLIC	VGADLINEV		; êÇíºÉâÉCÉìï`âÊ

EXTRN	C1VV_BANK_CHG_ES:NEAR	; vram bank check & chenge.(WRITE) ES
EXTRN	C1VV_MODE_PSET:NEAR	; vram put mode PSET.
EXTRN	C1VV_MODE_AND:NEAR	; vram put mode AND.
EXTRN	C1VV_MODE_OR:NEAR	; vram put mode OR.
EXTRN	C1VV_PLEAN_SLCT:NEAR	; plean select.


;	êÖïΩÉâÉCÉìï`âÊ
;	-I- VX1 : start dot point x1.
;	    VX2 : end dot point x2.
;	    VY1 : line hight y1.
;	    CX  : line width.
;	    VCOL: color.

VGADLINEH	PROC	NEAR
	CMP	CX,0			;
	JG	DLINEH0			;
	RET				;
DLINEH0:
	MOV	AX,VY1			; line hight y1.
	MOV	BX,SSDESW		; visual data plean width.
	MUL	BX			;
	MOV	DI,AX			; DI = VY1 * vram width.

	MOV	BX,VX1			; start line point X1.
	MOV	DX,VX2			; end line point X2.

	CMP	BX,DX			;
	JB	DLINEH1			; BX=start point X.
	XCHG	BX,DX			; DX=end point X.
DLINEH1:				;

	PUSH	CX			; CX=line width.

	MOV	CX,BX			; start point.
	AND	CX,111B			; bit shift.(dot point)
	MOV	AL,0FFH			; line start pattan.
	SHR	AL,CL			; AL=start dot shift.

	MOV	AH,0			; line end pattan.
	MOV	CX,DX			; end point.
	AND	CX,111B			; bit shift.(dot point)
;*;	JZ	DLINEH2			;
	MOV	AH,080H			; line end pattan.
	SAR	AH,CL			; AH=end dot shift.
DLINEH2:
	MOV	CX,DX			; DX=end point X.
	SHR	CX,1			;
	SHR	CX,1			;
	SHR	CX,1			; CX=end point X byte.
	MOV	BP,BX			; BX=start point X.
	SHR	BP,1			;
	SHR	BP,1			;
	SHR	BP,1			; BP=start point X byte.
	CMP	CX,BP			;
	JNE	DLINEH4			; goto draw line!

					; AL=start pattan.
	AND	AL,AH			; AH=end pattan.
					; AL=put pattan.
	ADD	DI,BP			; DI = start address.

	POP	CX			; CX=line width.
DLINEH3:				;
	CALL	DHLINEH_DOT		; h-line dor put.
	RET				;

DLINEH4:				;
	ADD	DI,BP			; DI = start address.
	MOV	SI,DI			; save offset.

	SUB	CX,BP			; BP=line length.
	MOV	BP,CX			;

	POP	CX			; CX=line width.
	PUSH	CX			;
	CALL	DHLINEH_DOT		; h-line dor put.

	POP	CX			; CX=line width.
	PUSH	CX			;
	MOV	AL,AH			; AL=AH=end pattan.
	MOV	DI,SI			; load offset.
	ADD	DI,BP			; BP=end point X byte.
	CALL	DHLINEH_DOT		; h-line dor put.

	POP	CX			; CX=line width.
	INC	SI			;
	MOV	DI,SI			; load offset.
	DEC	BP			;
	CALL	DLINEH1LINE		; line pattan put.

	RET
VGADLINEH	ENDP


;	êÖïΩÉâÉCÉìï`âÊì_ê¸
;	-I- VX1 : start dot point x1.
;	    VX2 : end dot point x2.
;	    VY1 : line hight y1.
;	    CX  : line width.
;	    VCOL: color.
;	    AL  : line bit pattern.

VGADLINEHBT	PROC	NEAR
	CMP	CX,0			;
	JG	DLINEHBT0		;
	RET				;
DLINEHBT0:
	MOV	H_BIT_PTN,AL		; h-line bit pattern.

	MOV	AX,VY1			; line hight y1.
	MOV	BX,SSDESW		; visual data plean width.
	MUL	BX			;
	MOV	DI,AX			; DI = VY1 * vram width.

	MOV	BX,VX1			; start line point X1.
	MOV	DX,VX2			; end line point X2.

	CMP	BX,DX			;
	JB	DLINEHBT1		; BX=start point X.
	XCHG	BX,DX			; DX=end point X.
DLINEHBT1:				;

	PUSH	CX			; CX=line width.

	MOV	CX,BX			; start point.
	AND	CX,111B			; bit shift.(dot point)
	MOV	AL,0FFH			; line start pattan.
	SHR	AL,CL			; AL=start dot shift.

	MOV	AH,0			; line end pattan.
	MOV	CX,DX			; end point.
	AND	CX,111B			; bit shift.(dot point)
;*;	JZ	DLINEHBT2		;
	MOV	AH,080H			; line end pattan.
	SAR	AH,CL			; AH=end dot shift.
DLINEHBT2:
	MOV	CX,DX			; DX=end point X.
	SHR	CX,1			;
	SHR	CX,1			;
	SHR	CX,1			; CX=end point X byte.
	MOV	BP,BX			; BX=start point X.
	SHR	BP,1			;
	SHR	BP,1			;
	SHR	BP,1			; BP=start point X byte.
	CMP	CX,BP			;
	JNE	DLINEHBT4		; goto draw line!

					; AL=start pattan.
	AND	AL,AH			; AH=end pattan.
					; AL=put pattan.
	ADD	DI,BP			; DI = start address.

	POP	CX			; CX=line width.
DLINEHBT3:				;
	MOV	AH,H_BIT_PTN		; h-line bit pattern.
	MOV	BIT_PTN,AH		; bit pattern.
	CALL	DHLINEH_DOTX		; h-line dor put.(bit pattern)
	RET				;

DLINEHBT4:				;
	ADD	DI,BP			; DI = start address.
	MOV	SI,DI			; save offset.

	SUB	CX,BP			; BP=line length.
	MOV	BP,CX			;

	POP	CX			; CX=line width.
	PUSH	CX			;
	MOV	BL,H_BIT_PTN		; h-line bit pattern.
	MOV	BIT_PTN,BL		; bit pattern.
	CALL	DHLINEH_DOTX		; h-line dor put.(bit pattern)

	POP	CX			; CX=line width.
	PUSH	CX			;
	MOV	AL,AH			; AL=AH=end pattan.
	MOV	DI,SI			; load offset.
	ADD	DI,BP			; BP=end point X byte.
	MOV	AH,H_BIT_PTN		; h-line bit pattern.
	MOV	BIT_PTN,AH		; bit pattern.
	CALL	DHLINEH_DOTX		; h-line dor put.(bit pattern)

	POP	CX			; CX=line width.
	INC	SI			;
	MOV	DI,SI			; load offset.
	DEC	BP			;

	MOV	BL,H_BIT_PTN		; h-line bit pattern.
	MOV	BIT_PTN,BL		; bit pattern.
	CALL	DLINEH1LINEX		; line pattan put.(bit pattern)

	RET
VGADLINEHBT	ENDP


;	h-line dor put.
;	-I- VCOL  : color.
;	    SSDES0: visual data segment plean 0
;	    DI    : start address.
;	    CX    : line width.
;	    AL    : put pattan.

DHLINEH_DOT	PROC	NEAR
	PUSH	AX

	MOV	ES,SSDES0		; ES=visual data segment plean 0
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES

	MOV	DX,1111B		;
	CALL	C1VV_PLEAN_SLCT		; plean select.

	PUSH	AX

	CALL	C1VV_MODE_AND		; vram put mode AND.
	NOT	AL			; mask pattan.
	PUSH	DI			;
	PUSH	CX			;
	MOV	DX,SSDESW		; visual data plean width.
DLINEH412:				;
	MOV	AH,ES:[DI]		; rach.
	MOV	ES:[DI],AL		; pattan AND.
	ADD	DI,DX			; visual data plean width.
	LOOP	DLINEH412		;
	POP	CX			;
	POP	DI			;

	MOV	DX,VCOL			; DX=color.
	CALL	C1VV_PLEAN_SLCT		; plean select.

	POP	AX

	CALL	C1VV_MODE_OR		; vram put mode OR.
	MOV	DX,SSDESW		; visual data plean width.
DLINEH413:				;
	MOV	AH,ES:[DI]		; rach.
	MOV	ES:[DI],AL		; pattan OR.
	ADD	DI,DX			; visual data plean width.
	LOOP	DLINEH413		;

	CALL	C1VV_MODE_PSET		; vram put mode PSET.

	POP	AX
	RET
DHLINEH_DOT	ENDP


;	h-line dor put.(bit pattern)
;	-I- VCOL  : color.
;	    BIT_PTN : bit pattern.
;	    SSDES0: visual data segment plean 0
;	    DI    : start address.
;	    CX    : line width.
;	    AL    : put pattan.

DHLINEH_DOTX	PROC	NEAR
	PUSH	AX

	MOV	ES,SSDES0		; ES=visual data segment plean 0
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES

	MOV	DX,1111B		;
	CALL	C1VV_PLEAN_SLCT		; plean select.

	PUSH	AX

	CALL	C1VV_MODE_AND		; vram put mode AND.
	MOV	BL,AL			;
	MOV	BH,BIT_PTN		; bit pattern.
	NOT	BL			; mask pattan.
	NOT	BH			;
	PUSH	DI			;
	PUSH	CX			;
	MOV	DX,SSDESW		; visual data plean width.
DHLINEH_DOTX_412:			;
	MOV	AL,BL			;
	OR	AL,BH			;
	ROR	BH,1			;
	MOV	AH,ES:[DI]		; rach.
	MOV	ES:[DI],AL		; pattan AND.
	ADD	DI,DX			; visual data plean width.
	LOOP	DHLINEH_DOTX_412	;
	POP	CX			;
	POP	DI			;

	MOV	DX,VCOL			; DX=color.
	CALL	C1VV_PLEAN_SLCT		; plean select.

	POP	AX

	MOV	BL,AL			;
	MOV	BH,BIT_PTN		; bit pattern.

	CALL	C1VV_MODE_OR		; vram put mode OR.
	MOV	DX,SSDESW		; visual data plean width.
DHLINEH_DOTX_413:			;
	MOV	AL,BL			;
	AND	AL,BH			;
	ROR	BH,1			;
	MOV	AH,ES:[DI]		; rach.
	MOV	ES:[DI],AL		; pattan OR.
	ADD	DI,DX			; visual data plean width.
	LOOP	DHLINEH_DOTX_413	;

	CALL	C1VV_MODE_PSET		; vram put mode PSET.

	POP	AX
	RET
DHLINEH_DOTX	ENDP


;	line pattan put.
;	-i-   VCOL    : color.
;	      SSDES0: visual data segment plean 0
;	      DI : start address
;	      CX : line width.
;	      BP : line byte length.

DLINEH1LINE	PROC	NEAR
	CMP	BP,0			; line byte length.
	JNE	DLINEH1LINE_START	;
	RET
DLINEH1LINE_START:

	MOV	ES,SSDES0		; ES=visual data segment plean 0
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES

	MOV	DX,VCOL			; DX=color.
	CALL	C1VV_PLEAN_SLCT		; plean select.

	PUSH	DI
	PUSH	CX
	MOV	DX,SSDESW		; visual data plean width.
	MOV	AL,0FFH			; bit pattern.
DLINEH1LINE_LOOP1:
	PUSH	CX
	PUSH	DI
	MOV	CX,BP
	REP	STOSB			; line put.
	POP	DI
	POP	CX
	ADD	DI,DX			; visual data plean width.
	LOOP	DLINEH1LINE_LOOP1
	POP	CX
	POP	DI

	MOV	DX,VCOL			; DX=color.
	NOT	DX			;
	AND	DX,1111B		;
	CALL	C1VV_PLEAN_SLCT		; plean select.

	MOV	DX,SSDESW		; visual data plean width.
	MOV	AL,0			; bit pattern.
DLINEH1LINE_LOOP2:
	PUSH	CX
	PUSH	DI
	MOV	CX,BP
	REP	STOSB			; line put.
	POP	DI
	POP	CX
	ADD	DI,DX			; visual data plean width.
	LOOP	DLINEH1LINE_LOOP2

	RET
DLINEH1LINE	ENDP


;	line pattan put.(bit pattern)
;	-i-   VCOL    : color.
;	      BIT_PTN : bit pattern.
;	      SSDES0: visual data segment plean 0
;	      DI : start address
;	      CX : line width.
;	      BP : line byte length.

DLINEH1LINEX	PROC	NEAR
	CMP	BP,0			; line byte length.
	JNE	DLINEH1LINEX_START	;
	RET
DLINEH1LINEX_START:
	MOV	ES,SSDES0		; ES=visual data segment plean 0
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES

	MOV	DX,VCOL			; DX=color.
	CALL	C1VV_PLEAN_SLCT		; plean select.

	CMP	BIT_PTN,0FFH		; bit pattern.
	JE	DLINEH1LINEX_1		;
	CALL	C1VV_MODE_OR		; vram put mode OR.
DLINEH1LINEX_1:

	PUSH	DI
	PUSH	CX
	MOV	DX,SSDESW		; visual data plean width.
	MOV	AL,BIT_PTN		; bit pattern.
DLINEH1LINEX_LOOP1:
	PUSH	CX
	PUSH	DI
	MOV	CX,BP
DLINEH1LINEX_LOOP1X:
	MOV	AH,ES:[DI]		; rach.
	STOSB				; line put.
	LOOP	DLINEH1LINEX_LOOP1X	;
	ROR	AL,1			; <=====================
	POP	DI
	POP	CX
	ADD	DI,DX			; visual data plean width.
	LOOP	DLINEH1LINEX_LOOP1
	POP	CX
	POP	DI

	MOV	DX,VCOL			; DX=color.
	NOT	DX			;
	AND	DX,1111B		;
	CALL	C1VV_PLEAN_SLCT		; plean select.

	CMP	BIT_PTN,0FFH		; bit pattern.
	JE	DLINEH1LINEX_5		;
	CALL	C1VV_MODE_AND		; vram put mode AND.
DLINEH1LINEX_5:

	MOV	DX,SSDESW		; visual data plean width.
	MOV	AL,BIT_PTN		; bit pattern.
	NOT	AL			;
DLINEH1LINEX_LOOP2:
	PUSH	CX
	PUSH	DI
	MOV	CX,BP
DLINEH1LINEX_LOOP2X:
	MOV	AH,ES:[DI]		; rach.
	STOSB				; line put.
	LOOP	DLINEH1LINEX_LOOP2X	;
	ROR	AL,1			; <=====================
	POP	DI
	POP	CX
	ADD	DI,DX			; visual data plean width.
	LOOP	DLINEH1LINEX_LOOP2

	CMP	BIT_PTN,0FFH		; bit pattern.
	JE	DLINEH1LINEX_9		;
	CALL	C1VV_MODE_PSET		; vram put mode PSET.
DLINEH1LINEX_9:

	RET
DLINEH1LINEX	ENDP



;	êÇíºÉâÉCÉìï`âÊ
;	-I- VX1 : line dot point x.
;	    VY1 : start line point y1.
;	    VY2 : end line point y2.
;	    CX  : line width.
;	    VCOL: color.

VGADLINEV	PROC	NEAR
	CMP	CX,0			;
	JG	DLINEV0			;
	RET
DLINEV0:
	PUSH	CX
	MOV	AX,08000H		; left side dot.
	CMP	CX,1			;
	JE	DLINEV1			;
	DEC	CX			;
	SAR	AX,CL			; line width.
DLINEV1:
	MOV	CX,VX1			; line dot point x.
	AND	CX,111B			; bit shift.(dot point)
	SHR	AX,CL			; dot shift.
	XCHG	AH,AL			; AX=line pattan.

	MOV	BX,VY1			; start line point y1.
	MOV	DX,VY2			; end line point y2.

	CMP	BX,DX			;
	JB	DLINEV2			; BX=start point Y.
	XCHG	BX,DX			; DX=end point Y.
DLINEV2:
	PUSH	AX
	PUSH	DX
	MOV	AX,BX			; BX=start point Y.
	MOV	CX,SSDESW		; visual data plean width.
	MUL	CX			;
	MOV	DI,AX			; DI = VY1 * vram width.
	POP	DX
	POP	AX

	MOV	BP,VX1			; BP = X offset.
	SHR	BP,1			;
	SHR	BP,1			;
	SHR	BP,1			; / 8

	ADD	DI,BP			; start line.

	MOV	CX,DX			; DX=end point Y.
	SUB	CX,BX			; BX=start point Y.
	INC	CX			;

	CALL	DLINEV1LINE		;

	POP	CX
	RET
VGADLINEV	ENDP


;	vatical line pattan put.
;	-I- AX : pattan.
;	    ES : vram plean.
;	    DI : start address.
;	    VCOL: color.

DLINEV1LINE	PROC	NEAR
	MOV	ES,SSDES0		; ES=visual data segment plean 0
	CALL	C1VV_BANK_CHG_ES		; vram bank check & chenge.(WRITE) ES

	MOV	BP,SSDESW		; BP=visual data plean width.

	PUSH	CX			;
	PUSH	DI			;

	NOT	AX			;

	MOV	DX,1111B		;
	CALL	C1VV_PLEAN_SLCT		; plean select.
	CALL	C1VV_MODE_AND		; vram put mode AND.
DLINEV1LINE_LOOP1:			;
	MOV	DL,ES:[DI]		; rach.
	MOV	ES:[DI],AL		; pattan AND.
	MOV	DL,ES:[DI][1]		; rach.
	MOV	ES:[DI][1],AH		; pattan AND.
	ADD	DI,BP			; BP=next address.
	LOOP	DLINEV1LINE_LOOP1	;

	NOT	AX			;

	POP	DI			;
	POP	CX			;

	MOV	DX,VCOL			; color.
	CALL	C1VV_PLEAN_SLCT		; plean select.
	CALL	C1VV_MODE_OR		; vram put mode OR.
	PUSH	CX			;
DLINEV1LINE_LOOP2:			;
	MOV	DL,ES:[DI]		; rach.
	MOV	ES:[DI],AL		; pattan AND.
	MOV	DL,ES:[DI][1]		; rach.
	MOV	ES:[DI][1],AH		; pattan AND.
	ADD	DI,BP			; BP=next address.
	LOOP	DLINEV1LINE_LOOP2	;
	POP	CX			;

	CALL	C1VV_MODE_PSET		; vram put mode PSET.
	RET
DLINEV1LINE	ENDP


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

H_BIT_PTN	DB	10101010B,0	; h-line bit pattern.

BIT_PTN		DB	0,0	; bit pattern.

DATA	ENDS

	END
;
;	end of "VGAHVLINE.ASM"
;
