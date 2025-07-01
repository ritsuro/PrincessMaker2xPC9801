; "CONSOLE.ASM" PC-9801UV11 make by R.H 1989/11/04
;
;
;	E X E L O A D    c o n s o l e  I/O.
;
;	PC9801.
;
; public subroutine.

INCLUDE	MACHINE.INC

IF	PC98

JMPEQ	MACRO	LBL
	LOCAL	LL
	JNE	LL
	JMP	LBL
LL:
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	CCCIN		; console in.
PUBLIC	CCCOUT		; print character.
PUBLIC	CCCRD		; read key buffer.
PUBLIC	CCCLOC		; locate.
PUBLIC	CCCCOL		; text color.
PUBLIC	CCCCLA		; text color&attribute.
PUBLIC	CCCCGT		; text color&attribute get.
PUBLIC	CCCINB		; console in + break on.
PUBLIC	CCCFKY		; function key.


NULL		EQU	0	; null code.
CHR_BS		EQU	08H	; back space.
CHR_TAB		EQU	09H	; TAB code.
CHR_LF		EQU	0AH	; line feed.
CHR_CR		EQU	0DH	; calig return.
CHR_DEL		EQU	10H	; DEL.
CHR_BACK	EQU	1DH	; back cursole.
CHR_SPACE	EQU	20H	; space.
CNTL_UP		EQU	1FH	; control upper.
END_OF_STR	EQU	0	; end of string.
TABLEN		EQU	8	; TAB colum.

PROMPT_NEXT	EQU	1000	; prompt interval.

;	console in.
;	-I/O- DS:[DX]  : string buffer
;		  -i-  ds:[dx][0]=buffer length - 2.
;		  -o-  ds:[dx][1]=input character length.
;		   ( 0Dh=end.of.string )

CCCIN	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	PUSH	DS
	PUSH	ES

	MOV	SI,DX
	CALL	KEYIN			; keybord input string.

	POP	ES
	POP	DS
	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
CCCIN	ENDP


;	print character.
;	-I- DL : character code.

CCCOUT	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	PUSH	DS
	PUSH	ES

	MOV	DH,0
	MOV	CHAR,DX
	CALL	CRTOUT			; CRT output.

	POP	ES
	POP	DS
	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
CCCOUT	ENDP


;	read key buffer.
;	-O- DX : character code. (NULL=none)

CCCRD	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX

	PUSH	SI
	PUSH	DI
	PUSH	BP
	PUSH	DS
	PUSH	ES

EXTRN CSLOFF:NEAR
CALL CSLOFF

	CALL	INKEY			; key buffer read.

	POP	ES
	POP	DS
	POP	BP
	POP	DI
	POP	SI

	POP	CX
	POP	BX
	POP	AX
	RET
CCCRD	ENDP


;	locate.
;	-I- AX : locate x.
;	    BX : locate y.

CCCLOC	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	PUSH	DS
	PUSH	ES

	MOV	LOCX,AX
	MOV	LOCY,BX

	POP	ES
	POP	DS
	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
CCCLOC	ENDP



;	text color.
;	-I- AX : text color.

CCCCOL	PROC	NEAR
	PUSH	AX
	MOV	AH,0
	AND	AL,111B
	ROR	AL,1
	ROR	AL,1
	ROR	AL,1
	OR	AL,1B				; not ST.
	MOV	TEXT_COLOR,AX			; text color.
	POP	AX
	RET
CCCCOL	ENDP


;	text color&attribute.
;	-I- AX : text color&attribute.

CCCCLA	PROC	NEAR
	MOV	TEXT_COLOR,AX			; text color.
	RET
CCCCLA	ENDP


;	text color&attribute get.
;	-O- AX : text color&attribute.

CCCCGT	PROC	NEAR
	MOV	AX,TEXT_COLOR			; text color.
	RET
CCCCGT	ENDP


;	console in + break on.
;	-I/O- DS:[DX]  : string buffer
;		  -i-  ds:[dx][0]=buffer length - 2.
;		  -O-  ds:[dx][1]=input character length.
;		   ( 0Dh=end.of.string )
;	-O- AX : 0=normal,3=F3,11=ESC

