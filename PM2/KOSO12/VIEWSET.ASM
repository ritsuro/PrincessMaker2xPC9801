; "VIEWSET.ASM" PS55Z/S14 make by R.H 1991/09/17
;
;
;	V I E W    l i b r a l y .
;
;
; ÉeÉLÉXÉgëÆê´ÅEÇoÇbÅ|ÇXÇWÇOÇPÇÃèÍçá
;
;	ÉAÉgÉäÉrÉÖÅ[Égï\åª
;	7   6   5   4     3     2     1    0____
;	ÇfÅ@ÇqÅ@ÇaÅ@ÇaÇfÅ@ÇtÇkÅ@ÇqÇuÅ@ÇaÇkÅ@ÇrÇs
;	Å@Å@Å@Å@Å@Å@ÇuÇk
;
; ÉeÉLÉXÉgëÆê´ÅEÇhÇaÇlÅ|ÇoÇbÇÃèÍçá
;
;	ÉAÉgÉäÉrÉÖÅ[Égï\åª
;	7   6   5   4   3   2   1   0
;	ñæÅ@ÇqÅ@ÇfÅ@ÇaÅ@ñæÅ@ÇqÅ@ÇfÅ@Ça
;	îwåi----------Å@ï∂éö----------
;
;
;
; public subroutine.

INCLUDE	TSTSET.INC
INCLUDE	MACHINE.INC

STRING_LEN 	EQU	70	; string length.

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	VW_FREAM			; view/fream.
PUBLIC	VW_ERRBOX			; view/error box.
PUBLIC	VW_INPUT			; view/input.
PUBLIC	VW_PRINT			; view/print.
PUBLIC	VW_CHPUT			; view/put character.
PUBLIC	VW_LOCATE			; view/locate.
PUBLIC	VW_TXCOLR			; view/text color.
PUBLIC	VW_CLS				; view/cls.
PUBLIC	VW_USERKEY			; view/user key.
PUBLIC	VW_INPUT_LENG			; view/input length set.

EXTRN	CCCIN:NEAR		; console in.
EXTRN	CCCINB:NEAR		; console in + break on.
EXTRN	CCCOUT:NEAR		; print character.
EXTRN	CCCRD:NEAR		; read key buffer.
EXTRN	CCCLOC:NEAR		; locate.
EXTRN	CCCCOL:NEAR		; text color.
IF PC98
EXTRN	CCCCLA:NEAR		; text color&attribute.
ENDIF
EXTRN	CCCFKY:NEAR		; function key.

STRING_INPUT	MACRO		; string input
	CALL	CCCINB		; console in + break on.
;*;	CALL	CCCIN		; console in.
	ENDM
PUTCHAR		MACRO		; character put.
	CALL	CCCOUT		; print character.
	ENDM
CHR_LOCATE	MACRO		; locate.
	CALL	CCCLOC		; locate.
	ENDM


; ****************************************************
;	view/fream.
; ****************************************************

VW_FREAM	PROC	NEAR

IF PC98
	MOV	VX1,0			; source point x1.
	MOV	VY1,0			; source point y1.
	MOV	VX2,79			; length x2.
	MOV	VY2,23			; length y2.
	MOV	DX,00000001B		; attribute.
	CALL	ATRBOX			; text attribute box.

	MOV	VX1,0			; source point x1.
	MOV	VY1,24			; source point y1.
	MOV	VX2,79			; length x2.
	MOV	VY2,24			; length y2.
	MOV	DX,00000001B		; attribute.
	CALL	ATRBOX			; text attribute box.
ENDIF

IF IBMPC
	MOV	CH,0			; up line.
	MOV	CL,0			; left side.
	MOV	DH,23			; under line.
	MOV	DL,79			; right side.
	MOV	BH,00011111B		; text color.
	MOV	AL,0			; 1 line.
	MOV	AH,06H			; window scroll up.
	INT	10H			; IBM bios.

	MOV	CH,24			; up line.
	MOV	CL,0			; left side.
	MOV	DH,24			; under line.
	MOV	DL,79			; right side.
	MOV	BH,01111111B		; text color.
	MOV	AL,0			; 1 line.
	MOV	AH,06H			; window scroll up.
	INT	10H			; IBM bios.
ENDIF

	MOV	AX,0			; x
	MOV	BX,0			; y
	CALL	CCCLOC			; locate.
	RET
VW_FREAM	ENDP


; ****************************************************
;	view/error box.
; ****************************************************

VW_ERRBOX	PROC	NEAR
IF PC98
	MOV	VX1,17			; start point x.
	MOV	VY1,10			; start point y.
	MOV	VX2,64			; end point x.
	MOV	VY2,14			; end point y.
	MOV	DX,11000001B		; attribute.
	CALL	ATRBOX			; text attribute box.
	MOV	DX,87H			; character.
	CALL	TXTBOX			; text box.

	MOV	VX1,18			; start point x.
	MOV	VY1,11			; start point y.
	MOV	VX2,63			; end point x.
	MOV	VY2,13			; end point y.
	MOV	DX,11100001B		; attribute.
	CALL	ATRBOX			; text attribute box.
	MOV	DX,20H			; character.
	CALL	TXTBOX			; text box.
ENDIF
	RET
VW_ERRBOX	ENDP


; ****************************************************
;	view/input.
;	-O- SI : string address.
;	    AX : 0=normal,3=F3,11=ESC
; ****************************************************

VW_INPUT	PROC	NEAR
	PUSH	BX
	PUSH	CX
	PUSH	DX

	MOV	AX,STRING_MAX		; string character max.
	MOV	STRING,AL		;
	MOV	DX,OFFSET STRING	;

	STRING_INPUT			; string input

	MOV	SI,OFFSET STRING
	INC	SI
	MOV	BL,[SI]
	MOV	BH,0
	INC	SI
	MOV	BYTE PTR [SI][BX],0	;end of string.

	POP	DX
	POP	CX
	POP	BX
	RET
VW_INPUT	ENDP


; ****************************************************
;	view/print.
;	-I- SI : string address.
; ****************************************************

VW_PRINT	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
PRINT1:
	MOV	AL,[SI]
	CMP	AL,0	;end of string
	JE	PRINT2

	CALL	VW_CHPUT			; view/put character.

	INC	SI
	JMP	PRINT1
PRINT2:
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
VW_PRINT	ENDP


; ****************************************************
;	view/put character.
; ****************************************************

VW_CHPUT	PROC	NEAR
	PUSH	DX
	PUSH	CX
	MOV	DL,AL			; put char=DL
	PUTCHAR				; character put.
	POP	CX
	POP	DX
	RET
VW_CHPUT	ENDP


; ****************************************************
;	view/locate.
; ****************************************************

VW_LOCATE	PROC	NEAR
	CHR_LOCATE		; locate.
	RET
VW_LOCATE	ENDP


; ****************************************************
;	view/text color.
;	-I- AX : text color.
; ****************************************************

VW_TXCOLR	PROC	NEAR
IF PC98
	CALL	CCCCLA				; text color&attribute.
ENDIF
IF IBMPC
	TEST	AX,100B
	JZ	VW_TXCOLR_2
	SHR	AX,1
	SHR	AX,1
	SHR	AX,1
	SHR	AX,1
	SHR	AX,1
	XOR	AX,111B
	OR	AX,11110000B
	JMP	VW_TXCOLR_4
VW_TXCOLR_2:
	SHR	AX,1
	SHR	AX,1
	SHR	AX,1
	SHR	AX,1
	SHR	AX,1
	OR	AX,11000B
VW_TXCOLR_4:
	CALL	CCCCOL				; text color.
ENDIF
	RET
VW_TXCOLR	ENDP


; ****************************************************
;	view/cls.
; ****************************************************

VW_CLS	PROC	NEAR

IF PC98
	MOV	ES,ATTR_VRAM_SEG	; attribute vram address.
	MOV	DI,0			;
	MOV	CX,80*25		;
	MOV	AX,11100001B		; attribute.
	REP	STOSW			; char=2byte.

	MOV	ES,TEXT_VRAM_SEG	; text vram address.
	MOV	DI,0			;
	MOV	CX,80*25		;
	MOV	AX,20H			; text.
	REP	STOSW			; char=2byte.
ENDIF

IF IBMPC
	MOV	CH,0			; up line.
	MOV	CL,0			; left side.
	MOV	DH,24			; under line.
	MOV	DL,79			; right side.
	MOV	BH,00001111B		; attrbute.
	MOV	AL,0			; 1 line.
	MOV	AH,06H			; window scroll up.
	INT	10H			; IBM bios.
ENDIF
	MOV	AX,0			; x
	MOV	BX,0			; y
	CALL	CCCLOC			; locate.
	RET
VW_CLS	ENDP


; ****************************************************
;	view/user key.
;	-O- AX : 1-10=F.key,11=ESC,12=ENTER
; ****************************************************

VW_USERKEY	PROC	NEAR

VW_USERKEY_CLR:
	CALL	CCCRD			; read key buffer.
	CMP	DX,0			; character code. (NULL=none)
	JNE	VW_USERKEY_CLR		;

VW_USERKEY_LOOP:
	CALL	CCCFKY			; function key.
	CMP	AX,0			;
	JE	VW_USERKEY_LOOP		;
	RET
VW_USERKEY	ENDP


; ****************************************************
;	view/input length set.
;	-I- AX : string max length.
; ****************************************************

VW_INPUT_LENG	PROC	NEAR
	INC	AX				; leng + CR
	CMP	AX,STRING_LEN			; string length.
	JBE	VW_INPUT_LENG_5			;
	MOV	AX,STRING_LEN			; string length.
VW_INPUT_LENG_5:
	MOV	STRING_MAX,AX			; string character max.
	RET
VW_INPUT_LENG	ENDP


; ****************************************************
;	text box.
;	-I- VX1,VY1 : start point.
;	    VX2,VY2 : end point.
;	    DX      : character.
; ****************************************************
IF PC98
TXTBOX	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DI
	PUSH	SI

	MOV	DI,VY1			;
	SHL	DI,1			;
	SHL	DI,1			;
	SHL	DI,1			;
	SHL	DI,1			;
	MOV	AX,DI			;
	SHL	DI,1			;
	SHL	DI,1			;
	ADD	DI,AX			; di = vy1 * 80 * 2
	SHL	DI,1			;

	MOV	AX,VX1			;
	SHL	AX,1			;
	ADD	DI,AX			; di = di + ( vx1 * 2 )
	MOV	SI,DI			; si = di

	MOV	CX,VY2			;
	SUB	CX,VY1			;
	INC	CX			; cx = Vy2 - Vy1 + 1

	MOV	BX,VX2			;
	SUB	BX,VX1			;
	INC	BX			; bx  = Vx2 - Vx1 + 1
	MOV	AH,0			;
	MOV	AL,DL			; set attribute.
TXTBOX1:				;
	PUSH	CX			;
	MOV	DI,SI			; si = di
	MOV	ES,TEXT_VRAM_SEG	; text vram address.
	MOV	CX,BX			;
	REP	STOSW			; GDC word address.

	ADD	SI,160			; GDC word address.
	POP	CX
	LOOP	TXTBOX1

	POP	SI
	POP	DI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
TXTBOX	ENDP
ENDIF


; ****************************************************
;	text attribute box.
;	-I- VX1,VY1 : start point.
;	    VX2,VY2 : end point.
;	    DX      : attribute.
; ****************************************************
IF PC98
ATRBOX	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DI
	PUSH	SI

	MOV	DI,VY1			;
	SHL	DI,1			;
	SHL	DI,1			;
	SHL	DI,1			;
	SHL	DI,1			;
	MOV	AX,DI			;
	SHL	DI,1			;
	SHL	DI,1			;
	ADD	DI,AX			; di = vy1 * 80 * 2
	SHL	DI,1			;

	MOV	AX,VX1			;
	SHL	AX,1			;
	ADD	DI,AX			; di = di + ( vx1 * 2 )
	MOV	SI,DI			; si = di

	MOV	CX,VY2			;
	SUB	CX,VY1			;
	INC	CX			; cx = Vy2 - Vy1 + 1

	MOV	BX,VX2			;
	SUB	BX,VX1			;
	INC	BX			; bx  = Vx2 - Vx1 + 1
	MOV	AH,0			;
	MOV	AL,DL			; set attribute.
ATRBOX1:				;
	PUSH	CX			;
	MOV	DI,SI			; si = di
	MOV	ES,ATTR_VRAM_SEG	; attribute vram address.
	MOV	CX,BX			;
	REP	STOSW			; GDC word address.

	ADD	SI,160			; GDC word address.
	POP	CX
	LOOP	ATRBOX1

	POP	SI
	POP	DI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
ATRBOX	ENDP
ENDIF

; ****************************************************
;	DATA.
; ****************************************************

EXTRN	STRING:BYTE				; buffer length.

		EVEN
IF PC98
TEXT_VRAM_SEG	DW	0A000H			; text vram address.
ATTR_VRAM_SEG	DW	0A200H			; attribute vram address.
ENDIF

VX1		DW	0			; source point x1.
VY1		DW	0			; source point y1.
VX2		DW	0			; length x2.
VY2		DW	0			; length y2.

STRING_MAX	DW	STRING_LEN		; string character max.
;*;STRING	DB	STRING_LEN		; buffer length.
;*;		DB	0			; character length.
;*;		DB	STRING_LEN DUP (0)	; string.

CODE	ENDS

	END
;
;	end of "VIEWSET.ASM"
;
