; "TSTSETC.INC" PC-9801UV11 make by R.H 1989/10/24
;
;	E X E L O A D    p r i n t   m a c r o .
;
;
;
; public subroutine.


;	‚o‚q	h•\Ž¦•¶Žš—ñh
;	i‰üs–³‚µƒvƒŠƒ“ƒgj

PR	MACRO	STRING
	LOCAL	L1
	PUSH	SI
DATA	SEGMENT	PUBLIC	'DATA'
	EVEN
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	SI,OFFSET L1
	CALL	c_PRINT
	POP	SI
	ENDM


;	‚o‚q‚e	h•\Ž¦•¶Žš—ñh
;	i‰üs—L‚èƒvƒŠƒ“ƒgj

PRF	MACRO	STRING
	LOCAL	L1
	PUSH	SI
DATA	SEGMENT	PUBLIC	'DATA'
	EVEN
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	SI,OFFSET L1
	CALL	c_PRINT
	POP	SI
	CALL	c_LFPRN	; line feed.
	ENDM


;	‚h‚m‚o	h•\Ž¦•¶Žš—ñh
;	i•¶Žš—ñ‚Ì“ü—Íj@o—Í@‚c‚rF‚r‚h“ü—Í•¶Žš—ñ—p
;		“à•”ƒoƒbƒtƒ@‚Ìæ“ªƒAƒhƒŒƒXiNULL=end of stringj

INP	MACRO	STRING
	LOCAL	L1,L3,L4,L5
	PUSH	SI
DATA	SEGMENT	PUBLIC	'DATA'
	EVEN
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	SI,OFFSET L1
	CALL	c_PRINT
	POP	SI
	CALL	c_INPUT
	CALL	c_LFPRN	; line feed.
	CMP	WORD PTR [SI],'Q'	;exit.
	JNZ	L3
	RET
L3:
	ENDM


;	‚b‚n‚l‚o	h”äŠr—p•¶Žš—ñh
;	i‚c‚rF‚r‚h‚Æ‚Ì”äŠrj@“ü—Í@‚c‚rF‚r‚h”äŠr‘ÎÆ•¶Žš—ñ
;					iNULL=end of stringj
;				o—Í@‚ƒ‚†A‚š‚†

COMP	MACRO	STRING
	LOCAL	L1
DATA	SEGMENT	PUBLIC	'DATA'
	EVEN
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	DI,OFFSET L1
	CALL	c_STRCMP
	ENDM


;	‚k‚e
;	i‰üsj

LF	MACRO
	CALL	c_LFPRN	; line feed.
	ENDM


;	‚e‚e	‘—‚è”
;	iƒJƒ‰ƒ€‘—‚èj

FF	MACRO	FFCOUNT
	PUSH	CX
	MOV	CX,FFCOUNT
	CALL	c_FFPRN			; colum shift.
	POP	CX
	ENDM


;	‚o‚s‚b‚g	h‚`h
;	i‚P•¶Žš•\Ž¦j

PTCH	MACRO	ACHR
	PUSH	AX
	MOV	AL,ACHR
	CALL	c_CHPUT			; print of ascii character.
	POP	AX
	ENDM


;	‚o‚q‚r	h•\Ž¦•¶Žš—ñhC‚r‚s‚q‚h‚m‚f
;	i‰üs—L‚è•¶Žš—ñƒvƒŠƒ“ƒgj

PRS	MACRO	STRING,PARAM
	LOCAL	L1
	PUSH	SI
	PUSH	DX
	PUSH	SI
DATA	SEGMENT	PUBLIC	'DATA'
	EVEN
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	SI,OFFSET L1
	CALL	c_PRINT
	POP	SI
	MOV	SI,OFFSET PARAM
	CALL	c_PRINT
	POP	DX
	POP	SI
	CALL	c_LFPRN	; line feed.
	ENDM


;	‚o‚q‚r‚`	h•\Ž¦•¶Žš—ñhC•¶Žš—ñƒAƒhƒŒƒX
;	i‰üs—L‚è•¶Žš—ñƒvƒŠƒ“ƒgj

PRSA	MACRO	STRING,PARAM
	LOCAL	L1
	PUSH	SI
	PUSH	DX
	PUSH	SI
