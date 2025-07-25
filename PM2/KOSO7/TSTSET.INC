; "TSTSET.INC" PC-9801UV11 make by R.H 1989/10/24
;
;	E X E L O A D    p r i n t   m a c r o .
;
;
;
; public subroutine.


;	oq	h\¦Άρh
;	iόs³΅vgj

PR	MACRO	STRING
	LOCAL	L1,L2
	PUSH	SI
	JMP	L2
L1	DB	STRING,0
L2:	MOV	SI,OFFSET L1
	CALL	PRINT
	POP	SI
	ENDM


;	oqe	h\¦Άρh
;	iόsLθvgj

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


;	hmo	h\¦Άρh
;	iΆρΜόΝj@oΝ@crFrhόΝΆρp
;		ΰobt@ΜζͺAhXiNULL=end of stringj

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


;	bnlo	hδrpΆρh
;	icrFrhΖΜδrj@όΝ@crFrhδrΞΖΆρ
;					iNULL=end of stringj
;				oΝ@A

COMP	MACRO	STRING
	LOCAL	L1,L2
	JMP	L2
L1	DB	STRING,0
L2:	MOV	DI,OFFSET L1
	CALL	STRCMP
	ENDM


;	ke
;	iόsj

LF	MACRO
	CALL	LFPRN	; line feed.
	ENDM


;	oqr	h\¦ΆρhCrsqhmf
;	iόsLθΆρvgj

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



;	oqu	h\¦ΆρhCvnqcQu`k
;	iόsLθ[hlvgPOij

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


;	oqut	h\¦ΆρhCvnqcQu`k
;	iόsLθ[hlvgPOij

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


;	oqug	h\¦ΆρhCvnqcQu`k
;	iόsLθ[hlvgPUij

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


;	oqua	h\¦ΆρhCvnqcQu`k
;	iόsLθ[hlvgQij

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


;	oqbg
;	iPLN^vgj@όΝ@`gLN^R[h

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


;	rdsr	ΆρΌ
;	icrFrhΜΆρπΆρΌΜGAΦRs[j
;		όΝ@crFrhZbgΆρ

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


;	kb	wCx
;	eLXg\¦ΐW

LC	MACRO	XX,YY
	PUSH	AX
	PUSH	BX
	MOV	AX,XX
	MOV	BX,YY
	CALL	LOCATE		; locate.
	POP	BX
	POP	AX
	ENDM


;	ilokd	x

JMPLE	MACRO	LBL
	LOCAL	LL
	JG	LL
	JMP	LBL
LL:
	ENDM

;	ilodp	x

JMPEQ	MACRO	LBL
	LOCAL	LL
	JNE	LL
	JMP	LBL
LL:
	ENDM

;	ilomd	x

JMPNE	MACRO	LBL
	LOCAL	LL
	JE	LL
	JMP	LBL
LL:
	ENDM

;	blow	vnqcCvnqc

CMPX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	CMP	DEST,AX
	ENDM

;	lnuw	vnqcCvnqc

MOVX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	MOV	DEST,AX
	ENDM

;	lnuwa	axsdCaxsd

MOVXB	MACRO	DEST,SOUR
	MOV	AL,SOUR
	MOV	DEST,AL
	ENDM

;	`ccw	vnqcCvnqc

ADDX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	ADD	DEST,AX
	ENDM


LOOPX	MACRO	LBL
	LOCAL	L1,L2
	LOOP	L1
	JMP	L2
L1:
	JMP	LBL
L2:
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
	EXTRN	STRCMP:NEAR	; string compare.
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
	EXTRN	MEMCPY:NEAR	; memory to memory copy.

CODE	ENDS

;
;	end of "TSTSET.INC"
;
