; "WIDDATSL.ASM" 486/50 make by R.H 1993/03/02
;
;
;	データ選択ウインドウ
;
;
;	WIDDTSLC_OPEN		; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳOPEN
;	WIDDTSLC_CLOSE		; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳCLOSE
;	WIDDTSLC_PARASET	; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ項目セット
;	WIDDTSLC_PARASHOW	; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ項目表示
;	WIDDTSLC_HEADER		; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳﾍｯﾀﾞ表示
;	WIDDTSLC_SLCT		; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳSLCT
;	WIDDTSLC_PRINT		; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ文字表示
;	WIDDTSLC_SIDEM_LIN	; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ ｻｲﾄﾞﾒﾆｭｰ行数
;
;
;	データファイル番号
;		１から１０まで	データ
;		１１から	サイドメニュー
;
;
;	待避エリア
;		DW	PARTBUF_TOP		; #0
;		DW	VVVRAM_TOP+56530	; #3	 9,000byte
;
; (C)1993 ritsurou hashimoto.

INCLUDE	TSTSET.INC

WD_INI_BAK_BANK		EQU	0		; window エリア待避バンク番号
WD_INI_BAK_CURS		EQU	1		; window ｶｰｿﾙ待避バンク番号

NORMAL_BANK		EQU	0		; 通常のパーツバンク番号

WD_INI_X1		EQU	1		; window 左上Ｘ
WD_INI_Y1		EQU	146		; window 左上Ｙ
WD_INI_XL		EQU	45		; window サイズＸ
WD_INI_YL		EQU	251	;245	; window サイズＹ
WD_INI_OFS_X		EQU	2		; window 項目表示ｵﾌｾｯﾄX
WD_INI_OFS_Y		EQU	16	;14	; window 項目表示ｵﾌｾｯﾄY
WD_INI_HIGHT		EQU	20		; window １行高さ
WD_INI_CUROF_X		EQU	1		; window ｶｰｿﾙｵﾌｾｯﾄX
WD_INI_CUROF_Y		EQU	10	;8	; window ｶｰｿﾙｵﾌｾｯﾄY

WD_INI_H_OFS_DOT_X	EQU	12		; window 項目表ｵﾌｾｯﾄdotX
WD_INI_H_OFS_Y		EQU	12	;10	; window 項目表ｵﾌｾｯﾄY

WD_INI_NUMB_OFS_X	EQU	0		; window 番号位置
WD_INI_DATE_OFS_X	EQU	5		; window 日付位置
WD_INI_NAME_OFS_X	EQU	21		; window 名前位置

WD_INI_CUR_DOT_XL	EQU	294+49	; window ｶｰｿﾙｻｲｽﾞdotX
WD_INI_CUR_YL		EQU	24	; window ｶｰｿﾙｻｲｽﾞY
WD_INI_CUR_SD_DOT_XL	EQU	112	; window ｶｰｿﾙｻｲｽﾞdotX(ｻｲﾄﾞﾒﾆﾕｰ)
WD_INI_CUR_SD_YL	EQU	24	; window ｶｰｿﾙｻｲｽﾞY(ｻｲﾄﾞﾒﾆﾕｰ)

WD_INI_CUR_BAK_XL	EQU	44	; cursole back 待避ｻｲｽﾞx.
WD_INI_CUR_BAK_YL	EQU	30	; cursole back 待避ｻｲｽﾞy.
WD_INI_CUR_BAK_SD_XL	EQU	16	; cursole back 待避ｻｲｽﾞx(ｻｲﾄﾞﾒﾆﾕｰ)
WD_INI_CUR_BAK_SD_YL	EQU	30	; cursole back 待避ｻｲｽﾞy(ｻｲﾄﾞﾒﾆﾕｰ)

WD_INI_CUR_AREA_X	EQU	42	; cursole ｴﾘｱｻｲｽﾞx.
WD_INI_CUR_AREA_Y	EQU	20	; cursole ｴﾘｱｻｲｽﾞy.
WD_INI_CUR_AREA_SD_X	EQU	15	; cursole ｴﾘｱｻｲｽﾞx(ｻｲﾄﾞﾒﾆﾕｰ)
WD_INI_CUR_AREA_SD_Y	EQU	20	; cursole ｴﾘｱｻｲｽﾞy(ｻｲﾄﾞﾒﾆﾕｰ)

WD_INI_SD_X1		EQU	47		; sidemenu 左上Ｘ
WD_INI_SD_Y1		EQU	146		; sidemenu 左上Ｙ
WD_INI_SD_XL		EQU	16		; sidemenu サイズＸ
WD_INI_SD_YL		EQU	67		; sidemenu サイズＹ
WD_INI_SD_OFS_X		EQU	2		; sidemenu 項目表示ｵﾌｾｯﾄX
WD_INI_SD_OFS_Y		EQU	16	;14	; sidemenu 項目表示ｵﾌｾｯﾄY
WD_INI_SD_HIGHT		EQU	20		; sidemenu １行高さ
WD_INI_SD_CUROF_X	EQU	1		; sidemenu ｶｰｿﾙｵﾌｾｯﾄX
WD_INI_SD_CUROF_Y	EQU	10	;8	; sidemenu ｶｰｿﾙｵﾌｾｯﾄY

WD_INI_SD_H_OFS_DOT_X	EQU	11		; sidemenu 表ｵﾌｾｯﾄdotX
WD_INI_SD_H_OFS_Y	EQU	13	;11	; sidemenu 表ｵﾌｾｯﾄY

INI_SD_H_DOT_LEN_X	EQU	105		; sidemenu 表横幅

INI_H_DOT_LEN_X		EQU	294+40		; 項目表横幅
INI_H_D_LOC_1_X		EQU	40		; 縦棒1
INI_H_D_LOC_2_X		EQU	124+40		; 縦棒1

TBL_KOMOKU_DIM		EQU	10		; table dim.
TBL_NAME_LEN		EQU	40		; table name length.
MESSAGE_LEN		EQU	40		; message length.
CUT_NAME_LEN		EQU	20		; cut name length.

HED_BANG_LEN		EQU	6		; ﾍｯﾀﾞ番号長さ
HED_DATE_LEN		EQU	20		; ﾍｯﾀﾞ日付長さ
HED_NAME_LEN		EQU	20		; ﾍｯﾀﾞ名前長さ

INI_LINE_KOMOKU		EQU	10		; 項目行数
INI_LINE_KOMOKU_SD	EQU	2		; 項目行数(ｻｲﾄﾞﾒﾆｭｰ)

COL_CURSOLE_H		EQU	14		; hi light color.
COL_CURSOLE		EQU	3		; color.
COL_CURSOLE_B		EQU	4		; color.

OFFF			EQU	-1		; off.
EOS			EQU	0		; end of string.

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
;	WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳOPEN
; ****************************************************

FUNC	WIDDTSLC_OPEN
	MOV	CUR_BACK_NUM,OFFF	; cursole back ﾃﾞｰﾀﾌｧｲﾙ番号

	CALL	WIDAREA_BACK		; ウインドウエリア待避

	MOV	AX,LINE_KOMOKU_SD	; 項目行数(ｻｲﾄﾞﾒﾆｭｰ)
	MUL	WINDSD_HIGHT		; sidemenu １行高さ
	ADD	AX,29	;25		; +29
	MOV	WINDSD_Y2,AX		; sidemenu ﾌﾚｰﾑｻｲｽﾞy.
	MOV	WINDSD_YL,AX		; sidemenu 待避サイズＹ

	MOV	CX,WINDOW_X1		; window 左上Ｘ
	MOV	DX,WINDOW_Y1		; window 左上Ｙ
	MOV	SI,WINDOW_X2		; window フレームサイズＸ
	MOV	DI,WINDOW_Y2		; window フレームサイズＹ
	CALLE	FRAME_LDSV		; ﾃﾞｰﾀﾛｰﾄﾞｾｰﾌﾞﾌﾚｰﾑ

	MOV	CX,WINDSD_X1		; sidemenu 左上Ｘ
	MOV	DX,WINDSD_Y1		; sidemenu 左上Ｙ
	MOV	SI,WINDSD_X2		; sidemenu ﾌﾚｰﾑｻｲｽﾞx.
	MOV	DI,WINDSD_Y2		; sidemenu ﾌﾚｰﾑｻｲｽﾞy.
	CALLE	FRAME_LDSV		; ﾃﾞｰﾀﾛｰﾄﾞｾｰﾌﾞﾌﾚｰﾑ

	CALL	KOUMOKU_HYO		; 項目表

	CALL	SIDEMENU_HYO		; ｻｲﾄﾞﾒﾆｭｰ表

	RET
FEND	WIDDTSLC_OPEN


; ****************************************************
;	WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳCLOSE
; ****************************************************

