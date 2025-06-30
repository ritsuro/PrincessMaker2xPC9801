; "WIDNAME.ASM" PC-9801UV11 make by R.H 1990/12/17
;		modify486/50 make by R.H 1993/02/03
;
;
;	名前ウインドウ
;
;
;	WIDNAME_SET			; WINDOWS/名前ウインドウ全表示
;	WIDNAME_COLOR_OL		; WINDOWS/名前ウインドウ・カラーＯＬ
;	WIDNAME_PRINT			; WINDOWS/名前ウインドウ文字列表示
;	WIDNAME_PRINTG			; WINDOWS/名前ウインドウ文字列ＧＯＬＤ
;	WIDNAME_MESSAGE			; WINDOWS/名前ウインドウ・メッセージ
;	WIDNAME_M_CLENDR		; WINDOWS/名前ウインドウ･ｶﾚﾝﾀﾞﾒｯｾｰｼﾞ
;
;
;	設定されるﾊﾟﾗﾒｰﾀ
;
;	NAME_FIRST      : ファーストネーム
;	NAME_SECOND     : ファミリーネーム
;	LEN_NAME_FIRST  : ファーストネーム長さ
;	LEN_NAME_SECOND : ファミリーネーム長さ
;
;
; (C) 1993 ritsurou hashimoto.

INCLUDE	TSTSET.INC

FUNC	MACRO	SUB
PUBLIC	SUB
SUB	PROC	NEAR
	ENDM

FEND	MACRO	SUB
SUB	ENDP
	ENDM

OFFF		EQU	0FFFFH	; とりあえずＯＦＦという意味

BUFFLEN		EQU	8*2	; 名前バッファ長さ

FONTSIZ		EQU	0	; フォントサイズ
				; 0=16x16,1=32x32,2=16x24,3=16x32

NAME_SCRN_X	EQU	40-20	; 名前入力ｽｸﾘｰﾝ文字Ｘ
NAME_SCRN_Y	EQU	144	; 名前入力ｽｸﾘｰﾝ文字Ｙ

BROTH_SCRN_X	EQU	40-14	; 誕生日入力ｽｸﾘｰﾝ文字Ｘ
BROTH_SCRN_Y	EQU	15	; 誕生日入力ｽｸﾘｰﾝ文字Ｙ

NAME_CHR_X1	EQU	32	; 名前Ｘキャラ位置
NAME_CHR_X2	EQU	32+2*1	;
NAME_CHR_X3	EQU	32+2*2	;
NAME_CHR_X4	EQU	32+2*3	;
NAME_CHR_X5	EQU	32+2*4	;
NAME_CHR_X6	EQU	32+2*5	;
NAME_CHR_X7	EQU	32+2*6	;
NAME_CHR_X8	EQU	32+2*7	;
;NAME_CHR_Y1	EQU	200	; 名前Ｙキャラ位置
NAME_CHR_Y2	EQU	144	;

WIDTH_X		EQU	4	; 横間隔
WIDTH_X_F	EQU	8	; ファンクション横間隔
WIDTH_Y		EQU	20	; 高さ間隔

BOTTON_X	EQU	2	; ボタン横サイズ
BOTTON_X_F	EQU	6	; ファンクション横サイズ
BOTTON_Y	EQU	20	; ボタン縦サイズ

BTN_X1		EQU	17	; ボタン横位置
BTN_X2		EQU	17+4	;
BTN_X3		EQU	17+4*2	;
BTN_X4		EQU	17+4*3	;
BTN_X5		EQU	17+4*4	;
BTN_X6		EQU	17+4*5	;
BTN_X7		EQU	17+4*6	;
BTN_X8		EQU	17+4*7	;
BTN_X9		EQU	17+4*8	;
BTN_X10		EQU	17+4*9	;
BTN_X11		EQU	17+4*10	;
BTN_X12		EQU	17+4*11	;
BTN_XE		EQU	17+4*12	;
	
BTN_Y1		EQU	210		; ボタン高さ
BTN_Y6		EQU	210+20*5	;


FUNC_TOP	EQU	61	; ボタン番号／ファンクション先頭
FUNC_NEXT	EQU	61	; ボタン番号／ＮＥＸＴボタン
FUNC_BS		EQU	62	; ボタン番号／ＢＳボタン
FUNC_MAX	EQU	62	; ボタン番号／ボタン最後

BTN_OFSET_X	EQU	0	; キートップＸオフセット
BTN_OFSET_FX	EQU	0	; キートップＸＦＵＮＣオフセット
BTN_OFSET_Y	EQU	0	; キートップＹオフセット

FONTCOL		EQU	0	; 台詞カラー
FONTCOLF	EQU	9	; 台詞カラー・ふち
FONTCOLGL	EQU	7	; 台詞カラー・ゴールド１段
FONTCOLG	EQU	12	; 台詞カラー・ゴールド
FONTCOLGH	EQU	14	; 台詞カラー・ゴールドハイライト
BACKCOL		EQU	10	; 背景カラー


CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

; ****************************************************
;	WINDOWS/名前ウインドウ全表示
;	-I- AX : 0=最初,1=キャンセルで戻ってきた
;	-O- AX : 0=通常,1=スキップ
;	    NAME_FIRST      : ファーストネーム
;	    NAME_SECOND     : ファミリーネーム
;	    LEN_NAME_FIRST  : ファーストネーム長さ
;	    LEN_NAME_SECOND : ファミリーネーム長さ
; ****************************************************

FUNC	WIDNAME_SET
	CMP	AX,1			; 1=キャンセルで戻ってきた
	JMPEQ	WIDNAME_SET_333		;

	; (2) ボタン

	CALL	WIDNAME_OPEN		; ウインドウＯＰＥＮ

	; (3) ジワー

	MOV	AX,14			;名前入力・父
	MOV	BX,0			;テーブル番号
	CALLE	PT_PALET_SETONLY	;パレットテーブルセットのみ

	CALLE	FEDIN			;Ｆ・Ｉ（フェードイン）

WIDNAME_SET_1:				;

	; (4) 入力セット

	MOV	SCRN_MSG,1		;"family name（あなたの名字）"
	CALL	SCREEN_PRINT		; スクリーンＰＲＩＮＴ

WIDNAME_SET_2:				;

	; (4-1) 名前消し

	CALL	NAME_CLEAR		; 名前クリア

	CALLE	MSCSRT			; カーソルスタート
	CALL	WIDPNL_SELECT		; パネル・ウインドウ選択指定
	PUSH	AX			;
	CALLE	MSCSTP			;
	POP	AX			;
	CMP	AX,1			; 1=スキップ
	JMPEQ	WIDNAME_SET_SKIP	;
	CMP	AX,2			; 2=キャンセル
	JE	WIDNAME_SET_2		;
	CALL	FAMILY_NAME_SET		; ファミリーネームセット

	; (5) 名前消し

	MOV	SCREEN_LINE,0		; スクリーン行
	MOV	SCREEN_STR_X,NAME_SCRN_X	; 名前入力ｽｸﾘｰﾝ文字Ｘ
	MOV	SCREEN_STR_Y,NAME_SCRN_Y	; 名前入力ｽｸﾘｰﾝ文字Ｙ
	CALL	SCRN_MSG_CLEAR		; スクリーンメッセージクリア

	; (6) カラーＯＬ

	MOV	AX,1			; 1=父->娘,2=娘->父
	CALL	COLOR_OL		; カラーＯＬ

	JMP	WIDNAME_SET_444		;

WIDNAME_SET_333:			;
	CALL	WIDNAME_OPEN		; ウインドウＯＰＥＮ
