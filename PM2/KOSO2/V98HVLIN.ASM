; "V98HVLINE.ASM" 1990/04/18 PC-9801UV11 make by R.H
;		modify 1992/05/08
;
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

PUBLIC	V98DLINEH		; êÖïΩÉâÉCÉìï`âÊ
PUBLIC	V98DLINEHBT		; êÖïΩÉâÉCÉìï`âÊì_ê¸
PUBLIC	V98DLINEV		; êÇíºÉâÉCÉìï`âÊ


;	êÖïΩÉâÉCÉìï`âÊ
;	-I- VX1 : start dot point x1.
;	    VX2 : end dot point x2.
;	    VY1 : line hight y1.
;	    CX  : line width.
;	    VCOL: color.

V98DLINEH	PROC	NEAR
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
	MOV	BX,VCOL			; BX=color.
	MOV	DX,SSDES0		; ES=visual data segment plean 0
	CALL	DLINEH1DOT		; dot pattan put.
	MOV	DX,SSDES1		; ES=visual data segment plean 1
	CALL	DLINEH1DOT		; dot pattan put.
	MOV	DX,SSDES2		; ES=visual data segment plean 2
	CALL	DLINEH1DOT		; dot pattan put.
	MOV	DX,SSDES3		; ES=visual data segment plean 3
	CALL	DLINEH1DOT		; dot pattan put.
	ADD	DI,SSDESW		; visual data plean width.
	LOOP	DLINEH3			;
	RET				;

DLINEH4:				;

	ADD	DI,BP			; DI = start address.
	MOV	SI,DI			; save offset.

	SUB	CX,BP			; BP=line length.
	MOV	BP,CX			;

	POP	CX			; CX=line width.
	PUSH	CX			;
DLINEH41:				;
	MOV	BX,VCOL			; BX=color.
	MOV	DX,SSDES0		; ES=visual data segment plean 0
	CALL	DLINEH1DOT		; dot pattan put.
	MOV	DX,SSDES1		; ES=visual data segment plean 1
	CALL	DLINEH1DOT		; dot pattan put.
	MOV	DX,SSDES2		; ES=visual data segment plean 2
	CALL	DLINEH1DOT		; dot pattan put.
	MOV	DX,SSDES3		; ES=visual data segment plean 3
	CALL	DLINEH1DOT		; dot pattan put.
	ADD	DI,SSDESW		; visual data plean width.
	LOOP	DLINEH41		;

	POP	CX			; CX=line width.
	PUSH	CX			;
	MOV	AL,AH			; AL=AH=end pattan.
	MOV	DI,SI			; load offset.
	ADD	DI,BP			; BP=end point X byte.
DLINEH42:				;
	MOV	BX,VCOL			; BX=color.
	MOV	DX,SSDES0		; ES=visual data segment plean 0
	CALL	DLINEH1DOT		; dot pattan put.
	MOV	DX,SSDES1		; ES=visual data segment plean 1
	CALL	DLINEH1DOT		; dot pattan put.
	MOV	DX,SSDES2		; ES=visual data segment plean 2
	CALL	DLINEH1DOT		; dot pattan put.
	MOV	DX,SSDES3		; ES=visual data segment plean 3
	CALL	DLINEH1DOT		; dot pattan put.
	ADD	DI,SSDESW		; visual data plean width.
	LOOP	DLINEH42		;

	POP	CX			; CX=line width.
	INC	SI			;
	DEC	BP			;
DLINEH43:				;
	PUSH	CX			;
	MOV	BX,VCOL			; BX=color.
	MOV	DX,SSDES0		; ES=visual data segment plean 0
	CALL	DLINEH1LINE		; line pattan put.
	MOV	DX,SSDES1		; ES=visual data segment plean 1
	CALL	DLINEH1LINE		; line pattan put.
	MOV	DX,SSDES2		; ES=visual data segment plean 2
	CALL	DLINEH1LINE		; line pattan put.
	MOV	DX,SSDES3		; ES=visual data segment plean 3
	CALL	DLINEH1LINE		; line pattan put.
	ADD	SI,SSDESW		; visual data plean width.
	POP	CX			;
	LOOP	DLINEH43		;

	RET
V98DLINEH	ENDP