CCCINB	PROC	NEAR
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	PUSH	DS
	PUSH	ES

	MOV	BREAK_ON,1		; break on flag.

	MOV	SI,DX
	CALL	KEYIN			; keybord input string.

	MOV	BREAK_ON,0		; break on flag.

	POP	ES
	POP	DS
	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	RET
CCCINB	ENDP


;	text color.
;	-O- AX : 0=none,1=F1,2=F2,3=F3,4=F4,5=F5,6=F6,7=F7,8=F8,9=F9,10=F10
;			11=ESC

CCCFKY	PROC	NEAR
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	PUSH	DS
	PUSH	ES

	CALL	FUNCTION_KEY		; function key.

	POP	ES
	POP	DS
	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	RET
CCCFKY	ENDP


;	keybord input string.
;	-I-   BREAK_ON : break on flag.
;	-I/O- DS:[SI]  : string buffer
;		       ds:[si][0]=buffer length - 2.
;		       ds:[si][1]=input character length.
;		       0ah=end.of.string.
;	-O- AX : 0=normal,3=F3,11=ESC

KEYIN	PROC	NEAR
	PUSH	SI

	MOV	CH,0			; input character count.

	MOV	CL,DS:[SI]		; character length(into CRcode 1byte)
	CMP	CL,0			;
	JNE	KEYIN1			;
					;
KEYIN1:					;
	INC	SI			;
	INC	SI			; string top.

KEYIN5:
	CALL	INPCHAR			; 1 char input.
	CMP	BREAK_ON,0		; break on flag.
	JE	KEYIN_BREAK		;
	CMP	FKEY,11			; 11=ESC
	JMPEQ	KEYIN_ESC		;
	CMP	FKEY,3			; 3=F3
	JE	KEYIN_F3		;
KEYIN_BREAK:				;

	CMP	DL,CHR_BS		; back space.
	JE	KEYIN5_BACK		;
	CMP	DL,CHR_DEL		; DEL.
	JE	KEYIN5_BACK		;
	CMP	DL,CHR_BACK		; back cursole.
	JE	KEYIN5_BACK		;
	JMP	KEYIN6			;
KEYIN5_BACK:
	CMP	CH,0			; input character count.
	JE	KEYIN5			;

	DEC	LOCX			;
	CMP	LOCX,0			;
	JGE	KEYIN55			;

	MOV	AX,WIDX			; CRT character window x size.
	DEC	AX			;
	MOV	LOCX,AX			;
	DEC	LOCY			;
KEYIN55:
	MOV	CHAR,CHR_SPACE		; space.

	PUSH	SI			;
	PUSH	DX			;
	PUSH	CX			;
	CALL	CRT98PUT		; 1 char disply of PC9801.
	POP	CX			;
	POP	DX			;
	POP	SI			;

	DEC	SI			;
	DEC	CH			;
	JMP	KEYIN5			; next.

KEYIN6:
	CMP	DL,CHR_CR		; calig return.
	JE	KEYIN9			;

	CMP	DL,CNTL_UP		; control upper.
	JNBE	KEYIN66			;
	JMP	KEYIN5			; next.
KEYIN66:
	INC	CH			; char counter.
	CMP	CH,CL			; input character count.
	JB	KEYIN8			; ( cl-1 )=max length.
	DEC	CH			; char counter.
	JMP	KEYIN5			; next.
KEYIN8:
	MOV	BYTE PTR DS:[SI],DL	; char code.
	INC	SI			;
	MOV	CHAR,DX			;
	CALL	CRTOUT			; CRT output.

	JMP	KEYIN5			; loop end.

KEYIN9:					;
	MOV	BYTE PTR DS:[SI],CHR_CR	; calig return.
KEYIN99:				;
	POP	SI			;
	MOV	DS:[SI][1],CH		; input character length.
	MOV	AX,0			; 0=normal
	RET				;
KEYIN_F3:
	POP	SI				;
	MOV	BYTE PTR DS:[SI][1],0		; input character length.
	MOV	BYTE PTR DS:[SI][2],CHR_CR	; end.of.string.
	MOV	AX,3				; 3=F3
	RET
KEYIN_ESC:
	POP	SI				;
	MOV	BYTE PTR DS:[SI][1],0		; input character length.
	MOV	BYTE PTR DS:[SI][2],CHR_CR	; end.of.string.
	MOV	AX,11				; 11=ESC
	RET
