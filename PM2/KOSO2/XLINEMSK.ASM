; "XLINEMASK.ASM" 486/50 make by R.H 1992/07/05
;
;
;	MASK line.
;
;
; public subroutine.

INCLUDE	TSTSET.INC


NEXTLINE_AX_DI	MACRO
;	MUL	BX			; visual data plean width.
;	MOV	DI,AX			; DI = YY1 * vram width.
	MOV	DI,AX
	SHL	DI,1	;*2
	SHL	DI,1	;*4
	SHL	DI,1	;*8
	SHL	DI,1	;*16
	MOV	AX,DI
	SHL	DI,1	;*32
	SHL	DI,1	;*64
	ADD	DI,AX	;*80
	ENDM

PUTB_START	MACRO
	NOT	AL
	ENDM

PUTB	MACRO
	AND	ES:[DI],AL
	INC	DI
	ENDM

PUTBN	MACRO
	AND	ES:[DI],AL
	DEC	DI
	ENDM

PUTBZ	MACRO
	AND	ES:[DI],AL
	ENDM

IF 0
;	XLINEMASK	->	XLINEOR
;	MASK line.	->	OR line.
PUTB_START	MACRO
	ENDM

PUTB	MACRO
	OR	ES:[DI],AL
	INC	DI
	ENDM

PUTBN	MACRO
	OR	ES:[DI],AL
	DEC	DI
	ENDM

PUTBZ	MACRO
	OR	ES:[DI],AL
	ENDM
ENDIF

IF 0
;	XLINEMASK	->	XLINEVGA
;	MASK line.	->	VGA line.
PUTB_START	MACRO
	ENDM

PUTB	MACRO
	MOV	DL,ES:[DI]
	MOV	ES:[DI],AL
	INC	DI
	ENDM

PUTBN	MACRO
	MOV	DL,ES:[DI]
	MOV	ES:[DI],AL
	DEC	DI
	ENDM

PUTBZ	MACRO
	MOV	DL,ES:[DI]
	MOV	ES:[DI],AL
	ENDM
ENDIF

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA


PUBLIC	XLINEMASK		; MASK line.

;	MASK line.
;	-I- VX1,VY1 : start point.
;	    VX2,VY2 : end point.
;	    ES      : vram segment.
;	    SSDESW  : vram width.

XLINEMASK	PROC	NEAR

;	(*) parameter set.

	MOVX	XX1,VX1
	MOVX	YY1,VY1

	MOV	XDIR,+1		; x direction.(+1/-1)
	MOV	YDIR,+1		; y direction.(+1/-1)

	MOV	BX,VX2		;
	SUB	BX,VX1		;
	JNB	XLINE_XX	;
	NEG	BX		;
	MOV	XDIR,-1		; x direction.(+1/-1)
XLINE_XX:			; BX = Xlength
	INC	BX		;

	MOV	CX,VY2		;
	SUB	CX,VY1		;
	JNB	XLINE_YY	;
	NEG	CX		;
	MOV	YDIR,-1		; y direction.(+1/-1)
XLINE_YY:			; CX = Ylength
	INC	CX		;

	CMP	BX,1		;
	JNE	XLINE_2		;

	MOV	BP,CX		; length.
	CMP	YDIR,0		;
	JL	XLINE_11	;
	CALL	LINE_Y_LONG	; draw line y long
	JMP	XLINE_EXIT	;
XLINE_11:			;
	CALL	LINE_YN_LONG	; draw line y minus long.
	JMP	XLINE_EXIT	;
XLINE_2:			;

	CMP	CX,1		;
	JNE	XLINE_3		;

	MOV	BP,BX		; length.
	CMP	XDIR,0		;
	JL	XLINE_22	;
	CALL	LINE_X_LONG	; draw line x long
	JMP	XLINE_EXIT	;
XLINE_22:			;
	CALL	LINE_XN_LONG	; draw line x minus long.
	JMP	XLINE_EXIT	;
