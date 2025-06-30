; "WIDBLOOD.ASM" PC-9801UV11 make by R.H 1991/04/22
;		modify486/50 make by R.H 1993/02/03
;
;
;	血液型入力ウインドウ
;
;
;	WIDBLOOD_SET			; WINDOWS/血液型入力
;
;
;	設定されるﾊﾟﾗﾒｰﾀ
;
;	BLOOD_TYPE	血液型  0=Ａ型,1=Ｂ型,2=Ｏ型,3=ＡＢ型
;
;
; (C) 1990,1991,1993 ritsurou hashimoto.

INCLUDE	TSTSET.INC

OFFF		EQU	0FFFFH	; とりあえずＯＦＦという意味

BLOOD_A_XX	EQU	26			; Ａ・Ｘ
BLOOD_A_YY	EQU	238			; Ａ・Ｙ
BLOOD_A_XL	EQU	26+2			; Ａ・Ｘ２
BLOOD_A_YL	EQU	238+16			; Ａ・Ｙ２

BLOOD_B_XX	EQU	26+8			; Ｂ・Ｘ
BLOOD_B_YY	EQU	238			; Ｂ・Ｙ
BLOOD_B_XL	EQU	26+8+2			; Ｂ・Ｘ２
BLOOD_B_YL	EQU	238+16			; Ｂ・Ｙ２

BLOOD_O_XX	EQU	27+8+8			; Ｏ・Ｘ
BLOOD_O_YY	EQU	238			; Ｏ・Ｙ
BLOOD_O_XL	EQU	27+8+8+2		; Ｏ・Ｘ２
BLOOD_O_YL	EQU	238+16			; Ｏ・Ｙ２

BLOOD_AB_XX	EQU	26+8+8+8		; Ａ・ＢＸ
BLOOD_AB_YY	EQU	238			; Ａ・ＢＹ
BLOOD_AB_XL	EQU	26+8+8+8+4		; Ａ・ＢＸ２
BLOOD_AB_YL	EQU	238+16			; Ａ・ＢＹ２

BACKCOL		EQU	10			; 背景カラー

FUNC	MACRO	SUB
PUBLIC	SUB
SUB	PROC	NEAR
	ENDM

FEND	MACRO	SUB
SUB	ENDP
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

; ****************************************************
;	血液型入力
;	-O- AX : 0=通常,2=キャンセル
;	    BLOOD_TYPE : 0=Ａ型,1=Ｂ型,2=Ｏ型,3=ＡＢ型
; ****************************************************

FUNC	WIDBLOOD_SET
	CALL	BLOOD_OPEN		; 血液型入力ＯＰＥＮ

	CALL	BLOOD_MAIN		; 血液型入力ＭＡＩＮ
	CMP	AX,1			; 1=キャンセル
	JE	WIDBLOOD_SET_CANCEL	;

	CALL	BLOOD_CLOSE		; 血液型入力ＣＬＯＳＥ

	MOV	AX,0			; 0=通常
	RET
WIDBLOOD_SET_CANCEL:
	MOV	AX,2			; 2=キャンセル
	RET
FEND	WIDBLOOD_SET


; ****************************************************
;	血液型入力ＯＰＥＮ
; ****************************************************

BLOOD_OPEN	PROC	NEAR
	CALL	ALL_MES_CLEAR		; メッセージ全体クリア

	MOV	DISP_BLOOD_NUM,0		; 表示中の血液型
	CALL	BLOOD_TYPE_SHOW			; 血液型の表示
	MOV	DISP_BLOOD_NUM,1		; 表示中の血液型
	CALL	BLOOD_TYPE_SHOW			; 血液型の表示
	MOV	DISP_BLOOD_NUM,2		; 表示中の血液型
	CALL	BLOOD_TYPE_SHOW			; 血液型の表示
	MOV	DISP_BLOOD_NUM,3		; 表示中の血液型
	CALL	BLOOD_TYPE_SHOW			; 血液型の表示

	MOV	DX,3			; 3="blood type  （むすめの血液型）"
	CALLE	WIDNAME_MESSAGE		; WINDOWS/名前ウインドウ・メッセージ

	RET
BLOOD_OPEN	ENDP


; ****************************************************
;	血液型入力ＣＬＯＳＥ
; ****************************************************

BLOOD_CLOSE	PROC	NEAR
	RET
BLOOD_CLOSE	ENDP


