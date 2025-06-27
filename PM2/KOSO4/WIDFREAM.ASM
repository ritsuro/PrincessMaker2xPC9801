; "WIDFREAM.ASM" PC-9801UV11 make by R.H 1992/05/20
;
;
;	ＷＩＮＤＯＷＳ／ウインドウ・フレーム
;
;
;	WID_FLAME_USER		; WINDOWS/フレーム・ﾕｰｻﾞｰﾌﾚｰﾑ
;	WID_FLAME_DISK		; WINDOWS/フレーム・ディスクウインドウ
;	WID_FLAME_DISK_BOX	; WINDOWS/フレーム・ﾃﾞｨｽｸｳｲﾝﾄﾞｳ BOX
;	WID_FLAME_SLCT		; WINDOWS/フレーム・セレクトウインドウ
;	WID_FLAME_SLCT_ON	; WINDOWS/フレーム・ｾﾚｸﾄｳｲﾝﾄﾞｳ ドラッグ ON
;	WID_FLAME_SLCT_OFF	; WINDOWS/フレーム・ｾﾚｸﾄｳｲﾝﾄﾞｳ ドラッグ OFF
;	WID_FLAME_S_TEXT	; WINDOWS/フレーム・ﾃｷｽﾄ(説明)ｳｲﾝﾄﾞｳ
;	WID_FLAME_SYU_TEXT	; WINDOWS/フレーム・ﾃｷｽﾄ(収穫祭)ｳｲﾝﾄﾞｳ
;	WID_FLAME_TEXT_BOX	; WINDOWS/フレーム・ﾃｷｽﾄｳｲﾝﾄﾞｳ BOX
;	WID_FLAME_TEXT_COL_BOX	; WINDOWS/フレーム・ﾃｷｽﾄｳｲﾝﾄﾞｳ color BOX
;	WID_FLAME_FACE		; WINDOWS/フレーム・フェイス
;	WID_FLAME_FACEL		; WINDOWS/フレーム・守護星ﾌｪｲｽ
;	WID_FLAME_FACES		; WINDOWS/フレーム・収穫祭ﾌｪｲｽ
;	WID_FLAME_GRAPH		; WINDOWS/フレーム・グラフ
;	WID_FLAME_GRPONE	; WINDOWS/フレーム・グラフ１本
;	WID_FLAME_GRP_ON	; WINDOWS/フレーム・グラフ ON
;	WID_FLAME_GRP_OFF	; WINDOWS/フレーム・グラフ OFF
;	WID_FLAME_SCHED		; WINDOWS/スケジュール・フレーム
;	WID_FRAME_G_PNAME	; WINDOWS/パラメータ名を書く
;	WID_FRAME_G_PPARA	; WINDOWS/パラメータ値を書く
;	WID_FRAME_G_PGRP	; WINDOWS/グラフを描く
;	WID_FLAME_GOLD		; WINDOWS/フレーム・ＧＯＬＤ
;	WID_FLAME_GOLDONE	; WINDOWS/フレーム・ＧＯＬＤ１本
;	WID_FRAME_GOLD_NAME	; WINDOWS/フレーム・ＧＯＬＤ 名前を書く
;	WID_FRAME_GOLD_GOLD	; WINDOWS/フレーム・ＧＯＬＤ 金額を書く
;	WID_FRAME_PROFILE	; WINDOWS/フレーム・プロフィール
;	WID_FRAME_PROFONE	; WINDOWS/プロフィール１行書く
;	WID_FRAME_LONGN		; WINDOWS/長い名前ﾊﾟﾗﾒｰﾀ・ｳｲﾝﾄﾞｳ１行書く
;	WID_FRAME_PROPR		; WINDOWS/フレーム・プロポーション
;	WID_FRAME_PROPRONE	; WINDOWS/フレーム・ﾌﾟﾛﾎﾟｰｼｮﾝ1本
;	WID_FRAME_P_PNAME	; WINDOWS/ﾌﾟﾛﾎﾟｰｼｮﾝ･ﾊﾟﾗﾒｰﾀ名を書く
;	WID_FRAME_P_PGRP	; WINDOWS/ﾌﾟﾛﾎﾟｰｼｮﾝ･ｸﾞﾗﾌを描く
;	WID_FRAME_P_PPARA	; WINDOWS/ﾌﾟﾛﾎﾟｰｼｮﾝ･ﾊﾟﾗﾒｰﾀ値を書く
;	WID_FRAME_STATUS	; WINDOWS/フレーム・ｽﾃｰﾀｽｳｲﾝﾄﾞｳ
;	WID_FRAME_STATUS_PAR	; WINDOWS/フレーム・ｽﾃｰﾀｽ・％表示
;	WID_FRAME_STATUS_VAL	; WINDOWS/フレーム・ｽﾃｰﾀｽ・ﾎﾟｲﾝﾄ値表示
;	WID_FRAME_STATUS_FLAG	; WINDOWS/フレーム・ｽﾃｰﾀｽ・ﾌﾗｸﾞON表示
;	WID_FRAME_ICON_PARA	; WINDOWS/フレーム・ICONﾊﾟﾗﾒｰﾀ表示
;	WID_FRAME_ANIME_SMALL	; WINDOWS/フレーム・小アニメ
;	WID_FRAME_ANIME_LARGE	; WINDOWS/フレーム・大アニメ
;	WID_FRAME_IVENT_SMALL	; WINDOWS/フレーム・小イベント
;	WID_FRAME_IVENT_LARGE	; WINDOWS/フレーム・大イベント
;	WID_FLAME_TOUR_NAME	; WINDOWS/フレーム・ﾄｰﾅﾒﾝﾄ名前箱
;	WID_FLAME_MULT_TYPE1	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1
;	WID_FLAME_MULT_TYPE2	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2
;	WID_FLAME_MULT_TYPE3	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3
;	WID_FLAME_MULT_TYPE4	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4
;	WID_FLAME_MULT_CANCEL	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel
;	WID_FLAME_MULT_TYP1_ON	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 ON
;	WID_FLAME_MULT_TYP1_OFF	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 OFF
;	WID_FLAME_MULT_TYP2_ON	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 ON
;	WID_FLAME_MULT_TYP2_OFF	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 OFF
;	WID_FLAME_MULT_TYP3_ON	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 ON
;	WID_FLAME_MULT_TYP3_OFF	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 OFF
;	WID_FLAME_MULT_TYP4_ON	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 ON
;	WID_FLAME_MULT_TYP4_OFF	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 OFF
;	WID_FLAME_MULT_CANCEL_ON  ; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel ON
;	WID_FLAME_MULT_CANCEL_OFF ; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel OFF
;	WID_FLAME_DSKTOOL	; WINDOWS/ﾌﾚｰﾑ･ﾃﾞｰﾀﾛｰﾄﾞｾｰﾌﾞ(DSKTOOL.COM)
;
;
; (C) 1991 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

COLOR_LAMP_UP	EQU	13	; color lamp on.
COLOR_LAMP_DWN	EQU	10	; color lamp on.
COLOR_LAMP_OFF	EQU	7	; color lamp off.

WDID_CHRCOLOR	EQU	15	; 文字表示色
WDID_CHRSIZE	EQU	0	; 文字表示サイズ
				; 0=16x16  1=32x32  2=16x24  3=16x32
PARA_CHRCOLOR	EQU	15	; ﾊﾟﾗﾒｰﾀ文字表示色
PARA_CHRSIZE	EQU	0	; ﾊﾟﾗﾒｰﾀ文字表示サイズ

TXCOL_GOLD	EQU	15	; お金font color.

GRP_NAME_HIGHT	EQU	16	; グラフ高さ
GRP_SIDE_XL	EQU	1	; グラフ左サイドＸ長さ
GRP_SIDE_YL	EQU	8	; グラフ開始Ｙ位置
GRP_NAME_XL	EQU	8	; パラメータ名Ｘ長さ
GRP_VALUE_XL	EQU	3	; パラメータ値Ｘ長さ
GRP_TXTSIZE	EQU	0	; グラフ文字表示サイズ
GRP_TXTCOLOR	EQU	15	; グラフ文字表示色
GRP_TXTCOLOR2	EQU	15	; グラフ文字(ﾊﾟﾗﾒｰﾀ値)表示色

GRP_GRAPH_XL	EQU	11	; グラフＸ長さ
GRP_GR_SFT_X	EQU	11	; グラフ位置シフトＸ
GRP_GR_SFT_Y	EQU	2	; グラフ位置シフトＹ
GRP_GR_WID	EQU	11	; グラフ太さ
GRP_GR_SCALE	EQU	10	; グラフ・スケール

GRP_PR_VAL_XL	EQU	6	; ﾌﾟﾛﾎﾟｰｼｮﾝ･ﾊﾟﾗﾒｰﾀ値Ｘ長さ
GRP_PROPO_XL	EQU	8	; ﾌﾟﾛﾎﾟｰｼｮﾝグラフＸ長さ
GRP_PRP_SFT_X	EQU	14	; ﾌﾟﾛﾎﾟｰｼｮﾝ位置シフトＸ
GRP_PRP_SFT_Y	EQU	2	; ﾌﾟﾛﾎﾟｰｼｮﾝ位置シフトＹ
GRP_PRP_WID	EQU	11	; ﾌﾟﾛﾎﾟｰｼｮﾝ太さ
GRP_PRP_SCALE	EQU	400	; ﾌﾟﾛﾎﾟｰｼｮﾝ・スケール

GOLD_SIDE_XL	EQU	2	; ＧＯＬＤ左サイドＸ長さ
GOLD_NAME_XL	EQU	8	; ＧＯＬＤ名前Ｘ長さ
GOLD_VALUE_XL	EQU	7	; ＧＯＬＤ金額Ｘ長さ
GOLD_NAME_HIGHT	EQU	19	; ＧＯＬＤ高さ
GOLD_SIDE_YL	EQU	9	; ＧＯＬＤ開始Ｙ位置

GOLD_TXTSIZE	EQU	0	; ＧＯＬＤ文字表示サイズ
GOLD_TXTCOLOR	EQU	15	; ＧＯＬＤ文字表示色
;*;GOLD_TXTCOLOR2	EQU	15	; ＧＯＬＤ文字(ﾊﾟﾗﾒｰﾀ値)表示色

PROF_SIDE_XL	EQU	1	; プロフィール左サイドＸ長さ
PROF_NAME_HIGHT	EQU	18	; プロフィールグラフ高さ
PROF_NAIYO_XL	EQU	8	; プロフィール内容Ｘ長さ
PROF_SIDE_YL	EQU	10	; プロフィール開始Ｙ位置
PROF_TXTSIZE	EQU	0	; プロフィール文字表示サイズ
PROF_TXTCOLOR	EQU	15	; プロフィール文字表示色

LONGN_NAIYO_XL	EQU	15	; プロフィール内容Ｘ長さ

STS_SIDE_XL	EQU	1	; ステータス左サイドＸ長さ
STS_NAME_HIGHT	EQU	18	; ステータスグラフ高さ
STS_SIDE_YL	EQU	10	; ステータス開始Ｙ位置
STS_TXTSIZE	EQU	0	; ｽﾃｰﾀｽ文字表示サイズ
STS_TXTCOLOR	EQU	1	; ｽﾃｰﾀｽ文字表示色
STS_TXTCOLOR2	EQU	1	; ｽﾃｰﾀｽ文字(ﾊﾟﾗﾒｰﾀ値)表示色
STS_NAME_XL	EQU	10	; ステータス名Ｘ長さ
STS_FLAG_NML_C	EQU	1	; フラグｎｏｒｍａｌ
STS_FLAG_ON_C	EQU	1	; フラグＯＮ
STS_FLAG_OFF_C	EQU	4	; フラグＯＦＦ

ICON_TXTCOLOR	EQU	15	; ICON文字表示色
ICON_TXTSIZE	EQU	0	; ICON文字サイズ
ICON_SIDE_XL	EQU	1	; ICON左サイドＸ長さ
ICON_SIDE_YL	EQU	10	; ICON開始Ｙ位置
ICON_NAME_HIGHT	EQU	36	; ICONグラフ高さ

WD_SML_AN_SZ_X	EQU	40+2	; フレーム・小アニメサイズＸ
WD_SML_AN_SZ_Y	EQU	128+16	; フレーム・小アニメサイズＹ
WD_LGE_AN_SZ_X	EQU	54+2	; フレーム・大アニメサイズＸ
WD_LGE_AN_SZ_Y	EQU	180+16	; フレーム・大アニメサイズＹ

WD_TYP1_SIZE_X	EQU	19;16;14; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 サイズＸ
WD_TYP1_SIZE_Y	EQU	62	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 サイズＹ
WD_TYP2_SIZE_X	EQU	16	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 サイズＸ
WD_TYP2_SIZE_Y	EQU	42	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 サイズＹ
WD_TYP3_SIZE_X	EQU	16	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 サイズＸ
WD_TYP3_SIZE_Y	EQU	42	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 サイズＹ
WD_TYP4_SIZE_X	EQU	16	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 サイズＸ
WD_TYP4_SIZE_Y	EQU	42	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 サイズＹ
WD_CANC_SIZE_X	EQU	12	; フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel サイズＸ
WD_CANC_SIZE_Y	EQU	32	; フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel サイズＹ

