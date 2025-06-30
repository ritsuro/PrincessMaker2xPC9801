; "ENDING.ASM" 486/50 make by R.H 1993/02/16
;
;
;	エンディング・ライブラリ
;
;
;	PARC(1,"ENDING.COM",1,0)	; 初期処理
;	PARC(2,2,offset,segment)	; ﾃｷｽﾄ編集ﾊﾞｯﾌｧｱﾄﾞﾚｽｾｯﾄ
;	PARC(2,3)			; ﾃｷｽﾄ編集ﾊﾞｯﾌｧ表示
;	PARC(2,4)			; ｴﾝﾃﾞｨﾝｸﾞ･ﾃｷｽﾄ表示１
;	PARC(2,5,startx,starty)		; ﾃｷｽﾄ位置ｾｯﾄ
;	PARC(2,6,linelen)		; ﾃｷｽﾄ編集ｾﾝﾀﾘﾝｸﾞ
;	PARC(2,7)			; ｴﾝﾃﾞｨﾝｸﾞ･ﾃｷｽﾄ表示2.ｽｸﾛｰﾙ
;	PARC(2,8,linelen)		; ﾃｷｽﾄ編集右端ｶｯﾄ
;	PARC(2,9,scrl_wait,scrl_count,scrl_step) ; ｽｸﾛｰﾙ送り設定
;	PARC(2,10,x,y,sizex,sizey)	; ｽｸﾛｰﾙview設定
;	PARC(2,11,hight)		; ﾃｷｽﾄ行間ｾｯﾄ
;	PARC(2,12,vvram1or2)		; ｴﾝﾃﾞｨﾝｸﾞ･ﾃｷｽﾄ画面転送3.ｽﾀｯﾌｽｸﾛｰﾙ
;	PARC(2,13,vvram1or2)		; ｴﾝﾃﾞｨﾝｸﾞ･ﾃｷｽﾄ取り込み3.ｽﾀｯﾌｽｸﾛｰﾙ
;	PARC(2,14)			; ｵｰﾌﾟﾆﾝｸﾞ･ﾃｷｽﾄ表示１
;	PARC(2,15)			; ｵｰﾌﾟﾆﾝｸﾞ･ﾃﾛｯﾌﾟ1･ｴﾘｱｸﾘｱ
;	PARC(2,16,x,y,n)		; ｵｰﾌﾟﾆﾝｸﾞ･ﾃﾛｯﾌﾟ1･ﾊﾟﾀｰﾝPUT
;	PARC(2,17)			; ｵｰﾌﾟﾆﾝｸﾞ･ﾃﾛｯﾌﾟ1･ｽｸﾛｰﾙ
;	PARC(2,18)			; ｴﾝﾃﾞｨﾝｸﾞ･ﾃｷｽﾄ表示2.文字送り表示
;	PARC(2,19,line)			; 文字送り行数設定
;
;
;	vvram1=1630line.
;	vvram2=1300line.
;	vvram3=1630line.
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
	MOV	AX,FUNCTION_NUM		;(+10ah) function number.
	MOV	BX,SUB_FUNCTION		;(+12ch) sub function number.
	MOV	CX,PARAM01		;(+132h) parameter 1.
	MOV	DX,PARAM02		;(+134h) parameter 2.
	MOV	SI,PARAM03		;(+136h) parameter 3.
	MOV	DI,PARAM04		;(+138h) parameter 4.
	MOV	BP,PARAM05		;(+13ah) parameter 5.
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
;		DX:[CX][16]	: ES
; ****************************************************

MAIN_F_REG_SAVE	PROC	NEAR
	MOV	TBL_REGISTER,AX
	MOV	TBL_REGISTER[2],BX
	MOV	TBL_REGISTER[4],CX
	MOV	TBL_REGISTER[6],DX
	MOV	TBL_REGISTER[8],SI
	MOV	TBL_REGISTER[10],DI
	MOV	TBL_REGISTER[12],DS
	MOV	TBL_REGISTER[16],ES
	RET
MAIN_F_REG_SAVE	ENDP


; ****************************************************
;	register load.
;	-O- AX,BX,CX,DX,SI,DI,ES
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
	PUSH	TBL_REGISTER[16]
	POP	ES

	RET
MAIN_F_REG_LOAD	ENDP


; ****************************************************
;	data.
; ****************************************************

		EVEN
WGATE_OPERA	DW	0				; operation.
TBL_REGISTER	DW	9 DUP (0)			; register table.
CHILD_STRING	DB	CHILD_STRING_LEN DUP (0),0,0	; child string.

MY_MESSAGE	DB "「プリンセスメーカー２」$",0

CODE	ENDS

	END	START
;
;	end of "ENDING.ASM"
;