FUNC	WIDDTSLC_CLOSE
	CALL	WIDAREA_RESTOR		; ウインドウエリア復元
	RET
FEND	WIDDTSLC_CLOSE


; ****************************************************
;	WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ項目セット
;	-I- BX : データファイル番号
;	    CX : 年
;	    DX : 月
;	    SI : 曜日
;	    DI : 日
;	    BP : 娘の名前
; ****************************************************

FUNC	WIDDTSLC_PARASET
	DEC	BX			;-1
	SHL	BX,1			; word pointer.
	MOV	TBL_YEAR[BX],CX		; 年
	MOV	TBL_MONTH[BX],DX	; 月
	MOV	TBL_WEEK[BX],SI		; 曜日
	MOV	TBL_DAY[BX],DI		; 日

	PUSH	BX
	MOV	SI,BP			; 文字列バッファ 名前
	MOV	DI,OFFSET STR_GIRL_NAME	; ﾍｯﾀﾞ娘名前
	MOV	CX,TBL_NAME_LEN		; table name length.
	CALL	MDATACOPY		; main DATA segment to memory.
	POP	BX

	MOV	DI,TBL_NAME[BX]		; 名前
	CALL	EDIT_GIRL_NAME		; 娘の名前編集

	RET
FEND	WIDDTSLC_PARASET


; ****************************************************
;	WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ項目表示
;	-I- BX : データファイル番号
; ****************************************************

FUNC	WIDDTSLC_PARASHOW
	MOV	DAT_FILE_NUM,BX		; データファイル番号
	MOV	P_NUMBER,BX		; 番号
	DEC	BX			;-1
	SHL	BX,1			; word pointer.
	MOVX	P_YEAR,	TBL_YEAR[BX]	; 年
	MOVX	P_MONTH,TBL_MONTH[BX]	; 月
	MOVX	P_WEEK,	TBL_WEEK[BX]	; 曜日
	MOVX	P_DAY,	TBL_DAY[BX]	; 日
	MOVX	P_NAME,	TBL_NAME[BX]	; 名前

	CALL	LOC_XY			; name locate.

	CMP	P_YEAR,0
	JE	WIDDTSLC_PARASHOW_CLR
	CALL	DSP_BANGO		; 項目番号表示
	CALL	CLR_1LINE		; 項目１行クリア
	CALL	DSP_DATE		; 項目日付表示
	CALL	DSP_NAME		; 項目名前表示
	RET
WIDDTSLC_PARASHOW_CLR:
	CALL	DSP_BANGO		; 項目番号表示
	CALL	CLR_1LINE		; 項目１行クリア
	RET
FEND	WIDDTSLC_PARASHOW


; ****************************************************
;	WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳﾍｯﾀﾞ表示
;	-I- BX : "番号"
;	    CX : "日付"
;	    DX : "名前"
; ****************************************************

FUNC	WIDDTSLC_HEADER
	PUSH	DX
	PUSH	CX
	PUSH	BX

	POP	SI			; "番号"
	MOV	DI,OFFSET STR_HED_BANG	; ﾍｯﾀﾞ番号
	MOV	CX,HED_BANG_LEN		; ﾍｯﾀﾞ番号長さ
	CALL	MDATACOPY		; main DATA segment to memory.

	POP	SI			; 日付
	MOV	DI,OFFSET STR_HED_DATE	; ﾍｯﾀﾞ日付
	MOV	CX,HED_DATE_LEN		; ﾍｯﾀﾞ日付長さ
	CALL	MDATACOPY		; main DATA segment to memory.

	POP	SI			; 名前
	MOV	DI,OFFSET STR_HED_NAME	; ﾍｯﾀﾞ名前
	MOV	CX,HED_NAME_LEN		; ﾍｯﾀﾞ名前長さ
	CALL	MDATACOPY		; main DATA segment to memory.

	MOV	DAT_FILE_NUM,0		; データファイル番号
	CALL	LOC_XY			; name locate.

	CALL	DSP_HEADER		; 項目ﾍｯﾀﾞ表示

	RET
FEND	WIDDTSLC_HEADER


; ****************************************************
;	WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳSLCT
;	-O- AX : 選択ﾃﾞｰﾀﾌｧｲﾙ番号(-1はｷｬﾝｾﾙ)
; ****************************************************

FUNC	WIDDTSLC_SLCT
	CMP	DEBUGXX,55		;55=ランダムセレクト
	JE	WIDDTSLC_SLCT_DEMO	;

	CALL	DTSLC_MAIN		; データ選択メイン
	RET
WIDDTSLC_SLCT_DEMO:
	MOV	AX,-1
	RET
FEND	WIDDTSLC_SLCT


; ****************************************************
;	WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ文字表示
;	-I- BX : データファイル番号(ｻｲﾄﾞﾒﾆｭｰは11から)
;	    CX : 文字列
; ****************************************************

FUNC	WIDDTSLC_PRINT
	MOV	DAT_FILE_NUM,BX		; データファイル番号

	MOV	SI,CX			; 文字列バッファ 名前
	MOV	DI,OFFSET STR_MESSAGE	; 娘の名前
	MOV	CX,MESSAGE_LEN		; message length.
	CALL	MDATACOPY		; main DATA segment to memory.

	CALL	LOC_XY			; name locate.
	CALL	DSP_MESSAGE		; 項目ﾒｯｾｰｼﾞ表示

	RET
FEND	WIDDTSLC_PRINT


; ****************************************************
;	WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ ｻｲﾄﾞﾒﾆｭｰ行数
;	-I- BX : 項目行数(ｻｲﾄﾞﾒﾆｭｰ)
; ****************************************************

FUNC	WIDDTSLC_SIDEM_LIN
	MOV	LINE_KOMOKU_SD,BX	; 項目行数(ｻｲﾄﾞﾒﾆｭｰ)
	RET
FEND	WIDDTSLC_SIDEM_LIN


; ****************************************************
;	データ選択メイン
;	-O- AX : 選択ﾃﾞｰﾀﾌｧｲﾙ番号(-1はｷｬﾝｾﾙ)
; ****************************************************

DTSLC_MAIN	PROC	NEAR
	CALLE	MSCSRT			; カーソルスタート
DTSLC_MAIN_LOOP:
	CALLE	MSCMOV			; カーソル移動
	MOV	MOUSE_X,AX		; mouse x.
	MOV	MOUSE_Y,BX		; mouse y.
	MOV	MUSBOTTONL,DH		; 左ボタン(1:OFF/0:ON)
	MOV	MUSBOTTONR,DL		; 右ボタン(1:OFF/0:ON)

	CALL	AREA_CHECK		; エリアチェック
	CALL	CURSOLE_PUT		; cursole put.

	CMP	MUSBOTTONL,0		; 左ボタン(1:OFF/0:ON)
	JE	DTSLC_MAIN_ON		;
	CMP	MUSBOTTONR,0		; 右ボタン(1:OFF/0:ON)
	JE	DTSLC_MAIN_CANCEL	;

	JMP	DTSLC_MAIN_NEXT

DTSLC_MAIN_ON:
	CMP	DAT_FILE_NUM,OFFF	; データファイル番号
	JNE	DTSLC_MAIN_LOOP_E	;
	JMP	DTSLC_MAIN_NEXT		;

DTSLC_MAIN_CANCEL:
	MOV	DAT_FILE_NUM,OFFF	; データファイル番号
	CALL	CURSOLE_PUT		; cursole put.
	JMP	DTSLC_MAIN_LOOP_E	;

DTSLC_MAIN_NEXT:
	JMP	DTSLC_MAIN_LOOP

DTSLC_MAIN_LOOP_E:

DTSLC_MAIN_EXIT:
	CALLE	MSCSTP			; カーソルストップ
	MOV	AX,DAT_FILE_NUM		; データファイル番号
	RET
DTSLC_MAIN	ENDP


; ****************************************************
;	エリアチェック
;	-I- MOUSE_X      : mouse x.
;	    MOUSE_Y      : mouse y.
;	-O- DAT_FILE_NUM : データファイル番号
; ****************************************************

AREA_CHECK	PROC	NEAR
	MOV	DAT_FILE_NUM,1		; データファイル番号
	MOV	CX,LINE_KOMOKU		; 項目行数
	ADD	CX,LINE_KOMOKU_SD	; 項目行数(ｻｲﾄﾞﾒﾆｭｰ)
AREA_CHECK_LOOP:
	PUSH	CX
	CALL	CUR_AREA_XY		; cursole area locate.
	POP	CX

	MOV	AX,MOUSE_X		; mouse x.
	CMP	AX,WID_CUR_ARA_X1	; cursole area x1.
	JB	AREA_CHECK_NEXT		;
	CMP	AX,WID_CUR_ARA_X2	; cursole area x2.
	JNBE	AREA_CHECK_NEXT		;

	MOV	AX,MOUSE_Y		; mouse y.
	CMP	AX,WID_CUR_ARA_Y1	; cursole area y1.
	JB	AREA_CHECK_NEXT		;
	CMP	AX,WID_CUR_ARA_Y2	; cursole area y2.
	JNBE	AREA_CHECK_NEXT		;

	JMP	AREA_CHECK_EXIT		;