DATA	SEGMENT	PUBLIC	'DATA'
	EVEN
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	SI,OFFSET L1
	CALL	c_PRINT
	POP	SI
	MOV	SI,PARAM
	CALL	c_PRINT
	POP	DX
	POP	SI
	CALL	c_LFPRN	; line feed.
	ENDM



;	‚o‚q‚u	h•\Ž¦•¶Žš—ñhC‚v‚n‚q‚cQ‚u‚`‚k
;	i‰üs—L‚èƒ[ƒh’lƒvƒŠƒ“ƒg‚P‚Oij

PRV	MACRO	STRING,PARAM
	LOCAL	L1
	PUSH	SI
	PUSH	DX
	PUSH	SI
DATA	SEGMENT	PUBLIC	'DATA'
	EVEN
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	SI,OFFSET L1
	CALL	c_PRINT
	POP	SI
	MOV	DX,PARAM
	CALL	c_DECSTR
	CALL	c_PRINT
	POP	DX
	POP	SI
	CALL	c_LFPRN	; line feed.
	ENDM



;	‚o‚q‚u‚g	h•\Ž¦•¶Žš—ñhC‚v‚n‚q‚cQ‚u‚`‚k
;	i‰üs—L‚èƒ[ƒh’lƒvƒŠƒ“ƒg‚P‚Uij

PRVH	MACRO	STRING,PARAM
	LOCAL	L1
	PUSH	SI
	PUSH	DX
	PUSH	SI
DATA	SEGMENT	PUBLIC	'DATA'
	EVEN
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	SI,OFFSET L1
	CALL	c_PRINT
	POP	SI
	MOV	DX,PARAM
	CALL	c_HEXSTR
	CALL	c_PRINT
	POP	DX
	POP	SI
	CALL	c_LFPRN	; line feed.
	ENDM


;	‚o‚q‚u‚a	h•\Ž¦•¶Žš—ñhC‚v‚n‚q‚cQ‚u‚`‚k
;	i‰üs—L‚èƒ[ƒh’lƒvƒŠƒ“ƒg‚Qij

PRVB	MACRO	STRING,PARAM
	LOCAL	L1
	PUSH	SI
	PUSH	DX
	PUSH	SI
DATA	SEGMENT	PUBLIC	'DATA'
	EVEN
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	SI,OFFSET L1
	CALL	c_PRINT
	POP	SI
	MOV	DX,PARAM
	CALL	c_BINSTR
	CALL	c_PRINT
	POP	DX
	POP	SI
	CALL	c_LFPRN	; line feed.
	ENDM


;	‚o‚q‚b‚g
;	i‚PƒLƒƒƒ‰ƒNƒ^ƒvƒŠƒ“ƒgj@“ü—Í@‚`‚gƒLƒƒƒ‰ƒNƒ^ƒR[ƒh

PRCH	MACRO
	LOCAL	L1
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	CMP	AH,20H
	JNB	L1
	MOV	AH,'.'
L1:
	MOV	AL,AH
	CALL	c_CHPUT	;print of ascii character.
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	ENDM


;	‚r‚d‚s‚r	•¶Žš—ñ–¼
;	i‚c‚rF‚r‚h‚Ì•¶Žš—ñ‚ð•¶Žš—ñ–¼‚ÌƒGƒŠƒA‚ÖƒRƒs[j
;		“ü—Í@‚c‚rF‚r‚hƒZƒbƒg•¶Žš—ñ

SETS	MACRO	SNAME
	LOCAL	L1,L2
	PUSH	ES
	PUSH	SI
	MOV	AX,DS
	MOV	ES,AX
	CLD
	MOV	DI,OFFSET SNAME
L1:	LODSB
	CMP	AL,' '		; space.
	JB	L2
	STOSB
	JMP	L1
L2:	POP	SI
	POP	ES
	ENDM


;	‚k‚b	‚wC‚x
;	ƒeƒLƒXƒg•\Ž¦À•W

LC	MACRO	XX,YY
	PUSH	AX
	PUSH	BX
	MOV	AX,XX
	MOV	BX,YY
	CALL	c_LOCATE		; locate.
	POP	BX
	POP	AX
	ENDM


;	‚i‚l‚o‚d‚p	ƒ‰ƒxƒ‹

JMPEQ	MACRO	LBL
	LOCAL	L1
	JNE	L1
	JMP	LBL
L1:
	ENDM


JMPNB	MACRO	LBL
	LOCAL	L1
	JB	L1
	JMP	LBL
L1:
	ENDM

JMPB	MACRO	LBL
	LOCAL	L1
	JNB	L1
	JMP	LBL
L1:
	ENDM

JMPBE	MACRO	LBL
	LOCAL	L1
	JNBE	L1
	JMP	LBL
L1:
	ENDM

JMPNBE	MACRO	LBL
	LOCAL	L1
	JBE	L1
	JMP	LBL
L1:
	ENDM

JMPC	MACRO	LBL
	LOCAL	L1
	JNC	L1
	JMP	LBL
L1:
	ENDM

JMPNE	MACRO	LBL
	LOCAL	L1
	JE	L1
	JMP	LBL
L1:
	ENDM

;	‚o‚q‚a‚x‚s‚d	h•\Ž¦•¶Žš—ñhC‚a‚x‚s‚dQ‚u‚`‚k
;	iƒoƒCƒg’lƒvƒŠƒ“ƒg‚P‚Oij

PRBYTE	MACRO	STRING,PARAM
	LOCAL	L1
	PUSH	SI
	PUSH	AX
	PUSH	DX
	PUSH	SI
DATA	SEGMENT	PUBLIC	'DATA'
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	SI,OFFSET L1
	CALL	c_PRINT
	POP	SI
	MOV	DL,PARAM
	MOV	DH,0
	CALL	c_DECSTR
	ADD	SI,2
	CALL	c_PRINT
	POP	DX
	POP	AX
	POP	SI
	ENDM

MOVX	MACRO	DEST,SOU
	MOV	AX,SOU
	MOV	DEST,AX
	ENDM

ADDX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	ADD	DEST,AX
	ENDM

SUBX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	SUB	DEST,AX
	ENDM

CMPX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	CMP	DEST,AX
	ENDM

LOOPX	MACRO	LBL
	LOCAL	L1,L2
	LOOP	L1
	JMP	L2
L1:
	JMP	LBL
L2:
	ENDM

JCXZX	MACRO	LBL
	LOCAL	L1,L2
	JCXZ	L1
	JMP	L2
L1:
	JMP	LBL
L2:
	ENDM

CALLE	MACRO	LBL
	EXTRN	LBL:NEAR
	CALL	LBL
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE

EXTRN	c_PRNAH:NEAR	; print ah reg.
EXTRN	c_PRINT:NEAR	; print string.
EXTRN	c_PRINTES:NEAR	; print of string ES.
EXTRN	c_DECSTR:NEAR	; val DX to dec string.
EXTRN	c_INPUT:NEAR	; string input.
EXTRN	c_STRDEC:NEAR	; dec string to DX reg.
EXTRN	c_HEXSTR:NEAR	; val DX to hex string.
EXTRN	c_STRHEX:NEAR	; hex string to DX reg.
EXTRN	c_BINSTR:NEAR	; val DX to bin string.
EXTRN	c_STRBIN:NEAR	; bin string to DX reg.
EXTRN	c_STRCMP:NEAR	; string compare.
EXTRN	c_CLS:NEAR	; text clear.
EXTRN	c_CSLON:NEAR	; cursole on.
EXTRN	c_CSLOFF:NEAR	; cursole off.
EXTRN	c_INPCHR:NEAR	; 1 char input.
EXTRN	c_CHPUT:NEAR	; print of ascii character.
EXTRN	c_KESCAP:NEAR	; ESC key & break check & pause.
EXTRN	c_KEYLOD:NEAR	; key buffer read.
EXTRN	c_PRNAB:NEAR	; print of a register(BIN).
EXTRN	c_LOCATE:NEAR	; locate.
EXTRN	c_LFPRN:NEAR	; line feed.
EXTRN	c_FFPRN:NEAR	; colum shift.
EXTRN	c_D10STR:NEAR	; i*4 value -> decimal string.
EXTRN	c_STRZTS:NEAR	; zero to space. "00123" - > "  123"
EXTRN	c_STRSPL:NEAR	; space pless. "  123" - > "123  "
EXTRN	c_SIGSTR:NEAR	; signed val DX to dec string.
EXTRN	c_MEMCPY:NEAR	; memory to memory copy.

CODE	ENDS

;
;	end of "TSTSETC.INC"
;
