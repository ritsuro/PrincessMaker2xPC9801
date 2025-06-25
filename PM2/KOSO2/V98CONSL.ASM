; "V98CONSL.ASM" PC-9801UV11 make by R.H 1989/11/04
;
;
;	E X E L O A D    c o n s o l e  I/O.
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01,DS:DATA

PUBLIC	C98CIN		; console in.
PUBLIC	C98COUT		; print character.
PUBLIC	C98CRD		; read key buffer.
PUBLIC	C98CLOC		; locate.
PUBLIC	C98CCOL		; text color.


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

C98CIN	PROC	NEAR
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
C98CIN	ENDP


;	print character.
;	-I- DL : character code.

C98COUT	PROC	NEAR
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
C98COUT	ENDP


;	read key buffer.
;	-O- DX : character code. (NULL=none)

C98CRD	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX

	PUSH	SI
	PUSH	DI
	PUSH	BP
	PUSH	DS
	PUSH	ES

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
C98CRD	ENDP


;	locate.
;	-I- AX : locate x.
;	    BX : locate y.

C98CLOC	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	PUSH	DS
	PUSH	ES

	CMP	AX,WIDX		; CRT character window x size.
	JBE	C98CLOC_2	;
	MOV	AX,WIDX		; CRT character window x size.
C98CLOC_2:

	CMP	BX,WIDY		; CRT character window y size.
	JBE	C98CLOC_3	;
	MOV	BX,WIDY		; CRT character window y size.
C98CLOC_3:

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
C98CLOC	ENDP



;	text color.
;	-I- AX : text color.

C98CCOL	PROC	NEAR
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
C98CCOL	ENDP


;	keybord input string.
;	-I/O- DS:[SI]  : string buffer
;		       ds:[si][0]=buffer length - 2.
;		       ds:[si][1]=input character length.
;		       0ah=end.of.string.

KEYIN	PROC	NEAR
	PUSH	SI

	MOV	CH,0		; input character count.

	MOV	CL,DS:[SI]	; character length(into CRcode 1byte)
	CMP	CL,0
	JNE	KEYIN1
	JMP	KEYIN99
KEYIN1:
	INC	SI		;
	INC	SI		; string top.

KEYIN5:
	CALL	INPCHR		; 1 char input.

	CMP	DL,CHR_BS	; back space.
	JE	KEYIN5_BACK	;
	CMP	DL,CHR_DEL	; DEL.
	JE	KEYIN5_BACK	;
	CMP	DL,CHR_BACK	; back cursole.
	JE	KEYIN5_BACK	;
	JMP	KEYIN6		;
KEYIN5_BACK:
	CMP	CH,0		; input character count.
	JE	KEYIN5

	DEC	LOCX
	CMP	LOCX,0
	JGE	KEYIN55

	MOV	AX,WIDX		; CRT character window x size.
	DEC	AX		;
	MOV	LOCX,AX		;
	DEC	LOCY		;
KEYIN55:
	MOV	CHAR,CHR_SPACE	; space.

	PUSH	SI
	PUSH	DX
	PUSH	CX
	CALL	CRT98PUT	; 1 char disply of PC9801.
	POP	CX
	POP	DX
	POP	SI

	DEC	SI
	DEC	CH
	JMP	KEYIN5		; next.

KEYIN6:
	CMP	DL,CHR_CR	; calig return.
	JE	KEYIN9		;

	CMP	DL,CNTL_UP	; control upper.
	JNBE	KEYIN66		;
	JMP	KEYIN5		; next.
KEYIN66:
	INC	CH		; char counter.
	CMP	CH,CL		; input character count.
	JB	KEYIN8		; ( cl-1 )=max length.
	DEC	CH		; char counter.
	JMP	KEYIN5		; next.
KEYIN8:
	MOV	BYTE PTR DS:[SI],DL	; char code.
	INC	SI		;
	MOV	CHAR,DX		;
	CALL	CRTOUT		; CRT output.

	JMP	KEYIN5		; loop end.

KEYIN9:
	MOV	BYTE PTR DS:[SI],CHR_CR	; calig return.
KEYIN99:
	POP	SI
	MOV	DS:[SI][1],CH	; input character length.
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
;	-o- DX : character code.

INPCHR	PROC	NEAR
	PUSH	AX
	PUSH	SI

	MOV	PROMPTCNT,0	; prompt count.
	MOV	SI,0		; prompt.
INPCHR2:
	CALL	INKEY		; key buffer read.
	CMP	DX,NULL		; null.
	JNE	INPCHR8		;

	INC	PROMPTCNT	; prompt count.
	CMP	PROMPTCNT,PROMPT_NEXT	; prompt interval.
	JB	INPCHR3		;

	MOV	PROMPTCNT,0	; prompt count.

	MOV	AH,0		;
	MOV	AL,BYTE PTR DS:PROMPTD[SI]
	MOV	CHAR,AX		;
	CALL	CRT98PUT	; 1 char disply of PC9801.
	INC	SI		;
	CMP	SI,8		;
	JL	INPCHR3		;
	MOV	SI,0		;
INPCHR3:
	JMP	INPCHR2
INPCHR8:
	PUSH	DX
	MOV	CHAR,CHR_SPACE	;
	CALL	CRT98PUT	; 1 char disply of PC9801.
	POP	DX

	POP	SI
	POP	AX
	RET
INPCHR	ENDP


;	key buffer read.
;	-o- DX : character code. (NULL=none)

INKEY	PROC	NEAR
	PUSH	AX
	PUSH	SI
	MOV	AH,01H	; key data buffer check.
	INT	18H	; BIOS call.
	CMP	BH,0	; key buffer empty ?
	JE	INKEY3

	MOV	AH,00H	; key data read.
	INT	18H	; BIOS call.
	CALL	KEYCONV	; key ocde conversion.
	JMP	INKEY9
INKEY3:
	MOV	DX,NULL	; null
INKEY9:
	POP	SI
	POP	AX
	RET
INKEY	ENDP


;	key code conversion.
;	-I- AH : scyan code.
;	    AL : internal code.
;	-O- DX : character code.

KEYCONV	PROC	NEAR
	MOV	DL,AL	; key data.
	MOV	DH,0	;

	CMP	AL,0	;
	JE	KEYCONV2
	JMP	KEYCONV9
KEYCONV2:
	CMP	AH,03BH	; cursole left.
	JE	KEYCONV_BS
	CMP	AH,039H	; DEL key.
	JE	KEYCONV_BS
	JMP	KEYCONV9
KEYCONV_BS:
	MOV	DX,CHR_BS	; back space.
KEYCONV9:
	RET
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

CODE01	ENDS



DATA	SEGMENT	PUBLIC	'DATA'

PROMPTD		DB	87H,86H,85H,84H,83H,82H,81H,80H	; prompt.
PROMPTCNT	DW	0	; prompt counter.


CHAR	DW	0	; 1 character.

LOCX	DW	0	; locate x.
LOCY	DW	0	; locate y.

WIDX	DW	80	; CRT character window x size.
WIDY	DW	24	; CRT character window y size.

ROLLUPCNT	DW	80*24	; rollup move count.

TEXT_VRAM_SEG	DW	0A000H	; text vram address.
ATTR_VRAM_SEG	DW	0A200H	; attribute vram address.

		;	76543210
TEXT_COLOR	DW	10000001B	; text color.

KNJFLAG		DW	0	; kanji flag.
KNJCODE		DW	0	; kanji code.

DATA	ENDS

	END
;
;	end of "V98CONSL.ASM"
;
