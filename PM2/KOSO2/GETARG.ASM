; "GETARG.ASM" PC-9801UV11 make by R.H 1990/10/23
;
;	get argument.
;
; public subroutine.

INCLUDE	TSTSET.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA


PUBLIC	GETARG		; get argument.

STRING_LEN 	EQU	128	; string length.
TOKEN_MAX	EQU	10	; token max.
CHR_SPACE	EQU	20H	; space.
CHR_TAB		EQU	09H	; tab.
CHR_LF		EQU	0AH	; line feed.
CHR_CR		EQU	0DH	; calig return.
EOS		EQU	0	; end of string.


;	get argument.
;	-O- SI : token address table address.
;	    CX : token count.

GETARG	PROC	NEAR
	MOV	AH,62H			; get PSP.
	INT	21H			;

	PUSH	DS			;

	MOV	SI,81H			; PSP top offset+command line.
	MOV	DI,OFFSET CLINE		; string address.
	MOV	CX,STRING_LEN 		; string length.
	MOV	AX,DS			;
	MOV	ES,AX			;
	MOV	DS,BX			; PSP top.
	MOV	CL,DS:[80H]		;
	MOV	CH,0			;
	REP	MOVSB			;
	POP	DS			;

	CALL	TOKADR			; token get address.

	MOV	SI,OFFSET CTOKEN	; token address table.
	MOV	CX,TOKEN_CNT		; token count.
	RET
GETARG	ENDP



;	token get address.
;	-I- CLINE     : string address.
;	-O- CTOKEN    : token address table.
;	    TOKEN_CNT : token count.

TOKADR	PROC	NEAR
	MOV	BX,0			;
	MOV	CX,TOKEN_MAX		; token max.
TOKADR_1:				;
	MOV	DS:CTOKEN[BX],OFFSET CLINE_END ; token address table.
	INC	BX			;
	INC	BX			;
	LOOP	TOKADR_1		;

	MOV	TOKEN_CNT,0		; token count.
	MOV	SI,OFFSET CLINE		; string address.
TOKADR_LOOP:
	CMP	TOKEN_CNT,TOKEN_MAX	; token max.
	JNB	TOKADR_EXIT		; max token!

TOKADR_LOOP2:
	LODSB				; 1 character get.
	CMP	AL,EOS			;
	JE	TOKADR_EXIT		; check EOS.
	CMP	AL,CHR_SPACE		; space.
	JE	TOKADR_LOOP2		;

	DEC	SI			;
	MOV	BX,TOKEN_CNT		; token count.
	SHL	BX,1			; word pointer.
	MOV	DS:CTOKEN[BX],SI	; token address table.
	INC	SI			;
	INC	TOKEN_CNT		; token count.

TOKADR_LOOP3:
	LODSB				; 1 character get.
	CMP	AL,EOS			;
	JE	TOKADR_EXIT		; check EOS.
	CMP	AL,CHR_SPACE		; space.
	JNE	TOKADR_LOOP3		;

	DEC	SI
	MOV	DS:[SI],BYTE PTR EOS
	INC	SI

	JMP	TOKADR_LOOP		;
TOKADR_EXIT:
	RET
TOKADR	ENDP

CODE01	ENDS



DATA	SEGMENT	PUBLIC	'DATA'

CLINE		DB	STRING_LEN DUP (0)	; string.
CLINE_END	DB	0,0

TOKEN_CNT	DW	0			; token count.
CTOKEN		DW	TOKEN_MAX DUP (OFFSET NONE)	; token address table.
NONE		DB	0,0

DATA	ENDS

	END
;
;	end of "GETARG.ASM"
;
