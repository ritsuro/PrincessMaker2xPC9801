; "VGAPOWER.ASM" PS55Z/S14 make by R.H 1991/06/20
;
;
;	VGA handler.
;
;	(code01 gate call)
;
; VL subroutine.

INCLUDE	TSTSET.INC

IN_VGAW	MACRO	AA,NUM
;same;	IN	AX,NUM
	PUSH	DX
	MOV	DX,NUM			;
	CALL	IN_VGA_WPORT		; in  port word VGA.
	POP	DX
	ENDM

OUTVGAW	MACRO	NUM,AA
;same;	OUT	NUM,AX
	PUSH	DX
	MOV	DX,NUM			;
	CALL	OUT_VGA_WPORT		; out port word VGA.
	POP	DX
	ENDM



VRAM_ADJUST	EQU	00		; vram adjust.
VRAM_BANK_FLD	EQU	00000111B	; vram bank feild.
VRAM_BANK_MASK	EQU	11111000B	; vram bank mask.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	C1VV_SETUP_EGA		; setup EGA mode.
PUBLIC	C1VV_SETUP_VGA		; setup VGA mode.
PUBLIC	C1VV_SETUP_RET		; video mode return.
PUBLIC	C1VV_PUT_MODE_SET	; put mode standerd.
PUBLIC	C1VV_PAL_TO_REG_SET	; palet nunber to color registar set.
PUBLIC	C1VV_PLEAN_SLCT		; plean select.
PUBLIC	C1VV_BANK_CHG_DX	; vram bank check & chenge.(WRITE) DX
PUBLIC	C1VV_BANK_XCG_DX	; vram bank check & chenge.(READ/WRITE) DX
PUBLIC	C1VV_BANK_XCG_ES	; vram bank check & chenge.(READ/WRITE) ES
PUBLIC	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
PUBLIC	C1VV_BANK_PLN_DS	; vram bank check & chenge.(READ) DS
PUBLIC	C1VV_BANK_FULL_DX	; vram bank check & full. DX
PUBLIC	C1VV_MASK_SET		; vram put mask set.
PUBLIC	C1VV_MODE_PSET		; vram put mode PSET.
PUBLIC	C1VV_MODE_AND		; vram put mode AND.
PUBLIC	C1VV_MODE_OR		; vram put mode OR.
PUBLIC	C1VV_MODE_XOR		; vram put mode XOR.
PUBLIC	C1VV_BANK_CHK		; vram bank check. DX
PUBLIC	C1VV_MODE_PIXEL		; vram pixel set mode.
PUBLIC	C1VV_MODE_PIXEL_STOP	; vram pixel set mode stop.

EXTRN	IN_VGA_WPORT:NEAR	; in  port word VGA.
EXTRN	OUT_VGA_WPORT:NEAR	; out port word VGA.

;	setup EGA mode.

C1VV_SETUP_EGA	PROC	NEAR
	MOV	AH,0FH			; get mode.
	INT	10H			; graph bios.
	MOV	BYTE PTR VSTDMODE,AL	; video standard mode.

	MOV	AL,10H			; disply mode.
	MOV	AH,00H			; mode set.
	INT	10H			; graph bios.
	MOV	VMODE,10H		; video mode.
	RET
C1VV_SETUP_EGA	ENDP


;	setup VGA mode.

C1VV_SETUP_VGA	PROC	NEAR
	MOV	AH,0FH			; get mode.
	INT	10H			; graph bios.
	MOV	BYTE PTR VSTDMODE,AL	; video standard mode.

	MOV	AL,12H			; disply mode.
	MOV	AH,00H			; mode set.
	INT	10H			; graph bios.
	MOV	VMODE,12H		; video mode.
	RET
C1VV_SETUP_VGA	ENDP


;	video mode return.

C1VV_SETUP_RET	PROC	NEAR
	MOV	AL,BYTE PTR VSTDMODE	; video standard mode.
	MOV	AH,00H			; mode set.
	INT	10H			; graph bios.
	MOV	VMODE,03H		; video mode.
	RET
C1VV_SETUP_RET	ENDP


;	put mode standerd.

C1VV_PUT_MODE_SET	PROC	NEAR

	MOV	AX,0005H	; read mode 0 / write mode 0.
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AX,0F00H	; set/reset.
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AX,0001H	; enable set/reset.
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AX,0003H	; data rotate/funtion select.
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AX,0F07H	; color don't care.
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AX,0FF08H	; bit mask.
	OUTVGAW	3CEH,AX		; address prot.

	RET
C1VV_PUT_MODE_SET	ENDP


;	palet nunber to color registar set.

C1VV_PAL_TO_REG_SET	PROC	NEAR
	MOV	PLTNUM,0		; palet.
	MOV	CX,16			;
