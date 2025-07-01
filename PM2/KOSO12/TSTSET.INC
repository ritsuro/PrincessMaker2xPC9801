; "TSTSET.INC" PC-9801UV11 make by R.H 1989/10/24
;
;	E X E L O A D    p r i n t   m a c r o .
;
;
;
; public subroutine.


;	‚o‚q	h•\Ž¦•¶Žš—ñh
;	i‰üs–³‚µƒvƒŠƒ“ƒgj

PR	MACRO	STRING
	LOCAL	L1,L2
	PUSH	SI
	JMP	L2
L1	DB	STRING,0
L2:	MOV	SI,OFFSET L1
	CALL	PRINT
	POP	SI
	ENDM


;	‚o‚q‚e	h•\Ž¦•¶Žš—ñh
;	i‰üs—L‚èƒvƒŠƒ“ƒgj

PRF	MACRO	STRING
	LOCAL	L1,L2
	PUSH	SI
	JMP	L2
L1	DB	STRING,0
L2:	MOV	SI,OFFSET L1
	CALL	PRINT
	POP	SI
	CALL	LFPRN	; line feed.
	ENDM


;	‚h‚m‚o	h•\Ž¦•¶Žš—ñh
;	i•¶Žš—ñ‚Ì“ü—Íj@o—Í@‚c‚rF‚r‚h“ü—Í•¶Žš—ñ—p
;		“à•”ƒoƒbƒtƒ@‚Ìæ“ªƒAƒhƒŒƒXiNULL=end of stringj

INP	MACRO	STRING
	LOCAL	L1,L2,L3,L4,L5
	PUSH	SI
	JMP	L2
L1	DB	STRING,0
L2:	MOV	SI,OFFSET L1
	CALL	PRINT
	POP	SI
	CALL	INPUT
	CALL	LFPRN	; line feed.
	CMP	WORD PTR [SI],'Q'	;exit.
	JNZ	L3
	RET
L3:
	CMP	WORD PTR [SI],'q'	;exit.
	JNZ	L4
	RET
L4:
	ENDM


;	‚b‚n‚l‚o	h”äŠr—p•¶Žš—ñh
;	i‚c‚rF‚r‚h‚Æ‚Ì”äŠrj@“ü—Í@‚c‚rF‚r‚h”äŠr‘ÎÆ•¶Žš—ñ
;					iNULL=end of stringj
;				o—Í@‚ƒ‚†A‚š‚†

COMP	MACRO	STRING
	LOCAL	L1,L2
	JMP	L2
L1	DB	STRING,0
L2:	MOV	DI,OFFSET L1
	CALL	STRCMPW
	ENDM


;	‚k‚e
;	i‰üsj

LF	MACRO
	CALL	LFPRN	; line feed.
	ENDM


;	‚o‚q‚r	h•\Ž¦•¶Žš—ñhC‚r‚s‚q‚h‚m‚f
;	i‰üs—L‚è•¶Žš—ñƒvƒŠƒ“ƒgj

PRS	MACRO	STRING,PARAM
	LOCAL	L1,L2
	PUSH	SI
	PUSH	DX
	PUSH	SI
	JMP	L2
L1	DB	STRING,0
L2:	MOV	SI,OFFSET L1
	CALL	PRINT
	POP	SI
	MOV	SI,OFFSET PARAM
	CALL	PRINT
	POP	DX
	POP	SI
	CALL	LFPRN	; line feed.
	ENDM



