; "V98GRBIO.ASM" PC-9801UV11 make by R.H 1988
;	modifay 1991/01/17 R.H port I/O
;
;	98graphic bios.
;
; public subroutine.

IN_GDC	MACRO	AA,NUM
;same;	IN	AL,NUM
	PUSH	DX
	MOV	DX,NUM			;
	CALL	IN_7220_GDC_PORT	; in  port 7220 GDC.
	POP	DX
	ENDM

OUTGDC	MACRO	NUM,AA
;same;	OUT	NUM,AL
	PUSH	DX
	MOV	DX,NUM			;
	CALL	OUT_7220_GDC_PORT	; out port 7220 GDC.
	POP	DX
	ENDM


DATA	SEGMENT	PUBLIC	'DATA'

TOP_OF_UCW	LABEL	WORD
	GBON_PTN	DB	1 DUP (0)
	GBBCC		DB	1 DUP (0)
	GBDOTU		DB	1 DUP (0)
	GBDSP		DB	1 DUP (0)
	GBCPC		DB	67H,45H,23H,01H
	GBSX1		DW	1 DUP (0)
	GBSY1		DW	1 DUP (0)
	GBLNG1		DW	1 DUP (0)
	GBWDPA		DW	1 DUP (0)
	GBRBUF		DW	3 DUP (0)
	GBSX2		DW	1 DUP (0)
	GBSY2		DW	1 DUP (0)
	GBMDOT		DW	1 DUP (0)
	GBCIR		DW	1 DUP (0)
	GBLNG2		DW	1 DUP (0)
	GBLPTN		LABEL	WORD
	GBDOT1		DB	8 DUP (0)
	GBDTYP		DB	1 DUP (0)
	GBFILL		DB	1 DUP (0)
	GBGWK1		DW	1 DUP (0)
	GBGWK2		DW	1 DUP (0)
	GBGWK3		DW	1 DUP (0)
	GBGWK4		DW	1 DUP (0)
	GBGWK5		DW	1 DUP (0)
	GBGWK6		DW	1 DUP (0)
	GBGWK7		DW	1 DUP (0)
	GBGWK8		DW	1 DUP (0)
	GBGP122		DW	1 DUP (0)
	GBGP34		DW	1 DUP (0)
	GBGP56		DW	1 DUP (0)
	GBGP78		DW	1 DUP (0)
	GBGP910		DW	1 DUP (0)
	GBGP1112	DW	1 DUP (0)
	GBGP1314	DW	1 DUP (0)
	GBGP1516	DW	1 DUP (0)

			DB	800 DUP (0)
DATA	ENDS

DATA	SEGMENT	PUBLIC	'DATA'
	PUBLIC	GX1
	PUBLIC	GY1
	PUBLIC	GX2
	PUBLIC	GY2
	PUBLIC	GMODE
	PUBLIC	GCODE
	PUBLIC	GCLR
	PUBLIC	GRD

	GX1	DW	0
	GY1	DW	0
	GX2	DW	0
	GY2	DW	0
	GMODE	DW	0
	GCODE	DW	0
	GCLR	DW	0
	GRD	DW	0
DATA	ENDS

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	GDCSRT			; graphic start.
PUBLIC	GDCSTP			; graphic stop.
PUBLIC	GDCSET			; graphic mode set.
PUBLIC	GDCPLT			; palette reg set.
PUBLIC	GDCBCR			; border color set.
PUBLIC	GDCLIN			; line.
PUBLIC	GDCCIR			; circle.
PUBLIC	GDCMDE			; drawing mode set.
PUBLIC	GDCWAT			; GDC wait.
PUBLIC	GDCBOX			; box.
PUBLIC	GDCLNP			; pattern line.

EXTRN	IN_7220_GDC_PORT:NEAR	; in  port 7220 GDC.
EXTRN	OUT_7220_GDC_PORT:NEAR	; out port 7220 GDC.

; graphic start.

GDCSRT	PROC	NEAR
	MOV	AH,40H
	INT	18H
	RET
GDCSRT	ENDP

; graphic stop.

GDCSTP	PROC	NEAR
	MOV	AH,41H
	INT	18H
	RET
GDCSTP	ENDP

; graphic mode set.
; -i- GMODE :disply mode.

GDCSET	PROC	NEAR
	MOV	CH,BYTE PTR GMODE
	MOV	AH,42H
	INT	18H
	RET
GDCSET	ENDP

; palette reg set.
; -i- GCODE :color palette number.
;     GCLR  :color code.

GDCPLT	PROC	NEAR
	MOV	AH,0			;
	MOV	AL,BYTE PTR GCODE	;
	SHR	AX,1			; bx = 3 - GCODE / 2
	MOV	BX,3			;
	SUB	BX,AX			; offset = GBCPC + bx
	MOV	AH,BYTE PTR GCLR	; ah = color value.
	MOV	AL,BYTE PTR GCODE	;
	AND	AL,01H			; if GCODE=even then
	JNZ	GDCPLT1			;
	SHL	AH,1			;   shift 4  ah
	SHL	AH,1			;
	SHL	AH,1			;
	SHL	AH,1			;
	MOV	AL,BYTE PTR GBCPC[BX]	;   high nible <= ah
	AND	AL,0FH			;
	OR	AL,AH			;
	JMP	GDCPLT2			; else