VV_PAL_TO_REG_SET_LOOP:
	PUSH	CX

	MOV	BH,BYTE PTR PLTNUM	; palet code.
	MOV	BL,BYTE PTR PLTNUM	; palet registar number.
	MOV	AL,00H			; palet registar set.
	MOV	AH,10H			; palet set.
	INT	10H			; video bios.

	INC	PLTNUM			; palet.

	POP	CX
	LOOP	VV_PAL_TO_REG_SET_LOOP

	RET
C1VV_PAL_TO_REG_SET	ENDP


;	plean select.
;	-I- DX : vram plean select.

C1VV_PLEAN_SLCT	PROC	NEAR
	PUSH	DX
	PUSH	AX

	MOV	AH,DL			; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	POP	AX
	POP	DX
	RET
C1VV_PLEAN_SLCT	ENDP


;	vram bank check & chenge. DX
;	-I/O- DX : vram segment value.
;	VGA type bank change segment format.
;
;	 A    0    0    0   h
;	1010.0000.0000.0000.B
;		       ---- <- 0=non bank.
;		               1-15=bank chenge.

C1VV_BANK_CHG_DX	PROC	NEAR
	TEST	DX,VRAM_BANK_FLD
	JZ	VV_BANK_CHG_DX_EXIT
	PUSH	DX
	PUSH	CX
	PUSH	AX

	MOV	CL,DL
	AND	CL,VRAM_BANK_FLD	; vram plean select.
	DEC	CL
	MOV	AH,1
	SHL	AH,CL			; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	POP	AX
	POP	CX
	POP	DX
	AND	DL,VRAM_BANK_MASK	; vram bank mask.
	ADD	DX,VRAM_ADJUST		; vram adjust.
VV_BANK_CHG_DX_EXIT:
	RET
C1VV_BANK_CHG_DX	ENDP


;	vram bank check & chenge.(READ/WRITE) DX
;	-I/O- DX : vram segment value.
;	VGA type bank change segment format.
;
;	 A    0    0    0   h
;	1010.0000.0000.0000.B
;		       ---- <- 0=non bank.
;		               1-15=bank chenge.

C1VV_BANK_XCG_DX	PROC	NEAR
	TEST	DX,VRAM_BANK_FLD
	JZ	VV_BANK_XCG_DX_EXIT
	PUSH	DX
	PUSH	CX
	PUSH	AX

	MOV	CL,DL
	AND	CL,VRAM_BANK_FLD	; vram plean select.
	DEC	CL
	MOV	AH,1
	SHL	AH,CL			; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	MOV	AH,CL			; vram plean select.
	MOV	AL,4			; read map select.
	OUTVGAW	3CEH,AX			; control registar.

	POP	AX
	POP	CX
	POP	DX
	AND	DL,VRAM_BANK_MASK	; vram bank mask.
	ADD	DX,VRAM_ADJUST		; vram adjust.
VV_BANK_XCG_DX_EXIT:
	RET
C1VV_BANK_XCG_DX	ENDP


;	vram bank check & chenge.(READ/WRITE) ES
;	-I/O- ES : vram segment value.
;	VGA type bank change segment format.
;
;	 A    0    0    0   h
;	1010.0000.0000.0000.B
;		       ---- <- 0=non bank.
;		               1-15=bank chenge.

C1VV_BANK_XCG_ES	PROC	NEAR
	PUSH	DX
	MOV	DX,ES			; vram segment value.
	CALL	C1VV_BANK_XCG_DX	; vram bank check & chenge.(R/W) DX
	MOV	ES,DX			; vram segment value.
	POP	DX
	RET
C1VV_BANK_XCG_ES	ENDP


;	vram bank check & chenge. ES
;	-I/O- ES : vram segment value.
;	VGA type bank change segment format.
;
;	 A    0    0    0   h
;	1010.0000.0000.0000.B
;		       ---- <- 0=non bank.
;		               1-15=bank chenge.

C1VV_BANK_CHG_ES	PROC	NEAR
	PUSH	DX
	MOV	DX,ES			; vram segment value.
	CALL	C1VV_BANK_CHG_DX		; vram bank check & chenge. ES
	MOV	ES,DX			; vram segment value.
	POP	DX
	RET
C1VV_BANK_CHG_ES	ENDP


;	vram bank check & chenge.(READ) DS
;	-I/O- DS : vram segment value.
;	VGA type bank change segment format.
;
;	 A    0    0    0   h
;	1010.0000.0000.0000.B
;		       ---- <- 0=non bank.
;		               1-15=bank chenge.

C1VV_BANK_PLN_DS	PROC	NEAR
	PUSH	AX
	MOV	AX,DS
	TEST	AX,VRAM_BANK_FLD
	JZ	VV_BANK_PLN_DS_EXIT
	PUSH	DX
	PUSH	CX

	DEC	AL			;
	AND	AL,VRAM_BANK_FLD	; vram plean select.
	MOV	AH,AL			; vram plean select.
	MOV	AL,4			; read map select.
	OUTVGAW	3CEH,AX			; control registar.

	POP	CX
	POP	DX
	MOV	AX,DS
	AND	AL,VRAM_BANK_MASK	; vram bank mask.
	ADD	AX,VRAM_ADJUST		; vram adjust.
	MOV	DS,AX
