; "TSTSETC.INC" PC-9801UV11 make by R.H 1989/10/24
;
;	E X E L O A D    p r i n t   m a c r o .
;
;
;
; public subroutine.


;	oq	h\¦Άρh
;	iόs³΅vgj

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


;	oqe	h\¦Άρh
;	iόsLθvgj

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


;	hmo	h\¦Άρh
;	iΆρΜόΝj@oΝ@crFrhόΝΆρp
;		ΰobt@ΜζͺAhXiNULL=end of stringj

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


;	bnlo	hδrpΆρh
;	icrFrhΖΜδrj@όΝ@crFrhδrΞΖΆρ
;					iNULL=end of stringj
;				oΝ@A

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


;	ke
;	iόsj

LF	MACRO
	CALL	c_LFPRN	; line feed.
	ENDM


;	ee	θ
;	iJθj

FF	MACRO	FFCOUNT
	PUSH	CX
	MOV	CX,FFCOUNT
	CALL	c_FFPRN			; colum shift.
	POP	CX
	ENDM


;	osbg	h`h
;	iPΆ\¦j

PTCH	MACRO	ACHR
	PUSH	AX
	MOV	AL,ACHR
	CALL	c_CHPUT			; print of ascii character.
	POP	AX
	ENDM


;	oqr	h\¦ΆρhCrsqhmf
;	iόsLθΆρvgj

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


;	oqr`	h\¦ΆρhCΆρAhX
;	iόsLθΆρvgj

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



;	oqu	h\¦ΆρhCvnqcQu`k
;	iόsLθ[hlvgPOij

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



;	oqug	h\¦ΆρhCvnqcQu`k
;	iόsLθ[hlvgPUij

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


;	oqua	h\¦ΆρhCvnqcQu`k
;	iόsLθ[hlvgQij

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
	CALL	c_CHPUT	;print of ascii character.
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
	CALL	c_LOCATE		; locate.
	POP	BX
	POP	AX
	ENDM


;	ilodp	x

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

;	oqaxsd	h\¦ΆρhCaxsdQu`k
;	ioCglvgPOij

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