GDCPLT1:				;
	MOV	AL,BYTE PTR GBCPC[BX]	;   low nible <= ah
	AND	AL,0F0H			;
	OR	AL,AH			; endif
GDCPLT2:
	MOV	BYTE PTR GBCPC[BX],AL
	MOV	BX, OFFSET TOP_OF_UCW
	MOV	AH,43H
	INT	18H
	RET
GDCPLT	ENDP

; border color.
; -i- GCLRB :border color.

GDCBCR	PROC	NEAR
	MOV	AL,BYTE PTR GCLR
	MOV	GBBCC,AL
	MOV	BX, OFFSET TOP_OF_UCW
	MOV	AH,44H
	INT	18H
	RET
GDCBCR	ENDP


; line(gx1,gy1)-(gx2,gy2),gclr
; -i- GX1,GY1 : start point.
;     GX2,GY2 : end point.
;     GCLR    : color.
;     GMODE   : disply mode.

GDCLIN	PROC	NEAR
	MOV	CH,BYTE PTR GMODE
	MOV	AL,BYTE PTR GCLR
	MOV	BYTE PTR GBON_PTN,AL	; 3 plain mode operation.
	MOV	BYTE PTR GBDOTU,AL	; 1 plain mode operation.
	MOV	AL,0
	MOV	BYTE PTR GBDSP,AL	; line direction.
	MOV	AX,WORD PTR GX1
	MOV	WORD PTR GBSX1,AX
	MOV	AX,WORD PTR GY1
	MOV	WORD PTR GBSY1,AX
	MOV	AX,WORD PTR GX2
	MOV	WORD PTR GBSX2,AX
	MOV	AX,WORD PTR GY2
	MOV	WORD PTR GBSY2,AX
	MOV	AX,0FFFFH
	MOV	WORD PTR GBLPTN,AX	; line pattan.(LINE)
	MOV	AL,00000001B
	MOV	BYTE PTR GBDTYP,AL	; drawing type.
	MOV	BX,OFFSET TOP_OF_UCW
	MOV	AH,47H
	INT	18H
	RET
GDCLIN	ENDP

; circle(gx1,gy1),gr,gclr
; -i- GX1,GY1 : center point.
;     GRD     : redius
;     GCLR    : color.
;     GMODE   : disply mode.

GDCCIR	PROC	NEAR
	MOV	CH,BYTE PTR GMODE
	MOV	AL,BYTE PTR GCLR
	MOV	BYTE PTR GBON_PTN,AL	; 3 plain mode operation.
	MOV	BYTE PTR GBDOTU,AL	; 1 plain mode operation.
	MOV	AX,0			;
	MOV	WORD PTR GBMDOT,AX	; 45 deg arc.
	MOV	AX,WORD PTR GRD		;
	MOV	WORD PTR GBCIR,AX	; redius.
	CALL	SQRDIV			; square root division.
	MOV	WORD PTR GBLNG1,AX	;
	MOV	AX,0FFFFH		;
	MOV	WORD PTR GBLPTN,AX	; line pattan.
	MOV	AL,00000100B		;
	MOV	BYTE PTR GBDTYP,AL	; drawing type.(CIRCLE)
	MOV	BX,OFFSET TOP_OF_UCW

	MOV	AX,WORD PTR GX1		;
	SUB	AX,WORD PTR GRD		;
	MOV	WORD PTR GBSX1,AX	; sx = x + r
	MOV	AX,WORD PTR GY1		;
	MOV	WORD PTR GBSY1,AX	; sy = y
	MOV	BYTE PTR GBDSP,0	; arc direction.
	MOV	AH,48H
	INT	18H
	MOV	BYTE PTR GBDSP,3	; arc direction.
	MOV	AH,48H
	INT	18H

	MOV	AX,WORD PTR GX1		;
	ADD	AX,WORD PTR GRD		;
	MOV	WORD PTR GBSX1,AX	; sx = x + r
	MOV	AX,WORD PTR GY1		;
	MOV	WORD PTR GBSY1,AX	; sy = y
	MOV	BYTE PTR GBDSP,4	; arc direction.
	MOV	AH,48H
	INT	18H
	MOV	BYTE PTR GBDSP,7	; arc direction.
	MOV	AH,48H
	INT	18H

	MOV	AX,WORD PTR GX1		;
	MOV	WORD PTR GBSX1,AX	; sx = x
	MOV	AX,WORD PTR GY1		;
	SUB	AX,WORD PTR GRD		;
	MOV	WORD PTR GBSY1,AX	; sy = y + r
	MOV	BYTE PTR GBDSP,6	; arc direction.
	MOV	AH,48H
	INT	18H
	MOV	BYTE PTR GBDSP,1	; arc direction.
	MOV	AH,48H
	INT	18H

	MOV	AX,WORD PTR GX1		;
	MOV	WORD PTR GBSX1,AX	; sx = x
	MOV	AX,WORD PTR GY1		;
	ADD	AX,WORD PTR GRD		;
	MOV	WORD PTR GBSY1,AX	; sy = y + r
	MOV	BYTE PTR GBDSP,2	; arc direction.
	MOV	AH,48H
	INT	18H
	MOV	BYTE PTR GBDSP,5	; arc direction.
	MOV	AH,48H
	INT	18H

	RET