AREA_CHECK_NEXT:
	INC	DAT_FILE_NUM		; データファイル番号
	LOOP	AREA_CHECK_LOOP

	MOV	DAT_FILE_NUM,OFFF	; データファイル番号
AREA_CHECK_EXIT:
	RET
AREA_CHECK	ENDP



; ****************************************************
;	項目ﾍｯﾀﾞ表示
;	-I- WID_BANG_X : 項目番号表示X
;	    WID_BANG_Y : 項目番号表示Y
;	    WID_DATE_X : 項目日付表示X
;	    WID_DATE_Y : 項目日付表示Y
;	    WID_NAME_X : 項目名前表示X
;	    WID_NAME_Y : 項目名前表示Y
;	    STR_HED_BANG: ﾍｯﾀﾞ番号
;	    STR_HED_DATE: ﾍｯﾀﾞ日付
;	    STR_HED_NAME: ﾍｯﾀﾞ名前
; ****************************************************

DSP_HEADER	PROC	NEAR
	MOV	AX,CHR_SIZE		; 0=16x16  1=32x32  2=16x24  3=16x32
	CALLE	VTXSIZ			;character size set.
	MOV	AX,CHR_COLOR		; character color.
	CALLE	VTXCOL			;character color set.

	MOV	SI,OFFSET STR_HED_BANG	; ﾍｯﾀﾞ番号
	MOV	AX,WID_BANG_X		; 項目番号表示X
	MOV	BX,WID_BANG_Y		; 項目番号表示Y
	CALLE	VTXPOR			;vram text print OR.

	MOV	SI,OFFSET STR_HED_DATE	; ﾍｯﾀﾞ日付
	MOV	AX,WID_DATE_X		; 項目日付表示X
	MOV	BX,WID_DATE_Y		; 項目日付表示Y
	CALLE	VTXPOR			;vram text print OR.

	MOV	SI,OFFSET STR_HED_NAME	; ﾍｯﾀﾞ名前
	MOV	AX,WID_NAME_X		; 項目名前表示X
	MOV	BX,WID_NAME_Y		; 項目名前表示Y
	CALLE	VTXPOR			;vram text print OR.

	RET
DSP_HEADER	ENDP


; ****************************************************
;	項目１行クリア
;	-I- WID_DATE_X : 項目日付表示X
;	    WID_DATE_Y : 項目日付表示Y
;	    WID_NAME_X : 項目名前表示X
;	    WID_NAME_Y : 項目名前表示Y
; ****************************************************

CLR_1LINE	PROC	NEAR
	MOV	AX,WID_DATE_X		; 項目日付表示X
	MOV	BX,WID_DATE_Y		; 項目日付表示Y
	MOV	CX,15			; length.
	CALL	TXBOX			; テキスト描画クリア

	MOV	AX,WID_NAME_X		; 項目名前表示X
	MOV	BX,WID_NAME_Y		; 項目名前表示Y
	MOV	CX,20			; length.
	CALL	TXBOX			; テキスト描画クリア

	RET
CLR_1LINE	ENDP


; ****************************************************
;	項目番号表示
;	-I- WID_BANG_X : 項目番号表示X
;	    WID_BANG_Y : 項目番号表示Y
;	    P_NUMBER   : 番号
; ****************************************************

DSP_BANGO	PROC	NEAR
	MOV	AX,CHR_SIZE		; 0=16x16  1=32x32  2=16x24  3=16x32
	CALLE	VTXSIZ			;character size set.
	MOV	AX,CHR_COLOR		; character color.
	CALLE	VTXCOL			;character color set.

	MOV	DX,P_NUMBER		; 番号
	CALLE	DECSTR			;
	CALLE	STRZTS			; zero to space. "00123" - > "  123"
	ADD	SI,2			;
	MOV	AX,WID_BANG_X		; 項目番号表示X
	MOV	BX,WID_BANG_Y		; 項目番号表示Y
	CALLE	VTXPOR			;vram text print OR.
	RET
DSP_BANGO	ENDP


; ****************************************************
;	項目日付表示
;	-I- WID_DATE_X : 項目日付表示X
;	    WID_DATE_Y : 項目日付表示Y
;	    P_YEAR     : 年
;	    P_MONTH    : 月
;	    P_WEEK     : 曜日
;	    P_DAY      : 日
; ****************************************************

DSP_DATE	PROC	NEAR
	CMP	P_YEAR,0		; 年
	JE	DSP_DATE_EXIT		;

	CALL	EDIT_DATE		; 日付編集

	MOV	AX,CHR_SIZE		; 0=16x16  1=32x32  2=16x24  3=16x32
	CALLE	VTXSIZ			;character size set.
	MOV	AX,CHR_COLOR		; character color.
	CALLE	VTXCOL			;character color set.

	MOV	SI,OFFSET STR_DATE	; string date.
	MOV	AX,WID_DATE_X		; 項目日付表示X
	MOV	BX,WID_DATE_Y		; 項目日付表示Y
	CALLE	VTXPOR			;vram text print OR.

DSP_DATE_EXIT:
	RET
DSP_DATE	ENDP


; ****************************************************
;	項目名前表示
;	-I- WID_NAME_X : 項目名前表示X
;	    WID_NAME_Y : 項目名前表示Y
;	    P_NAME     : 名前
; ****************************************************

DSP_NAME	PROC	NEAR
	MOV	AX,CHR_SIZE		; 0=16x16  1=32x32  2=16x24  3=16x32
	CALLE	VTXSIZ			;character size set.
	MOV	AX,CHR_COLOR		; character color.
	CALLE	VTXCOL			;character color set.

	MOV	SI,P_NAME		; 名前
	MOV	AX,WID_NAME_X		; 項目名前表示X
	MOV	BX,WID_NAME_Y		; 項目名前表示Y
	CALLE	VTXPOR			;vram text print OR.
	RET
DSP_NAME	ENDP


; ****************************************************
;	項目ﾒｯｾｰｼﾞ表示
;	-I- WID_MESS_X : 項目ﾒｯｾｰｼﾞ表示X
;	    WID_MESS_Y : 項目ﾒｯｾｰｼﾞ表示Y
;	    STR_MESSAGE: メッセージ
; ****************************************************

DSP_MESSAGE	PROC	NEAR
	MOV	AX,CHR_SIZE		; 0=16x16  1=32x32  2=16x24  3=16x32
	CALLE	VTXSIZ			;character size set.
	MOV	AX,CHR_COLOR		; character color.
	CALLE	VTXCOL			;character color set.

	MOV	SI,OFFSET STR_MESSAGE	; メッセージ
	MOV	AX,WID_MESS_X		; 項目ﾒｯｾｰｼﾞ表示X
	MOV	BX,WID_MESS_Y		; 項目ﾒｯｾｰｼﾞ表示Y
	CALLE	VTXPOR			;vram text print OR.
	RET
DSP_MESSAGE	ENDP


; ****************************************************
;	日付編集
;	-I- P_YEAR   : 年
;	    P_MONTH  : 月
;	    P_WEEK   : 曜日
;	    P_DAY    : 日
;	-O- STR_DATE : string date.
;
;	 12345678901234
;	"1222/12/12 Mon"
; ****************************************************

EDIT_DATE	PROC	NEAR
	MOVX	ES,DS

	MOV	DX,P_YEAR		; 年
	CALLE	DECSTR			; i*2 value -> decimal string.
	CALLE	STRZTS			; zero to space. "00123" - > "  123"
	INC	SI			;
	MOV	DI,OFFSET STR_DATE	; string date.
	MOV	CX,4			;
	CALL	MEMCOPY			; memory to memory copy.
	MOV	AL,"/"			;
	STOSB				;

	PUSH	DI
	MOV	DX,P_MONTH		; 月
	CALLE	DECSTR			; i*2 value -> decimal string.
	CALLE	STRZTS			; zero to space. "00123" - > "  123"
	ADD	SI,3			; + 3
	POP	DI

	MOV	CX,2			;
	CALL	MEMCOPY			; memory to memory copy.
	MOV	AL,"/"			;
	STOSB				;

	PUSH	DI
	MOV	DX,P_DAY		; 日
	CALLE	DECSTR			; i*2 value -> decimal string.
	CALLE	STRZTS			; zero to space. "00123" - > "  123"
	ADD	SI,3			; + 3
	POP	DI

	MOV	CX,2			;
	CALL	MEMCOPY			; memory to memory copy.
	MOV	AL,"("			;
	STOSB				;

	MOV	BX,P_WEEK		; 曜日
	SHL	BX,1			;
	MOV	SI,NAME_WEEK[BX]	;
	MOV	CX,3			;
	CALL	MEMCOPY			; memory to memory copy.

	MOV	AL,")"			;
	STOSB				;

	MOV	AL,EOS			; end of string.
	STOSB				;
	RET
