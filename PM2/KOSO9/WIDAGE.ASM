; "WIDAGE.ASM" 486/50 make by R.H 1993/02/03
;
;
;	年齢入力ウインドウ
;
;
;	WIDAGE_SET			; WINDOWS/年齢入力
;
;
;	設定されるﾊﾟﾗﾒｰﾀ
;
;	SLCT_AGE     選択された年齢
;
;
; (C) 1990,1991,1993 ritsurou hashimoto.

INCLUDE	TSTSET.INC

FUNC	MACRO	SUB
PUBLIC	SUB
SUB	PROC	NEAR
	ENDM

FEND	MACRO	SUB
SUB	ENDP
	ENDM

OFFF		EQU	0FFFFH	; とりあえずＯＦＦという意味

SCREEN_STR_X	EQU	40-20	; スクリーン文字Ｘ
SCREEN_STR_Y	EQU	170	; スクリーン文字Ｙ
AGE_CHR_X1	EQU	38	; 年齢表示位置Ｘ1
AGE_CHR_Y1	EQU	144	; 年齢表示位置Ｙ1
AGE_CHR_X2	EQU	40	; 年齢表示位置Ｘ2
AGE_CHR_Y2	EQU	144	; 年齢表示位置Ｙ2

KETTEI_XX	EQU	17		; 決定ボタン位置X
KETTEI_YY	EQU	210+20*5	; 決定ボタン位置Y
KETTEI_XL	EQU	4		; 決定ボタンサイズＸ
KETTEI_YL	EQU	20		; 決定ボタンサイズＹ

BACKCOL		EQU	10	; 背景カラー

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

; ****************************************************
;	年齢入力
;	-O- AX : 0=通常,2=キャンセル
;	    SLCT_AGE : 選択された年齢
; ****************************************************

FUNC	WIDAGE_SET
	CALL	AGE_OPEN		; 年齢入力ＯＰＥＮ

	CALL	AGE_MAIN		; 年齢入力ＭＡＩＮ
	CMP	AX,1			; 1=キャンセル
	JE	WIDAGE_SET_CANCEL	;

	CALL	AGE_CLOSE		; 年齢入力ＣＬＯＳＥ

	MOV	AX,0			; 0=通常
	RET
WIDAGE_SET_CANCEL:
	MOV	AX,2			; 2=キャンセル
	RET
FEND	WIDAGE_SET


; ****************************************************
;	年齢入力ＯＰＥＮ
; ****************************************************

AGE_OPEN	PROC	NEAR
	CALL	AGE_CLEAR		; 年齢クリア
	CALL	ALL_MES_CLEAR		; メッセージ全体クリア

	MOV	DISP_NUMBER,0		; 表示する数字
	MOV	CX,10			;
AGE_OPEN_LOOP:				;
	PUSH	CX			;
	CALL	AGE_TYPE_SHOW		; 数字の表示
	INC	DISP_NUMBER		; 表示する数字
	POP	CX			;
	LOOP	AGE_OPEN_LOOP		;

	CALL	FUNC_SHOW		; ファンクション表示

	MOV	DX,6			; "あなたの年齢を教えて下さい"
	CALLE	WIDNAME_MESSAGE		; WINDOWS/名前ウインドウ・メッセージ
	RET
AGE_OPEN	ENDP


; ****************************************************
;	年齢入力ＣＬＯＳＥ
; ****************************************************

AGE_CLOSE	PROC	NEAR
	RET
AGE_CLOSE	ENDP


; ****************************************************
;	年齢入力ＭＡＩＮ
;	-O- AX       : 1=キャンセル
;	    SLCT_AGE : 選択された年齢
; ****************************************************

AGE_MAIN	PROC	NEAR
	CALL	WID_SLCT		; マウスセレクト
	CMP	AX,1			; 1=キャンセル
	JE	AGE_MAIN_CANCEL		;

	CALL	AGE_SETER		; データベースＳＥＴ

	MOV	AX,0
	RET
AGE_MAIN_CANCEL:
	MOV	AX,1			; 1=キャンセル
	RET
AGE_MAIN	ENDP


