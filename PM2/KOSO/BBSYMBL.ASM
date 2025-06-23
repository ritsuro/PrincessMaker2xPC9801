; "BBSYMBL.ASM" PC-9801UV11 make by R.H 1991/10/16
;
;
;	princess  B A S I C    symbol set.
;
;
; symboles.

TCHRSEG_FREE_SIZE	EQU	1300	; symbol free area size.
TCHRADR_REC_MAX		EQU	200	; symbol decord max.
USER_AREA_WSIZE		EQU	700	; user area word size.

TC	MACRO	STRINGS
	LOCAL	L1,L2
	DB	(L2-L1)
L1	LABEL	BYTE
	DB	"&STRINGS"
L2	LABEL	BYTE
	ENDM

TA_CODE	MACRO	STRINGS
CODE	SEGMENT	PUBLIC	'CODE'
	EXTRN	STRINGS:NEAR
CODE	ENDS
	DW	OFFSET STRINGS
	DW	SEG CODE
	ENDM

TA_CODE01	MACRO	STRINGS
CODE01	SEGMENT	PUBLIC	'CODE01'
	EXTRN	STRINGS:NEAR
CODE01	ENDS
	DW	OFFSET STRINGS
	DW	SEG CODE01
	ENDM

TA_DATA	MACRO	STRINGS
DATA	SEGMENT	PUBLIC	'DATA'
	EXTRN	STRINGS:WORD
DATA	ENDS
	DW	OFFSET STRINGS
	DW	SEG DATA
	ENDM

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	SEGTCHRSEG			; symbol segment.
PUBLIC	SEGTCHRADR			; symbol address segment.
PUBLIC	SEGUSERAREA			; user area segment.

PUBLIC	TCHR_SYM_SIZ			; user symbol area size.
PUBLIC	TCHR_SYM_FSIZ			; user symbol free area size.

PUBLIC	TCHR_SYM_OFST			; user symbol area offset.
PUBLIC	TCHR_SYM_FOFST			; user symbol area free offset.

PUBLIC	TCHR_ADR_MAX			; user symbol address max.
PUBLIC	TCHR_ADR_FMAX			; user symbol free address max.

PUBLIC	TCHR_ADR_OFST			; user symbol adrs offset.
PUBLIC	TCHR_ADR_FOFST			; user symbol adrs free offset.

PUBLIC	USER_FREE_AREA			; user free area.
PUBLIC	USER_FREE_OFST			; user free area offset.

PUBLIC	USER_FREE_WORD			; user area word size.
PUBLIC	USER_FREE_FWORD			; user area free word size.

SEGTCHRSEG	DW	SEG TCHRSEG		; symbol segment.
SEGTCHRADR	DW	SEG TCHRADR		; symbol address segment.
SEGUSERAREA	DW	SEG DATA		; user area segment.

TCHR_SYM_SIZ	DW	TCHRSEG_FREE_SIZE	; user symbol area size.
TCHR_SYM_FSIZ	DW	TCHRSEG_FREE_SIZE	; user symbol free area size.

TCHR_SYM_OFST	DW	TCHRSEG_OFFSET_END	; user symbol area offset.
TCHR_SYM_FOFST	DW	TCHRSEG_OFFSET_END	; user symbol area free offset.

TCHR_ADR_MAX	DW	TCHRADR_REC_MAX		; user symbol address max.
TCHR_ADR_FMAX	DW	TCHRADR_REC_MAX		; user symbol free address max.

TCHR_ADR_OFST	DW	TCHRADR_OFFSET_END	; user symbol adrs offset.
TCHR_ADR_FOFST	DW	TCHRADR_OFFSET_END	; user symbol adrs free offset.

USER_FREE_AREA	DW	USER_AREA		; user free area.
USER_FREE_OFST	DW	USER_AREA		; user free area offset.
USER_FREE_WORD	DW	USER_AREA_WSIZE		; user area word size.
USER_FREE_FWORD	DW	USER_AREA_WSIZE		; user area free word size.
USER_AREA	DW	USER_AREA_WSIZE DUP (0)	;

DATA	ENDS

TCHRSEG	SEGMENT	PUBLIC	'TCHRSEG'

PUBLIC	TCHRSEG_OFFSET_TOP
TCHRSEG_OFFSET_TOP	LABEL	BYTE

TC	AX			; registar value AX.
TC	BX			; registar value BX.
TC	CX			; registar value CX.
TC	DX			; registar value DX.
TC	SI			; registar value SI.
TC	DI			; registar value DI.
TC	BP			; registar value BP.
TC	ES			; registar value ES.

TC	C1			; user counter.
TC	C2			; user counter.
TC	C3			; user counter.
TC	C4			; user counter.
TC	C5			; user counter.
TC	C6			; user counter.
TC	C7			; user counter.
TC	C8			; user counter.

TC	ISLCT			; select number.
TC	ISITM			; select item number.

TC	PR			; syntax : PR  ("string")
TC	PRES			; syntax : PRES(length)
TC	PRF			; syntax : PRF ("string")
TC	PRV			; syntax : PRV ("string",C1)
TC	PRVH			; syntax : PRVH("string",C1)
TC	PRVB			; syntax : PRVB("string",C1)
TC	PRINT			; syntax : PRINT(string)
TC	STR			; syntax : STR(C1)
TC	HEX			; syntax : HEX(C1)
TC	BIN			; syntax : BIN(C1)
TC	LLF			; syntax : LLF
TC	CLS			; syntax : CLS
TC	ABS			; syntax : ABS (value)
TC	MOD			; syntax : MOD (value)
TC	P1X100			; syntax : P1X100(value,x100)
TC	P100PAR			; syntax : P100PAR(value,base)
TC	SLCT			; syntax : SLCT("str1,str2,str3")
TC	SLCTX			; syntax : SLCTX("str1,str2,str3")
TC	SLCTBAK			; syntax : SLCTBAK(backbank)
TC	SLCPOS			; syntax : SLCPOS(function)
TC	FREE			; syntax : FREE
TC	END			; syntax : END

TC	STRSCLEAR		; syntax : STRSCLEAR
TC	STRSTACK		; syntax : STRSTACK("strings")
TC	PROGADRS		; syntax : PROGADRS("label")
TC	PROGCOPY		; syntax : PROGCOPY(string)
TC	STRCOPY			; syntax : STRCOPY("string",string)
TC	STRLEN			; syntax : STRLEN(string)
TC	LOAD			; syntax : LOAD("file_name")
TC	CK_LVL			; syntax : CK_LVL(count,lv1,lv2,lv3,lvm)
TC	CK_GUARA		; syntax : CK_GUARA(count,base)
;*;TC	CRTREWRITE		; syntax : CRTREWRITE
TC	TXTSZ			; syntax : TXTSZ(mode)
TC	GOLDADD			; syntax : GOLDADD(value)
TC	GOLDSUB			; syntax : GOLDSUB(value)
TC	GOLDSUB2		; syntax : GOLDSUB2(value)
TC	GOLDCMP			; syntax : GOLDCMP(value)
TC	EDTX			; syntax : EDTX(function)