WIDNAME_SET_444:			;

	; (7) 娘の名前

	MOV	SCRN_MSG,2		;"girl's name（むすめのなまえ）"
	CALL	SCREEN_PRINT		; スクリーンＰＲＩＮＴ
	CALLE	MSCSRT			; カーソルスタート
	CALL	WIDPNL_SELECT		; パネル・ウインドウ選択指定
	PUSH	AX			;
	CALLE	MSCSTP			;
	POP	AX			;
	CMP	AX,2			; 2=キャンセル
	JNE	WIDNAME_SET_55		;

	; (7-2) キャンセルカラーＯＬ

	MOV	AX,2			; 1=父->娘,2=娘->父
	CALL	COLOR_OL		; カラーＯＬ

	JMP	WIDNAME_SET_1		;

WIDNAME_SET_55:				;
	CALL	GIRLS_NAME_SET		; ファーストネームセット

	CALL	WIDNAME_CLOSE		; ウインドウＣＬＯＳＥ
	MOV	AX,0			; 0=通常
	RET
WIDNAME_SET_SKIP:
	CALLE	MSCSTP			;
	MOV	AX,1			; 1=スキップ
	RET
FEND	WIDNAME_SET


; ****************************************************
;	WINDOWS/名前ウインドウ・カラーＯＬ
;	-I- AX : 1=父->娘,2=娘->父
; ****************************************************

FUNC	WIDNAME_COLOR_OL
	CALL	COLOR_OL		; カラーＯＬ
	RET
FEND	WIDNAME_COLOR_OL


; ****************************************************
;	カラーＯＬ
;	-I- AX : 1=父->娘,2=娘->父
; ****************************************************

COLOR_OL	PROC	NEAR
	CMP	AX,2			;1=父->娘,2=娘->父
	JE	COLOR_OL_2		;
COLOR_OL_1:
	MOV	AX,14			;名前入力・父
	MOV	BX,2			;テーブル番号
	CALLE	PT_PALET_SETONLY	;パレットテーブルセットのみ
	MOV	AX,15			;名前入力・娘
	MOV	BX,0			;テーブル番号
	CALLE	PT_PALET_SETONLY	;パレットテーブルセットのみ
	JMP	COLOR_OL_4		;
COLOR_OL_2:
	MOV	AX,15			;名前入力・娘
	MOV	BX,2			;テーブル番号
	CALLE	PT_PALET_SETONLY	;パレットテーブルセットのみ
	MOV	AX,14			;名前入力・父
	MOV	BX,0			;テーブル番号
	CALLE	PT_PALET_SETONLY	;パレットテーブルセットのみ
COLOR_OL_4:

	MOV	AX,2			; オーバラップ開始パレットテーブル番号
	MOV	BX,0			; オーバラップ終了パレットテーブル番号
	CALLE	PLTOLS			; パレット・オーバラップ／時分割初期
	MOV	AX,60*1			;
	CALLE	TMVWAT			; V-SYNC timer wait.
	MOV	CX,22			;
COLOR_OL_LOOP:				;
	PUSH	CX			;
	MOV	AX,1			;
	CALLE	TMVWAT			; V-SYNC timer wait.
	CALLE	PLTOLT			; パレット・オーバラップ／時分割処理
	POP	CX			;
	LOOP	COLOR_OL_LOOP		;
	RET
COLOR_OL	ENDP


; ****************************************************
;	WINDOWS/名前ウインドウ文字列表示
;	-I- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.
; ****************************************************

FUNC	WIDNAME_PRINT
	CALL	STRING_PUT		; 文字列の表示
	RET
FEND	WIDNAME_PRINT


; ****************************************************
;	WINDOWS/名前ウインドウ文字列ＧＯＬＤ
;	-I- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.
; ****************************************************

FUNC	WIDNAME_PRINTG
	CALL	STRING_PUTG		; 文字列の表示・ＧＯＬＤ
	RET
FEND	WIDNAME_PRINTG


; ****************************************************
;	WINDOWS/名前ウインドウ・メッセージ
;	-I- DX : スクリーンメッセージ番号
; ****************************************************

FUNC	WIDNAME_MESSAGE
	MOV	SCRN_MSG,DX		; スクリーンメッセージ番号
	CALL	SCREEN_PRINT		; スクリーンＰＲＩＮＴ
	RET
FEND	WIDNAME_MESSAGE


; ****************************************************
;	WINDOWS/名前ウインドウ･ｶﾚﾝﾀﾞﾒｯｾｰｼﾞ
;	-I- DX : スクリーンメッセージ番号
; ****************************************************

FUNC	WIDNAME_M_CLENDR
	MOV	SCRN_MSG,DX			; スクリーンメッセージ番号

	MOV	SCREEN_LINE,0			; スクリーン行
	MOV	SCREEN_STR_X,BROTH_SCRN_X	; 誕生日入力ｽｸﾘｰﾝ文字Ｘ
	MOV	SCREEN_STR_Y,BROTH_SCRN_Y	; 誕生日入力ｽｸﾘｰﾝ文字Ｙ
	CALL	SCRN_MSG_CLEAR			; スクリーンメッセージクリア

	CALL	SCREEN_PRIN2			; スクリーンＰＲＩＮＴ２
	RET
FEND	WIDNAME_M_CLENDR


; ****************************************************
;	ウインドウＯＰＥＮ
; ****************************************************

WIDNAME_OPEN	PROC	NEAR
	CALL	ALL_MES_CLEAR		; メッセージ全体クリア
	CALL	BOTTAN_PUTS		; ボタンＰＵＴ
	RET
WIDNAME_OPEN	ENDP


; ****************************************************
;	ウインドウＣＬＯＳＥ
; ****************************************************

WIDNAME_CLOSE	PROC	NEAR
	RET
WIDNAME_CLOSE	ENDP



; ****************************************************
;	パネル・ウインドウ選択指定
;	-I- SCRN_MSG   : スクリーンメッセージ番号(１のとき＋スキップ出来る技)
;	-O- SSLINE_BUF : 名前バッファ
;	    SSLINE_LEN : 名前バッファ文字長さ
;	    AX         : 0=通常,1=スキップ,2=キャンセル
; ****************************************************

WIDPNL_SELECT	PROC	NEAR
	MOV	AX,0			; カーソル現在位置
	CALL	NAME_CUR_SET		; 名前カーソルセット

	MOV	NOW_BOTTAN,OFFF		; 現在ボタン番号
WIDPNL_SELECT_RETRY:			;
;*;	CALLE	MSCWAT			; カーソルボタンＯＦＦ待ち

	MOV	MOUSEFLAG,OFFF		; マウスＯＮ／ＯＦＦフラグ
	MOV	SSLINE_LEN,0		; 名前バッファ文字長さ
WIDPNL_SELECT_LOOP:			;
	CMP	SCRN_MSG,1		; (１のとき＋スキップ出来る技)
	JNE	WIDPNL_SELECT_01	;
	CALLE	KEYTEN			; キーボード・読み込み
	CMP	BX,3			; 3=PLUS,4=ESC (-1:押していない)
	JNE	WIDPNL_SELECT_01	;
	JMP	WIDPNL_SELECT_ENDSKIP	;
WIDPNL_SELECT_01:			;

	CALLE	MSCMOV			; カーソル移動
	CMP	DL,1			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WIDPNL_SELECT_1		;
	JMP	WIDPNL_SELECT_CANCEL	;
WIDPNL_SELECT_1:			;
	CMP	DH,1			; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WIDPNL_SELECT_2		;
	JMP	WIDPNL_SELECT_ON	;
