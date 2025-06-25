; "MGXTXT.ASM" 1991/04/17 R.H PC-9801UV11 make by R.H 1991
;			modify 1992/05/14 486/50
;
;	GAINAX mini font vram put routine.
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	MGXPRN			; GAINAX mini string.
PUBLIC	MGXPRNP			; GAINAX mini string.(put)

EXTRN	C1VV_BANK_XCG_ES:NEAR	; vram bank check & chenge.(READ/WRITE) ES


;	GAINAX mini string.
;	-i- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

MGXPRN	PROC	NEAR
	CALL	MIT_LOCATE		; vram location.
MGXPRN_LOOP:
	LODSB				; get char.
	CMP	AL,0			; end of string.
	JE	MGXPRN_EXIT		;
	CMP	AL,' '			; space.
	JE	MGXPRN_NEXT		;
	CALL	MIT_GETFONT_ADRS	; get font adrs.
	CALL	MIT_VRMPUT		; put vram.

MGXPRN_NEXT:
	INC	LOCATE_ADRS		; location vram address. next+.

	JMP	MGXPRN_LOOP		;
MGXPRN_EXIT:
	RET
MGXPRN	ENDP


;	GAINAX mini string.(put)
;	-i- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

MGXPRNP	PROC	NEAR
	CALL	MIT_LOCATE		; vram location.
MGXPRNP_LOOP:
	LODSB				; get char.
	CMP	AL,0			; end of string.
	JE	MGXPRNP_EXIT		;
	CMP	AL,' '			; space.
	JE	MGXPRNP_NEXT		;
	CALL	MIT_GETFONT_ADRS	; get font adrs.
	CALL	MIT_VRMPUTP		; put vram.(notput)

MGXPRNP_NEXT:				;
	INC	LOCATE_ADRS		; location vram address. next+.

	JMP	MGXPRNP_LOOP		;
MGXPRNP_EXIT:
	RET
MGXPRNP	ENDP


;	vram location.
;	-I- AX          : location x point.
;	    BX          : location y point.
;	-O- LOCATE_ADRS : location vram address.

MIT_LOCATE	PROC	NEAR
	XCHG	AX,BX
	MOV	CX,SEGVTW		; visual data plean width.
	MUL	CX			;
	ADD	AX,BX			; address = x + y
	MOV	LOCATE_ADRS,AX		; location vram address.
	RET
MIT_LOCATE	ENDP


;	get font adrs.
;	-I- AL : character code.
;	-O- BX : font address.

MIT_GETFONT_ADRS	PROC	NEAR
	CMP	AL,'$'
	JE	MIT_GETFONT_ADRS_DOLLAR
	CMP	AL,'G'
	JE	MIT_GETFONT_ADRS_G

	SUB	AL,'.'
	MOV	BL,12
	MUL	BL		; AX = AL * 12

	MOV	BX,AX
	ADD	BX,OFFSET FONT_TABLE
	RET
MIT_GETFONT_ADRS_DOLLAR:
	MOV	BX,OFFSET FONT_TABLE_DOLLAR
	RET
MIT_GETFONT_ADRS_G:
	MOV	BX,OFFSET FONT_TABLE_G
	RET
MIT_GETFONT_ADRS	ENDP


;	put vram.
;	-I- LOCATE_ADRS : location vram address.
;	    BX : font address.

MIT_VRMPUT	PROC	NEAR
	PUSH	SI		; save string pointer.

	MOV	AX,SEGVT0	; text put vram segment plean 0.
	MOV	ES,AX		;
	TEST	FONT_COLOR,0001B ; font color.
	JZ	MIT_VRMPUT_01	;
	CALL	MIT_PUTOR	; vram put 1 plean OR.
	JMP	MIT_VRMPUT_02	;
MIT_VRMPUT_01:			;
	CALL	MIT_PUTMASK	; vram put 1 plean MASK.
MIT_VRMPUT_02:			;


	MOV	AX,SEGVT1	; text put vram segment plean 1.
	MOV	ES,AX		;
	TEST	FONT_COLOR,0010B ; font color.
	JZ	MIT_VRMPUT_11	;
	CALL	MIT_PUTOR	; vram put 1 plean OR.
	JMP	MIT_VRMPUT_12	;
MIT_VRMPUT_11:			;
	CALL	MIT_PUTMASK	; vram put 1 plean MASK.
