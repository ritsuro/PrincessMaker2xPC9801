; "MIBTXT.ASM" 1990/07/08 R.H PC-9801UV11 make by R.H 1990
;			modify 1992/05/14 486/50
;
;	big size text vram put routine.	16x16
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	MBTPRN			; BIG string. (null=end of string)

EXTRN	C1VV_BANK_XCG_ES:NEAR	; vram bank check & chenge.(READ/WRITE) ES


; BIG string.
; -i- DS:SI   : string. (null=end of string)
;     AX      : location x point.
;     BX      : location y point.

MBTPRN	PROC	NEAR
	CALL	MBT_LOCATE		; vram location.
MBTPRN_LOOP:
	LODSB				; get char.
	CMP	AL,0			; end of string.
	JE	MBTPRN_EXIT		;
	CALL	MBT_GETFONT_ADRS	; get font adrs.
	CALL	MBT_VRMPUT		; put vram.

	ADD	LOCATE_ADRS,2		; location vram address. next+.

	JMP	MBTPRN_LOOP		;
MBTPRN_EXIT:
	RET
MBTPRN	ENDP


;	vram location.
;	-I- AX          : location x point.
;	    BX          : location y point.
;	-O- LOCATE_ADRS : location vram address.

MBT_LOCATE	PROC	NEAR
	XCHG	AX,BX
	MOV	CX,SEGVTW		; visual data plean width.
	MUL	CX			;
	ADD	AX,BX			; address = x + y
	ADD	AX,SEGVTW		; 1 LINE shift
	MOV	LOCATE_ADRS,AX		; location vram address.
	RET
MBT_LOCATE	ENDP



;	get font adrs.
;	-I- AL : character code.
;	-O- BX : font address.

MBT_GETFONT_ADRS	PROC	NEAR
	MOV	BL,AL		; character code.
	MOV	BH,0		;

	SUB	BL,20H		; + 20H (space code)
	SHL	BX,1		;
	SHL	BX,1		;
	SHL	BX,1		; * 8

	ADD	BX,OFFSET FONT_TABLE
	RET
MBT_GETFONT_ADRS	ENDP



;	put vram.
;	-I- LOCATE_ADRS : location vram address.
;	    BX : font address.

MBT_VRMPUT	PROC	NEAR
	PUSH	SI

	MOV	AX,SEGVT0	; text put vram segment plean 0.
	MOV	ES,AX		;
	TEST	FONT_COLOR,0001B ; font color.
	JZ	MBT_VRMPUT_01	;
	CALL	MBT_PUTOR	; vram put 1 plean OR.
	JMP	MBT_VRMPUT_02	;
MBT_VRMPUT_01:			;
	CALL	MBT_PUTAND	; vram put 1 plean AND.
MBT_VRMPUT_02:			;

	MOV	AX,SEGVT1	; text put vram segment plean 1.
	MOV	ES,AX		;
	TEST	FONT_COLOR,0010B ; font color.
	JZ	MBT_VRMPUT_11	;
	CALL	MBT_PUTOR	; vram put 1 plean OR.
	JMP	MBT_VRMPUT_12	;
MBT_VRMPUT_11:			;
	CALL	MBT_PUTAND	; vram put 1 plean AND.
MBT_VRMPUT_12:			;

	MOV	AX,SEGVT2	; text put vram segment plean 2.
	MOV	ES,AX		;
	TEST	FONT_COLOR,0100B ; font color.
	JZ	MBT_VRMPUT_21	;
	CALL	MBT_PUTOR	; vram put 1 plean OR.
	JMP	MBT_VRMPUT_22	;
MBT_VRMPUT_21:			;
	CALL	MBT_PUTAND	; vram put 1 plean AND.
MBT_VRMPUT_22:			;

	MOV	AX,SEGVT3	; text put vram segment plean 3.
	MOV	ES,AX		;
	TEST	FONT_COLOR,1000B ; font color.
	JZ	MBT_VRMPUT_31	;
	CALL	MBT_PUTOR	; vram put 1 plean OR.
	JMP	MBT_VRMPUT_32	;
MBT_VRMPUT_31:			;
	CALL	MBT_PUTAND	; vram put 1 plean AND.
MBT_VRMPUT_32:			;
	POP	SI
	RET
MBT_VRMPUT	ENDP


;	vram put 1 plean OR.
;	-I- ES : put vram seggment.
;	    BX : font address.
;	    LOCATE_ADRS : location vram address.

MBT_PUTOR	PROC	NEAR
	CALL	C1VV_BANK_XCG_ES ; vram bank check & chenge.(READ/WRITE) ES

	MOV	SI,BX		; font address.
	MOV	DI,LOCATE_ADRS	; location vram address.

	MOV	BP,SEGVTW	; visual data plean width.
	DEC	BP		; -2
	DEC	BP		;

	MOV	CX,8		;
MBT_PUTOR2:			;
	LODSB			; get 1 line.
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2

	XCHG	DL,DH		;

	MOV	AX,ES:[DI]	;
	OR	AX,DX		;
	STOSW			;
	ADD	DI,BP		; visual data plean width.

	MOV	AX,ES:[DI]	;
	OR	AX,DX		;
	STOSW			;
	ADD	DI,BP		; visual data plean width.

	LOOP	MBT_PUTOR2	;
	RET
MBT_PUTOR	ENDP


;	vram put 1 plean AND.
;	-I- ES : put vram seggment.
;	    BX : font address.
;	    LOCATE_ADRS : location vram address.

MBT_PUTAND	PROC	NEAR
	CALL	C1VV_BANK_XCG_ES ; vram bank check & chenge.(READ/WRITE) ES

	MOV	SI,BX		; font address.
	MOV	DI,LOCATE_ADRS	; location vram address.

	MOV	BP,SEGVTW	; visual data plean width.
	DEC	BP		; -2
	DEC	BP		;

	MOV	CX,8		;
MBT_PUTAND2:			;
	LODSB			; get 1 line.
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2
	RCR	AL,1		; dot -> cf
	RCR	DX,1		;  cf -> BX
	SAR	DX,1		;  dot * 2

	XCHG	DL,DH		;

	NOT	DX		;

	MOV	AX,ES:[DI]	;
	AND	AX,DX		;
	STOSW			;
	ADD	DI,BP		; visual data plean width.

	MOV	AX,ES:[DI]	;
	AND	AX,DX		;
	STOSW			;
	ADD	DI,BP		; visual data plean width.

	LOOP	MBT_PUTAND2	;
	RET
MBT_PUTAND	ENDP


CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	FONT_TABLE:BYTE		; FONT1.INC character pattan 1.
EXTRN	FONT_COLOR:WORD		; font color.

EXTRN	SEGVT0:WORD		; visual data segment plean 0
EXTRN	SEGVT1:WORD		; visual data segment plean 1
EXTRN	SEGVT2:WORD		; visual data segment plean 2
EXTRN	SEGVT3:WORD		; visual data segment plean 3
EXTRN	SEGVTW:WORD		; visual data plean width.

LOCATE_ADRS	DW	0	; location vram address.

DATA	ENDS

	END
;
;	end of "MIBTXT.ASM"
;
