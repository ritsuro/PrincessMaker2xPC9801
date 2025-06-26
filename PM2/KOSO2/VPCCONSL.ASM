; "VPCCONSL.ASM" PC-9801UV11 make by R.H 1989/11/04
;			J-3100GS001	1990/11/17
;			PS/55Z		1991/05/23
;			486/33		1992/04/03
;
;
;	E X E L O A D    c o n s o l e  I/O.
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01,DS:DATA

PUBLIC	CPCCIN		; console in.
PUBLIC	CPCCOUT		; print character.
PUBLIC	CPCCRD		; read key buffer.
PUBLIC	CPCCLOC		; locate.
PUBLIC	CPCCCOL		; text color.


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

CPCCIN	PROC	NEAR
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
CPCCIN	ENDP


;	print character.
;	-I- DL : character code.

CPCCOUT	PROC	NEAR
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
CPCCOUT	ENDP


;	read key buffer.
;	-O- DX : character code. (NULL=none)

CPCCRD	PROC	NEAR
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
CPCCRD	ENDP


;	locate.
;	-I- AX : locate x.
;	    BX : locate y.

CPCCLOC	PROC	NEAR
	MOV	LOCX,AX
	MOV	LOCY,BX
	RET
CPCCLOC	ENDP


;	text color.
;	-I- AX : text color.

CPCCCOL	PROC	NEAR
	MOV	TEXT_ATTR,AX	; text attrbute.
	RET
CPCCCOL	ENDP



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
	INT	10H		; IBM bios.
	RET
LOCATE	ENDP



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
	CALL	CRTPUT		; 1 char disply.
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
;	-o- DX : character code.

INPCHR	PROC	NEAR
	PUSH	AX
	PUSH	SI

	MOV	AX,LOCX			; X
	MOV	BX,LOCY			; Y
	CALL	LOCATE			; locate.
INPCHR2:
	CALL	INKEY		; key buffer read.
	CMP	DX,NULL		; null.
	JNE	INPCHR8		;

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
;	-o- DX : character code. (NULL=none)

INKEY	PROC	NEAR
	PUSH	AX
	PUSH	SI
	MOV	AH,01H	; key data buffer check.
	INT	16H	; IBM bios.
	JZ	INKEY3

	MOV	AH,00H	; key data read.
	INT	16H	; IBM bios.
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
	INT	10H		; IBM bios.
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

	MOV	BH,0		; attrbute.
	MOV	AL,1		; 1 line.
	MOV	AH,06H		; window scroll up.
	INT	10H		; IBM bios.
	RET
CRTUP	ENDP



CODE01	ENDS



DATA	SEGMENT	PUBLIC	'DATA'

CHAR		DW	0	; 1 character.
TEXT_ATTR	DW	15	; text attrbute.

LOCX		DW	0	; locate x.
LOCY		DW	0	; locate y.

WIDX		DW	80	; CRT character window x size.
WIDY		DW	30	; CRT character window y size.

KNJFLAG		DW	0	; kanji flag.
KNJCODE		DW	0	; kanji code.


DATA	ENDS

	END
;
;	end of "VPCCONSL.ASM"
;