WIDPNL_SELECT_2:			;
	MOV	MOUSEX,AX		; マウスＸ
	MOV	MOUSEY,BX		; マウスＹ

	MOV	MOUSEFLAG,OFFF		; マウスＯＮ／ＯＦＦフラグ

	CALL	BOTTAN_PIC		; ボタンピック
	CMP	AX,1			; 1=見つかった,0=見つからない
	JE	WIDPNL_SELECT_CHK	;

	CMP	NOW_BOTTAN,OFFF		; 現在ボタン番号
	JE	WIDPNL_SELECT_SKIP0	;
	MOV	AX,NOW_BOTTAN		; 現在ボタン番号
	MOV	BTNNUMBER,AX		; ボタン番号
	CALLE	MSCSTP			; カーソルストップ
	CALL	BTN_OFF			; ボタンＯＦＦ
	CALLE	MSCSRT			; カーソルスタート
WIDPNL_SELECT_SKIP0:			;
	MOV	NOW_BOTTAN,OFFF		; 現在ボタン番号

	JMP	WIDPNL_SELECT_NEXT	;

WIDPNL_SELECT_CHK:			;
	MOV	AX,NOW_BOTTAN		; 現在ボタン番号
	CMP	AX,BTNNUMBER		; ボタン番号
	JE	WIDPNL_SELECT_NEXT	;

	CALLE	MSCSTP			; カーソルストップ

	CMP	NOW_BOTTAN,OFFF		; 現在ボタン番号
	JE	WIDPNL_SELECT_SKIP	;
	PUSH	BTNNUMBER		; ボタン番号
	MOV	AX,NOW_BOTTAN		; 現在ボタン番号
	MOV	BTNNUMBER,AX		; ボタン番号
	CALL	BTN_OFF			; ボタンＯＦＦ
	POP	BTNNUMBER		; ボタン番号
WIDPNL_SELECT_SKIP:			;

	CALL	BTN_ON			; ボタンＯＮ

	CALLE	MSCSRT			; カーソルスタート

	MOV	AX,BTNNUMBER		; ボタン番号
	MOV	NOW_BOTTAN,AX		; 現在ボタン番号

	JMP	WIDPNL_SELECT_NEXT	;

WIDPNL_SELECT_ON:			;
	CMP	MOUSEFLAG,OFFF		; マウスＯＮ／ＯＦＦフラグ
	JNE	WIDPNL_SELECT_NEXT	;

	MOV	MOUSEFLAG,0		; マウスＯＮ／ＯＦＦフラグ

	CALL	NAME_EDIT		; 名前編集

	CMP	BTNNUMBER,FUNC_NEXT	; ボタン番号／ＮＥＸＴボタン
	JE	WIDPNL_SELECT_EXIT	;
WIDPNL_SELECT_NEXT:			;

	JMP	WIDPNL_SELECT_LOOP	;
WIDPNL_SELECT_EXIT:			;

	CALL	WID_CHECK		; 禁則チェック
	CMP	AX,0			; 0=ＯＫ,1=駄目
	JE	WIDPNL_SELECT_EXIT2	;
	JMP	WIDPNL_SELECT_RETRY	;
WIDPNL_SELECT_EXIT2:			;
	CALLE	MSCSTP			; カーソルストップ
	CALL	BTN_OFF			; ボタンＯＦＦ
	CALLE	MSCSRT			; カーソルスタート

	MOV	AX,0			; 0=通常
	RET
WIDPNL_SELECT_ENDSKIP:			;
	MOV	AX,1			; 1=スキップ
	RET
WIDPNL_SELECT_CANCEL:			;
	CALLE	MSCSTP			; カーソルストップ
	CALL	BTN_OFF			; ボタンＯＦＦ
	CALLE	MSCSRT			; カーソルスタート
	MOV	AX,2			; 2=キャンセル
	RET
WIDPNL_SELECT	ENDP


; ****************************************************
;	ボタンピック
;	-I- MOUSEX    : マウスＸ
;	    MOUSEY    : マウスＹ
;	-O- AX        : 1=見つかった,0=見つからない
;	    BTNNUMBER : ボタン番号
;	    BTNX      : ボタンＸ
;	    BTNY      : ボタンＹ
; ****************************************************

BOTTAN_PIC	PROC	NEAR
	MOV	AX,MOUSEX		; マウスＸ
	MOV	BX,MOUSEY		; マウスＹ

	CMP	BX,BTN_Y6		;
	JL	BOTTAN_PIC02		;
	JMP	BOTTAN_PIC_CDAN		; 中段
BOTTAN_PIC02:				;

	CMP	AX,BTN_X1		; ボタン横位置
	JGE	BOTTAN_PIC3		;
	JMP	BOTTAN_PIC_NOT_FOUND	;
BOTTAN_PIC3:				;
	CMP	AX,BTN_X2		;
	JGE	BOTTAN_PIC31		;
	MOV	BTNNUMBER,1		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;
BOTTAN_PIC31:				;
	CMP	AX,BTN_X3		;
	JGE	BOTTAN_PIC32		;
	MOV	BTNNUMBER,6		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;
BOTTAN_PIC32:				;
	CMP	AX,BTN_X4		;
	JGE	BOTTAN_PIC33		;
	MOV	BTNNUMBER,11		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;
BOTTAN_PIC33:				;
	CMP	AX,BTN_X5		;
	JGE	BOTTAN_PIC34		;
	MOV	BTNNUMBER,16		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;
BOTTAN_PIC34:				;
	CMP	AX,BTN_X6		;
	JGE	BOTTAN_PIC35		;
	MOV	BTNNUMBER,21		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;
BOTTAN_PIC35:				;
	CMP	AX,BTN_X7		;
	JGE	BOTTAN_PIC36		;
	MOV	BTNNUMBER,26		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;
BOTTAN_PIC36:				;
	CMP	AX,BTN_X8		;
	JGE	BOTTAN_PIC37		;
	MOV	BTNNUMBER,31		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;
BOTTAN_PIC37:				;
	CMP	AX,BTN_X9		;
	JGE	BOTTAN_PIC38		;
	MOV	BTNNUMBER,36		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;
BOTTAN_PIC38:				;
	CMP	AX,BTN_X10		;
	JGE	BOTTAN_PIC39		;
	MOV	BTNNUMBER,41		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;
BOTTAN_PIC39:				;
	CMP	AX,BTN_X11		;
	JNBE	BOTTAN_PIC40		;
	MOV	BTNNUMBER,46		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;
BOTTAN_PIC40:				;
	CMP	AX,BTN_X12		;
	JNBE	BOTTAN_PIC41		;
	MOV	BTNNUMBER,51		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;
BOTTAN_PIC41:				;
	CMP	AX,BTN_XE		;
	JNBE	BOTTAN_PIC_NOT_FOUND	;
	MOV	BTNNUMBER,56		; ボタン番号
	JMP	BOTTAN_PIC_SCH		;

BOTTAN_PIC_CDAN:			; 中段
	MOV	BTNNUMBER,FUNC_TOP	; ボタン番号／ファンクション先頭
	JMP	BOTTAN_PIC_SCH		;


BOTTAN_PIC_SCH:				;
	MOV	CX,5			;
BOTTAN_PIC_LOOP:			;
	CMP	BTNNUMBER,FUNC_MAX	; ボタン番号／ボタン最後
	JNBE	BOTTAN_PIC_NOT_FOUND	;
	PUSH	CX			;
	CALL	BTN_LOC_CMP		; ボタンロケーション比較
	POP	CX			;
	CMP	AX,1			; 1=一致する,0=一致しない
	JE	BOTTAN_PIC_NOT_OK	;
	INC	BTNNUMBER		; ボタン番号
	LOOP	BOTTAN_PIC_LOOP		;

	JMP	BOTTAN_PIC_NOT_FOUND	;

BOTTAN_PIC_NOT_OK:
	MOV	AX,1			; 1=見つかった
	RET				;
BOTTAN_PIC_NOT_FOUND:
	MOV	BTNNUMBER,0		; ボタン番号
	MOV	AX,0			; 0=見つからない
	RET				;
