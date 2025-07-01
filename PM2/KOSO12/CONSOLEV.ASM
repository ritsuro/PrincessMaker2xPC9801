; "CONSOLEV.ASM" PC-9801UV11 make by R.H 1989/11/04
;			J-3100GS001	1990/11/17
;			PS/55Z		1991/05/23
;
;	E X E L O A D    c o n s o l e  I/O.
;
;	world-PC.
;
;
; public subroutine.

INCLUDE	MACHINE.INC

IF	IBMPC

JMPEQ	MACRO	LBL
	LOCAL	LL
	JNE	LL
	JMP	LBL
LL:
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	CCCIN		; console in.
PUBLIC	CCCINB		; console in + break on.
PUBLIC	CCCOUT		; print character.
PUBLIC	CCCRD		; read key buffer.
PUBLIC	CCCLOC		; locate.
PUBLIC	CCCCOL		; text color.
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

PROMPT_NEXT	EQU	1000	; prompt interval.

;	console in.
;	-I/O- DS:[DX]  : string buffer
;		  -i-  ds:[dx][0]=buffer length - 2.
;		  -O-  ds:[dx][1]=input character length.
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
	MOV	LOCX,AX
	MOV	LOCY,BX
	RET
CCCLOC	ENDP


;	text color.
;	-I- AX : text color.

CCCCOL	PROC	NEAR
	MOV	TEXT_ATTR,AX	; text attrbute.
	RET
CCCCOL	ENDP


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


;	locate.
;	-i- AX : locate X.
;	    BX : locate Y.

LOCATE	PROC	NEAR
	MOV	LOCX,AX		; X
	MOV	LOCY,BX		; Y
	MOV	DH,BL		; locate X.
	MOV	DL,AL		; locate Y.
	MOV	BX,0		; page.
	MOV	AH,02H		; coursole set.
	INT	10H		; PC bios.
	RET
LOCATE	ENDP



;	keybord input string.
;	-I-   BREAK_ON : break on flag.
;	-I/O- DS:[SI]  : string buffer
;		       ds:[si][0]=buffer length - 2.
;		       ds:[si][1]=input character length.
;		       0Dh=end.of.string.
;	-O- AX : 0=normal,3=F3,11=ESC

KEYIN	PROC	NEAR
	PUSH	SI

	MOV	CH,0			; input character count.

	MOV	CL,DS:[SI]		; character length(into CRcode 1byte)
	CMP	CL,0
	JNE	KEYIN1
	JMP	KEYIN99
KEYIN1:
	INC	SI			;
	INC	SI			; string top.

KEYIN5:
	CALL	INPCHR			; 1 char input.

	CMP	BREAK_ON,0		; break on flag.
	JE	KEYIN555		;

	CMP	SCYAN_CODE,1		; scyan code=ESC
	JMPEQ	KEYIN_ESC		;
	CMP	SCYAN_CODE,3DH		; scyan code=F1
	JE	KEYIN_F3		;

KEYIN555:
	CMP	DL,CHR_BS		; back space.
	JE	KEYIN5_BACK		;
	CMP	DL,CHR_DEL		; DEL.
	JE	KEYIN5_BACK		;
	CMP	DL,CHR_BACK		; back cursole.
	JE	KEYIN5_BACK		;
	JMP	KEYIN6			;
KEYIN5_BACK:
	CMP	CH,0			; input character count.
	JE	KEYIN5

	DEC	LOCX
	CMP	LOCX,0
	JGE	KEYIN55

	MOV	AX,WIDX			; CRT character window x size.
	DEC	AX			;
	MOV	LOCX,AX			;
	DEC	LOCY			;
KEYIN55:
	MOV	CHAR,CHR_SPACE		; space.

	PUSH	SI
	PUSH	DX
	PUSH	CX
	CALL	CRTPUT			; 1 char disply.
	POP	CX
	POP	DX
	POP	SI

	DEC	SI
	DEC	CH
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

KEYIN9:
	MOV	BYTE PTR DS:[SI],CHR_CR	; calig return.
KEYIN99:
	POP	SI
	MOV	DS:[SI][1],CH		; input character length.
	MOV	AX,0			; 0=normal
	RET
KEYIN_F3:
	POP	SI
	MOV	BYTE PTR DS:[SI][1],0		; input character length.
	MOV	BYTE PTR DS:[SI][2],CHR_CR	; end.of.string.
	MOV	AX,3				; 3=F3
	RET
KEYIN_ESC:
	POP	SI
	MOV	BYTE PTR DS:[SI][1],0		; input character length.
	MOV	BYTE PTR DS:[SI][2],CHR_CR	; end.of.string.
	MOV	AX,11				; 11=ESC
	RET
KEYIN	ENDP


;	CRT output.
;	-I- CHAR : 1 character

CRTOUT	PROC	NEAR
	PUSH	DX

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
	CALL	CRTPUT		; 1 char disply.
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
	JL	CRTOUT99

	CALL	CRTUP		; 1 line scroll up.

	MOV	AX,WIDY
	DEC	AX		; -1
	MOV	LOCY,AX
CRTOUT99:
	POP	DX
	RET
CRTOUT	ENDP


;	1 char input. ( prompt )
;	-I- BREAK_ON : break on flag.
;	-O- DX : character code.

