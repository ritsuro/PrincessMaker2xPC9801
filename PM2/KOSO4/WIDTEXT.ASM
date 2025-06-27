; "WIDTEXT.ASM" PC-9801UV11 make by R.H 1992/05/20
;
;
;	ＷＩＮＤＯＷＳ／ＴＥＸＴウインドウ
;
;
;	WID_TEXT_OPEN		; WINDOWS/テキストウインドウＯＰＥＮ
;	WID_TEXT_CLOSE		; WINDOWS/テキストウインドウＣＬＯＳＥ
;	WID_TEXT_STRIME		; WINDOWS/テキストウインドウ選択
;	WID_TEXT_PRINT		; WINDOWS/テキストウインドウ表示
;	WID_TEXT_PAUSE		; WINDOWS/テキストウインドウＰＡＵＳＥ
;	WID_TEXT_LF		; WINDOWS/テキストウインドウ改行
;	WID_TEXT_KNJ		; WINDOWS/テキストウインドウ漢字表示
;	WID_TEXT_ANK		; WINDOWS/テキストウインドウＡＮＫ表示
;	WID_TEXT_CLR		; WINDOWS/テキストウインドウクリア
;	WID_TEXT_FACE		; WINDOWS/テキストウインドウフェイス
;	WID_TEXT_FACEGIRL	; WINDOWS/テキストウインドウ娘フェイス
;	WID_TEXT_FACESYUGO	; WINDOWS/テキストウインドウ守護星フェイス
;	WID_TEXT_CURRENT	; WINDOWS/テキストウインドウカレントの取得
;	WID_TEXT_LOCATE		; WINDOWS/テキストウインドウ位置
;	WID_TEXT_BACK_DIS	; WINDOWS/テキストウインドウ退避のを止める
;	WID_TEXT_ONLY_FACE	; WINDOWS/テキストウインドウ ﾌｪｲｽのみ
;	WID_TEXT_ONLY_FACEGIRL	; WINDOWS/テキストウインドウ 娘ﾌｪｲｽのみ
;	WID_TEXT_ONLY_FACESYUGO	; WINDOWS/テキストウインドウ 守護星ﾌｪｲｽのみ
;	WID_TEXT_TIMER		; WINDOWS/テキストウインドウタイマ
;	WID_TEXT_PAC		; WINDOWS/テキストウインドウ文字送りﾀｲﾏ
;
;
;
;	ハンドル数をふやしたら、TALKER　のハンドル数も増やしておく。
;
;			テキスト・タイプ
;
;		    table	handle	bank->show"KS2TBL.ASM"
;		TEXT_STYLE_01	1	1	; 説明テキスト window
;		TEXT_STYLE_02	2	1	; 相手テキスト window
;		TEXT_STYLE_03	3	2	; 娘テキスト window
;		TEXT_STYLE_04	4	-	; デバッグテキスト window
;		TEXT_STYLE_05	5	3	; 小型テキスト window
;		TEXT_STYLE_06	5	6	; 鍛える・仕事テキスト window
;		TEXT_STYLE_07	2	11	; バトル・メインテキスト window
;		TEXT_STYLE_08	3	12	; バトル・娘テキスト window
;		TEXT_STYLE_09	6	7	; 小さい娘テキスト window
;		TEXT_STYLE_10	1	8	; 説明テキスト2 window
;		TEXT_STYLE_11	3	2	; 守護星 window
;		TEXT_STYLE_12	1	-	; 武闘会用 window
;		TEXT_STYLE_13	1	19	; ｴﾝﾃﾞｨﾝｸﾞ用1 window
;		TEXT_STYLE_14	2	20	; ｴﾝﾃﾞｨﾝｸﾞ用2 window
;		TEXT_STYLE_15	3	21	; ｴﾝﾃﾞｨﾝｸﾞ用3 window
;		TEXT_STYLE_16	1	11	; 武闘会用２(f1) window
;		TEXT_STYLE_17	2	12	; 武闘会用３(f2) window
;		TEXT_STYLE_18	3	8	; 武闘会用４(na) window
;		TEXT_STYLE_19	3	2	; ｴﾝﾃﾞｨﾝｸﾞ守護星window
;
;	"TALKER.ASM" line 540-
;
;		HANDLE_AREA_ADRS LABEL	WORD
;			DW	HANDLE01,...,HANDLE05
;		HANDLE01 DB	1,(NOW_HANDLE_END-NOW_HANDLE_TOP) DUP (0)
;		...
;		HANDLE05 DB	1,(NOW_HANDLE_END-NOW_HANDLE_TOP) DUP (0)
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC
INCLUDE	MACHINEX.INC

DEF_WD1_XP	EQU	4		; window 左上Ｘ
DEF_WD1_YP	EQU	275		; window 左上Ｙ
DEF_WD1_XL	EQU	39		; window フレームサイズＸ
DEF_WD1_YL	EQU	100		; window フレームサイズＹ
DEF_WD1_BAK	EQU	1		; window エリア退避バンク番号
DEF_WD1_F_BAK	EQU	0		; window フェイス退避フラグ
DEF_WD1_XF	EQU	39		; window フェイス左上Ｘ
DEF_WD1_YF	EQU	275		; window フェイス左上Ｙ
DEF_WD1_XFB	EQU	39-1		; window フェイス退避Ｘ
DEF_WD1_YFB	EQU	275-8		; window フェイス退避Ｙ
DEF_WD1_XFL	EQU	14		; window フェイスサイズＸ
DEF_WD1_YFL	EQU	120		; window フェイスサイズＹ

DEF_WD2_XP	EQU	18		; window 左上Ｘ
DEF_WD2_YP	EQU	160		; window 左上Ｙ
DEF_WD2_XL	EQU	31		; window フレームサイズＸ
DEF_WD2_YL	EQU	120		; window フレームサイズＹ
DEF_WD2_BAK	EQU	1		; window エリア退避バンク番号
DEF_WD2_F_BAK	EQU	1		; window フェイス退避フラグ
DEF_WD2_XF	EQU	4		; window フェイス左上Ｘ
DEF_WD2_YF	EQU	168		; window フェイス左上Ｙ
DEF_WD2_XFB	EQU	4-1		; window フェイス退避Ｘ
DEF_WD2_YFB	EQU	168-8		; window フェイス退避Ｙ
DEF_WD2_XFL	EQU	14		; window フェイスサイズＸ
DEF_WD2_YFL	EQU	120		; window フェイスサイズＹ

DEF_WD3_XP	EQU	31		; window 左上Ｘ
DEF_WD3_YP	EQU	262		; window 左上Ｙ
DEF_WD3_XL	EQU	31		; window フレームサイズＸ
DEF_WD3_YL	EQU	120		; window フレームサイズＹ
DEF_WD3_BAK	EQU	2		; window エリア退避バンク番号
DEF_WD3_F_BAK	EQU	1		; window フェイス退避フラグ
DEF_WD3_XF	EQU	64		; window フェイス左上Ｘ
DEF_WD3_YF	EQU	270		; window フェイス左上Ｙ
DEF_WD3_XFB	EQU	64-1		; window フェイス退避Ｘ
DEF_WD3_YFB	EQU	270-8		; window フェイス退避Ｙ
DEF_WD3_XFL	EQU	14		; window フェイスサイズＸ
DEF_WD3_YFL	EQU	120		; window フェイスサイズＹ

DEF_WD5_XP	EQU	44		; window 左上Ｘ
DEF_WD5_YP	EQU	100		; window 左上Ｙ
DEF_WD5_XL	EQU	31		; window フレームサイズＸ
DEF_WD5_YL	EQU	60		; window フレームサイズＹ
DEF_WD5_BAK	EQU	3		; window エリア退避バンク番号
DEF_WD5_F_BAK	EQU	0		; window フェイス退避フラグ
DEF_WD5_XF	EQU	1		; window フェイス左上Ｘ
DEF_WD5_YF	EQU	1		; window フェイス左上Ｙ
DEF_WD5_XFB	EQU	1		; window フェイス退避Ｘ
DEF_WD5_YFB	EQU	1		; window フェイス退避Ｙ
DEF_WD5_XFL	EQU	1		; window フェイスサイズＸ
DEF_WD5_YFL	EQU	1		; window フェイスサイズＹ

DEF_WD6_XP	EQU	46		; window 左上Ｘ
DEF_WD6_YP	EQU	192		; window 左上Ｙ
DEF_WD6_XL	EQU	31		; window フレームサイズＸ
DEF_WD6_YL	EQU	128+16		; window フレームサイズＹ
DEF_WD6_BAK	EQU	6;4		; window エリア退避バンク番号
DEF_WD6_F_BAK	EQU	0		; window フェイス退避フラグ
DEF_WD6_XF	EQU	1		; window フェイス左上Ｘ
DEF_WD6_YF	EQU	1		; window フェイス左上Ｙ
DEF_WD6_XFB	EQU	1		; window フェイス退避Ｘ
DEF_WD6_YFB	EQU	1		; window フェイス退避Ｙ
DEF_WD6_XFL	EQU	1		; window フェイスサイズＸ
DEF_WD6_YFL	EQU	1		; window フェイスサイズＹ

DEF_WD7_XP	EQU	4		; window 左上Ｘ
DEF_WD7_YP	EQU	275		; window 左上Ｙ
DEF_WD7_XL	EQU	28		; window フレームサイズＸ
DEF_WD7_YL	EQU	100		; window フレームサイズＹ
DEF_WD7_BAK	EQU	1		; window エリア退避バンク番号
DEF_WD7_F_BAK	EQU	0		; window フェイス退避フラグ
DEF_WD7_XF	EQU	39		; window フェイス左上Ｘ
DEF_WD7_YF	EQU	275		; window フェイス左上Ｙ
DEF_WD7_XFB	EQU	39-1		; window フェイス退避Ｘ
DEF_WD7_YFB	EQU	275-8		; window フェイス退避Ｙ
DEF_WD7_XFL	EQU	14		; window フェイスサイズＸ
DEF_WD7_YFL	EQU	120		; window フェイスサイズＹ