; ****************************************************
;	マウスセレクト
;	-O- AX       : 1=キャンセル
;	    SLCT_AGE : 選択された年齢
; ****************************************************

WID_SLCT	PROC	NEAR
	MOV	SLCT_AGE,0		; 選択された年齢
	MOV	DISP_AGE_TBL,0		; 年齢(2桁)
	MOV	DISP_AGE_TBL[2],0	;

	CALLE	MSCSRT			; カーソルスタート
WID_SLCT_LOOP:				;
	CALLE	MSCMOV			; カーソル移動
	CMP	DL,1			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WID_SLCT_1		;
	JMP	WID_SLCT_CANCEL		;
WID_SLCT_1:				;
	CMP	DH,1			; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WID_SLCT_2		;
	JMP	WID_SLCT_ON		;
WID_SLCT_2:				;
	MOV	MOUSEX,AX		; マウスＸ
	MOV	MOUSEY,BX		; マウスＹ

	CALL	NUMBER_SCH		; サーチ・数字
	CALL	FUNCTION_SCH		; ｻｰﾁ･ﾌｧﾝｸｼｮﾝ
	CALL	NUMBER_SHOW		; 数字の表示
	CALL	FUNCTION_SHOW		; ﾌｧﾝｸｼｮﾝの表示
WID_SLCT_NEXT:				;
	JMP	WID_SLCT_LOOP		;

WID_SLCT_ON:
	CMP	NOW_FUNC_NUM,OFFF	; 選択されたﾌｧﾝｸｼｮﾝ
	JE	WID_SLCT_5		;
	CMP	SLCT_AGE,10		; 選択された年齢
	JNB	WID_SLCT_EXIT		;

WID_SLCT_5:
	CMP	NOW_SLCT_NUM,OFFF	; 選択された数字
	JE	WID_SLCT_LOOP		;

	CALL	AGE_DATA_CHK		; 年齢のﾃﾞｰﾀﾁｪｯｸ
	CALL	AGE_SHOW		; 年齢の表示
	JMP	WID_SLCT_LOOP		;

WID_SLCT_EXIT:
	CALLE	MSCSTP			; カーソルストップ
	MOV	AX,0			;
	RET
WID_SLCT_CANCEL:
	CALLE	MSCSTP			; カーソルストップ
	MOV	AX,1			; 1=キャンセル
	RET
WID_SLCT	ENDP


; ****************************************************
;	サーチ・数字
;	-I-   MOUSEX       : マウスＸ
;	      MOUSEY       : マウスＹ
;	-O-   NOW_SLCT_NUM : 選択された数字
; ****************************************************

NUMBER_SCH	PROC	NEAR
	MOV	NOW_SLCT_NUM,0			; 選択された数字

	MOV	CX,10				;
NUMBER_SCH_LOOP:
	MOV	AX,MOUSEX			; マウスＸ
	MOV	BX,MOUSEY			; マウスＹ

	MOV	SI,NOW_SLCT_NUM			; 選択された数字
	SHL	SI,1				; word pointer.
	SUB	AX,AGE_DSP_XX_TBL[SI]		; 数字の表示Ｘ
	JB	NUMBER_SCH_NEXT
	CMP	AX,AGE_DSP_X2			; 数字の表示範囲Ｘ
	JNBE	NUMBER_SCH_NEXT

	SUB	BX,AGE_DSP_YY			; 数字の表示Ｙ
	JB	NUMBER_SCH_NEXT
	CMP	BX,AGE_DSP_Y2			; 数字の表示範囲Ｙ
	JNBE	NUMBER_SCH_NEXT

	JMP	NUMBER_SCH_SEARCH
NUMBER_SCH_NEXT:
	INC	NOW_SLCT_NUM			; 選択された数字
	LOOP	NUMBER_SCH_LOOP

	JMP	NUMBER_SCH_NONE
NUMBER_SCH_SEARCH:
	RET
NUMBER_SCH_NONE:
	MOV	NOW_SLCT_NUM,OFFF		;
	RET
NUMBER_SCH	ENDP