XLINE_3:			;

	CMP	CX,BX		; if Ylength >= Xlength then
	JMPB	XLINE_X_UP	;

;	dy > dx

	CMP	YDIR,0
	JL	XLINE_YN

;	dy > dx   ystep > 0

	MOV	AX,CX		; AX = Ylength
	MOV	BP,0		; BP = Ystep = 0
	MOV	SI,CX		; SI = Ylength
XLINE_Y_LOOP:			; for i=1 to Ylength
	INC	BP		;
	SUB	AX,BX		;   AX=AX-Xlength
	JNBE	XLINE_Y_NEXT	;   if  AX =< 0  then
	ADD	AX,SI		;     AX=AX+Ylength
	PUSH	CX		;
	PUSH	BX		;
	PUSH	AX		;
	CALL	LINE_Y_LONG	;     draw line y long
	POP	AX		;
	POP	BX		;
	POP	CX		;
	ADD	YY1,BP		;
	MOV	DI,XDIR		;
	ADD	XX1,DI		;
	MOV	BP,0		;
XLINE_Y_NEXT:			;
	LOOP	XLINE_Y_LOOP	;   next i
	CMP	BP,0		;
	JE	XLINE_Y_E	;
	CALL	LINE_Y_LONG	;   draw line y long
XLINE_Y_E:			;
	JMP	XLINE_EXIT	;

;	dy > dx   ystep < 0

XLINE_YN:
	MOV	AX,CX		; AX = Ylength
	MOV	BP,0		; BP = Ystep = 0
	MOV	SI,CX		; SI = Ylength
XLINE_YN_LOOP:			; for i=1 to Ylength
	INC	BP		;
	SUB	AX,BX		;   AX=AX-Xlength
	JNBE	XLINE_YN_NEXT	;   if  AX =< 0  then
	ADD	AX,SI		;     AX=AX+Ylength
	PUSH	CX		;
	PUSH	BX		;
	PUSH	AX		;
	CALL	LINE_YN_LONG	;     draw line y minus long.
	POP	AX		;
	POP	BX		;
	POP	CX		;
	SUB	YY1,BP		;
	MOV	DI,XDIR		;
	ADD	XX1,DI		;
	MOV	BP,0		;
XLINE_YN_NEXT:			;
	LOOP	XLINE_YN_LOOP	;   next i
	CMP	BP,0		;
	JE	XLINE_YN_E	;
	CALL	LINE_YN_LONG	;   draw line y long
XLINE_YN_E:			;
	JMP	XLINE_EXIT	;


XLINE_X_UP:

;	dy < dx

	CMP	XDIR,0
	JL	XLINE_XN

;	dy < dx   xstep > 0

	XCHG	BX,CX		;

	MOV	AX,CX		; AX = Xlength
	MOV	BP,0		; BP = Xstep = 0
	MOV	SI,CX		; SI = Xlength
XLINE_X_LOOP:			; for i=1 to Xlength
	INC	BP		;
	SUB	AX,BX		;   AX=AX-Ylength
	JNBE	XLINE_X_NEXT	;   if  AX =< 0  then
	ADD	AX,SI		;     AX=AX+Xlength
	PUSH	CX		;
	PUSH	BX		;
	PUSH	AX		;
	CALL	LINE_X_LONG	;     draw line x long.
	POP	AX		;
	POP	BX		;
	POP	CX		;
	ADD	XX1,BP		;
	MOV	DI,YDIR		;
	ADD	YY1,DI		;
	MOV	BP,0		;
XLINE_X_NEXT:			;
	LOOP	XLINE_X_LOOP	;   next i
	CMP	BP,0		;
	JE	XLINE_X_E	;
	CALL	LINE_X_LONG	;   draw line x long
XLINE_X_E:			;
	JMP	XLINE_EXIT	;


;	dy < dx   xstep < 0