DEF_WD8_XP	EQU	44		; window 左上Ｘ
DEF_WD8_YP	EQU	290		; window 左上Ｙ
DEF_WD8_XL	EQU	34		; window フレームサイズＸ
DEF_WD8_YL	EQU	100		; window フレームサイズＹ
DEF_WD8_BAK	EQU	12		; window エリア退避バンク番号
DEF_WD8_F_BAK	EQU	0		; window フェイス退避フラグ
DEF_WD8_XF	EQU	1		; window フェイス左上Ｘ
DEF_WD8_YF	EQU	1		; window フェイス左上Ｙ
DEF_WD8_XFB	EQU	1		; window フェイス退避Ｘ
DEF_WD8_YFB	EQU	1		; window フェイス退避Ｙ
DEF_WD8_XFL	EQU	14		; window フェイスサイズＸ
DEF_WD8_YFL	EQU	120		; window フェイスサイズＹ

DEF_WD9_XP	EQU	31		; window 左上Ｘ
DEF_WD9_YP	EQU	282		; window 左上Ｙ
DEF_WD9_XL	EQU	17		; window フレームサイズＸ
DEF_WD9_YL	EQU	120		; window フレームサイズＹ
DEF_WD9_BAK	EQU	7;2		; window エリア退避バンク番号
DEF_WD9_F_BAK	EQU	1		; window フェイス退避フラグ
DEF_WD9_XF	EQU	50		; window フェイス左上Ｘ
DEF_WD9_YF	EQU	290		; window フェイス左上Ｙ
DEF_WD9_XFB	EQU	50-1		; window フェイス退避Ｘ
DEF_WD9_YFB	EQU	290-8		; window フェイス退避Ｙ
DEF_WD9_XFL	EQU	14		; window フェイスサイズＸ
DEF_WD9_YFL	EQU	120		; window フェイスサイズＹ

DEF_WD10_XP	EQU	4		; window 左上Ｘ
DEF_WD10_YP	EQU	275		; window 左上Ｙ
DEF_WD10_XL	EQU	39		; window フレームサイズＸ
DEF_WD10_YL	EQU	100		; window フレームサイズＹ
DEF_WD10_BAK	EQU	8	;<===	; window エリア退避バンク番号
DEF_WD10_F_BAK	EQU	0		; window フェイス退避フラグ
DEF_WD10_XF	EQU	39		; window フェイス左上Ｘ
DEF_WD10_YF	EQU	275		; window フェイス左上Ｙ
DEF_WD10_XFB	EQU	39-1		; window フェイス退避Ｘ
DEF_WD10_YFB	EQU	275-8		; window フェイス退避Ｙ
DEF_WD10_XFL	EQU	14		; window フェイスサイズＸ
DEF_WD10_YFL	EQU	120		; window フェイスサイズＹ

DEF_WD11_XP	EQU	31		; window 左上Ｘ
DEF_WD11_YP	EQU	282		; window 左上Ｙ
DEF_WD11_XL	EQU	31		; window フレームサイズＸ
DEF_WD11_YL	EQU	120		; window フレームサイズＹ
DEF_WD11_BAK	EQU	2		; window エリア退避バンク番号
DEF_WD11_F_BAK	EQU	1		; window フェイス退避フラグ
DEF_WD11_XF	EQU	64		; window フェイス左上Ｘ
DEF_WD11_YF	EQU	270		; window フェイス左上Ｙ
DEF_WD11_XFB	EQU	64-1		; window フェイス退避Ｘ
DEF_WD11_YFB	EQU	270-8		; window フェイス退避Ｙ
DEF_WD11_XFL	EQU	14		; window フェイスサイズＸ
DEF_WD11_YFL	EQU	156		; window フェイスサイズＹ

DEF_WD12_XP	EQU	28		; window 左上Ｘ
DEF_WD12_YP	EQU	284		; window 左上Ｙ
DEF_WD12_XL	EQU	24		; window フレームサイズＸ
DEF_WD12_YL	EQU	98		; window フレームサイズＹ
DEF_WD12_BAK	EQU	-1    ;no save	; window エリア退避バンク番号
DEF_WD12_F_BAK	EQU	0		; window フェイス退避フラグ
DEF_WD12_XF	EQU	0		; window フェイス左上Ｘ
DEF_WD12_YF	EQU	0		; window フェイス左上Ｙ
DEF_WD12_XFB	EQU	0		; window フェイス退避Ｘ
DEF_WD12_YFB	EQU	0		; window フェイス退避Ｙ
DEF_WD12_XFL	EQU	0		; window フェイスサイズＸ
DEF_WD12_YFL	EQU	0		; window フェイスサイズＹ

DEF_WD13_XP	EQU	18		; window 左上Ｘ
DEF_WD13_YP	EQU	30		; window 左上Ｙ
DEF_WD13_XL	EQU	31		; window フレームサイズＸ
DEF_WD13_YL	EQU	120		; window フレームサイズＹ
DEF_WD13_BAK	EQU	19	;<===	; window エリア退避バンク番号
DEF_WD13_F_BAK	EQU	1		; window フェイス退避フラグ
DEF_WD13_XF	EQU	4		; window フェイス左上Ｘ
DEF_WD13_YF	EQU	38		; window フェイス左上Ｙ
DEF_WD13_XFB	EQU	4-1		; window フェイス退避Ｘ
DEF_WD13_YFB	EQU	38-8		; window フェイス退避Ｙ
DEF_WD13_XFL	EQU	14		; window フェイスサイズＸ
DEF_WD13_YFL	EQU	120		; window フェイスサイズＹ

DEF_WD14_XP	EQU	18		; window 左上Ｘ
DEF_WD14_YP	EQU	160		; window 左上Ｙ
DEF_WD14_XL	EQU	31		; window フレームサイズＸ
DEF_WD14_YL	EQU	120		; window フレームサイズＹ
DEF_WD14_BAK	EQU	20	;<===	; window エリア退避バンク番号
DEF_WD14_F_BAK	EQU	1		; window フェイス退避フラグ
DEF_WD14_XF	EQU	4		; window フェイス左上Ｘ
DEF_WD14_YF	EQU	168		; window フェイス左上Ｙ
DEF_WD14_XFB	EQU	4-1		; window フェイス退避Ｘ
DEF_WD14_YFB	EQU	168-8		; window フェイス退避Ｙ
DEF_WD14_XFL	EQU	14		; window フェイスサイズＸ
DEF_WD14_YFL	EQU	120		; window フェイスサイズＹ

DEF_WD15_XP	EQU	31		; window 左上Ｘ
DEF_WD15_YP	EQU	262		; window 左上Ｙ
DEF_WD15_XL	EQU	31		; window フレームサイズＸ
DEF_WD15_YL	EQU	120		; window フレームサイズＹ
DEF_WD15_BAK	EQU	21	;<===	; window エリア退避バンク番号
DEF_WD15_F_BAK	EQU	1		; window フェイス退避フラグ
DEF_WD15_XF	EQU	64		; window フェイス左上Ｘ
DEF_WD15_YF	EQU	270		; window フェイス左上Ｙ
DEF_WD15_XFB	EQU	64-1		; window フェイス退避Ｘ
DEF_WD15_YFB	EQU	270-8		; window フェイス退避Ｙ
DEF_WD15_XFL	EQU	14		; window フェイスサイズＸ
DEF_WD15_YFL	EQU	120		; window フェイスサイズＹ

DEF_WD16_XP	EQU	28		; window 左上Ｘ
DEF_WD16_YP	EQU	240		; window 左上Ｙ
DEF_WD16_XL	EQU	34		; window フレームサイズＸ
DEF_WD16_YL	EQU	128		; window フレームサイズＹ
DEF_WD16_BAK	EQU	11		; window エリア退避バンク番号
DEF_WD16_F_BAK	EQU	1		; window フェイス退避フラグ
DEF_WD16_XF	EQU	14		; window フェイス左上Ｘ
DEF_WD16_YF	EQU	252		; window フェイス左上Ｙ
DEF_WD16_XFB	EQU	14-2		; window フェイス退避Ｘ
DEF_WD16_YFB	EQU	252-18		; window フェイス退避Ｙ
DEF_WD16_XFL	EQU	16		; window フェイスサイズＸ
DEF_WD16_YFL	EQU	140		; window フェイスサイズＹ

DEF_WD17_XP	EQU	28		; window 左上Ｘ
DEF_WD17_YP	EQU	240		; window 左上Ｙ
DEF_WD17_XL	EQU	34		; window フレームサイズＸ
DEF_WD17_YL	EQU	128		; window フレームサイズＹ
DEF_WD17_BAK	EQU	12		; window エリア退避バンク番号
DEF_WD17_F_BAK	EQU	2		; window フェイス退避フラグ
DEF_WD17_XF	EQU	63		; window フェイス左上Ｘ
DEF_WD17_YF	EQU	252		; window フェイス左上Ｙ
DEF_WD17_XFB	EQU	63-2		; window フェイス退避Ｘ
DEF_WD17_YFB	EQU	252-18		; window フェイス退避Ｙ
DEF_WD17_XFL	EQU	16		; window フェイスサイズＸ
DEF_WD17_YFL	EQU	140		; window フェイスサイズＹ

DEF_WD18_XP	EQU	28		; window 左上Ｘ
DEF_WD18_YP	EQU	240		; window 左上Ｙ
DEF_WD18_XL	EQU	34		; window フレームサイズＸ
DEF_WD18_YL	EQU	128		; window フレームサイズＹ
DEF_WD18_BAK	EQU	8		; window エリア退避バンク番号
DEF_WD18_F_BAK	EQU	0		; window フェイス退避フラグ
DEF_WD18_XF	EQU	1		; window フェイス左上Ｘ
DEF_WD18_YF	EQU	1		; window フェイス左上Ｙ
DEF_WD18_XFB	EQU	1		; window フェイス退避Ｘ
DEF_WD18_YFB	EQU	1		; window フェイス退避Ｙ
DEF_WD18_XFL	EQU	10		; window フェイスサイズＸ
DEF_WD18_YFL	EQU	10		; window フェイスサイズＹ