;	‚o‚q‚u	h•\Ž¦•¶Žš—ñhC‚v‚n‚q‚cQ‚u‚`‚k
;	i‰üs—L‚èƒ[ƒh’lƒvƒŠƒ“ƒg‚P‚Oij

PRV	MACRO	STRING,PARAM
	LOCAL	L1,L2
	PUSH	SI
	PUSH	DX
	PUSH	SI
	JMP	L2
L1	DB	STRING,0
L2:	MOV	SI,OFFSET L1
	CALL	PRINT
	POP	SI
	MOV	DX,PARAM
	CALL	DECSTR
	CALL	PRINT
	POP	DX
	POP	SI
	CALL	LFPRN	; line feed.
	ENDM


;	‚o‚q‚u‚t	h•\Ž¦•¶Žš—ñhC‚v‚n‚q‚cQ‚u‚`‚k
;	i‰üs—L‚èƒ[ƒh’lƒvƒŠƒ“ƒg‚P‚Oij

PRVU	MACRO	STRING,PARAM
	LOCAL	L1,L2
	PUSH	SI
	PUSH	DX
	PUSH	SI
	JMP	L2
L1	DB	STRING,0
L2:	MOV	SI,OFFSET L1
	CALL	PRINT
	POP	SI
	MOV	DX,PARAM
	CALL	DECSTR
	EXTRN	STRZTS:NEAR
	CALL	STRZTS	; zero to space. "00123" - > "  123"
	EXTRN	STRSPL:NEAR
	CALL	STRSPL	; space pless. "  123" - > "123  "
	CALL	PRINT
	POP	DX
	POP	SI
	CALL	LFPRN	; line feed.
	ENDM


;	‚o‚q‚u‚g	h•\Ž¦•¶Žš—ñhC‚v‚n‚q‚cQ‚u‚`‚k
;	i‰üs—L‚èƒ[ƒh’lƒvƒŠƒ“ƒg‚P‚Uij

PRVH	MACRO	STRING,PARAM
	LOCAL	L1,L2
	PUSH	SI
	PUSH	DX
	PUSH	SI
	JMP	L2
L1	DB	STRING,0
L2:	MOV	SI,OFFSET L1
	CALL	PRINT
	POP	SI
	MOV	DX,PARAM
	CALL	HEXSTR
	CALL	PRINT
	POP	DX
	POP	SI
	CALL	LFPRN	; line feed.
	ENDM


;	‚o‚q‚u‚a	h•\Ž¦•¶Žš—ñhC‚v‚n‚q‚cQ‚u‚`‚k
;	i‰üs—L‚èƒ[ƒh’lƒvƒŠƒ“ƒg‚Qij

PRVB	MACRO	STRING,PARAM
	LOCAL	L1,L2
	PUSH	SI
	PUSH	DX
	PUSH	SI
	JMP	L2
L1	DB	STRING,0
L2:	MOV	SI,OFFSET L1
	CALL	PRINT
	POP	SI
	MOV	DX,PARAM
	CALL	BINSTR
	CALL	PRINT
	POP	DX
	POP	SI
	CALL	LFPRN	; line feed.
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
	CALL	CHPUT	;print of ascii character.
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	ENDM


;	‚r‚d‚s‚r	•¶Žš—ñ–¼,ƒoƒCƒg”
;	i‚c‚rF‚r‚h‚Ì•¶Žš—ñ‚ð•¶Žš—ñ–¼‚ÌƒGƒŠƒA‚ÖƒRƒs[j
;		“ü—Í@‚c‚rF‚r‚hƒZƒbƒg•¶Žš—ñ

SETS	MACRO	SNAME,CNT
	LOCAL	L1,L2
	PUSH	ES
	PUSH	SI
	PUSH	CX
	MOV	AX,DS
	MOV	ES,AX
	MOV	DI,OFFSET SNAME
	MOV	CX,CNT
	JCXZ	L2
L1:
	LODSB
	STOSB
	CMP	AL,' '		; space.
	JB	L2
	LOOP	L1
L2:
	POP	CX
	POP	SI
	POP	ES
	ENDM


;	‚k‚b	‚wC‚x
;	ƒeƒLƒXƒg•\Ž¦À•W

LC	MACRO	XX,YY
	PUSH	AX
	PUSH	BX
	MOV	AX,XX
	MOV	BX,YY
	CALL	LOCATE		; locate.
	POP	BX
	POP	AX
	ENDM


;	‚i‚l‚o‚k‚d	ƒ‰ƒxƒ‹

JMPLE	MACRO	LBL
	LOCAL	LL
	JG	LL
	JMP	LBL
LL:
	ENDM

;	‚i‚l‚o‚d‚p	ƒ‰ƒxƒ‹

JMPEQ	MACRO	LBL
	LOCAL	LL
	JNE	LL
	JMP	LBL
LL:
	ENDM

;	‚i‚l‚o‚m‚d	ƒ‰ƒxƒ‹

JMPNE	MACRO	LBL
	LOCAL	LL
	JE	LL
	JMP	LBL
LL:
	ENDM

;	‚b‚l‚o‚w	‚v‚n‚q‚cC‚v‚n‚q‚c

CMPX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	CMP	DEST,AX
	ENDM

;	‚l‚n‚u‚w	‚v‚n‚q‚cC‚v‚n‚q‚c

MOVX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	MOV	DEST,AX
	ENDM

;	‚l‚n‚u‚w‚a	‚a‚x‚s‚dC‚a‚x‚s‚d

MOVXB	MACRO	DEST,SOUR
	MOV	AL,SOUR
	MOV	DEST,AL
	ENDM

;	‚`‚c‚c‚w	‚v‚n‚q‚cC‚v‚n‚q‚c

ADDX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	ADD	DEST,AX
	ENDM


CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

	EXTRN	PRNAH:NEAR	; print ah reg.
	EXTRN	PRINT:NEAR	; print string.
	EXTRN	DECSTR:NEAR	; val DX to dec string.
	EXTRN	INPUT:NEAR	; string input.
	EXTRN	STRDEC:NEAR	; dec string to DX reg.
	EXTRN	HEXSTR:NEAR	; val DX to hex string.
	EXTRN	STRHEX:NEAR	; hex string to DX reg.
	EXTRN	BINSTR:NEAR	; val DX to bin string.
	EXTRN	STRBIN:NEAR	; bin string to DX reg.
	EXTRN	STRCMPW:NEAR	; string compare.(wildcard)
	EXTRN	CLS:NEAR	; text clear.
	EXTRN	CSLON:NEAR	; cursole on.
	EXTRN	CSLOFF:NEAR	; cursole off.
	EXTRN	INPCHR:NEAR	; 1 char input.
	EXTRN	CHPUT:NEAR	; print of ascii character.
	EXTRN	KESCAP:NEAR	; ESC key & break check & pause.
	EXTRN	KEYLOD:NEAR	; key buffer read.
	EXTRN	PRNAB:NEAR	; print of a register(BIN).
	EXTRN	LOCATE:NEAR	; locate.
	EXTRN	LFPRN:NEAR	; line feed.
	EXTRN	D10STR:NEAR	; i*4 value -> decimal string.
	EXTRN	STRZTS:NEAR	; zero to space. "00123" - > "  123"
	EXTRN	MEMCPY:NEAR	; memory to memory copy.
	EXTRN	TXCOLR:NEAR	; text color.

CODE	ENDS

;
;	end of "TSTSET.INC"
;