XLINE_XN:
	XCHG	BX,CX		;

	MOV	AX,CX		; AX = Xlength
	MOV	BP,0		; BP = Xstep = 0
	MOV	SI,CX		; SI = Xlength
XLINE_XN_LOOP:			; for i=1 to Xlength
	INC	BP		;
	SUB	AX,BX		;   AX=AX-Ylength
	JNBE	XLINE_XN_NEXT	;   if  AX =< 0  then
	ADD	AX,SI		;     AX=AX+Xlength
	PUSH	CX		;
	PUSH	BX		;
	PUSH	AX		;
	CALL	LINE_XN_LONG	;      draw line x minus long.
	POP	AX		;
	POP	BX		;
	POP	CX		;
	SUB	XX1,BP		;
	MOV	DI,YDIR		;
	ADD	YY1,DI		;
	MOV	BP,0		;
XLINE_XN_NEXT:			;
	LOOP	XLINE_XN_LOOP	;   next i
	CMP	BP,0		;
	JE	XLINE_XN_E	;
	CALL	LINE_XN_LONG	; draw line x minus long.
XLINE_XN_E:			;
	JMP	XLINE_EXIT	;
XLINE_EXIT:
	RET
XLINEMASK	ENDP


;	draw line x long.
;	-I- XX1,YY1 : start point
;	    BP      : length.

LINE_X_LONG	PROC	NEAR
	MOV	BX,SSDESW		; BX = vram width.

	MOV	AX,YY1			;
	NEXTLINE_AX_DI			; DI = YY1 * vram width.

	MOV	AX,XX1			;
	MOV	CX,AX			;
	AND	CX,111B			; CX = XX1 mod 8
	SUB	AX,CX			; AX = XX1 - (XX1 mod 8)
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;
	ADD	DI,AX			; DI = address.

	MOV	AX,CX			; CX = start shift point.
	ADD	AX,BP			; length.
	CMP	AX,16			;
	JBE	LINE_X_LONG_16DOT	;

	MOV	AL,0FFH			; left side bit pattern.
	SHR	AL,CL			; ex.00011111B (start shift 3)
	PUTB_START			;
	PUTB				;

	MOV	AX,BP			; length.
	SUB	AX,8			;
	ADD	AX,CX			; CX = start shift point.
	MOV	BX,AX			;
	AND	BX,111B			; BX=end bit pattern length.
	MOV	CX,AX			;
	SHR	CX,1			;
	SHR	CX,1			;
	SHR	CX,1			;
	MOV	AL,0FFH			; fill pattern.
	PUTB_START			;
LINE_X_LONG_LOOP:			;
	PUTB				;
	LOOP	LINE_X_LONG_LOOP	;

	MOV	CX,BX			; CX=end bit pattern length.
	MOV	AL,0FFH			;
	SHR	AL,CL			;
	NOT	AL			;
	PUTB_START			;
	PUTB				;
	RET
LINE_X_LONG_16DOT:			;
	MOV	BX,CX			;
	MOV	CX,BP			; length.
	DEC	CX			;
	MOV	AX,8000H		; bit15=1
	SAR	AX,CL			; fill left bits.
	MOV	CX,BX			;
	SHR	AX,CL			; shift bits.

	XCHG	AL,AH			;
	PUTB_START			;
	PUTB				;
	XCHG	AL,AH			;
	PUTB_START			;
	PUTB				;
	RET
LINE_X_LONG	ENDP


;	draw line x minus long.
;	-I- XX1,YY1 : start point
;	    BP      : length.