;	êÖïΩÉâÉCÉìï`âÊì_ê¸
;	-I- VX1 : start dot point x1.
;	    VX2 : end dot point x2.
;	    VY1 : line hight y1.
;	    CX  : line width.
;	    VCOL: color.
;	    AL  : line bit pattern.

V98DLINEHBT	PROC	NEAR
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

	MOV	DL,H_BIT_PTN		; h-line bit pattern.
	MOV	BIT_PTN,DL		; bit pattern.
DLINEHBT3:				;
	MOV	BX,VCOL			; BX=color.
	MOV	DX,SSDES0		; ES=visual data segment plean 0
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	MOV	DX,SSDES1		; ES=visual data segment plean 1
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	MOV	DX,SSDES2		; ES=visual data segment plean 2
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	MOV	DX,SSDES3		; ES=visual data segment plean 3
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	ADD	DI,SSDESW		; visual data plean width.
	ROR	BIT_PTN,1		; bit pattern.
	LOOP	DLINEHBT3		;
	RET				;

DLINEHBT4:				;

	ADD	DI,BP			; DI = start address.
	MOV	SI,DI			; save offset.

	SUB	CX,BP			; BP=line length.
	MOV	BP,CX			;

	POP	CX			; CX=line width.
	PUSH	CX			;
	MOV	DL,H_BIT_PTN		; h-line bit pattern.
	MOV	BIT_PTN,DL		; bit pattern.
DLINEHBT41:				;
	MOV	BX,VCOL			; BX=color.
	MOV	DX,SSDES0		; ES=visual data segment plean 0
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	MOV	DX,SSDES1		; ES=visual data segment plean 1
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	MOV	DX,SSDES2		; ES=visual data segment plean 2
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	MOV	DX,SSDES3		; ES=visual data segment plean 3
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	ADD	DI,SSDESW		; visual data plean width.
	ROR	BIT_PTN,1		; bit pattern.
	LOOP	DLINEHBT41		;

	POP	CX			; CX=line width.
	PUSH	CX			;
	MOV	DL,H_BIT_PTN		; h-line bit pattern.
	MOV	BIT_PTN,DL		; bit pattern.
	MOV	AL,AH			; AL=AH=end pattan.
	MOV	DI,SI			; load offset.
	ADD	DI,BP			; BP=end point X byte.
DLINEHBT42:				;
	MOV	BX,VCOL			; BX=color.
	MOV	DX,SSDES0		; ES=visual data segment plean 0
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	MOV	DX,SSDES1		; ES=visual data segment plean 1
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	MOV	DX,SSDES2		; ES=visual data segment plean 2
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	MOV	DX,SSDES3		; ES=visual data segment plean 3
	CALL	DLINEH1DOTBT		; dot pattan put.(bit pattern)
	ADD	DI,SSDESW		; visual data plean width.
	ROR	BIT_PTN,1		; bit pattern.
	LOOP	DLINEHBT42		;

	POP	CX			; CX=line width.
	MOV	AL,H_BIT_PTN		; h-line bit pattern.
	INC	SI			;
	DEC	BP			;
DLINEHBT43:				;
	PUSH	CX			;
	MOV	BX,VCOL			; BX=color.
	MOV	DX,SSDES0		; ES=visual data segment plean 0
	CALL	DLINEH1LINEBT		; line pattan put.(bit pattern)
	MOV	DX,SSDES1		; ES=visual data segment plean 1
	CALL	DLINEH1LINEBT		; line pattan put.(bit pattern)
	MOV	DX,SSDES2		; ES=visual data segment plean 2
	CALL	DLINEH1LINEBT		; line pattan put.(bit pattern)
	MOV	DX,SSDES3		; ES=visual data segment plean 3
	CALL	DLINEH1LINEBT		; line pattan put.(bit pattern)
	ADD	SI,SSDESW		; visual data plean width.
	ROR	AL,1			;
	POP	CX			;
	LOOP	DLINEHBT43		;

	RET
V98DLINEHBT	ENDP


;	line pattan put.
;	-I/O- BX lower bit : color.
;	      DX : vram plean segment.
;	      SI : start address.
;	      BP : line length(byte).

DLINEH1LINE	PROC	NEAR
	MOV	ES,DX			;
	MOV	DI,SI			;
	MOV	CX,BP			; BP=(end-start)-1 

	SHR	BX,1			; BX=color.
	JNB	DLINEH40_AND		;
DLINEH40_OR:				;
	MOV	AL,0FFH			; line pattan.
	REP	STOSB			; line put.
	JMP	DLINEH40_END		;
DLINEH40_AND:				;
	MOV	AL,0			; line pattan.
	REP	STOSB			; line put.
DLINEH40_END:				;
	RET
DLINEH1LINE	ENDP


;	line pattan put.(bit pattern)
;	-I-   AL : bit pattern.
;	-I/O- BX lower bit : color.
;	      DX : vram plean segment.
;	      SI : start address.
;	      BP : line length(byte).

DLINEH1LINEBT	PROC	NEAR
	MOV	ES,DX			;
	MOV	DI,SI			;
	MOV	CX,BP			; BP=(end-start)-1 
	JCXZ	DLINEH1LINEBT_EXIT	;

	SHR	BX,1			; BX=color.
	JNB	DLINEH1LINEBT_AND	;
DLINEH1LINEBT_OR:
	OR	ES:[DI],AL
	INC	DI
	LOOP	DLINEH1LINEBT_OR
	RET

DLINEH1LINEBT_AND:
	NOT	AL
DLINEH1LINEBT_AND_LP:
	AND	ES:[DI],AL
	INC	DI
	LOOP	DLINEH1LINEBT_AND_LP
	NOT	AL

DLINEH1LINEBT_EXIT:
	RET
DLINEH1LINEBT	ENDP


;	dot pattan put.
;	-I-   AL=put pattan.
;	-I/O- BX lower bit : color.
;	      DX : vram plean segment.
;	      DI : start address

DLINEH1DOT	PROC	NEAR
	MOV	ES,DX			;
	SHR	BX,1			; BX=color.
	JNB	DLINEH50_AND		;
DLINEH50_OR:				;
	OR	ES:[DI],AL		;
	RET				;
DLINEH50_AND:				;
	NOT	AL			;
	AND	ES:[DI],AL		;
	NOT	AL			;
	RET				;
DLINEH1DOT	ENDP


;	dot pattan put.(bit pattern)
;	-I-   AL=put pattan.
;	      BIT_PTN : bit pattern.
;	-I/O- BX lower bit : color.
;	      DX : vram plean segment.
;	      DI : start address

DLINEH1DOTBT	PROC	NEAR
	MOV	ES,DX			;
	SHR	BX,1			; BX=color.
	JNB	DLINEH1DOTBT_AND	;
DLINEH1DOTBT_OR:			;
	MOV	DL,AL			;
	AND	DL,BIT_PTN		; bit pattern.
	OR	ES:[DI],DL		;
	RET				;
DLINEH1DOTBT_AND:			;
	MOV	DL,AL			;
	AND	DL,BIT_PTN		; bit pattern.
	NOT	DL			;
	AND	ES:[DI],DL		;
	RET				;
DLINEH1DOTBT	ENDP


;	êÇíºÉâÉCÉìï`âÊ
;	-I- VX1 : line dot point x.
;	    VY1 : start line point y1.
;	    VY2 : end line point y2.
;	    CX  : line width.
;	    VCOL: color.