VV_BANK_PLN_DS_EXIT:
	POP	AX
	RET
C1VV_BANK_PLN_DS	ENDP


;	vram bank check & full. DX
;	all plean allocate.
;	-I/O- DX : vram segment value.
;	VGA type bank change segment format.
;
;	 A    0    0    0   h
;	1010.0000.0000.0000.B
;		       ---- <- 0=non bank.

C1VV_BANK_FULL_DX	PROC	NEAR
	TEST	DX,VRAM_BANK_FLD
	JZ	VV_BANK_FULL_DX_EXIT
	PUSH	DX
	PUSH	AX

	MOV	AH,1111B		; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	POP	AX
	POP	DX
	AND	DL,VRAM_BANK_MASK	; vram bank mask.
	ADD	DX,VRAM_ADJUST		; vram adjust.
VV_BANK_FULL_DX_EXIT:
	RET
C1VV_BANK_FULL_DX	ENDP


;	vram put mask set.
;	-I- AH : mask pattan.

C1VV_MASK_SET	PROC	NEAR
	PUSH	AX
	MOV	AL,08H		; bit mask.
	OUTVGAW	3CEH,AX		; address prot.
	POP	AX
	RET
C1VV_MASK_SET	ENDP


;	vram put mode PSET.

C1VV_MODE_PSET	PROC	NEAR
	PUSH	AX
	MOV	AX,0003H	; data rotate/funtion select.
	OUTVGAW	3CEH,AX		; address prot.
	POP	AX
	RET
C1VV_MODE_PSET	ENDP


;	vram put mode AND.

C1VV_MODE_AND	PROC	NEAR
	PUSH	AX
	MOV	AX,0803H	; data rotate/funtion select.
	OUTVGAW	3CEH,AX		; address prot.
	POP	AX
	RET
C1VV_MODE_AND	ENDP


;	vram put mode OR.

C1VV_MODE_OR	PROC	NEAR
	PUSH	AX
	MOV	AX,1003H	; data rotate/funtion select.
	OUTVGAW	3CEH,AX		; address prot.
	POP	AX
	RET
C1VV_MODE_OR	ENDP


;	vram put mode PSET.

C1VV_MODE_XOR	PROC	NEAR
	PUSH	AX
	MOV	AX,1803H	; data rotate/funtion select.
	OUTVGAW	3CEH,AX		; address prot.
	POP	AX
	RET
C1VV_MODE_XOR	ENDP


;	vram bank check. DX
;	-I/O- DX : vram segment value.
;	-O-   AX : 0=normal,1=video memory.
;	VGA type bank change segment format.
;
;	 A    0    0    0   h
;	1010.0000.0000.0000.B
;		       ---- <- 0=non bank.
;		               1-15=bank chenge.

C1VV_BANK_CHK	PROC	NEAR
	TEST	DX,VRAM_BANK_FLD
	JZ	VV_BANK_CHK_NORMAL

	AND	DL,VRAM_BANK_MASK	; vram bank mask.
	ADD	DX,VRAM_ADJUST		; vram adjust.
	MOV	AX,1			; 1=video memory.
	RET
VV_BANK_CHK_NORMAL:
	MOV	AX,0			; 0=normal.
	RET
C1VV_BANK_CHK	ENDP


;	vram pixel set mode.
;	-I- DX : pixel color.

C1VV_MODE_PIXEL	PROC	NEAR
	PUSH	AX

	MOV	AX,0305H	; read mode 0 / write mode 3.
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AL,00H		; set/reset.
	MOV	AH,DL		;
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AX,0FF01H	; enable set/reset.
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AX,0003H	; data rotate/funtion select.
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AX,0FF08H	; bit mask.
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AX,0F02H	; map mask.
	OUTVGAW	3C4H,AX		; sequence registar.

	POP	AX
	RET
C1VV_MODE_PIXEL	ENDP


;	vram pixel set mode stop.

C1VV_MODE_PIXEL_STOP	PROC	NEAR
	PUSH	AX

	MOV	AX,0005H	; read mode 0 / write mode 0.
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AX,0F00H	; set/reset.
	OUTVGAW	3CEH,AX		; address prot.

	MOV	AX,0001H	; enable set/reset.
	OUTVGAW	3CEH,AX		; address prot.

;*;	MOV	AX,0003H	; data rotate/funtion select.
;*;	OUTVGAW	3CEH,AX		; address prot.
;*;
;*;	MOV	AX,0FF08H	; bit mask.
;*;	OUTVGAW	3CEH,AX		; address prot.

	POP	AX
	RET
C1VV_MODE_PIXEL_STOP	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

VSTDMODE	DW	0		; video standard mode.
VMODE		DW	0		; video mode.

COLNUM		DW	0		; color.
PLTNUM		DW	0		; palet.

DATA	ENDS

	END
;
;	end of "VGAPOWER.ASM"
;