BOTTAN_PIC	ENDP


; ****************************************************
;	ボタンロケーション比較
;	-I- BTNNUMBER : ボタン番号
;	    MOUSEX    : マウスＸ
;	    MOUSEY    : マウスＹ
;	-O- AX        : 1=一致する,0=一致しない
;	    BTNX      : ボタンＸ
;	    BTNY      : ボタンＹ
; ****************************************************

BTN_LOC_CMP	PROC	NEAR
	CALL	BTN_LOC			; ボタンロケーション計算
	MOV	AX,BTNX			; ボタンＸ
	MOV	BX,BTNY			; ボタンＹ
	MOV	CX,AX			; X
	MOV	DX,BX			; Y
	ADD	CX,BTNXSZ		; ボタンサイズＸ
	ADD	DX,BTNYSZ		; ボタンサイズＹ
	DEC	CX			; 横間隔
	DEC	DX			; 高さ間隔

	CMP	MOUSEX,AX		; マウスＸ
	JB	BTN_LOC_CMP_NON		;
	CMP	MOUSEX,CX		; マウスＸ
	JNBE	BTN_LOC_CMP_NON		;

	CMP	MOUSEY,BX		; マウスＹ
	JB	BTN_LOC_CMP_NON		;
	CMP	MOUSEY,DX		; マウスＹ
	JNBE	BTN_LOC_CMP_NON		;
BTN_LOC_CMP_EQ:
	MOV	AX,1			; 1=一致する
	RET				;
BTN_LOC_CMP_NON:
	MOV	AX,0			; 0=一致しない
	RET				;
BTN_LOC_CMP	ENDP


; ****************************************************
;	名前カーソルセット
;	-I- AX : カーソル現在位置
; ****************************************************

NAME_CUR_SET	PROC	NEAR
	MOV	CURSOLE_NOW,AX		; カーソル現在位置
	MOV	CURSOLE_FLAG,0		; カーソルＯＮ／ＯＦＦ
	RET
NAME_CUR_SET	ENDP


; ****************************************************
;	スクリーンＰＲＩＮＴ
;	-I- SCRN_MSG : スクリーンメッセージ番号
; ****************************************************

SCREEN_PRINT	PROC	NEAR
	MOV	SCREEN_LINE,1			; スクリーン行
	MOV	SCREEN_STR_X,NAME_SCRN_X	; 名前入力ｽｸﾘｰﾝ文字Ｘ
	MOV	SCREEN_STR_Y,NAME_SCRN_Y	; 名前入力ｽｸﾘｰﾝ文字Ｙ
	CALL	SCRN_MSG_CLEAR			; スクリーンメッセージクリア

	CALL	SCREEN_PRIN2			; スクリーンＰＲＩＮＴ２
	RET
SCREEN_PRINT	ENDP


; ****************************************************
;	スクリーンＰＲＩＮＴ２
;	-I- SCRN_MSG    : スクリーンメッセージ番号
;	    SCREEN_LINE : スクリーン行
;	    SCREEN_STR_X: スクリーン文字Ｘ
;	    SCREEN_STR_Y: スクリーン文字Ｙ
; ****************************************************

SCREEN_PRIN2	PROC	NEAR
	MOV	BX,SCRN_MSG		; スクリーンメッセージ番号
	SHL	BX,1			; word pointer.
	MOV	SI,DS:SCRN_MSG_TABLE[BX] ; スクリーンメッセージテーブル

	LODSW				;
	MOV	WORD PTR SCREEN_CHR,AX	; スクリーンＰＵＴキャラクタ
	MOV	DX,SCREEN_STR_X		; スクリーン文字Ｘ

	MOV	AX,SCREEN_LINE		; スクリーン行
	MOV	BL,24			;
	IMUL	BL			; AL=AL*BL
	ADD	AX,SCREEN_STR_Y		; スクリーン文字Ｙ
	MOV	BX,AX			; Y.

SCREEN_PRIN2_LOOP:			;
	PUSH	DX			;
	PUSH	BX			;
	PUSH	SI			;

	MOV	AX,DX			; X.
	MOV	SI,OFFSET SCREEN_CHR	; スクリーンＰＵＴキャラクタ
	CALL	STRING_PUT		; 文字列の表示

	POP	SI			;
	POP	BX			;
	POP	DX			;
	ADD	DX,2			; X=X+2
	LODSW				;
	MOV	WORD PTR SCREEN_CHR,AX	; スクリーンＰＵＴキャラクタ
	CMP	AL,0			;
	JNE	SCREEN_PRIN2_LOOP	;

	RET
SCREEN_PRIN2	ENDP


; ****************************************************
;	ボタンＰＵＴ
; ****************************************************

BOTTAN_PUTS	PROC	NEAR
	MOV	BTNNUMBER,1		; ボタン番号

	MOV	CX,FUNC_MAX		; ボタン番号／ボタン最後
BOTTAN_PUTS_LOOP:			;
	PUSH	CX			;

	CALL	BTN_OFF			; ボタンＯＦＦ
	INC	BTNNUMBER		; ボタン番号

	POP	CX			;
	LOOP	BOTTAN_PUTS_LOOP	;

	RET
BOTTAN_PUTS	ENDP


; ****************************************************
;	ボタンＯＦＦ
;	-I- BTNNUMBER : ボタン番号
; ****************************************************

BTN_OFF	PROC	NEAR
	CALL	BTN_LOC			; ボタンロケーション計算
	CALL	BTN_KTOPB		; ボタン・キートップＰＵＴ影付き
	RET
BTN_OFF	ENDP


; ****************************************************
;	ボタンＯＮ
;	-I- BTNNUMBER : ボタン番号
; ****************************************************

BTN_ON	PROC	NEAR
	CALL	BTN_LOC		; ボタンロケーション計算
	CALL	BTN_KTOPB_ON	; ボタン・キートップＰＵＴ影付き／ＯＮ
	RET
BTN_ON	ENDP


; ****************************************************
;	ボタン・キートップＰＵＴ影付き
;	-I- BTNNUMBER : ボタン番号
;	    BTNX      : ボタンＸ
;	    BTNY      : ボタンＹ
; ****************************************************

BTN_KTOPB	PROC	NEAR
	CALL	BTN_CHAR		; ボタン・キャラクタ

	MOV	AX,BTNX      		; ボタンＸ
	MOV	BX,BTNY			; ボタンＹ

	CMP	BTNNUMBER,FUNC_TOP	; ボタン番号／ファンクション先頭
	JGE	BTN_KTOPB2		;
	ADD	AX,BTN_OFSET_X		; キートップＸオフセット
	JMP	BTN_KTOPB21		;
BTN_KTOPB2:				;
	ADD	AX,BTN_OFSET_FX		; キートップＸＦＵＮＣオフセット
BTN_KTOPB21:
	ADD	BX,BTN_OFSET_Y		; キートップＹオフセット

	MOV	SI,OFFSET SSETA_CHAR	; 入力キャラクタ
	CALL	STRING_PUT		; 文字列の表示
	RET
BTN_KTOPB	ENDP


; ****************************************************
;	ボタン・キートップＰＵＴ影付き／ＯＮ
;	-I- BTNNUMBER : ボタン番号
;	    BTNX      : ボタンＸ
;	    BTNY      : ボタンＹ
; ****************************************************

BTN_KTOPB_ON	PROC	NEAR
	CALL	BTN_CHAR		; ボタン・キャラクタ

	MOV	AX,BTNX      		; ボタンＸ
	MOV	BX,BTNY			; ボタンＹ

	CMP	BTNNUMBER,FUNC_TOP	; ボタン番号／ファンクション先頭
	JGE	BTN_KTOPB_ON2		;
	ADD	AX,BTN_OFSET_X		; キートップＸオフセット
	JMP	BTN_KTOPB_ON21		;