V98DLINEV	PROC	NEAR
	PUSH	CX
	CMP	CX,0			;
	JG	DLINEV0			;
	RET
DLINEV0:
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
	MOV	AX,BX			;
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

	MOV	BX,VCOL			; BX=color.

	MOV	SI,DI			;

	MOV	DI,SI			;
	MOV	DX,SSDES0		; ES=visual data segment plean 0
	MOV	ES,DX			;
	CALL	DLINEV1LINE		;

	MOV	DI,SI			;
	MOV	DX,SSDES1		; ES=visual data segment plean 1
	MOV	ES,DX			;
	CALL	DLINEV1LINE		;

	MOV	DI,SI			;
	MOV	DX,SSDES2		; ES=visual data segment plean 2
	MOV	ES,DX			;
	CALL	DLINEV1LINE		;

	MOV	DI,SI			;
	MOV	DX,SSDES3		; ES=visual data segment plean 3
	MOV	ES,DX			;
	CALL	DLINEV1LINE		;

	POP	CX
	RET
V98DLINEV	ENDP


;	vatical line pattan put.
;	-I-   AX : pattan.
;	      ES : vram plean.
;	      DI : start address.
;	-I/O- BX : color.

DLINEV1LINE	PROC	NEAR
	MOV	BP,SSDESW		; visual data plean width.
	PUSH	CX			;
	SHR	BX,1			; BX=color.
	JNB	DLINEV40_AND		;
DLINEV40_OR:				;
	OR	ES:[DI],AX		;
	ADD	DI,BP			; BP=next address.
	LOOP	DLINEV40_OR		;
	JMP	DLINEV40_END		;
DLINEV40_AND:				;
	NOT	AX			;
DLINEV40_AND2:				;
	AND	ES:[DI],AX		;
	ADD	DI,BP			; BP=next address.
	LOOP	DLINEV40_AND2		;
	NOT	AX			;
DLINEV40_END:				;
	POP	CX			;
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
;	end of "V98HVLINE.ASM"
;