EDIT_DATE	ENDP


; ****************************************************
;	娘の名前編集
;	18byte(名前)+2byte+18byte(名字)+2byte.
;	-I- STR_GIRL_NAME : 娘の名前
;	    DS:DI
; ****************************************************

EDIT_GIRL_NAME	PROC	NEAR
	PUSH	DI

	PUSH	DI
	MOV	CX,TBL_NAME_LEN
	CALL	MEMCLEAR		; memory clear.
	POP	DI

	PUSH	DI
	MOV	DI,OFFSET STR_GIRL_NAME	; 娘の名前
	CALL	STRLENG			; 文字列長さスペースまで
	POP	DI

	MOV	SI,OFFSET STR_GIRL_NAME	; 娘の名前
	CALL	MEMCOPY			; memory to memory copy.

	MOV	SI,OFFSET KNJ_TEN	;"・"
	MOV	CX,2			;
	CALL	MEMCOPY			; memory to memory copy.

	PUSH	DI
	MOV	DI,OFFSET STR_GIRL_NAME	; 娘の名前
	ADD	DI,18+2			;
	CALL	STRLENG			; 文字列長さスペースまで
	POP	DI

	MOV	SI,OFFSET STR_GIRL_NAME	; 娘の名前
	ADD	SI,18+2			;
	CALL	MEMCOPY			; memory to memory copy.

	POP	DI
	MOV	WORD PTR DS:[DI][CUT_NAME_LEN],EOS

	RET
EDIT_GIRL_NAME	ENDP


; ****************************************************
;	name locate.
;	-I- DAT_FILE_NUM : データファイル番号
;	-O- WID_KLOC_X   : 項目X
;	    WID_KLOC_Y   : 項目Y
; ****************************************************

LOC_XY	PROC	NEAR
	CMPX	DAT_FILE_NUM,LINE_KOMOKU	; 項目行数
	JNBE	LOC_XY_SIDEMENU			;

	MOV	AX,DAT_FILE_NUM		; データファイル番号
	MUL	WINDOW_HIGHT		; window １行高さ

	ADD	AX,WINDOW_Y1		; window 左上Ｙ
	ADD	AX,WINDOW_OFS_Y		; window 項目表示ｵﾌｾｯﾄY
	MOV	WID_KLOC_Y,AX		; window 項目表示ｵﾌｾｯﾄY

	MOV	AX,WINDOW_X1		; window 左上Ｘ
	ADD	AX,WINDOW_OFS_X		; window 項目表示ｵﾌｾｯﾄX
	MOV	WID_KLOC_X,AX		; window 項目表示ｵﾌｾｯﾄX

	MOV	AX,WID_KLOC_X		; 項目X
	ADD	AX,WINDOW_NUMB_OFS_X	; window 番号位置
	MOV	WID_BANG_X,AX		; 項目番号表示X
	MOVX	WID_BANG_Y,WID_KLOC_Y	; 項目番号表示Y

	MOV	AX,WID_KLOC_X		; 項目X
	ADD	AX,WINDOW_DATE_OFS_X	; window 日付位置
	MOV	WID_DATE_X,AX		; 項目日付表示X
	MOVX	WID_DATE_Y,WID_KLOC_Y	; 項目日付表示Y

	MOV	AX,WID_KLOC_X		; 項目X
	ADD	AX,WINDOW_NAME_OFS_X 	; window 名前位置
	MOV	WID_NAME_X,AX		; 項目名前表示X
	MOVX	WID_NAME_Y,WID_KLOC_Y	; 項目名前表示Y

	MOVX	WID_MESS_X,WID_DATE_X	; 項目ﾒｯｾｰｼﾞ表示X
	MOVX	WID_MESS_Y,WID_DATE_Y	; 項目ﾒｯｾｰｼﾞ表示Y

	RET
LOC_XY_SIDEMENU:
	MOV	AX,DAT_FILE_NUM		; データファイル番号
	SUB	AX,LINE_KOMOKU		; 項目行数
	DEC	AX			; -1
	MUL	WINDSD_HIGHT		; sidemenu １行高さ

	ADD	AX,WINDSD_Y1		; sidemenu 左上Ｙ
	ADD	AX,WINDSD_OFS_Y		; sidemenu 項目表示ｵﾌｾｯﾄY
	MOV	WID_KLOC_Y,AX		; window 項目表示ｵﾌｾｯﾄY

	MOV	AX,WINDSD_X1		; sidemenu 左上Ｘ
	ADD	AX,WINDSD_OFS_X		; sidemenu 項目表示ｵﾌｾｯﾄX
	MOV	WID_KLOC_X,AX		; window 項目表示ｵﾌｾｯﾄX

	MOVX	WID_MESS_X,WID_KLOC_X	; 項目ﾒｯｾｰｼﾞ表示X
	MOVX	WID_MESS_Y,WID_KLOC_Y	; 項目ﾒｯｾｰｼﾞ表示Y

	RET
LOC_XY	ENDP


; ****************************************************
;	cursole locate.
;	-I- DAT_FILE_NUM : データファイル番号
;	-O- WID_CUR_X    : cursole x.
;	    WID_CUR_Y    : cursole y.
; ****************************************************

CURSOLE_XY	PROC	NEAR
	CMPX	DAT_FILE_NUM,LINE_KOMOKU	; 項目行数
	JNBE	CURSOLE_XY_SIDEMENU		;

	MOV	WID_CUR_BAK_XL,WD_INI_CUR_BAK_XL; cursole back 待避ｻｲｽﾞx.
	MOV	WID_CUR_BAK_YL,WD_INI_CUR_BAK_YL; cursole back 待避ｻｲｽﾞy.

	MOV	WID_CUR_SIZ_DOT_XL,WD_INI_CUR_DOT_XL; window ｶｰｿﾙｻｲｽﾞdotX
	MOV	WID_CUR_SIZ_YL,WD_INI_CUR_YL	; window ｶｰｿﾙｻｲｽﾞY

	MOV	AX,DAT_FILE_NUM		; データファイル番号
	MUL	WINDOW_HIGHT		; window １行高さ

	ADD	AX,WINDOW_Y1		; window 左上Ｙ
	ADD	AX,WINDOW_CUROF_Y	; window ｶｰｿﾙｵﾌｾｯﾄY
	MOV	WID_CUR_Y,AX		; cursole y.

	MOV	AX,WINDOW_X1		; window 左上Ｘ
	ADD	AX,WINDOW_CUROF_X	; window ｶｰｿﾙｵﾌｾｯﾄX
	MOV	WID_CUR_X,AX		; cursole x.

	RET

CURSOLE_XY_SIDEMENU:
	MOV	WID_CUR_BAK_XL,WD_INI_CUR_BAK_SD_XL; cursole back 待避ｻｲｽﾞx
	MOV	WID_CUR_BAK_YL,WD_INI_CUR_BAK_SD_YL; cursole back 待避ｻｲｽﾞy

	MOV	WID_CUR_SIZ_DOT_XL,WD_INI_CUR_SD_DOT_XL	; window ｶｰｿﾙｻｲｽﾞdotX
	MOV	WID_CUR_SIZ_YL,WD_INI_CUR_SD_YL		; window ｶｰｿﾙｻｲｽﾞY

	MOV	AX,DAT_FILE_NUM		; データファイル番号
	SUB	AX,LINE_KOMOKU		; 項目行数
	DEC	AX			; -1
	MUL	WINDSD_HIGHT		; sidemenu １行高さ

	ADD	AX,WINDSD_Y1		; sidemenu 左上Ｙ
	ADD	AX,WINDSD_CUROF_Y	; sidemenu ｶｰｿﾙｵﾌｾｯﾄY
	MOV	WID_CUR_Y,AX		; cursole y.

	MOV	AX,WINDSD_X1		; sidemenu 左上Ｘ
	ADD	AX,WINDSD_CUROF_X	; sidemenu ｶｰｿﾙｵﾌｾｯﾄX
	MOV	WID_CUR_X,AX		; cursole x.

	RET
CURSOLE_XY	ENDP


; ****************************************************
;	cursole area locate.
;	-I- DAT_FILE_NUM   : データファイル番号
;	-O- WID_CUR_ARA_X1 : cursole area x1.
;	    WID_CUR_ARA_Y1 : cursole area y1.
;	    WID_CUR_ARA_X2 : cursole area x2.
;	    WID_CUR_ARA_Y2 : cursole area y2.
; ****************************************************