MIT_VRMPUT_12:			;


	MOV	AX,SEGVT2	; text put vram segment plean 2.
	MOV	ES,AX		;
	TEST	FONT_COLOR,0100B ; font color.
	JZ	MIT_VRMPUT_21	;
	CALL	MIT_PUTOR	; vram put 1 plean OR.
	JMP	MIT_VRMPUT_22	;
MIT_VRMPUT_21:			;
	CALL	MIT_PUTMASK	; vram put 1 plean MASK.
MIT_VRMPUT_22:			;


	MOV	AX,SEGVT3	; text put vram segment plean 3.
	MOV	ES,AX		;
	TEST	FONT_COLOR,1000B ; font color.
	JZ	MIT_VRMPUT_31	;
	CALL	MIT_PUTOR	; vram put 1 plean OR.
	JMP	MIT_VRMPUT_32	;
MIT_VRMPUT_31:			;
	CALL	MIT_PUTMASK	; vram put 1 plean MASK.
MIT_VRMPUT_32:			;

	POP	SI		;
	RET
MIT_VRMPUT	ENDP


;	vram put 1 plean OR.
;	-I- ES : put vram seggment.
;	    BX : font address.
;	    LOCATE_ADRS : location vram address.

MIT_PUTOR	PROC	NEAR
	CALL	C1VV_BANK_XCG_ES ; vram bank check & chenge.(READ/WRITE) ES

	MOV	SI,BX		; font address.
	MOV	DI,LOCATE_ADRS	; location vram address.

	MOV	DX,SEGVTW	; visual data plean width.
	DEC	DX		; next line add.

	MOV	CX,12		; 12 line.
MIT_PUTOR2:			;
	LODSB			;
	MOV	AH,ES:[DI]	;
	OR	AL,AH		; OR.
	STOSB			;
	ADD	DI,DX		; next line add.
	LOOP	MIT_PUTOR2	;
	RET
MIT_PUTOR	ENDP


;	vram put 1 plean MASK.
;	-I- ES : put vram seggment.
;	    BX : font address.
;	    LOCATE_ADRS : location vram address.

MIT_PUTMASK	PROC	NEAR
	CALL	C1VV_BANK_XCG_ES ; vram bank check & chenge.(READ/WRITE) ES

	MOV	SI,BX		; font address.
	MOV	DI,LOCATE_ADRS	; location vram address.

	MOV	DX,SEGVTW	; visual data plean width.
	DEC	DX		; next line add.

	MOV	CX,12		;
MIT_PUTMASK2:			;
	LODSB			;
	NOT	AL		; mask data.
	MOV	AH,ES:[DI]	;
	AND	AL,AH		;
	STOSB			;
	ADD	DI,DX		; next line add.
	LOOP	MIT_PUTMASK2	;
	RET
MIT_PUTMASK	ENDP


;	put vram.(notput)
;	-I- LOCATE_ADRS : location vram address.
;	    BX : font address.

MIT_VRMPUTP	PROC	NEAR
	PUSH	SI		; save string pointer.

	MOV	AX,SEGVT0	; text put vram segment plean 0.
	MOV	ES,AX		;
	CALL	MIT_PUTSET	; vram put 1 plean.

	MOV	AX,SEGVT1	; text put vram segment plean 1.
	MOV	ES,AX		;
	CALL	MIT_PUTSET	; vram put 1 plean.

	MOV	AX,SEGVT2	; text put vram segment plean 2.
	MOV	ES,AX		;
	CALL	MIT_PUTSET	; vram put 1 plean.

	MOV	AX,SEGVT3	; text put vram segment plean 3.
	MOV	ES,AX		;
	CALL	MIT_PUTSET	; vram put 1 plean.

	POP	SI		;
	RET
MIT_VRMPUTP	ENDP


;	vram put 1 plean(notput).
;	-I- ES : put vram seggment.
;	    BX : font address.
;	    LOCATE_ADRS : location vram address.

MIT_PUTSET	PROC	NEAR
	CALL	C1VV_BANK_XCG_ES ; vram bank check & chenge.(READ/WRITE) ES

	MOV	SI,BX		; font address.
	MOV	DI,LOCATE_ADRS	; location vram address.

	MOV	DX,SEGVTW	; visual data plean width.
	DEC	DX		; next line add.

	MOV	CX,12		;
MIT_PUTSET2:			;
	LODSB			; get 1 line.
	NOT	AL		; mask data.
	STOSB			;
	ADD	DI,DX		; next line add.
	LOOP	MIT_PUTSET2	;
	RET
MIT_PUTSET	ENDP


CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	FONT_COLOR:WORD		; font color.

