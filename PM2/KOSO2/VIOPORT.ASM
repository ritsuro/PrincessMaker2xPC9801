; "VIOPORT.ASM" PC-9801UV11 make by R.H 1991/01/17
;		1992/04/03 dual machine.
;
;	I/O port.
;
;	i486DX 33MHz wait i/o port.
;
;
;	example./ MACRO set.
;
;	EXTRN	IN_VGA_PORT:NEAR	; in  port VGA.
;	EXTRN	OUT_VGA_PORT:NEAR	; out port VGA.
;	EXTRN	IN_VGA_WPORT:NEAR	; in  port word VGA.
;	EXTRN	OUT_VGA_WPORT:NEAR	; out port word VGA.
;
;	EXTRN	IN_7220_GDC_PORT:NEAR	; in  port 7220 GDC.
;	EXTRN	OUT_7220_GDC_PORT:NEAR	; out port 7220 GDC.
;	EXTRN	IN_8259_PORT:NEAR	; in  port 8259.
;	EXTRN	OUT_8259_PORT:NEAR	; out port 8259.
;	EXTRN	IN_8255_PORT:NEAR	; in  prot 8255.
;	EXTRN	OUT_8255_PORT:NEAR	; out prot 8255.
;	EXTRN	IN_8251_PORT:NEAR	; in  prot 8251.
;	EXTRN	OUT_8251_PORT:NEAR	; out prot 8251.
;	;
;	IN_VGA	MACRO	AA,NUM
;	;same;	IN	AL,NUM
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	IN_VGA_PORT		; in  port VGA.
;		POP	DX
;		ENDM
;	;
;	OUTVGA	MACRO	NUM,AA
;	;same;	OUT	NUM,AL
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	OUT_VGA_PORT		; out port VGA.
;		POP	DX
;		ENDM
;	;
;	IN_VGAW	MACRO	AA,NUM
;	;same;	IN	AX,NUM
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	IN_VGA_WPORT		; in  port word VGA.
;		POP	DX
;		ENDM
;	;
;	OUTVGAW	MACRO	NUM,AA
;	;same;	OUT	NUM,AX
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	OUT_VGA_WPORT		; out port word VGA.
;		POP	DX
;		ENDM
;	;
;	IN_GDC	MACRO	AA,NUM
;	;same;	IN	AL,NUM
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	IN_7220_GDC_PORT	; in  port 7220 GDC.
;		POP	DX
;		ENDM
;	;
;	OUTGDC	MACRO	NUM,AA
;	;same;	OUT	NUM,AL
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	OUT_7220_GDC_PORT	; out port 7220 GDC.
;		POP	DX
;		ENDM
;	;
;	IN_8259	MACRO	AA,NUM
;	;same;	IN	AL,NUM
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	IN_8259_PORT		; in  port 8259.
;		POP	DX
;		ENDM
;	;
;	OUT8259	MACRO	NUM,AA
;	;same;	OUT	NUM,AL
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	OUT_8259_PORT		; out port 8259.
;		POP	DX
;		ENDM
;	;
;	IN_8255	MACRO	AA,NUM
;	;same;	IN	AL,NUM
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	IN_8255_PORT		; in  prot 8255.
;		POP	DX
;		ENDM
;	;
;	OUT8255	MACRO	NUM,AA
;	;same;	OUT	NUM,AL
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	OUT_8255_PORT		; out prot 8255.
;		POP	DX
;		ENDM
;	;
;	IN_8251	MACRO	AA,NUM
;	;same;	IN	AL,NUM
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	IN_8251_PORT		; in  prot 8251.
;		POP	DX
;		ENDM
;	;
;	OUT8251	MACRO	NUM,AA
;	;same;	OUT	NUM,AL
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	OUT_8251_PORT		; out prot 8251.
;		POP	DX
;		ENDM
;	;
;	OUT8253	MACRO	NUM,AA
;	;same;	OUT	NUM,AL
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	OUT_8253_PORT		; out prot 8253.
;		POP	DX
;		ENDM
;	;
;	IN_FMBORD	MACRO	AA,NUM
;	;same;	IN	AL,NUM
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	IN_FMBORD_PORT		; (far) in  prot FM sound bord.
;		POP	DX
;		ENDM
;	;
;	IN_MIDIBORD	MACRO	AA,NUM
;	;same;	IN	AL,NUM
;		PUSH	DX
;		MOV	DX,NUM			;
;		CALL	IN_MIDIBORD_PORT	; (far) in  prot MIDI bord.
;		POP	DX
;		ENDM
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01