TIME_GRP_ON	EQU	3	; time graph on.

BNK_FACE	EQU	5;4	; face bank.

;	ＢＯＸ１プレーンヌキ

BOXPBK	MACRO	X1,Y1,X2,Y2
	LOCAL	L1,L2
	MOV	AX,X1
	MOV	VX1,AX
	MOV	AX,Y1
	MOV	VY1,AX
	MOV	AX,X2
	MOV	VX2,AX
	MOV	AX,Y2
	MOV	VY2,AX
	MOV	CX,1111B		; color palet number.
	EXTRN	w_BOXNOT:NEAR
	CALL	w_BOXNOT		; ＢＯＸ反転
	ENDM

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/フレーム・ﾕｰｻﾞｰﾌﾚｰﾑ
;	-I- AX   : frame type.
;	    WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC	WID_FLAME_USER
	CMP	AL,1			; winodw type.
	JE	WID_FLAME_USER_01
	RET
WID_FLAME_USER_01:
	CALL	BASE_FLAME		; フレーム１
	RET
FEND	WID_FLAME_USER


; ****************************************************
;	WINDOWS/フレーム・ディスクウインドウ
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC_L	WID_FLAME_DISK
	CALL	BOX_CALC		; box calc.
	CALL	JI_TEXT			; テキスト地色
	MOVX	GWA_COL1,W_COL1		; WINDOWS/カラー・ハイライト
	MOVX	GWA_COL2,W_COL2		; WINDOWS/カラー・明るい灰
	MOVX	GWA_COL3,W_COL3		; WINDOWS/カラー・暗い灰
	MOVX	GWA_COL4,W_COL4		; WINDOWS/カラー・黒
	MOVX	GWA_COL5,W_COL5		; WINDOWS/カラー・暗い色
	CALL	WID_GAWA		; フレームの側
	RET
FEND	WID_FLAME_DISK


; ****************************************************
;	WINDOWS/フレーム・ﾃﾞｨｽｸｳｲﾝﾄﾞｳ BOX
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC_L	WID_FLAME_DISK_BOX
	CALL	BOX_CALC		; box calc.
	CALL	JI_TEXT			; テキスト地色
	RET
FEND	WID_FLAME_DISK_BOX


; ****************************************************
;	WINDOWS/フレーム・セレクトウインドウ
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC_L	WID_FLAME_SLCT
	CALL	BASE_SLCT_FLM		; フレーム２ SLCT用
	RET
FEND	WID_FLAME_SLCT


; ****************************************************
;	WINDOWS/フレーム・ｾﾚｸﾄｳｲﾝﾄﾞｳ ドラッグ ON
;	-I- AX : ＰＵＴ　Ｘ座標
;	    BX : ＰＵＴ　Ｙ座標
; ****************************************************

FUNC_L	WID_FLAME_SLCT_ON
	RET
FEND	WID_FLAME_SLCT_ON


; ****************************************************
;	WINDOWS/フレーム・ｾﾚｸﾄｳｲﾝﾄﾞｳ ドラッグ OFF
;	-I- AX : ＰＵＴ　Ｘ座標
;	    BX : ＰＵＴ　Ｙ座標
; ****************************************************

FUNC_L	WID_FLAME_SLCT_OFF
	RET
FEND	WID_FLAME_SLCT_OFF


; ****************************************************
;	WINDOWS/フレーム・ﾃｷｽﾄ(説明)ｳｲﾝﾄﾞｳ
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC_L	WID_FLAME_S_TEXT
	CALL	BASE_FLAME		; フレーム１
	RET
FEND	WID_FLAME_S_TEXT


; ****************************************************
;	WINDOWS/フレーム・ﾃｷｽﾄ(収穫祭)ｳｲﾝﾄﾞｳ
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_SYU_TEXT
	MOV	AX,6			; 6=ﾌﾚｰﾑ･収穫祭ﾃｷｽﾄ
	MOV	BX,BNK_FACE		;face bank.
	MOV	CX,WDX1			;表示位置Ｘ
	MOV	DX,WDY1			;表示位置Ｙ
	CALL_w	PT_MINI_FRAME		;各種小さいフレーム
	RET
FEND	WID_FLAME_SYU_TEXT


; ****************************************************
;	WINDOWS/フレーム・ﾃｷｽﾄｳｲﾝﾄﾞｳ BOX
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC	WID_FLAME_TEXT_BOX
	CALL	BOX_CALC		; box calc.
	CALL	JI_TEXT			; テキスト地色
	RET
FEND	WID_FLAME_TEXT_BOX


; ****************************************************
;	WINDOWS/フレーム・ﾃｷｽﾄｳｲﾝﾄﾞｳ color BOX
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
;	    CX   : カラー
; ****************************************************

FUNC	WID_FLAME_TEXT_COL_BOX
	PUSH	CX
	CALL	BOX_CALC		; box calc.
	POP	CX
	CALL	JI_TEXT_COLOR		; テキスト地色・カラー
	RET
FEND	WID_FLAME_TEXT_COL_BOX


; ****************************************************
;	WINDOWS/フレーム・フェイス
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_FACE
	MOV	AX,1			;1=ﾌﾚｰﾑ･ﾌｪｲｽ
	MOV	BX,BNK_FACE		;face bank.
	MOV	CX,WDX1			;表示位置Ｘ
	MOV	DX,WDY1			;表示位置Ｙ
	CALL_w	PT_MINI_FRAME		;各種小さいフレーム
	RET
FEND	WID_FLAME_FACE


; ****************************************************
;	WINDOWS/フレーム・守護星ﾌｪｲｽ
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC	WID_FLAME_FACEL
	MOV	AX,2			;2=ﾌﾚｰﾑ･守護星ﾌｪｲｽ
	MOV	BX,BNK_FACE		;face bank.
	MOV	CX,WDX1			;表示位置Ｘ
	MOV	DX,WDY1			;表示位置Ｙ
	CALL_w	PT_MINI_FRAME		;各種小さいフレーム
	RET
FEND	WID_FLAME_FACEL


; ****************************************************
;	WINDOWS/フレーム・収穫祭ﾌｪｲｽ
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC	WID_FLAME_FACES
	MOV	AX,5			;5=ﾌﾚｰﾑ･収穫祭ﾌｪｲｽ
	MOV	BX,BNK_FACE		;face bank.
	MOV	CX,WDX1			;表示位置Ｘ
	MOV	DX,WDY1			;表示位置Ｙ
	CALL_w	PT_MINI_FRAME		;各種小さいフレーム
	RET
FEND	WID_FLAME_FACES


; ****************************************************
;	WINDOWS/フレーム・グラフ
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC_L	WID_FLAME_GRAPH
	CALL	BASE_FLAME		; フレーム１
	RET
FEND	WID_FLAME_GRAPH


; ****************************************************
;	WINDOWS/フレーム・グラフ１本
;	-I- WDX1    : グラフ表・表示位置Ｘ
;	    WDY1    : グラフ表・表示位置Ｙ
;	    DX      : グラフ番号
;	    AX      : ウインドウタイプ
; ****************************************************

FUNC_L	WID_FLAME_GRPONE
	MOV	GWIDTYPE,AX		; ウインドウタイプ

	MOV	GNUM,DX			; グラフ番号
	CALL	GRPLOC			; グラフ１本ロケーション

	MOV	AX,VX1			; start point.
	MOV	BX,VY1			; start point.
	MOV	XX1,AX			; x.
	MOV	YY1,BX			; y.
	ADD	AX,GRP_NAME_XL		; パラメータ名Ｘ長さ
	ADD	BX,GRP_NAME_HIGHT-1	; グラフ高さ
	MOV	VX2,AX			; end point.
	MOV	VY2,BX			; end point.

	MOV	SI,GWIDTYPE		; ウインドウタイプ
	DEC	SI			; -1
	SHL	SI,1			; word pointer.
	MOV	CX,W_COL_G1[SI]		; WINDOWS/カラー・グラフ地色１
	MOV	BX,W_COL_G2[SI]		; WINDOWS/カラー・グラフ地色２
	CALL_w	BOXMCH			; ＢＯＸチェック模様

	MOV	AX,VX2			; end point.
	MOV	VX1,AX			; start point.
	ADD	VX2,GRP_VALUE_XL	; パラメータ値Ｘ長さ
	MOV	CX,W_COL9		; WINDOWS/カラー・グラフ値地色
	CALL_w	BOXPAL			; ＢＯＸペイント

	MOV	AX,VX2			; end point.
	MOV	VX1,AX			; start point.
	ADD	VX2,GRP_GRAPH_XL-1	; グラフＸ長さ
	MOV	CX,W_COL8		; WINDOWS/カラー・グラフ地色
	CALL_w	BOXPAL			; ＢＯＸペイント

	MOV	AX,XX1			; x.
	MOV	VX1,AX			;
	ADD	AX,GRP_NAME_XL+GRP_VALUE_XL+GRP_GRAPH_XL-1
	MOV	VX2,AX			;
	MOV	AX,VY2			; end point.
	MOV	VY1,AX			; end point.
	MOV	CX,W_COL10		; WINDOWS/カラー・グラフライン地色
	CALL_w	BOXPAL			; ＢＯＸペイント


	MOV	AX,XX1			; x.
	MOV	BX,YY1			; y.
	ADD	AX,GRP_VALUE_XL+GRP_NAME_XL ; パラメータ名Ｘ長さ
	SHL	AX,1			;
	SHL	AX,1			; * 8
	SHL	AX,1			;
	MOV	VX1,AX			;
	ADD	BX,GRP_NAME_HIGHT-2	; グラフ高さ
	MOV	VY1,BX			;
	SUB	BX,3			;
	MOV	VY2,BX			;

	MOV	VCOL,1			; color.
	ADD	VX1,7			;
	MOV	CX,10			;
WID_FLAME_GRPONE_LOOP:			;
	PUSH	CX			;
	MOV	CX,1			; line width.
	CALL_w	DLINEV			; 垂直ライン描画
	ADD	VX1,8			;
	POP	CX			;
	LOOP	WID_FLAME_GRPONE_LOOP

	RET
FEND	WID_FLAME_GRPONE


; ****************************************************
;	WINDOWS/フレーム・グラフ ON
;	-I- WDX1    : グラフ表・表示位置Ｘ
;	    WDY1    : グラフ表・表示位置Ｙ
;	    AX      : ウインドウタイプ
;	    BX      : 0=none,1=上昇,2=下降
;	    DX      : グラフ番号
; ****************************************************

FUNC_L	WID_FLAME_GRP_ON
	MOV	GWIDTYPE,AX		; ウインドウタイプ
	MOV	GUPDOWN,BX		; 上下目安
	MOV	GNUM,DX			; グラフ番号
	CALL	GRPLOC			; グラフ１本ロケーション

;*;	MOV	AX,VX1			; start point.
;*;	MOV	BX,VY1			; start point.
;*;	MOV	XX1,AX			; x.
;*;	ADD	AX,GRP_NAME_XL-1	; パラメータ名Ｘ長さ
;*;	ADD	BX,GRP_NAME_HIGHT-1	; グラフ高さ
;*;	MOV	VX2,AX			; end point.
;*;	MOV	VY2,BX			; end point.
;*;	MOV	CX,15			; color palet number.
;*;	CALL_w	BOXNOT			; ＢＯＸ反転
;*;
;*;	MOV	AX,TIME_GRP_ON		; time graph on.
;*;	CALL_w	TMVSET			; V-SYNC timer set.
;*;
;*;	PUSH	VX1			; start point.
;*;	PUSH	VY1			; start point.
;*;	PUSH	VX2			; end point.
;*;	PUSH	VY2			; end point.

	CMP	GUPDOWN,1		; 上下目安
	JE	WID_FLAME_GRP_ON_51	;
	CMP	GUPDOWN,2		; 上下目安
	JE	WID_FLAME_GRP_ON_52	;
	MOV	AX,COLOR_LAMP_OFF	; color lamp off.
	JMP	WID_FLAME_GRP_ON_59	;
WID_FLAME_GRP_ON_51:			;
	MOV	AX,COLOR_LAMP_UP	; color lamp on.
	JMP	WID_FLAME_GRP_ON_59	;
WID_FLAME_GRP_ON_52:			;
	MOV	AX,COLOR_LAMP_DWN	; color lamp on.
WID_FLAME_GRP_ON_59:			;
	MOV	VCOL,AX			;

	CALL	FLAME_GRP_ONOFF		; graph on/off mark.