DEF_WD19_XP	EQU	28		; window 左上Ｘ
DEF_WD19_YP	EQU	240		; window 左上Ｙ
DEF_WD19_XL	EQU	45		; window フレームサイズＸ
DEF_WD19_YL	EQU	148		; window フレームサイズＹ
DEF_WD19_BAK	EQU	2		; window エリア退避バンク番号
DEF_WD19_F_BAK	EQU	0		; window フェイス退避フラグ
DEF_WD19_XF	EQU	1		; window フェイス左上Ｘ
DEF_WD19_YF	EQU	1		; window フェイス左上Ｙ
DEF_WD19_XFB	EQU	1		; window フェイス退避Ｘ
DEF_WD19_YFB	EQU	1		; window フェイス退避Ｙ
DEF_WD19_XFL	EQU	10		; window フェイスサイズＸ
DEF_WD19_YFL	EQU	10		; window フェイスサイズＹ


NORMAL_BANK	EQU	0		; 通常のパーツバンク番号

CHECK_MACHINE_SKIP	MACRO		; マシン別の処理スキップ
	LOCAL	L2			;
	CMP	WIDTEXT_TYPE,4		; 4=デバッグテキスト window
	JNE	L2			;
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	L2			;
	RET
L2:
	ENDM

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA


; ****************************************************
;	WINDOWS/テキストウインドウＯＰＥＮ
;	-I- DX : テキスト・タイプ
;		1=説明テキスト window
;		2=相手テキスト window
;		3=娘テキスト window
;		4=デバッグテキスト window(ＶＧＡモードのみ)
;		5=小型テキスト window(健康管理)
;		6=鍛える・仕事テキスト window
;		7=バトル・メインテキスト window
;		8=バトル・娘テキスト window
;		9=小さい娘テキスト window
;		10=説明テキスト2 window
;		11=守護星 window
;		12=武闘会用 window
;		13=ｴﾝﾃﾞｨﾝｸﾞ用1 window
;		14=ｴﾝﾃﾞｨﾝｸﾞ用2 window
;		15=ｴﾝﾃﾞｨﾝｸﾞ用3 window
;		16=武闘会用２(f1) window
;		17=武闘会用３(f2) window
;		18=武闘会用４(na) window
;
; ****************************************************

FUNC	WID_TEXT_OPEN
	MOV	WIDTEXT_TYPE,DX			; window text type.

	CHECK_MACHINE_SKIP			; マシン別の処理スキップ

	CALL_w	PT_VRAM_ID_ALL_ASSIGN		; vram ID all asigned.

	MOV	BX,WIDTEXT_TYPE			; window text type.
	DEC	BX				;
	SHL	BX,1				;
	MOV	SI,DS:WINDOW_STYLE_TABLE[BX]	; window style table.
	MOV	DI,OFFSET WINDOW_TBL_TOP	; window locaton top.
	MOVX	ES,DS				;
	MOV	CX,WINDOW_TBL_LEN		; window loc table length.
	SHR	CX,1				; word counter.
	REP	MOVSW				;

	CALL	WIDAREA_BACK			; ウインドウエリア退避

	CMP	WIDTEXT_TYPE,12			; 武闘会用 window
	JE	WID_TEXT_OPEN_3			;

	CMP	WIDTEXT_TYPE,16			; 武闘会用２(f1) window
	JE	WID_TEXT_OPEN_22		;
	CMP	WIDTEXT_TYPE,17			; 武闘会用３(f2) window
	JE	WID_TEXT_OPEN_22		;
	CMP	WIDTEXT_TYPE,18			; 武闘会用４(na) window
	JE	WID_TEXT_OPEN_22		;

	MOVX	WDX1,WINDOW_X1			; window 左上Ｘ
	MOVX	WDY1,WINDOW_Y1			; window 左上Ｙ
	MOVX	WDX2,WINDOW_X2			; window フレームサイズＸ
	MOVX	WDY2,WINDOW_Y2			; window フレームサイズＹ
	CALL_w	WID_FLAME_S_TEXT		; WINDOWS/ﾃｷｽﾄ(説明)ｳｲﾝﾄﾞｳ

	JMP	WID_TEXT_OPEN_3			;
WID_TEXT_OPEN_22:
	MOVX	WDX1,WINDOW_X1			; window 左上Ｘ
	MOVX	WDY1,WINDOW_Y1			; window 左上Ｙ
	CALL_w	WID_FLAME_SYU_TEXT		; WINDOWS/ﾃｷｽﾄ(収穫祭)ｳｲﾝﾄﾞｳ

WID_TEXT_OPEN_3:
	CMP	WINDOW_F_BAK,0			; window フェイス退避フラグ
	JE	WID_TEXT_OPEN_6			;

	CMP	WIDTEXT_TYPE,11			; 11=守護星 window
	JE	WID_TEXT_OPEN_52		;
	CMP	WIDTEXT_TYPE,16			; 武闘会用２(f1) window
	JE	WID_TEXT_OPEN_53		;
	CMP	WIDTEXT_TYPE,17			; 武闘会用３(f2) window
	JE	WID_TEXT_OPEN_53		;
	CMP	WIDTEXT_TYPE,18			; 武闘会用４(na) window
	JE	WID_TEXT_OPEN_53		;

WID_TEXT_OPEN_51:				;
	MOVX	WDX1,WINDOW_XFB			; window フェイス退避Ｘ
	MOVX	WDY1,WINDOW_YFB			; window フェイス退避Ｙ
	CALL_w	WID_FLAME_FACE			; WINDOWS/フレーム・フェイス
	JMP	WID_TEXT_OPEN_6			;

WID_TEXT_OPEN_52:				;
	MOVX	WDX1,WINDOW_XFB			; window フェイス退避Ｘ
	MOVX	WDY1,WINDOW_YFB			; window フェイス退避Ｙ
	CALL_w	WID_FLAME_FACEL			; WINDOWS/フレーム・守護星ﾌｪｲｽ
	JMP	WID_TEXT_OPEN_6			;

WID_TEXT_OPEN_53:
	MOVX	WDX1,WINDOW_XFB			; window フェイス退避Ｘ
	MOVX	WDY1,WINDOW_YFB			; window フェイス退避Ｙ
	CALL_w	WID_FLAME_FACES			; WINDOWS/フレーム・収穫祭ﾌｪｲｽ

WID_TEXT_OPEN_6:				;

	MOV	BX,WIDTEXT_TYPE			; window text type.
	DEC	BX				;
	SHL	BX,1				;
	MOV	SI,DS:TEXT_STYLE_TABLE[BX]	; text style table.
	CALL_w	TKTSTL				; 文字列表示スタイル設定

	CALL_w	TKTCLR				; 文字列表示クリア

	RET
FEND	WID_TEXT_OPEN


; ****************************************************
;	WINDOWS/テキストウインドウＣＬＯＳＥ
;	-I- DX : テキスト・タイプ
; ****************************************************

FUNC	WID_TEXT_CLOSE
	MOV	WIDTEXT_TYPE,DX			; window text type.

	CHECK_MACHINE_SKIP			; マシン別の処理スキップ

	CALL_w	PT_VRAM_ID_ALL_ASSIGN		; vram ID all asigned.

	MOV	BX,WIDTEXT_TYPE			; window text type.
	DEC	BX				;
	SHL	BX,1				;
	MOV	SI,DS:WINDOW_STYLE_TABLE[BX]	; window style table.
	MOV	DI,OFFSET WINDOW_TBL_TOP	; window locaton top.
	MOVX	ES,DS				;
	MOV	CX,WINDOW_TBL_LEN		; window loc table length.
	SHR	CX,1				; word counter.
	REP	MOVSW				;

	CALL	WIDAREA_RESTOR			; ウインドウエリア復元
	RET
FEND	WID_TEXT_CLOSE


; ****************************************************
;	WINDOWS/テキストウインドウ選択
;	-I- DX : テキスト・タイプ
; ****************************************************

FUNC	WID_TEXT_STRIME
	MOV	WIDTEXT_TYPE,DX			; window text type.

	CHECK_MACHINE_SKIP			; マシン別の処理スキップ

	MOV	BX,WIDTEXT_TYPE			; window text type.
	DEC	BX				;
	SHL	BX,1				;
	MOV	SI,DS:WINDOW_STYLE_TABLE[BX]	; window style table.
	MOV	DI,OFFSET WINDOW_TBL_TOP	; window locaton top.
	MOVX	ES,DS				;
	MOV	CX,WINDOW_TBL_LEN		; window loc table length.
	SHR	CX,1				; word counter.
	REP	MOVSW				;

	MOV	BX,WIDTEXT_TYPE			; window text type.
	DEC	BX				;
	SHL	BX,1				;
	MOV	SI,DS:TEXT_STYLE_TABLE[BX]	; text style table.
	CALL_w	TKTSTL				; 文字列表示スタイル設定
	RET
FEND	WID_TEXT_STRIME


; ****************************************************
;	WINDOWS/テキストウインドウ表示
;	-I- SI : 文字列
; ****************************************************

FUNC	WID_TEXT_PRINT
	CHECK_MACHINE_SKIP		; マシン別の処理スキップ

	MOVX	ES,DS
	CALL_w	TKTPRN			; 文字列表示
	RET
FEND	WID_TEXT_PRINT


; ****************************************************
;	WINDOWS/テキストウインドウＰＡＵＳＥ
; ****************************************************

FUNC	WID_TEXT_PAUSE
	CHECK_MACHINE_SKIP		; マシン別の処理スキップ

	CALL_w	WIDDIRSL_NOW_CLOSE	; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE

	CMP	WIDTDEMO,55		; デモフラグ0=通常,55=ランダムセレクト
	JE	WID_TEXT_PAUSE_5	;

	MOV	AX,WINDOW_X2		; window フレームサイズＸ
	MOV	BX,WINDOW_Y2		; window フレームサイズＹ
	SHR	AX,1			; / 2
	SUB	AX,2			; - 2
	SUB	BX,8;14;8		; - 10
	ADD	AX,WINDOW_X1		; window 左上Ｘ
	ADD	BX,WINDOW_Y1		; window 左上Ｙ
	CALL_w	MSWWAT			; カーソルボタン待ち
	JMP	WID_TEXT_PAUSE_EXIT	;