BTN_KTOPB_ON2:				;
	ADD	AX,BTN_OFSET_FX		; キートップＸＦＵＮＣオフセット
BTN_KTOPB_ON21:
	ADD	BX,BTN_OFSET_Y		; キートップＹオフセット

	MOV	SI,OFFSET SSETA_CHAR	; 入力キャラクタ
	CALL	STRING_PUTG		; 文字列の表示・ＧＯＬＤ
	RET
BTN_KTOPB_ON	ENDP




; ****************************************************
;	文字列の表示
;	-i- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.
; ****************************************************

STRING_PUT	PROC	NEAR
	MOV	STRN_XX,AX		; 文字Ｘ
	MOV	STRN_YY,BX		; 文字Ｙ
	MOV	STRN_ADRS,SI		; 文字アドレス

	MOV	AX,FONTSIZ		; フォントサイズ
	CALLE	VTXSIZ			; character size set.

	MOV	AX,FONTCOLF		; 台詞カラー・ふち
	CALLE	VTXCOL			; character color set.
	MOV	AX,STRN_XX		; 文字Ｘ
	MOV	BX,STRN_YY		; 文字Ｙ
	ADD	BX,2			; 文字Ｙ
	MOV	SI,STRN_ADRS		; 文字アドレス
	CALLE	VTXPOR			; vram text print OR.

	MOV	AX,FONTCOL		; 台詞カラー
	CALLE	VTXCOL			; character color set.
	MOV	AX,STRN_XX		; 文字Ｘ
	MOV	BX,STRN_YY		; 文字Ｙ
	MOV	SI,STRN_ADRS		; 文字アドレス
	CALLE	VTXPOR			; vram text print OR.
	MOV	AX,STRN_XX		; 文字Ｘ
	MOV	BX,STRN_YY		; 文字Ｙ
	ADD	BX,1			; 文字Ｙ
	MOV	SI,STRN_ADRS		; 文字アドレス
	CALLE	VTXPOR			; vram text print OR.

	RET
STRING_PUT	ENDP


; ****************************************************
;	文字列の表示・ＧＯＬＤ
;	-i- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.
; ****************************************************

STRING_PUTG	PROC	NEAR
	MOV	STRN_XX,AX		; 文字Ｘ
	INC	BX			;
	MOV	STRN_YY,BX		; 文字Ｙ
	MOV	STRN_ADRS,SI		; 文字アドレス

	CALL	STRXLEN			; string length.
	MOV	STRN_LEN,CX		; 文字長さ

	MOV	AX,STRN_XX		; 文字Ｘ
	MOV	BX,STRN_YY		; 文字Ｙ
	DEC	BX			;-1
	MOV	VX1,AX
	MOV	VY1,BX
	ADD	AX,2-1
	ADD	BX,20-1
	MOV	VX2,AX
	MOV	VY2,BX
	MOV	CX,BACKCOL		; 台詞カラー
	CALLE	BOXPAL			; ＢＯＸペイント

	MOV	SI,STRN_ADRS		; 文字アドレス
	MOV	AX,WORD PTR KNJ_SPC	; 漢字スペース
	CMP	DS:[SI],AX		; 漢字スペース
	JMPEQ	STRING_PUTG_BRNK	;

	MOV	AX,FONTSIZ		; フォントサイズ
	CALLE	VTXSIZ			; character size set.

	; (1) ノーマル部分

	MOV	AX,FONTCOLGH		; 台詞カラー・ゴールドハイライト
	CALLE	VTXCOL			; character color set.
	MOV	AX,STRN_XX		; 文字Ｘ
	MOV	BX,STRN_YY		; 文字Ｙ
	INC	BX			;
	MOV	SI,STRN_ADRS		; 文字アドレス
	CALLE	VTXPOR			; vram text print OR.

	MOV	AX,FONTCOLGL		; 台詞カラー・ゴールド１段
	CALLE	VTXCOL			; character color set.
	MOV	AX,STRN_XX		; 文字Ｘ
	MOV	BX,STRN_YY		; 文字Ｙ
	DEC	BX			;
	MOV	SI,STRN_ADRS		; 文字アドレス
	CALLE	VTXPOR			; vram text print OR.

	MOV	AX,FONTCOLG		; 台詞カラー・ゴールド
	CALLE	VTXCOL			; character color set.
	MOV	AX,STRN_XX		; 文字Ｘ
	MOV	BX,STRN_YY		; 文字Ｙ
	MOV	SI,STRN_ADRS		; 文字アドレス
	CALLE	VTXPOR			; vram text print OR.

	JMP	STRING_PUTG_EXIT
STRING_PUTG_BRNK:

STRING_PUTG_EXIT:
	RET
STRING_PUTG	ENDP


; ****************************************************
;	ボタンロケーション計算
;	-I- BTNNUMBER : ボタン番号
;	-O- BTNX      : ボタンＸ
;	    BTNY      : ボタンＹ
;	    BTNXSZ    : ボタンサイズＸ
;	    BTNYSZ    : ボタンサイズＹ
; ****************************************************

BTN_LOC	PROC	NEAR
	CMP	BTNNUMBER,FUNC_TOP	; ボタン番号／ファンクション先頭
	JGE	BTN_LOC_55		;

	MOV	AX,BTNNUMBER		; ボタン番号
	DEC	AX			; AX=AX-1
	CWD				;
	MOV	BX,5			; 縦に５個ずつ並んでいる
	IDIV	BX			; AX=AX/BX  DX=AX MOD BX

	MOV	BL,WIDTH_X		; x 横間隔　横は何列目か？
	IMUL	BL			; AX=AL*BL

	ADD	AX,BTN_X1		; ボタン横位置
	MOV	BTNX,AX			; ボタンＸは求められた

	MOV	AX,DX			; 縦何段目か？
	MOV	BX,WIDTH_Y		; 高さ間隔
	CWD				;
	IMUL	BX			; AX=AX*BX
	ADD	AX,BTN_Y1		; ボタン高さ
	MOV	BTNY,AX			; ボタンＹは求められた

	MOV	BTNXSZ,BOTTON_X		; ボタン横サイズ
	MOV	BTNYSZ,BOTTON_Y		; ボタン縦サイズ

	JMP	BTN_LOC_99		;

BTN_LOC_55:				; 中段

	MOV	AX,BTNNUMBER		; ボタン番号
	SUB	AX,FUNC_TOP		; ボタン番号／ファンクション先頭
	MOV	BX,WIDTH_X_F		; ファンクション横間隔
	IMUL	BL			; AX=AX*BX
	ADD	AX,BTN_X1		; ボタン横位置
	MOV	BTNX,AX			; ボタンＸは求められた

	MOV	BTNY,BTN_Y6		; ボタン高さ

	MOV	BTNXSZ,BOTTON_X_F	; ファンクション横サイズ
	MOV	BTNYSZ,BOTTON_Y		; ボタン縦サイズ

	JMP	BTN_LOC_99		;

BTN_LOC_99:
	RET
BTN_LOC	ENDP


; ****************************************************
;	ボタン・キャラクタ
;	-I- BTNNUMBER  : ボタン番号
;	-O- SSETA_CHAR : 入力キャラクタ
; ****************************************************

BTN_CHAR	PROC	NEAR
	CMP	BTNNUMBER,FUNC_TOP	; ボタン番号／ファンクション先頭
	JGE	BTN_CHAR_FUNC		;

	CALL	BTN_CHAR2		; ボタン・キャラクタその２

	RET

