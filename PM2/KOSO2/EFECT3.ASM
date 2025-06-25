; "EFECT3.ASM" 486/50 make by R.H 1992/11/13
;
;
;	graphic effect.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	EF_BAR_LINE	; bar graphic line.

EXTRN	DLINEH:NEAR		; 水平ライン描画
EXTRN	DLINEHBT:NEAR		; 水平ライン描画点線


;	bar graphic line.
;	-I- AX,BX  : start point.
;	    CX     : max length.
;	    DX     : bar length.

EF_BAR_LINE	PROC	NEAR
	MOV	XX1,AX			; start point.
	MOV	YY1,BX			; start point.
	MOV	LENBAR,DX		; bar length.

	ADD	AX,CX
	DEC	AX
	MOV	BASE_X_END,AX

	CALL	DRAW_BAR		; draw bar.

	RET
EF_BAR_LINE	ENDP



BAR_LOC	MACRO	XX,YY,LENG
	MOV	AX,XX
	MOV	BASE_X,AX
	MOV	AX,YY
	MOV	BASE_Y,AX
	MOV	AX,LENG
	MOV	BAR_LENG,AX
	ENDM

BAR_PIC	MACRO	WID,COLR
	MOV	CX,WID
	MOV	DX,COLR
	CALL	BAR_DRAW_P
	ENDM

BAR_PIC_BT	MACRO	WID,COLR,COL2
	MOV	CX,WID
	MOV	DX,COLR
	MOV	BX,COL2
	CALL	BAR_DRAW_BT
	ENDM

;	bar draw.
;	-I- CX : width.
;	    DX : color.
;	-O- AX : 0=normal,1=area end.

BAR_DRAW_P	PROC	NEAR
	CALL	BAR_DRAW_CALC		; bar draw calc.
	PUSH	AX
	CALL	DLINEH			; 水平ライン描画
	POP	AX
	RET
BAR_DRAW_P	ENDP


;	bar draw.点線
;	-I- CX : width.
;	    DX : color.
;	    BX : color2.
;	-O- AX : 0=normal,1=area end.

BAR_DRAW_BT	PROC	NEAR
	PUSH	BX
	CALL	BAR_DRAW_CALC		; bar draw calc.
	POP	BX
	PUSH	AX
	PUSH	BX
	PUSH	CX	 		; line width.
	MOV	AL,10101010B		; line bit pattern.
	CALL	DLINEHBT		; 水平ライン描画点線
	POP	CX	 		; line width.
	POP	VCOL			; CX=color.
	MOV	AL,01010101B		; line bit pattern.
	CALL	DLINEHBT		; 水平ライン描画点線
	POP	AX
	RET
BAR_DRAW_BT	ENDP


;	bar draw calc.
;	-I- CX : width.
;	    DX : color.
;	-O- AX : 0=normal,1=area end.
;	    VX1 : start dot point x1.
;	    VX2 : end dot point x2.
;	    VY1 : line hight y1.
;	    CX  : line width.
;	    VCOL: color.

BAR_DRAW_CALC	PROC	NEAR
	MOV	VCOL,DX		; color.

	MOV	AX,BASE_Y
	MOV	VY1,AX

	ADD	BASE_Y,CX

	MOV	AX,BASE_X
	MOV	VX1,AX
	ADD	AX,BAR_LENG
	DEC	AX		;-1
	MOV	VX2,AX

	CMP	AX,BASE_X_END
	JNBE	BAR_DRAW_CALC_AREA_END

	MOV	AX,0			; 0=normal,1=area end.
	RET
BAR_DRAW_CALC_AREA_END:
	MOV	AX,BASE_X_END
	MOV	VX2,AX

	MOV	AX,1			; 1=area end.
	RET
BAR_DRAW_CALC	ENDP


;	draw bar.

DRAW_BAR	PROC	NEAR
	CMP	LENBAR,0
	JE	DRAW_BAR_8

	BAR_LOC		XX1,YY1,LENBAR

	BAR_PIC		1,10
	BAR_PIC		1,5
	BAR_PIC		1,10
	BAR_PIC		1,3
	BAR_PIC		1,15
	BAR_PIC		1,3
	BAR_PIC		3,10
	BAR_PIC		1,5
	BAR_PIC		1,10

	CMP	AX,0
	JNE	DRAW_BAR_EXIT
	ADDX	XX1,LENBAR