TC	TXOPEN			; text window open      : TXOPEN(type)
TC	TXCLOSE			; text window close     : TXCLOSE(type)
TC	TXSLCT			; text window select    : TXSLCT(type)
TC	TXT			; text window print     : TXT("strings")
TC	TXA			; text window print adrs: TXA(strings)
TC	TXGOLD			; text window お金      : TXGOLD(gold)
TC	TXPOINT			; text window ポイント  : TXPOINT(point)
TC	TXS2KETA		; text window 小数２桁  : TXS2KETA(value)
TC	TXPAUSE			; text window pause     : TXPAUSE
TC	TXCLR			; text window clear     : TXCLR
TC	TXLF			; text window line feed : TXLF
TC	TXFACE			; text window show face : TXFACE("filename")
TC	TXGIRL			; text window show girl : TXGIRL(face)
TC	TXGIRK			; EETN03.TXT 790行  TXGIRK(1)->TXGIRL(1)
TC	TXSYU			; text window show face : TXSYU(syugo)
TC	TXLC			; text window locate    : TXLC(type,x,y,face)
TC	TXF			; text window function  : TXF(function)
TC	ITEMSLCT		; マルチアイテム選択　  : ITEMSLCT(type)
TC	ITEMST			; マルチアイテム選択    : ITEMST(type)
TC	ITEMPRN			; マルチアイテム表示    : ITEMPRN(function)

TC	GR_OPEN			;ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ OPEN  :GR_OPEN
TC	GR_CLOSE		;ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ CLOSE :GR_CLOSE
TC	GR_F			;ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ function: GR_F(function)
TC	GRPOPEN			;ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ       :GRPOPEN(win_type,han)
TC	GRPUPD			;ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ 更新  :GRPUPD(han,rec,dat)
TC	GOLDOPEN		;ﾊﾟﾗﾒｰﾀ 所持金ｳｲﾝﾄﾞｳ :GOLDOPEN(win_type,han)
TC	GOLDUPD			;ﾊﾟﾗﾒｰﾀ 所持金 更新  :GOLDUPD(han,rec,dat)
TC	PROFILE			;プロフィール･ｳｲﾝﾄﾞｳ :PROFILE(win_type,handle)
TC	PROPROPEN		;ﾌﾟﾛﾎﾟｰｼｮﾝ･ｳｲﾝﾄﾞｳ :PROPROPEN(win_type,handle)
TC	PROPRUPD		;ﾌﾟﾛﾎﾟｰｼｮﾝ･ｳｲﾝﾄﾞｳ更新:PROPRUPD(handle,rec,dat)
TC	STATUS			;通常ｽﾃｰﾀｽ･ｳｲﾝﾄﾞｳ    :STATUS(win_type,handle)
TC	PROLONG			;長い名前ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ:PROLONG(win_type,handle)
TC	PRICON			;ICONﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ   :PRICON(win_type,handle)

TC	CLENDER			; カレンダー            : CLENDER(function)
TC	RANDAM			; 乱数			: RANDAM(max)
TC	IRAND2			; 範囲乱数		: IRAND2(base,max)
TC	IRAND999X		; 乱数９９９範囲指定	: IRAND999X(max)
TC	IRNDPAR			; +-%の乱数	:IRNDPAR(value,parcent)
TC	TIMER1			; タイマー１		: TIMER1(timer60)
TC	TIMER2			; タイマー２		: TIMER2(timer60)
TC	WAIT1			; タイマー待ち１	: WAIT1
TC	WAIT2			; タイマー待ち２	: WAIT2
TC	TMCHK2			; タイマーチェック２	: TMCHK2
TC	WAITU			; ユーザ待ち		: WAITU
TC	VALSTR			; 数値を文字列化	: VALSTR(num)
TC	BORTHDAYSTR		; 誕生日を文字列化:BORTHDAYSTR(year,month,day)
TC	ITEM_KILL		; アイテム削除          : ITEM_KILL(rec)
TC	ITEM_INST		; アイテム登録         	: ITEM_INST(f,,,,)
TC	ITEM_SRCH		; アイテム検索          : ITEM_SRCH(function)
TC	SCHD_OPEN		; ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ OPEN: SCHD_OPEN(d,w,end,m,y)
TC	SCHD_CLOSE		; ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ CLOSE: SCHD_CLOSE
TC	SCHD_ICON		; ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ SET ICON: SCHD_ICON(dy,dy,ic)
TC	PALET_SET		; パレットセット    : PALET_SET(rec)
TC	PALET_SETONLY		; ﾊﾟﾚｯﾄﾃｰﾌﾞﾙｾｯﾄのみ : PALET_SETONLY(rec,num)

TC	WWFRAME			; 全画面枠		: WWFRAME(function)
TC	WWMUSYA			; 武者修行		: WWMUSYA(function)
TC	WWGIRL			; 娘			: WWGIRL(function)
TC	WWANIME			; アニメ・ウインドウ	: WWANIME(function)
TC	WWIVENT			; イベント・ウインドウ	: WWIVENT(function)
TC	WWPROF			; ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ	: WWPROF(function)
TC	WWTOUR			; トーナメント表	: WWTOUR(function)

TC	P98F			; PC9801 function.	: P98F(function)
TC	PTBK			; パーツバンク設定	: PTBK(bank)
TC	PTMD			; ＰＵＴモード設定	: PTMD(mode)
TC	PTLD			; パーツロード		: PTLD("filename")
TC	PTLA			; パーツ追加ロード	: PTLA("filename")
TC	PTX			; パーツ座標ＰＵＴ	: PTX(x,y,rec)
TC	PTM			; マスクパーツＰＵＴ	: PTM(x,y,rec)
TC	PTF			; ﾊﾟｰﾂｵﾌｾｯﾄ座標ＰＵＴ	: PTF(x,y,rec)
TC	PTMF			; ﾏｽｸﾊﾟﾀｰﾝ座標ｵﾌｾｯﾄPUT	: PTMF(x,y,rec)
TC	PTMFX			; ﾏｽｸﾊﾟﾀｰﾝ座標ｵﾌｾｯﾄ範囲PUT: PTMFX(x,y,rec...)
TC	PTCLR			; パーツバッファクリア	: PTCLR
TC	PTGT			; パーツ座標ＰＵＴ	: PTGT(x,y,xl,yl)
TC	PTPLT			; パーツパレットセット	: PTPLT(rec,num)