BTN_CHAR_FUNC:
	MOV	BX,BTNNUMBER		; ボタン番号／ファンクション先頭
	SUB	BX,FUNC_TOP		; ボタン番号／ファンクション先頭
	SHL	BX,1			;
	MOV	SI,DS:FUNC_TOP_TABLE[BX] ; ファンクション
	MOV	AX,DS			;
	MOV	ES,AX			;
	MOV	DI,OFFSET SSETA_CHAR	; 入力キャラクタ
	MOV	CX,8			;
	REP	MOVSB			;
	MOV	WORD PTR SSETA_CHAR[8],0 ; 入力キャラクタ
	RET
BTN_CHAR	ENDP


; ****************************************************
;	ボタン・キャラクタその２
;	-I- BTNNUMBER  : ボタン番号
;	-O- SSETA_CHAR : 入力キャラクタ
; ****************************************************

BTN_CHAR2	PROC	NEAR
	MOV	BX,BTNNUMBER		; ボタン番号
	DEC	BX			; base.
	SHL	BX,1			; word pointer.
	MOV	AX,WORD PTR DS:BTN_TOP_TABLE[BX]
	MOV	WORD PTR SSETA_CHAR,AX	 ; 入力キャラクタ
	MOV	WORD PTR SSETA_CHAR[2],0 ; 入力キャラクタ
	RET
BTN_CHAR2	ENDP


; ****************************************************
;	名前プリント
;	・このプリントは最後の１文字のみＰＵＴします
;	-I- SSLINE_LEN : 名前バッファ文字長さ
;	    SSLINE_BUF : 名前バッファ
; ****************************************************

NAME_PRINT	PROC	NEAR
	MOV	BX,SSLINE_LEN		; 名前バッファ文字長さ
	CMP	BX,0			;
	JE	NAME_PRINT_EXIT		;

	DEC	BX			;
	DEC	BX			; - 2
	MOV	AX,WORD PTR DS:SSLINE_BUF[BX]	; 名前バッファ
	MOV	WORD PTR NAME_CHR,AX	; なまえキャラクタ(2byte)

	SHR	BX,1			; / 2
	MOV	NAME_NUM,BX		; なまえキャラ番号
	CALL	NAME_CHR_PUT		; 名前キャラＰＵＴ
NAME_PRINT_EXIT:			;
	RET
NAME_PRINT	ENDP


; ****************************************************
;	名前キャラＰＵＴ
;	-I- NAME_NUM : なまえキャラ番号
;	    NAME_CHR : なまえキャラクタ(2byte)
; ****************************************************

NAME_CHR_PUT	PROC	NEAR
	CALL	CHR_PUT			; キャラクタＰＵＴ
	RET
NAME_CHR_PUT	ENDP

; ****************************************************
;	キャラクタＰＵＴ
;	-I- NAME_NUM : なまえキャラ番号
;	    NAME_CHR : なまえキャラクタ(2byte)
; ****************************************************

CHR_PUT	PROC	NEAR
	MOV	BX,NAME_NUM		; なまえキャラ番号
	SHL	BX,1			; word pointer.
	MOV	DX,DS:NAME_X_LOC[BX]	;

	MOV	BX,NAME_NUM		; なまえキャラ番号
	SHL	BX,1			; word pointer.
	MOV	AX,DS:NAME_X_LOC[BX]	;
	MOV	BX,NAME_CHR_Y2		; 名前Ｙキャラ位置

	MOV	SI,OFFSET NAME_CHR	; なまえキャラクタ(2byte)
	CALL	STRING_PUTG		; 文字列の表示・ＧＯＬＤ

	RET
CHR_PUT	ENDP


; ****************************************************
;	名前クリア
; ****************************************************

NAME_CLEAR	PROC	NEAR
	MOV	VX1,18
	MOV	VY1,136
	MOV	VX2,60
	MOV	VY2,162
	MOV	CX,BACKCOL		; 台詞カラー
	CALLE	BOXPAL			; ＢＯＸペイント
	RET
NAME_CLEAR	ENDP


; ****************************************************
;	スクリーンメッセージクリア
;	-I- SCREEN_STR_X: スクリーン文字Ｘ
;	    SCREEN_STR_Y: スクリーン文字Ｙ
;	    SCREEN_LINE : スクリーン行
; ****************************************************

SCRN_MSG_CLEAR	PROC	NEAR
	MOV	AX,SCREEN_LINE		; スクリーン行
	MOV	BL,24			;
	IMUL	BL			; AL=AL*BL
	ADD	AX,SCREEN_STR_Y		; スクリーン文字Ｙ
	MOV	BX,AX			; Y.
	MOV	VY1,BX
	MOV	AX,SCREEN_STR_X		; スクリーン文字Ｘ
	MOV	VX1,AX
	ADD	AX,40
	ADD	BX,18
	MOV	VX2,AX
	MOV	VY2,BX
	MOV	CX,BACKCOL		; 台詞カラー
	CALLE	BOXPAL			; ＢＯＸペイント
	RET
SCRN_MSG_CLEAR	ENDP


; ****************************************************
;	名前ＢＳ
; ****************************************************

NAME_BS		PROC	NEAR
	SUB	SSLINE_LEN,2		; 名前バッファ文字長さ
	JGE	NAME_BS_2		;
	MOV	SSLINE_LEN,0		; 名前バッファ文字長さ
NAME_BS_2:				;

	MOV	AX,WORD PTR KNJ_SPC		; 名前バッファ
	MOV	BX,SSLINE_LEN			; 名前バッファ文字長さ
	MOV	WORD PTR DS:SSLINE_BUF[BX],AX	; 名前バッファ

	MOV	AX,SSLINE_LEN		; カーソル現在位置
	SHR	AX,1			;
	CALL	NAME_CUR_SET		; 名前カーソルセット


	MOV	AX,SSLINE_LEN		; カーソル現在位置
	SHR	AX,1			;
	MOV	NAME_NUM,AX		; なまえキャラ番号
	MOV	AX,WORD PTR KNJ_SPC	; 漢字スペース
	MOV	WORD PTR NAME_CHR,AX	; なまえキャラクタ(2byte)
	CALL	NAME_CHR_PUT		; 名前キャラＰＵＴ

	RET
NAME_BS		ENDP


; ****************************************************
;	ファミリーネームセット
;	-I- SSLINE_BUF      : 名前バッファ
;	    SSLINE_LEN      : 名前バッファ文字長さ
;	-O- LEN_NAME_SECOND : ファミリーネーム長さ
;	    NAME_SECOND     : ファミリーネーム
; ****************************************************

FAMILY_NAME_SET	PROC	NEAR
	MOV	CX,SSLINE_LEN		; 名前バッファ文字長さ
	MOV	LEN_NAME_SECOND,CX	; ファミリーネーム長さ

	MOV	SI,OFFSET SSLINE_BUF	; 名前バッファ
	MOV	AX,DS			;
	MOV	ES,AX			;
	MOV	DI,OFFSET NAME_SECOND	; ファミリーネーム
	REP	MOVSB			;
	MOV	AX,0			;
	STOSW				; end of string.


	; データベース

	RET
FAMILY_NAME_SET	ENDP


; ****************************************************
;	ファーストネームセット
;	-I- SSLINE_BUF : 名前バッファ
;	    SSLINE_LEN      : 名前バッファ文字長さ
;	-O- LEN_NAME_FIRST : ファーストネーム長さ
;	    NAME_FIRST     : ファーストネーム
; ****************************************************

GIRLS_NAME_SET	PROC	NEAR
	MOV	CX,SSLINE_LEN		; 名前バッファ文字長さ
	MOV	LEN_NAME_FIRST,CX	; ファーストネーム長さ

	MOV	SI,OFFSET SSLINE_BUF	; 名前バッファ
	MOV	AX,DS			;
	MOV	ES,AX			;
	MOV	DI,OFFSET NAME_FIRST	; ファーストネーム
	REP	MOVSB			;
	MOV	AX,0			;
	STOSW				; end of string.

	; データベース

	RET