CUR_AREA_XY	PROC	NEAR
	CMPX	DAT_FILE_NUM,LINE_KOMOKU	; 項目行数
	JNBE	CUR_AREA_XY_SIDE_MENU

	MOV	WID_CUR_ARA_XL,WD_INI_CUR_AREA_X	; cursole ｴﾘｱｻｲｽﾞx.
	MOV	WID_CUR_ARA_YL,WD_INI_CUR_AREA_Y	; cursole ｴﾘｱｻｲｽﾞy.

	MOV	AX,DAT_FILE_NUM		; データファイル番号
	MUL	WINDOW_HIGHT		; window １行高さ

	ADD	AX,WINDOW_Y1		; window 左上Ｙ
	ADD	AX,WINDOW_OFS_Y		; window 項目表示ｵﾌｾｯﾄY
	MOV	WID_CUR_ARA_Y1,AX	; cursole area y1.
	ADD	AX,WID_CUR_ARA_YL	; cursole ｴﾘｱｻｲｽﾞy.
	DEC	AX			; -1
	MOV	WID_CUR_ARA_Y2,AX	; cursole area y2.

	MOV	AX,WINDOW_X1		; window 左上Ｘ
	ADD	AX,WINDOW_OFS_X		; window 項目表示ｵﾌｾｯﾄX
	MOV	WID_CUR_ARA_X1,AX	; cursole area x1.
	ADD	AX,WID_CUR_ARA_XL	; cursole ｴﾘｱｻｲｽﾞx.
	DEC	AX			; -1
	MOV	WID_CUR_ARA_X2,AX	; cursole area x2.
	RET

CUR_AREA_XY_SIDE_MENU:

	MOV	WID_CUR_ARA_XL,WD_INI_CUR_AREA_SD_X	; cursole ｴﾘｱｻｲｽﾞx(ｻｲﾄﾞﾒﾆﾕｰ)
	MOV	WID_CUR_ARA_YL,WD_INI_CUR_AREA_SD_Y	; cursole ｴﾘｱｻｲｽﾞy(ｻｲﾄﾞﾒﾆﾕｰ)

	MOV	AX,DAT_FILE_NUM		; データファイル番号
	SUB	AX,LINE_KOMOKU		; 項目行数
	DEC	AX			; -1
	MUL	WINDSD_HIGHT		; sidemenu １行高さ

	ADD	AX,WINDSD_Y1		; sidemenu 左上Ｙ
	ADD	AX,WINDSD_OFS_Y		; sidemenu 項目表示ｵﾌｾｯﾄY
	MOV	WID_CUR_ARA_Y1,AX	; cursole area y1.
	ADD	AX,WID_CUR_ARA_YL	; cursole ｴﾘｱｻｲｽﾞy.
	DEC	AX			; -1
	MOV	WID_CUR_ARA_Y2,AX	; cursole area y2.

	MOV	AX,WINDSD_X1		; sidemenu 左上Ｘ
	ADD	AX,WINDSD_OFS_X		; sidemenu 項目表示ｵﾌｾｯﾄX
	MOV	WID_CUR_ARA_X1,AX	; cursole area x1.
	ADD	AX,WID_CUR_ARA_XL	; cursole ｴﾘｱｻｲｽﾞx.
	DEC	AX			; -1
	MOV	WID_CUR_ARA_X2,AX	; cursole area x2.
	RET
CUR_AREA_XY	ENDP


; ****************************************************
;	項目表
; ****************************************************

KOUMOKU_HYO	PROC	NEAR

	MOV	AX,WINDOW_X1		; window 左上Ｘ
	SHL	AX,1			;
	SHL	AX,1			; * 8
	SHL	AX,1			;
	ADD	AX,WINDOW_H_OFS_DOT_X	; window 項目表ｵﾌｾｯﾄdotX

	MOV	BX,WINDOW_Y1		; window 左上Ｙ
	ADD	BX,WINDOW_H_OFS_Y	; window 項目表ｵﾌｾｯﾄY

	MOV	WDX1N,AX		; dot x1.
	MOV	WDY1N,BX		; y1.
	ADD	AX,H_DOT_LEN_X		; 項目表横幅
	DEC	AX			;
	MOV	WDX2N,AX		; dot x2.

	MOV	AX,LINE_KOMOKU		; 項目行数
	INC	AX			; +1
	MUL	WINDOW_HIGHT		; window １行高さ
	ADD	AX,WDY1N		; y1.
	MOV	WDY2N,AX		; y2.

	; box x,y

	MOV	AX,WDY1N		; y1
	INC	AX			;+1
	MOV	WDY1,AX			; y1

	MOV	AX,WDY2N		; y2
	INC	AX			;+2
	INC	AX			;
	MOV	WDY2,AX			; y2

	; box.

	MOV	AX,WDX1N		; x1
	SUB	AX,3			; 縦棒1
	MOV	WDX1,AX			; x1
	CALL	KOUMOKU_Y_LINE		; 項目表・縦棒

	MOV	AX,WDX1N		; x1
	ADD	AX,H_D_LOC_1_X		; 縦棒1
	MOV	WDX1,AX			; x1
	CALL	KOUMOKU_Y_LINE		; 項目表・縦棒

	MOV	AX,WDX1N		; x1
	ADD	AX,H_D_LOC_2_X		; 縦棒2
	MOV	WDX1,AX			; x1
	CALL	KOUMOKU_Y_LINE		; 項目表・縦棒

	MOV	AX,WDX1N		; x1
	ADD	AX,H_DOT_LEN_X		; 項目表横幅
	DEC	AX			; -1
	MOV	WDX1,AX			; x1
	CALL	KOUMOKU_Y_LINE		; 項目表・縦棒


	MOVX	WDX1,WDX1N		; x1
	MOVX	WDY1,WDY1N		; y1
	MOVX	WDX2,WDX2N		; x2
	MOV	CX,LINE_KOMOKU		; 項目行数
	ADD	CX,2			; +2
KOUMOKU_HYO_LOOP:
	PUSH	CX
	CALL	KOUMOKU_X_LINE		; 項目表・横棒
	ADDX	WDY1,WINDOW_HIGHT	; window １行高さ
	POP	CX
	LOOP	KOUMOKU_HYO_LOOP

	RET
KOUMOKU_HYO	ENDP


; ****************************************************
;	項目表・横棒
;	-I- WDX1 : dot x1.
;	    WDY1 : y1.
;	    WDX2 : dot x2.
; ****************************************************

KOUMOKU_X_LINE	PROC	NEAR
	MOV	AX,WDX1			; dot x1.
	MOV	BX,WDY1			; y1.
	MOV	CX,WDX2			; dot x2.

	MOV	VX1,AX			; start dot point x1.
	MOV	VY1,BX			; line hight y1.
	MOV	VX2,CX			; end dot point x2.

	MOV	CX,1			; line width.
	MOV	VCOL,4			; color.
	CALLE	DLINEH			; 水平ライン描画

	INC	VY1			; line hight y1.

	MOV	CX,1			; line width.
	MOV	VCOL,15			; color.
	CALLE	DLINEH			; 水平ライン描画

	INC	VY1			; line hight y1.

	MOV	CX,1			; line width.
	MOV	VCOL,8			; color.
	CALLE	DLINEH			; 水平ライン描画

	INC	VY1			; line hight y1.

	MOV	CX,1			; line width.
	MOV	VCOL,4			; color.
	CALLE	DLINEH			; 水平ライン描画
	RET
KOUMOKU_X_LINE	ENDP


; ****************************************************
;	項目表・縦棒
;	-I- WDX1 : dot x1.
;	    WDY1 : y1.
;	    WDY2 : y2.
; ****************************************************

KOUMOKU_Y_LINE	PROC	NEAR
	MOV	AX,WDX1			; dot x1.
	MOV	BX,WDY1			; y1.
	MOV	CX,WDY2			; y2.

	MOV	VX1,AX			; line dot point x.
	MOV	VY1,BX			; start line point y1.
	MOV	VY2,CX			; end line point y2.

	MOV	CX,1			; line width.
	MOV	VCOL,4			; color.
	CALLE	DLINEV			; 垂直ライン描画

	INC	VX1			; line dot point x.

	MOV	CX,1			; line width.
	MOV	VCOL,15			; color.
	CALLE	DLINEV			; 垂直ライン描画

	INC	VX1			; line dot point x.

	MOV	CX,1			; line width.
	MOV	VCOL,8			; color.
	CALLE	DLINEV			; 垂直ライン描画

	INC	VX1			; line dot point x.

	MOV	CX,1			; line width.
	MOV	VCOL,4			; color.
	CALLE	DLINEV			; 垂直ライン描画

	RET
KOUMOKU_Y_LINE	ENDP


; ****************************************************
;	ｻｲﾄﾞﾒﾆｭｰ表
; ****************************************************