DRAW_BAR_2:
	BAR_LOC		XX1,YY1,1

	BAR_PIC		1,10
	BAR_PIC		1,5
	BAR_PIC		7,10
	BAR_PIC		1,5
	BAR_PIC		1,10

	CMP	AX,0
	JNE	DRAW_BAR_EXIT
	INC	XX1

	BAR_LOC		XX1,YY1,2

	BAR_PIC		1,10
	BAR_PIC		1,5
	BAR_PIC		7,5
	BAR_PIC		1,5
	BAR_PIC		1,10

	CMP	AX,0
	JNE	DRAW_BAR_EXIT
	ADD	XX1,2

	BAR_LOC		XX1,YY1,2

	BAR_PIC		1,4
	BAR_PIC		1,5
	BAR_PIC_BT	7,6,5
	BAR_PIC		1,5
	BAR_PIC		1,4

	CMP	AX,0
	JNE	DRAW_BAR_EXIT
	ADD	XX1,2

	BAR_LOC		XX1,YY1,2

	BAR_PIC		1,5
	BAR_PIC		1,5
	BAR_PIC		7,6
	BAR_PIC		1,5
	BAR_PIC		1,5

	CMP	AX,0
	JNE	DRAW_BAR_EXIT
	ADD	XX1,2

	BAR_LOC		XX1,YY1,3

	BAR_PIC		1,6
	BAR_PIC		1,5
	BAR_PIC_BT	7,6,0
	BAR_PIC		1,5
	BAR_PIC		1,6

	CMP	AX,0
	JNE	DRAW_BAR_EXIT
	ADD	XX1,3

	BAR_LOC		XX1,YY1,4

	BAR_PIC		1,0
	BAR_PIC		1,5
	BAR_PIC_BT	7,6,0
	BAR_PIC		1,5
	BAR_PIC		1,6

	CMP	AX,0
	JNE	DRAW_BAR_EXIT
	ADD	XX1,4

	BAR_LOC		XX1,YY1,3

	BAR_PIC		1,0
	BAR_PIC		1,5
	BAR_PIC_BT	7,6,0
	BAR_PIC		1,5
	BAR_PIC		1,6

	CMP	AX,0
	JNE	DRAW_BAR_EXIT
	ADD	XX1,3

	BAR_LOC		XX1,YY1,4

	BAR_PIC		1,0
	BAR_PIC_BT	1,5,6
	BAR_PIC_BT	7,6,0
	BAR_PIC_BT	1,5,6
	BAR_PIC		1,6

	CMP	AX,0
	JNE	DRAW_BAR_EXIT
	ADD	XX1,4

	BAR_LOC		XX1,YY1,12

	BAR_PIC		1,0
	BAR_PIC		1,6
	BAR_PIC_BT	7,6,0
	BAR_PIC		1,6
	BAR_PIC		1,6

	CMP	AX,0
	JNE	DRAW_BAR_EXIT
	ADD	XX1,12

DRAW_BAR_8:

	MOV	DX,BASE_X_END
	SUB	DX,XX1
	MOV	END_LENG,DX

	CMP	DX,0
	JL	DRAW_BAR_EXIT

	CMP	DX,0
	JE	DRAW_BAR_9

	BAR_LOC		XX1,YY1,END_LENG

	BAR_PIC		1,0
	BAR_PIC		1,0
	BAR_PIC_BT	7,6,0
	BAR_PIC		1,6
	BAR_PIC		1,6

	CMP	LENBAR,0
	JE	DRAW_BAR_EXIT

DRAW_BAR_9:
	MOVX		XX1,BASE_X_END
	BAR_LOC		XX1,YY1,1
	BAR_PIC		11,4
DRAW_BAR_EXIT:
	RET
DRAW_BAR	ENDP



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

XX1		DW	0		; start point.
YY1		DW	0		; start point.
LENBAR		DW	0		; bar length.

TBL_HIGHT	DW	0, 1, 2, 3, 4, 5, 6, 7,10,11,12
TBL_WIDTH	DW	1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1
TBL_COLOR	DW	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

BASE_X_END	DW	0

BASE_X		DW	0
BASE_Y		DW	0
BAR_LENG	DW	0

END_LENG	DW	0

DATA	ENDS

	END

;LENMAX		DW	0		; max length.
;MOV	LENMAX,CX		; max length.
;
;	end of "EFECT3.ASM"
;