GIRLS_NAME_SET	ENDP


; ****************************************************
;	名前編集
;	-I- NOW_BOTTAN : 現在ボタン番号
;	    BTNNUMBER  : ボタン番号
;	-O- SSETA_CHAR[] : 入力キャラクタ
; ****************************************************

NAME_EDIT	PROC	NEAR
	CMP	NOW_BOTTAN,OFFF		; 現在ボタン番号
	JNE	NAME_EDIT_START		;
	RET

NAME_EDIT_START:
	CMP	BTNNUMBER,FUNC_TOP	; ボタン番号／ファンクション先頭
	JE	NAME_EDIT_EXIT		;
	CMP	BTNNUMBER,FUNC_NEXT	; ボタン番号／ＮＥＸＴボタン
	JE	NAME_EDIT_EXIT		;

	CMP	BTNNUMBER,FUNC_BS	; ボタン番号／ＢＳボタン
	JNE	NAME_EDIT_22		;

	CALLE	MSCSTP			; カーソルストップ
	CALL	NAME_BS			; 名前ＢＳ
	CALLE	MSCSRT			; カーソルスタート

	JMP	NAME_EDIT_EXIT		;
NAME_EDIT_22:
	CALL	BTN_CHAR2		; ボタン・キャラクタその２
	CALL	CNV_DAK			; 濁点判定と処理

	CALLE	MSCSTP			; カーソルストップ
	CALL	NAME_PRINT		; 名前プリント
	CALLE	MSCSRT			; カーソルスタート

	MOV	AX,SSLINE_LEN		; カーソル現在位置
	SHR	AX,1			;
	CALL	NAME_CUR_SET		; 名前カーソルセット
NAME_EDIT_EXIT:
	RET
NAME_EDIT	ENDP



; ****************************************************
;	禁則チェック
;	-I- SSLINE_LEN : 名前バッファ文字長さ
;	    SSLINE_BUF : 名前バッファ
;	-O- AX         : 0=ＯＫ,1=駄目
; ****************************************************

WID_CHECK	PROC	NEAR
	CMP	SSLINE_LEN,0		; 名前バッファ文字長さ
	JNE	WID_CHECK_2		;

					; ”名前なし！”
	CALLE	MSCSTP			; カーソルストップ
	MOV	SCRN_MSG,4		; スクリーンメッセージ番号
	CALL	SCREEN_PRINT		; スクリーンＰＲＩＮＴ
	CALL	WID_NAME_CLEAR		; 名前クリア
	CALLE	MSCSRT			; カーソルスタート

	JMP	WID_CHECK_ERROR		;

WID_CHECK_2:
	CALL	WID_KINSOKU		; 禁則チェック・エッチ名前チェック
	CMP	AX,0			; 0=ＯＫ
	JE	WID_CHECK_OK		;

					; ”エッチ！”
	CALLE	MSCSTP			; カーソルストップ
	MOV	SCRN_MSG,5		; スクリーンメッセージ番号
	CALL	SCREEN_PRINT		; スクリーンＰＲＩＮＴ
	CALLE	MSCSRT			; カーソルスタート

	JMP	WID_CHECK_ERROR		;

WID_CHECK_OK:
	MOV	AX,0			; 0=ＯＫ
	RET
WID_CHECK_ERROR:
	MOV	AX,1			; 1=駄目
	RET
WID_CHECK	ENDP



; ****************************************************
;	名前クリア
; ****************************************************

WID_NAME_CLEAR	PROC	NEAR
	MOV	SSLINE_LEN,0		; 名前バッファ文字長さ

	MOV	AX,DS			;
	MOV	ES,AX			;
	MOV	AX,WORD PTR KNJ_SPC	; 名前バッファ
	MOV	CX,BUFFLEN/2		; 名前バッファ長さ
	MOV	DI,OFFSET SSLINE_BUF	; 名前バッファ
	REP	STOSW			;

	CALL	NAME_CLEAR		; 名前クリア

	MOV	AX,0			; カーソル現在位置
	CALL	NAME_CUR_SET		; 名前カーソルセット
	RET
WID_NAME_CLEAR	ENDP


; ****************************************************
;	禁則チェック・エッチ名前チェック
;	-I- SSLINE_LEN : 名前バッファ文字長さ
;	    SSLINE_BUF : 名前バッファ
;	-O- AX         : 0=ＯＫ,1=駄目
; ****************************************************

WID_KINSOKU	PROC	NEAR
	MOV	SI,OFFSET SSLINE_BUF	; 名前バッファ
	MOV	DI,OFFSET KINSOKU_TABLE	; 禁則の名前一覧(１バイト目は長さ)
	MOV	CX,SSLINE_LEN		; 名前バッファ文字長さ
WID_KINSOKU_2:
	MOV	AL,DS:[DI]		; 禁則の名前一覧(１バイト目は長さ)
	CBW				;
	INC	DI			;

	CMP	AX,-1			; データ終り？
	JE	WID_KINSOKU_OK		;

	CMP	AX,CX			; 長さは一緒か？
	JNE	WID_KINSOKU_4		;

	CALL	STRNCMP			; string compare.
	JE	WID_KINSOKU_ERROR	; cf,zf :comper set.

WID_KINSOKU_4:				;
	ADD	DI,AX			; 次の単語
	JMP	WID_KINSOKU_2		;

WID_KINSOKU_OK:
	MOV	AX,0			; 0=ＯＫ
	RET
WID_KINSOKU_ERROR:
	MOV	AX,1			; 1=駄目
	RET
WID_KINSOKU	ENDP


; ****************************************************
;	濁点判定と処理
;	-I-   SSETA_CHAR   : 入力キャラクタ
;	-I/O- SSLINE_LEN   : 名前バッファ文字長さ
;	      SSLINE_BUF[] : 名前バッファ
;	-O-   DX           : 2=通常,1=濁点変換した,0=エラー
; ****************************************************

CNV_DAK	PROC	NEAR
	MOV	DX,WORD PTR SSETA_CHAR		; DX=入力キャラクタ

	MOV	BX,SSLINE_LEN			  ;
	MOV	AX,WORD PTR DS:SSLINE_BUF[BX][-2] ; AX=１つ前のキャラクタ

	CMP	DX,WORD PTR KNJ_DAKU		; 濁点か？
	JNE	CNV_DAK_1			;

	CMP	SSLINE_LEN,0			; 名前バッファ文字長さ
	JE	CNV_DAK_NONE			;

	CALL	CNV_DAKUTEN			; 濁点変換
	CMP	DX,1				; 0=対象外,1=変換
	JE	CNV_DAK_OK			;

	JMP	CNV_DAK_NONE			;

CNV_DAK_1:
	CMP	DX,WORD PTR KNJ_HANDAKU		; 半濁点か？
	JNE	CNV_DAK_2

	CMP	SSLINE_LEN,0			; 名前バッファ文字長さ
	JE	CNV_DAK_NONE			;

	CALL	CNV_HANDAKU			; 半濁点変換
	CMP	DX,1				; 0=対象外,1=変換
	JE	CNV_DAK_OK			;

	JMP	CNV_DAK_NONE			;

CNV_DAK_2:
	MOV	AX,SSLINE_LEN			; 名前バッファ文字長さ
	CMP	AX,BUFFLEN			; 名前バッファ長さ
	JNB	CNV_DAK_NONE			;

	MOV	BX,SSLINE_LEN			; 名前バッファ文字長さ
	MOV	WORD PTR DS:SSLINE_BUF[BX],DX	; 名前バッファ
	MOV	AX,WORD PTR KNJ_SPC	; 名前バッファ
	MOV	WORD PTR DS:SSLINE_BUF[BX][2],AX

	ADD	SSLINE_LEN,2			; 名前バッファ文字長さ

	MOV	DX,2				; 2=通常
	RET