KEYIN	ENDP


;	CRT output.
;	-I- CHAR : 1 character

CRTOUT	PROC	NEAR
	PUSH	DX

	CMP	KNJFLAG,1
	JNE	CRTOUT0

	MOV	DH,BYTE PTR KNJCODE
	MOV	DL,BYTE PTR CHAR
	MOV	CHAR,DX		; jis code.

	CALL	JIS98PUT	; shift jis disply of PC9801.

	MOV	KNJFLAG,0

	JMP	CRTOUT99	; exit.
CRTOUT0:
	MOV	DX,CHAR
	CALL	SJISCK		; shift jis check.
	CMP	AX,1		; 1=shift jis code.
	JNE	CRTOUT1

	MOV	DX,CHAR
	MOV	KNJCODE,DX
	MOV	KNJFLAG,1

	JMP	CRTOUT99	; exit.
CRTOUT1:
	CMP	CHAR,CNTL_UP	; control upper.
	JNBE	CRTOUT6

	CMP	CHAR,CHR_LF	; ( LF ) line feed.
	JNE	CRTOUT2

	JMP	CRTOUT7_LF	; line feed.
CRTOUT2:
	CMP	CHAR,CHR_CR	; ( CR ) calig return.
	JNE	CRTOUT22

	MOV	LOCX,0		; x = 0
	JMP	CRTOUT99	; exit.
CRTOUT22:
	CMP	CHAR,CHR_TAB	; TAB code.
	JNE	CRTOUT3
	MOV	AX,LOCX
	SHR	AX,1	;/2
	SHR	AX,1	;/4
	SHR	AX,1	;/8
	INC	AX	;+1
	SHL	AX,1	;*2
	SHL	AX,1	;*4
	SHL	AX,1	;*8
	MOV	LOCX,AX
	JMP	CRTOUT7_X	; scroll up?
CRTOUT3:
	JMP	CRTOUT99
CRTOUT6:
	CALL	CRT98PUT	; 1 char disply of PC9801.
	INC	LOCX

CRTOUT7_X:
	MOV	AX,LOCX
	CMP	AX,WIDX
	JL	CRTOUT99
CRTOUT7_Y:			; scroll up?
	MOV	LOCX,0
CRTOUT7_LF:			; line feed.
	INC	LOCY
	MOV	AX,LOCY
	CMP	AX,WIDY
	JLE	CRTOUT99

	CALL	CRT98UP		; 1 line scroll up.

	MOV	AX,WIDY
	MOV	LOCY,AX
CRTOUT99:
	POP	DX
	RET
CRTOUT	ENDP


;	1 char disply of PC9801.
;	-I-   CHAR      : 1 character.
;	      LOCX,LOCY : locate position.

CRT98PUT	PROC	NEAR
	MOV	DI,LOCY	;
	SHL	DI,1	;*2
	SHL	DI,1	;*4
	SHL	DI,1	;*8
	SHL	DI,1	;*16
	MOV	AX,DI	;
	SHL	DI,1	;*32
	SHL	DI,1	;*64
	ADD	DI,AX	;*80
	ADD	DI,LOCX	; text vram address.

	SHL	DI,1	; kanji system vram address.

	MOV	AX,TEXT_VRAM_SEG	; vram segment.
	MOV	ES,AX			;
	MOV	AX,CHAR			; character put.
	MOV	ES:[DI],AX		;

	MOV	AX,ATTR_VRAM_SEG	; attribute vram address.
	MOV	ES,AX			;
	MOV	AX,TEXT_COLOR		; text color.
	MOV	ES:[DI],AX		;

	RET
CRT98PUT	ENDP


;	1 line scroll up.