GDCCIR	ENDP

; draw mode set.
; -i- GMODE :graphic mode.

GDCMDE	PROC	NEAR
	MOV	CH,BYTE PTR GMODE
	MOV	AH,4AH
	INT	18H
GDCMDE	ENDP

; GDC wait.

GDCWAT	PROC	NEAR
GDCWAT1:			; FIFO=empty wait.
	IN_GDC	AL,0A0H		; GDC status port.
	TEST	AL,04H		;
	JZ	GDCWAT1		;

	MOV	CX,6		;
	LOOP	$		; CPU 54+5 clock wait.
GDCWAT2:
	IN_GDC	AL,0A0H		; Not-drawing wait.
	TEST	AL,08H		;
	JNZ	GDCWAT2		;

	RET
GDCWAT	ENDP


; common routine.

; square root division.
; -i/o- AX : value

SQRDIV	PROC	NEAR
	PUSH	DX

	MOV	DX,AX	;
	SHL	AX,1	;
	SHL	AX,1	;
	ADD	AX,DX	;	AX = AX * 7
	ADD	AX,DX	;
	ADD	AX,DX	;

	SHR	DX,1	;
	SHR	DX,1	;
	SHR	DX,1	;	DX = DX / 16
	SHR	DX,1	;

	ADD	AX,DX	;	AX = AX + DX

	CWD		;
	DIV	SQRDIV1	;	AX = AX / 10

	POP	DX
	RET
SQRDIV	ENDP

DATA	SEGMENT	PUBLIC	'DATA'
SQRDIV1	DW	10
DATA	ENDS

; box(gx1,gy1)-(gx2,gy2),gclr
; -i- GX1,GY1 : start point.
;     GX2,GY2 : end point.
;     GCLR    : color.
;     GMODE   : disply mode.

GDCBOX	PROC	NEAR
	MOV	CH,BYTE PTR GMODE
	MOV	AL,BYTE PTR GCLR
	MOV	BYTE PTR GBON_PTN,AL	; 3 plain mode operation.
	MOV	BYTE PTR GBDOTU,AL	; 1 plain mode operation.
	MOV	AL,0
	MOV	BYTE PTR GBDSP,AL	; line direction.
	MOV	AX,WORD PTR GX1
	MOV	WORD PTR GBSX1,AX
	MOV	AX,WORD PTR GY1
	MOV	WORD PTR GBSY1,AX
	MOV	AX,WORD PTR GX2
	MOV	WORD PTR GBSX2,AX
	MOV	AX,WORD PTR GY2
	MOV	WORD PTR GBSY2,AX
	MOV	AX,0FFFFH
	MOV	WORD PTR GBLPTN,AX	; line pattan.
	MOV	AL,00000010B
	MOV	BYTE PTR GBDTYP,AL	; drawing type.(BOX)
	MOV	BX,OFFSET TOP_OF_UCW
	MOV	AH,47H
	INT	18H
	RET
GDCBOX	ENDP


; pattern line.
; line(gx1,gy1)-(gx2,gy2),gclr
; -i- GX1,GY1 : start point.
;     GX2,GY2 : end point.
;     GCLR    : color.
;     GMODE   : disply mode.
;     GCODE   : line pattern.

GDCLNP	PROC	NEAR
	MOV	CH,BYTE PTR GMODE
	MOV	AL,BYTE PTR GCLR
	MOV	BYTE PTR GBON_PTN,AL	; 3 plain mode operation.
	MOV	BYTE PTR GBDOTU,AL	; 1 plain mode operation.
	MOV	AL,0
	MOV	BYTE PTR GBDSP,AL	; line direction.
	MOV	AX,WORD PTR GX1
	MOV	WORD PTR GBSX1,AX
	MOV	AX,WORD PTR GY1
	MOV	WORD PTR GBSY1,AX
	MOV	AX,WORD PTR GX2
	MOV	WORD PTR GBSX2,AX
	MOV	AX,WORD PTR GY2
	MOV	WORD PTR GBSY2,AX
	MOV	AX,GCODE
	MOV	WORD PTR GBLPTN,AX	; line pattan.(LINE)
	MOV	AL,00000001B
	MOV	BYTE PTR GBDTYP,AL	; drawing type.
	MOV	BX,OFFSET TOP_OF_UCW
	MOV	AH,47H
	INT	18H
	RET

GDCLNP	ENDP

CODE01	ENDS

END

;
;	end of "V98GRBIO.ASM"
;
