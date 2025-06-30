; "NAMEIN.ASM" 486/50 make by R.H 1993/02/01
;
;
;	名前入力
;
;
; public subroutine.

INCLUDE	TSTSET.INC

RETFAR	MACRO				; ＦＡＲリターン
	DB	11001011B		; RETF
	ENDM

CHILD_STRING_LEN	EQU	64	; child string length.

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	MAIN_FUNCTION_INTER		; main function inter.
PUBLIC	MAIN_F_INTER_C_CODE		; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE)
PUBLIC	MAIN_F_INTER_C_CODE01		; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
PUBLIC	MAIN_F_REG_SAVE			; register save.
PUBLIC	MAIN_F_REG_LOAD			; register load.

; ****************************************************
;	PROGRAM CODE
; ****************************************************

	ORG	100H
START:
	JMP	SHORT FINALE

	ORG	102H

		DW	FUNCTION_ENTRY	;(+102h) function entry.
MAIN_F_JMP_OFS	DW	0		;(+104h) main function inter offset.
MAIN_F_JMP_SEG	DW	0		;(+106h) main function inter segment.
EXIT_STATUS	DW	0		;(+108h) exit status.
FUNCTION_NUM	DW	0		;(+10ah) function number.
		DW	0		;(+10ch)
		DW	0		;(+10eh)
		DW	0		;(+110h)
		DW	0		;(+112h)
		DW	0		;(+114h)
		DW	0		;(+116h)
		DW	0		;(+118h)
		DW	0		;(+11ah)
		DW	0		;(+11ch)
		DW	0		;(+11eh)
		DW	0		;(+120h)
		DW	0		;(+122h)
		DW	0		;(+124h)
		DW	0		;(+126h)
		DW	0		;(+128h)
		DW	0		;(+12ah)
SUB_FUNCTION	DW	0		;(+12ch) sub function number.
		DW	0		;(+12eh)
		DW	0		;(+130h)
PARAM01		DW	0		;(+132h) parameter 1.
PARAM02		DW	0		;(+134h) parameter 2.
PARAM03		DW	0		;(+136h) parameter 3.
PARAM04		DW	0		;(+138h) parameter 4.
PARAM05		DW	0		;(+13ah) parameter 5.
PARAM06		DW	0		;(+13ch) parameter 6.
DEBUGXX		DW	0		;(+13eh) debug mode.

FINALE:
	MOV	DX,OFFSET MY_MESSAGE	;
	MOV	AH,09H			; print string.
	INT	21H			;
	MOV	AH,4CH			; return to DOS.
	MOV	AL,0			;
	INT	21H			; end.
	JMP	$			;

; ****************************************************
;	function entry.
;	-I- FUNCTION_NUM : function number.
; ****************************************************

FUNCTION_ENTRY	PROC	NEAR
	CALLE	MAINLP			; main loop.
	RETFAR
FUNCTION_ENTRY	ENDP


; ****************************************************
;	main function inter.
;	-I/O- BX,CX,DX,SI,DI,ES : user parameter.
; ****************************************************

MAIN_FUNCTION_INTER	PROC	NEAR
	PUSH	DS
	MOV	AX,CS
	PUSH	AX
	MOV	AX,OFFSET MAIN_FUNCTION_INTER_RET
	PUSH	AX
	PUSH	MAIN_F_JMP_SEG		; main function inter segment.
	PUSH	MAIN_F_JMP_OFS		; main function inter offset.
	RETFAR

MAIN_FUNCTION_INTER_RET:
	POP	DS
	RET
MAIN_FUNCTION_INTER	ENDP


; ****************************************************
;	ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE)
;	-I- CX : function number.
;	    DI : operation. 0=normal,1=SI string,2=SI string i/o.
; ****************************************************

MAIN_F_INTER_C_CODE	PROC	NEAR
	MOV	WGATE_OPERA,DI		; operation.
	MOV	DX,DS			; register table segment.
	MOV	SI,OFFSET TBL_REGISTER	; register table.
	MOV	BX,22			; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE)
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	CALL	MAIN_F_REG_LOAD		; register load.
	RET
MAIN_F_INTER_C_CODE	ENDP


; ****************************************************
;	ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
;	-I- CX : function number.
;	    DI : operation. 0=normal,1=SI string,2=SI string i/o.
;			    3=SI string out.
; ****************************************************

MAIN_F_INTER_C_CODE01	PROC	NEAR
	MOV	WGATE_OPERA,DI		; operation.
	MOV	DX,DS			; register table segment.
	MOV	SI,OFFSET TBL_REGISTER	; register table.
	MOV	BX,23			; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	CALL	MAIN_F_REG_LOAD		; register load.
	RET
MAIN_F_INTER_C_CODE01	ENDP


; ****************************************************
;	register save.
;	-I- AX,BX,CX,DX,SI,DI,DS
;		<< register table >>
;		DX:[CX][0]	: AX
;		DX:[CX][2]	: BX
;		DX:[CX][4]	: CX
;		DX:[CX][6]	: DX
;		DX:[CX][8]	: SI
;		DX:[CX][10]	: DI
;		DX:[CX][12]	: DS
;		DX:[CX][14]	: main DS
; ****************************************************

MAIN_F_REG_SAVE	PROC	NEAR
	MOV	TBL_REGISTER,AX
	MOV	TBL_REGISTER[2],BX
	MOV	TBL_REGISTER[4],CX
	MOV	TBL_REGISTER[6],DX
	MOV	TBL_REGISTER[8],SI
	MOV	TBL_REGISTER[10],DI
	MOV	TBL_REGISTER[12],DS
	RET
MAIN_F_REG_SAVE	ENDP


; ****************************************************
;	register load.
;	-O- AX,BX,CX,DX,SI,DI
; ****************************************************

MAIN_F_REG_LOAD	PROC	NEAR
	CMP	WGATE_OPERA,3		; 3=SI string out.
	JNE	MAIN_F_REG_LOAD_3	;

	MOV	SI,TBL_REGISTER[8]
	MOV	DX,TBL_REGISTER[14]
	MOV	CX,CHILD_STRING_LEN	; child string length.
	MOV	DI,OFFSET CHILD_STRING	; child string.
	PUSH	ES
	PUSH	DS
	MOVX	ES,DS
	MOV	DS,DX
	REP	MOVSB
	POP	DS
	POP	ES

	MOV	AX,OFFSET CHILD_STRING	; child string.
	MOV	TBL_REGISTER[8],AX

MAIN_F_REG_LOAD_3:
	MOV	AX,TBL_REGISTER
	MOV	BX,TBL_REGISTER[2]
	MOV	CX,TBL_REGISTER[4]
	MOV	DX,TBL_REGISTER[6]
	MOV	SI,TBL_REGISTER[8]
	MOV	DI,TBL_REGISTER[10]

	RET
MAIN_F_REG_LOAD	ENDP


; ****************************************************
;	data.
; ****************************************************

		EVEN
WGATE_OPERA	DW	0				; operation.
TBL_REGISTER	DW	8 DUP (0)			; register table.
CHILD_STRING	DB	CHILD_STRING_LEN DUP (0),0,0	; child string.

MY_MESSAGE	DB "「プリンセスメーカー２」$",0

CODE	ENDS

	END	START
;
;	end of "NAMEIN.ASM"
;
