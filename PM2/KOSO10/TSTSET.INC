; "TSTSET.INC" PC-9801UV11 make by R.H 1989/10/24
;
;	E X E L O A D    p r i n t   m a c r o .
;
;
;
; public subroutine.1993


;	�o�q	�h�\��������h
;	�i���s�����v�����g�j

PR	MACRO	STRING
	LOCAL	L1,L2
	PUSH	SI
	JMP	L2
L1	DB	STRING,0
L2:	MOV	SI,OFFSET L1
	CALL	PRINT
	POP	SI
	ENDM


;	�o�q�e	�h�\��������h
;	�i���s�L��v�����g�j

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


;	�k�e
;	�i���s�j

LF	MACRO
	CALL	LFPRN	; line feed.
	ENDM


;	�o�q�r	�h�\��������h�C�r�s�q�h�m�f
;	�i���s�L�蕶����v�����g�j

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



;	�o�q�u	�h�\��������h�C�v�n�q�c�Q�u�`�k
;	�i���s�L�胏�[�h�l�v�����g�P�O�i�j

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


;	�o�q�u�t	�h�\��������h�C�v�n�q�c�Q�u�`�k
;	�i���s�L�胏�[�h�l�v�����g�P�O�i�j

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


;	�o�q�u�g	�h�\��������h�C�v�n�q�c�Q�u�`�k
;	�i���s�L�胏�[�h�l�v�����g�P�U�i�j

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


;	�o�q�u�a	�h�\��������h�C�v�n�q�c�Q�u�`�k
;	�i���s�L�胏�[�h�l�v�����g�Q�i�j

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


;	�o�q�b�g
;	�i�P�L�����N�^�v�����g�j�@���́@�`�g���L�����N�^�R�[�h

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


;	�r�d�s�r	������
;	�i�c�r�F�r�h�̕�����𕶎��񖼂̃G���A�փR�s�[�j
;		���́@�c�r�F�r�h���Z�b�g������

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



;	�i�l�o�k�d	���x��

JMPLE	MACRO	LBL
	LOCAL	LL
	JG	LL
	JMP	LBL
LL:
	ENDM

;	�i�l�o�d�p	���x��

JMPEQ	MACRO	LBL
	LOCAL	LL
	JNE	LL
	JMP	LBL
LL:
	ENDM

;	�i�l�o�m�d	���x��

JMPNE	MACRO	LBL
	LOCAL	LL
	JE	LL
	JMP	LBL
LL:
	ENDM

;	�b�l�o�w	�v�n�q�c�C�v�n�q�c

CMPX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	CMP	DEST,AX
	ENDM

;	�l�n�u�w	�v�n�q�c�C�v�n�q�c

MOVX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	MOV	DEST,AX
	ENDM

;	�l�n�u�w�a	�a�x�s�d�C�a�x�s�d

MOVXB	MACRO	DEST,SOUR
	MOV	AL,SOUR
	MOV	DEST,AL
	ENDM

;	�`�c�c�w	�v�n�q�c�C�v�n�q�c

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

CALLE	MACRO	LBL
	EXTRN	LBL:NEAR
	CALL	LBL
	ENDM

;	define string -> offset.

STRS	MACRO	RRR,STRING
	LOCAL	L1
	LOCAL	L2
	JMP	L2
L1	DB	STRING,0
L2:
	MOV	RRR,OFFSET L1
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

	EXTRN	PRINT:NEAR	; print string.
	EXTRN	DECSTR:NEAR	; val DX to dec string.
	EXTRN	STRDEC:NEAR	; dec string to DX reg.
	EXTRN	HEXSTR:NEAR	; val DX to hex string.
	EXTRN	STRHEX:NEAR	; hex string to DX reg.
	EXTRN	BINSTR:NEAR	; val DX to bin string.
	EXTRN	STRBIN:NEAR	; bin string to DX reg.
	EXTRN	CHPUT:NEAR	; print of ascii character.
	EXTRN	PRNAB:NEAR	; print of a register(BIN).
	EXTRN	LFPRN:NEAR	; line feed.
	EXTRN	D10STR:NEAR	; i*4 value -> decimal string.

CODE	ENDS

;
;	end of "TSTSET.INC"
;