;;*;	MOV	AX,VX1			; line dot point x.
;;*;	SHL	AX,1			;
;;*;	SHL	AX,1			;
;;*;	SHL	AX,1			;
;;*;	SUB	AX,3			;
;;*;	MOV	VX1,AX			; line dot point x.
;;*;	INC	VY1			; start line point y1.
;;*;	MOV	AX,VY1			; start line point y1.
;;*;	ADD	AX,14			;
;;*;	MOV	VY2,AX			; end point.
;;*;	MOV	CX,2			; line width.
;;*;	CALL_w	DLINEV			; 垂直ライン描画

;*;	POP	VY2			; end point.
;*;	POP	VX2			; end point.
;*;	POP	VY1			; start point.
;*;	POP	VX1			; start point.
;*;
;*;	CALL_w	TMVEWT			; V-SYNC timer end wait.
;*;
;*;	MOV	CX,15			; color palet number.
;*;	CALL_w	BOXNOT			; ＢＯＸ反転
	RET
FEND	WID_FLAME_GRP_ON


; ****************************************************
;	WINDOWS/フレーム・グラフ OFF
;	-I- WDX1    : グラフ表・表示位置Ｘ
;	    WDY1    : グラフ表・表示位置Ｙ
;	    DX      : グラフ番号
;	    AX      : ウインドウタイプ
; ****************************************************

FUNC_L	WID_FLAME_GRP_OFF
	MOV	GWIDTYPE,AX		; ウインドウタイプ
	MOV	GNUM,DX			; グラフ番号
	CALL	GRPLOC			; グラフ１本ロケーション

	MOV	VCOL,COLOR_LAMP_OFF	; color lamp off.
	CALL	FLAME_GRP_ONOFF		; graph on/off mark.

	RET
FEND	WID_FLAME_GRP_OFF


; ****************************************************
;	graph on/off mark.
;	-I- VX1  : start point.
;	    VY1  : start point.
;	    VCOL : color.
; ****************************************************

FLAME_GRP_ONOFF	PROC	NEAR
	MOV	AX,VX1			; line dot point x.
	ADD	AX,GRP_NAME_XL		; パラメータ名Ｘ長さ
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	MOV	VX1,AX			; line dot point x.
	ADD	VY1,GRP_NAME_HIGHT-2	; グラフ高さ

	MOV	AX,VX1			; start line point x1.
	ADD	AX,GRP_VALUE_XL*8-1	; パラメータ値Ｘ長さ
	MOV	VX2,AX			; end point.

	MOV	CX,2			; line width.
	CALL_w	DLINEH			; 水平ライン描画
	RET
FLAME_GRP_ONOFF	ENDP


; ****************************************************
;	WINDOWS/スケジュール・フレーム
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC_L	WID_FLAME_SCHED
	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	CALL_w	PT_SCHED_LOC		; schedule locate.
	CALL_w	PT_SCHED_LD		; schedule load.
	CALL_w	PT_SCHED_FRM		; schedule fream.
	RET
FEND	WID_FLAME_SCHED


; ****************************************************
;	グラフ１本ロケーション
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    GNUM : グラフ番号
;	-O- VX1  : start point.
;	    VY1  : start point.
;	    LOCX : start point.
;	    LOCY : start point.
; ****************************************************

GRPLOC	PROC	NEAR
	MOV	AX,WDX1			; 表示位置Ｘ
	ADD	AX,GRP_SIDE_XL		; グラフ左サイドＸ長さ
	MOV	VX1,AX			; start point.
	MOV	LOCX,AX			; start point.

	MOV	AX,GRP_NAME_HIGHT	; グラフ高さ
	MUL	GNUM			; グラフ番号
	ADD	AX,WDY1			; グラフ表・表示位置Ｙ
	ADD	AX,GRP_SIDE_YL		; グラフ開始Ｙ位置
	MOV	VY1,AX			; start point.
	MOV	LOCY,AX			; start point.
	RET
GRPLOC	ENDP


; ****************************************************
;	パラメータ名を書く
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    DX   : グラフ番号
;	    SI   : 名前
; ****************************************************

FUNC_L	WID_FRAME_G_PNAME
	MOV	GNAME,SI		; 名前
	MOV	GNUM,DX			; グラフ番号

	CALL	GRPLOC			; グラフ１本ロケーション

	MOV	AX,GRP_TXTSIZE		; グラフ文字表示サイズ
	CALL_w	VTXSIZ			; character size set.

	MOV	AX,GRP_TXTCOLOR		; グラフ文字表示色
	CALL_w	VTXCOL			; character color set.

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	MOV	SI,GNAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.
	RET
FEND	WID_FRAME_G_PNAME


; ****************************************************
;	パラメータ値を書く
;	-I- WDXX    : グラフＸ
;	    WDYY    : グラフＹ
;	    DX      : グラフ番号
;	    AX      : パラメータ値
; ****************************************************

FUNC_L	WID_FRAME_G_PPARA
	MOV	GVALUE,AX		; パラメータ値
	MOV	GNUM,DX			; グラフ番号

	CALL	GRPLOC			; グラフ１本ロケーション

	ADDX	VX1,GRP_NAME_XL		; パラメータ名Ｘ長さ
	MOV	AX,VX1			; start point.
	ADD	AX,GRP_VALUE_XL-1	; パラメータ値Ｘ長さ
	MOV	VX2,AX			; end point.
	MOV	BX,VY1			; start point.
	ADD	BX,GRP_NAME_HIGHT-1-2	; グラフ高さ
	MOV	VY2,BX			; end point.
	MOV	CX,W_COL9		; WINDOWS/カラー・グラフ値地色
	CALL_w	BOXPAL			; ＢＯＸペイント

	MOV	AX,GRP_TXTCOLOR2	; グラフ文字(ﾊﾟﾗﾒｰﾀ値)表示色
	CALL_w	MITCOL			; mini string color.

	MOV	DX,GVALUE		; パラメータ値
	CALL_w	DECSTR			;
	CALL_w	STRZTS			; zero to space. "00123" - > "  123"

	CMP	GVALUE,1000		; パラメータ値
	JNB	WID_FRAME_G_PPARA_1000	;

	ADD	SI,2			;
	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	ADD	AX,GRP_NAME_XL		; パラメータ名Ｘ長さ
;;;	CALL_w	MDTPRN			; MID string. (null=end of string)
	INC	BX			;
	CALL_w	MGXPRN			; GAINAX mini string.
	RET
WID_FRAME_G_PPARA_1000:
	ADD	SI,1			;
	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	ADD	AX,GRP_NAME_XL		; パラメータ名Ｘ長さ
;;;	CALL_w	MDTPRN			; MID string. (null=end of string)
	INC	BX			;
	CALL_w	MGXPRN			; GAINAX mini string.
	RET
FEND	WID_FRAME_G_PPARA


; ****************************************************
;	WINDOWS/グラフを描く
;	-I- WDXX    : グラフＸ
;	    WDYY    : グラフＹ
;	    DX      : グラフ番号
;	    AX      : パラメータ値
; ****************************************************

FUNC_L	WID_FRAME_G_PGRP
	MOV	GVALUE,AX		; パラメータ値
	MOV	GNUM,DX			; グラフ番号

	CALL	GRPLOC			; グラフ１本ロケーション

	MOV	GR_SCALE,GRP_GR_SCALE	; グラフ・スケール
	MOV	GR_SFT_X,GRP_GR_SFT_X	; グラフ位置シフトＸ
	MOV	GR_SFT_Y,GRP_GR_SFT_Y	; グラフ位置シフトＹ
	MOV	GR_DOT_XL,GRP_GRAPH_XL*8 ; グラフＸ長さ
	MOV	GR_G_WID,GRP_GR_WID	; グラフ太さ

	CALL	GRP_DRAW		; グラフ描画
	RET
FEND	WID_FRAME_G_PGRP


; ****************************************************
;	WINDOWS/フレーム・ＧＯＬＤ
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC_L	WID_FLAME_GOLD
	CALL	BOX_CALC		; box calc.
	CALL	JI_TEXT			; テキスト地色
	CALL	WID_GAWA_3T		; フレームの側 その３(ＧＯＬＤ)
	RET
FEND	WID_FLAME_GOLD


; ****************************************************
;	ＧＯＬＤ１本ロケーション
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    GNUM : グラフ番号
;	-O- VX1  : start point.
;	    VY1  : start point.
;	    LOCX : start point.
;	    LOCY : start point.
; ****************************************************

GOLDLOC	PROC	NEAR
	MOV	AX,WDX1			; 表示位置Ｘ
	ADD	AX,GOLD_SIDE_XL		; ＧＯＬＤ左サイドＸ長さ
	MOV	VX1,AX			; start point.
	MOV	LOCX,AX			; start point.

	MOV	AX,GOLD_NAME_HIGHT	; ＧＯＬＤグラフ高さ
	MUL	GNUM			; グラフ番号
	ADD	AX,WDY1			; グラフ表・表示位置Ｙ
	ADD	AX,GOLD_SIDE_YL		; ＧＯＬＤ開始Ｙ位置
	MOV	VY1,AX			; start point.
	MOV	LOCY,AX			; start point.
	RET
GOLDLOC	ENDP


; ****************************************************
;	WINDOWS/フレーム・ＧＯＬＤ１本
;	-I- WDX1    : グラフ表・表示位置Ｘ
;	    WDY1    : グラフ表・表示位置Ｙ
;	    DX      : グラフ番号
; ****************************************************

FUNC_L	WID_FLAME_GOLDONE
	MOV	GNUM,DX			; グラフ番号

	CALL	GOLDLOC			; ＧＯＬＤ１本ロケーション

	MOV	AX,VX1			; start point.
	MOV	BX,VY1			; start point.
	MOV	XX1,AX			; x.
	MOV	YY1,BX			; y.
	DEC	BX			; y-1
	MOV	VX1,AX			;
	MOV	VY1,BX			;
	ADD	AX,GOLD_NAME_XL+GOLD_VALUE_XL
	ADD	BX,GOLD_NAME_HIGHT-2	; ＧＯＬＤ高さ
	MOV	VX2,AX			;
	MOV	VY2,BX			; end point.
	MOV	CX,W_COL_GOLDNAME	; WINDOWS/カラー・ＧＯＬＤ名前
	CALL_w	BOXPAL			; ＢＯＸペイント

	MOV	AX,XX1			; x.
	MOV	BX,YY1			; y.
	ADD	AX,GOLD_NAME_XL		; ＧＯＬＤ名前Ｘ長さ
	MOV	VX1,AX			;
	MOV	VY1,BX			;
	ADD	AX,GOLD_VALUE_XL-1	; ＧＯＬＤ金額Ｘ長さ
	ADD	BX,GOLD_NAME_HIGHT-4	; ＧＯＬＤ高さ
	MOV	VX2,AX			; end point.
	MOV	VY2,BX			; end point.
	MOV	CX,W_COL_GOLD1		; WINDOWS/カラー・ＧＯＬＤ地色１
	CALL_w	BOXPAL			; ＢＯＸペイント
;*;	MOV	BX,W_COL_GOLD2		; WINDOWS/カラー・ＧＯＬＤ地色２
;*;	CALL_w	BOXMCH			; ＢＯＸチェック模様

	MOV	AX,VX1			; start point x1.
	MOV	BX,VX2			; start point x2.
	INC	BX
	SHL	AX,1
	SHL	AX,1
	SHL	AX,1
	SHL	BX,1
	SHL	BX,1
	SHL	BX,1
	DEC	BX
	MOV	VX1,AX			; start dot point x1.
	MOV	VX2,BX			; start dot point x2.

	MOV	AX,VY2			; end point.
	INC	AX			;
	MOV	VY1,AX			; end point.

	MOVX	VCOL,W_COL_GOLD2	; WINDOWS/カラー・ＧＯＬＤ地色２
	MOV	CX,1			; 太さ
	CALL_w	DLINEH			; 水平ライン描画

	RET
FEND	WID_FLAME_GOLDONE


; ****************************************************
;	WINDOWS/フレーム・ＧＯＬＤ 名前を書く
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    DX   : グラフ番号
;	    SI   : 名前
; ****************************************************

FUNC_L	WID_FRAME_GOLD_NAME
	MOV	GNAME,SI		; 名前
	MOV	GNUM,DX			; グラフ番号

	CALL	GOLDLOC			; ＧＯＬＤ１本ロケーション

	MOV	AX,GOLD_TXTSIZE		; ＧＯＬＤ文字表示サイズ
	CALL_w	VTXSIZ			; character size set.

	MOV	AX,GOLD_TXTCOLOR	; ＧＯＬＤ文字表示色
	CALL_w	VTXCOL			; character color set.

	MOV	AX,VX1			; start point.
	MOV	BX,VY1			; start point.
	MOV	SI,GNAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.
	RET
FEND	WID_FRAME_GOLD_NAME


; ****************************************************
;	WINDOWS/フレーム・ＧＯＬＤ 金額を書く
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    DX   : グラフ番号
;	    AX   : 金額
; ****************************************************