PUBLIC	IN_VGA_PORT		; in  port VGA.
PUBLIC	OUT_VGA_PORT		; out port VGA.
PUBLIC	IN_VGA_WPORT		; in  port word VGA.
PUBLIC	OUT_VGA_WPORT		; out port word VGA.
PUBLIC	IN_7220_GDC_PORT	; in  port 7220 GDC.
PUBLIC	OUT_7220_GDC_PORT	; out port 7220 GDC.
PUBLIC	IN_8259_PORT		; in  port 8259.
PUBLIC	OUT_8259_PORT		; out port 8259.
PUBLIC	IN_8255_PORT		; in  prot 8255.
PUBLIC	OUT_8255_PORT		; out prot 8255.
PUBLIC	IN_8251_PORT		; in  prot 8251.
PUBLIC	OUT_8251_PORT		; out prot 8251.
PUBLIC	OUT_8253_PORT		; out prot 8253.
PUBLIC	IN_FMBORD_PORT		; in  prot FM sound bord.
PUBLIC	IN_MIDIBORD_PORT	; in  prot MIDI bord.

PACH_LABEL	DB	"IOPORTver0.3"

;	in  port VGA.
;	-I- DX : port number.
;	-O- AL : input data.

IN_VGA_PORT	PROC	NEAR
	IN	AL,DX
	RET
IN_VGA_PORT	ENDP

;	out port VGA.
;	-I- DX : port number.
;	    AL : output data.

OUT_VGA_PORT	PROC	NEAR
	OUT	DX,AL
	RET
OUT_VGA_PORT	ENDP

;	in  port word VGA.
;	-I- DX : port number.
;	-O- AX : input data.

IN_VGA_WPORT	PROC	NEAR
	IN	AX,DX
	RET
IN_VGA_WPORT	ENDP

;	out port word VGA.
;	-I- DX : port number.
;	    AX : output data.

OUT_VGA_WPORT	PROC	NEAR
	OUT	DX,AX
	RET
OUT_VGA_WPORT	ENDP

;	in  port 7220 GDC.
;	-I- DX : port number.
;	-O- AL : input data.

IN_7220_GDC_PORT	PROC	NEAR
	IN	AL,DX
	RET
IN_7220_GDC_PORT	ENDP

;	out port 7220 GDC.
;	-I- DX : port number.
;	    AL : output data.

OUT_7220_GDC_PORT	PROC	NEAR
	OUT	DX,AL
	RET
OUT_7220_GDC_PORT	ENDP

;	in  port 8259.
;	-I- DX : port number.
;	-O- AL : input data.

IN_8259_PORT		PROC	NEAR
	IN	AL,DX
	RET
IN_8259_PORT		ENDP

;	out port 8259.
;	-I- DX : port number.
;	    AL : output data.

OUT_8259_PORT		PROC	NEAR
	OUT	DX,AL
	RET
OUT_8259_PORT		ENDP

;	in  prot 8255.
;	-I- DX : port number.
;	-O- AL : input data.

IN_8255_PORT		PROC	NEAR
	IN	AL,DX
	RET
IN_8255_PORT		ENDP

;	out prot 8255.
;	-I- DX : port number.
;	    AL : output data.

OUT_8255_PORT		PROC	NEAR
	OUT	DX,AL
	RET
OUT_8255_PORT		ENDP

;	in  prot 8251.
;	-I- DX : port number.
;	-O- AL : input data.

IN_8251_PORT		PROC	NEAR
	IN	AL,DX
	RET
IN_8251_PORT		ENDP

;	out prot 8251.
;	-I- DX : port number.
;	    AL : output data.

OUT_8251_PORT		PROC	NEAR
	OUT	DX,AL
	RET
OUT_8251_PORT		ENDP

;	out prot 8253.
;	-I- DX : port number.
;	    AL : output data.

OUT_8253_PORT	PROC	NEAR
	OUT	DX,AL
	RET
OUT_8253_PORT	ENDP

;	in  prot FM sound bord.
;	-I- DX : port number.
;	-O- AL : input data.

IN_FMBORD_PORT		PROC	NEAR
	IN	AL,DX
	RET
IN_FMBORD_PORT		ENDP

;	in  prot MIDI bord.
;	-I- DX : port number.
;	-O- AL : input data.

IN_MIDIBORD_PORT	PROC	NEAR
	IN	AL,DX
	RET
IN_MIDIBORD_PORT	ENDP

CODE01	ENDS

	END
;
;	end of "VIOPORT.ASM"
;