TC	EFC			; effect function.	: EFC(function)
TC	PIC			; picture function.	: PIC(function)
TC	MUSIC			; music.		: MUSIC(function)
TC	PLAY			; music play.		: PLAY(n)
TC	GG_LINE			; line		: GG_LINE(x1,y1,x2,y2,col)
TC	PARC			; parameter calc.	: PARC(function)
TC	XDBG			; debug mode		: XDBG(function)
TC	GRPCLS			; graphics clear screen.

TC	FFDISK			; ディスク操作

TC	ITEMID_TBL1		; アイテムIDﾃｰﾌﾞﾙ／名前ＩＤ
TC	ITEMID_TBL2		; アイテムIDﾃｰﾌﾞﾙ／ＩＣＯＮ
TC	ITEMID_TBL3		; アイテムIDﾃｰﾌﾞﾙ／金
TC	ITEMID_TBL4		; アイテムIDﾃｰﾌﾞﾙ／文字ＩＤ１
TC	ITEMID_TBL5		; アイテムIDﾃｰﾌﾞﾙ／ﾊﾟﾗﾒｰﾀ値１
TC	ITEMID_TBL6		; アイテムIDﾃｰﾌﾞﾙ／文字ＩＤ２
TC	ITEMID_TBL7		; アイテムIDﾃｰﾌﾞﾙ／ﾊﾟﾗﾒｰﾀ値２
TC	ITEMID_CNT		; アイテムID数
TC	ITEMID_DIM		; アイテムIDﾃｰﾌﾞﾙｻｲｽﾞ

TC	IGRP_TBL1		; グラフテーブル／名前
TC	IGRP_TBL2		; グラフテーブル／タイプ
TC	IGRP_TBL3		; グラフテーブル／パラメータ値
TC	IGRP_TBL4		; グラフテーブル／項目名
TC	IGRP_CNT		; グラフテーブル数
TC	IGRP_DIM		; グラフ本数の上限
TC	IGRP_X			; グラフＸ
TC	IGRP_Y			; グラフＹ

TC	VAL_YEAR		; 年
TC	VAL_MONTH		; 月
TC	VAL_WEEK		; 曜日
TC	VAL_DAY			; 日
TC	VAL_A_DAY		; 年内合計日付
TC	VAL_M_END		; 月末の日
TC	TM_SEASON		; 季節（1:春,2:夏,3:秋,4:冬）
TC	FLG_SHOGATSU		; フラグ・正月
TC	FLG_URUBI		; フラグ・うるう日
TC	FLG_CHRISTMAS_EVE 	; フラグ・クリスマスイブ
TC	FLG_G_BORTH		; フラグ・娘の誕生日
TC	FLG_M_BORTH		; フラグ・私の誕生日
TC	FLG_HOLIDAY		; フラグ・休日
TC	FLG_SYUKAKU		; フラグ・収穫祭の準備

TC	SCHED_SECTION		; ｽｹｼﾞｭｰﾙ項目
TC	SCHED_WORKS		; ｽｹｼﾞｭｰﾙ内容

TC	DEF_STR_BROOD		; 血液型・文字列
TC	DEF_STR_SIKYU		; 子宮名・文字列
TC	DEF_STR_STAR		; 守護星・文字列
TC	DEF_STR_LEVEL		; レベル・文字列

TC	SCH_STARTDAY		; スケジュール開始日
TC	SCH_ENDDAY		; スケジュール終了日
TC	SCH_COUNT		; スケジュール数
TC	SCH_NOW			; スケジュール実行中項目
TC	SCH_SYUKAKUSAI		; 収穫祭スケジュール

TC	FLG_TAKARA		; 宝箱フラグ
TC	ENDNM			; エンディング
TC	IDBG			; デバッグフラグ

TC	IRND			; 乱数

TC	DBGFLAG_CONSOLE		; debug flag console.
TC	INLINECOMPDBG		; inline compile debug.
TC	DBGFLAG_FILE		; debug flag file.
TC	DBGFLAG_ERROR		; debug flag error.

; ****************************************************
;	娘のパラメータ
; ****************************************************

;	基本能力

TC	B_TAIRYOKU			; 体力
TC	B_KINRYOKU			; 筋力
TC	B_CHINOH			; 知能
TC	B_KIHIN				; 気品
TC	B_IROKE				; 色気
TC	B_MORALS			; モラル
TC	B_SHINKOH			; 信仰
TC	B_INGYO				; 因業
TC	B_KANJUSEI			; 感受性
TC	B_STRESS			; ストレス

;*;TC	B_UP_TAIRYOKU			; 増強・体力
;*;TC	B_UP_KINRYOKU			; 増強・筋力
;*;TC	B_UP_CHINOH			; 増強・知能
;*;TC	B_UP_KIHIN			; 増強・気品
;*;TC	B_UP_IROKE			; 増強・色気

;	技能別能力

TC	H_SENSHI			; 戦士評価
TC	H_MAHO				; 魔法評価
TC	H_SYAKOH			; 社交評価
TC	H_KAJI				; 家事評価

TC	V_SENTOH			; 戦闘技術
TC	V_KOUGEKI			; 攻撃力
TC	V_BOUGYO			; 防御力
TC	V_MAHOGIJUTSU			; 魔法技術
TC	V_MARYOKU			; 魔力
TC	V_KOHMARYOKU			; 抗魔力
TC	V_REIGI				; 礼儀作法
TC	V_GEIJYUTSU			; 芸術
TC	V_WAJYUTU			; 話術
TC	V_RYOURI			; 料理
TC	V_SOUJISENTAKU			; 掃除洗濯
TC	V_KIDATE			; 気だて

TC	T_SENTOH			; trg戦闘技術
TC	T_KOUGEKI			; trg攻撃力
TC	T_BOUGYO			; trg防御力
TC	T_MAHOGIJUTSU			; trg魔法技術
TC	T_MARYOKU			; trg魔力
TC	T_KOHMARYOKU			; trg抗魔力
TC	T_REIGI				; trg礼儀作法
TC	T_GEIJYUTSU			; trg芸術
TC	T_WAJYUTU			; trg話術
TC	T_RYOURI			; trg料理
TC	T_SOUJISENTAKU			; trg掃除洗濯
TC	T_KIDATE			; trg気だて

;*;TC	V_UP_SENTOH			; 増強・戦闘技術
;*;TC	V_UP_KOUGEKI			; 増強・攻撃力
;*;TC	V_UP_BOUGYO			; 増強・防御力
;*;TC	V_UP_MAHOGIJUTSU 		; 増強・魔法技術
;*;TC	V_UP_MARYOKU			; 増強・魔力
;*;TC	V_UP_KOHMARYOKU			; 増強・抗魔力

;	所持金

TC	GOLD_GIRL			; 娘の所持金
;*;TC	GOLD_MINE			; 私の所持金

;	プロフィール