WID_TEXT_PAUSE_5:
	MOV	AX,WIDTDEMOWAIT		; デモ 待ち時間
	CALL_w	TMVWAT			; V-SYNC timer wait.
WID_TEXT_PAUSE_EXIT:
	RET
FEND	WID_TEXT_PAUSE


; ****************************************************
;	WINDOWS/テキストウインドウ改行
; ****************************************************

FUNC	WID_TEXT_LF
	CHECK_MACHINE_SKIP		; マシン別の処理スキップ

	CALL_w	TKTLF			; 改行
	RET
FEND	WID_TEXT_LF


; ****************************************************
;	WINDOWS/テキストウインドウ漢字表示
;	-I- AX : 表示文字列
; ****************************************************

FUNC	WID_TEXT_KNJ
	CHECK_MACHINE_SKIP		; マシン別の処理スキップ
	PUSH	AX
;;	MOV	AX,2			; wait timer count.
;;	CALL_w	TMVWAT			; V-SYNC timer wait.
	POP	AX
	CALL_w	TKTKANJI		; 漢字表示
	RET
FEND	WID_TEXT_KNJ


; ****************************************************
;	WINDOWS/テキストウインドウＡＮＫ表示
;	-I- AL : 表示文字列
; ****************************************************

FUNC	WID_TEXT_ANK
	CHECK_MACHINE_SKIP		; マシン別の処理スキップ
	CALL_w	TKTANK			; ＡＮＫ表示
	RET
FEND	WID_TEXT_ANK


; ****************************************************
;	WINDOWS/テキストウインドウクリア
; ****************************************************

FUNC	WID_TEXT_CLR
	CHECK_MACHINE_SKIP		; マシン別の処理スキップ

	CALL_w	TKTCLR			; 文字列表示クリア
	RET
FEND	WID_TEXT_CLR


; ****************************************************
;	WINDOWS/テキストウインドウフェイス
;	-I- SI : フェイスファイル名
; ****************************************************

FUNC	WID_TEXT_FACE
	MOVX	WDX1,WINDOW_XF		; window フェイス左上Ｘ
	MOVX	WDY1,WINDOW_YF		; window フェイス左上Ｙ
	CALL_w	WIDFACE			; WINDOWS/フェイス・ウインドウ
	RET
FEND	WID_TEXT_FACE


; ****************************************************
;	WINDOWS/テキストウインドウ娘フェイス
;	-I- DX : 0=普通 1=嬉しい 2=怒り 3=悲しい 4=暑い
;	         5=寒い 6=大怪我 7=苦しい 8=すねる
;	         9=不思議 10=恥らう 11=不安 12=不愉快
;	        13=妖しい 14=りりしい 15=驚き 16=ガーン
;	        17=真剣 18=困り
; ****************************************************

FUNC	WID_TEXT_FACEGIRL
	MOV	WD_FACE_GIRL,DX		; girl face.
	MOVX	WDX1,WINDOW_XF		; window フェイス左上Ｘ
	MOVX	WDY1,WINDOW_YF		; window フェイス左上Ｙ
	CALL_w	WIDFACEGIRL		; WINDOWS/フェイス・娘ウインドウ
	RET
FEND	WID_TEXT_FACEGIRL


; ****************************************************
;	WINDOWS/テキストウインドウ守護星フェイス
;	-I- DX : 0="太陽",1="月",2="火星",3="水星",4="木星",5="金星"
;		 6="土星",7="天王星",8="海王星",9="冥王星"
; ****************************************************

FUNC	WID_TEXT_FACESYUGO
	MOV	WD_FACE_SYUGO,DX	; syugosei face.
	MOVX	WDX1,WINDOW_XF		; window フェイス左上Ｘ
	MOVX	WDY1,WINDOW_YF		; window フェイス左上Ｙ
	CALL_w	WIDFACESYUGO		; WINDOWS/フェイス・守護星ウインドウ
	RET
FEND	WID_TEXT_FACESYUGO


; ****************************************************
;	WINDOWS/テキストウインドウカレントの取得
;	-O- DX : テキスト・タイプ
;	(MACLIB.ASM)
; ****************************************************

FUNC	WID_TEXT_CURRENT
	MOV	DX,WIDTEXT_TYPE		; window text type.
	RET
FEND	WID_TEXT_CURRENT


; ****************************************************
;	WINDOWS/テキストウインドウ位置
;	-I- DX : テキスト・タイプ
;	    AX : フェイス位置 0=none,1=left,2=right,3=top left,4=top right.
;	    WDX1 : locate x.
;	    WDY1 : locate y.
; ****************************************************

FUNC	WID_TEXT_LOCATE
	MOV	TEXTTYPE,DX

	MOV	BX,DX				; window text type.
	DEC	BX				;
	SHL	BX,1				;
	MOV	SI,DS:WINDOW_STYLE_TABLE[BX]	; window style table.

	MOV	CX,WDX1				; locate x.
	MOV	DX,WDY1				; locate y.

	MOV	DS:[SI][0],CX		;00 window 左上Ｘ
	MOV	DS:[SI][2],DX		;02 window 左上Ｙ
					;04 window フレームサイズＸ
					;06 window フレームサイズＹ
					;08 window エリア退避バンク番号
	MOV	DS:[SI][10],AX		;10 window フェイス退避フラグ


	CMP	AX,3			;フェイス位置 3=top left.
	JNE	WID_TEXT_LOCATE_21	;
	INC	CX			; + 1
	MOV	DS:[SI][12],CX		;12 window フェイス左上Ｘ
	SUB	DX,DS:[SI][22]		; - face y size.
	SUB	DX,2			; -2
	JMP	WID_TEXT_LOCATE_4	;
WID_TEXT_LOCATE_21:


	CMP	AX,4			;フェイス位置 4=top right.
	JNE	WID_TEXT_LOCATE_22	;
	ADD	CX,DS:[SI][04]		; + text x size.
	ADD	CX,2			; + 2
	SUB	CX,DS:[SI][20]		; - face x size.
	SUB	CX,1			; - 1 (face fream)
	MOV	DS:[SI][12],CX		;12 window フェイス左上Ｘ
	SUB	DX,DS:[SI][22]		; - face y size.
	SUB	DX,2			; -2
	JMP	WID_TEXT_LOCATE_4	;
WID_TEXT_LOCATE_22:


	CMP	AX,1			;フェイス位置 0=none,1=left,2=right.
	JNE	WID_TEXT_LOCATE_3	;
	CMP	TEXTTYPE,16
	JL	WID_TEXT_LOCATE_26
	CMP	TEXTTYPE,18
	JG	WID_TEXT_LOCATE_26
	ADD	CX,2			;+2
WID_TEXT_LOCATE_26:
	SUB	CX,DS:[SI][20]		; - face x size.
	MOV	DS:[SI][12],CX		;12 window フェイス左上Ｘ
	JMP	WID_TEXT_LOCATE_4	;
WID_TEXT_LOCATE_3:


	ADD	CX,DS:[SI][04]		; + text x size.
	ADD	CX,2			;
	CMP	TEXTTYPE,9		; <=== 9
	JNE	WID_TEXT_LOCATE_33	;
	DEC	CX			;
WID_TEXT_LOCATE_33:			;
	CMP	TEXTTYPE,16
	JL	WID_TEXT_LOCATE_34
	CMP	TEXTTYPE,18
	JG	WID_TEXT_LOCATE_34
	DEC	CX			;
WID_TEXT_LOCATE_34:			;
	MOV	DS:[SI][12],CX		;12 window フェイス左上Ｘ

WID_TEXT_LOCATE_4:
	MOV	XX1,1
	MOV	YY1,8
	CMP	TEXTTYPE,16
	JL	WID_TEXT_LOCATE_44
	CMP	TEXTTYPE,18
	JG	WID_TEXT_LOCATE_44
	MOV	XX1,2
	MOV	YY1,18
	SUB	DX,6
WID_TEXT_LOCATE_44:
	ADD	DX,YY1			; + 8
	MOV	DS:[SI][14],DX		;14 window フェイス左上Ｙ
	SUB	CX,XX1			; - 1
	MOV	DS:[SI][16],CX		;16 window フェイス退避Ｘ
	SUB	DX,YY1			; - 8
	MOV	DS:[SI][18],DX		;18 window フェイス退避Ｙ

					;20 window フェイスサイズＸ
					;22 window フェイスサイズＹ

	MOV	SI,DS:TEXT_STYLE_TABLE[BX] ; text style table.
	MOV	CX,WDX1			; locate x.
	MOV	DX,WDY1			; locate y.

	CMP	TEXTTYPE,16
	JL	WID_TEXT_LOCATE_71
	CMP	TEXTTYPE,18
	JG	WID_TEXT_LOCATE_71
	ADD	CX,3			; locate x.
	ADD	DX,12			; locate y.
	JMP	WID_TEXT_LOCATE_79
WID_TEXT_LOCATE_71:
	ADD	CX,1			; locate x.
	ADD	DX,8			; locate y.
WID_TEXT_LOCATE_79:
					;0 now handle number.
	MOV	DS:[SI][2],CX		;2 now locate x.
	MOV	DS:[SI][4],DX		;4 now locate y.
					;6 max colum.
					;8 max line.
					;10 step x.
					;12 step 2byte x.
					;14 step y.
	MOV	DS:[SI][16],CX		;16 scroll base x.
	MOV	DS:[SI][18],DX		;18 scroll base y.
	RET
FEND	WID_TEXT_LOCATE


; ****************************************************
;	WINDOWS/テキストウインドウ退避のを止める
;	-I- AX : flag window back.
; ****************************************************

FUNC	WID_TEXT_BACK_DIS
	MOV	FLAG_WINDOW_BAK_DISABLE,AX	; flag window back.
	RET