EXTRN	SEGVT0:WORD		; visual data segment plean 0
EXTRN	SEGVT1:WORD		; visual data segment plean 1
EXTRN	SEGVT2:WORD		; visual data segment plean 2
EXTRN	SEGVT3:WORD		; visual data segment plean 3
EXTRN	SEGVTW:WORD		; visual data plean width.

LOCATE_ADRS	DW	0	; location vram address.

FONT_TABLE_DOLLAR	LABEL	BYTE
	DB	00011001B
	DB	00111111B
	DB	01111010B
	DB	01011010B
	DB	01111000B
	DB	01111000B
	DB	00011110B
	DB	01011011B
	DB	01011011B
	DB	01111010B
	DB	11111100B
	DB	00011000B

FONT_TABLE_G	LABEL	BYTE
	DB	00000000B
	DB	00000000B
	DB	00011110B
	DB	00110011B
	DB	01100000B
	DB	01100000B
	DB	01101111B
	DB	01101011B
	DB	01100011B
	DB	01110011B
	DB	00111110B
	DB	00000000B

FONT_TABLE	LABEL	BYTE

	DB	00000000B
	DB	00000000B
	DB	00000000B
	DB	00000000B
	DB	00000000B
	DB	00000000B
	DB	00000000B
	DB	00110000B
	DB	01111000B
	DB	01111000B
	DB	00110000B
	DB	00000000B

	DB	00000001B
	DB	00000010B
	DB	00000010B
	DB	00000110B
	DB	00000110B
	DB	00001100B
	DB	00001100B
	DB	00011000B
	DB	00011000B
	DB	00110000B
	DB	01100000B
	DB	10000000B

	DB	00011000B
	DB	01111110B
	DB	01100110B
	DB	11000011B
	DB	11000011B
	DB	11000011B
	DB	11000011B
	DB	11000011B
	DB	11000011B
	DB	01100110B
	DB	01111110B
	DB	00011000B

	DB	00000100B
	DB	00001100B
	DB	01111000B
	DB	00011000B
	DB	00011000B
	DB	00011000B
	DB	00011000B
	DB	00011000B
	DB	00011000B
	DB	00011000B
	DB	00111100B
	DB	01110010B

	DB	00011100B
	DB	00100110B
	DB	01000011B
	DB	01100011B
	DB	00100111B
	DB	00000110B
	DB	00001100B
	DB	00011000B
	DB	00110000B
	DB	00100000B
	DB	01111111B
	DB	01001110B

	DB	01100011B
	DB	01111111B
	DB	01000110B
	DB	00001100B
	DB	00011000B
	DB	00111100B
	DB	00000110B
	DB	00000111B
	DB	00000110B
	DB	00001100B
	DB	10011000B
	DB	01100000B

	DB	00000100B
	DB	00001100B
	DB	00011100B
	DB	00111100B
	DB	00101100B
	DB	01001100B
	DB	01001100B
	DB	10001101B
	DB	11111111B
	DB	00001100B
	DB	00011110B
	DB	00000110B

	DB	01111111B
	DB	01111110B
	DB	01000000B
	DB	01000000B
	DB	01111100B
	DB	00001110B
	DB	00000111B
	DB	00000110B
	DB	00000110B
	DB	00001100B
	DB	00011000B
	DB	01100000B

	DB	00000010B
	DB	00001100B
	DB	00011000B
	DB	00110000B
	DB	01100000B
	DB	01101110B
	DB	01110111B
	DB	01100011B
	DB	01100011B
	DB	01100011B
	DB	00110111B
	DB	00011100B

	DB	00111111B
	DB	00111111B
	DB	01000011B
	DB	00000110B
	DB	00001100B
	DB	00001000B
	DB	00011000B
	DB	00011000B
	DB	00011000B
	DB	00011100B
	DB	00011000B
	DB	00001000B

	DB	00011100B
	DB	00110110B
	DB	01100011B
	DB	01100011B
	DB	00110110B
	DB	00011100B
	DB	00110110B
	DB	01100011B
	DB	01100011B
	DB	01100011B
	DB	00110110B
	DB	00011100B

	DB	00111000B
	DB	01101100B
	DB	01000110B
	DB	11000110B
	DB	11000111B
	DB	11000111B
	DB	01111110B
	DB	00110110B
	DB	00000100B
	DB	00001100B
	DB	00011000B
	DB	00100000B

DATA	ENDS

	END
;
;	end of "MGXTXT.ASM"
;
