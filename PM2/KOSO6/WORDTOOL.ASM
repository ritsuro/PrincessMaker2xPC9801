; "WORDTOOL.ASM" 486/50 make by R.H 1992/05/29
;
;
;	�����ҏW.
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	WORDTL_N_HNZN		; �����񔼊p��S�p

; ***********************************************
;	������E�������p��S�p
;	-I- DS:[SI] : �������p
;	    DS:[DI] : �S�p�p�o�b�t�@
;	-O- DS:[DI] : �S�p
; ***********************************************

WORDTL_N_HNZN	PROC	NEAR
	PUSH	SI
	PUSH	DI
	MOV	CX,256
WORDTL_N_HNZN_LOOP:
	MOV	AL,DS:[SI]		; �������p
	INC	SI			;

	CMP	AL,0			;
	JE	WORDTL_N_HNZN_EXIT	;

	CMP	AL,'$'			;��
	JE	WORDTL_N_HNZN_41	;
	CMP	AL,'%'			;��
	JE	WORDTL_N_HNZN_42	;
	CMP	AL,' '			;space
	JE	WORDTL_N_HNZN_43	;

	CMP	AL,'0'
	JB	WORDTL_N_HNZN_3
	CMP	AL,'9'
	JNBE	WORDTL_N_HNZN_3
WORDTL_N_HNZN_2:
	MOV	AH,0
	ADD	AX,824FH-'0'		;"�O"<-"0"
	MOV	DS:[DI],AH		;
	INC	DI			;
	MOV	DS:[DI],AL		;
	INC	DI			;
	JMP	WORDTL_N_HNZN_NEXT
WORDTL_N_HNZN_3:
	MOV	DS:[DI],AL		; ���p�̂܂�
	INC	DI			;
	JMP	WORDTL_N_HNZN_NEXT

WORDTL_N_HNZN_41:
	MOV	AX,"��"
	JMP	WORDTL_N_HNZN_SET
WORDTL_N_HNZN_42:
	MOV	AX,"��"
	JMP	WORDTL_N_HNZN_SET
WORDTL_N_HNZN_43:
	MOV	AX,"�@"
	JMP	WORDTL_N_HNZN_SET

WORDTL_N_HNZN_SET:
	MOV	DS:[DI],AH		;
	INC	DI			;
	MOV	DS:[DI],AL		;
	INC	DI			;
WORDTL_N_HNZN_NEXT:
	LOOP	WORDTL_N_HNZN_LOOP
WORDTL_N_HNZN_EXIT:
	MOV	DS:[DI],BYTE PTR 0	; �d�n�r
	POP	DI
	POP	SI
	RET
WORDTL_N_HNZN	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'
DATA	ENDS

	END
;
;	end of "WORDTOOL.ASM"
;