FEND	WID_TEXT_BACK_DIS


; ****************************************************
;	WINDOWS/テキストウインドウ ﾌｪｲｽのみ
;	-I- SI : フェイスファイル名
;	    AX : x.
;	    BX : y.
; ****************************************************

FUNC	WID_TEXT_ONLY_FACE
	PUSH	SI

	MOV	FACEXX,AX		; face x.
	MOV	FACEYY,BX		; face y.
	MOV	WDX1,AX			; フェイスＸ
	MOV	WDY1,BX			; フェイスＹ
	CALL_w	WID_FLAME_FACE		; WINDOWS/フレーム・フェイス

	POP	SI

	MOV	AX,FACEXX		; face x.
	MOV	BX,FACEYY		; face y.
	ADD	AX,1			; + 2
	ADD	BX,8			; + 8
	MOV	WDX1,AX			; window フェイス左上Ｘ
	MOV	WDY1,BX			; window フェイス左上Ｙ
	CALL_w	WIDFACE			; WINDOWS/フェイス・ウインドウ

	RET
FEND	WID_TEXT_ONLY_FACE


; ****************************************************
;	WINDOWS/テキストウインドウ 娘ﾌｪｲｽのみ
;	-I- DX : 0=普通 1=嬉しい 2=怒り 3=悲しい 4=暑い
;	         5=寒い 6=大怪我 7=苦しい 8=すねる
;	         9=不思議 10=恥らう 11=不安 12=不愉快
;	        13=妖しい 14=りりしい 15=驚き 16=ガーン
;	        17=真剣 18=困り
;	    AX : x.
;	    BX : y.
; ****************************************************

FUNC	WID_TEXT_ONLY_FACEGIRL
	MOV	WD_FACE_GIRL,DX		; girl face.

	MOV	FACEXX,AX		; face x.
	MOV	FACEYY,BX		; face y.
	MOV	WDX1,AX			; フェイスＸ
	MOV	WDY1,BX			; フェイスＹ
	CALL_w	WID_FLAME_FACE		; WINDOWS/フレーム・フェイス

	MOV	AX,FACEXX		; face x.
	MOV	BX,FACEYY		; face y.
	ADD	AX,1			; + 2
	ADD	BX,8			; + 8
	MOV	WDX1,AX			; window フェイス左上Ｘ
	MOV	WDY1,BX			; window フェイス左上Ｙ
	CALL_w	WIDFACEGIRL		; WINDOWS/フェイス・娘ウインドウ
	RET
FEND	WID_TEXT_ONLY_FACEGIRL


; ****************************************************
;	WINDOWS/テキストウインドウ 守護星ﾌｪｲｽのみ
;	-I- DX : 0="太陽",1="月",2="火星",3="水星",4="木星",5="金星"
;		 6="土星",7="天王星",8="海王星",9="冥王星"
;	    AX : x.
;	    BX : y.
; ****************************************************

FUNC	WID_TEXT_ONLY_FACESYUGO
	MOV	WD_FACE_SYUGO,DX	; syugosei face.

	MOV	FACEXX,AX		; face x.
	MOV	FACEYY,BX		; face y.
	MOV	WDX1,AX			; フェイスＸ
	MOV	WDY1,BX			; フェイスＹ
	CALL_w	WID_FLAME_FACEL		; WINDOWS/フレーム・守護星ﾌｪｲｽ

	MOV	AX,FACEXX		; face x.
	MOV	BX,FACEYY		; face y.
	ADD	AX,1			; + 2
	ADD	BX,8			; + 8
	MOV	WDX1,AX			; window フェイス左上Ｘ
	MOV	WDY1,BX			; window フェイス左上Ｙ
	CALL_w	WIDFACESYUGO		; WINDOWS/フェイス・守護星ウインドウ

	RET
FEND	WID_TEXT_ONLY_FACESYUGO


; ****************************************************
;	 WINDOWS/テキストウインドウタイマ
; ****************************************************

FUNC	WID_TEXT_TIMER
	CALL_w	TKTCOUNT		; 表示文字数
	;;SHL	AX,1
	CMP	AX,60			;
	JNB	WID_TEXT_TIMER_5	;
	ADD	AX,60			;
WID_TEXT_TIMER_5:
	CALL_w	TMVWAT			; V-SYNC timer wait.
	RET
FEND	WID_TEXT_TIMER


; ****************************************************
;	WINDOWS/テキストウインドウ文字送りﾀｲﾏ
;	-I- AX : timer.
; ****************************************************

FUNC	WID_TEXT_PAC
	CMP	AX,0			; timer.
	JE	WID_TEXT_PAC_OFF	;

	PUSH	AX			;
	MOV	AX,1			; 1=on,0=off
	CALL_w	TKTWAIT			; ウエイトON/OFF
	POP	AX			; timer.
	CALL_w	TKTWTIME		; ウエイト間隔
	RET
WID_TEXT_PAC_OFF:
	MOV	AX,0			; 1=on,0=off
	CALL_w	TKTWAIT			; ウエイトON/OFF
	MOV	AX,0			; timer.
	CALL_w	TKTWTIME		; ウエイト間隔
	RET
FEND	WID_TEXT_PAC


; ****************************************************
;	ウインドウエリア退避
;	-I- WINDOW_X1  : window 左上Ｘ
;	    WINDOW_Y1  : window 左上Ｙ
;	    WINDOW_XL  : window サイズＸ
;	    WINDOW_YL  : window サイズＹ
;	    WINDOW_BAK_BANK : window エリア退避バンク番号
; ****************************************************

WIDAREA_BACK	PROC	NEAR
	CMP	FLAG_WINDOW_BAK_DISABLE,0	; flag window back.
	JE	WIDAREA_BACK_00			;
	RET
WIDAREA_BACK_00:
	CMP	WINDOW_BAK_BANK,-1	; window エリア退避バンク番号
	JNE	WIDAREA_BACK_START	;
	RET
WIDAREA_BACK_START:

	MOV	DX,WINDOW_BAK_BANK	; window エリア退避バンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	CALL_w	C1PATCLR		; パーツセットクリア

	MOVX	VRX,WINDOW_X1		; window 左上Ｘ
	MOVX	VRY,WINDOW_Y1		; window 左上Ｙ
	MOVX	VRLENX,WINDOW_XL	; window サイズＸ
	MOVX	VRLENY,WINDOW_YL	; window サイズＹ
	CALL_w	C1PATGTA		; パーツＧＥＴ圧縮無し

	CMP	WINDOW_F_BAK,0		; window フェイス退避フラグ
	JE	WIDAREA_BACK_8		;

	MOVX	VRX,WINDOW_XFB		; window フェイス退避Ｘ
	MOVX	VRY,WINDOW_YFB		; window フェイス退避Ｙ
	MOVX	VRLENX,WINDOW_XFL	; window フェイスサイズＸ
	MOVX	VRLENY,WINDOW_YFL	; window フェイスサイズＹ
	CALL_w	C1PATGTA		; パーツＧＥＴ圧縮無し

WIDAREA_BACK_8:
	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	RET
WIDAREA_BACK	ENDP


; ****************************************************
;	ウインドウエリア復元
;	-I- WINDOW_BAK_BANK : window エリア退避バンク番号
; ****************************************************

WIDAREA_RESTOR	PROC	NEAR
	CMP	FLAG_WINDOW_BAK_DISABLE,0	; flag window back.
	JE	WIDAREA_RESTOR_00		;
	RET
WIDAREA_RESTOR_00:
	CMP	WINDOW_BAK_BANK,-1	; window エリア退避バンク番号
	JNE	WIDAREA_RESTOR_START	;
	RET
WIDAREA_RESTOR_START:			;

	MOV	DX,WINDOW_BAK_BANK	; window エリア退避バンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOV	CX,0			; パーツ番号
	CALL_w	C1PATPUT		; パーツＰＵＴ

	CMP	WINDOW_F_BAK,0		; window フェイス退避フラグ
	JE	WIDAREA_RESTOR_8	;

	MOV	CX,1			; パーツ番号
	CALL_w	C1PATPUT		; パーツＰＵＴ
WIDAREA_RESTOR_8:			;

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ
	RET
WIDAREA_RESTOR	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SSDES0:WORD		; visual data segment plean 0
EXTRN	SSGR0:WORD		; visual data segment plean 0
EXTRN	SSEFC0:WORD		; visual data segment plean 0
EXTRN	SEGVT0:WORD		; text put vram segment plean 0.
EXTRN	SSCUR0:WORD		; visual data segment plean 0

EXTRN	WD_FACE_GIRL:WORD	; girl face.
EXTRN	WD_FACE_SYUGO:WORD	; syugosei face.

PUBLIC	WIDTDEMO		; (WIDTEXT.ASM)デモフラグ
				; 0=通常,55=ランダムセレクト
PUBLIC	WIDTDEMOWAIT		; (WIDTEXT.ASM)デモ 待ち時間

WIDTDEMO	DW	0	; デモフラグ0=通常,55=ランダムセレクト
WIDTDEMOWAIT	DW	60	; デモ 待ち時間

FLAG_WINDOW_BAK_DISABLE	DW	0	; flag window back.

WIDTEXT_TYPE	DW	1		; window text type.

TEXTTYPE	DW	0		; text type.

FACEXX		DW	0		; face x.
FACEYY		DW	0		; face y.

WINDOW_TBL_LEN	DW WINDOW_TBL_END-WINDOW_TBL_TOP ; window loc table length.