SIDEMENU_HYO	PROC	NEAR

	MOV	AX,WINDSD_X1		; sidemenu 左上Ｘ
	SHL	AX,1			;
	SHL	AX,1			; * 8
	SHL	AX,1			;
	ADD	AX,WINDSD_H_OFS_DOT_X	; sidemenu 表ｵﾌｾｯﾄdotX

	MOV	BX,WINDSD_Y1		; sidemenu 左上Ｙ
	ADD	BX,WINDSD_H_OFS_Y	; sidemenu 表ｵﾌｾｯﾄY

	MOV	WDX1N,AX		; dot x1.
	MOV	WDY1N,BX		; y1.

	ADD	AX,SD_H_DOT_LEN_X	; sidemenu 表横幅
	DEC	AX			;
	MOV	WDX2N,AX		; dot x2.

	MOV	AX,LINE_KOMOKU_SD	; 項目行数(ｻｲﾄﾞﾒﾆｭｰ)
	MUL	WINDSD_HIGHT		; sidemenu １行高さ
	ADD	AX,WDY1N		; y1.
	MOV	WDY2N,AX		; y2.

	; box x,y

	MOV	AX,WDY1N		; y1
	MOV	WDY1,AX			; y1

	MOV	AX,WDY2N		; y2
	INC	AX			;+1
	MOV	WDY2,AX			; y2

	; box.

	MOV	AX,WDX1N		; x1
	DEC	AX			; -1
	MOV	WDX1,AX			; x1
	CALL	SIDEMENU_Y_LINE		; ｻｲﾄﾞﾒﾆｭｰ表・縦線

	MOV	AX,WDX1N		; x1
	ADD	AX,SD_H_DOT_LEN_X	; sidemenu 表横幅
	DEC	AX			; -1
	MOV	WDX1,AX			; x1
	CALL	SIDEMENU_Y_LINE		; ｻｲﾄﾞﾒﾆｭｰ表・縦線

	MOVX	WDX1,WDX1N		; x1
	MOVX	WDY1,WDY1N		; y1
	MOVX	WDX2,WDX2N		; x2
	MOV	CX,LINE_KOMOKU_SD	; 項目行数(ｻｲﾄﾞﾒﾆｭｰ)
	INC	CX			; + 1
SIDEMENU_HYO_LOOP:
	PUSH	CX
	CALL	SIDEMENU_X_LINE		; ｻｲﾄﾞﾒﾆｭｰ表・横線
	ADDX	WDY1,WINDSD_HIGHT	; sidemenu １行高さ
	POP	CX
	LOOP	SIDEMENU_HYO_LOOP
SIDEMENU_HYO_EXIT:
	RET
SIDEMENU_HYO	ENDP


; ****************************************************
;	ｻｲﾄﾞﾒﾆｭｰ表・横線
; ****************************************************

SIDEMENU_X_LINE	PROC	NEAR
	MOV	AX,WDX1			; dot x1.
	MOV	BX,WDY1			; y1.
	MOV	CX,WDX2			; dot x2.
	MOV	VX1,AX			; start dot point x1.
	MOV	VY1,BX			; line hight y1.
	MOV	VX2,CX			; end dot point x2.
	MOV	CX,2			; line width.
	MOV	VCOL,4			; color.
	CALLE	DLINEH			; 水平ライン描画
	RET
SIDEMENU_X_LINE	ENDP


; ****************************************************
;	ｻｲﾄﾞﾒﾆｭｰ表・縦線
; ****************************************************

SIDEMENU_Y_LINE	PROC	NEAR
	MOV	AX,WDX1			; dot x1.
	MOV	BX,WDY1			; y1.
	MOV	CX,WDY2			; y2.
	MOV	VX1,AX			; line dot point x.
	MOV	VY1,BX			; start line point y1.
	MOV	VY2,CX			; end line point y2.
	MOV	CX,2			; line width.
	MOV	VCOL,4			; color.
	CALLE	DLINEV			; 垂直ライン描画
	RET
SIDEMENU_Y_LINE	ENDP


; ****************************************************
;	cursole put.
;	-I- DAT_FILE_NUM : データファイル番号
; ****************************************************

CURSOLE_PUT	PROC	NEAR
	CMPX	DAT_FILE_NUM,CUR_BACK_NUM	; cursole back ﾃﾞｰﾀﾌｧｲﾙ番号
	JE	CURSOLE_PUT_EXIT		;

	CMP	CUR_BACK_NUM,OFFF		; cursole back ﾃﾞｰﾀﾌｧｲﾙ番号
	JE	CURSOLE_PUT_3			;

	CALLE	MSCSTP				; カーソルストップ
	CALL	CURSOLE_RESTOR			; cursole restore.
	CALLE	MSCSRT				; カーソルスタート

CURSOLE_PUT_3:
	CMP	DAT_FILE_NUM,OFFF		; データファイル番号
	JE	CURSOLE_PUT_6			;

	CALLE	MSCSTP				; カーソルストップ
	CALL	CURSOLE_XY			; cursole locate.
	CALL	CURSOLE_BACK			; cursole back.
	CALL	CURSOLE_PAT			; cursole pattern.
	CALLE	MSCSRT				; カーソルスタート

CURSOLE_PUT_6:
	MOVX	CUR_BACK_NUM,DAT_FILE_NUM	; cursole back ﾃﾞｰﾀﾌｧｲﾙ番号

CURSOLE_PUT_EXIT:
	RET
CURSOLE_PUT	ENDP


; ****************************************************
;	cursole pattern.
;	-I- WID_CUR_X : cursole x.
;	    WID_CUR_Y : cursole y.
; ****************************************************

CURSOLE_PAT	PROC	NEAR
	MOV	AX,WID_CUR_X		; cursole x.
	MOV	BX,WID_CUR_Y		; cursole y.
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SUB	AX,1
	MOV	VX1,AX			; start dot point x1.
	MOV	VY1,BX			; line hight y1.
	ADD	AX,WID_CUR_SIZ_DOT_XL	; window ｶｰｿﾙｻｲｽﾞdotX
	MOV	VX2,AX			; end dot point x2.

	MOV	CX,1			; line width.
	MOV	VCOL,COL_CURSOLE_H	; hi light color.
	CALLE	DLINEH			; 水平ライン描画

	INC	VY1			; +1
	MOV	CX,2			; line width.
	MOV	VCOL,COL_CURSOLE	; color.
	CALLE	DLINEH			; 水平ライン描画

	ADDX	VY1,WID_CUR_SIZ_YL	; window ｶｰｿﾙｻｲｽﾞY
	MOV	CX,1			; line width.
	MOV	VCOL,COL_CURSOLE_H	; hi light color.
	CALLE	DLINEH			; 水平ライン描画

	INC	VY1			; +1
	MOV	CX,2			; line width.
	MOV	VCOL,COL_CURSOLE	; color.
	CALLE	DLINEH			; 水平ライン描画

	ADD	VY1,2			;
	MOV	CX,1			; line width.
	MOV	VCOL,COL_CURSOLE_B	; color.
	CALLE	DLINEH			; 水平ライン描画


	MOV	AX,WID_CUR_X		; cursole x.
	MOV	BX,WID_CUR_Y		; cursole y.
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SUB	AX,1
	MOV	VX1,AX			; line dot point x.
	INC	BX			;
	MOV	VY1,BX			; start line point y1.
	ADD	BX,WID_CUR_SIZ_YL	; window ｶｰｿﾙｻｲｽﾞY
	MOV	VY2,BX			; end line point y2.

	ADD	VY2,2			; end line point y2.
	MOV	CX,1			; line width.
	MOV	VCOL,COL_CURSOLE_H	; hi light color.
	CALLE	DLINEV			; 垂直ライン描画
	INC	VX1			;
	SUB	VY2,2			; end line point y2.
	MOV	CX,2			; line width.
	MOV	VCOL,COL_CURSOLE	; color.
	CALLE	DLINEV			; 垂直ライン描画
	ADDX	VX1,WID_CUR_SIZ_DOT_XL	; window ｶｰｿﾙｻｲｽﾞdotX
	SUB	VX1,3			;
	ADD	VY1,2			; start line point y1.
	MOV	CX,1			; line width.
	MOV	VCOL,COL_CURSOLE_H	; hi light color.
	CALLE	DLINEV			; 垂直ライン描画
	INC	VX1			;
	SUB	VY1,2			; start line point y1.
	MOV	CX,2			; line width.
	MOV	VCOL,COL_CURSOLE	; color.
	CALLE	DLINEV			; 垂直ライン描画
	ADD	VX1,2			; line dot point x.
	SUB	VY1,1			; start line point y1.
	ADD	VY2,3			; end line point y2.
	MOV	CX,1			; line width.
	MOV	VCOL,COL_CURSOLE_B	; color.
	CALLE	DLINEV			; 垂直ライン描画

	RET
CURSOLE_PAT	ENDP