; ****************************************************
;	年齢のﾃﾞｰﾀﾁｪｯｸ
;	-I- NOW_SLCT_NUM : 選択された数字
;	    DISP_AGE_TBL : 年齢(2桁)
; ****************************************************

AGE_DATA_CHK	PROC	NEAR
	MOV	AX,DISP_AGE_TBL		; 年齢(2桁)
	MOV	DISP_AGE_TBL[2],AX	; 年齢(2桁)
	MOV	AX,NOW_SLCT_NUM		; 選択された数字
	MOV	DISP_AGE_TBL,AX		; 年齢(2桁)

	MOV	SLCT_AGE,AX		; 選択された年齢

	MOV	AX,DISP_AGE_TBL[2]	; 年齢
	MOV	BX,10			;
	MUL	BX			; * 10

	ADD	SLCT_AGE,AX		; 選択された年齢

	RET
AGE_DATA_CHK	ENDP


; ****************************************************
;	数字の表示
;	-I- NOW_SLCT_NUM : 選択された数字
; ****************************************************

NUMBER_SHOW	PROC	NEAR
	CMPX	DISP_SLCT_NUM,NOW_SLCT_NUM	; 選択された血液型
	JNE	NUMBER_SHOW_START		;
	RET
NUMBER_SHOW_START:

	CALLE	MSCSTP				; カーソルストップ
	MOVX	DISP_NUMBER,DISP_SLCT_NUM	; 表示中の血液型
	CALL	AGE_TYPE_SHOW			; 数字の表示

	MOVX	DISP_NUMBER,NOW_SLCT_NUM	; 選択された数字
	CALL	AGE_TYPE_GOLD			; 数字ＧＯＬＤ

	MOVX	DISP_SLCT_NUM,NOW_SLCT_NUM	; 選択された数字
	CALLE	MSCSRT				; カーソルスタート
	RET
NUMBER_SHOW	ENDP


; ****************************************************
;	ｻｰﾁ･ﾌｧﾝｸｼｮﾝ
;	-I-   MOUSEX       : マウスＸ
;	      MOUSEY       : マウスＹ
;	-O-   NOW_FUNC_NUM : 選択されたﾌｧﾝｸｼｮﾝ
; ****************************************************

FUNCTION_SCH	PROC	NEAR
	MOV	AX,MOUSEX		; マウスＸ
	MOV	BX,MOUSEY		; マウスＹ

	SUB	AX,KETTEI_XX		; 決定ボタン位置X
	JB	FUNCTION_SCH_NONE	;
	CMP	AX,KETTEI_XL		; 決定ボタンサイズＸ
	JNBE	FUNCTION_SCH_NONE	;

	SUB	BX,KETTEI_YY		; 決定ボタン位置Y
	JB	FUNCTION_SCH_NONE	;
	CMP	BX,KETTEI_YL		; 決定ボタンサイズＹ
	JNBE	FUNCTION_SCH_NONE	;

	MOV	NOW_FUNC_NUM,0			; 選択されたﾌｧﾝｸｼｮﾝ
	RET
FUNCTION_SCH_NONE:
	MOV	NOW_FUNC_NUM,OFFF		; 選択されたﾌｧﾝｸｼｮﾝ
	RET
FUNCTION_SCH	ENDP


; ****************************************************
;	ﾌｧﾝｸｼｮﾝの表示
;	-I- NOW_FUNC_NUM : 選択されたﾌｧﾝｸｼｮﾝ
; ****************************************************

FUNCTION_SHOW	PROC	NEAR
	CMPX	DISP_FUNC_NUM,NOW_FUNC_NUM	; 選択されたﾌｧﾝｸｼｮﾝ
	JNE	FUNCTION_SHOW_START		;
	RET
FUNCTION_SHOW_START:
	CALLE	MSCSTP				; カーソルストップ

	CMP	NOW_FUNC_NUM,OFFF		; 選択されたﾌｧﾝｸｼｮﾝ
	JE	FUNCTION_SHOW_OFF		;

FUNCTION_SHOW_ON:
	CALL	FUNC_GOLD			; ファンクションＧＯＬＤ
	JMP	FUNCTION_SHOW_8			;