LINE_XN_LONG	PROC	NEAR
	MOV	BX,SSDESW		; BX = vram width.

	MOV	AX,YY1			;
	NEXTLINE_AX_DI			; DI = YY1 * vram width.

	MOV	AX,XX1			;
	MOV	CX,AX			;
	AND	CX,111B			; CX = XX1 mod 8
	SUB	AX,CX			; AX = XX1 - (XX1 mod 8)
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;
	ADD	DI,AX			; DI = address.

	MOV	AX,8			;
	SUB	AX,CX			; CX = start shift point.
	ADD	AX,BP			; length.
	CMP	AX,16			;
	JBE	LINE_XN_LONG_16DOT	;

	MOV	AL,0FFH			; right side bit pattern.
	INC	CX			;
	SHR	AL,CL			; shift.
	NOT	AL			;
	PUTB_START			;
	PUTBN				;

	MOV	AX,BP			; length.
	SUB	AX,CX			; line length = Xstep - cx
	MOV	BX,AX			;
	AND	BX,111B			; BX=end bit pattern length.
	MOV	CX,AX			;
	SHR	CX,1			;
	SHR	CX,1			;
	SHR	CX,1			;
	MOV	AL,0FFH			; fill pattern.
	PUTB_START			;
LINE_XN_LONG_LOOP:			;
	PUTBN				;
	LOOP	LINE_XN_LONG_LOOP	;

	MOV	CX,BX			; CX=end bit pattern length.
	MOV	AL,0FFH			;
	SHL	AL,CL			;
	NOT	AL			;
	PUTB_START			;
	PUTBN				;
	RET
LINE_XN_LONG_16DOT:			;
	MOV	BX,CX			;
	MOV	CX,BP			; length.
	MOV	AX,0FFFFH		;
	SHL	AX,CL			; fill left bits.
	NOT	AX			;
	MOV	CX,7			;
	SUB	CX,BX			;
	SHL	AX,CL			; shift bits.

	PUTB_START			;
	PUTBN				;
	MOV	AL,AH			;
	PUTB_START			;
	PUTBN				;
	RET
LINE_XN_LONG	ENDP


;	draw line y long.
;	-I- XX1,YY1 : start point
;	    BP      : length.

LINE_Y_LONG	PROC	NEAR
	MOV	BX,SSDESW		; BX = vram width.

	MOV	AX,YY1			;
	NEXTLINE_AX_DI			; DI = YY1 * vram width.

	MOV	AX,XX1			;
	MOV	CX,AX			;
	AND	CX,111B			; CX = XX1 mod 8
	SUB	AX,CX			; AX = XX1 - (XX1 mod 8)
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;

	ADD	DI,AX			; DI = address.
	MOV	AL,10000000B		;
	SHR	AL,CL			; AL = bit pattern.

	MOV	CX,BP			;
	PUTB_START			;
LINE_Y_LONG_LOOP:			;
	PUTBZ				;
	ADD	DI,BX			; next address.
	LOOP	LINE_Y_LONG_LOOP	;
	RET
LINE_Y_LONG	ENDP


;	draw line y minus long.
;	-I- XX1,YY1 : start point
;	    BP      : length.

LINE_YN_LONG	PROC	NEAR
	MOV	BX,SSDESW		; BX = vram width.

	MOV	AX,YY1			;
	NEXTLINE_AX_DI			; DI = YY1 * vram width.

	MOV	AX,XX1			;
	MOV	CX,AX			;
	AND	CX,111B			; CX = XX1 mod 8
	SUB	AX,CX			; AX = XX1 - (XX1 mod 8)
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;

	ADD	DI,AX			; DI = address.
	MOV	AL,10000000B		;
	SHR	AL,CL			; AL = bit pattern.

	MOV	CX,BP			;
	PUTB_START			;
LINE_YN_LONG_LOOP:			;
	PUTBZ				;
	SUB	DI,BX			; next address.
	LOOP	LINE_YN_LONG_LOOP	;
	RET
LINE_YN_LONG	ENDP

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

XX1		DW	0	; x.
YY1		DW	0	; y.

XDIR		DW	0	; x direction.(+1/-1)
YDIR		DW	0	; y direction.(+1/-1)

DATA	ENDS

	END
;
;	end of "XLINEMASK.ASM"
;