; ****************************************************
;	cursole back.
;	-I- WID_CUR_X : cursole x.
;	    WID_CUR_Y : cursole y.
; ****************************************************

CURSOLE_BACK	PROC	NEAR
	MOV	AX,WID_CUR_X		; cursole x.
	MOV	BX,WID_CUR_Y		; cursole y.
	DEC	AX			;
	MOV	WID_CUR_BAK_X,AX	; cursole back x.
	MOV	WID_CUR_BAK_Y,BX	; cursole back y.

	MOV	DX,WID_CUR_BANK		; ｶｰｿﾙ待避バンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.

	CALLE	PT_PATTERN_CLEAR	; parts buffer clear.

	MOV	AX,WID_CUR_BAK_X	; cursole back x.
	MOV	BX,WID_CUR_BAK_Y	; cursole back y.
	MOV	CX,WID_CUR_BAK_XL	; cursole back 待避ｻｲｽﾞx.
	MOV	DX,WID_CUR_BAK_YL	; cursole back 待避ｻｲｽﾞy.
	CALLE	PT_PATTERN_GET		; parts get.

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.
	RET
CURSOLE_BACK	ENDP


; ****************************************************
;	cursole restore.
; ****************************************************

CURSOLE_RESTOR	PROC	NEAR
	MOV	DX,WID_CUR_BANK		; ｶｰｿﾙ待避バンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.

	MOV	AX,WID_CUR_BAK_X	; cursole back x.
	MOV	BX,WID_CUR_BAK_Y	; cursole back y.
	MOV	DX,0			; pattern number.
	CALLE	PT_PATTERN_PUT		; pattern put.

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.
	RET
CURSOLE_RESTOR	ENDP


; ****************************************************
;	ウインドウエリア待避
;	-I- WINDOW_X1  : window 左上Ｘ
;	    WINDOW_Y1  : window 左上Ｙ
;	    WINDOW_XL  : window 待避サイズＸ
;	    WINDOW_YL  : window 待避サイズＹ
;	    WINDOW_BAK_BANK : window エリア待避バンク番号
; ****************************************************

WIDAREA_BACK	PROC	NEAR
	MOV	CX,0			;0=ARAVRM : ＶＲＡＭプレーン
	MOV	DX,0			;0=SSGR0  : visual data segment plean.
	CALLE	VRAMASSIGN		; vram assign.

	MOV	DX,WINDOW_BAK_BANK	; window エリア待避バンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.

	CALLE	PT_PATTERN_CLEAR	; parts buffer clear.

	MOV	AX,WINDOW_X1		; window 左上Ｘ
	MOV	BX,WINDOW_Y1		; window 左上Ｙ
	MOV	CX,WINDOW_XL		; window 待避サイズＸ
	MOV	DX,WINDOW_YL		; window 待避サイズＹ
	CALLE	PT_PATTERN_GET		; parts get.

	MOV	AX,WINDSD_X1		; sidemenu 左上Ｘ
	MOV	BX,WINDSD_Y1		; sidemenu 左上Ｙ
	MOV	CX,WINDSD_XL		; sidemenu 待避サイズＸ
	MOV	DX,WINDSD_YL		; sidemenu 待避サイズＹ
	CALLE	PT_PATTERN_GET		; parts get.

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.

	RET
WIDAREA_BACK	ENDP


; ****************************************************
;	ウインドウエリア復元
;	-I- WINDOW_BAK_BANK : window エリア待避バンク番号
; ****************************************************

WIDAREA_RESTOR	PROC	NEAR
	MOV	CX,0			;0=ARAVRM : ＶＲＡＭプレーン
	MOV	DX,0			;0=SSGR0  : visual data segment plean.
	CALLE	VRAMASSIGN		; vram assign.

	MOV	DX,WINDOW_BAK_BANK	; window エリア待避バンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.

	MOV	AX,WINDOW_X1		; window 左上Ｘ
	MOV	BX,WINDOW_Y1		; window 左上Ｙ
	MOV	DX,0			; pattern number.
	CALLE	PT_PATTERN_PUT		;pattern put.

	MOV	AX,WINDSD_X1		; sidemenu 左上Ｘ
	MOV	BX,WINDSD_Y1		; sidemenu 左上Ｙ
	MOV	DX,1			; pattern number.
	CALLE	PT_PATTERN_PUT		;pattern put.

	RET
WIDAREA_RESTOR	ENDP


; ****************************************************
;	テキスト描画クリア
;	-I- AX : x.
;	    BX : y.
;	    CX : length.
; ****************************************************

TXBOX	PROC	NEAR
	JCXZ	TXBOX_EXIT

	MOV	VX1,AX			; start point.
	MOV	VY1,BX			; start point.
	ADD	AX,CX			; length.
	DEC	AX			;
	ADD	BX,15			;
	MOV	VX2,AX			; end point.
	MOV	VY2,BX			; end point.

	MOV	CX,4			; color1 palet number.
	MOV	BX,0			; color2 palet number.
	CALLE	BOXMCH			; ＢＯＸチェック模様

TXBOX_EXIT:
	RET
TXBOX	ENDP


; ****************************************************
;	main DATA segment to memory.
;	-I- SI : source offset.(DATA)
;	    DI : destination pointer.
;	    CX : move counter.
; ****************************************************

MDATACOPY	PROC	NEAR
	PUSH	DI
	PUSH	SI
	CALLE	DS_GET_TO_MAIN		; ﾃﾞｰﾀｾｸﾞﾒﾝﾄ取得
	POP	SI			;
	POP	DI			;
	PUSH	DS			;
	MOVX	ES,DS			;
	MOV	DS,DX			;
	REP	MOVSB			;
	POP	DS			;
	RET
MDATACOPY	ENDP


; ****************************************************
;	memory to memory copy.
;	-I/O- SI : source pointer.
;	      DI : destination  pointer.
;	      CX : move counter.
; ****************************************************

MEMCOPY	PROC	NEAR
	PUSH	ES
	PUSH	DS
	POP	ES
	REP	MOVSB
	POP	ES
	RET
MEMCOPY	ENDP


; ****************************************************
;	memory clear.
;	-I- DI : destination  pointer.
;	    CX : move counter.
; ****************************************************

MEMCLEAR	PROC	NEAR
	PUSH	ES
	PUSH	DS
	POP	ES
	MOV	AL,0
	REP	STOSB
	POP	ES
	RET
MEMCLEAR	ENDP


; ****************************************************
;	文字列長さスペースまで
;	-I- DS:DI : 文字列アドレス
;	-O- CX    : 表示単語長さ
; ****************************************************

STRLENG	PROC	NEAR
	PUSH	DI

	MOV	CX,256
STRLENG_LOOP:
	MOV	AL,DS:[DI]
	INC	DI
	CMP	AL,' '
	JBE	STRLENG_LOOP_E
	LOOP	STRLENG_LOOP

	MOV	CX,256
	POP	DI
	RET

STRLENG_LOOP_E:
	NEG	CX
	ADD	CX,256

	POP	DI
	RET
STRLENG	ENDP


; ****************************************************
;	data.
; ****************************************************

EXTRN	DEBUGXX:WORD			; debug mode.
					;デモフラグ0=通常,55=ランダムセレクト

EXTRN	VX1:WORD			; point x1.
EXTRN	VY1:WORD			; point y1.
EXTRN	VX2:WORD			; point x2.
EXTRN	VY2:WORD			; point y2.
EXTRN	VX3:WORD			; point x3.
EXTRN	VY3:WORD			; point y3.
EXTRN	VCOL:WORD			; color.

WINDOW_BAK_BANK	DW	WD_INI_BAK_BANK	; window エリア待避バンク番号

WINDOW_X1	DW	WD_INI_X1	; window 左上Ｘ
WINDOW_Y1	DW	WD_INI_Y1	; window 左上Ｙ
WINDOW_X2	DW	WD_INI_XL	; window フレームサイズＸ
WINDOW_Y2	DW	WD_INI_YL	; window フレームサイズＹ
WINDOW_XL	DW	WD_INI_XL	; window 待避サイズＸ
WINDOW_YL	DW	WD_INI_YL	; window 待避サイズＹ
WINDOW_OFS_X	DW	WD_INI_OFS_X	; window 項目表示ｵﾌｾｯﾄX
WINDOW_OFS_Y	DW	WD_INI_OFS_Y	; window 項目表示ｵﾌｾｯﾄY
WINDOW_HIGHT	DW	WD_INI_HIGHT	; window １行高さ
WINDOW_CUROF_X	DW	WD_INI_CUROF_X	; window ｶｰｿﾙｵﾌｾｯﾄX
WINDOW_CUROF_Y	DW	WD_INI_CUROF_Y	; window ｶｰｿﾙｵﾌｾｯﾄY