TC	NAME_FIRST			; 名前
TC	NAME_FAMILY			; 名前(family)
TC	P_BLOOD				; 血液型
TC	P_NENREI			; 年齢
TC	P_BORTHDAY			; 誕生日
TC	P_BORTHMONTH			; 誕生月
TC	P_BORTHYEAR			; 誕生年
TC	P_SHIKYU			; 子宮名
TC	P_SYUGOSEI			; 守護星
TC	P_SHINCHO			; 身長
TC	P_TAIJYU			; 体重
TC	P_BUST				; バスト
TC	P_WAIST				; ウエスト
TC	P_HIP				; ヒップ

;	戦闘ステータス

TC	W_HP_MAX			; 最大ＨＰ
TC	W_MP_MAX			; 最大ＭＰ
TC	W_HP				; ＨＰ
TC	W_MP				; ＭＰ
TC	W_SENI				; 戦意

;	通常ステータス

TC	S_BYOUKI			; 病気指数(%)
TC	S_HIKOUKA			; 非行化指数(%)
TC	S_JINMYAKU			; 人脈
TC	FLAG_BYOUKI			; 状態・病気
TC	FLAG_HIKOUKA			; 状態・非行化
TC	FLAG_RENAI			; 状態・恋愛
TC	FLAG_KENKO			; 健康管理
TC	GIRL_BODY			; 体形 1=細,2=太
TC	GIRL_FACE			; 表情 1=基本,2=非行,3病気,4元気,5色気
TC	GIRL_BREAST			; 胸大 0=無,1=有
TC	GIRL_DAMEG			; 重病 0=normal,1=重病

;	装備

TC	ROOM_PIC			; 部屋の絵

TC	DRESS_NUM			; 着衣絵番号

TC	DRESS_ICON			; 着衣　ＩＣＯＮ番号
TC	DRESS_GOLD			; 着衣　値段
TC	DRESS_NAME			; 着衣　名前 string
TC	DRESS_PROG			; 着衣　効果 string

TC	EQUIP_ICON			; 装備　ＩＣＯＮ番号
TC	EQUIP_GOLD			; 装備　値段
TC	EQUIP_NAME			; 装備　名前
TC	EQUIP_PROG			; 装備　効果
TC	EQUIP_HELP			; 装備　説明 string

TC	ARMS_ICON			; 武器　ＩＣＯＮ番号
TC	ARMS_GOLD			; 武器　値段
TC	ARMS_NAME			; 武器　名前
TC	ARMS_PROG			; 武器　効果
TC	ARMS_HELP			; 武器　説明 string

TC	ITEM_MAX			; 所有アイテム数
TC	ITEM_DIM			; 所有最大アイテム数
TC	ITEM_ICON			; 所有アイテムＩＣＯＮ番号
TC	ITEM_GOLD			; 所有アイテム値段
TC	ITEM_ATTR			; 所有アイテム種別
TC	ITEM_NAME			; 所有アイテム名前 string
TC	ITEM_PROG			; 所有アイテム効果 string
TC	ITEM_HELP			; 所有アイテム説明 string

;	隠しパラメータ・各コマンド実行回数

TC	RUN_OSHIRO			;「お城に行く」実行回数
TC	RUN_MACHI	 		;「街に行く」実行回数
TC	RUN_TALK	 		;「娘と話す」実行回数
TC	RUN_KENKOH	 		;「健康管理」実行回数
TC	RUN_SYUGOSEI	 		;「守護星に祈る」実行回数
TC	RUN_KITAERU	 		;「娘を鍛える」実行回数
TC	RUN_ARBEIT	 		;「娘を働かせる」実行回数
TC	GRA_ARBEIT			;「娘を働かせる」待遇
TC	RUN_MUSYA	 		;「武者修行に出す」実行回数
TC	RUN_BACANCE	 		;「休みをあげる」実行回数
TC	RUN_SYUKAKUSAI	 		;「収穫祭」実行回数
TC	RUN_MONTH	 		;「月１イベント」実行回数

;	隠しパラメータ・その他

TC	URA_BREAST_TYPE			; バストの大中小タイプの分類
TC	URA_HIP_TYPE			; ヒップの大中小タイプの分類
TC	URA_PRINCE			; 王子との関係
TC	URA_FATHER			; 父との関係
TC	URA_STEWARD			; 執事との関係
TC	URA_MOTHER_LOVE			; 母性
TC	URA_KILL_MONSTR			; モンスター殺戮数

;	条件判定

TC	E_RIVAL				;ライバル登場
TC	E_KAISIN			;会心の一撃発生倍率２倍
TC	E_KEN				;ｲﾍﾞﾝﾄ｢恩賜の剣売却事件｣発生条件
TC	E_COOL				;ｲﾍﾞﾝﾄ｢厳寒」
TC	E_HOT				;ｲﾍﾞﾝﾄ｢猛暑」
TC	E_COLX				;ｲﾍﾞﾝﾄ｢厳寒｣の被害を防ぐ
TC	E_HOTX				;ｲﾍﾞﾝﾄ｢猛暑｣の被害を防ぐ
TC	E_SEIREI			;ｲﾍﾞﾝﾄ｢精霊に出会う｣発生条件
TC	E_UNICOON			;ｲﾍﾞﾝﾄ｢ユニコーンを発見｣発生条件
TC	E_DEVIL				;ｲﾍﾞﾝﾄ｢悪魔に出会う｣発生条件
TC	E_BENUS				;ｲﾍﾞﾝﾄ｢ビーナスの祝福｣発生条件
TC	E_CAT				;ｲﾍﾞﾝﾄ｢精霊猫に会う｣発生条件
TC	E_MERMAID			;ｲﾍﾞﾝﾄ｢マーメイドに会う｣発生条件
TC	E_PROPOSAL			;ｲﾍﾞﾝﾄ｢プロポーズ｣毎月発生
TC	E_COOK_WIN			;ｲﾍﾞﾝﾄ｢料理コンクール｣優勝出来る
TC	E_EAT_EGG			;ｲﾍﾞﾝﾄ｢極楽鳥の卵を食べる｣発生条件
TC	E_MAX_MP			;ＭＰが減らない
TC	E_RWAY				;ｲﾍﾞﾝﾄ｢家出」
TC	E_EV_SKIP			;イベントスキップ
TC	E_ETC				;その他ｲﾍﾞﾝﾄ発生条件

TC	S_HEALTH_CARE			; 健康管理 string

PUBLIC	TCHRSEG_OFFSET_END
TCHRSEG_OFFSET_END	LABEL	BYTE
	DB	TCHRSEG_FREE_SIZE DUP (0)
	DB	0,0		; end of table.

TCHRSEG	ENDS

TCHRADR	SEGMENT	PUBLIC	'TCHRADR'