FUNC_L	WID_FRAME_GOLD_GOLD
	MOV	GVALUE,AX		; パラメータ値
	MOV	GNUM,DX			; グラフ番号

	CALL	GOLDLOC			; ＧＯＬＤ１本ロケーション

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	ADD	AX,GOLD_NAME_XL		; ＧＯＬＤ名前Ｘ長さ
	MOV	VX1,AX			;
	MOV	VY1,BX			;
	ADD	AX,GOLD_VALUE_XL-1	; ＧＯＬＤ金額Ｘ長さ
	ADD	BX,GOLD_NAME_HIGHT-4	; ＧＯＬＤ高さ
	MOV	VX2,AX			; end point.
	MOV	VY2,BX			; end point.
	MOV	CX,W_COL_GOLD1		; WINDOWS/カラー・ＧＯＬＤ地色１
	CALL_w	BOXPAL			; ＢＯＸペイント

;*;	MOV	BX,W_COL_GOLD2		; WINDOWS/カラー・ＧＯＬＤ地色２
;*;	CALL_w	BOXMCH			; ＢＯＸチェック模様

	MOV	BX,LOCX			; start point.
	MOV	CX,LOCY			; start point.
	ADD	BX,GOLD_NAME_XL		; ＧＯＬＤ名前Ｘ長さ
	MOV	AX,GVALUE		; パラメータ値
	MOV	DX,0			;
	CALL_w	PT_GRP_GOLD		; graph gold.

;*;	MOV	AX,GOLD_TXTCOLOR2	; グラフ文字(ﾊﾟﾗﾒｰﾀ値)表示色
;*;	CALL_w	MITCOL			; mini string color.
;*;	MOV	DX,GVALUE		; パラメータ値
;*;	CALL_w	DECSTR			;
;*;	CALL_w	STRZTS			; zero to space. "00123" - > "  123"
;*;	MOV	WORD PTR [SI][5],'G'	;
;*;	MOV	AX,LOCX			; start point.
;*;	MOV	BX,LOCY			; start point.
;*;	ADD	AX,GOLD_NAME_XL-2	; ＧＯＬＤ名前Ｘ長さ
;*;	CALL_w	MBTPRN			; BIG string. (null=end of string)

	RET
FEND	WID_FRAME_GOLD_GOLD


; ****************************************************
;	WINDOWS/プロフィール
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC_L	WID_FRAME_PROFILE
	CALL	BASE_FLAME		; フレーム１
	RET
FEND	WID_FRAME_PROFILE


; ****************************************************
;	WINDOWS/プロフィール１行書く
;	-I- WDX1 : 表・表示位置Ｘ
;	    WDY1 : 表・表示位置Ｙ
;	    DX   : 通し番号
;	    SI   : 名前
;	    DI   : 内容
; ****************************************************

FUNC_L	WID_FRAME_PROFONE
	MOV	GNUM,DX			; 通し番号
	MOV	GNAME,SI		; 名前
	MOV	GNAIYO,DI		; 内容

	CALL	PROFLOC			; プロフィール１行ロケーション

	MOV	AX,PROF_TXTSIZE		; プロフィール文字表示サイズ
	CALL_w	VTXSIZ			; character size set.

	MOV	AX,PROF_TXTCOLOR	; プロフィール文字表示色
	CALL_w	VTXCOL			; character color set.

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	MOV	SI,GNAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	ADD	AX,PROF_NAIYO_XL	; プロフィール内容Ｘ長さ
	MOV	SI,GNAIYO		; 内容
	CALL_w	VTXPOR			; vram text print OR.

	RET
FEND	WID_FRAME_PROFONE


; ****************************************************
;	WINDOWS/長い名前ﾊﾟﾗﾒｰﾀ・ｳｲﾝﾄﾞｳ１行書く
;	-I- WDX1 : 表・表示位置Ｘ
;	    WDY1 : 表・表示位置Ｙ
;	    DX   : 通し番号
;	    SI   : 名前
;	    AX      : パラメータ値
; ****************************************************

FUNC_L	WID_FRAME_LONGN
	MOV	GNUM,DX			; 通し番号
	MOV	GNAME,SI		; 名前
	MOV	GVALUE,AX		; パラメータ値

	CALL	PROFLOC			; プロフィール１行ロケーション

	MOV	AX,PROF_TXTSIZE		; プロフィール文字表示サイズ
	CALL_w	VTXSIZ			; character size set.

	MOV	AX,PROF_TXTCOLOR	; プロフィール文字表示色
	CALL_w	VTXCOL			; character color set.

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	MOV	SI,GNAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.

	MOV	DX,GVALUE		; パラメータ値
	CALL_w	DECSTR			;
	CALL_w	STRZTS			; zero to space. "00123" - > "  123"

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	ADD	AX,LONGN_NAIYO_XL	; プロフィール内容Ｘ長さ
	CALL_w	VTXPOR			; vram text print OR.

	RET
FEND	WID_FRAME_LONGN


; ****************************************************
;	プロフィール１行ロケーション
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    GNUM : グラフ番号
;	-O- VX1  : start point.
;	    VY1  : start point.
;	    LOCX : start point.
;	    LOCY : start point.
; ****************************************************

PROFLOC	PROC	NEAR
	MOV	AX,WDX1			; 表示位置Ｘ
	ADD	AX,PROF_SIDE_XL		; プロフィール左サイドＸ長さ
	MOV	VX1,AX			; start point.
	MOV	LOCX,AX			; start point.

	MOV	AX,PROF_NAME_HIGHT	; プロフィールグラフ高さ
	MUL	GNUM			; グラフ番号
	ADD	AX,WDY1			; グラフ表・表示位置Ｙ
	ADD	AX,PROF_SIDE_YL		; プロフィール開始Ｙ位置
	MOV	VY1,AX			; start point.
	MOV	LOCY,AX			; start point.
	RET
PROFLOC	ENDP


; ****************************************************
;	WINDOWS/プロポーション
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC_L	WID_FRAME_PROPR
	CALL	BASE_FLAME		; フレーム１
	RET
FEND	WID_FRAME_PROPR


; ****************************************************
;	WINDOWS/フレーム・ﾌﾟﾛﾎﾟｰｼｮﾝ1本
;	-I- WDX1    : グラフ表・表示位置Ｘ
;	    WDY1    : グラフ表・表示位置Ｙ
;	    DX      : グラフ番号
;	    AX      : ウインドウタイプ
; ****************************************************

FUNC_L	WID_FRAME_PROPRONE
	CALL	w_WID_FLAME_GRPONE	; WINDOWS/フレーム・グラフ１本
	RET
FEND	WID_FRAME_PROPRONE


; ****************************************************
;	WINDOWS/ﾌﾟﾛﾎﾟｰｼｮﾝ･ﾊﾟﾗﾒｰﾀ名を書く
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    DX   : グラフ番号
;	    SI   : 名前
; ****************************************************

FUNC_L	WID_FRAME_P_PNAME
	CALL	w_WID_FRAME_G_PNAME	; WINDOWS/パラメータ名を書く
	RET
FEND	WID_FRAME_P_PNAME


; ****************************************************
;	WINDOWS/ﾌﾟﾛﾎﾟｰｼｮﾝ･ｸﾞﾗﾌを描く
;	-I- WDXX    : グラフＸ
;	    WDYY    : グラフＹ
;	    DX      : グラフ番号
;	    AX      : パラメータ値
; ****************************************************

FUNC_L	WID_FRAME_P_PGRP
	MOV	GVALUE,AX		; パラメータ値
	MOV	GNUM,DX			; グラフ番号

	CALL	GRPLOC			; グラフ１本ロケーション

	MOV	GR_SCALE,GRP_PRP_SCALE	; ﾌﾟﾛﾎﾟｰｼｮﾝ・スケール
	MOV	GR_SFT_X,GRP_PRP_SFT_X	; ﾌﾟﾛﾎﾟｰｼｮﾝ位置シフトＸ
	MOV	GR_SFT_Y,GRP_PRP_SFT_Y	; ﾌﾟﾛﾎﾟｰｼｮﾝ位置シフトＹ
	MOV	GR_DOT_XL,GRP_PROPO_XL*8 ; ﾌﾟﾛﾎﾟｰｼｮﾝグラフＸ長さ
	MOV	GR_G_WID,GRP_PRP_WID	; ﾌﾟﾛﾎﾟｰｼｮﾝ太さ

	CALL	GRP_DRAW		; グラフ描画
	RET
FEND	WID_FRAME_P_PGRP


; ****************************************************
;	WINDOWS/ﾌﾟﾛﾎﾟｰｼｮﾝ･ﾊﾟﾗﾒｰﾀ値を書く
;	-I- WDXX    : グラフＸ
;	    WDYY    : グラフＹ
;	    DX      : グラフ番号
;	    AX      : パラメータ値
; ****************************************************

FUNC_L	WID_FRAME_P_PPARA
	MOV	GVALUE,AX		; パラメータ値
	MOV	GNUM,DX			; グラフ番号

	CALL	GRPLOC			; グラフ１本ロケーション

	ADDX	VX1,GRP_NAME_XL		; パラメータ名Ｘ長さ
	MOV	AX,VX1			; start point.
	ADD	AX,GRP_PR_VAL_XL-1	; ﾌﾟﾛﾎﾟｰｼｮﾝ･ﾊﾟﾗﾒｰﾀ値Ｘ長さ
	MOV	VX2,AX			; end point.
	MOV	BX,VY1			; start point.
	ADD	BX,GRP_NAME_HIGHT-1	; グラフ高さ
	MOV	VY2,BX			; end point.
	MOV	CX,W_COL9		; WINDOWS/カラー・グラフ値地色
	CALL_w	BOXPAL			; ＢＯＸペイント

	MOV	AX,GRP_TXTCOLOR2	; グラフ文字(ﾊﾟﾗﾒｰﾀ値)表示色
	CALL_w	MITCOL			; mini string color.

	MOV	DX,GVALUE		; パラメータ値
	CALL_w	UNIT_S_S2KETA_G		; 小数２桁文字列(ｸﾞﾗﾌ)

	MOV	SI,OFFSET STR_VAL_BUFF	; 表示値文字列バッファ
	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	ADD	AX,GRP_NAME_XL		; パラメータ名Ｘ長さ
;;;	CALL_w	MDTPRN			; MID string. (null=end of string)
	INC	BX			;
	CALL_w	MGXPRN			; GAINAX mini string.
	RET
FEND	WID_FRAME_P_PPARA


; ****************************************************
;	WINDOWS/フレーム・ｽﾃｰﾀｽｳｲﾝﾄﾞｳ
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC_L	WID_FRAME_STATUS
	CALL	BASE_FLAME		; フレーム１
	RET
FEND	WID_FRAME_STATUS


; ****************************************************
;	ステータス１行ロケーション
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    GNUM : グラフ番号
;	-O- VX1  : start point.
;	    VY1  : start point.
;	    LOCX : start point.
;	    LOCY : start point.
; ****************************************************

STATLOC	PROC	NEAR
	MOV	AX,WDX1			; 表示位置Ｘ
	ADD	AX,STS_SIDE_XL		; ステータス左サイドＸ長さ
	MOV	VX1,AX			; start point.
	MOV	LOCX,AX			; start point.

	MOV	AX,STS_NAME_HIGHT	; ステータスグラフ高さ
	MUL	GNUM			; グラフ番号
	ADD	AX,WDY1			; グラフ表・表示位置Ｙ
	ADD	AX,STS_SIDE_YL		; ステータス開始Ｙ位置
	MOV	VY1,AX			; start point.
	MOV	LOCY,AX			; start point.
	RET
STATLOC	ENDP


; ****************************************************
;	WINDOWS/フレーム・ｽﾃｰﾀｽ・％表示
;	-I- WDX1    : グラフ表・表示位置Ｘ
;	    WDY1    : グラフ表・表示位置Ｙ
;	    DX      : グラフ番号
;	    SI      : 名前
;	    AX      : 表示値
; ****************************************************

FUNC_L	WID_FRAME_STATUS_PAR
	MOV	GNUM,DX			; グラフ番号
	MOV	GNAME,SI		; 名前
	MOV	GVALUE,AX		; パラメータ値

	CALL	STATUS_NAME		; ステータス名

	MOV	AX,STS_TXTSIZE		; ｽﾃｰﾀｽ文字表示サイズ
	CALL_w	VTXSIZ			; character size set.
	MOV	AX,STS_TXTCOLOR2	; ｽﾃｰﾀｽ文字(ﾊﾟﾗﾒｰﾀ値)表示色
	CALL_w	VTXCOL			; character color set.

	MOV	DX,GVALUE		; パラメータ値
	CALL_w	DECSTR			;
	CALL_w	STRZTS			; zero to space. "00123" - > "  123"

	ADD	SI,2			;
	MOV	WORD PTR [SI][3],'%'	;
	MOV	DI,OFFSET STR_BUFF	; 文字列バッファ
	CALL_w	WORDTL_N_HNZN		; 文字列半角を全角

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	ADD	AX,STS_NAME_XL		; ステータス名Ｘ長さ
	MOV	SI,OFFSET STR_BUFF	; 文字列バッファ
	CALL_w	VTXPOR			; vram text print OR.
	RET