CRT98UP	PROC	NEAR
	PUSH	SI
	PUSH	CX
	PUSH	DX

	MOV	DI,0
	MOV	SI,WIDX
	SHL	SI,1			; *2

	PUSH	DI
	PUSH	SI
	MOV	CX,ROLLUPCNT		; rollup move count.
	MOV	AX,ATTR_VRAM_SEG	; attribute vram address.
	MOV	ES,AX			;
	PUSH	DS
	MOV	DS,AX			;
	REP	MOVSW			; roll up action.
	POP	DS
	POP	SI
	POP	DI

	MOV	CX,ROLLUPCNT		; rollup move count.
	MOV	AX,TEXT_VRAM_SEG	; vram segment.
	MOV	ES,AX			;
	PUSH	DS
	MOV	DS,AX			;
	REP	MOVSW			; roll up action.
	POP	DS

	MOV	ES,TEXT_VRAM_SEG	; vram segment.
	MOV	AX,0			; under line clear.
	MOV	CX,WIDX			;
	MOV	DI,ROLLUPCNT		;
	SHL	DI,1			; *2
	REP	STOSW			;

	MOV	ES,ATTR_VRAM_SEG	; attribute vram address.
	MOV	AX,11100001B		; under line clear.
	MOV	CX,WIDX			;
	MOV	DI,ROLLUPCNT		;
	SHL	DI,1			; *2
	REP	STOSW			;

	POP	DX
	POP	CX
	POP	SI
	RET
CRT98UP	ENDP


;	1 char input. ( prompt )
;	-o- DX   : character code.
;	    FKEY : function key number. 0=none,1=F1,2=F2,3=F3,4=F4,5=F5
;					6=F6,7=F7,8=F8,9=F9,10=F10,11=ESC

INPCHAR	PROC	NEAR
	PUSH	AX
	PUSH	SI

	MOV	FKEY,0			; function key number.
	MOV	PROMPTCNT,0		; prompt count.
	MOV	SI,0			; prompt.
INPCHAR2:
	CALL	INKEY			; key buffer read.
	CMP	DX,NULL			; null.
	JNE	INPCHAR8		;
	CMP	FKEY,0			; function key number.
	JNE	INPCHAR8		;

	INC	PROMPTCNT		; prompt count.
	CMP	PROMPTCNT,PROMPT_NEXT	; prompt interval.
	JB	INPCHAR3		;

	MOV	PROMPTCNT,0		; prompt count.

	MOV	BX,SI			;
	SHR	BX,1			; / 2
	MOV	AH,0			;
	MOV	AL,BYTE PTR DS:PROMPTD[BX]
	MOV	CHAR,AX			;
	CALL	CRT98PUT		; 1 char disply of PC9801.
	CALL	CURSOLELOC		; cursole locate.
	INC	SI			;
	CMP	SI,16			;
	JL	INPCHAR3		;
	MOV	SI,0			;
INPCHAR3:				;
	JMP	INPCHAR2		;
INPCHAR8:				;
	PUSH	DX			;
	MOV	CHAR,CHR_SPACE		;
	CALL	CRT98PUT		; 1 char disply of PC9801.
	POP	DX			;

	POP	SI
	POP	AX
	RET
INPCHAR	ENDP


;	key buffer read.
;	-o- DX   : character code. (NULL=none)
;	    FKEY : function key number. 0=none,1=F1,2=F2,3=F3,4=F4,5=F5
;					6=F6,7=F7,8=F8,9=F9,10=F10,11=ESC

INKEY	PROC	NEAR
	PUSH	AX
	PUSH	SI

	MOV	FKEY,0		; function key number.

	MOV	AH,01H		; key data buffer check.
	INT	18H		; BIOS call.
	CMP	BH,0		; key buffer empty ?
	JE	INKEY3

	MOV	AH,00H		; key data read.
	INT	18H		; BIOS call.
	CALL	KEYCONV		; key ocde conversion.
	JMP	INKEY9
INKEY3:
	MOV	DX,NULL		; null
INKEY9:
	POP	SI
	POP	AX
	RET
INKEY	ENDP


;	key code conversion.
;	-I- AH   : scyan code.
;	    AL   : internal code.
;	-O- DX   : character code.
;	    FKEY : function key number. 0=none,1=F1,2=F2,3=F3,4=F4,5=F5
;					6=F6,7=F7,8=F8,9=F9,10=F10,11=ESC

KEYCONV	PROC	NEAR
	PUSH	BX

	MOV	FKEY,0			; function key number.

	MOV	DL,AL			; key data.
	MOV	DH,0			;

	CMP	AH,62H			; scyan code=F1
	JB	KEYCONV1		;
	CMP	AH,6BH			; scyan code=F10
	JNBE	KEYCONV1		;
	MOV	BL,AH			;
	SUB	BL,61H			;
	MOV	FKEY,BL			; function key number.
