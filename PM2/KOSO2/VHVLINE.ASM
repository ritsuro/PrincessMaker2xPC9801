; "VHVLINE.ASM" 486/33 make by R.H 1992/05/08 dual machine.
;
;
;	縦横ライン描画
;
;
; public soubroutine.

INCLUDE	MACHINEX.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	DLINEH			; 水平ライン描画
PUBLIC	DLINEHBT		; 水平ライン描画点線
PUBLIC	DLINEV			; 垂直ライン描画

;	PC9801.

EXTRN	V98DLINEH:NEAR		; 水平ライン描画
EXTRN	V98DLINEHBT:NEAR	; 水平ライン描画点線
EXTRN	V98DLINEV:NEAR		; 垂直ライン描画

;	PC/AT.

EXTRN	VGADLINEH:NEAR		; 水平ライン描画
EXTRN	VGADLINEHBT:NEAR	; 水平ライン描画点線
EXTRN	VGADLINEV:NEAR		; 垂直ライン描画


;	水平ライン描画
;	-I- VX1 : start dot point x1.
;	    VX2 : end dot point x2.
;	    VY1 : line hight y1.
;	    CX  : line width.
;	    VCOL: color.

DLINEH	PROC	NEAR
	MACHINE_CALL	VGADLINEH,V98DLINEH		; 水平ライン描画
	RET
DLINEH	ENDP


;	水平ライン描画点線
;	-I- VX1 : start dot point x1.
;	    VX2 : end dot point x2.
;	    VY1 : line hight y1.
;	    CX  : line width.
;	    VCOL: color.
;	    AL  : line bit pattern.

DLINEHBT	PROC	NEAR
	MACHINE_CALL	VGADLINEHBT,V98DLINEHBT		; 水平ライン描画点線
	RET
DLINEHBT	ENDP


;	垂直ライン描画
;	-I- VX1 : line dot point x.
;	    VY1 : start line point y1.
;	    VY2 : end line point y2.
;	    CX  : line width.
;	    VCOL: color.

DLINEV	PROC	NEAR
	MACHINE_CALL	VGADLINEV,V98DLINEV		; 垂直ライン描画
	RET
DLINEV	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'
DATA	ENDS

	END
;
;	end of "VHVLINE.ASM"
;