WINDOW_TBL_TOP	LABEL	WORD		; window locaton top.
WINDOW_X1	DW	0		; window 左上Ｘ
WINDOW_Y1	DW	0		; window 左上Ｙ
WINDOW_X2	LABEL	WORD		; window フレームサイズＸ
WINDOW_XL	DW	1		; window サイズＸ
WINDOW_Y2	LABEL	WORD		; window フレームサイズＹ
WINDOW_YL	DW	1		; window サイズＹ
WINDOW_BAK_BANK	DW	-1		; window エリア退避バンク番号
WINDOW_F_BAK	DW	0		; window フェイス退避フラグ (1)
WINDOW_XF	DW	0		; window フェイス左上Ｘ
WINDOW_YF	DW	0		; window フェイス左上Ｙ
WINDOW_XFB	DW	0		; window フェイス退避Ｘ
WINDOW_YFB	DW	0		; window フェイス退避Ｙ
WINDOW_XFL	DW	0		; window フェイスサイズＸ
WINDOW_YFL	DW	0		; window フェイスサイズＹ
WINDOW_TBL_END	LABEL	WORD		; window locaton top.

; (1) 0=none,1=left,2=right,3=top left,4=top right.

WINDOW_STYLE_TABLE	LABEL	WORD	; window style table.
		DW	WINDOW_STYLE_01	; 説明テキスト window
		DW	WINDOW_STYLE_02	; 相手テキスト window
		DW	WINDOW_STYLE_03	; 娘テキスト window
		DW	WINDOW_STYLE_04	; デバッグテキスト window
		DW	WINDOW_STYLE_05	; 小型テキスト window
		DW	WINDOW_STYLE_06	; 鍛える・仕事テキスト window
		DW	WINDOW_STYLE_07	; バトル・メインテキスト window
		DW	WINDOW_STYLE_08	; バトル・娘テキスト window
		DW	WINDOW_STYLE_09	; 小さい娘テキスト window
		DW	WINDOW_STYLE_10	; 説明テキスト2 window
		DW	WINDOW_STYLE_11	; 守護星 window
		DW	WINDOW_STYLE_12	; 武闘会用 window
		DW	WINDOW_STYLE_13	; ｴﾝﾃﾞｨﾝｸﾞ用1 window
		DW	WINDOW_STYLE_14	; ｴﾝﾃﾞｨﾝｸﾞ用2 window
		DW	WINDOW_STYLE_15	; ｴﾝﾃﾞｨﾝｸﾞ用3 window
		DW	WINDOW_STYLE_16	; 武闘会用２(f1) window
		DW	WINDOW_STYLE_17	; 武闘会用３(f2) window
		DW	WINDOW_STYLE_18	; 武闘会用４(na) window
		DW	WINDOW_STYLE_19	; ｴﾝﾃﾞｨﾝｸﾞ守護星window

WINDOW_STYLE_01	LABEL	WORD		; 説明テキスト window
		DW	DEF_WD1_XP	; window 左上Ｘ
		DW	DEF_WD1_YP	; window 左上Ｙ
		DW	DEF_WD1_XL	; window フレームサイズＸ
		DW	DEF_WD1_YL	; window フレームサイズＹ
		DW	DEF_WD1_BAK	; window エリア退避バンク番号
		DW	DEF_WD1_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD1_XF	; window フェイス左上Ｘ
		DW	DEF_WD1_YF	; window フェイス左上Ｙ
		DW	DEF_WD1_XFB	; window フェイス退避Ｘ
		DW	DEF_WD1_YFB	; window フェイス退避Ｙ
		DW	DEF_WD1_XFL	; window フェイスサイズＸ
		DW	DEF_WD1_YFL	; window フェイスサイズＹ

WINDOW_STYLE_02	LABEL	WORD		; 相手テキスト window
		DW	DEF_WD2_XP	; window 左上Ｘ
		DW	DEF_WD2_YP	; window 左上Ｙ
		DW	DEF_WD2_XL	; window フレームサイズＸ
		DW	DEF_WD2_YL	; window フレームサイズＹ
		DW	DEF_WD2_BAK	; window エリア退避バンク番号
		DW	DEF_WD2_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD2_XF	; window フェイス左上Ｘ
		DW	DEF_WD2_YF	; window フェイス左上Ｙ
		DW	DEF_WD2_XFB	; window フェイス退避Ｘ
		DW	DEF_WD2_YFB	; window フェイス退避Ｙ
		DW	DEF_WD2_XFL	; window フェイスサイズＸ
		DW	DEF_WD2_YFL	; window フェイスサイズＹ

WINDOW_STYLE_03	LABEL	WORD		; 娘テキスト window
		DW	DEF_WD3_XP	; window 左上Ｘ
		DW	DEF_WD3_YP	; window 左上Ｙ
		DW	DEF_WD3_XL	; window フレームサイズＸ
		DW	DEF_WD3_YL	; window フレームサイズＹ
		DW	DEF_WD3_BAK	; window エリア退避バンク番号
		DW	DEF_WD3_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD3_XF	; window フェイス左上Ｘ
		DW	DEF_WD3_YF	; window フェイス左上Ｙ
		DW	DEF_WD3_XFB	; window フェイス退避Ｘ
		DW	DEF_WD3_YFB	; window フェイス退避Ｙ
		DW	DEF_WD3_XFL	; window フェイスサイズＸ
		DW	DEF_WD3_YFL	; window フェイスサイズＹ

WINDOW_STYLE_04	LABEL	WORD		; デバッグテキスト window
		DW	0		; window 左上Ｘ
		DW	400		; window 左上Ｙ
		DW	80		; window フレームサイズＸ
		DW	80		; window フレームサイズＹ
		DW	-1		; window エリア退避バンク番号
		DW	0		; window フェイス退避フラグ
		DW	0		; window フェイス左上Ｘ
		DW	0		; window フェイス左上Ｙ
		DW	0		; window フェイス退避Ｘ
		DW	0		; window フェイス退避Ｙ
		DW	1		; window フェイスサイズＸ
		DW	1		; window フェイスサイズＹ

WINDOW_STYLE_05	LABEL	WORD		; 小型テキスト window
		DW	DEF_WD5_XP	; window 左上Ｘ
		DW	DEF_WD5_YP	; window 左上Ｙ
		DW	DEF_WD5_XL	; window フレームサイズＸ
		DW	DEF_WD5_YL	; window フレームサイズＹ
		DW	DEF_WD5_BAK	; window エリア退避バンク番号
		DW	DEF_WD5_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD5_XF	; window フェイス左上Ｘ
		DW	DEF_WD5_YF	; window フェイス左上Ｙ
		DW	DEF_WD5_XFB	; window フェイス退避Ｘ
		DW	DEF_WD5_YFB	; window フェイス退避Ｙ
		DW	DEF_WD5_XFL	; window フェイスサイズＸ
		DW	DEF_WD5_YFL	; window フェイスサイズＹ

WINDOW_STYLE_06	LABEL	WORD		; 鍛える・仕事テキスト window
		DW	DEF_WD6_XP	; window 左上Ｘ
		DW	DEF_WD6_YP	; window 左上Ｙ
		DW	DEF_WD6_XL	; window フレームサイズＸ
		DW	DEF_WD6_YL	; window フレームサイズＹ
		DW	DEF_WD6_BAK	; window エリア退避バンク番号
		DW	DEF_WD6_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD6_XF	; window フェイス左上Ｘ
		DW	DEF_WD6_YF	; window フェイス左上Ｙ
		DW	DEF_WD6_XFB	; window フェイス退避Ｘ
		DW	DEF_WD6_YFB	; window フェイス退避Ｙ
		DW	DEF_WD6_XFL	; window フェイスサイズＸ
		DW	DEF_WD6_YFL	; window フェイスサイズＹ

WINDOW_STYLE_07	LABEL	WORD		; バトル・メインテキスト window
		DW	DEF_WD7_XP	; window 左上Ｘ
		DW	DEF_WD7_YP	; window 左上Ｙ
		DW	DEF_WD7_XL	; window フレームサイズＸ
		DW	DEF_WD7_YL	; window フレームサイズＹ
		DW	DEF_WD7_BAK	; window エリア退避バンク番号
		DW	DEF_WD7_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD7_XF	; window フェイス左上Ｘ
		DW	DEF_WD7_YF	; window フェイス左上Ｙ
		DW	DEF_WD7_XFB	; window フェイス退避Ｘ
		DW	DEF_WD7_YFB	; window フェイス退避Ｙ
		DW	DEF_WD7_XFL	; window フェイスサイズＸ
		DW	DEF_WD7_YFL	; window フェイスサイズＹ

WINDOW_STYLE_08	LABEL	WORD		; バトル・娘テキスト window
		DW	DEF_WD8_XP	; window 左上Ｘ
		DW	DEF_WD8_YP	; window 左上Ｙ
		DW	DEF_WD8_XL	; window フレームサイズＸ
		DW	DEF_WD8_YL	; window フレームサイズＹ
		DW	DEF_WD8_BAK	; window エリア退避バンク番号
		DW	DEF_WD8_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD8_XF	; window フェイス左上Ｘ
		DW	DEF_WD8_YF	; window フェイス左上Ｙ
		DW	DEF_WD8_XFB	; window フェイス退避Ｘ
		DW	DEF_WD8_YFB	; window フェイス退避Ｙ
		DW	DEF_WD8_XFL	; window フェイスサイズＸ
		DW	DEF_WD8_YFL	; window フェイスサイズＹ

WINDOW_STYLE_09	LABEL	WORD		; 小さい娘テキスト window
		DW	DEF_WD9_XP	; window 左上Ｘ
		DW	DEF_WD9_YP	; window 左上Ｙ
		DW	DEF_WD9_XL	; window フレームサイズＸ
		DW	DEF_WD9_YL	; window フレームサイズＹ
		DW	DEF_WD9_BAK	; window エリア退避バンク番号
		DW	DEF_WD9_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD9_XF	; window フェイス左上Ｘ
		DW	DEF_WD9_YF	; window フェイス左上Ｙ
		DW	DEF_WD9_XFB	; window フェイス退避Ｘ
		DW	DEF_WD9_YFB	; window フェイス退避Ｙ
		DW	DEF_WD9_XFL	; window フェイスサイズＸ
		DW	DEF_WD9_YFL	; window フェイスサイズＹ