FUNCTION_SHOW_OFF:
	CALL	FUNC_SHOW			; ファンクション表示

FUNCTION_SHOW_8:
	MOVX	DISP_FUNC_NUM,NOW_FUNC_NUM	; 選択されたﾌｧﾝｸｼｮﾝ
	CALLE	MSCSRT				; カーソルスタート
	RET
FUNCTION_SHOW	ENDP


; ****************************************************
;	年齢の表示
;	-I- DISP_AGE_TBL : 年齢(2桁)
; ****************************************************

AGE_SHOW	PROC	NEAR
	CALL	AGE_CLEAR		; 年齢クリア

	MOV	DI,DISP_AGE_TBL[2]	; 年齢(2桁)
	CMP	DI,0			;
	JE	AGE_SHOW_5		;

	SHL	DI,1			; word pointer.
	MOV	SI,AGE_DSP_STR_TBL[DI]	; 数字の表示文字
	MOV	AX,AGE_CHR_X1		; 年齢表示位置Ｘ1
	MOV	BX,AGE_CHR_Y1		; 年齢表示位置Ｙ1
	CALL	GOLD_STR_PUT		; ＧＯＬＤ文字列ＰＵＴ

AGE_SHOW_5:
	MOV	DI,DISP_AGE_TBL		; 年齢(2桁)
	SHL	DI,1			; word pointer.
	MOV	SI,AGE_DSP_STR_TBL[DI]	; 数字の表示文字
	MOV	AX,AGE_CHR_X2		; 年齢表示位置Ｘ2
	MOV	BX,AGE_CHR_Y2		; 年齢表示位置Ｙ2
	CALL	GOLD_STR_PUT		; ＧＯＬＤ文字列ＰＵＴ

	RET
AGE_SHOW	ENDP


; ****************************************************
;	ファンクション表示
; ****************************************************

FUNC_SHOW	PROC	NEAR
	MOV	AX,KETTEI_XX			; 決定ボタン位置X
	MOV	BX,KETTEI_YY			; 決定ボタン位置Y
	MOV	SI,OFFSET FUNC_KETTEI		; 決定
	CALL	STRING_PUT			; 文字列ＰＵＴ
	RET
FUNC_SHOW	ENDP


; ****************************************************
;	ファンクションＧＯＬＤ
; ****************************************************

FUNC_GOLD	PROC	NEAR
	MOV	AX,KETTEI_XX			; 決定ボタン位置X
	MOV	BX,KETTEI_YY			; 決定ボタン位置Y
	MOV	SI,OFFSET FUNC_KETTEI		; 決定
	CALL	GOLD_STR_PUT			; ＧＯＬＤ文字列ＰＵＴ
	RET
FUNC_GOLD	ENDP


; ****************************************************
;	数字の表示
;	-I- DISP_NUMBER : 表示する数字
; ****************************************************

AGE_TYPE_SHOW	PROC	NEAR
	CMP	DISP_NUMBER,9			; 表示する数字
	JNBE	AGE_TYPE_SHOW_EXIT		;

	MOV	DI,DISP_NUMBER			; 表示する数字
	SHL	DI,1				; word pointer.
	MOV	AX,DS:AGE_DSP_XX_TBL[DI]	; 数字の表示Ｘ
	MOV	BX,DS:AGE_DSP_YY		; 数字の表示Ｙ
	MOV	SI,DS:AGE_DSP_STR_TBL[DI]	; 数字の表示文字
	CALL	STRING_PUT			; 文字列ＰＵＴ
AGE_TYPE_SHOW_EXIT:
	RET
AGE_TYPE_SHOW	ENDP


; ****************************************************
;	数字ＧＯＬＤ
;	-I- DISP_NUMBER : 表示する数字
; ****************************************************

AGE_TYPE_GOLD	PROC	NEAR
	CMP	DISP_NUMBER,9			; 表示する数字
	JNBE	AGE_TYPE_GOLD_EXIT		;

	MOV	DI,DISP_NUMBER			; 表示する数字
	SHL	DI,1				; word pointer.
	MOV	AX,DS:AGE_DSP_XX_TBL[DI]	; 数字の表示Ｘ
	MOV	BX,DS:AGE_DSP_YY		; 数字の表示Ｙ
	MOV	SI,DS:AGE_DSP_STR_TBL[DI]	; 数字の表示文字
	CALL	GOLD_STR_PUT			; ＧＯＬＤ文字列ＰＵＴ