PUBLIC	TCHRADR_OFFSET_TOP
TCHRADR_OFFSET_TOP	LABEL	BYTE

TA_DATA	REG_AX			; registar value AX.
TA_DATA	REG_BX			; registar value BX.
TA_DATA	REG_CX			; registar value CX.
TA_DATA	REG_DX			; registar value DX.
TA_DATA	REG_SI			; registar value SI.
TA_DATA	REG_DI			; registar value DI.
TA_DATA	REG_BP			; registar value BP.
TA_DATA	REG_ES			; registar value ES.

TA_DATA	USR_CNT1		; user counter.
TA_DATA	USR_CNT2		; user counter.
TA_DATA	USR_CNT3		; user counter.
TA_DATA	USR_CNT4		; user counter.
TA_DATA	USR_CNT5		; user counter.
TA_DATA	USR_CNT6		; user counter.
TA_DATA	USR_CNT7		; user counter.
TA_DATA	USR_CNT8		; user counter.

TA_DATA	ISLCT			; select number.
TA_DATA	ISITM			; select item number.

TA_CODE	BBC_PR			; syntax : PR  ("string")
TA_CODE	BBC_PRES		; syntax : PRES(length)
TA_CODE	BBC_PRF			; syntax : PRF ("string")
TA_CODE	BBC_PRV			; syntax : PRV ("string",C1)
TA_CODE	BBC_PRVH		; syntax : PRVH("string",C1)
TA_CODE	BBC_PRVB		; syntax : PRVB("string",C1)
TA_CODE	BBC_PRINT		; syntax : PRINT(string)
TA_CODE	BBC_STR			; syntax : STR(C1)
TA_CODE	BBC_HEX			; syntax : HEX(C1)
TA_CODE	BBC_BIN			; syntax : BIN(C1)
TA_CODE	BBC_LLF			; syntax : LLF
TA_CODE	BBC_CLS			; syntax : CLS
TA_CODE	BBC_ABS			; syntax : ABS (value)
TA_CODE	BBC_MOD			; syntax : MOD (value)
TA_CODE	BBC_P1X100		; syntax : P1X100(value,x100)
TA_CODE	BBC_P100PAR		; syntax : P100PAR(value,base)
TA_CODE	BBC_SLCT		; syntax : SLCT("str1,str2,str3")
TA_CODE	BBC_SLCTX		; syntax : SLCTX("str1,str2,str3")
TA_CODE	BBC_SLCTBAK		; syntax : SLCTBAK(backbank)
TA_CODE	BBC_SLCPOS		; syntax : SLCPOS(function)
TA_CODE	BBC_FREE		; syntax : FREE
TA_CODE	BBC_END			; syntax : END

TA_CODE	BBC_STRSCLEAR		; syntax : STRSCLEAR
TA_CODE	BBC_STRSTACK		; syntax : STRSTACK("strings")
TA_CODE	BBC_PROGADRS		; syntax : PROGADRS("label")
TA_CODE	BBC_PROGCOPY		; syntax : PROGCOPY(string)
TA_CODE	BBC_STRCOPY		; syntax : STRCOPY("string",string)
TA_CODE	BBC_STRLEN		; syntax : STRLEN(string)
TA_CODE	BBC_LOAD		; syntax : LOAD("file_name")
TA_CODE	BBC_CK_LVL		; syntax : CK_LVL(count,lv1,lv2,lv3,lvm)
TA_CODE	BBC_CK_GUARA		; syntax : CK_GUARA(count,base)
;*;TA_CODE BBC_CRTREWRITE	; syntax : CRTREWRITE
TA_CODE	BBC_TXTSZ		; syntax : TXTSZ(mode)
TA_CODE	BBC_GOLDADD		; syntax : GOLDADD(value)
TA_CODE	BBC_GOLDSUB		; syntax : GOLDSUB(value)
TA_CODE	BBC_GOLDSUB2		; syntax : GOLDSUB2(value)
TA_CODE	BBC_GOLDCMP		; syntax : GOLDCMP(value)
TA_CODE	BBC_EDTX		; syntax : EDTX(function)

TA_CODE01	TXOPEN		; text window open      : TXOPEN(type)
TA_CODE01	TXCLOSE		; text window close     : TXCLOSE(type)
TA_CODE01	TXSLCT		; text window select    : TXSLCT(type)
TA_CODE01	TXT		; text window print     : TXT("strings")
TA_CODE01	TXA		; text window print adrs: TXA(strings)
TA_CODE01	TXGOLD		; text window お金      : TXGOLD(gold)
TA_CODE01	TXPOINT		; text window ポイント  : TXPOINT(point)
TA_CODE01	TXS2KETA	; text window 小数２桁  : TXS2KETA(value)
TA_CODE01	TXPAUSE		; text window pause     : TXPAUSE
TA_CODE01	TXCLR		; text window clear     : TXCLR
TA_CODE01	TXLF		; text window line feed : TXLF
TA_CODE01	TXFACE		; text window show face : TXFACE("filename")
TA_CODE01	TXGIRL		; text window show girl : TXGIRL(face)
TA_CODE01	TXGIRL		; EETN03.TXT 790行  TXGIRK(1)->TXGIRL(1)
TA_CODE01	TXSYU		; text window show face : TXSYU(syugo)
TA_CODE01	TXLC		; text window locate    : TXLC(type,x,y,face)
TA_CODE01	TXF		; text window function  : TXF(function)
TA_CODE01	ITEMSLCT	; マルチアイテム選択　  : ITEMSLCT(type)
TA_CODE01	ITEMST		; マルチアイテム選択    : ITEMST(type)
TA_CODE01	ITEMPRN		; マルチアイテム表示    : ITEMPRN(function)

TA_CODE01	GR_OPEN		;ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ OPEN  :GR_OPEN
TA_CODE01	GR_CLOSE	;ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ CLOSE :GR_CLOSE
TA_CODE01	GR_F		;ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ function: GR_F(function)
TA_CODE01	GRPOPEN		;ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ       :GRPOPEN(win_type,han)
TA_CODE01	GRPUPD		;ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ 更新  :GRPUPD(han,rec,dat)
TA_CODE01	GOLDOPEN	;ﾊﾟﾗﾒｰﾀ 所持金ｳｲﾝﾄﾞｳ :GOLDOPEN(win_type,han)
TA_CODE01	GOLDUPD		;ﾊﾟﾗﾒｰﾀ 所持金 更新  :GOLDUPD(han,rec,dat)
TA_CODE01	PROFILE		;プロフィール･ｳｲﾝﾄﾞｳ :PROFILE(win_type,handle)
TA_CODE01	PROPROPEN	;ﾌﾟﾛﾎﾟｰｼｮﾝ･ｳｲﾝﾄﾞｳ :PROPROPEN(win_type,handle)
TA_CODE01	PROPRUPD	;ﾌﾟﾛﾎﾟｰｼｮﾝ･ｳｲﾝﾄﾞｳ更新:PROPRUPD(handle,rec,dat)
TA_CODE01	STATUS		;通常ｽﾃｰﾀｽ･ｳｲﾝﾄﾞｳ    :STATUS(win_type,handle)
TA_CODE01	PROLONG		;長い名前ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ:PROLONG(win_type,handle)
TA_CODE01	PRICON		;ICONﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ   :PRICON(win_type,handle)