CNV_DAK_OK:
	MOV	BX,SSLINE_LEN			  ; 名前バッファ文字長さ
	MOV	WORD PTR DS:SSLINE_BUF[BX][-2],AX ; 名前バッファ

	MOV	DX,1				; 1=濁点変換した
	RET

CNV_DAK_NONE:
	MOV	DX,0				; 0=エラー
	RET
CNV_DAK	ENDP




; ****************************************************
;	濁点変換
;	-I- AX : 対象キャラクタ（漢字）
;	-O- AX : 変換キャラクタ
;	    DX : 0=対象外,1=変換
; ****************************************************

CNV_DAKUTEN	PROC	NEAR
	MOV	DX,DS
	MOV	ES,DX
	MOV	DI,OFFSET DAKUTEN_TBL	; カキクケコサシ・・・
	MOV	CX,21			; <=====
	REPNE	SCASW
	JNE	CNV_DAKUTEN_NONE

	SUB	DI,OFFSET DAKUTEN_TBL+2 ; カキクケコサシ・・・
	MOV	SI,DI			;
	ADD	SI,OFFSET DAKUTEN_TBLX	; ガギグゲゴザジ・・・
	LODSW				;

	MOV	DX,1			; 1=変換
	RET				;
CNV_DAKUTEN_NONE:
	MOV	DX,0			; 対象外
	RET				;
CNV_DAKUTEN	ENDP



; ****************************************************
;	半濁点変換
;	-I- AX : 対象キャラクタ（漢字）
;	-O- AX : 変換キャラクタ
;	    DX : 0=対象外,1=変換
; ****************************************************

CNV_HANDAKU	PROC	NEAR
	MOV	DX,DS
	MOV	ES,DX
	MOV	DI,OFFSET HANDAKU_TBL	; ハヒフヘホ
	MOV	CX,5			; <=====
	REPNE	SCASW
	JNE	CNV_HANDAKU_NONE

	SUB	DI,OFFSET HANDAKU_TBL+2	; ハヒフヘホ
	MOV	SI,DI			;
	ADD	SI,OFFSET HANDAKU_TBLX	; パピプペポ
	LODSW				;

	MOV	DX,1			; 1=変換
	RET				;
CNV_HANDAKU_NONE:
	MOV	DX,0			; 対象外
	RET				;
CNV_HANDAKU	ENDP


; ****************************************************
;	string length.
;	-i- SI : source string.
;	-o- CX : string length.
; ****************************************************

STRXLEN	PROC	NEAR
	PUSH	ES
	PUSH	AX
	PUSH	DI

	MOV	AX,DS
	MOV	ES,AX
	MOV	CX,256
	MOV	DI,SI
	MOV	AL,0
	REPNE	SCASB
	DEC	DI
	MOV	CX,DI
	SUB	CX,SI

	POP	DI
	POP	AX
	POP	ES
	RET
STRXLEN	ENDP



; ****************************************************
;	string compare.
;	-i- SI : source string.
;	    DI : immediate string.
;	    CX : string length.
;	-o- cf,zf :comper set.
; ****************************************************

STRNCMP	PROC	NEAR
	PUSH	ES
	PUSH	DI
	PUSH	SI
	PUSH	CX

	PUSH	DS
	POP	ES
	REPE	CMPSB

	POP	CX
	POP	SI
	POP	DI
	POP	ES
	RET
STRNCMP	ENDP


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

PUBLIC	NAME_FIRST			; ファーストネーム
PUBLIC	NAME_SECOND			; ファミリーネーム
PUBLIC	LEN_NAME_FIRST			; ファーストネーム長さ
PUBLIC	LEN_NAME_SECOND			; ファミリーネーム長さ

EXTRN	VX1:WORD			; point x1.
EXTRN	VY1:WORD			; point y1.
EXTRN	VX2:WORD			; point x2.
EXTRN	VY2:WORD			; point y2.

EXTRN	KNJ_SPC:BYTE			; 漢字スペース
EXTRN	BTN_TOP_TABLE:BYTE		; ﾎﾞﾀﾝﾃｰﾌﾞﾙ
EXTRN	KNJ_DAKU:BYTE			; 濁点
EXTRN	KNJ_HANDAKU:BYTE		; 半濁点
EXTRN	DAKUTEN_TBL:BYTE		; 濁点ﾃｰﾌﾞﾙ1
EXTRN	DAKUTEN_TBLX:BYTE		; 濁点ﾃｰﾌﾞﾙ2
EXTRN	HANDAKU_TBL:BYTE		; 半濁点ﾃｰﾌﾞﾙ1
EXTRN	HANDAKU_TBLX:BYTE		; 半濁点ﾃｰﾌﾞﾙ1
EXTRN	FUNC_TOP_TABLE:WORD		; ﾌｧﾝｸｼｮﾝﾃｰﾌﾞﾙ
EXTRN	KINSOKU_TABLE:WORD		; 禁則の名前一覧
EXTRN	SCRN_MSG_TABLE:WORD		; ｽｸﾘｰﾝﾒｯｾｰｼﾞﾃｰﾌﾞﾙ

NAME_FIRST	DB	BUFFLEN DUP (0),0,0	; ファーストネーム
NAME_SECOND	DB	BUFFLEN DUP (0),0,0	; ファミリーネーム
LEN_NAME_FIRST	DW	0			; ファーストネーム長さ
LEN_NAME_SECOND	DW	0			; ファミリーネーム長さ

SCREEN_CHR	DB	"  ",0,0	; スクリーンＰＵＴキャラクタ
SCREEN_LINE	DW	0		; スクリーン行
SCREEN_STR_X	DW	0		; スクリーン文字Ｘ
SCREEN_STR_Y	DW	0		; スクリーン文字Ｙ

SSLINE_LEN	DW	0		; 名前バッファ文字長さ
SSLINE_BUF	DB	"                ",0,0	; 名前バッファ
SSETA_CHAR	DB	"                ",0,0	; 入力キャラクタ

CURSOLE_NOW	DW	0		; カーソル現在位置
CURSOLE_FLAG	DW	0		; カーソルＯＮ／ＯＦＦ

MOUSEFLAG	DW	0		; マウスＯＮ／ＯＦＦフラグ
MOUSEX		DW	0		; マウスＸ
MOUSEY		DW	0		; マウスＹ

NAME_X_LOC	LABEL	WORD		;
		DW	NAME_CHR_X1	; 名前Ｘキャラ位置
		DW	NAME_CHR_X2	;
		DW	NAME_CHR_X3	;
		DW	NAME_CHR_X4	;
		DW	NAME_CHR_X5	;
		DW	NAME_CHR_X6	;
		DW	NAME_CHR_X7	;
		DW	NAME_CHR_X8	;

NAME_NUM	DW	0		; なまえキャラ番号
NAME_CHR	DB	"  ",0,0	; なまえキャラクタ

NOW_BOTTAN	DW	0		; 現在ボタン番号

BTNNUMBER	DW	0		; ボタン番号
BTNX		DW	0		; ボタンＸ
BTNY		DW	0		; ボタンＹ
BTNXSZ		DW	0		; ボタンサイズＸ
BTNYSZ		DW	0		; ボタンサイズＹ

SCRN_MSG	DW	0		; スクリーンメッセージ番号

STRN_XX		DW	0		; 文字Ｘ
STRN_YY		DW	0		; 文字Ｙ
STRN_ADRS	DW	0		; 文字アドレス
STRN_LEN	DW	0		; 文字長さ

CODE	ENDS

	END
;
;	end of "WIDNAME.ASM"
;