WINDOW_H_OFS_DOT_X DW	WD_INI_H_OFS_DOT_X	; window 項目表ｵﾌｾｯﾄdotX
WINDOW_H_OFS_Y	DW	WD_INI_H_OFS_Y		; window 項目表ｵﾌｾｯﾄY

WINDOW_NUMB_OFS_X DW	WD_INI_NUMB_OFS_X	; window 番号位置
WINDOW_DATE_OFS_X DW	WD_INI_DATE_OFS_X	; window 日付位置
WINDOW_NAME_OFS_X DW	WD_INI_NAME_OFS_X	; window 名前位置

H_DOT_LEN_X	DW	INI_H_DOT_LEN_X		; 項目表横幅
H_D_LOC_1_X	DW	INI_H_D_LOC_1_X		; 縦棒1
H_D_LOC_2_X	DW	INI_H_D_LOC_2_X		; 縦棒2

WID_KLOC_X	DW	0			; 項目X
WID_KLOC_Y	DW	0			; 項目Y

WID_BANG_X	DW	0			; 項目番号表示X
WID_BANG_Y	DW	0			; 項目番号表示Y

WID_DATE_X	DW	0			; 項目日付表示X
WID_DATE_Y	DW	0			; 項目日付表示Y

WID_NAME_X	DW	0			; 項目名前表示X
WID_NAME_Y	DW	0			; 項目名前表示Y

WID_MESS_X	DW	0			; 項目ﾒｯｾｰｼﾞ表示X
WID_MESS_Y	DW	0			; 項目ﾒｯｾｰｼﾞ表示Y

WID_CUR_BANK	DW	WD_INI_BAK_CURS		; ｶｰｿﾙ待避バンク番号
WID_CUR_X	DW	0			; cursole x.
WID_CUR_Y	DW	0			; cursole y.

WID_CUR_SIZ_DOT_XL DW	WD_INI_CUR_DOT_XL	; window ｶｰｿﾙｻｲｽﾞdotX
WID_CUR_SIZ_YL	DW	WD_INI_CUR_YL		; window ｶｰｿﾙｻｲｽﾞY

WID_CUR_ARA_X1	DW	0			; cursole area x1.
WID_CUR_ARA_Y1	DW	0			; cursole area y1.
WID_CUR_ARA_X2	DW	0			; cursole area x2.
WID_CUR_ARA_Y2	DW	0			; cursole area y2.
WID_CUR_ARA_XL	DW	WD_INI_CUR_AREA_X	; cursole ｴﾘｱｻｲｽﾞx.
WID_CUR_ARA_YL	DW	WD_INI_CUR_AREA_Y	; cursole ｴﾘｱｻｲｽﾞy.

WID_CUR_BAK_X	DW	0			; cursole back x.
WID_CUR_BAK_Y	DW	0			; cursole back y.
WID_CUR_BAK_XL	DW	WD_INI_CUR_BAK_XL	; cursole back 待避ｻｲｽﾞx.
WID_CUR_BAK_YL	DW	WD_INI_CUR_BAK_YL	; cursole back 待避ｻｲｽﾞy.

WINDSD_X1	DW	WD_INI_SD_X1		; sidemenu 左上Ｘ
WINDSD_Y1	DW	WD_INI_SD_Y1		; sidemenu 左上Ｙ
WINDSD_X2	DW	WD_INI_SD_XL		; sidemenu ﾌﾚｰﾑｻｲｽﾞx.
WINDSD_Y2	DW	WD_INI_SD_YL		; sidemenu ﾌﾚｰﾑｻｲｽﾞy.
WINDSD_XL	DW	WD_INI_SD_XL		; sidemenu 待避サイズＸ
WINDSD_YL	DW	WD_INI_SD_YL		; sidemenu 待避サイズＹ
WINDSD_OFS_X	DW	WD_INI_SD_OFS_X		; sidemenu 項目表示ｵﾌｾｯﾄX
WINDSD_OFS_Y	DW	WD_INI_SD_OFS_Y		; sidemenu 項目表示ｵﾌｾｯﾄY
WINDSD_HIGHT	DW	WD_INI_SD_HIGHT		; sidemenu １行高さ
WINDSD_CUROF_X	DW	WD_INI_SD_CUROF_X	; sidemenu ｶｰｿﾙｵﾌｾｯﾄX
WINDSD_CUROF_Y	DW	WD_INI_SD_CUROF_Y	; sidemenu ｶｰｿﾙｵﾌｾｯﾄY

WINDSD_H_OFS_DOT_X DW	WD_INI_SD_H_OFS_DOT_X	; sidemenu 表ｵﾌｾｯﾄdotX
WINDSD_H_OFS_Y	DW	WD_INI_SD_H_OFS_Y	; sidemenu 表ｵﾌｾｯﾄY

SD_H_DOT_LEN_X	DW	INI_SD_H_DOT_LEN_X	; sidemenu 表横幅

CUR_BACK_NUM	DW	OFFF			; cursole back ﾃﾞｰﾀﾌｧｲﾙ番号

DAT_FILE_NUM	DW	0			; データファイル番号

LINE_KOMOKU	DW	INI_LINE_KOMOKU		; 項目行数
LINE_KOMOKU_SD	DW	INI_LINE_KOMOKU_SD	; 項目行数(ｻｲﾄﾞﾒﾆｭｰ)

MOUSE_X		DW	0			; mouse x.
MOUSE_Y		DW	0			; mouse y.
MUSBOTTONL	DB	0,0			; 左ボタン(1:OFF/0:ON)
MUSBOTTONR	DB	0,0			; 右ボタン(1:OFF/0:ON)

WDX1N		DW	0			; x1
WDY1N		DW	0			; y1
WDX2N		DW	0			; x2
WDY2N		DW	0			; y2

WDX1		DW	0			; x1
WDY1		DW	0			; y1
WDX2		DW	0			; x2
WDY2		DW	0			; y2

CHR_COLOR	DW	1		; character color.
CHR_SIZE	DW	0		; 0=16x16  1=32x32  2=16x24  3=16x32

P_NUMBER	DW	0			; 番号
P_YEAR		DW	0			; 年
P_MONTH		DW	0			; 月
P_WEEK		DW	0			; 曜日
P_DAY		DW	0			; 日
P_NAME		DW	0			; 名前

TBL_YEAR	DW	TBL_KOMOKU_DIM DUP (0)	; 年
TBL_MONTH	DW	TBL_KOMOKU_DIM DUP (0)	; 月
TBL_WEEK	DW	TBL_KOMOKU_DIM DUP (0)	; 曜日
TBL_DAY		DW	TBL_KOMOKU_DIM DUP (0)	; 日
TBL_NAME	LABEL	WORD			; 名前
	DW BUF01,BUF02,BUF03,BUF04,BUF05,BUF06,BUF07,BUF08,BUF09,BUF10
BUF01		DB	TBL_NAME_LEN DUP (0),0,0
BUF02		DB	TBL_NAME_LEN DUP (0),0,0
BUF03		DB	TBL_NAME_LEN DUP (0),0,0
BUF04		DB	TBL_NAME_LEN DUP (0),0,0
BUF05		DB	TBL_NAME_LEN DUP (0),0,0
BUF06		DB	TBL_NAME_LEN DUP (0),0,0
BUF07		DB	TBL_NAME_LEN DUP (0),0,0
BUF08		DB	TBL_NAME_LEN DUP (0),0,0
BUF09		DB	TBL_NAME_LEN DUP (0),0,0
BUF10		DB	TBL_NAME_LEN DUP (0),0,0

STR_GIRL_NAME	DB	TBL_NAME_LEN DUP (0),0,0	; 娘の名前

STR_MESSAGE	DB	MESSAGE_LEN DUP (0),0,0	; メッセージ

NAME_WEEK	DW	NAME_W_1,NAME_W_2,NAME_W_3,NAME_W_4,NAME_W_5
		DW	NAME_W_6,NAME_W_7
NAME_W_1	DB	"Sun",0
NAME_W_2	DB	"Mon",0
NAME_W_3	DB	"Tue",0
NAME_W_4	DB	"Wed",0
NAME_W_5	DB	"Thu",0
NAME_W_6	DB	"Fri",0
NAME_W_7	DB	"Sat",0

KNJ_TEN		DB	"・"

STR_HED_BANG	DB	HED_BANG_LEN DUP (0),0,0	; ﾍｯﾀﾞ番号
STR_HED_DATE	DB	HED_DATE_LEN DUP (0),0,0	; ﾍｯﾀﾞ日付
STR_HED_NAME	DB	HED_NAME_LEN DUP (0),0,0	; ﾍｯﾀﾞ名前

		;	"1222/12/12 MON"
		;	 12345678901234
STR_DATE	DB	14 DUP (0),0,0		; string date.

CODE	ENDS

	END
;
;	end of "WIDDATSL.ASM"
;