TA_CODE01	CLENDER		; カレンダー            : CLENDER(function)
TA_CODE01	IRANDAM		; 乱数			: RANDAM(max)
TA_CODE01	IRAND2		; 範囲乱数		: IRAND2(base,max)
TA_CODE01	IRAND999X	; 乱数９９９範囲指定	: IRAND999X(max)
TA_CODE01	IRNDPAR		; +-%の乱数	:IRNDPAR(value,parcent)
TA_CODE01	TIMER1		; タイマー１		: TIMER1(timer60)
TA_CODE01	TIMER2		; タイマー２		: TIMER2(timer60)
TA_CODE01	WAIT1		; タイマー待ち１	: WAIT1
TA_CODE01	WAIT2		; タイマー待ち２	: WAIT2
TA_CODE01	TMCHK2		; タイマーチェック２	: TMCHK2
TA_CODE01	WAITU		; ユーザ待ち		: WAITU
TA_CODE01	VALSTR		; 数値を文字列化	: VALSTR(num)
TA_CODE01	BORTHDAYSTR	; 誕生日を文字列化:BORTHDAYSTR(year,month,day)
TA_CODE01	ITEM_KILL	; アイテム削除       	: ITEM_KILL(rec)
TA_CODE01	ITEM_INST	; アイテム登録         	: ITEM_INST(f,,,,)
TA_CODE01	ITEM_SRCH	; アイテム検索          : ITEM_SRCH(function)
TA_CODE01	SCHD_OPEN	; ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ OPEN: SCHD_OPEN(d,w,end,m,y)
TA_CODE01	SCHD_CLOSE	; ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ CLOSE: SCHD_CLOSE
TA_CODE01	SCHD_ICON	; ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ SET ICON: SCHD_ICON(dy,dy,ic)
TA_CODE01	PALET_SET	; パレットセット    : PALET_SET(rec)
TA_CODE01	PALET_SETONLY	; ﾊﾟﾚｯﾄﾃｰﾌﾞﾙｾｯﾄのみ : PALET_SETONLY(rec,num)

TA_CODE01	WWFRAME		; 全画面枠		: WWFRAME(function)
TA_CODE01	WWMUSYA		; 武者修行		: WWMUSYA(function)
TA_CODE01	WWGIRL		; 娘			: WWGIRL(function)
TA_CODE01	WWANIME		; アニメ・ウインドウ	: WWANIME(function)
TA_CODE01	WWIVENT		; イベント・ウインドウ	: WWIVENT(function)
TA_CODE01	WWPROF		; ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ	: WWPROF(function)
TA_CODE01	WWTOUR		; トーナメント表	: WWTOUR(function)

TA_CODE01	P98F		; PC9801 function.	: P98F(function)
TA_CODE01	PP_PTBK		; パーツバンク設定	: PTBK(bank)
TA_CODE01	PP_PTMD		; ＰＵＴモード設定	: PTMD(mode)
TA_CODE01	PP_PTLD		; パーツロード		: PTLD("filename")
TA_CODE01	PP_PTLA		; パーツ追加ロード	: PTLA("filename")
TA_CODE01	PP_PTX		; パーツ座標ＰＵＴ	: PTX(x,y,rec)
TA_CODE01	PP_PTM		; マスクパーツＰＵＴ	: PTM(x,y,rec)
TA_CODE01	PP_PTF		; ﾊﾟｰﾂｵﾌｾｯﾄ座標ＰＵＴ	: PTF(x,y,rec)
TA_CODE01	PP_PTMF		; ﾏｽｸﾊﾟﾀｰﾝ座標ｵﾌｾｯﾄPUT	: PTMF(x,y,rec)
TA_CODE01	PP_PTMFX	; ﾏｽｸﾊﾟﾀｰﾝ座標ｵﾌｾｯﾄ範囲PUT: PTMFX(x,y,rec...)
TA_CODE01	PP_PTCLR	; パーツバッファクリア	: PTCLR
TA_CODE01	PP_PTGT		; パーツ座標ＰＵＴ	: PTGT(x,y,xl,yl)
TA_CODE01	PP_PTPLT	; パーツパレットセット	: PTPLT(rec,num)

TA_CODE01	EFC		; effect function.	: EFC(function)
TA_CODE01	PIC		; picture function.	: PIC(function)
TA_CODE01	MUSIC		; music.		: MUSIC(function)
TA_CODE01	PLAY		; music play.		: PLAY(n)
TA_CODE01	GG_LINE		; line		: GG_LINE(x1,y1,x2,y2,col)
TA_CODE01	PARC		; parameter calc.	: PARC(function)
TA_CODE01	XDBG		; debug mode		: XDBG(function)
TA_CODE01	GRPCLS		; graphics clear screen.

TA_CODE01	BBC2_FFDISK	; ディスク操作

TA_DATA	ITEMID_TBL1		; アイテムIDﾃｰﾌﾞﾙ／名前ＩＤ
TA_DATA	ITEMID_TBL2		; アイテムIDﾃｰﾌﾞﾙ／ＩＣＯＮ
TA_DATA	ITEMID_TBL3		; アイテムIDﾃｰﾌﾞﾙ／金
TA_DATA	ITEMID_TBL4		; アイテムIDﾃｰﾌﾞﾙ／文字ＩＤ１
TA_DATA	ITEMID_TBL5		; アイテムIDﾃｰﾌﾞﾙ／ﾊﾟﾗﾒｰﾀ値１
TA_DATA	ITEMID_TBL6		; アイテムIDﾃｰﾌﾞﾙ／文字ＩＤ２
TA_DATA	ITEMID_TBL7		; アイテムIDﾃｰﾌﾞﾙ／ﾊﾟﾗﾒｰﾀ値２
TA_DATA	ITEMID_CNT		; アイテムID数
TA_DATA	ITEMID_DIM		; アイテムIDﾃｰﾌﾞﾙｻｲｽﾞ

TA_DATA	IGRP_TBL1		; グラフテーブル／名前
TA_DATA	IGRP_TBL2		; グラフテーブル／タイプ
TA_DATA	IGRP_TBL3		; グラフテーブル／パラメータ値
TA_DATA	IGRP_TBL4		; グラフテーブル／項目名
TA_DATA	IGRP_CNT		; グラフテーブル数
TA_DATA	IGRP_DIM		; グラフ本数の上限
TA_DATA	IGRP_X			; グラフＸ
TA_DATA	IGRP_Y			; グラフＹ