WINDOW_STYLE_10	LABEL	WORD		; 説明テキスト2 window
		DW	DEF_WD10_XP	; window 左上Ｘ
		DW	DEF_WD10_YP	; window 左上Ｙ
		DW	DEF_WD10_XL	; window フレームサイズＸ
		DW	DEF_WD10_YL	; window フレームサイズＹ
		DW	DEF_WD10_BAK	; window エリア退避バンク番号
		DW	DEF_WD10_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD10_XF	; window フェイス左上Ｘ
		DW	DEF_WD10_YF	; window フェイス左上Ｙ
		DW	DEF_WD10_XFB	; window フェイス退避Ｘ
		DW	DEF_WD10_YFB	; window フェイス退避Ｙ
		DW	DEF_WD10_XFL	; window フェイスサイズＸ
		DW	DEF_WD10_YFL	; window フェイスサイズＹ

WINDOW_STYLE_11	LABEL	WORD		; 守護星 window
		DW	DEF_WD11_XP	; window 左上Ｘ
		DW	DEF_WD11_YP	; window 左上Ｙ
		DW	DEF_WD11_XL	; window フレームサイズＸ
		DW	DEF_WD11_YL	; window フレームサイズＹ
		DW	DEF_WD11_BAK	; window エリア退避バンク番号
		DW	DEF_WD11_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD11_XF	; window フェイス左上Ｘ
		DW	DEF_WD11_YF	; window フェイス左上Ｙ
		DW	DEF_WD11_XFB	; window フェイス退避Ｘ
		DW	DEF_WD11_YFB	; window フェイス退避Ｙ
		DW	DEF_WD11_XFL	; window フェイスサイズＸ
		DW	DEF_WD11_YFL	; window フェイスサイズＹ

WINDOW_STYLE_12	LABEL	WORD		; 武闘会用 window
		DW	DEF_WD12_XP	; window 左上Ｘ
		DW	DEF_WD12_YP	; window 左上Ｙ
		DW	DEF_WD12_XL	; window フレームサイズＸ
		DW	DEF_WD12_YL	; window フレームサイズＹ
		DW	DEF_WD12_BAK	; window エリア退避バンク番号
		DW	DEF_WD12_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD12_XF	; window フェイス左上Ｘ
		DW	DEF_WD12_YF	; window フェイス左上Ｙ
		DW	DEF_WD12_XFB	; window フェイス退避Ｘ
		DW	DEF_WD12_YFB	; window フェイス退避Ｙ
		DW	DEF_WD12_XFL	; window フェイスサイズＸ
		DW	DEF_WD12_YFL	; window フェイスサイズＹ

WINDOW_STYLE_13	LABEL	WORD		; ｴﾝﾃﾞｨﾝｸﾞ用1 window
		DW	DEF_WD13_XP	; window 左上Ｘ
		DW	DEF_WD13_YP	; window 左上Ｙ
		DW	DEF_WD13_XL	; window フレームサイズＸ
		DW	DEF_WD13_YL	; window フレームサイズＹ
		DW	DEF_WD13_BAK	; window エリア退避バンク番号
		DW	DEF_WD13_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD13_XF	; window フェイス左上Ｘ
		DW	DEF_WD13_YF	; window フェイス左上Ｙ
		DW	DEF_WD13_XFB	; window フェイス退避Ｘ
		DW	DEF_WD13_YFB	; window フェイス退避Ｙ
		DW	DEF_WD13_XFL	; window フェイスサイズＸ
		DW	DEF_WD13_YFL	; window フェイスサイズＹ

WINDOW_STYLE_14	LABEL	WORD		; ｴﾝﾃﾞｨﾝｸﾞ用2 window
		DW	DEF_WD14_XP	; window 左上Ｘ
		DW	DEF_WD14_YP	; window 左上Ｙ
		DW	DEF_WD14_XL	; window フレームサイズＸ
		DW	DEF_WD14_YL	; window フレームサイズＹ
		DW	DEF_WD14_BAK	; window エリア退避バンク番号
		DW	DEF_WD14_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD14_XF	; window フェイス左上Ｘ
		DW	DEF_WD14_YF	; window フェイス左上Ｙ
		DW	DEF_WD14_XFB	; window フェイス退避Ｘ
		DW	DEF_WD14_YFB	; window フェイス退避Ｙ
		DW	DEF_WD14_XFL	; window フェイスサイズＸ
		DW	DEF_WD14_YFL	; window フェイスサイズＹ

WINDOW_STYLE_15	LABEL	WORD		; ｴﾝﾃﾞｨﾝｸﾞ用3 window
		DW	DEF_WD15_XP	; window 左上Ｘ
		DW	DEF_WD15_YP	; window 左上Ｙ
		DW	DEF_WD15_XL	; window フレームサイズＸ
		DW	DEF_WD15_YL	; window フレームサイズＹ
		DW	DEF_WD15_BAK	; window エリア退避バンク番号
		DW	DEF_WD15_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD15_XF	; window フェイス左上Ｘ
		DW	DEF_WD15_YF	; window フェイス左上Ｙ
		DW	DEF_WD15_XFB	; window フェイス退避Ｘ
		DW	DEF_WD15_YFB	; window フェイス退避Ｙ
		DW	DEF_WD15_XFL	; window フェイスサイズＸ
		DW	DEF_WD15_YFL	; window フェイスサイズＹ

WINDOW_STYLE_16	LABEL	WORD		; 武闘会用２(f1) window
		DW	DEF_WD16_XP	; window 左上Ｘ
		DW	DEF_WD16_YP	; window 左上Ｙ
		DW	DEF_WD16_XL	; window フレームサイズＸ
		DW	DEF_WD16_YL	; window フレームサイズＹ
		DW	DEF_WD16_BAK	; window エリア退避バンク番号
		DW	DEF_WD16_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD16_XF	; window フェイス左上Ｘ
		DW	DEF_WD16_YF	; window フェイス左上Ｙ
		DW	DEF_WD16_XFB	; window フェイス退避Ｘ
		DW	DEF_WD16_YFB	; window フェイス退避Ｙ
		DW	DEF_WD16_XFL	; window フェイスサイズＸ
		DW	DEF_WD16_YFL	; window フェイスサイズＹ

WINDOW_STYLE_17	LABEL	WORD		; 武闘会用３(f2) window
		DW	DEF_WD17_XP	; window 左上Ｘ
		DW	DEF_WD17_YP	; window 左上Ｙ
		DW	DEF_WD17_XL	; window フレームサイズＸ
		DW	DEF_WD17_YL	; window フレームサイズＹ
		DW	DEF_WD17_BAK	; window エリア退避バンク番号
		DW	DEF_WD17_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD17_XF	; window フェイス左上Ｘ
		DW	DEF_WD17_YF	; window フェイス左上Ｙ
		DW	DEF_WD17_XFB	; window フェイス退避Ｘ
		DW	DEF_WD17_YFB	; window フェイス退避Ｙ
		DW	DEF_WD17_XFL	; window フェイスサイズＸ
		DW	DEF_WD17_YFL	; window フェイスサイズＹ

WINDOW_STYLE_18	LABEL	WORD		; 武闘会用４(na) window
		DW	DEF_WD18_XP	; window 左上Ｘ
		DW	DEF_WD18_YP	; window 左上Ｙ
		DW	DEF_WD18_XL	; window フレームサイズＸ
		DW	DEF_WD18_YL	; window フレームサイズＹ
		DW	DEF_WD18_BAK	; window エリア退避バンク番号
		DW	DEF_WD18_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD18_XF	; window フェイス左上Ｘ
		DW	DEF_WD18_YF	; window フェイス左上Ｙ
		DW	DEF_WD18_XFB	; window フェイス退避Ｘ
		DW	DEF_WD18_YFB	; window フェイス退避Ｙ
		DW	DEF_WD18_XFL	; window フェイスサイズＸ
		DW	DEF_WD18_YFL	; window フェイスサイズＹ

WINDOW_STYLE_19	LABEL	WORD		; ｴﾝﾃﾞｨﾝｸﾞ守護星window
		DW	DEF_WD19_XP	; window 左上Ｘ
		DW	DEF_WD19_YP	; window 左上Ｙ
		DW	DEF_WD19_XL	; window フレームサイズＸ
		DW	DEF_WD19_YL	; window フレームサイズＹ
		DW	DEF_WD19_BAK	; window エリア退避バンク番号
		DW	DEF_WD19_F_BAK	; window フェイス退避フラグ
		DW	DEF_WD19_XF	; window フェイス左上Ｘ
		DW	DEF_WD19_YF	; window フェイス左上Ｙ
		DW	DEF_WD19_XFB	; window フェイス退避Ｘ
		DW	DEF_WD19_YFB	; window フェイス退避Ｙ
		DW	DEF_WD19_XFL	; window フェイスサイズＸ
		DW	DEF_WD19_YFL	; window フェイスサイズＹ


TEXT_STYLE_TABLE	LABEL	WORD	; text style table.
		DW	TEXT_STYLE_01	; 説明テキスト window
		DW	TEXT_STYLE_02	; 相手テキスト window
		DW	TEXT_STYLE_03	; 娘テキスト window
		DW	TEXT_STYLE_04	; デバッグテキスト window
		DW	TEXT_STYLE_05	; 小型テキスト window
		DW	TEXT_STYLE_06	; 鍛える・仕事テキスト window
		DW	TEXT_STYLE_07	; バトル・メインテキスト window
		DW	TEXT_STYLE_08	; バトル・娘テキスト window
		DW	TEXT_STYLE_09	; 小さい娘テキスト window
		DW	TEXT_STYLE_10	; 説明テキスト2 window
		DW	TEXT_STYLE_11	; 守護星 window
		DW	TEXT_STYLE_12	; 武闘会用 window
		DW	TEXT_STYLE_13	; ｴﾝﾃﾞｨﾝｸﾞ用1 window
		DW	TEXT_STYLE_14	; ｴﾝﾃﾞｨﾝｸﾞ用2 window
		DW	TEXT_STYLE_15	; ｴﾝﾃﾞｨﾝｸﾞ用3 window
		DW	TEXT_STYLE_16	; 武闘会用２(f1) window
		DW	TEXT_STYLE_17	; 武闘会用３(f2) window
		DW	TEXT_STYLE_18	; 武闘会用４(na) window
		DW	TEXT_STYLE_19	; ｴﾝﾃﾞｨﾝｸﾞ守護星window