AGE_TYPE_GOLD_EXIT:
	RET
AGE_TYPE_GOLD	ENDP


; ****************************************************
;	文字列ＰＵＴ
;	-I- SI : 文字列
;	    AX : Ｘ
;	    BX : Ｙ
; ****************************************************

STRING_PUT	PROC	NEAR
	CALLE	WIDNAME_PRINT		; WINDOWS/名前ウインドウ文字列表示
	RET
STRING_PUT	ENDP


; ****************************************************
;	ＧＯＬＤ文字列ＰＵＴ
;	-I- SI : 文字列
;	    AX : Ｘ
;	    BX : Ｙ
; ****************************************************

GOLD_STR_PUT	PROC	NEAR
	CALLE	WIDNAME_PRINTG		; WINDOWS/名前ウインドウ文字列ＧＯＬＤ
	RET
GOLD_STR_PUT	ENDP


; ****************************************************
;	データベースＳＥＴ
;	-I- AGE_TYPE : 1=Ａ型,2=Ｂ型,3=ＡＢ型,4=Ｏ型
; ****************************************************

AGE_SETER	PROC	NEAR
	RET
AGE_SETER	ENDP


; ****************************************************
;	年齢クリア
; ****************************************************

AGE_CLEAR	PROC	NEAR
	MOV	VX1,18
	MOV	VY1,136
	MOV	VX2,60
	MOV	VY2,162
	MOV	CX,BACKCOL		; 台詞カラー
	CALLE	BOXPAL			; ＢＯＸペイント
	RET
AGE_CLEAR	ENDP


; ****************************************************
;	メッセージ全体クリア
; ****************************************************

ALL_MES_CLEAR	PROC	NEAR
	MOV	VX1,15
	MOV	VY1,152
	MOV	VX2,63
	MOV	VY2,328
	MOV	CX,BACKCOL		; 台詞カラー
	CALLE	BOXPAL			; ＢＯＸペイント
	RET
ALL_MES_CLEAR	ENDP


; ****************************************************
;	data.
; ****************************************************

PUBLIC	SLCT_AGE		; 選択された年齢

EXTRN	AGE_DSP_STR_TBL:WORD	; 数字の表示文字
EXTRN	FUNC_KETTEI:BYTE	; 決定

EXTRN	VX1:WORD		; point x1.
EXTRN	VY1:WORD		; point y1.
EXTRN	VX2:WORD		; point x2.
EXTRN	VY2:WORD		; point y2.

		EVEN
SLCT_AGE	DW	0		; 選択された年齢

NOW_SLCT_NUM	DW	0		; 選択された数字
DISP_SLCT_NUM	DW	0		; 表示中の数字
DISP_NUMBER	DW	0		; 表示する数字
DISP_AGE_TBL	DW	0,0		; 年齢(2桁)

NOW_FUNC_NUM	DW	0		; 選択されたﾌｧﾝｸｼｮﾝ
DISP_FUNC_NUM	DW	0		; 表示中ﾌｧﾝｸｼｮﾝ

AGE_DSP_XX_TBL	LABEL	WORD		; 数字の表示Ｘ
		DW	26		;0
		DW	26+3		;1
		DW	26+3*2		;2
		DW	26+3*3		;3
		DW	26+3*4		;4
		DW	26+3*5		;5
		DW	26+3*6		;6
		DW	26+3*7		;7
		DW	26+3*8		;8
		DW	26+3*9		;9

AGE_DSP_YY	DW	238		; 数字の表示Ｙ
AGE_DSP_X2	DW	2		; 数字の表示範囲Ｘ
AGE_DSP_Y2	DW	20		; 数字の表示範囲Ｙ

MOUSEX		DW	0		; マウスＸ
MOUSEY		DW	0		; マウスＹ

CODE	ENDS

	END
;
;	end of "WIDAGE.ASM"
;