TA_DATA	VAL_YEAR		; 年
TA_DATA	VAL_MONTH		; 月
TA_DATA	VAL_WEEK		; 曜日
TA_DATA	VAL_DAY			; 日
TA_DATA	VAL_A_DAY		; 年内合計日付
TA_DATA	VAL_M_END		; 月末の日
TA_DATA	TM_SEASON		; 季節（1:春,2:夏,3:秋,4:冬）
TA_DATA	FLG_SHOGATSU		; フラグ・正月
TA_DATA	FLG_URUBI		; フラグ・うるう日
TA_DATA	FLG_CHRISTMAS_EVE 	; フラグ・クリスマスイブ
TA_DATA	FLG_G_BORTH		; フラグ・娘の誕生日
TA_DATA	FLG_M_BORTH		; フラグ・私の誕生日
TA_DATA	FLG_HOLIDAY		; フラグ・休日
TA_DATA	FLG_SYUKAKU		; フラグ・収穫祭の準備

TA_DATA	SCHED_SECTION		; ｽｹｼﾞｭｰﾙ項目
TA_DATA	SCHED_WORKS		; ｽｹｼﾞｭｰﾙ内容

TA_DATA	DEF_STR_BROOD		; 血液型・文字列
TA_DATA	DEF_STR_SIKYU		; 子宮名・文字列
TA_DATA	DEF_STR_STAR		; 守護星・文字列
TA_DATA	DEF_STR_LEVEL		; レベル・文字列

TA_DATA	SCH_STARTDAY		; スケジュール開始日
TA_DATA	SCH_ENDDAY		; スケジュール終了日
TA_DATA	SCH_COUNT		; スケジュール数
TA_DATA	SCH_NOW			; スケジュール実行中項目
TA_DATA	SCH_SYUKAKUSAI		; 収穫祭スケジュール

TA_DATA	FLG_TAKARA		; 宝箱フラグ
TA_DATA	ENDNM			; エンディング
TA_DATA	IDBG			; デバッグフラグ

TA_DATA	IRND			; 乱数

TA_DATA	DBGFLAG_CONSOLE		; debug flag console.
TA_DATA	INLINECOMPDBG		; inline compile debug.
TA_DATA	DBGFLAG_FILE		; debug flag file.
TA_DATA	DBGFLAG_ERROR		; debug flag error.

; ****************************************************
;	娘のパラメータ
; ****************************************************

;	基本能力

TA_DATA	B_TAIRYOKU			; 体力
TA_DATA	B_KINRYOKU			; 筋力
TA_DATA	B_CHINOH			; 知能
TA_DATA	B_KIHIN				; 気品
TA_DATA	B_IROKE				; 色気
TA_DATA	B_MORALS			; モラル
TA_DATA	B_SHINKOH			; 信仰
TA_DATA	B_INGYO				; 因業
TA_DATA	B_KANJUSEI			; 感受性
TA_DATA	B_STRESS			; ストレス

;*;TA_DATA	B_UP_TAIRYOKU			; 増強・体力
;*;TA_DATA	B_UP_KINRYOKU			; 増強・筋力
;*;TA_DATA	B_UP_CHINOH			; 増強・知能
;*;TA_DATA	B_UP_KIHIN			; 増強・気品
;*;TA_DATA	B_UP_IROKE			; 増強・色気

;	技能別能力

TA_DATA	H_SENSHI			; 戦士評価
TA_DATA	H_MAHO				; 魔法評価
TA_DATA	H_SYAKOH			; 社交評価
TA_DATA	H_KAJI				; 家事評価

TA_DATA	V_SENTOH			; 戦闘技術
TA_DATA	V_KOUGEKI			; 攻撃力
TA_DATA	V_BOUGYO			; 防御力
TA_DATA	V_MAHOGIJUTSU			; 魔法技術
TA_DATA	V_MARYOKU			; 魔力
TA_DATA	V_KOHMARYOKU			; 抗魔力
TA_DATA	V_REIGI				; 礼儀作法
TA_DATA	V_GEIJYUTSU			; 芸術
TA_DATA	V_WAJYUTU			; 話術
TA_DATA	V_RYOURI			; 料理
TA_DATA	V_SOUJISENTAKU			; 掃除洗濯
TA_DATA	V_KIDATE			; 気だて

TA_DATA	T_SENTOH			; trg戦闘技術
TA_DATA	T_KOUGEKI			; trg攻撃力
TA_DATA	T_BOUGYO			; trg防御力
TA_DATA	T_MAHOGIJUTSU			; trg魔法技術
TA_DATA	T_MARYOKU			; trg魔力
TA_DATA	T_KOHMARYOKU			; trg抗魔力
TA_DATA	T_REIGI				; trg礼儀作法
TA_DATA	T_GEIJYUTSU			; trg芸術
TA_DATA	T_WAJYUTU			; trg話術
TA_DATA	T_RYOURI			; trg料理
TA_DATA	T_SOUJISENTAKU			; trg掃除洗濯
TA_DATA	T_KIDATE			; trg気だて

;*;TA_DATA	V_UP_SENTOH			; 増強・戦闘技術
;*;TA_DATA	V_UP_KOUGEKI			; 増強・攻撃力
;*;TA_DATA	V_UP_BOUGYO			; 増強・防御力
;*;TA_DATA	V_UP_MAHOGIJUTSU 		; 増強・魔法技術
;*;TA_DATA	V_UP_MARYOKU			; 増強・魔力
;*;TA_DATA	V_UP_KOHMARYOKU			; 増強・抗魔力

;	所持金

TA_DATA	GOLD_GIRL			; 娘の所持金
;*;TA_DATA	GOLD_MINE		; 私の所持金

;	プロフィール

TA_DATA	NAME_FIRST			; 名前
TA_DATA	NAME_FAMILY			; 名前(family)
TA_DATA	P_BLOOD				; 血液型
TA_DATA	P_NENREI			; 年齢
TA_DATA	P_BORTHDAY			; 誕生日
TA_DATA	P_BORTHMONTH			; 誕生月
TA_DATA	P_BORTHYEAR			; 誕生年
TA_DATA	P_SHIKYU			; 子宮名
TA_DATA	P_SYUGOSEI			; 守護星
TA_DATA	P_SHINCHO			; 身長
TA_DATA	P_TAIJYU			; 体重
TA_DATA	P_BUST				; バスト
TA_DATA	P_WAIST				; ウエスト
TA_DATA	P_HIP				; ヒップ

;	戦闘ステータス

