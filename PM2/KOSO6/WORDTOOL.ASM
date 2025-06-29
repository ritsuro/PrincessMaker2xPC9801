; "WORDTOOL.ASM" 486/50 make by R.H 1992/05/29
;
;
;	文字編集.
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	WORDTL_N_HNZN		; 文字列半角を全角

; ***********************************************
;	文字列・数字半角を全角
;	-I- DS:[SI] : 数字半角
;	    DS:[DI] : 全角用バッファ
;	-O- DS:[DI] : 全角
; ***********************************************

WORDTL_N_HNZN	PROC	NEAR
	PUSH	SI
	PUSH	DI
	MOV	CX,256
WORDTL_N_HNZN_LOOP:
	MOV	AL,DS:[SI]		; 数字半角
	INC	SI			;

	CMP	AL,0			;
	JE	WORDTL_N_HNZN_EXIT	;

	CMP	AL,'$'			;＄
	JE	WORDTL_N_HNZN_41	;
	CMP	AL,'%'			;％
	JE	WORDTL_N_HNZN_42	;
	CMP	AL,' '			;space
	JE	WORDTL_N_HNZN_43	;

	CMP	AL,'0'
	JB	WORDTL_N_HNZN_3
	CMP	AL,'9'
	JNBE	WORDTL_N_HNZN_3
WORDTL_N_HNZN_2:
	MOV	AH,0
	ADD	AX,824FH-'0'		;"０"<-"0"
	MOV	DS:[DI],AH		;
	INC	DI			;
	MOV	DS:[DI],AL		;
	INC	DI			;
	JMP	WORDTL_N_HNZN_NEXT
WORDTL_N_HNZN_3:
	MOV	DS:[DI],AL		; 半角のまま
	INC	DI			;
	JMP	WORDTL_N_HNZN_NEXT

WORDTL_N_HNZN_41:
	MOV	AX,"＄"
	JMP	WORDTL_N_HNZN_SET
WORDTL_N_HNZN_42:
	MOV	AX,"％"
	JMP	WORDTL_N_HNZN_SET
WORDTL_N_HNZN_43:
	MOV	AX,"　"
	JMP	WORDTL_N_HNZN_SET

WORDTL_N_HNZN_SET:
	MOV	DS:[DI],AH		;
	INC	DI			;
	MOV	DS:[DI],AL		;
	INC	DI			;
WORDTL_N_HNZN_NEXT:
	LOOP	WORDTL_N_HNZN_LOOP
WORDTL_N_HNZN_EXIT:
	MOV	DS:[DI],BYTE PTR 0	; ＥＯＳ
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