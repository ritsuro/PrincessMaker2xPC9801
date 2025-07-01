; "MACLIB.ASM" PC-9801UV11 make by R.H 1989/11/04
;		modify486/50 make by R.H 1993/02/03
;
;
;	main link "MACLIB.ASM"
;
;
;
; public subroutine.

INCLUDE	MAINF.INC

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	PRINT			; print string.
PUBLIC	DECSTR			; val DX to dec string.
PUBLIC	STRDEC			; dec string to DX reg.
PUBLIC	HEXSTR			; val DX to hex string.
PUBLIC	STRHEX			; hex string to DX reg.
PUBLIC	BINSTR			; val DX to bin string.
PUBLIC	STRBIN			; bin string to DX reg.
PUBLIC	CHPUT			; print of ascii character.
PUBLIC	PRNAB			; print of a register(BIN).
PUBLIC	LFPRN			; line feed.
PUBLIC	D10STR			; i*4 value -> decimal string.
PUBLIC	STRZTS			; zero to space. "00123" - > "  123"
PUBLIC	STRSPL			; space pless. "  123" - > "123  "

EXTRN	MAIN_F_INTER_C_CODE01:NEAR	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
EXTRN	MAIN_F_REG_SAVE:NEAR		; register save.

;	print of string.
;	-i- SI : string address.
;	       NULL=end of string.

PRINT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PRINT		; print string.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
PRINT	ENDP


;	i*2 value -> decimal string.
;	-i- DX   : i*2 value
;	-o- SI   : string address.
;	           NULL=end of string.

DECSTR	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_DECSTR		; val DX to dec string.
	MOV	DI,3			; 3=SI string out.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
DECSTR	ENDP


;	string(decimal format) -> i*2 value.
;	-i- SI :string address.
;	        NULL=end of string.
;	-o- DX :i*2 value.

STRDEC	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_STRDEC		; dec string to DX reg.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
STRDEC	ENDP


;	i*2 value -> hexdecimal string.
;	-i- DX : i*2 value
;	-o- SI : string address.
;	        NULL=end of string.

HEXSTR	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_HEXSTR		; val DX to hex string.
	MOV	DI,3			; 3=SI string out.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
HEXSTR	ENDP


;	string(hex format) -> i*2 value.
;	-i- SI :string address.
;	        NULL=end of string.
;	-o- DX :i*2 value.

STRHEX	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_STRHEX		; hex string to DX reg.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
STRHEX	ENDP


;	i*2 value -> string(bin format).
;	-i- DX :i*2 value.
;	-o- SI :string address.
;	        NULL=end of string.

BINSTR	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_BINSTR		; val DX to bin string.
	MOV	DI,3			; 3=SI string out.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
BINSTR	ENDP


;	string(bin format) -> i*2 value.
;	-i- SI :string address.
;	-o- DX :i*2 value.

STRBIN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_STRBIN		; bin string to DX reg.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
STRBIN	ENDP


;	print of ascii character.
;	-i- AL : ascii code

CHPUT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_CHPUT		; print of ascii character.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
CHPUT	ENDP


;	print of a register(BIN).
;	-i- AH  print hexdecimal.

PRNAB	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PRNAB		; print of a register(BIN).
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
PRNAB	ENDP


;	line feed.

LFPRN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_LFPRN		; line feed.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
LFPRN	ENDP


;	i*4 value -> decimal string.
;	2,147,483,648
;	-i- DX:AX : i*4 value
;	-o- SI    : string address.
;	           NULL=end of string.

D10STR	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_D10STR		; i*4 value -> decimal string.
	MOV	DI,3			; 3=SI string out.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
D10STR	ENDP


;	zero to space. "00123" - > "  123"
;	-i- SI : string address.
;	       NULL=end of string.

STRZTS	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_STRZTS		; zero to space. "00123"->"  123"
	MOV	DI,2			; 2=SI string i/o.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
STRZTS	ENDP


;	space pless. "  123" - > "123  "
;	-i- SI : string address.
;	       NULL=end of string.

STRSPL	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_STRSPL		; space pless. "  123"->"123  "
	MOV	DI,2			; 2=SI string i/o.
	CALL	MAIN_F_INTER_C_CODE01	; Ò²Ý‚Ì»ÌÞÙ°ÁÝcall.(seg CODE01)
	RET
STRSPL	ENDP


CODE	ENDS

	END
;
;	end of "MACLIB.ASM"
;