; ****************************************************
;	血液型入力ＭＡＩＮ
;	-O- AX        : 1=キャンセル
;	    BLOOD_TYPE : 0=Ａ型,1=Ｂ型,2=Ｏ型,3=ＡＢ型
; ****************************************************

BLOOD_MAIN	PROC	NEAR
	CALL	WID_SLCT		; マウスセレクト
	CMP	AX,1			; 1=キャンセル
	JE	BLOOD_MAIN_CANCEL	;

	MOV	AX,0
	RET
BLOOD_MAIN_CANCEL:
	MOV	AX,1			; 1=キャンセル
	RET
BLOOD_MAIN	ENDP


; ****************************************************
;	マウスセレクト
;	-O- AX        : 1=キャンセル
; ****************************************************

WID_SLCT	PROC	NEAR
	MOV	DISP_SLCT_NUM,OFFF	; 表示中の血液型

	CALLE	MSCSRT			; カーソルスタート
WID_SLCT_LOOP:
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
	MOV	MOUSEFLAG,OFFF		; マウスＯＮ／ＯＦＦフラグ

	CALL	BLOOD_SCH		; サーチ・血液型
	CALL	BLOOD_SHOW		; 血液型の選択表示
	MOVX	BLOOD_TYPE,NOW_SLCT_NUM	; 選択された血液型
WID_SLCT_NEXT:
	JMP	WID_SLCT_LOOP		;

WID_SLCT_ON:
	CMP	BLOOD_TYPE,4		; 選択された血液型
	JNB	WID_SLCT_LOOP		;

	;古い;1=Ａ型,2=Ｂ型,3=ＡＢ型,4=Ｏ型

	MOV	AX,BLOOD_TYPE		; 選択された血液型
	MOV	NOW_SLCT_NUM,AX		; 選択された血液型
	CALL	BLOOD_SHOW		; 血液型の選択表示
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
;	サーチ・血液型
;	-O- AX           : 0=無し,1=一致した
;	    NOW_SLCT_NUM : 選択された血液型(0=無し)
; ****************************************************

BLOOD_SCH	PROC	NEAR
	MOV	NOW_SLCT_NUM,0			; 選択された血液型

	MOV	CX,4				;
BLOOD_SCH_LOOP:

	MOV	SI,NOW_SLCT_NUM			; 選択された血液型
	SHL	SI,1				; word pointer.

	MOV	AX,MOUSEX			; マウスＸ
	MOV	BX,MOUSEY			; マウスＹ

	CMP	AX,DS:BLOOD_DSP_XX_TBL[SI]	; 血液型の表示Ｘ
	JB	BLOOD_SCH_55
	CMP	AX,DS:BLOOD_DSP_X2_TBL[SI]	; 血液型の表示Ｘ２
	JNBE	BLOOD_SCH_55
	CMP	BX,DS:BLOOD_DSP_YY_TBL[SI]	; 血液型の表示Ｙ
	JB	BLOOD_SCH_55
	CMP	BX,DS:BLOOD_DSP_Y2_TBL[SI]	; 血液型の表示Ｙ２
	JNBE	BLOOD_SCH_55
	JMP	BLOOD_SCH_SEARCH
BLOOD_SCH_55:
	INC	NOW_SLCT_NUM			; 選択された血液型
	LOOP	BLOOD_SCH_LOOP

	JMP	BLOOD_SCH_NONE
BLOOD_SCH_SEARCH:
	MOV	AX,1				; 1=一致した
	RET
BLOOD_SCH_NONE:
	MOV	NOW_SLCT_NUM,99			;
	MOV	AX,0				; 0=無し
	RET
BLOOD_SCH	ENDP



; ****************************************************
;	血液型の選択表示
;	-I-   NOW_SLCT_NUM : 選択された血液型
;	-I/O- DISP_SLCT_NUM: 表示中の血液型
; ****************************************************

BLOOD_SHOW	PROC	NEAR
	CMPX	DISP_SLCT_NUM,NOW_SLCT_NUM	; 選択された血液型
	JNE	BLOOD_SHOW_START		;
	RET
BLOOD_SHOW_START:
	CALLE	MSCSTP				; カーソルストップ
	MOVX	DISP_BLOOD_NUM,DISP_SLCT_NUM	; 表示中の血液型
	CALL	BLOOD_TYPE_SHOW			; 血液型の表示

	MOVX	DISP_BLOOD_NUM,NOW_SLCT_NUM	; 選択された血液型
	CALL	BLOOD_TYPE_GOLD			; 血液型ＧＯＬＤ

	MOVX	DISP_SLCT_NUM,NOW_SLCT_NUM	; 選択された血液型
	CALLE	MSCSRT				; カーソルスタート
	RET