KEYCONV1:				;
	CMP	AH,82H			; scyan code=F1
	JB	KEYCONV12		;
	CMP	AH,8BH			; scyan code=F10
	JNBE	KEYCONV12		;
	MOV	BL,AH			;
	SUB	BL,81H			;
	MOV	FKEY,BL			; function key number.
KEYCONV12:				;

	CMP	AH,00H			; scyan code=ESC
	JNE	KEYCONV2		;
	MOV	FKEY,11			; 11=ESC
KEYCONV2:				;

	CMP	AL,0			;
	JE	KEYCONV3		;
	JMP	KEYCONV9		;
KEYCONV3:				;
	CMP	AH,03BH			; cursole left.
	JE	KEYCONV_BS		;
	CMP	AH,039H			; DEL key.
	JE	KEYCONV_BS		;
	JMP	KEYCONV9		;
KEYCONV_BS:				;
	MOV	DX,CHR_BS		; back space.
KEYCONV9:				;
	POP	BX			;
	RET				;
KEYCONV	ENDP


;	shift jis disply of PC9801.
;	-I-   CHAR      : 1 character.
;	-I/O- LOCX,LOCY : locate position.

JIS98PUT	PROC	NEAR
	MOV	DX,CHAR
	PUSH	DX

	CALL	SJISCNV		; shift JIS -> JIS

	MOV	AL,DL
	MOV	DL,DH
	MOV	DH,AL

	SUB	DL,20H

	MOV	CHAR,DX
	CALL	CRT98PUT	; 1 char disply of PC9801.
	INC	LOCX

	OR	DL,80H
	MOV	CHAR,DX
	CALL	CRT98PUT	; 1 char disply of PC9801.
	INC	LOCX

JIS98PUT7_X:
	MOV	AX,LOCX
	CMP	AX,WIDX
	JL	JIS98PUT99
JIS98PUT7_Y:			; scroll up?
	MOV	LOCX,0
	INC	LOCY
	MOV	AX,LOCY
	CMP	AX,WIDY
	JL	JIS98PUT99

	CALL	CRT98UP		; 1 line scroll up.

	MOV	AX,WIDY
	MOV	LOCY,AX
JIS98PUT99:

	POP	DX
	MOV	CHAR,DX
	RET
JIS98PUT	ENDP


;	shift jis check.
;	-I- DX : character code.
;	-O- AX : 0=normal,1=shift jis code.

SJISCK	PROC	NEAR
	MOV	AX,0
	CMP	DL,081H
	JB	SJISCK3
	CMP	DL,09FH
	JNBE	SJISCK3
	MOV	AX,1		; shift jis code.
	RET
SJISCK3:
	CMP	DL,0E0H
	JB	SJISCK9
	CMP	DL,0FCH
	JNBE	SJISCK9
	MOV	AX,1		; shift jis code.
SJISCK9:
	RET
SJISCK	ENDP


;	shift JIS -> JIS
;	-I/O- DX : jis code.

SJISCNV	PROC	NEAR
	CMP	DL,09EH		;	IF (I2 .LE. I9E)  THEN
	JNBE	SJISCNV4	;
	CMP	DH,09FH		;	  IF (I1 .LE. I9F)  THEN
	JNBE	SJISCNV2	;
	SUB	DH,071H		;	    I1  =  (I1 - I71) * 2 + 1
	SHL	DH,1		;
	INC	DH		;
	JMP	SJISCNV3	;
SJISCNV2:			;	  ELSE
	SUB	DH,0B1H		;	    I1  =  (I1 - IB1) * 2 + 1
	SHL	DH,1		;
	INC	DH		;
SJISCNV3:			;	  END IF
	SUB	DL,01FH		;	  I2  =  I2 - I1F
	CMP	DL,061H		;	IF (I2 .GE. I61)  I2 = I2 - 1
	JB	SJISCNV33	;
	DEC	DL		;
SJISCNV33:			;
	JMP	SJISCNV7	;
SJISCNV4:			;	ELSE
	CMP	DH,09FH		;	  IF (I1 .LE. I9F)  THEN
	JNBE	SJISCNV6	;
	SUB	DH,070H		;	    I1  =  (I1 - I70) * 2
	SHL	DH,1		;
	JMP	SJISCNV66	;
