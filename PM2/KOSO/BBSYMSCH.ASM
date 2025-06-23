; "BBSYMSCH.ASM" PC-9801UV11 make by R.H 1991/10/16
;
;
;	princess  B A S I C    symbol search.
;
;
; command routine.

INCLUDE	TSTSETC.INC
INCLUDE	BBEXTRN.INC

TCHRSEG	SEGMENT	PUBLIC	'TCHRSEG'
TCHRSEG	ENDS

TCHRADR	SEGMENT	PUBLIC	'TCHRADR'
TCHRADR	ENDS

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA


PUBLIC	BBSYMBOL_SCH			; symbol table search.
PUBLIC	BBSOUSYM_SCH			; source symbol table search.


; *********************************************************
;	symbol table search.
;	-I- STRSYMBOL : symbol string.
;	    STRSYMLEN : symbol length.
;	-O- AX        : 0=search,1=none.
;	    SYMNUMBER : symbol number.
;	    SYMSEGM   : segment of symbol.
;	    SYMOFST   : offset of symbol.
; *********************************************************

BBSYMBOL_SCH	PROC	NEAR
	MOV	DI,STRSYMBOL			; symbol string.
	MOV	CX,STRSYMLEN			; symbol length.

	CALL	SYMBL_SCH			; symbol table search.

	MOV	SYMNUMBER,BP			; symbol number.
	MOV	SYMOFST,DI			; offset of symbol.
	MOV	SYMSEGM,DX			; segment of symbol.

	RET
BBSYMBOL_SCH	ENDP


; *********************************************************
;	source symbol table search.
;	-I- STRSYMBOL : symbol string.
;	    STRSYMLEN : symbol length.
;	-O- AX           : 0=search,1=none.
;	    SOUSYMNUMBER : source symbol number.
;	    SOUSYMOFST   : offset of source symbol.
;	    SOUSYMSEGM   : segment of source symbol.
; *********************************************************

BBSOUSYM_SCH	PROC	NEAR
	MOV	DI,STRSYMBOL			; symbol string.
	MOV	CX,STRSYMLEN			; symbol length.

	CALL	SYMBL_SCH			; symbol table search.

	MOV	SOUSYMNUMBER,BP			; source symbol number.
	MOV	SOUSYMOFST,DI			; offset of source symbol.
	MOV	SOUSYMSEGM,DX			; segment of source symbol.

	RET
BBSOUSYM_SCH	ENDP


; *********************************************************
;	symbol table search.
;	-I- DI : symbol string.
;	    CX : symbol length.
;	-O- AX : 0=search,1=none.
;	    BP : symbol number.
;	    DI : offset of symbol.
;	    DX : segment of symbol.
; *********************************************************

SYMBL_SCH	PROC	NEAR
	MOVX	ES,DS

	PUSH	DS
	MOVX	DS,<SEG TCHRSEG>
	MOV	SI,0
	MOV	DH,0				; DH=0
	MOV	BP,0				; number.
SYMBL_SCH_LOOP:
	MOV	BX,SI				;
	LODSB					; counter get.
	CMP	AL,0				; end of table?
	JE	SYMBL_SCH_NONE			;

	MOV	DL,AL				; symbol length.
	CMP	AL,CL				; symbol length.
	JNE	SYMBL_SCH_NEXT			;

	MOV	AX,DI				;
	MOV	DH,CL				;
	REPE	CMPSB				; string comper.
	MOV	CL,DH				;
	MOV	DI,AX				;
	JE	SYMBL_SCH_OK			;

	XOR	DH,DH				; DH=0
SYMBL_SCH_NEXT:					;
	MOV	SI,BX				;
	ADD	SI,DX				; current + length.
	INC	SI				; + 1 (counter)
	INC	BP				; number.
	JMP	SYMBL_SCH_LOOP

SYMBL_SCH_OK:					;
	POP	DS				;

	MOVX	ES,<SEG TCHRADR>		;
	MOV	DI,BP				;
	SHL	DI,1				;
	SHL	DI,1				; * 4

	MOV	DX,ES:[DI][2]			; segment of symbol.
	MOV	DI,ES:[DI]			; offset of symbol.

	MOV	AX,0				; 0=search.
	RET
SYMBL_SCH_NONE:					;
	POP	DS
	MOV	AX,1				; 1=none.
	RET
SYMBL_SCH	ENDP

CODE	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'
DATA	ENDS

	END
;
;	end of "BBSYMSCH.ASM"
;