BLOOD_SHOW	ENDP


; ****************************************************
;	血液型の表示
;	-I- DISP_BLOOD_NUM : 表示する血液型
; ****************************************************

BLOOD_TYPE_SHOW	PROC	NEAR
	CMP	DISP_BLOOD_NUM,4		;
	JNB	BLOOD_TYPE_SHOW_EXIT		;

BLOOD_TYPE_SHOW_START:
	MOV	DI,DISP_BLOOD_NUM		; 表示する血液型
	SHL	DI,1				; word pointer.
	MOV	AX,DS:BLOOD_DSP_XX_TBL[DI]	; 血液型の表示Ｘ
	MOV	BX,DS:BLOOD_DSP_YY_TBL[DI]	; 血液型の表示Ｙ
	MOV	SI,DS:BLOOD_DSP_STR_TBL[DI]	; 血液型の表示文字
	CALL	STRING_PUT			; 文字列ＰＵＴ
BLOOD_TYPE_SHOW_EXIT:
	RET
BLOOD_TYPE_SHOW	ENDP


; ****************************************************
;	血液型ＧＯＬＤ
;	-I- DISP_BLOOD_NUM : 表示する血液型
; ****************************************************

BLOOD_TYPE_GOLD	PROC	NEAR
	CMP	DISP_BLOOD_NUM,4		;
	JNB	BLOOD_TYPE_GOLD_EXIT		;

BLOOD_TYPE_GOLD_START:
	MOV	DI,DISP_BLOOD_NUM		; 表示する血液型
	SHL	DI,1				; word pointer.
	MOV	AX,DS:BLOOD_DSP_XX_TBL[DI]	; 血液型の表示Ｘ
	MOV	BX,DS:BLOOD_DSP_YY_TBL[DI]	; 血液型の表示Ｙ
	MOV	SI,DS:BLOOD_DSP_STR_TBL[DI]	; 血液型の表示文字
	CALL	GOLD_STR_PUT			; ＧＯＬＤ文字列ＰＵＴ
BLOOD_TYPE_GOLD_EXIT:
	RET
BLOOD_TYPE_GOLD	ENDP


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

PUBLIC	BLOOD_TYPE			; 血液型

EXTRN	BLOOD_DSP_STR_TBL:WORD		; 血液型の表示文字

EXTRN	VX1:WORD			; point x1.
EXTRN	VY1:WORD			; point y1.
EXTRN	VX2:WORD			; point x2.
EXTRN	VY2:WORD			; point y2.

		EVEN
BLOOD_TYPE	DW	2			; 血液型
						;0=Ａ型,1=Ｂ型,2=Ｏ型,3=ＡＢ型
BLOOD_TYPE_ADRS	DW	0			; 血液型アドレス

NOW_SLCT_NUM	DW	0			; 選択された血液型
DISP_SLCT_NUM	DW	0			; 表示中の血液型

DISP_BLOOD_NUM	DW	0			; 表示する血液型
						;0=Ａ型,1=Ｂ型,2=Ｏ型,3=ＡＢ型

BLOOD_DSP_XX_TBL	LABEL	WORD		; 血液型の表示Ｘ
		DW	BLOOD_A_XX
		DW	BLOOD_B_XX
		DW	BLOOD_O_XX
		DW	BLOOD_AB_XX

BLOOD_DSP_YY_TBL	LABEL	WORD		; 血液型の表示Ｙ
		DW	BLOOD_A_YY
		DW	BLOOD_B_YY
		DW	BLOOD_O_YY
		DW	BLOOD_AB_YY

BLOOD_DSP_X2_TBL	LABEL	WORD		; 血液型の表示Ｘ２
		DW	BLOOD_A_XL
		DW	BLOOD_B_XL
		DW	BLOOD_O_XL
		DW	BLOOD_AB_XL

BLOOD_DSP_Y2_TBL	LABEL	WORD		; 血液型の表示Ｙ２
		DW	BLOOD_A_YL
		DW	BLOOD_B_YL
		DW	BLOOD_O_YL
		DW	BLOOD_AB_YL

		EVEN
MOUSEFLAG	DW	0		; マウスＯＮ／ＯＦＦフラグ
MOUSEX		DW	0		; マウスＸ
MOUSEY		DW	0		; マウスＹ

CODE	ENDS

	END
;
;	end of "WIDBLOOD.ASM"
;