SJISCNV6:			;	  ELSE
	SUB	DH,0B0H		;	    I1  =  (I1 - IB0) * 2
	SHL	DH,1		;
SJISCNV66:			;	  END IF
	SUB	DL,07EH		;	  I2  =  I2 - I7E
SJISCNV7:			;	END IF
	RET			;
SJISCNV	ENDP


;	function key.
;	-O- AX : 0=none,1=F1,2=F2,3=F3,4=F4,5=F5,6=F6,7=F7,8=F8,9=F9,10=F10
;			11=ESC,12=ENTER

FUNCTION_KEY	PROC	NEAR
	MOV	AH,01H			; key data buffer check.
	INT	18H			; PC bios.
	CMP	BH,00H			; 00H=none,01h=ok.
	JE	FUNCTION_KEY_NONE	;

	MOV	AH,00H			; key data read.
	INT	18H			; PC bios.

	CMP	AH,00H			; scyan code=ESC
	JE	FUNCTION_KEY_ESC	;

	CMP	AH,1CH			; scyan code=ENTER
	JE	FUNCTION_KEY_ENTER	;

	CMP	AL,0			; ascii char?
	JNE	FUNCTION_KEY_NONE	;

	CMP	AH,62H			; scyan code=F1
	JB	FUNCTION_KEY_5		;
	CMP	AH,6BH			; scyan code=F10
	JNBE	FUNCTION_KEY_5		;
	MOV	AL,AH			; AL=scyan code.
	SUB	AL,61H			;
	MOV	AH,0			;
	JMP	FUNCTION_KEY_FKEY	;
FUNCTION_KEY_5:
	CMP	AH,82H			; scyan code=F1
	JB	FUNCTION_KEY_6		;
	CMP	AH,8BH			; scyan code=F10
	JNBE	FUNCTION_KEY_6		;
	MOV	AL,AH			; AL=scyan code.
	SUB	AL,81H			;
	MOV	AH,0			;
	JMP	FUNCTION_KEY_FKEY	;
FUNCTION_KEY_6:

	MOV	AX,0			; 0=none.
	RET
FUNCTION_KEY_FKEY:
	RET
FUNCTION_KEY_ESC:
	MOV	AX,11			; 11=ESC
	RET
FUNCTION_KEY_ENTER:
	MOV	AX,12			; 11=ENTER
	RET
FUNCTION_KEY_NONE:
	MOV	AX,0			; 0=none.
	RET
FUNCTION_KEY	ENDP


;	cursole locate.
;	-I- LOCX,LOCY : locate position.

CURSOLELOC	PROC	NEAR
	MOV	DX,LOCY	;
	SHL	DX,1	;*2
	SHL	DX,1	;*4
	SHL	DX,1	;*8
	SHL	DX,1	;*16
	MOV	AX,DX	;
	SHL	DX,1	;*32
	SHL	DX,1	;*64
	ADD	DX,AX	;*80
	ADD	DX,LOCX	; text vram address.
	MOV	AH,13H			; cursole locate.
	INT	18H			; PC bios.
	RET
CURSOLELOC	ENDP


; ****************************************************
;	DATA.
; ****************************************************

		EVEN
TEXT_VRAM_SEG	DW	0A000H		; text vram address.
ATTR_VRAM_SEG	DW	0A200H		; attribute vram address.

PROMPTD		DB	87H,86H,85H,84H,83H,82H,81H,80H	; prompt.
PROMPTCNT	DW	0		; prompt counter.


CHAR		DW	0		; 1 character.

LOCX		DW	0		; locate x.
LOCY		DW	0		; locate y.

WIDX		DW	80		; CRT character window x size.
WIDY		DW	25;23		; CRT character window y size.

ROLLUPCNT	DW	80*25;23	; rollup move count.

		;	76543210
TEXT_COLOR	DW	11000001B	; text color.

FKEY		DB	0,0		; function key number.

KNJFLAG		DW	0		; kanji flag.
KNJCODE		DW	0		; kanji code.

BREAK_ON	DW	0		; break on flag.

CODE	ENDS

ENDIF
	END
;
;	end of "CONSOLE.ASM"
;