FEND	WID_FRAME_STATUS_PAR


; ****************************************************
;	ステータス名
;	-I- WDX1    : グラフ表・表示位置Ｘ
;	    WDY1    : グラフ表・表示位置Ｙ
;	    GNUM    : グラフ番号
;	    GNAME   : 名前
;	    GVALUE  : パラメータ値
;	-O- LOCX    : start point.
;	    LOCY    : start point.
; ****************************************************

STATUS_NAME	PROC	NEAR
	CALL	STATLOC			; ステータス１行ロケーション

	MOV	AX,STS_TXTSIZE		; ｽﾃｰﾀｽ文字表示サイズ
	CALL_w	VTXSIZ			; character size set.
	MOV	AX,STS_TXTCOLOR		; ｽﾃｰﾀｽ文字表示色
	CALL_w	VTXCOL			; character color set.

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	MOV	SI,GNAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.
	RET
STATUS_NAME	ENDP


; ****************************************************
;	WINDOWS/フレーム・ｽﾃｰﾀｽ・ﾎﾟｲﾝﾄ値表示
;	-I- WDX1    : グラフ表・表示位置Ｘ
;	    WDY1    : グラフ表・表示位置Ｙ
;	    DX      : グラフ番号
;	    SI      : 名前
;	    AX      : ポイント値
; ****************************************************

FUNC_L	WID_FRAME_STATUS_VAL
	MOV	GNUM,DX			; グラフ番号
	MOV	GNAME,SI		; 名前
	MOV	GVALUE,AX		; パラメータ値

	CALL	STATUS_NAME		; ステータス名

	MOV	AX,STS_TXTSIZE		; ｽﾃｰﾀｽ文字表示サイズ
	CALL_w	VTXSIZ			; character size set.
	MOV	AX,STS_TXTCOLOR2	; ｽﾃｰﾀｽ文字(ﾊﾟﾗﾒｰﾀ値)表示色
	CALL_w	VTXCOL			; character color set.

	MOV	DX,GVALUE		; パラメータ値
	CALL_w	DECSTR			;
	CALL_w	STRZTS			; zero to space. "00123" - > "  123"
	ADD	SI,1	;2		;
	MOV	DI,OFFSET STR_BUFF	; 文字列バッファ
	CALL_w	WORDTL_N_HNZN		; 文字列半角を全角

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	ADD	AX,STS_NAME_XL-1	; ステータス名Ｘ長さ
	MOV	SI,OFFSET STR_BUFF	; 文字列バッファ
	CALL_w	VTXPOR			; vram text print OR.
	RET
FEND	WID_FRAME_STATUS_VAL


; ****************************************************
;	WINDOWS/フレーム・ｽﾃｰﾀｽ・ﾌﾗｸﾞON表示
;	-I- WDX1    : グラフ表・表示位置Ｘ
;	    WDY1    : グラフ表・表示位置Ｙ
;	    DX      : グラフ番号
;	    SI      : 名前
;	    AX      : フラグＯＮ／ＯＦＦ／ｎｏｒｍａｌ
; ****************************************************

FUNC_L	WID_FRAME_STATUS_FLAG
	MOV	GNUM,DX			; グラフ番号
	MOV	GNAME,SI		; 名前
	MOV	GVALUE,AX		; フラグＯＮ／ＯＦＦ

	CALL	STATLOC			; ステータス１行ロケーション

	MOV	AX,STS_TXTSIZE		; ｽﾃｰﾀｽ文字表示サイズ
	CALL_w	VTXSIZ			; character size set.

	CMP	GVALUE,0		; ＯＦＦ
	JE	WID_FRAME_STATUS_FLAG_OFF
	CMP	GVALUE,1		; ＯＮ
	JE	WID_FRAME_STATUS_FLAG_ON

WID_FRAME_STATUS_FLAG_NORMAL:
	MOV	AX,STS_FLAG_NML_C	; フラグｎｏｒｍａｌ
	CALL_w	VTXCOL			; character color set.
	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	MOV	SI,GNAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.
	RET
WID_FRAME_STATUS_FLAG_ON:
	MOV	AX,STS_FLAG_ON_C	; フラグＯＮ
	CALL_w	VTXCOL			; character color set.
	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	MOV	SI,GNAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.
	RET
WID_FRAME_STATUS_FLAG_OFF:
	MOV	AX,STS_FLAG_OFF_C	; フラグＯＦＦ
	CALL_w	VTXCOL			; character color set.
	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	MOV	SI,GNAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.
	RET
FEND	WID_FRAME_STATUS_FLAG


; ****************************************************
;	WINDOWS/フレーム・ICONﾊﾟﾗﾒｰﾀ表示
;	-I- WDX1    : グラフ表・表示位置Ｘ
;	    WDY1    : グラフ表・表示位置Ｙ
;	    BX      : グラフ番号
;	    CX      : 項目名
;	    DX      : 名前
;	    AX      : ＩＣＯＮ番号
;	    SI      : 内容
; ****************************************************

FUNC_L	WID_FRAME_ICON_PARA
	MOV	GNUM,BX			; グラフ番号
	MOV	GKNAME,CX		; 項目名
	MOV	GNAME,DX		; 名前
	MOV	ICONNO,AX		; ＩＣＯＮ番号
	MOV	GNAIYO,SI		; 内容

	CALL	ICONLOC			; ICONﾊﾟﾗﾒｰﾀ表示１行ロケーション

	MOV	AX,ICON_TXTSIZE		; ICON文字サイズ
	CALL_w	VTXSIZ			; character size set.
	MOV	AX,ICON_TXTCOLOR	; ICON文字表示色
	CALL_w	VTXCOL			; character color set.

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	MOV	SI,GKNAME		; 項目名
	CALL_w	VTXPOR			; vram text print OR.

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	ADD	AX,4			; + 4
	MOV	ICONXX,AX		;ＩＣＯＮ　Ｘ
	MOV	ICONYY,BX		;ＩＣＯＮ　Ｙ
	CALL	PUT_ICON		;ＩＣＯＮ

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	ADD	AX,8			;
	MOV	SI,GNAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.

	MOV	AX,LOCX			; start point.
	MOV	BX,LOCY			; start point.
	ADD	AX,8			;
	ADD	BX,18			;
	MOV	SI,GNAIYO		; 内容
	CALL_w	VTXPOR			; vram text print OR.

	RET
FEND	WID_FRAME_ICON_PARA


; ****************************************************
;	ICONﾊﾟﾗﾒｰﾀ表示１行ロケーション
;	-I- WDX1 : グラフ表・表示位置Ｘ
;	    WDY1 : グラフ表・表示位置Ｙ
;	    GNUM : グラフ番号
;	-O- LOCX : start point.
;	    LOCY : start point.
; ****************************************************

ICONLOC	PROC	NEAR
	MOV	AX,WDX1			; 表示位置Ｘ
	ADD	AX,ICON_SIDE_XL		; ICON左サイドＸ長さ
	MOV	LOCX,AX			; start point.

	MOV	AX,ICON_NAME_HIGHT	; ICONグラフ高さ
	MUL	GNUM			; グラフ番号
	ADD	AX,WDY1			; グラフ表・表示位置Ｙ
	ADD	AX,ICON_SIDE_YL		; ICON開始Ｙ位置
	MOV	LOCY,AX			; start point.
	RET
ICONLOC	ENDP


; ****************************************************
;	WINDOWS/フレーム・小アニメ
;	-I- WDX1         : 表示位置Ｘ
;	    WDY1         : 表示位置Ｙ
; ****************************************************

FUNC	WID_FRAME_ANIME_SMALL
	MOV	WDX2,WD_SML_AN_SZ_X	; フレーム・小アニメサイズＸ
	MOV	WDY2,WD_SML_AN_SZ_Y	; フレーム・小アニメサイズＹ
	CALL	BASE_FLAME		; フレーム１
	RET
FEND	WID_FRAME_ANIME_SMALL


; ****************************************************
;	WINDOWS/フレーム・大アニメ
;	-I- WDX1         : 表示位置Ｘ
;	    WDY1         : 表示位置Ｙ
; ****************************************************

FUNC	WID_FRAME_ANIME_LARGE
	MOV	WDX2,WD_LGE_AN_SZ_X	; フレーム・大アニメサイズＸ
	MOV	WDY2,WD_LGE_AN_SZ_Y	; フレーム・大アニメサイズＹ
	CALL	BASE_FLAME		; フレーム１
	RET
FEND	WID_FRAME_ANIME_LARGE


; ****************************************************
;	WINDOWS/フレーム・小イベント
;	-I- WDX1         : 表示位置Ｘ
;	    WDY1         : 表示位置Ｙ
;	    BX           : bank number.
; ****************************************************

FUNC	WID_FRAME_IVENT_SMALL
	MOV	AX,4			;4=ﾌﾚｰﾑ･小ｲﾍﾞﾝﾄ
	MOV	CX,WDX1			;表示位置Ｘ
	MOV	DX,WDY1			;表示位置Ｙ
	CALL_w	PT_MINI_FRAME		;各種小さいフレーム
	RET
FEND	WID_FRAME_IVENT_SMALL


; ****************************************************
;	WINDOWS/フレーム・大イベント
;	-I- WDX1         : 表示位置Ｘ
;	    WDY1         : 表示位置Ｙ
;	    BX           : bank number.
; ****************************************************

FUNC	WID_FRAME_IVENT_LARGE
	MOV	AX,3			;3=ﾌﾚｰﾑ･大ｲﾍﾞﾝﾄ
	MOV	CX,WDX1			;表示位置Ｘ
	MOV	DX,WDY1			;表示位置Ｙ
	CALL_w	PT_MINI_FRAME		;各種小さいフレーム
	RET
FEND	WID_FRAME_IVENT_LARGE


; ****************************************************
;	WINDOWS/フレーム・ﾄｰﾅﾒﾝﾄ名前箱
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC_L	WID_FLAME_TOUR_NAME
	CALL	BASE_FLAME		; フレーム１
	RET
FEND	WID_FLAME_TOUR_NAME


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1
;	-I- WDX1         : 表示位置Ｘ
;	    WDY1         : 表示位置Ｙ
;	    IPARATBL[0]  : ＩＣＯＮ番号
;	    IPARATBL[2]  : 名前
;	    IPARATBL[4]  : ＧＯＬＤ
;	    IPARATBL[6]  : ﾊﾟﾗﾒｰﾀ数 1or2
;	    IPARATBL[8]  : ﾊﾟﾗﾒｰﾀ名前 1
;	    IPARATBL[10] : ﾊﾟﾗﾒｰﾀ値 1
;	    IPARATBL[12] : ﾊﾟﾗﾒｰﾀ名前 2
;	    IPARATBL[14] : ﾊﾟﾗﾒｰﾀ値 2
;
;	TYPE 1	道具、武器
;		[    ] [　名前　]
;		[    ] [ＧＯＬＤ]
;		[攻]9999 [技]9999
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYPE1
	MOV	WDX2,WD_TYP1_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 サイズＸ
	MOV	WDY2,WD_TYP1_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 サイズＹ
	CALL	BASE_MLUT_FLAME		; フレーム3 ﾏﾙﾁｱｲﾃﾑ用

	MOVX	ICONNO,IPARATBL[0]	; ＩＣＯＮ番号
	MOVX	WORDADRS,IPARATBL[2]	; 名前
	MOVX	GOLD_VAL,IPARATBL[4]	; ＧＯＬＤ

	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	ADD	AX,1			;
	ADD	BX,4+1			;
	MOV	ICONXX,AX		; ＩＣＯＮ　Ｘ
	MOV	ICONYY,BX		; ＩＣＯＮ　Ｙ
	ADD	AX,4			; 
	MOV	STRXX,AX		; 文字Ｘ
	MOV	STRYY,BX		; 文字Ｙ
	ADD	BX,17			;
	MOV	GOLDXX,AX		; お金 Ｘ
	MOV	GOLDYY,BX		; お金 Ｙ

	CALL	PUT_ICON		; ＩＣＯＮ
	CALL	WORD_PRINT		; 文字列を表示
	CALL	GOLD_PRINT		; お金の表示

	CMP	IPARATBL[6],0		; ﾊﾟﾗﾒｰﾀ数 1or2
	JE	WID_FLAME_MULT_TYPE1_EXIT

	MOVX	PARANMID,IPARATBL[8]	; ﾊﾟﾗﾒｰﾀ名前 1
	MOVX	PARAVAL,IPARATBL[10]	; ﾊﾟﾗﾒｰﾀ値 1
	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	ADD	AX,1			;
	ADD	BX,39			;
	MOV	PARAXX,AX		; パラメータＸ
	MOV	PARAYY,BX		; パラメータＹ
	CALL	PARA_PRINT		; パラメータ表示

	CMP	IPARATBL[6],1		; ﾊﾟﾗﾒｰﾀ数 1or2
	JE	WID_FLAME_MULT_TYPE1_EXIT

	MOVX	PARANMID,IPARATBL[12]	; ﾊﾟﾗﾒｰﾀ名前 2
	MOVX	PARAVAL,IPARATBL[14]	; ﾊﾟﾗﾒｰﾀ値 2
	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	ADD	AX,8			;
	ADD	BX,39			;
	MOV	PARAXX,AX		; パラメータＸ
	MOV	PARAYY,BX		; パラメータＹ
	CALL	PARA_PRINT		; パラメータ表示