INPCHR	PROC	NEAR
	PUSH	AX
	PUSH	SI

	MOV	AX,LOCX			; X
	MOV	BX,LOCY			; Y
	CALL	LOCATE			; locate.
INPCHR2:
	CALL	INKEY			; key buffer read.
	CMP	DX,NULL			; null.
	JNE	INPCHR8			;

	CMP	BREAK_ON,0		; break on flag.
	JE	INPCHR3			;

	CMP	SCYAN_CODE,1		; scyan code=ESC
	JE	INPCHR8			;
	CMP	SCYAN_CODE,3DH		; scyan code=F1
	JE	INPCHR8			;
INPCHR3:
	JMP	INPCHR2

INPCHR8:
	PUSH	DX
	MOV	CHAR,CHR_SPACE	;
	CALL	CRTPUT		; 1 char disply.
	POP	DX

	POP	SI
	POP	AX
	RET
INPCHR	ENDP


;	key buffer read.
;	-O- DX : character code. (NULL=none)

INKEY	PROC	NEAR
	PUSH	AX
	PUSH	SI

	MOV	SCYAN_CODE,0		; scyan code.
	MOV	INTERNAL_CODE,0		; internal code.

	MOV	AH,01H			; key data buffer check.
	INT	16H			; PC bios.
	JZ	INKEY3

	MOV	AH,00H			; key data read.
	INT	16H			; PC bios.
	MOV	SCYAN_CODE,AH		; scyan code.
	MOV	INTERNAL_CODE,AL	; internal code.
	CALL	KEYCONV			; key ocde conversion.
	JMP	INKEY9
INKEY3:
	MOV	DX,NULL			; null
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
	MOV	DL,AL		; key data.
	MOV	DH,0		;

	CMP	AL,0		;
	JE	KEYCONV2
	JMP	KEYCONV9
KEYCONV2:
	CMP	AH,03BH		; cursole left.
	JE	KEYCONV_BS
	CMP	AH,039H		; DEL key.
	JE	KEYCONV_BS
	JMP	KEYCONV9
KEYCONV_BS:
	MOV	DX,CHR_BS	; back space.
KEYCONV9:
	RET
KEYCONV	ENDP


;	1 char disply.
;	-I- CHAR : 1 character.

CRTPUT	PROC	NEAR
	MOV	AX,LOCX			; X
	MOV	BX,LOCY			; Y
	CALL	LOCATE			; locate.

	MOV	AL,BYTE PTR CHAR	; 1 character.
	CALL	PUTCHR			; put character.

	RET
CRTPUT	ENDP


;	put character.
;	-i- AL : character.

PUTCHR	PROC	NEAR
	PUSH	SI
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	MOV	BX,TEXT_ATTR	; text attrbute.
	MOV	CX,1		; character length.
	MOV	AH,09H		; character & attrbute write.
;*;	MOV	AH,0EH		; teletype text write.
	INT	10H		; PC bios.
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POP	SI
	RET
PUTCHR	ENDP


;	1 line scroll up.

CRTUP	PROC	NEAR
	MOV	CH,0		; up line.
	MOV	CL,0		; left side.
	MOV	DH,29		; under line.
	MOV	DL,79		; right side.

	MOV	BH,00001111B	; attrbute.
	MOV	AL,1		; 1 line.
	MOV	AH,06H		; window scroll up.
	INT	10H		; PC bios.
	RET
CRTUP	ENDP


;	function key.
;	-O- AX : 0=none,1=F1,2=F2,3=F3,4=F4,5=F5,6=F6,7=F7,8=F8,9=F9,10=F10
;			11=ESC,12=ENTER

FUNCTION_KEY	PROC	NEAR
	MOV	AH,01H			; key data buffer check.
	INT	16H			; PC bios.
	JZ	FUNCTION_KEY_NONE	;

	MOV	AH,00H			; key data read.
	INT	16H			; PC bios.

	CMP	AH,1			; scyan code=ESC
	JE	FUNCTION_KEY_ESC	;

	CMP	AH,1CH			; scyan code=ENTER
	JE	FUNCTION_KEY_ENTER	;

	CMP	AL,0			; ascii char?
	JNE	FUNCTION_KEY_NONE	;

	CMP	AH,3BH			; scyan code=F1
	JB	FUNCTION_KEY_5		;
	CMP	AH,44H			; scyan code=F10
	JNBE	FUNCTION_KEY_5		;
	JMP	FUNCTION_KEY_FKEY	;
FUNCTION_KEY_5:

	MOV	AX,0			; 0=none.
	RET
FUNCTION_KEY_FKEY:
	MOV	AL,AH			; AL=scyan code.
	SUB	AL,3AH			;
	MOV	AH,0			;
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


;	DATA.


CHAR		DW	0	; 1 character.
TEXT_ATTR	DW	2	; text attrbute.

LOCX		DW	0	; locate x.
LOCY		DW	0	; locate y.

WIDX		DW	80	; CRT character window x size.
WIDY		DW	25	; CRT character window y size.

KNJFLAG		DW	0	; kanji flag.
KNJCODE		DW	0	; kanji code.

SCYAN_CODE	DB	0,0	; scyan code.
INTERNAL_CODE	DB	0,0	; internal char.

BREAK_ON	DW	0	; break on flag.

CODE	ENDS

ENDIF
	END
;
;	end of "CONSOLEV.ASM"
;