TA_DATA	W_HP_MAX			; 最大ＨＰ
TA_DATA	W_MP_MAX			; 最大ＭＰ
TA_DATA	W_HP				; ＨＰ
TA_DATA	W_MP				; ＭＰ
TA_DATA	W_SENI				; 戦意

;	通常ステータス

TA_DATA	S_BYOUKI			; 病気指数(%)
TA_DATA	S_HIKOUKA			; 非行化指数(%)
TA_DATA	S_JINMYAKU			; 人脈
TA_DATA	FLAG_BYOUKI			; 状態・病気
TA_DATA	FLAG_HIKOUKA			; 状態・非行化
TA_DATA	FLAG_RENAI			; 状態・恋愛
TA_DATA	FLAG_KENKO			; 健康管理
TA_DATA	GIRL_BODY			; 体形 1=細,2=太
TA_DATA	GIRL_FACE			; 表情 1=基本,2=非行,3病気,4元気,5色気
TA_DATA	GIRL_BREAST			; 胸大 0=無,1=有
TA_DATA	GIRL_DAMEG			; 重病 0=normal,1=重病

;	装備

TA_DATA	ROOM_PIC			; 部屋の絵

TA_DATA	DRESS_NUM			; 着衣絵番号

TA_DATA	DRESS_ICON			; 着衣　ＩＣＯＮ番号
TA_DATA	DRESS_GOLD			; 着衣　値段
TA_DATA	DRESS_NAME			; 着衣　名前 string
TA_DATA	DRESS_PROG			; 着衣　効果 string

TA_DATA	EQUIP_ICON			; 装備　ＩＣＯＮ番号
TA_DATA	EQUIP_GOLD			; 装備　値段
TA_DATA	EQUIP_NAME			; 装備　名前
TA_DATA	EQUIP_PROG			; 装備　効果
TA_DATA	EQUIP_HELP			; 装備　説明 string

TA_DATA	ARMS_ICON			; 武器　ＩＣＯＮ番号
TA_DATA	ARMS_GOLD			; 武器　値段
TA_DATA	ARMS_NAME			; 武器　名前
TA_DATA	ARMS_PROG			; 武器　効果
TA_DATA	ARMS_HELP			; 武器　説明 string

TA_DATA	ITEM_MAX			; 所有アイテム数
TA_DATA	ITEM_DIM			; 所有最大アイテム数
TA_DATA	ITEM_ICON			; 所有アイテムＩＣＯＮ番号
TA_DATA	ITEM_GOLD			; 所有アイテム値段
TA_DATA	ITEM_ATTR			; 所有アイテム種別
TA_DATA	ITEM_NAME			; 所有アイテム名前 string
TA_DATA	ITEM_PROG			; 所有アイテム効果 string
TA_DATA	ITEM_HELP			; 所有アイテム説明 string

;	隠しパラメータ・各コマンド実行回数

TA_DATA	RUN_OSHIRO			;「お城に行く」実行回数
TA_DATA	RUN_MACHI	 		;「街に行く」実行回数
TA_DATA	RUN_TALK	 		;「娘と話す」実行回数
TA_DATA	RUN_KENKOH	 		;「健康管理」実行回数
TA_DATA	RUN_SYUGOSEI	 		;「守護星に祈る」実行回数
TA_DATA	RUN_KITAERU	 		;「娘を鍛える」実行回数
TA_DATA	RUN_ARBEIT	 		;「娘を働かせる」実行回数
TA_DATA	GRA_ARBEIT			;「娘を働かせる」待遇
TA_DATA	RUN_MUSYA	 		;「武者修行に出す」実行回数
TA_DATA	RUN_BACANCE	 		;「休みをあげる」実行回数
TA_DATA	RUN_SYUKAKUSAI	 		;「収穫祭」実行回数
TA_DATA	RUN_MONTH	 		;「月１イベント」実行回数

;	隠しパラメータ・その他

TA_DATA	URA_BREAST_TYPE			; バストの大中小タイプの分類
TA_DATA	URA_HIP_TYPE			; ヒップの大中小タイプの分類
TA_DATA	URA_PRINCE			; 王子との関係
TA_DATA	URA_FATHER			; 父との関係
TA_DATA	URA_STEWARD			; 執事との関係
TA_DATA	URA_MOTHER_LOVE			; 母性
TA_DATA	URA_KILL_MONSTR			; モンスター殺戮数

;	条件判定

TA_DATA	E_RIVAL				;ライバル登場
TA_DATA	E_KAISIN			;会心の一撃発生倍率２倍
TA_DATA	E_KEN				;ｲﾍﾞﾝﾄ｢恩賜の剣売却事件｣発生条件
TA_DATA	E_COOL				;ｲﾍﾞﾝﾄ｢厳寒」
TA_DATA	E_HOT				;ｲﾍﾞﾝﾄ｢猛暑」
TA_DATA	E_COLX				;ｲﾍﾞﾝﾄ｢厳寒｣の被害を防ぐ
TA_DATA	E_HOTX				;ｲﾍﾞﾝﾄ｢猛暑｣の被害を防ぐ
TA_DATA	E_SEIREI			;ｲﾍﾞﾝﾄ｢精霊に出会う｣発生条件
TA_DATA	E_UNICOON			;ｲﾍﾞﾝﾄ｢ユニコーンを発見｣発生条件
TA_DATA	E_DEVIL				;ｲﾍﾞﾝﾄ｢悪魔に出会う｣発生条件
TA_DATA	E_BENUS				;ｲﾍﾞﾝﾄ｢ビーナスの祝福｣発生条件
TA_DATA	E_CAT				;ｲﾍﾞﾝﾄ｢精霊猫に会う｣発生条件
TA_DATA	E_MERMAID			;ｲﾍﾞﾝﾄ｢マーメイドに会う｣発生条件
TA_DATA	E_PROPOSAL			;ｲﾍﾞﾝﾄ｢プロポーズ｣毎月発生
TA_DATA	E_COOK_WIN			;ｲﾍﾞﾝﾄ｢料理コンクール｣優勝出来る
TA_DATA	E_EAT_EGG			;ｲﾍﾞﾝﾄ｢極楽鳥の卵を食べる｣発生条件
TA_DATA	E_MAX_MP			;ＭＰが減らない
TA_DATA	E_RWAY				;ｲﾍﾞﾝﾄ｢家出」
TA_DATA	E_EV_SKIP			;イベントスキップ
TA_DATA	E_ETC				;その他ｲﾍﾞﾝﾄ発生条件

TA_DATA	S_HEALTH_CARE			; 健康管理 string

PUBLIC	TCHRADR_OFFSET_END
TCHRADR_OFFSET_END	LABEL	BYTE

	DW	TCHRADR_REC_MAX	DUP (0)
	DW	TCHRADR_REC_MAX	DUP (0)

TCHRADR	ENDS

	END
;
;	end of "BBSYMBL.ASM"
;