WID_FLAME_MULT_TYPE1_EXIT:
	RET
FEND	WID_FLAME_MULT_TYPE1


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    IPARATBL[0]  : ＩＣＯＮ番号
;	    IPARATBL[2]  : 名前
;	    IPARATBL[4]  : ＧＯＬＤ
;	    IPARATBL[8]  : 文字
;
;		[    ] [　名前　]
;		[    ] [初級][Ｇ]
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYPE2
	MOV	WDX2,WD_TYP2_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 サイズＸ
	MOV	WDY2,WD_TYP2_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 サイズＹ
	CALL	BASE_MLUT_FLAME		; フレーム3 ﾏﾙﾁｱｲﾃﾑ用

	MOVX	ICONNO,IPARATBL[0]	; ＩＣＯＮ番号
	MOVX	WORDADRS,IPARATBL[2]	; 名前
	MOVX	GOLD_VAL,IPARATBL[4]	; ＧＯＬＤ

	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	ADD	AX,1			;
	ADD	BX,4+1			;
	MOV	ICONXX,AX		; ＩＣＯＮ　Ｘ
	MOV	ICONYY,BX		; ＩＣＯＮ　Ｙ
	ADD	AX,5			; 
	MOV	STRXX,AX		; 文字Ｘ
	MOV	STRYY,BX		; 文字Ｙ

	MOV	SI,IPARATBL[8]		; 文字
	CMP	BYTE PTR DS:[SI],0	; 文字
	JE	WID_FLAME_MULT_TYPE2_5	;
	ADD	AX,4			;
WID_FLAME_MULT_TYPE2_5:			;

	ADD	BX,17			;
	MOV	GOLDXX,AX		; お金 Ｘ
	MOV	GOLDYY,BX		; お金 Ｙ

	CALL	PUT_ICON		; ＩＣＯＮ
	CALL	WORD_PRINT		; 文字列を表示
	CALL	GOLD_PRINT		; お金の表示

	MOV	SI,IPARATBL[8]		; 文字
	CMP	BYTE PTR DS:[SI],0	; 文字
	JE	WID_FLAME_MULT_TYPE2_8	;

	MOVX	WORDADRS,IPARATBL[8]	; 文字
	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	ADD	AX,6			;
	ADD	BX,21			;
	MOV	STRXX,AX		; 文字Ｘ
	MOV	STRYY,BX		; 文字Ｙ
	CALL	WORD_PRINT		; 文字列を表示

WID_FLAME_MULT_TYPE2_8:
	RET
FEND	WID_FLAME_MULT_TYPE2


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    IPARATBL[0]  : ＩＣＯＮ番号
;	    IPARATBL[2]  : 名前
;	    IPARATBL[4]  : ＧＯＬＤ
;
;		[    ] [　名前　]
;		[    ] [ＧＯＬＤ]
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYPE3
	MOV	WDX2,WD_TYP3_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 サイズＸ
	MOV	WDY2,WD_TYP3_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 サイズＹ
	CALL	BASE_MLUT_FLAME		; フレーム3 ﾏﾙﾁｱｲﾃﾑ用

	MOVX	ICONNO,IPARATBL[0]	; ＩＣＯＮ番号
	MOVX	WORDADRS,IPARATBL[2]	; 名前
	MOVX	GOLD_VAL,IPARATBL[4]	; ＧＯＬＤ

	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	ADD	AX,1			;
	ADD	BX,4+1			;
	MOV	ICONXX,AX		; ＩＣＯＮ　Ｘ
	MOV	ICONYY,BX		; ＩＣＯＮ　Ｙ
	ADD	AX,5			; 
	MOV	STRXX,AX		; 文字Ｘ
	MOV	STRYY,BX		; 文字Ｙ
	ADD	BX,17			;
	MOV	GOLDXX,AX		; お金 Ｘ
	MOV	GOLDYY,BX		; お金 Ｙ

	CALL	PUT_ICON		; ＩＣＯＮ
	CALL	WORD_PRINT		; 文字列を表示
	CALL	GOLD_PRINT		; お金の表示

	RET
FEND	WID_FLAME_MULT_TYPE3


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    IPARATBL[0]  : ＩＣＯＮ番号
;	    IPARATBL[2]  : 名前
;	    IPARATBL[8]  : 文字
;
;		[    ] [　名前　]
;		[    ]
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYPE4
	MOV	WDX2,WD_TYP4_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 サイズＸ
	MOV	WDY2,WD_TYP4_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 サイズＹ
	CALL	BASE_MLUT_FLAME		; フレーム3 ﾏﾙﾁｱｲﾃﾑ用

	MOVX	ICONNO,IPARATBL[0]	; ＩＣＯＮ番号
	MOVX	WORDADRS,IPARATBL[2]	; 名前

	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	ADD	AX,1			;
	ADD	BX,4+1			;
	MOV	ICONXX,AX		; ＩＣＯＮ　Ｘ
	MOV	ICONYY,BX		; ＩＣＯＮ　Ｙ
	ADD	AX,5			; 
	MOV	STRXX,AX		; 文字Ｘ
	MOV	STRYY,BX		; 文字Ｙ
	ADD	BX,17			;
	MOV	GOLDXX,AX		; お金 Ｘ
	MOV	GOLDYY,BX		; お金 Ｙ

	CALL	PUT_ICON		; ＩＣＯＮ
	CALL	WORD_PRINT		; 文字列を表示

	MOVX	WORDADRS,IPARATBL[8]	; 文字
	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	ADD	AX,6			;
	ADD	BX,21			;
	MOV	STRXX,AX		; 文字Ｘ
	MOV	STRYY,BX		; 文字Ｙ
	CALL	WORD_PRINT		; 文字列を表示

	RET
FEND	WID_FLAME_MULT_TYPE4


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel
;	-I- SI : メッセージ
; ****************************************************

FUNC	WID_FLAME_MULT_CANCEL
	MOVX	WORDADRS,SI		; 名前

	MOV	WDX2,WD_CANC_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel サイズＸ
	MOV	WDY2,WD_CANC_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel サイズＹ
	CALL	BASE_MLUT_FLAME		; フレーム3 ﾏﾙﾁｱｲﾃﾑ用

	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	ADD	AX,2			;
	ADD	BX,8			;
	MOV	STRXX,AX		; 文字Ｘ
	MOV	STRYY,BX		; 文字Ｙ
	CALL	WORD_PRINT		; 文字列を表示

	RET
FEND	WID_FLAME_MULT_CANCEL


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 ON
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYP1_ON
	MOV	WDX2,WD_TYP1_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 サイズＸ
	MOV	WDY2,WD_TYP1_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 サイズＹ
	CALL	WID_GAWA_2T		; フレームの側 その２
	RET
FEND	WID_FLAME_MULT_TYP1_ON


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 OFF
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYP1_OFF
	MOV	WDX2,WD_TYP1_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 サイズＸ
	MOV	WDY2,WD_TYP1_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 サイズＹ
	CALL	WID_GAWA_1T		; フレームの側 その１
	RET
FEND	WID_FLAME_MULT_TYP1_OFF


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 ON
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYP2_ON
	MOV	WDX2,WD_TYP2_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 サイズＸ
	MOV	WDY2,WD_TYP2_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 サイズＹ
	CALL	WID_GAWA_2T		; フレームの側 その２
	RET
FEND	WID_FLAME_MULT_TYP2_ON


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 OFF
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYP2_OFF
	MOV	WDX2,WD_TYP2_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 サイズＸ
	MOV	WDY2,WD_TYP2_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 サイズＹ
	CALL	WID_GAWA_1T		; フレームの側 その１
	RET
FEND	WID_FLAME_MULT_TYP2_OFF


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 ON
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYP3_ON
	MOV	WDX2,WD_TYP3_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 サイズＸ
	MOV	WDY2,WD_TYP3_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 サイズＹ
	CALL	WID_GAWA_2T		; フレームの側 その２
	RET
FEND	WID_FLAME_MULT_TYP3_ON


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 OFF
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYP3_OFF
	MOV	WDX2,WD_TYP3_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 サイズＸ
	MOV	WDY2,WD_TYP3_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 サイズＹ
	CALL	WID_GAWA_1T		; フレームの側 その１
	RET
FEND	WID_FLAME_MULT_TYP3_OFF


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 ON
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYP4_ON
	MOV	WDX2,WD_TYP4_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 サイズＸ
	MOV	WDY2,WD_TYP4_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 サイズＹ
	CALL	WID_GAWA_2T		; フレームの側 その２
	RET
FEND	WID_FLAME_MULT_TYP4_ON


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 OFF
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_MULT_TYP4_OFF
	MOV	WDX2,WD_TYP4_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 サイズＸ
	MOV	WDY2,WD_TYP4_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 サイズＹ
	CALL	WID_GAWA_1T		; フレームの側 その１
	RET
FEND	WID_FLAME_MULT_TYP4_OFF


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel ON
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_MULT_CANCEL_ON
	MOV	WDX2,WD_CANC_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel サイズＸ
	MOV	WDY2,WD_CANC_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel サイズＹ
	CALL	WID_GAWA_2T		; フレームの側 その２
	RET
FEND	WID_FLAME_MULT_CANCEL_ON


; ****************************************************
;	WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel OFF
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

FUNC_L	WID_FLAME_MULT_CANCEL_OFF
	MOV	WDX2,WD_CANC_SIZE_X	; フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel サイズＸ
	MOV	WDY2,WD_CANC_SIZE_Y	; フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel サイズＹ
	CALL	WID_GAWA_1T		; フレームの側 その１
	RET
FEND	WID_FLAME_MULT_CANCEL_OFF


; ****************************************************
;	WINDOWS/ﾌﾚｰﾑ･ﾃﾞｰﾀﾛｰﾄﾞｾｰﾌﾞ(DSKTOOL.COM)
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

FUNC	WID_FLAME_DSKTOOL
	CALL	BASE_LDSV_FLM		; フレーム4 ﾛｰﾄﾞｾｰﾌﾞ用
	RET
FEND	WID_FLAME_DSKTOOL



; ****************************************************
;	ＩＣＯＮ
;	-I- ICONNO :ＩＣＯＮ番号
;	    ICONXX :ＩＣＯＮ　Ｘ
;	    ICONYY :ＩＣＯＮ　Ｙ
; ****************************************************

PUT_ICON	PROC	NEAR
	MOV	DX,ICONNO		; ICON number.
	MOV	AX,ICONXX		; put x.
	MOV	BX,ICONYY		; put y.
	CALL_w	ICON_PUT		; ICON put.
	RET
PUT_ICON	ENDP


; ****************************************************
;	文字列を表示
;	-I- WORDADRS : 名前
;	    STRXX  : 文字Ｘ
;	    STRYY  : 文字Ｙ
; ****************************************************

WORD_PRINT	PROC	NEAR
	MOV	AX,WDID_CHRSIZE		; 文字表示サイズ
	CALL_w	VTXSIZ			; character size set.

	MOV	AX,WDID_CHRCOLOR	; 文字表示色
	CALL_w	VTXCOL			; character color set.

	MOV	AX,STRXX		; 文字Ｘ
	MOV	BX,STRYY		; 文字Ｙ
	MOV	SI,WORDADRS		; 名前
	CALL_w	VTXPOR			; vram text print OR.

	RET
WORD_PRINT	ENDP


; ****************************************************
;	お金の表示
;	-I- GOLD_VAL : お金
;	    GOLDXX   : お金 Ｘ
;	    GOLDYY   : お金 Ｙ
; ****************************************************

GOLD_PRINT	PROC	NEAR
	MOV	DX,GOLD_VAL		; お金
	CALL_w	WID_STR_GOLD		; WINDOWS/文字列化・通貨

	MOV	AX,TXCOL_GOLD		; お金font color.
	CALL_w	MITCOL			; mini string color.

	MOV	AX,GOLDXX		; お金 Ｘ
	MOV	BX,GOLDYY		; お金 Ｙ
	MOV	SI,OFFSET STR_VAL_BUFF	; 表示値文字列バッファ
;;;	CALL_w	MBTPRN			; BIG string. (null=end of string)
;;;	CALL_w	MDTPRN			; MID string. (null=end of string)
	INC	BX			;
	CALL_w	MGXPRN			; GAINAX mini string.
	RET