TEXT_STYLE_01	LABEL	WORD		; 説明テキスト window
		DW	1		; now handle number.
		DW	DEF_WD1_XP+1	; now locate x.
		DW	DEF_WD1_YP+8	; now locate y.
		DW	34+2		; max colum.
		DW	4		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD1_XP+1	; scroll base x.
		DW	DEF_WD1_YP+8	; scroll base y.
		DW	DEF_WD1_XL-2	; scroll size x.
		DW	DEF_WD1_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_02	LABEL	WORD		; 相手テキスト window
		DW	2		; now handle number.
		DW	DEF_WD2_XP+1	; now locate x.
		DW	DEF_WD2_YP+8	; now locate y.
		DW	28		; max colum.
		DW	5		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD2_XP+1	; scroll base x.
		DW	DEF_WD2_YP+8	; scroll base y.
		DW	DEF_WD2_XL-2	; scroll size x.
		DW	DEF_WD2_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_03	LABEL	WORD		; 娘テキスト window
		DW	3		; now handle number.
		DW	DEF_WD3_XP+1	; now locate x.
		DW	DEF_WD3_YP+8	; now locate y.
		DW	28		; max colum.
		DW	5		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD3_XP+1	; scroll base x.
		DW	DEF_WD3_YP+8	; scroll base y.
		DW	DEF_WD3_XL-2	; scroll size x.
		DW	DEF_WD3_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_04	LABEL	WORD		; デバッグテキスト window
		DW	4		; now handle number.
		DW	1		; now locate x.
		DW	406		; now locate y.
		DW	77		; max colum.
		DW	4	;3	; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	16	;20	; step y.
		DW	1		; scroll base x.
		DW	406		; scroll base y.
		DW	78		; scroll size x.
		DW	16*4+2	;20*3	; scroll size y.
		DW	16	;20	; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_05	LABEL	WORD		; 小型テキスト window
		DW	5		; now handle number.
		DW	DEF_WD5_XP+1	; now locate x.
		DW	DEF_WD5_YP+8	; now locate y.
		DW	28		; max colum.
		DW	2		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD5_XP+1	; scroll base x.
		DW	DEF_WD5_YP+8	; scroll base y.
		DW	DEF_WD5_XL-2	; scroll size x.
		DW	DEF_WD5_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_06	LABEL	WORD		; 鍛える・仕事テキスト window
		DW	5		; now handle number.=5
		DW	DEF_WD6_XP+1	; now locate x.
		DW	DEF_WD6_YP+8	; now locate y.
		DW	28		; max colum.
		DW	6		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD6_XP+1	; scroll base x.
		DW	DEF_WD6_YP+8	; scroll base y.
		DW	DEF_WD6_XL-2	; scroll size x.
		DW	DEF_WD6_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_07	LABEL	WORD		; バトル・メインテキスト window
		DW	1		; now handle number.
		DW	DEF_WD7_XP+1	; now locate x.
		DW	DEF_WD7_YP+8	; now locate y.
		DW	22+2		; max colum.
		DW	4		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD7_XP+1	; scroll base x.
		DW	DEF_WD7_YP+8	; scroll base y.
		DW	DEF_WD7_XL-2	; scroll size x.
		DW	DEF_WD7_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_08	LABEL	WORD		; バトル・娘テキスト window
		DW	3		; now handle number.
		DW	DEF_WD8_XP+1	; now locate x.
		DW	DEF_WD8_YP+8	; now locate y.
		DW	32		; max colum.
		DW	4		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD8_XP+1	; scroll base x.
		DW	DEF_WD8_YP+8	; scroll base y.
		DW	DEF_WD8_XL-2	; scroll size x.
		DW	DEF_WD8_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_09	LABEL	WORD		; 小さい娘テキスト window
		DW	6		; now handle number.
		DW	DEF_WD9_XP+1	; now locate x.
		DW	DEF_WD9_YP+8	; now locate y.
		DW	14		; max colum.
		DW	4		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD9_XP+1	; scroll base x.
		DW	DEF_WD9_YP+8	; scroll base y.
		DW	DEF_WD9_XL-2	; scroll size x.
		DW	DEF_WD9_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_10	LABEL	WORD		; 説明テキスト2 window
		DW	1		; now handle number.
		DW	DEF_WD10_XP+1	; now locate x.
		DW	DEF_WD10_YP+8	; now locate y.
		DW	34+2		; max colum.
		DW	4		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD10_XP+1	; scroll base x.
		DW	DEF_WD10_YP+8	; scroll base y.
		DW	DEF_WD10_XL-2	; scroll size x.
		DW	DEF_WD10_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_11	LABEL	WORD		; 守護星 window
		DW	3		; now handle number.
		DW	DEF_WD11_XP+1	; now locate x.
		DW	DEF_WD11_YP+8	; now locate y.
		DW	28		; max colum.
		DW	5		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD11_XP+1	; scroll base x.
		DW	DEF_WD11_YP+8	; scroll base y.
		DW	DEF_WD11_XL-2	; scroll size x.
		DW	DEF_WD11_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_12	LABEL	WORD		; 武闘会用 window
		DW	1		; now handle number.
		DW	DEF_WD12_XP	; now locate x.
		DW	DEF_WD12_YP+2	; now locate y.
		DW	20+2		; max colum.
		DW	4		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD12_XP	; scroll base x.
		DW	DEF_WD12_YP+2	; scroll base y.
		DW	DEF_WD12_XL	; scroll size x.
		DW	DEF_WD12_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	0		; character color 0-15
		DW	2		; back color 0=brawn,1=black,2=cream.

TEXT_STYLE_13	LABEL	WORD		; ｴﾝﾃﾞｨﾝｸﾞ用1 window
		DW	1		; now handle number.
		DW	DEF_WD13_XP+1	; now locate x.
		DW	DEF_WD13_YP+8	; now locate y.
		DW	28		; max colum.
		DW	5		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD13_XP+1	; scroll base x.
		DW	DEF_WD13_YP+8	; scroll base y.
		DW	DEF_WD13_XL-2	; scroll size x.
		DW	DEF_WD13_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_14	LABEL	WORD		; ｴﾝﾃﾞｨﾝｸﾞ用2 window
		DW	2		; now handle number.
		DW	DEF_WD14_XP+1	; now locate x.
		DW	DEF_WD14_YP+8	; now locate y.
		DW	28		; max colum.
		DW	5		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD14_XP+1	; scroll base x.
		DW	DEF_WD14_YP+8	; scroll base y.
		DW	DEF_WD14_XL-2	; scroll size x.
		DW	DEF_WD14_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_15	LABEL	WORD		; ｴﾝﾃﾞｨﾝｸﾞ用3 window
		DW	3		; now handle number.
		DW	DEF_WD15_XP+1	; now locate x.
		DW	DEF_WD15_YP+8	; now locate y.
		DW	28		; max colum.
		DW	5		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD15_XP+1	; scroll base x.
		DW	DEF_WD15_YP+8	; scroll base y.
		DW	DEF_WD15_XL-2	; scroll size x.
		DW	DEF_WD15_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black.

TEXT_STYLE_16	LABEL	WORD		; 武闘会用２(f1) window
		DW	1		; now handle number.
		DW	DEF_WD18_XP+3	; now locate x.
		DW	DEF_WD18_YP+12	; now locate y.
		DW	24+2		; max colum.
		DW	5		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD18_XP+3	; scroll base x.
		DW	DEF_WD18_YP+12	; scroll base y.
		DW	DEF_WD18_XL-6	; scroll size x.
		DW	DEF_WD18_YL-22	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	0		; character color 0-15
		DW	2		; back color 0=brawn,1=black,2=cream.

TEXT_STYLE_17	LABEL	WORD		; 武闘会用３(f2) window
		DW	2		; now handle number.
		DW	DEF_WD18_XP+3	; now locate x.
		DW	DEF_WD18_YP+12	; now locate y.
		DW	24+2		; max colum.
		DW	5		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD18_XP+3	; scroll base x.
		DW	DEF_WD18_YP+12	; scroll base y.
		DW	DEF_WD18_XL-6	; scroll size x.
		DW	DEF_WD18_YL-22	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	0		; character color 0-15
		DW	2		; back color 0=brawn,1=black,2=cream.

TEXT_STYLE_18	LABEL	WORD		; 武闘会用４(na) window
		DW	3		; now handle number.
		DW	DEF_WD18_XP+3	; now locate x.
		DW	DEF_WD18_YP+12	; now locate y.
		DW	24+2		; max colum.
		DW	5		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD18_XP+3	; scroll base x.
		DW	DEF_WD18_YP+12	; scroll base y.
		DW	DEF_WD18_XL-6	; scroll size x.
		DW	DEF_WD18_YL-22	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	0		; character color 0-15
		DW	2		; back color 0=brawn,1=black,2=cream.

TEXT_STYLE_19	LABEL	WORD		; ｴﾝﾃﾞｨﾝｸﾞ守護星window
		DW	3		; now handle number.
		DW	DEF_WD19_XP+2	; now locate x.
		DW	DEF_WD19_YP+8	; now locate y.
		DW	42		; max colum.
		DW	6		; max line.
		DW	1		; step x.
		DW	2		; step 2byte x.
		DW	22		; step y.
		DW	DEF_WD19_XP+2	; scroll base x.
		DW	DEF_WD19_YP+8	; scroll base y.
		DW	DEF_WD19_XL-2	; scroll size x.
		DW	DEF_WD19_YL-16	; scroll size y.
		DW	22		; scroll length.
		DW	0		; char size.0=16x16 1=32x32 2=16x24...
		DW	15		; character color 0-15
		DW	0		; back color 0=brawn,1=black,2=cream.


XX1	DW	0
YY1	DW	0
XX2	DW	0
YY2	DW	0

DATA	ENDS

	END
;
;	end of "WIDTEXT.ASM"
;