GOLD_PRINT	ENDP


; ****************************************************
;	パラメータ表示
;	-I- PARANMID : パラメータ名前
;	    PARAVAL  : パラメータ値
;	    PARAXX   : パラメータＸ
;	    PARAYY   : パラメータＹ
; ****************************************************

PARA_PRINT	PROC	NEAR
	MOV	AX,PARA_CHRSIZE		; ﾊﾟﾗﾒｰﾀ文字表示サイズ
	CALL_w	VTXSIZ			; character size set.

	MOV	AX,PARA_CHRCOLOR	; ﾊﾟﾗﾒｰﾀ文字表示色
	CALL_w	VTXCOL			; character color set.

	MOV	SI,PARANMID		; パラメータ名前
;*;	CALL_w	WID_STR_P_1MOJI		; WINDOWS/ﾊﾟﾗﾒｰﾀ名前１文字化
;*;	MOV	SI,OFFSET STR_BUFF	; １文字化文字列
	MOV	AX,PARAXX		; パラメータＸ
	MOV	BX,PARAYY		; パラメータＹ
	CALL_w	VTXPOR			; vram text print OR.

	CMP	PARAVAL,0		; パラメータ値
	JE	PARA_PRINT_EXIT		;

	MOV	DX,PARAVAL		; パラメータ値
	CALL_w	WID_STR_POINT		; WINDOWS/文字列化・ポイント

	MOV	SI,OFFSET STR_VAL_BUFF	; 表示値文字列バッファ
	MOV	AX,PARAXX		; パラメータＸ
	ADD	AX,2			;
	MOV	BX,PARAYY		; パラメータＹ
	CALL_w	VTXPOR			; vram text print OR.

PARA_PRINT_EXIT:
	RET
PARA_PRINT	ENDP


; ****************************************************
;	グラフ描画
;	-I- GVALUE   : パラメータ値
;	    GR_SCALE : グラフ・スケール
;	    VX1      : start point.
;	    VY1      : start point.
;	    GR_SFT_X : グラフ位置シフトＸ
;	    GR_SFT_Y : グラフ位置シフトＹ
;	    GR_DOT_XL: グラフＸドット長さ
;	    GR_G_WID : グラフ太さ
; ****************************************************

GRP_DRAW	PROC	NEAR
	MOV	AX,VX1			; start point.
	MOV	BX,VY1			; start point.
	ADD	AX,GR_SFT_X		; グラフ位置シフトＸ
	ADD	BX,GR_SFT_Y		; グラフ位置シフトＹ

	SHL	AX,1			;
	SHL	AX,1			; * 8
	SHL	AX,1			;

	MOV	VX1,AX			; start dot point x1.
	MOV	VY1,BX			; line hight y1.

;*;	ADD	AX,GR_DOT_XL		; グラフＸドット長さ
;*;	MOV	VX2,AX			; end dot point x2.
;*;	MOVX	VCOL,W_COL_GR_OFF	; WINDOWS/カラー・グラフOFF色
;*;	MOV	CX,GR_G_WID		; グラフ太さ
;*;	CALL_w	DLINEH			; 水平ライン描画

	MOV	DX,0			;
	MOV	AX,GVALUE		; パラメータ値
	MOV	BX,GR_SCALE		; ÷グラフ・スケール
	DIV	BX			;
	CMP	DX,0			;
	JE	GRP_DRAW_7		;
	INC	AX			;
GRP_DRAW_7:				;
;*;	CMP	AX,0			;
;*;	JE	GRP_DRAW_EXIT		;

	CMP	AX,GR_DOT_XL		; グラフＸドット長さ
	JBE	GRP_DRAW_8		;
	MOV	AX,GR_DOT_XL		; グラフＸ長さ
GRP_DRAW_8:				;

	MOV	DX,AX			; bar length.
	MOV	CX,GR_DOT_XL		; グラフＸドット長さ
	MOV	AX,VX1			; start point x.
	MOV	BX,VY1			; start point y.
	CALL_w	EF_BAR_LINE	; bar graphic line.


;*;	DEC	AX			;
;*;	ADD	AX,VX1			; start dot point x1.
;*;	MOV	VX2,AX			; end dot point x2.
;*;	MOVX	VCOL,W_COL_GR_ON	; WINDOWS/カラー・グラフON色
;*;	MOV	CX,GR_G_WID		; グラフ太さ
;*;	CALL_w	DLINEH			; 水平ライン描画


GRP_DRAW_EXIT:
	RET
GRP_DRAW	ENDP


; ****************************************************
;	フレーム１
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

BASE_FLAME	PROC	NEAR
	CALL	BOX_CALC		; box calc.
	CALL	JI_TEXT			; テキスト地色
	CALL	WID_GAWA_1T		; フレームの側 その１
	RET
BASE_FLAME	ENDP


; ****************************************************
;	フレーム２ SLCT用
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

BASE_SLCT_FLM	PROC	NEAR
	CALL	BOX_CALC		; box calc.
	CALL	JI_TEXT			; テキスト地色
	CALL	WID_GAWA_3T		; フレームの側 その３(ＧＯＬＤ)
	MOV	KAZA_PT_NUM,0		; 飾りﾊﾟﾀｰﾝ番号
	CALL	WID_KAZARI		; 四つ角の飾りPUT
	RET
BASE_SLCT_FLM	ENDP


; ****************************************************
;	フレーム3 ﾏﾙﾁｱｲﾃﾑ用
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

BASE_MLUT_FLAME	PROC	NEAR
	CALL	BOX_CALC		; box calc.
	CALL	JI_TEXT			; テキスト地色
	MOV	FLAG_GAWA_FT,1		; ﾌﾗｸﾞ側ふち
	CALL	WID_GAWA_1T		; フレームの側 その１

	MOV	FLAG_GAWA_FT,0		; ﾌﾗｸﾞ側ふち
	MOV	KAZA_PT_NUM,4		; 飾りﾊﾟﾀｰﾝ番号
	CALL	WID_KAZARI		; 四つ角の飾りPUT
	RET
BASE_MLUT_FLAME	ENDP


; ****************************************************
;	フレーム4 ﾛｰﾄﾞｾｰﾌﾞ用
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

BASE_LDSV_FLM	PROC	NEAR
	CALL	BOX_CALC		; box calc.
	CALL	JI_TEXT			; テキスト地色
	CALL	WID_GAWA_3T		; フレームの側 その３(ＧＯＬＤ)
	MOV	KAZA_PT_NUM,12		; 飾りﾊﾟﾀｰﾝ番号
	CALL	WID_KAZARI		; 四つ角の飾りPUT
	RET
BASE_LDSV_FLM	ENDP


; ****************************************************
;	フレームの側 その１（ノーマル）
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

WID_GAWA_1T	PROC	NEAR
	MOVX	GWA_COL1,W_COL1		; WINDOWS/カラー・ハイライト
	MOVX	GWA_COL2,W_COL2		; WINDOWS/カラー・明るい灰
	MOVX	GWA_COL3,W_COL3		; WINDOWS/カラー・暗い灰
	MOVX	GWA_COL4,W_COL4		; WINDOWS/カラー・黒
	MOVX	GWA_COL5,W_COL5		; WINDOWS/カラー・暗い色
	CALL	WID_GAWA		; フレームの側
	MOV	KAZA_PT_NUM,8		; 飾りﾊﾟﾀｰﾝ番号
	CALL	WID_KAZA2N		; 四つ角の飾りPUT2(細いタイプ)
	RET
WID_GAWA_1T	ENDP


; ****************************************************
;	フレームの側 その２(ブリンク用)
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

WID_GAWA_2T	PROC	NEAR
	MOVX	GWA_COL1,W2_COL1	; BRINK/カラー・ハイライトNO.2
	MOVX	GWA_COL2,W2_COL2	; BRINK/カラー・明るい灰NO.2
	MOVX	GWA_COL3,W2_COL3	; BRINK/カラー・暗い灰NO.2
	MOVX	GWA_COL4,W2_COL4	; BRINK/カラー・黒NO.2
	MOVX	GWA_COL5,W2_COL5	; BRINK/カラー・暗い色NO.2
	CALL	WID_GAWA		; フレームの側
	RET
WID_GAWA_2T	ENDP


; ****************************************************
;	フレームの側 その３(ＧＯＬＤ)
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

WID_GAWA_3T	PROC	NEAR
	MOVX	GWA_COL1,W3_COL1	; GOLD/カラー・ハイライトNO.3
	MOVX	GWA_COL2,W3_COL2	; GOLD/カラー・明るい灰NO.3
	MOVX	GWA_COL3,W3_COL3	; GOLD/カラー・暗い灰NO.3
	MOVX	GWA_COL4,W3_COL4	; GOLD/カラー・黒NO.3
	MOVX	GWA_COL5,W3_COL5	; GOLD/カラー・暗い色NO.3
	CALL	WID_GAWA		; フレームの側
	RET
WID_GAWA_3T	ENDP


; ****************************************************
;	フレームの側
;	-I- WDX1     : 表示位置Ｘ
;	    WDY1     : 表示位置Ｙ
;	    WDX2     : 大きさＸ
;	    WDY2     : 大きさＹ
;	    GWA_COL1 : 側カラー・ハイライト
;	    GWA_COL2 : 側カラー・明るい灰
;	    GWA_COL3 : 側カラー・暗い灰
;	    GWA_COL4 : 側カラー・黒
;	    GWA_COL5 : 側カラー・暗い色
; ****************************************************

WID_GAWA	PROC	NEAR
	MOV	AX,WDX1			; 表示位置Ｘ
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			; * 8
	MOV	VX1,AX			; ヘッダー表示Ｘ位置
	MOV	AX,WDX1			; 表示位置Ｘ
	ADD	AX,WDX2			; 大きさＸ
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			; * 8
	DEC	AX			; -1
	MOV	VX2,AX			; ヘッダー表示Ｘ位置

	MOVX	VY1,WDY1		; 表示位置Ｙ
	MOVX	VCOL,GWA_COL4		; カラー・黒
	MOV	CX,1			; 太さ
	CALL_w	DLINEH			; 水平ライン描画

	INC	VY1			;
	MOVX	VCOL,GWA_COL1		; カラー・ハイライト
	MOV	CX,1			; 太さ
	CALL_w	DLINEH			; 水平ライン描画

	INC	VY1			;
	MOVX	VCOL,GWA_COL2		; カラー・明るい灰
	MOV	CX,1			; 太さ
	CALL_w	DLINEH			; 水平ライン描画

	INC	VY1			;
	MOVX	VCOL,GWA_COL3		; カラー・暗い灰
	MOV	CX,1			; 太さ
	CALL_w	DLINEH			; 水平ライン描画

	CMP	FLAG_GAWA_FT,0		; ﾌﾗｸﾞ側ふち
	JE	WID_GAWA_31		;

	INC	VY1			;
	MOVX	VCOL,GWA_COL6		; 側カラー・内側
	MOV	CX,1			; 太さ
	CALL_w	DLINEH			; 水平ライン描画

	ADDX	VY1,WDY2		; 大きさＹ
	SUB	VY1,6+1+2		;

	MOVX	VCOL,GWA_COL6		; 側カラー・内側
	MOV	CX,1			; 太さ
	CALL_w	DLINEH			; 水平ライン描画

	INC	VY1			;
	JMP	WID_GAWA_32

WID_GAWA_31:
	ADDX	VY1,WDY2		; 大きさＹ
	SUB	VY1,6+1			;
WID_GAWA_32:

	MOVX	VCOL,GWA_COL1		; カラー・ハイライト
	MOV	CX,1			; 太さ
	CALL_w	DLINEH			; 水平ライン描画

	INC	VY1			;
	MOVX	VCOL,GWA_COL2		; カラー・明るい灰
	MOV	CX,1			; 太さ
	CALL_w	DLINEH			; 水平ライン描画

	INC	VY1			;
	MOVX	VCOL,GWA_COL3		; カラー・暗い灰
	MOV	CX,1			; 太さ
	CALL_w	DLINEH			; 水平ライン描画

	INC	VY1			;
	MOVX	VCOL,GWA_COL4		; カラー・黒
	MOV	CX,1			; 太さ
	CALL_w	DLINEH			; 水平ライン描画


	MOVX	VY1,WDY1		; 表示位置Ｙ

	MOV	AX,WDY1			; 表示位置Ｙ
	ADD	AX,WDY2			; 大きさＹ
	DEC	AX			;
	MOV	VY2,AX			;


	MOVX	VCOL,GWA_COL4		; カラー・黒
	MOV	CX,1			; 太さ
	CALL_w	DLINEV			; 垂直ライン描画

	INC	VX1			;
	INC	VY1			;
	DEC	VY2			;
	MOVX	VCOL,GWA_COL1		; カラー・ハイライト
	MOV	CX,1			; 太さ
	CALL_w	DLINEV			; 垂直ライン描画

	INC	VX1			;
	INC	VY1			;
	DEC	VY2			;
	MOVX	VCOL,GWA_COL2		; カラー・明るい灰
	MOV	CX,1			; 太さ
	CALL_w	DLINEV			; 垂直ライン描画

	INC	VX1			;
	INC	VY1			;
	DEC	VY2			;
	MOVX	VCOL,GWA_COL3		; カラー・暗い灰
	MOV	CX,1			; 太さ
	CALL_w	DLINEV			; 垂直ライン描画


	CMP	FLAG_GAWA_FT,0		; ﾌﾗｸﾞ側ふち
	JE	WID_GAWA_61		;

	INC	VX1			;
	INC	VY1			;
	DEC	VY2			;
	MOVX	VCOL,GWA_COL6		; 側カラー・内側
	MOV	CX,1			; 太さ
	CALL_w	DLINEV			; 垂直ライン描画

	MOVX	VX1,VX2			;
	SUB	VX1,4			;

	MOVX	VCOL,GWA_COL6		; 側カラー・内側
	MOV	CX,1			; 太さ
	CALL_w	DLINEV			; 垂直ライン描画
	INC	VX1			;
	DEC	VY1			;
	INC	VY2			;

	JMP	WID_GAWA_62
WID_GAWA_61:
	MOVX	VX1,VX2			;
	SUB	VX1,3			;
WID_GAWA_62:


	MOVX	VCOL,GWA_COL1		; カラー・ハイライト
	MOV	CX,1			; 太さ
	CALL_w	DLINEV			; 垂直ライン描画

	INC	VX1			;
	DEC	VY1			;
	INC	VY2			;
	MOVX	VCOL,GWA_COL2		; カラー・明るい灰
	MOV	CX,1			; 太さ
	CALL_w	DLINEV			; 垂直ライン描画

	INC	VX1			;
	DEC	VY1			;
	INC	VY2			;
	MOVX	VCOL,GWA_COL3		; カラー・暗い灰
	MOV	CX,1			; 太さ
	CALL_w	DLINEV			; 垂直ライン描画

	INC	VX1			;
	DEC	VY1			;
	INC	VY2			;
	MOVX	VCOL,GWA_COL4		; カラー・黒
	MOV	CX,1			; 太さ
	CALL_w	DLINEV			; 垂直ライン描画

	RET
WID_GAWA	ENDP


;*;; ****************************************************
;*;;	フレームの側・反転(ﾌﾞﾘﾝｸ用)
;*;;	-I- WDX1     : 表示位置Ｘ
;*;;	    WDY1     : 表示位置Ｙ
;*;;	    WDX2     : 大きさＸ
;*;;	    WDY2     : 大きさＹ
;*;; ****************************************************
;*;
;*;WID_GAWA_BRK	PROC	NEAR
;*;	MOV	AX,WDX1			; 表示位置Ｘ
;*;	MOV	BX,WDY1			; 表示位置Ｙ
;*;	MOV	CX,AX
;*;	MOV	DX,BX
;*;	ADD	CX,WDX2			; 大きさＸ
;*;	ADD	DX,WDY2			; 大きさＹ
;*;	DEC	CX
;*;	DEC	DX
;*;	MOV	VX1,AX
;*;	MOV	VY1,BX
;*;	MOV	VX2,CX
;*;	MOV	VY2,DX
;*;	MOV	CX,1111B		; color palet number.
;*;	CALL_w	BOXNOT			; ＢＯＸ反転
;*;
;*;	MOV	VX1,AX
;*;	MOV	VY1,BX
;*;	MOV	VX2,CX
;*;	MOV	VY2,DX
;*;	MOV	CX,1111B		; color palet number.
;*;	CALL_w	BOXNOT			; ＢＯＸ反転
;*;	RET
;*;WID_GAWA_BRK	ENDP


; ****************************************************
;	四つ角の飾りPUT
;	-I- KAZA_PT_NUM : 飾りﾊﾟﾀｰﾝ番号
;	    WDX1     : 表示位置Ｘ
;	    WDY1     : 表示位置Ｙ
;	    WDX2     : 大きさＸ
;	    WDY2     : 大きさＹ
; ****************************************************

WID_KAZARI	PROC	NEAR
	CALL	BOX_CALC		; box calc.

	DEC	VX2			; end point.
	SUB	VY2,15			; end point.

	MOV	AX,KAZA_PT_NUM		; 飾りﾊﾟﾀｰﾝ番号
	MOV	BX,VX1			; start point.
	MOV	CX,VY1			; start point.
	PUSH	AX			;
	CALL_w	PT_FRM_KAZARI		;汎用フレームの飾り
	POP	AX			;

	INC	AX			;
	MOV	BX,VX2			; start point.
	MOV	CX,VY1			; start point.
	PUSH	AX			;
	CALL_w	PT_FRM_KAZARI		;汎用フレームの飾り
	POP	AX			;

	INC	AX			;
	MOV	BX,VX2			; start point.
	MOV	CX,VY2			; start point.
	PUSH	AX			;
	CALL_w	PT_FRM_KAZARI		;汎用フレームの飾り
	POP	AX			;

	INC	AX			;
	MOV	BX,VX1			; start point.
	MOV	CX,VY2			; start point.
	CALL_w	PT_FRM_KAZARI		;汎用フレームの飾り

	RET
WID_KAZARI	ENDP


; ****************************************************
;	四つ角の飾りPUT2(細いタイプ)
;	-I- KAZA_PT_NUM : 飾りﾊﾟﾀｰﾝ番号
;	    WDX1     : 表示位置Ｘ
;	    WDY1     : 表示位置Ｙ
;	    WDX2     : 大きさＸ
;	    WDY2     : 大きさＹ
; ****************************************************

WID_KAZA2N	PROC	NEAR
	CALL	BOX_CALC		; box calc.

	DEC	VX2			; end point.
	SUB	VY2,4			; end point.

	MOV	AX,KAZA_PT_NUM		; 飾りﾊﾟﾀｰﾝ番号
	MOV	BX,VX1			; start point.
	MOV	CX,VY1			; start point.
	PUSH	AX			;
	CALL_w	PT_FRM_KAZARI		;汎用フレームの飾り
	POP	AX			;

	INC	AX			;
	MOV	BX,VX2			; start point.
	MOV	CX,VY1			; start point.
	PUSH	AX			;
	CALL_w	PT_FRM_KAZARI		;汎用フレームの飾り
	POP	AX			;

	INC	AX			;
	MOV	BX,VX2			; start point.
	MOV	CX,VY2			; start point.
	PUSH	AX			;
	CALL_w	PT_FRM_KAZARI		;汎用フレームの飾り
	POP	AX			;

	INC	AX			;
	MOV	BX,VX1			; start point.
	MOV	CX,VY2			; start point.
	CALL_w	PT_FRM_KAZARI		;汎用フレームの飾り

	RET
WID_KAZA2N	ENDP


; ****************************************************
;	box calc.
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
;	-O- VX1  : start point.
;	    VY1  : start point.
;	    VX2  : end point.
;	    VY2  : end point.
; ****************************************************

BOX_CALC	PROC	NEAR
	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	MOV	VX1,AX			; start point.
	MOV	VY1,BX			; start point.
	ADD	AX,WDX2			; 大きさＸ
	ADD	BX,WDY2			; 大きさＹ
	DEC	AX			;
	DEC	BX			;
	MOV	VX2,AX			; end point.
	MOV	VY2,BX			; end point.
	RET
BOX_CALC	ENDP


; ****************************************************
;	テキスト地色
;	-I- VX1,VY1  : start point.
;	    VX2,VY2  : end point.
; ****************************************************

JI_TEXT	PROC	NEAR
	MOV	CX,W_COL6		; WINDOWS/カラー・テキスト地色１
	MOV	BX,W_COL7		; WINDOWS/カラー・テキスト地色１
	CALL_w	BOXMCH			; ＢＯＸチェック模様
	RET
JI_TEXT	ENDP


; ****************************************************
;	テキスト地色・カラー
;	-I- VX1,VY1  : start point.
;	    VX2,VY2  : end point.
;	    CX       : カラー
; ****************************************************

JI_TEXT_COLOR	PROC	NEAR
	CALL_w	BOXPAL			; ＢＯＸペイント
	RET
JI_TEXT_COLOR	ENDP


WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	IPARATBL:WORD		; アイテムパラメータ・ﾃｰﾌﾞﾙ
EXTRN	IPARACNT:WORD		; アイテムパラメータ・数
EXTRN	IPARADIM:WORD		; アイテムパラメータ・ﾃｰﾌﾞﾙｻｲｽﾞ

ICONNO		DW	0	; ＩＣＯＮ番号
ICONXX		DW	0	; ＩＣＯＮ　Ｘ
ICONYY		DW	0	; ＩＣＯＮ　Ｙ

WORDADRS	DW	0	; 名前
STRXX		DW	0	; 文字Ｘ
STRYY		DW	0	; 文字Ｙ

GOLD_VAL	DW	0	; お金
GOLDXX		DW	0	; お金 Ｘ
GOLDYY		DW	0	; お金 Ｙ

PARANMID	DW	0	; パラメータ名前
PARAVAL		DW	0	; パラメータ値
PARAXX		DW	0	; パラメータＸ
PARAYY		DW	0	; パラメータＹ

GNUM		DW	0	; グラフ番号
GNAME		DW	0	; 名前
GNAIYO		DW	0	; 内容
GVALUE		DW	0	; パラメータ値
GWIDTYPE	DW	0	; ウインドウタイプ
GKNAME		DW	0	; 項目名
GUPDOWN		DW	0	; 上下目安

LOCX		DW	0	; x.
LOCY		DW	0	; y.
XX1		DW	0	; x1.
YY1		DW	0	; y1.
XX2		DW	0	; x2.
YY2		DW	0	; y2.


W_COL1		DW	15;2;15	; WINDOWS/カラー・ハイライト
W_COL2		DW	8;4;8	; WINDOWS/カラー・明るい灰
W_COL3		DW	7;4;2	; WINDOWS/カラー・暗い灰
W_COL4		DW	0	; WINDOWS/カラー・黒
W_COL5		DW	4;2	; WINDOWS/カラー・暗い色

W_COL6		DW	4	; WINDOWS/カラー・テキスト地色１
W_COL7		DW	0	; WINDOWS/カラー・テキスト地色１
W_COL8		DW	5	; WINDOWS/カラー・グラフ地色
W_COL9		DW	0	; WINDOWS/カラー・グラフ値地色
W_COL10		DW	6	; WINDOWS/カラー・グラフライン地色

W_COL_G1	DW	5,4,3,9,6	; WINDOWS/カラー・グラフ地色１
W_COL_G2	DW	6,5,5,7,10	; WINDOWS/カラー・グラフ地色２

W_COL_GR_OFF	DW	4	; WINDOWS/カラー・グラフOFF色
W_COL_GR_ON	DW	8	; WINDOWS/カラー・グラフON色

W_COL_GOLDNAME	DW	5	; WINDOWS/カラー・ＧＯＬＤ名前
W_COL_GOLD1	DW	0;4	; WINDOWS/カラー・ＧＯＬＤ地色１
W_COL_GOLD2	DW	4;6	; WINDOWS/カラー・ＧＯＬＤ地色２

W2_COL1		DW	15	; BRINK/カラー・ハイライトNO.2
W2_COL2		DW	15	; BRINK/カラー・明るい灰NO.2
W2_COL3		DW	15	; BRINK/カラー・暗い灰NO.2
W2_COL4		DW	15	; BRINK/カラー・黒NO.2
W2_COL5		DW	15	; BRINK/カラー・暗い色NO.2

W3_COL1		DW	14	; GOLD/カラー・ハイライトNO.3
W3_COL2		DW	3	; GOLD/カラー・明るい灰NO.3
W3_COL3		DW	4	; GOLD/カラー・暗い灰NO.3
W3_COL4		DW	0	; GOLD/カラー・黒NO.3
W3_COL5		DW	2	; GOLD/カラー・暗い色NO.3

GWA_COL1	DW	15	; 側カラー・ハイライト
GWA_COL2	DW	3	; 側カラー・明るい灰
GWA_COL3	DW	5	; 側カラー・暗い灰
GWA_COL4	DW	0	; 側カラー・黒
GWA_COL5	DW	6	; 側カラー・暗い色
GWA_COL6	DW	4	; 側カラー・内側

GR_SCALE	DW	0	; グラフ・スケール
GR_SFT_X	DW	0	; グラフ位置シフトＸ
GR_SFT_Y	DW	0	; グラフ位置シフトＹ
GR_DOT_XL	DW	0	; グラフＸドット長さ
GR_G_WID	DW	0	; グラフ太さ

KAZA_PT_NUM	DW	0	; 飾りﾊﾟﾀｰﾝ番号

FLAG_GAWA_FT	DW	0	; ﾌﾗｸﾞ側ふち

DATA	ENDS

	END
;
;	end of "WIDFREAM.ASM"
;
