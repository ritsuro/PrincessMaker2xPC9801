; "BBCTOOL3.ASM" 486/50 make by R.H 1992/05/29
;
;
;	princess  B A S I C    command tool 3.
;
;
;	* * * WARNING * * *
;	* * *  注 意  * * *
;
;	This subroutines i/o list.
;	このサブルーチン類の I/O list は以下のようになっています。
;
;	AX -> public REG_AX
;	BX -> public REG_BX
;	CX -> public REG_CX
;	DX -> public REG_DX
;	SI -> public REG_SI
;	DI -> public REG_DI
;	ES -> public REG_ES
;
;	; syntax : P1X100(value,x100)	-> ; syntax : P1X100
;	; 百分率			-> ; 百分率
;	; -i- value (AX): source value.	-> ; -i- REG_AX : source value.
;	;     x100  (BX): %		-> ;     REG_BX : %
;	; -o- AX        : value.	-> ; -o- REG_AX : value.
;
;
;
; command routine.

INCLUDE	TSTSET.INC
INCLUDE	BBEXTRN.INC
INCLUDE	MACHINEX.INC

DEBUG_PALET	EQU	0
DEBUG_KEYBORD	EQU	0

STACK	SEGMENT	STACK
EXTRN	TOP_OF_STACK:WORD
STACK	ENDS

EMMCOD	SEGMENT	PUBLIC	'EMMCOD'
	ASSUME	CS:EMMCOD
EXTRN	EMEMCHECK:FAR		; (far)Expanded memory check.
EXTRN	EMEMAREA64K:FAR		; (far)Expanded memory 64k area allocate.
EXTRN	EMEMALLOC:FAR		; (far)Expanded memory allocate.
EXTRN	EMEMDEALLOC:FAR		; (far)Expanded memory deallocate.
EXTRN	EMEMQUICK:FAR		; (far)Expanded memory data name search.
EXTRN	EMEMLOAD:FAR		; (far)Expanded memory data load.
EMMCOD	ENDS

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	TXOPEN		; text window open      : TXOPEN(type)
PUBLIC	TXCLOSE		; text window close     : TXCLOSE(type)
PUBLIC	TXSLCT		; text window select    : TXSLCT(type)
PUBLIC	TXT		; text window print     : TXT("strings")
PUBLIC	TXA		; text window print adrs: TXA(strings)
PUBLIC	TXGOLD		; text window お金      : TXGOLD(gold)
PUBLIC	TXPOINT		; text window ポイント  : TXPOINT(point)
PUBLIC	TXS2KETA	; text window 小数２桁  : TXS2KETA(value)
PUBLIC	TXPAUSE		; text window pause     : TXPAUSE
PUBLIC	TXCLR		; text window clear     : TXCLR
PUBLIC	TXLF		; text window line feed : TXLF
PUBLIC	TXFACE		; text window show face : TXFACE("filename")
PUBLIC	TXGIRL		; text window show girl : TXGIRL(face)
PUBLIC	TXSYU		; text window show face : TXSYU(syugo)
PUBLIC	TXLC		; text window locate    : TXLC(type,x,y,face)
PUBLIC	TXF		; text window function  : TXF(function)
PUBLIC	ITEMSLCT	; マルチアイテム選択    : ITEMSLCT(type)
PUBLIC	ITEMST		; マルチアイテム選択    : ITEMST(type)
PUBLIC	ITEMPRN		; マルチアイテム表示    : ITEMPRN(function)

PUBLIC	GR_OPEN		; ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ OPEN    : GR_OPEN
PUBLIC	GR_CLOSE	; ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ CLOSE   : GR_CLOSE
PUBLIC	GR_F		; ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ function: GR_F(function)
PUBLIC	GRPOPEN		; ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ         : GRPOPEN(win_type,handle)
PUBLIC	GRPUPD		; ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ 更新    : GRPUPD(handle,rec,dat)
PUBLIC	GOLDOPEN	; ﾊﾟﾗﾒｰﾀ 所持金ｳｲﾝﾄﾞｳ   : GOLDOPEN(win_type,handle)
PUBLIC	GOLDUPD		; ﾊﾟﾗﾒｰﾀ 所持金 更新    : GOLDUPD(handle,rec,dat)
PUBLIC	PROFILE		; プロフィール･ｳｲﾝﾄﾞｳ	: PROFILE(win_type,handle)
PUBLIC	PROPROPEN	; ﾌﾟﾛﾎﾟｰｼｮﾝ･ｳｲﾝﾄﾞｳ      : PROPROPEN(win_type,handle)
PUBLIC	PROPRUPD	; ﾌﾟﾛﾎﾟｰｼｮﾝ･ｳｲﾝﾄﾞｳ 更新 : PROPRUPD(handle,rec,dat)
PUBLIC	STATUS		; 通常ｽﾃｰﾀｽ･ｳｲﾝﾄﾞｳ      : STATUS(win_type,handle)
PUBLIC	PROLONG		; 長い名前ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ	: PROLONG(win_type,handle)
PUBLIC	PRICON		; ICONﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ	: PRICON(win_type,handle)

PUBLIC	CLENDER		; カレンダー            : CLENDER(function)
PUBLIC	IRANDAM		; 乱数			: RANDAM(max)
PUBLIC	IRAND2		; 範囲乱数		: IRAND2(base,max)
PUBLIC	IRAND999X	; 乱数９９９範囲指定	: IRAND999X(max)
PUBLIC	IRNDPAR		; +-%の乱数		: IRNDPAR(value,parcent)
PUBLIC	TIMER1		; タイマー１		: TIMER1(timer60)
PUBLIC	TIMER2		; タイマー２		: TIMER2(timer60)
PUBLIC	WAIT1		; タイマー待ち１	: WAIT1
PUBLIC	WAIT2		; タイマー待ち２	: WAIT2
PUBLIC	TMCHK2		; タイマーチェック２	: TMCHK2
PUBLIC	WAITU		; ユーザ待ち		: WAITU
PUBLIC	VALSTR		; 数値を文字列化	: VALSTR(num)
PUBLIC	BORTHDAYSTR	; 誕生日を文字列化	: BORTHDAYSTR(year,month,day)
PUBLIC	ITEM_KILL	; アイテム削除          : ITEM_KILL(rec)
PUBLIC	ITEM_INST	; アイテム登録          : ITEM_INST(f,,,,)
PUBLIC	ITEM_SRCH	; アイテム検索          : ITEM_SRCH(function)
PUBLIC	SCHD_OPEN	; ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ OPEN	: SCHD_OPEN(d,w,end,m,y)
PUBLIC	SCHD_CLOSE	; ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ CLOSE	: SCHD_CLOSE
PUBLIC	SCHD_ICON	; ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ SET ICON : SCHD_ICON(s_day,e_day,icon)

PUBLIC	PALET_SET	; パレットセット	: PALET_SET(rec)
PUBLIC	PALET_SETONLY	; パレットテーブルセットのみ : PALET_SETONLY(rec,num)

PUBLIC	WWFRAME		; 全画面枠		: WWFRAME(function)
PUBLIC	WWMUSYA		; 武者修行		: WWMUSYA(function)
PUBLIC	WWGIRL		; 娘			: WWGIRL(function)
PUBLIC	WWANIME		; アニメ・ウインドウ	: WWANIME(function)
PUBLIC	WWIVENT		; イベント・ウインドウ	: WWIVENT(function)
PUBLIC	WWPROF		; ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ	: WWPROF(function)
PUBLIC	WWTOUR		; トーナメント表	: WWTOUR(function)

PUBLIC	P98F		; PC9801 function.	: P98F(function)

PUBLIC	PP_PTBK		; パーツバンク設定	: PTBK(bank)
PUBLIC	PP_PTMD		; ＰＵＴモード設定	: PTMD(mode)
PUBLIC	PP_PTLD		; パーツロード		: PTLD("filename")
PUBLIC	PP_PTLA		; パーツ追加ロード	: PTLA("filename")
PUBLIC	PP_PTX		; パーツ座標ＰＵＴ	: PTX(x,y,rec)
PUBLIC	PP_PTM		; マスクパーツＰＵＴ	: PTM(x,y,rec)
PUBLIC	PP_PTF		; ﾊﾟｰﾂｵﾌｾｯﾄ座標ＰＵＴ	: PTF(x,y,rec)
PUBLIC	PP_PTMF		; ﾏｽｸﾊﾟﾀｰﾝ座標ｵﾌｾｯﾄPUT	: PTMF(x,y,rec)
PUBLIC	PP_PTMFX	; ﾏｽｸﾊﾟﾀｰﾝ座標ｵﾌｾｯﾄ範囲PUT : PTMFX(x,y,rec...)
PUBLIC	PP_PTCLR	; パーツバッファクリア	: PTCLR
PUBLIC	PP_PTGT		; パーツ座標ＰＵＴ	: PTGT(x,y,xl,yl)
PUBLIC	PP_PTPLT	; パーツパレットセット	: PTPLT(rec,num)

PUBLIC	EFC		; effect function.	: EFC(function)

PUBLIC	PIC		; picture function.	: PIC(function)

PUBLIC	MUSIC		; music.		: MUSIC(function)

PUBLIC	PLAY		; music play.		: PLAY(n)

PUBLIC	GG_LINE		; line			: GG_LINE(x1,y1,x2,y2,col)

PUBLIC	PARC		; parameter calc.	: PARC(function)

PUBLIC	XDBG		; debug mode.		: XDBG(function)

PUBLIC	BBCTOOL3_LOADINIT	; テキストロード時の初期処理(far)

EXTRN	FEDIN:NEAR	; Ｆ・Ｉ（フェードイン）
EXTRN	FEDOUT:NEAR	; Ｆ・Ｏ（フェードアウト）
EXTRN	WHTFLS:NEAR	; ＷＨＩＴＥ・ＦＬＡＳＨ
EXTRN	WHTIN:NEAR	; ＷＨＩＴＥ・ＩＮ
EXTRN	WHTOUT:NEAR	; ＷＨＩＴＥ・ＯＵＴ
EXTRN	COLFLS:NEAR	; カラー・ＦＬＡＳＨ
EXTRN	COLFUL:NEAR	; カラー・ＦＵＬＬ
EXTRN	BLACK:NEAR	; ブラックアウト
EXTRN	WHITE:NEAR	; ＷＨＩＴＥ
EXTRN	BRIIN:NEAR	; 明度５０％からノーマルへ
EXTRN	BRIOUT:NEAR	; 明度５０％ダウン
EXTRN	COLBCK:NEAR	; 色相反転
EXTRN	COLRET:NEAR	; 色相戻し
EXTRN	FFWHT:NEAR	; ＷＨＩＴＥ反射感
EXTRN	PLTOL:NEAR	; パレット・オーバラップ
EXTRN	PLTMIX:NEAR	; パレット・混合
EXTRN	NORMIN:NEAR	; ノーマルカラー
EXTRN	DWN50P:NEAR	; 明度５０％ダウン（瞬間）
EXTRN	PLTINT_P10_ON:NEAR	; 18=palet10変化割込ON
EXTRN	PLTINT_P10_OFF:NEAR	; 19=palet10変化割込OFF
EXTRN	PLTINT_FO:NEAR	; 割り込みＦ・Ｏ(ﾌｪｰﾄﾞｱｳﾄ)
EXTRN	PLTINT_FI:NEAR	; 割り込みＦ・Ｉ(ﾌｪｰﾄﾞｲﾝ)
EXTRN	PLTINT_WI:NEAR	; 割り込みＷＨＩＴＥ・ＩＮ
EXTRN	PLTINT_WO:NEAR	; 割り込みＷＨＩＴＥ・ＯＵＴ
EXTRN	PLTINT_P567_ON:NEAR	; palet5,6,7変化割込ON(OPENING用)
EXTRN	PLTINT_P567_OFF:NEAR	; palet5,6,7変化割込OFF(OPENING用)

EXTRN	M_SETUP_PMD:NEAR	; 音楽システムPMD起動
EXTRN	M_SETUP_MMD:NEAR	; 音楽システムMMD起動
EXTRN	M_SETUP_MIDI:NEAR	; 音楽システムMIDI設定
EXTRN	M_INIT:NEAR		; 音楽システム初期処理
EXTRN	M_PLAY:NEAR		; 音楽演奏
EXTRN	M_STOP:NEAR		; 音楽停止
EXTRN	M_FDOT:NEAR		; 音楽フェードアウト
EXTRN	M_TIMER:NEAR		; 音楽用ﾀｲﾏｰｾｯﾄ
EXTRN	M_TIMER2:NEAR		; ｴﾝﾃﾞｨﾝｸﾞ音楽用ﾀｲﾏｰｾｯﾄ2
EXTRN	M_TIMER2WAIT:NEAR	; ｴﾝﾃﾞｨﾝｸﾞ音楽用ﾀｲﾏｰWAIT

EXTRN	SNDON:NEAR		; 効果音発生

EXTRN	WIDPROF_SET:NEAR	; WINDOWS/プロフィール・表示
EXTRN	WIDPROF_SHOW:NEAR	; WINDOWS/プロフィール・再表示
EXTRN	WIDPROF_GOLD:NEAR	; WINDOWS/プロフィール・所持金
EXTRN	WIDPROF_AGE:NEAR	; WINDOWS/プロフィール・年齢
EXTRN	WIDPROF_R_GOLD:NEAR	; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･所持金
EXTRN	WIDPROF_R_HP:NEAR	; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･HP
EXTRN	WIDPROF_R_MP:NEAR	; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･MP
EXTRN	WIDPROF_R_ARMS:NEAR	; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･装備


; *********************************************************
;	text window open      : TXOPEN(type)
;	-i- type : window type.
; *********************************************************

TXOPEN	PROC	NEAR
	MOV	DX,REG_AX		; registar value AX.
	CALLE	WID_TEXT_OPEN		; WINDOWS/テキストウインドウＯＰＥＮ
	RET
TXOPEN	ENDP


; *********************************************************
;	text window close     : TXCLOSE(type)
;	-i- type : window type.
; *********************************************************

TXCLOSE	PROC	NEAR
	MOV	DX,REG_AX		; registar value AX.
	CALLE	WID_TEXT_CLOSE		; WINDOWS/テキストウインドウＣＬＯＳＥ
	RET
TXCLOSE	ENDP


; *********************************************************
;	text window select    : TXSLCT(type)
;	-i- type : window type.
; *********************************************************

TXSLCT	PROC	NEAR
	MOV	DX,REG_AX		; registar value AX.
	CALLE	WID_TEXT_STRIME		; WINDOWS/テキストウインドウ選択
	RET
TXSLCT	ENDP


; *********************************************************
;	text window print     : TXT("strings")
;	-i- "strings" : string.
; *********************************************************

TXT	PROC	NEAR
	MOV	SI,REG_SI		; registar value SI.
	CALLE	WID_TEXT_PRINT		; WINDOWS/テキストウインドウ表示
	RET
TXT	ENDP


; *********************************************************
;	text window print adrs  : TXA(strings)
;	-i- strings : string address.
; *********************************************************

TXA	PROC	NEAR
	MOV	SI,REG_AX		; registar value SI.
	CALLE	WID_TEXT_PRINT		; WINDOWS/テキストウインドウ表示
	RET
TXA	ENDP


; *********************************************************
;	text window お金     : TXGOLD(gold)
;	-i- gold : show gold.
; *********************************************************

TXGOLD	PROC	NEAR
	MOV	DX,REG_AX		; お金
	CALLE	UNIT_S_GOLD		; お金文字列
	MOV	SI,OFFSET STR_BUFF	; お金文字列
	CALLE	WID_TEXT_PRINT		; WINDOWS/テキストウインドウ表示
	RET
TXGOLD	ENDP


; *********************************************************
;	text window ポイント     : TXPOINT(point)
;	-i- point : show point.
; *********************************************************

TXPOINT	PROC	NEAR
	MOV	DX,REG_AX		; お金
	CALLE	UNIT_S_POINT		; ポイント文字列
	MOV	SI,OFFSET STR_BUFF	; お金文字列
	CALLE	WID_TEXT_PRINT		; WINDOWS/テキストウインドウ表示
	RET
TXPOINT	ENDP


; *********************************************************
;	text window 小数２桁  : TXS2KETA(value)
;	-i- value : value.
; *********************************************************

TXS2KETA	PROC	NEAR
	MOV	DX,REG_AX		; お金
	CALLE	UNIT_S_S2KETA		; 小数２桁文字列
	MOV	SI,OFFSET STR_BUFF	; お金文字列
	CALLE	WID_TEXT_PRINT		; WINDOWS/テキストウインドウ表示
	RET
TXS2KETA	ENDP


; *********************************************************
;	text window pause     : TXPAUSE
; *********************************************************

TXPAUSE	PROC	NEAR
	CALLE	WID_TEXT_PAUSE		; WINDOWS/テキストウインドウＰＡＵＳＥ
	RET
TXPAUSE	ENDP


; *********************************************************
;	text window clear     : TXCLR
; *********************************************************

TXCLR	PROC	NEAR
	CALLE	WID_TEXT_CLR		; WINDOWS/テキストウインドウクリア
	RET
TXCLR	ENDP


; *********************************************************
;	text window line feed : TXLF
; *********************************************************

TXLF	PROC	NEAR
	CALLE	WID_TEXT_LF		; WINDOWS/テキストウインドウ改行
	RET
TXLF	ENDP


; *********************************************************
;	text window show face : TXFACE("filename")
;	-I- SI : フェイスファイル名
; *********************************************************

TXFACE	PROC	NEAR
	MOV	SI,REG_SI		; registar value SI.
	CALLE	WID_TEXT_FACE		; WINDOWS/テキストウインドウフェイス
	RET
TXFACE	ENDP


; *********************************************************
;	text window show girl : TXGIRL(face)
;	-I- face (AX) : 0=普通 1=嬉しい 2=怒り 3=悲しい 4=暑い
;	         5=寒い 6=大怪我 7=苦しい 8=すねる
;	         9=不思議 10=恥らう 11=不安 12=不愉快
;	        13=妖しい 14=りりしい 15=驚き 16=ガーン
;	        17=真剣 18=困り
; *********************************************************

TXGIRL	PROC	NEAR
	MOV	DX,REG_AX		;
	CALLE	WID_TEXT_FACEGIRL	; WINDOWS/テキストウインドウ娘フェイス
	RET
TXGIRL	ENDP


; *********************************************************
;	text window show face : TXSYU(syugo)
;	-I- syugo (AX) : 守護星
;		0="太陽",1="月",2="火星",3="水星",4="木星",5="金星"
;		6="土星",7="天王星",8="海王星",9="冥王星"
; *********************************************************

TXSYU	PROC	NEAR
	MOV	DX,REG_AX		;
	CALLE	WID_TEXT_FACESYUGO	; WINDOWS/ウインドウ守護星フェイス
	RET
TXSYU	ENDP


; *********************************************************
;	text window locate    : TXLC(type,x,y,face)
;	-I- type     (AX): テキスト・タイプ
;	    x        (BX): locate x.
;	    y        (CX): locate y.
;	    face     (DX): フェイス位置 0=none,1=left,2=right.
; *********************************************************

TXLC	PROC	NEAR
	MOVX	WDX1,REG_BX		; locate x.
	MOVX	WDY1,REG_CX		; locate y.
	MOV	DX,REG_AX		; テキスト・タイプ
	MOV	AX,REG_DX		; フェイス位置 0=none,1=left,2=right.
	CALLE	WID_TEXT_LOCATE		; WINDOWS/テキストウインドウ位置
	RET
TXLC	ENDP


; *********************************************************
;	text window function  : TXF(function)
;	-i- function (AX) : 機能
;
;	TXF(1,flag_back)  : ﾃｷｽﾄｳｲﾝﾄﾞｳ退避のを止める
;	-i- flag_back (BX): flag window back.
;	TXF(2)            : マウスOFF待ち
;	TXF(3)            : 乱数初期化
;	TXF(4,string,length) : 漢字文字詰め処理
;	-i- string    (BX): 漢字文字列
;	    length    (CX): 表示名前の最長
;	TXF(5,"filename",x,y) : テキストウインドウ ﾌｪｲｽのみ
;	    "filename"(SI) : ファイル名
;	    x         (BX) : locate x.
;	    y         (CX) : locate y.
;	TXF(6,face,x,y) : テキストウインドウ 娘ﾌｪｲｽのみ
;	-i- face      (BX) : 0=普通 1=嬉しい 2=怒り 3=悲しい ...
;	    x         (CX) : locate x.
;	    y         (DX) : locate y.
;	TXF(7,timer)    : WINDOWS/テキストウインドウ文字送りﾀｲﾏ
;	-i- timer     (AX) : timer.
;	TXF(8,face,x,y) : テキストウインドウ 守護星ﾌｪｲｽのみ
;	-i- face      (BX) : 0="太陽",1="月",2="火星"...
;	    x         (CX) : locate x.
;	    y         (DX) : locate y.
;	TXF(9,point) : ﾎﾟｲﾝﾄの文字列化
;	-o- SI       : ポイント文字列
;	TXF(10)      : ﾉｰﾏﾙ時ﾃｷｽﾄﾓｰﾄﾞ
;	TXF(11)      : 戦闘時ﾃｷｽﾄﾓｰﾄﾞ
;	TXF(12)      : タイマ無ﾃｷｽﾄﾓｰﾄﾞ
; *********************************************************

TXF	PROC	NEAR
	MOV	AX,REG_AX		;
	CMP	AL,1			; ﾃｷｽﾄｳｲﾝﾄﾞｳ退避のを止める
	JE	TXF_01F
	CMP	AL,2			; ﾃｷｽﾄｳｲﾝﾄﾞｳ退避のを止める
	JE	TXF_02F
	CMP	AL,3			; 乱数初期化
	JE	TXF_03F
	CMP	AL,4			; 漢字文字詰め処理
	JE	TXF_04F
	CMP	AL,5
	JE	TXF_05F
	CMP	AL,6
	JE	TXF_06F
	CMP	AL,7
	JE	TXF_07F
	CMP	AL,8
	JE	TXF_08F
	CMP	AL,9
	JE	TXF_09F
	CMP	AL,10
	JE	TXF_10F
	CMP	AL,11
	JE	TXF_11F
	CMP	AL,12
	JE	TXF_12F
	RET
TXF_01F:
	MOV	AX,REG_BX		;
	CALLE	WID_TEXT_BACK_DIS	; WINDOWS/テキストウインドウ退避のを止める
	RET
TXF_02F:
	CALLE	MUSWAT			; マウスボタンＯＦＦ待ち
	RET
TXF_03F:
	CALLE	RANDAM_STR		; 乱数スタート
	RET
TXF_04F:
	MOV	SI,REG_BX		; 漢字文字列
	MOV	CX,REG_CX		; 表示名前の最長
	CALLE	KANJITUME		; 漢字文字詰め処理
	RET
TXF_05F:
	MOV	SI,REG_SI		; フェイスファイル名
	MOV	AX,REG_BX		; x.
	MOV	BX,REG_CX		; y.
	CALLE	WID_TEXT_ONLY_FACE	; WINDOWS/テキストウインドウ ﾌｪｲｽのみ
	RET
TXF_06F:
	MOV	DX,REG_BX		; 0=普通 1=嬉しい 2=怒り 3=悲しい...
	MOV	AX,REG_CX		; x.
	MOV	BX,REG_DX		; y.
	CALLE	WID_TEXT_ONLY_FACEGIRL	;WINDOWS/テキストウインドウ 娘ﾌｪｲｽのみ
	RET
TXF_07F:
	MOV	AX,REG_BX		;
	CALLE	WID_TEXT_PAC		;WINDOWS/テキストウインドウ文字送りﾀｲﾏ
	RET
TXF_08F:
	MOV	DX,REG_BX		; 0="太陽",1="月",2="火星"...
	MOV	AX,REG_CX		; x.
	MOV	BX,REG_DX		; y.
	CALLE	WID_TEXT_ONLY_FACESYUGO	; WINDOWS/ﾃｷｽﾄｳｲﾝﾄﾞｳ 守護星ﾌｪｲｽのみ
	RET
TXF_09F:
	MOV	DX,REG_BX		; ポイント
	CALLE	UNIT_S_POINT		; ポイント文字列
	MOV	REG_SI,OFFSET STR_BUFF	; ポイント文字列
	RET
TXF_10F:
	MOV	AX,2
	CALLE	WID_TEXT_PAC		;WINDOWS/テキストウインドウ文字送りﾀｲﾏ
	RET
TXF_11F:
	MOV	AX,0
	CALLE	WID_TEXT_PAC		;WINDOWS/テキストウインドウ文字送りﾀｲﾏ
	RET
TXF_12F:
	MOV	AX,0
	CALLE	WID_TEXT_PAC		;WINDOWS/テキストウインドウ文字送りﾀｲﾏ
	RET
TXF	ENDP


; *********************************************************
;	マルチアイテム選択　: ITEMSLCT(type)
;	-i- type  (AX)      : ウインドウＯＰＥＮタイプ
;			   1=道具、武器
;			   2=鍛える
;			   3=アルバイト
;	    ITEMID_TBL1[] : アイテムＩＤテーブル／名前
;	    ITEMID_TBL2[] : アイテムＩＤテーブル／ＩＣＯＮ
;	    ITEMID_TBL3[] : アイテムＩＤテーブル／金
;	    ITEMID_TBL4[] : アイテムＩＤテーブル／文字１
;	    ITEMID_TBL5[] : アイテムＩＤテーブル／パラメータ値１
;	    ITEMID_TBL6[] : アイテムＩＤテーブル／文字２
;	    ITEMID_TBL7[] : アイテムＩＤテーブル／パラメータ値２
;	    ITEMID_CNT    : アイテムＩＤ数
;	-O- ISITM         : アイテム選択番号
; *********************************************************

ITEMSLCT	PROC	NEAR
	MOV	DX,REG_AX		; registar value AX.
	CALLE	WIDMULT			; WINDOWS/マルチアイテム
	MOVX	ISITM,WIDINM		; アイテム選択番号
	RET
ITEMSLCT	ENDP


; *********************************************************
;	マルチアイテム選択　: ITEMST(type)
;	選択アイテム残して背景復帰
;	-i- type  (AX)      : ウインドウＯＰＥＮタイプ
;			   1=道具、武器
;			   2=鍛える
;			   3=アルバイト
;			  99=選択アイテムクリア
;	    ITEMID_TBL1[] : アイテムＩＤテーブル／名前
;	    ITEMID_TBL2[] : アイテムＩＤテーブル／ＩＣＯＮ
;	    ITEMID_TBL3[] : アイテムＩＤテーブル／金
;	    ITEMID_TBL4[] : アイテムＩＤテーブル／文字１
;	    ITEMID_TBL5[] : アイテムＩＤテーブル／パラメータ値１
;	    ITEMID_TBL6[] : アイテムＩＤテーブル／文字２
;	    ITEMID_TBL7[] : アイテムＩＤテーブル／パラメータ値２
;	    ITEMID_CNT    : アイテムＩＤ数
;	-O- ISITM         : アイテム選択番号
; *********************************************************

ITEMST	PROC	NEAR
	MOV	DX,REG_AX		; registar value AX.

	CMP	DX,99			;
	JE	ITEMST2_CLEAR		;

	CALLE	WIDMULT2N		; WINDOWS/マルチアイテム２
	MOVX	ISITM,WIDINM		; アイテム選択番号
	RET
ITEMST2_CLEAR:
	CALLE	WIDMULT2NCLEAR		; WINDOWS/マルチアイテム２CLAER
	MOV	ISITM,0
	RET
ITEMST	ENDP


; *********************************************************
;	マルチアイテム表示    : ITEMPRN(function)
;	-i- function : 機能
;
;	ITEMPRN(1,type)		: マルチアイテム表示
;	-i- type  (BX)	: ウインドウＯＰＥＮタイプ
;			1=道具、武器
;			2=鍛える
;			3=アルバイト
;			4=休息・武者修行など
;			5=道具、武器（任意の位置へ）
;	    ITEMID_TBL1[] : アイテムＩＤテーブル／名前
;	    ITEMID_TBL2[] : アイテムＩＤテーブル／ＩＣＯＮ
;	    ITEMID_TBL3[] : アイテムＩＤテーブル／金
;	    ITEMID_TBL4[] : アイテムＩＤテーブル／文字１
;	    ITEMID_TBL5[] : アイテムＩＤテーブル／パラメータ値１
;	    ITEMID_TBL6[] : アイテムＩＤテーブル／文字２
;	    ITEMID_TBL7[] : アイテムＩＤテーブル／パラメータ値２
;	    ITEMID_CNT    : アイテムＩＤ数
;	ITEMPRN(2)	: マルチアイテム復帰
;	ITEMPRN(3,x,y)	: マルチアイテム TYPE 5 位置
;	ITEMPRN(4,flag)	: マルチアイテムｷｬﾝｾﾙON/OFF
;	-i- flag  (BX)  : 1=ｷｬﾝｾﾙON,0=ｷｬﾝｾﾙOFF
;	ITEMPRN(5,flag)	: マルチアイテムﾌｧﾝｸｼｮﾝON/OFF
;	-i- flag  (BX)  : 1=ﾌｧﾝｸｼｮﾝON,0=ﾌｧﾝｸｼｮﾝOFF
;	ITEMPRN(6,flag) : マルチアイテムｶﾚﾝﾄﾍﾟｰｼﾞON/OFF
;	-i- flag  (BX)  : 1=ｶﾚﾝﾄﾍﾟｰｼﾞON,0=ｶﾚﾝﾄﾍﾟｰｼﾞOFF
; *********************************************************

ITEMPRN	PROC	NEAR
	MOV	AX,REG_AX
	CMP	AL,1		; マルチアイテム表示
	JE	ITEMPRN_OPEN
	CMP	AL,2		; マルチアイテム復帰
	JE	ITEMPRN_CLOSE
	CMP	AL,3		; マルチアイテム TYPE 5 位置
	JE	ITEMPRN_XY
	CMP	AL,4
	JE	ITEMPRN_CANCEL
	CMP	AL,5
	JE	ITEMPRN_FUNCTION
	CMP	AL,6
	JE	ITEMPRN_PAGE_CURRENT
	RET
ITEMPRN_OPEN:
	MOV	DX,REG_BX		; registar value BX.
	CALLE	WIDMULT3OPEN		; WINDOWS/マルチアイテム表示
	RET
ITEMPRN_CLOSE:
	CALLE	WIDMULT3CLOSE		; WINDOWS/マルチアイテム復帰
	RET
ITEMPRN_XY:
	MOV	AX,REG_BX		; Ｘ座標
	MOV	BX,REG_CX		; Ｙ座標
	CALLE	WIDMULTTP5XY		; WINDOWS/マルチアイテム TYPE 5 位置
	RET
ITEMPRN_CANCEL:
	MOV	AX,REG_BX		; flag キャンセルウインドウ
	CALLE	WIDMULTCANONOFF		; WINDOWS/マルチアイテムｷｬﾝｾﾙON/OFF
	RET
ITEMPRN_FUNCTION:
	MOV	AX,REG_BX		;
	CALLE	WIDMULTFNCONOFF		; WINDOWS/マルチアイテムﾌｧﾝｸｼｮﾝON/OFF
	RET
ITEMPRN_PAGE_CURRENT:
	MOV	AX,REG_BX		;
	CALLE	WIDMULTCURONOFF		; WINDOWS/マルチアイテムｶﾚﾝﾄﾍﾟｰｼﾞON/OFF
	RET
ITEMPRN	ENDP


; *********************************************************
;	ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ OPEN    : GR_OPEN
; *********************************************************

GR_OPEN	PROC	NEAR
	CALLE	WIDGRAPOPEN		; WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ OPEN
	RET
GR_OPEN	ENDP


; *********************************************************
;	ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ CLOSE   : GR_CLOSE
; *********************************************************

GR_CLOSE	PROC	NEAR
	CALLE	WIDGRAPCLOSE		; WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ CLOSE
	RET
GR_CLOSE	ENDP


; *********************************************************
;	ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ function: GR_F(function)
;	-i- function : 機能
;
;	GR_F(1,savebank)   : ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ OPEN
;	-i- savebank  (BX) : 背景退避用パーツバンク番号
;	    VVVRAM_TOP+22000 : #2  34,530byte
;	    VVVRAM_TOP+22000 : #9  43,532byte
;	GR_F(2,"filename") : フェイス
;	-i- "filename"(SI) : file name.
;	    IGRP_X         : グラフＸ
;	    IGRP_Y         : グラフＹ
;	GR_F(3,"name")     : 名前
;	-i- "name"(SI)     : 名前
;	    IGRP_X         : グラフＸ
;	    IGRP_Y         : グラフＹ
;	GR_F(4,face)       : 娘フェイス
;	-i- face (BX)      : 0=普通 1=嬉しい 2=怒り ...
;	    IGRP_X         : グラフＸ
;	    IGRP_Y         : グラフＹ
;	GR_F(5,win_type,handle) : ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ･ﾌﾚｰﾑ無し
;	-i- win_type (BX)  : ウインドウタイプ
;	    handle   (CX)  : ハンドル番号
;	    IGRP_TBL1[]    : グラフテーブル／名前
;	    IGRP_TBL2[]    : グラフテーブル／タイプ
;	    IGRP_TBL3[]    : グラフテーブル／パラメータ値
;	    IGRP_CNT       : グラフテーブル数
;	    IGRP_X         : グラフＸ
;	    IGRP_Y         : グラフＹ
;	GR_F(6,"name")     : 名前
;	-i- "name"(SI)     : 名前
;	    IGRP_X         : グラフＸ
;	    IGRP_Y         : グラフＹ
; *********************************************************

GR_F	PROC	NEAR
	MOV	AX,REG_AX		; マルチアイテム表示
	CMP	AL,1
	JE	GR_F_01F
	CMP	AL,2
	JE	GR_F_02F
	CMP	AL,3
	JE	GR_F_03F
	CMP	AL,4
	JE	GR_F_04F
	CMP	AL,5
	JE	GR_F_05F
	CMP	AL,6
	JE	GR_F_06F
	RET
GR_F_01F:
	MOV	DX,REG_BX		; 背景退避用パーツバンク番号
	CALLE	WIDGRAPOPEN2		; WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ OPEN2
	RET
GR_F_02F:
	MOV	SI,REG_SI		; file name.
	CALLE	WIDGR_FACE		; WINDOWS/ﾊﾟﾗﾒｰﾀ・フェイス
	RET
GR_F_03F:
	MOV	SI,REG_SI		; file name.
	CALLE	WIDGR_NAME		; WINDOWS/ﾊﾟﾗﾒｰﾀ・名前
	RET
GR_F_04F:
	MOV	DX,REG_BX		; girl face.
	CALLE	WIDGR_FGIRL		; WINDOWS/ﾊﾟﾗﾒｰﾀ・娘フェイス
	RET
GR_F_05F:
	MOV	DX,REG_BX		; ウインドウタイプ
	MOV	CX,REG_CX		; ハンドル番号
	CALLE	WIDGRAP_NOFRM		; WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ･ﾌﾚｰﾑ無し
	RET
GR_F_06F:
	MOV	SI,REG_SI		; file name.
	CALLE	WIDGR_NAME_NOFRM	; WINDOWS/ﾊﾟﾗﾒｰﾀ・名前･ﾌﾚｰﾑ無し
	RET
GR_F	ENDP


; *********************************************************
;	ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ         : GRPOPEN(win_type,handle)
;	-i- win_type (AX): ウインドウタイプ
;	    handle   (BX): ハンドル番号
;	    IGRP_TBL1[]  : グラフテーブル／名前
;	    IGRP_TBL2[]  : グラフテーブル／タイプ
;	    IGRP_TBL3[]  : グラフテーブル／パラメータ値
;	    IGRP_CNT     : グラフテーブル数
;	    IGRP_X       : グラフＸ
;	    IGRP_Y       : グラフＹ
; *********************************************************

GRPOPEN	PROC	NEAR
	MOV	DX,REG_AX		; registar value AX.
	MOV	CX,REG_BX		; registar value BX.
	CALLE	WIDGRAP			; WINDOWS/パラメータ・ウインドウ
	RET
GRPOPEN	ENDP


; *********************************************************
;	ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ 更新    : GRPUPD(handle,rec,dat)
;	-i- handle  (AX): ハンドル番号
;	    rec     (BX): パラメータ通し番号
;	    dat     (CX): パラメータ値
; *********************************************************

GRPUPD	PROC	NEAR
	MOV	CX,REG_AX		; registar value AX.
	MOV	AX,REG_BX		; registar value BX.
	MOV	DX,REG_CX		; registar value CX.
	CALLE	WIDGRAP_UPD		; WINDOWS/パラメータ・更新
	RET
GRPUPD	ENDP


; *********************************************************
;	ﾊﾟﾗﾒｰﾀ 所持金ｳｲﾝﾄﾞｳ   : GOLDOPEN(win_type,handle)
;	-i- win_type (AX): ウインドウタイプ
;	    handle   (BX): ハンドル番号
;	    IGRP_TBL1[]  : グラフテーブル／名前
;	    IGRP_TBL3[]  : グラフテーブル／パラメータ値
;	    IGRP_CNT     : グラフテーブル数
;	    IGRP_X       : グラフＸ
;	    IGRP_Y       : グラフＹ
; *********************************************************

GOLDOPEN	PROC	NEAR
	MOV	DX,REG_AX		; registar value AX.
	MOV	CX,REG_BX		; registar value BX.
	CALLE	WIDGRGOLD		; WINDOWS/ﾊﾟﾗﾒｰﾀ 所持金ｳｲﾝﾄﾞｳ
	RET
GOLDOPEN	ENDP


; *********************************************************
;	ﾊﾟﾗﾒｰﾀ 所持金 更新    : GOLDUPD(handle)
;	-i- handle  (AX): ハンドル番号
;	    rec     (BX): パラメータ通し番号
;	    dat     (CX): パラメータ値
; *********************************************************

GOLDUPD	PROC	NEAR
	MOV	CX,REG_AX		; registar value AX.
	MOV	AX,REG_BX		; registar value BX.
	MOV	DX,REG_CX		; registar value CX.
	CALLE	WIDGRGOLD_UPD		; WINDOWS/ﾊﾟﾗﾒｰﾀ 所持金・更新
	RET
GOLDUPD	ENDP


; *********************************************************
;	プロフィール･ｳｲﾝﾄﾞｳ	: PROFILE(win_type,handle)
;	-i- win_type (AX):ウインドウタイプ
;	    handle   (BX): ハンドル番号
;	    IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : グラフテーブル／表示文字列
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; *********************************************************

PROFILE	PROC	NEAR
	MOV	DX,REG_AX		; registar value AX.
	MOV	CX,REG_BX		; registar value BX.
	CALLE	WIDGRPROFILE		; WINDOWS/ﾊﾟﾗﾒｰﾀ・プロフィール
	RET
PROFILE	ENDP


; *********************************************************
;	ﾌﾟﾛﾎﾟｰｼｮﾝ･ｳｲﾝﾄﾞｳ      : PROPROPEN(win_type,handle)
;	-i- win_type (AX): ウインドウタイプ
;	    handle   (BX): ハンドル番号
;	    IGRP_TBL1[]  : グラフテーブル／名前
;	    IGRP_TBL2[]  : グラフテーブル／タイプ
;	    IGRP_TBL3[]  : グラフテーブル／パラメータ値
;	    IGRP_CNT     : グラフテーブル数
;	    IGRP_X       : グラフＸ
;	    IGRP_Y       : グラフＹ
; *********************************************************

PROPROPEN	PROC	NEAR
	MOV	DX,REG_AX		; registar value AX.
	MOV	CX,REG_BX		; registar value BX.
	CALLE	WIDGRPROPR		; WINDOWS/ﾊﾟﾗﾒｰﾀ・プロポーション
	RET
PROPROPEN	ENDP


; *********************************************************
;	ﾌﾟﾛﾎﾟｰｼｮﾝ･ｳｲﾝﾄﾞｳ 更新 : PROPRUPD(handle,rec,dat)
;	-i- handle  (AX): ハンドル番号
;	    rec     (BX): パラメータ通し番号
;	    dat     (CX): パラメータ値
; *********************************************************

PROPRUPD	PROC	NEAR
	MOV	CX,REG_AX		; registar value AX.
	MOV	AX,REG_BX		; registar value BX.
	MOV	DX,REG_CX		; registar value CX.
	CALLE	WIDGRPROPR_UPD		; WINDOWS/ﾊﾟﾗﾒｰﾀ・ﾌﾟﾛﾎﾟｰｼｮﾝ・更新
	RET
PROPRUPD	ENDP


; *********************************************************
;	通常ｽﾃｰﾀｽ･ｳｲﾝﾄﾞｳ      : STATUS(win_type,handle)
;	-i- win_type (AX): ウインドウタイプ
;	    handle   (BX): ハンドル番号
;	    IGRP_X       : グラフＸ
;	    IGRP_Y       : グラフＹ
;	    IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : パラメータ値
;		IGRP_TBL3[0] : 病気指数(%)
;		IGRP_TBL3[1] : 非行化指数(%)
;		IGRP_TBL3[2] : 人脈
;		IGRP_TBL3[3] : 1=病気
;		IGRP_TBL3[4] : 1=非行化
;		IGRP_TBL3[5] : 1=恋愛
; *********************************************************

STATUS	PROC	NEAR
	CALLE	WIDGR_STATUS		; WINDOWS/ﾊﾟﾗﾒｰﾀ・通常ステータス
	RET
STATUS	ENDP


; *********************************************************
;	長い名前ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ	: PROLONG(win_type,handle)
;	-i- win_type (AX):ウインドウタイプ
;	    handle   (BX): ハンドル番号
;	    IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : パラメータ値
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; *********************************************************

PROLONG	PROC	NEAR
	CALLE	WIDGRLONGNAME		; WINDOWS/ﾊﾟﾗﾒｰﾀ・長い名前ﾊﾟﾗﾒｰﾀ
	RET
PROLONG	ENDP


; *********************************************************
;	ICONﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ	: PRICON(win_type,handle)
;	-i- win_type (AX):ウインドウタイプ
;	    handle   (BX): ハンドル番号
;	    IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL2[] : グラフテーブル／ＩＣＯＮ番号
;	    IGRP_TBL3[] : グラフテーブル／内容
;	    IGRP_TBL4[] : グラフテーブル／項目名
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; *********************************************************

PRICON	PROC	NEAR
	CALLE	WIDGR_ARMS		; WINDOWS/ﾊﾟﾗﾒｰﾀ・武器と防具
	RET
PRICON	ENDP


; *********************************************************
;	カレンダー            : CLENDER(function)
;	-i- function : 機能
; CLENDER(1)			カレンダー・表示
; CLENDER(2)			カレンダー・再表示
; CLENDER(3)			カレンダー・更新処理
; CLENDER(4)			カレンダー・翌月の計算
;				-O- AX : 翌月の年
;				    BX : 翌月の月
;				    CX : 翌月の末日
;				    DX : 翌月の最初の曜日
; CLENDER(5,year,month,day)	カレンダー・年齢の計算 -O- DX : 年齢
; CLENDER(6,x,y)		カレンダー・セットアップ
; CLENDER(7)			カレンダー・月次処理
;				-O- BX :0=変化無し
;					1=体形の変化あり
;					2=重体->正常
;					3=正常->重体
;					4=顔の変化のみ
; CLENDER(8)			初期状態の整合処理
; CLENDER(9)			ﾊﾟﾗﾒｰﾀの整合処理
; CLENDER(10)			体形のチェック
; CLENDER(11)			カレンダー・今月の計算
;				-O- AX : 月末の日
;				    BX : 翌日の日付
;				    CX : 翌日の曜日
;				    DX : 0=通常,1=一番最初の日,2=運命の日
;					 3=一番最後の月,4=１月前,5=２月前
;					 6=３月前
; CLENDER(12)			１旬次処理
; CLENDER(13)			訓練技能値計算
; CLENDER(14)			パラメータ全クリア
;
; *********************************************************

CLENDER	PROC	NEAR
	MOV	AX,REG_AX		; registar value AX.
	CMP	AL,1			;
	JE	CLENDER_01F		;
	CMP	AL,2			;
	JE	CLENDER_02F		;
	CMP	AL,3			;
	JE	CLENDER_03F		;
	CMP	AL,4			;
	JE	CLENDER_04F		;
	CMP	AL,5			;
	JE	CLENDER_05F		;
	CMP	AL,6			;
	JE	CLENDER_06F		;
	CMP	AL,7			;
	JE	CLENDER_07F		;
	CMP	AL,8			;
	JE	CLENDER_08F		;
	CMP	AL,9			;
	JE	CLENDER_09F		;
	CMP	AL,10			;
	JE	CLENDER_10F		;
	CMP	AL,11			;
	JE	CLENDER_11F		;
	CMP	AL,12			;
	JE	CLENDER_12F		;
	CMP	AL,13			;
	JE	CLENDER_13F		;
	CMP	AL,14			;
	JE	CLENDER_14F		;
	RET				;
CLENDER_01F:
	CALLE	WIDCLEN_SET		; WINDOWS/カレンダー・表示
	RET
CLENDER_02F:
	CALLE	WIDCLEN_SHOW		; WINDOWS/カレンダー・再表示
	RET
CLENDER_03F:
	CALLE	WIDCLEN_UDATE		; WINDOWS/カレンダー・更新処理
	MOVX	BORTH_YEAR,	P_BORTHYEAR
	MOVX	BORTH_MONTH,	P_BORTHMONTH
	MOVX	BORTH_DAY,	P_BORTHDAY
	CALLE	WIDCLEN_AGE		; WINDOWS/カレンダー・年齢の計算
	MOV	P_NENREI,DX		; 年齢

	MOVX	BORTH_YEAR,	P_BORTHYEAR[2]
	MOVX	BORTH_MONTH,	P_BORTHMONTH[2]
	MOVX	BORTH_DAY,	P_BORTHDAY[2]
	CALLE	WIDCLEN_AGE		; WINDOWS/カレンダー・年齢の計算
	MOV	P_NENREI[2],DX		; 年齢

	CALLE	PCALC_DAYS		; 日次処理

	RET
CLENDER_04F:
	CALLE	WIDCLEN_NXT_E		; WINDOWS/カレンダー・翌月の計算
	MOV	AX,NEXT_M_YEAR		; 翌月の年
	MOV	BX,NEXT_M_MONTH		; 翌月の月
	MOV	CX,NEXT_M_ENDDAY	; 翌月の末日
	MOV	DX,NEXT_M_SWEEK		; 翌月の最初の曜日
	MOV	REG_AX,AX		; 翌月の年
	MOV	REG_BX,BX		; 翌月の月
	MOV	REG_CX,CX		; 翌月の末日
	MOV	REG_DX,DX		; 翌月の最初の曜日
	RET
CLENDER_05F:
	MOVX	BORTH_YEAR,REG_BX	; registar value BX.
	MOVX	BORTH_MONTH,REG_CX	; registar value CX.
	MOVX	BORTH_DAY,REG_DX	; registar value DX.
	CALLE	WIDCLEN_AGE		; WINDOWS/カレンダー・年齢の計算
	MOV	REG_DX,DX		; -O- DX : 年齢
	RET
CLENDER_06F:
	MOV	AX,REG_BX		; x.
	MOV	BX,REG_CX		; y.
	CALLE	WIDCLEN_SETUP		; WINDOWS/カレンダー・セットアップ
	RET
CLENDER_07F:
	CALL	CLENDER_07FSUB		;カレンダー・月次処理
	RET
CLENDER_08F:
	CALLE	WIDCLEN_SETUP_INI	; WINDOWS/カレンダー・初期ｾｯﾄｱｯﾌﾟ
	CALLE	PCALC_SRTDAT		; 初期状態の整合処理
	RET
CLENDER_09F:
	CALLE	PCALC_CHKDAT		; 整合処理
	RET
CLENDER_10F:
	CALLE	PCALC_CHK_BODY		; 体形のチェック
	RET
CLENDER_11F:
	CALLE	WIDCLEN_NOW_E		; WINDOWS/カレンダー・今月の計算
	MOV	REG_AX,AX		; 月末の日
	MOV	REG_BX,BX		; 翌日の日付
	MOV	REG_CX,CX		; 翌日の曜日
	MOV	REG_DX,DX		; 0=通常,1=一番最初の日,2=運命の日...
	RET
CLENDER_12F:
	CALLE	PCALC_10DAYS		; １旬処理
	RET
CLENDER_13F:
	CALLE	PCALC_V_UPER		; 訓練技能値計算
	RET
CLENDER_14F:
	CALLE	PARA_CLEAR		; parameter clear.
	RET
CLENDER	ENDP


; *********************************************************
;	カレンダー・月次処理
; *********************************************************

CLENDER_07FSUB	PROC	NEAR
	MOVX	BAK_GIRL_BODY,GIRL_BODY		; 体形 1=細,2=太
	MOVX	BAK_GIRL_FACE,GIRL_FACE		; 表情 1=基本,2=非行...
	MOVX	BAK_GIRL_DAMEG,GIRL_DAMEG	; 重病 0=normal,1=重病

	CALLE	PCALC_M_BORN			; 月次成長処理

	CMPX	BAK_GIRL_DAMEG,GIRL_DAMEG	; 重病 0=normal,1=重病
	JNE	CLENDER_07F_6			;

	CMP	GIRL_DAMEG,1			; 重病 0=normal,1=重病
	JE	CLENDER_07F_4			;

	CMPX	BAK_GIRL_BODY,GIRL_BODY		; 体形 1=細,2=太
	JNE	CLENDER_07F_5			;

	CMPX	BAK_GIRL_FACE,GIRL_FACE		; 表情 1=基本,2=非行...
	JNE	CLENDER_07F_8			;

CLENDER_07F_4:					;
	MOV	REG_BX,0			; 0=変化無し
	RET					;
CLENDER_07F_5:					;
	MOV	REG_BX,1			; 1=体形の変化あり
	RET					;
CLENDER_07F_6:					;
	CMP	GIRL_DAMEG,1			; 重病 0=normal,1=重病
	JE	CLENDER_07F_7			;
	MOV	REG_BX,2			; 2=重体->正常
	RET					;
CLENDER_07F_7:					;
	MOV	REG_BX,3			; 3=正常->重体
	RET					;
CLENDER_07F_8:					;
	MOV	REG_BX,4			; 4=顔の変化のみ
	RET
CLENDER_07FSUB	ENDP


; *********************************************************
;	乱数		: RANDAM(max)
;	-i- max   (AX) : 最大値(1-200)
;	-O- AX  : １からＡＸの数字
;	    IRND: １からＡＸの数字
; *********************************************************

IRANDAM	PROC	NEAR
	MOV	AX,REG_AX		; 範囲（２００以内）
	CALLE	RANDAM			; 乱数範囲指定
	MOV	REG_AX,AX		; １からＡＸの数字
	RET
IRANDAM	ENDP


; *********************************************************
;	範囲乱数	: IRAND2(base,max)
;	-i- base  (AX) : 開始値(1-200)
;	    max   (BX) : 最大値(1-200)
;	-O- AX  : ＡＸからＢＸの数字
; *********************************************************

IRAND2	PROC	NEAR
	MOV	AX,REG_BX		;
	SUB	AX,REG_AX		;
	INC	AX			; 範囲（２００以内）
	CALLE	RANDAM			; 乱数範囲指定
	DEC	AX			;
	ADD	REG_AX,AX		;
	RET
IRAND2	ENDP


; *********************************************************
;	乱数９９９範囲指定	: IRAND999X(max)
;	-i- max   (AX) : 最大値(0-999)
;	-O- AX  : ０からＡＸの数字
;	    IRND: ０からＡＸの数字
; *********************************************************

IRAND999X	PROC	NEAR
	MOV	AX,REG_AX		; 範囲（９９９以内）
	CALLE	RAND999X		; 乱数９９９範囲指定
	MOV	REG_AX,AX		; ０からＡＸの数字
	RET
IRAND999X	ENDP


; *********************************************************
;	+-%の乱数	: IRNDPAR(value,parcent)
;	-i- value   (AX) : value.
;	    parcent (BX) : +-%parcent.
; *********************************************************

IRNDPAR	PROC	NEAR
	MOV	BX,REG_BX		;
	SHL	BX,1			; 30%*2 = 60%
	MOV	AX,REG_AX		; value * 60% = AX
	MUL	BX			;
	MOV	BX,100			;
	DIV	BX			;
	PUSH	AX			; randam(value60%)

	CALLE	RAND999X		; 乱数９９９範囲指定

	POP	BX			;
	SHR	BX,1			; / 2
	SUB	AX,BX			; AX = randam - value30%
	ADD	REG_AX,AX		; value.

	CMP	REG_AX,0		; value.
	JGE	IRNDPAR_9		;
	MOV	REG_AX,0		; value.
IRNDPAR_9:
	RET
IRNDPAR	ENDP


; *********************************************************
;	タイマー１	: TIMER1(timer60)
;	-i- timer60 : 1/60秒タイマー
; *********************************************************

TIMER1	PROC	NEAR
	MOV	AX,REG_AX		;
	CALLE	TMVST2			; V-SYNC timer2 set.
	RET
TIMER1	ENDP


; *********************************************************
;	タイマー２	: TIMER2(timer60)
;	-i- timer60 : 1/60秒タイマー
; *********************************************************

TIMER2	PROC	NEAR
	MOV	AX,REG_AX		;
	CALLE	TMVST3			; V-SYNC timer3 set.
	RET
TIMER2	ENDP


; *********************************************************
;	タイマー待ち１	: WAIT1
; *********************************************************

WAIT1	PROC	NEAR
WAIT1_LOOP:
	CALLE	TMVCK2			; V-SYNC timer2 check.
	CMP	AX,0			; 0=timer now, 1=timer end.
	JE	WAIT1_LOOP		;
	RET
WAIT1	ENDP


; *********************************************************
;	タイマー待ち２	: WAIT2
; *********************************************************

WAIT2	PROC	NEAR
WAIT2_LOOP:
	CALLE	TMVCK3			; V-SYNC timer3 check.
	CMP	AX,0			; 0=timer now, 1=timer end.
	JE	WAIT2_LOOP		;
	RET
WAIT2	ENDP


; *********************************************************
;	タイマーチェック２ : TMCHK2
;	-o- DX : タイマー値
; *********************************************************

TMCHK2	PROC	NEAR
	CALLE	TMVCK3			; V-SYNC timer3 check.
	MOV	REG_DX,DX		;
	RET
TMCHK2	ENDP


; *********************************************************
;	ユーザ待ち	: WAITU
; *********************************************************

WAITU	PROC	NEAR
	CALLE	USERWAIT		; user wait.
	RET
WAITU	ENDP


; *********************************************************
;	数値を文字列化	: VALSTR(num)
;	-i- num (AX) : 数値
;	-o- SI       : 文字列
; *********************************************************

VALSTR	PROC	NEAR
	MOV	DX,REG_AX		;
	CALL	DECSTR			; val DX to dec string.
	CALL	STRZTS			; zero to space. "00123" - > "  123"
	CALL	STRSPL			; space pless. "  123" - > "123  "
	MOV	REG_SI,SI		; registar value SI.
	RET
VALSTR	ENDP


; *********************************************************
;	誕生日を文字列化 : BORTHDAYSTR(year,month,day)
;	-i- year  (AX): 年
;	    month (BX): 月
;	    day   (CX): 日
;	-o- SI        : 文字列
; *********************************************************

BORTHDAYSTR	PROC	NEAR
	MOV	AX,REG_AX		; 年
	MOV	BX,REG_BX		; 月
	MOV	CX,REG_CX		; 日
	CALLE	UNIT_DATE_VAL_TO_STR	; 数値から日付文字列へ
	MOV	REG_SI,OFFSET STR_BUFF	; 時間 DB "1880/10/16"
	RET
BORTHDAYSTR	ENDP


; *********************************************************
;	アイテム削除   : ITEM_KILL(rec)
;	-i- rec   (AX) : 削除アイテム番号
; *********************************************************

ITEM_KILL	PROC	NEAR
	MOV	DX,REG_AX		;
	CALLE	PARA_ITEM_KILL		; アイテム削除
	RET
ITEM_KILL	ENDP


; *********************************************************
;	アイテム登録   : ITEM_INST(f,icon,gold,attr,name,prog,help)
;	-i- f    (AX) : finction 1=normal.
;	    icon (BX) : ＩＣＯＮ
;	    gold (CX) : 値段
;	    attr (DX) : 種別
;	    name (SI) : 名前 string
;	    prog (DI) : 効果 string
;	    help (BP) : 説明 string
;	-o- AX : 0=normal,1=table over.
; *********************************************************

ITEM_INST	PROC	NEAR
	MOV	AX,REG_AX		;
	MOV	BX,REG_BX		;
	MOV	CX,REG_CX		;
	MOV	DX,REG_DX		;
	MOV	SI,REG_SI		;
	MOV	DI,REG_DI		;
	MOV	BP,REG_BP		;
	CALLE	PARA_ITEM_INST		; アイテム登録
	MOV	REG_AX,AX		;
	RET
ITEM_INST	ENDP


; *********************************************************
;	アイテム検索  : ITEM_SRCH(function)
;	-i- function   (AX) :
;
;	ITEM_SRCH(1,ICONnumber) :ICON search.
;	-i- ICONnumber (BX) : ICON number.
;	-o- AX : 0=none,1=search.
;	    DX : item record.
;
;	ITEM_SRCH(2) :ICON next search.
;	-o- AX : 0=none,1=search.
;	    DX : item record.
;
;	ITEM_SRCH(3,rec) :attribute get.
;	-i- rec   (BX) : item record.
;	-o- AX : item attribute 0=normal,1=equip,2=arms,3=dress,4=up_param
;	    DX : item equipment.0=normal,1=now equip
;
;	ITEM_SRCH(4,rec) :equip set.
;	-i- rec   (BX) : item record.
;
;	ITEM_SRCH(5,attr) : equip clear.
;	-i- attr  (AX) : item attribute 0=normal,1=equip,2=arms,3=dress
;			4=up_param
;
;	ITEM_SRCH(6,rec) : equipment chenge.(equip,arms,dress)
;	-i- rec   (BX) : item record.
;
; *********************************************************

ITEM_SRCH	PROC	NEAR
	MOV	AX,REG_AX		; function.
	MOV	BX,REG_BX		; ICON number.

	CALLE	PARA_ITEM_SRCH		; アイテム検索

	MOV	REG_AX,AX		; 0=none,1=search.
	MOV	REG_DX,DX		; item record.
	RET
ITEM_SRCH	ENDP


; *********************************************************
;	ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ OPEN	: SCHD_OPEN(day,week,end_day,month,year)
;	-i- day     (AX) : 開始日付
;	    week    (BX) : 開始曜日
;	    end_day (CX) : 終了日付
;	    month   (DX) : 月
;	    year    (SI) : 年
; *********************************************************

SCHD_OPEN	PROC	NEAR
	MOV	AX,REG_AX		; 開始日付
	MOV	BX,REG_BX		; 開始曜日
	MOV	CX,REG_CX		; 終了日付
	MOV	DX,REG_DX		; 月
	MOV	SI,REG_SI		; 年
	CALLE	WIDSCHD_OPEN		; WINDOWS/ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ OPEN
	RET
SCHD_OPEN	ENDP


; *********************************************************
;	ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ CLOSE	: SCHD_CLOSE
; *********************************************************

SCHD_CLOSE	PROC	NEAR
	CALLE	WIDSCHD_CLOSE		; WINDOWS/ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ CLOSE
	RET
SCHD_CLOSE	ENDP


; *********************************************************
;	ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ SET ICON	: SCHD_ICON(s_day,e_day,icon)
;	-i- s_day (AX) : 開始日付
;	    e_day (BX) : 終了日付
;	    icon  (CX) : ＩＣＯＮ番号
; *********************************************************

SCHD_ICON	PROC	NEAR
	MOV	AX,REG_AX		; 開始日付
	MOV	BX,REG_BX		; 終了日付
	MOV	CX,REG_CX		; ＩＣＯＮ番号
	CALLE	WIDSCHD_SET_ICON	; WINDOWS/ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ SET ICON
	RET
SCHD_ICON	ENDP


; *********************************************************
;	パレットセット	: PALET_SET(rec)
;	-i- rec  (AX) : record number.
; *********************************************************

PALET_SET	PROC	NEAR
	MOV	AX,REG_AX
	CALLE	PT_PALET_SET		; パレットセット
	RET
PALET_SET	ENDP


; *********************************************************
;	パレットテーブルセットのみ : PALET_SETONLY(rec,num)
;	-i- rec  (AX) : record number.
;	    num  (BX) : table number.
; *********************************************************

PALET_SETONLY	PROC	NEAR
	MOV	AX,REG_AX
	MOV	BX,REG_BX
	CALLE	PT_PALET_SETONLY	; パレットテーブルセットのみ
	RET
PALET_SETONLY	ENDP


; *********************************************************
;	全画面枠
;	-i- function (AX) :
;		1=娘の部屋
;		2=武者修行
;		3=「王国芸術祭」
;		4=「ダンスパーティー」
;		5=「お料理コンクール」
;		6=「武闘会」
;		7=「バカンス」
;		50=RPG用HPMP
;		100=現在表示中の枠番号
;		-o- AX : 現在表示中の枠番号
; *********************************************************

WWFRAME	PROC	NEAR
	MOV	BX,REG_AX
	CALLE	WID_FULL_FREAM		; WINDOWS/全画面枠

	CMP	REG_AX,100		; 100=現在表示中の枠番号
	JNE	WWFRAME_5		;
	MOV	REG_AX,AX		; 現在表示中の枠番号
WWFRAME_5:
	RET
WWFRAME	ENDP


; *********************************************************
;	武者修行	: WWMUSYA(function)
;	-i- function (AX) :
;
;	WWMUSYA(1,maptype,mapx,mapy,girlx,girly,banksw) : start.
;	    maptype     (BX):1=East,2=West,3=South,4=North1,5=North2,6=North3
;	    mapx,mapy   (CX)(DX):map location.
;	    girlx,girly (SI)(DI):girl location.
;	    banksw      (BP)    : load bank bit switch.
;			bit0:bank0, bit1:bank1, bit2:bank2....
;
;	WWMUSYA(2,timerday,timernight)    : interval.
;	    timerday  (BX) : 昼・経過時間
;	    timernight(CX) : 夜・経過時間
;
;	WWMUSYA(3,daylight) : normal walk.
;	    daylight (BX) : 1=昼,2=夜,3=昼->夜,4=夜->昼,5=前回の継続
;			6=ﾊﾟﾚｯﾄ割込みOFF(西マップ)
;			7=ﾊﾟﾚｯﾄ割込みON(西マップ)
;	-o- AX : status.0=normal,1=place ivent,2=timeout,3=camp,4=event50.
;	    BX : map locate x.
;	    CX : map locate y.
;	    DX : 娘の向き 0=front,1=back,2=left,3=right.
;	    SI : grand level.
;	    DI : orginal dir x.
;	    BP : orginal dir y.
;
;	WWMUSYA(4,effect) : effect.
;	    effect   (CX) : 1=穴へ,2=穴から,3=沼へ,4=沼から
;			    5=キャンプ,6=キャンプたたむ,7=滝
;			    8=上へ,9=下へ,10=上から,11=下から,12=落下
;			    13=左へ,14=右へ
;
;	WWMUSYA(5,x,y,gx,gy,flag) : map relocate. 
;	    x    (BX) : map location x.
;	    y    (CX) : map location y.
;	    gx   (DX) : girl location x.
;	    gy   (SI) : girl location y.
;	    flag (DI) : 1=全部,2=背景のみ
;
;	WWMUSYA(6)	: ＲＰＧモード
;
;	WWMUSYA(7)	: ノーマルモード
;
;	WWMUSYA(8,flag)	: 再描画
;	    flag (BX) : 1=全部,2=背景のみ
;
;	WWMUSYA(9)	: 戦闘後データロード
;
;	WWMUSYA(10,direction,banksw) : マップ再ロード
;	    direction (BX) : map type.
;		1=East,2=West,3=South,4=North1,5=North2,6=North3.
;	    banksw    (CX) : load bank bit switch.
;		bit0:bank0, bit1:bank1, bit2:bank2....
;
;	WWMUSYA(11,len) : 滝長さ
;	    len    (BX) : 滝長さ
;
;	WWMUSYA(12,dir) : 娘の向き設定
;	    dir    (BX) : 0=front.1=back,2=left,3=right.
;
;	WWMUSYA(13,mapx,mapy,girlx,girly,count) : マップシフト
;	    mapx   (BX) : map shift x.
;	    mapy   (CX) : map shift y.
;	    girlx  (DX) : girl shift x.
;	    girly  (SI) : girl shift y.
;	    count  (DI) : shift count.
;
;	WWMUSYA(14,flag) : キャンプ
;	    flag   (BX) : 1=キャンプ張る,2=キャンプをたたむ
;
;	WWMUSYA(15,"str1,str2,str3",flag) : セレクト
;	    "str1,str2,str3" (SI) : セレクト単語列
;	    flag   (BX) : セレクトアニメON/OFF
;	-o- BX : select number.
;
;	WWMUSYA(16) : キャンプ後ロード
;
;	WWMUSYA(17) : ステータス
;	-o-  AX : map type.1=East,2=West,3=South,4=North1,5=North2,6=North3.
;	     BX : map locate x.
;	     CX : map locate y.
;
;	WWMUSYA(18,daylight) : 昼<->夜操作
;	-i- daylight  (BX) : 1=day,2=night,3=day->night,4=night->day.
;
;	WWMUSYA(19,function) : マップの修正
;	-i- function (BX) :
;			1=西の泉が枯れた
;			2=北の守護星現れる
;			3=北の守護星への階段が消える
;			4=北の武神への階段が消える
;			5=宝箱OPEN.1
;			6=宝箱OPEN.2
;			7=宝箱OPEN.3
;			8=宝箱OPEN.4
;			9=宝箱OPEN.5
;			10=宝箱CLOSE.1
;			11=宝箱CLOSE.2
;			12=宝箱CLOSE.3
;			13=宝箱CLOSE.4
;			14=宝箱CLOSE.5
;
;	WWMUSYA(20,function) : 守護星のセット
;	-i- function (BX) : 守護星
;
;	WWMUSYA(21)          : マップデータのみ再ロード
;	WWMUSYA(22)          : 全モードクリア
;	WWMUSYA(23)          : 残り時間
;	-o- BX : 残り時間
;	WWMUSYA(24)          : 残りクリア
;
; *********************************************************

WWMUSYA	PROC	NEAR
	MOV	AX,REG_AX
	MOV	BX,REG_BX
	MOV	CX,REG_CX
	MOV	DX,REG_DX
	MOV	SI,REG_SI
	MOV	DI,REG_DI
	MOV	BP,REG_BP

	CALLE	WIDMUSYA	; WINDOWS/武者修行
	MOV	REG_AX,AX	; status. 1=place ivent,2=timeout,3=camp.
	MOV	REG_BX,BX	; map locate x.
	MOV	REG_CX,CX	; map locate y.
	MOV	REG_DX,DX	; 娘の向き 0=front,1=back,2=left,3=right.
	MOV	REG_SI,SI	; grand level.
	MOV	REG_DI,DI	; orginal dir x.
	MOV	REG_BP,BP	; orginal dir y.
	RET
WWMUSYA	ENDP


; *********************************************************
;	娘		: WWGIRL(function)
;	-i- function (AX) :
;
;	WWGIRL(1,age,body,face,breast,dress,dameg) : direct put.
;		age	(BX):年齢
;		body	(CX):体形　1=細,2=太
;		face	(DX):表情　1=基本,2=非行,3=病気,4=元気,5=色気
;		breast	(SI):胸大　0=無,1=有
;		dress	(DI):服  0=裸
;		dameg	(BP):重病　0=normal,1=重病
;
;	WWGIRL(2)	: girl put.
;	WWGIRL(3)	: girl quick put.
;	WWGIRL(4)	: girl clear.
;	WWGIRL(5)	: girl quick clear.
;	WWGIRL(6)	: now show girl age.
;	WWGIRL(7)	: girl normal<->dameg put.
;	WWGIRL(8)	; girl face put.
;	-o- AX : 表示中の年齢
;
; *********************************************************

WWGIRL	PROC	NEAR
	MOV	AX,REG_AX
	CMP	AL,1
	JE	WWGIRL_1F
	CMP	AL,2
	JE	WWGIRL_2F
	CMP	AL,3
	JE	WWGIRL_3F
	CMP	AL,4
	JE	WWGIRL_4F
	CMP	AL,5
	JE	WWGIRL_5F
	CMP	AL,6
	JE	WWGIRL_6F
	CMP	AL,7
	JE	WWGIRL_7F
	CMP	AL,8
	JE	WWGIRL_8F

WWGIRL_1F:
	MOV	AX,1			; girl put mode.0=normal,1=o.l.
	CALLE	WID_GIRL_PMODE		; WINDOWS/娘 girl put mode.
	MOV	AX,REG_BX		; 年齢
	MOV	BX,REG_CX		; 体形　1=細,2=太
	MOV	CX,REG_DX		; 表情　1=基本,2=非行,3=病気...
	MOV	DX,REG_SI		; 胸大　0=無,1=有
	MOV	SI,REG_DI		; 服  0=裸
	MOV	DI,REG_BP		; 重病　0=normal,1=重病
	CALLE	WID_GIRL_DIRECT		; WINDOWS/娘 direct put.
	RET
WWGIRL_2F:
	MOV	AX,1			; girl put mode.0=normal,1=o.l.
	CALLE	WID_GIRL_PMODE		; WINDOWS/娘 girl put mode.
	CALLE	WID_GIRL_DRAW		; WINDOWS/娘 girl put.
	RET
WWGIRL_3F:
	MOV	AX,0			; girl put mode.0=normal,1=o.l.
	CALLE	WID_GIRL_PMODE		; WINDOWS/娘 girl put mode.
	CALLE	WID_GIRL_DRAW		; WINDOWS/娘 girl put.
	RET
WWGIRL_4F:
	MOV	AX,1			; girl put mode.0=normal,1=o.l.
	CALLE	WID_GIRL_PMODE		; WINDOWS/娘 girl put mode.
	CALLE	WID_GIRL_WALL		; WINDOWS/娘 girl back wall.
	RET
WWGIRL_5F:
	MOV	AX,0			; girl put mode.0=normal,1=o.l.
	CALLE	WID_GIRL_PMODE		; WINDOWS/娘 girl put mode.
	CALLE	WID_GIRL_WALL		; WINDOWS/娘 girl back wall.
	RET
WWGIRL_6F:
	CALLE	PT_NOW_GIRL_BODY	; now girl body.
	MOV	REG_AX,DX		; girl show body age.
	RET
WWGIRL_7F:
	CALLE	WID_GIRL_SMOOTH		; WINDOWS/娘 girl normal<->dameg put.
	RET
WWGIRL_8F:
	MOV	AX,0			; girl put mode.0=normal,1=o.l.
	CALLE	WID_GIRL_PMODE		; WINDOWS/娘 girl put mode.
	CALLE	WID_GIRL_DRAW_FCONLY	; WINDOWS/娘 girl face put.
	RET
WWGIRL	ENDP


; *********************************************************
;	アニメ・ウインドウ	: WWANIME(function)
;	-I- function  (AX) :
;
;	WWANIME(1,animetype)		: anime window open.
;	WWANIME(2,animetype)		: anime window close.
;	WWANIME(3,animetype,"filename")	: pictuer load.
;	WWANIME(4,animetype)		: put BG.
;	WWANIME(5,animetype)		: pictuer copy vvram -> CRT.
;	WWANIME(6,animetype,"filename")	: anime pattern add load.
;	WWANIME(7,animetype,x,y,n)	: anime pattern put vvram.
;	WWANIME(8,animetype)		: restore vram ARA002 -> bank#6 move.
;	WWANIME(9,animetype)		: anime window close.(to bank#6)
;	WWANIME(10,animetype,x,y,sizex,sizey):anime window size set.高速化の為
;	WWANIME(11,animetype,"filename",bank): (bank)pictuer load.
;	WWANIME(12,animetype,"filename",bank): (bank)anime pattern add load.
;	WWANIME(13,animetype,bank,x,y,n)     : (bank)anime pattern put vvram.
;	WWANIME(14,animetype)		: anime window open.(no frame open)
;	WWANIME(15,animetype,x1,y1,x2,y2,sizex,sizey)  : anime window copy.
;	WWANIME(16,animetype,x,y)	: anime window open.(location/no save)
;	WWANIME(17,animetype,bank,x,y,n):(bank)anime ptn ofset maskput vvram.
;
;	animetype : anime window type. 0=small,1=large
;	n         : pattern number.
;
; *********************************************************

WWANIME	PROC	NEAR
	MOV	AX,REG_AX
	MOV	BX,REG_BX
	MOV	CX,REG_CX
	MOV	DX,REG_DX
	MOV	SI,REG_SI
	MOV	DI,REG_DI
	MOV	BP,REG_BP
	MOV	ES,REG_ES
	CALLE	WIDANIME		; WINDOWS/アニメ・ウインドウ
	RET
WWANIME	ENDP


; *********************************************************
;	イベント・ウインドウ	: WWIVENT(function)
;	-I- function  (AX) :
;
;	WWIVENT(1,iventtype,"filename")	: ivent window open.
;	WWIVENT(2,iventtype)		: ivent window close.
;	WWIVENT(3,iventtype,"filename")	: ivent window open(no save)
;	WWIVENT(4,iventtype)		: ivent window close(diskload)
;	WWIVENT(5,iventtype,x,y)	: ivent window locate.
;	WWIVENT(6,iventtype,bank,lbank,"filename")
;					: ivent window open.(select bank)
;	WWIVENT(7,iventtype,bank)	: ivent window close.(select bank)
;	bank : save bank number.
;	lbank: diskload bank number.
;	iventtype : ivent window type. 0=small,1=large
;
; *********************************************************

WWIVENT	PROC	NEAR
	MOV	AX,REG_AX
	MOV	BX,REG_BX
	MOV	CX,REG_CX
	MOV	DX,REG_DX
	MOV	SI,REG_SI
	CALLE	WIDIVENT		 ; WINDOWS/イベント・ウインドウ
	RET
WWIVENT	ENDP


; *********************************************************
;	ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ	: WWPROF(function)
;	-I- function  (AX) :
;
;	WWPROF(1) : ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ・表示
;	WWPROF(2) : ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ・再表示
;	WWPROF(3) : ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ・所持金
;	WWPROF(4) : ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ・年齢
;	WWPROF(5) : ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ・RPG･所持金
;	WWPROF(6) : ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ・RPG･HP
;	WWPROF(7) : ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ・RPG･MP
;	WWPROF(8) : ﾌﾟﾛﾌｨｰﾙ･ｳｲﾝﾄﾞｳ・RPG･装備
;
; *********************************************************

WWPROF	PROC	NEAR
	MOV	BX,REG_AX			;
	DEC	BX
	CMP	BX,(JMP_MUSIC_END-JMP_MUSIC)/2	; jump table.
	JNB	WWPROF_EXIT			;
	SHL	BX,1				; word pointer.
	CALL	WORD PTR DS:JMP_PROF[BX]	; jump table.
WWPROF_EXIT:
	RET
WWPROF	ENDP


; *********************************************************
;	トーナメント表	: WWTOUR(function)
;	-I- AX : function.
;
;	WWTOUR(1)		     : トーナメント表スタート
;	WWTOUR(2,game,link,state)    : エレメント・テスト
;	-i- game  (BX) : 第何試合か？(1-4)
;	    link  (CX) : 組み合せ番号(1-8)
;	    state (DX) : 状態 1=甲の勝ち,2=乙の勝ち,3=試合開始
;	WWTOUR(3,entrynum,entryname) : エントリィ名前表示
;	-i- entrynum  (BX) : エントリィ番号
;	    entryname (CX) : エントリィ名前
;	WWTOUR(4,entrynum,charanum) : トーナメント・エントリィ登録
;	-i- entrynum  (BX) : エントリィ番号(表の左上から1,2,3...)
;	    charanum  (CX) : キャラクタ番号
;	WWTOUR(5,game) : トーナメント試合・キックオフ
;	-i- game  (BX) : 第何試合か？
;	-o- AX         : 組み合せ数
;	WWTOUR(6,link) : トーナメント試合・組み合せ
;	-i- link  (BX) : 組み合せ番号(1-n)
;	-o- AX         : 試合属性 0=他人の試合,1=甲自分の娘,2=乙自分の娘
;	    CX         : 組み合せ・甲チーム
;	    DX         : 組み合せ・乙チーム
;	    SI         : キャラクタ番号・甲チーム
;	    DI         : キャラクタ番号・乙チーム
;	WWTOUR(7)      : トーナメント試合・衝撃！
;	WWTOUR(8,flag_victory,game,link) : トーナメント試合・勝敗
;	-i- flag_victory(BX) : 1=甲が勝ち,2=乙が勝ち
;	    game  (CX) : 第何試合か？
;	    link  (DX) : 組み合せ番号(1-n)
;	WWTOUR(9)      : トーナメント試合・オフサイド
;	-o- AX         : 状態 0=通常,1=全試合終了
;	    SI         : 優勝キャラクタ番号
;	    DI         : 準優勝キャラクタ番号
;	WWTOUR(10,entrynum): トーナメント・キャラクタ番号取得
;	-i- entrynum  (BX) : エントリィ番号(表の左上から1,2,3...)
;	-o- CX             : キャラクタ番号
;	WWTOUR(11)     : トーナメント表・再描画
;	WWTOUR(12,fighter)    : 対戦相手の検索
;	-I- fighter(BX): 対戦の片方
;	-O- AX         : 1=見つかった,0=見つからない
;	    BX         : 組み合せ番号(1-n)
;	    CX         : 検索された対戦相手
;	WWTOUR(13)     : トーナメント表飾り再描画
;
; *********************************************************

WWTOUR	PROC	NEAR
	MOV	AX,REG_AX
	MOV	BX,REG_BX
	MOV	CX,REG_CX
	MOV	DX,REG_DX
	MOV	SI,REG_SI
	MOV	DI,REG_DI
	MOV	BP,REG_BP

	CALLE	WIDTOUR			; トーナメント表

	MOV	REG_AX,AX
	MOV	REG_BX,BX
	MOV	REG_CX,CX
	MOV	REG_DX,DX
	MOV	REG_SI,SI
	MOV	REG_DI,DI
	MOV	REG_BP,BP
	RET
WWTOUR	ENDP


; *********************************************************
;	PC9801 function.	: P98F(function)
;	-I- function (AX)  :
;
;	P98F(1)		   : vram0 -> vram1 copy.
;	P98F(2,show_bank,write_bank) : bank change.
;	P98F(3,sw_analog)  : analog switch.
;	-I- sw_analog (BX) : 0=normal analog,1=386LSX(15color)
;			     2=full DIGITAL,3=B/W
; *********************************************************

P98F	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98		; PC9801
	JE	P98F_START
	RET
P98F_START:
	MOV	AX,REG_AX
	CMP	AL,1
	JE	P98F_01
	CMP	AL,2
	JE	P98F_02
	CMP	AL,3
	JE	P98F_03
	RET
P98F_01:
	MOV	AX,0
	MOV	VX1,AX			; source point.
	MOV	VY1,AX			; source point.
	MOV	VX2,80			; data size.
	MOV	VY2,400			; data size.
	MOV	VX3,AX			; dest point.
	MOV	VY3,AX			; dest point.

	MOV	AX,ARAVRM[8]		;
	MOV	SSSOUW,AX		; visual data plean width.
	MOV	SSDESW,AX		; visual data plean width.

	MOV	BX,0			;
	MOV	CX,4			;
P98F_01_LOOP:				;
	PUSH	CX			;
	PUSH	BX			;
	PUSH	BX			;
	PUSH	BX			;

	MOV	AX,0			; 0=VRAM0 write.
	CALLE	VRM98WT			; PC98 vram write bank.

	POP	BX			;
	MOV	DX,ARAVRM[BX]		; ＶＲＡＭプレーン
	MOV	ES,SEG98VRAMWORK	; PC9801 vram work.(BBCTOOL.ASM)
	CALLE	MOV1VR			; vram to vram move 1 plean.

	MOV	AX,1			; 1=VRAM1 write.
	CALLE	VRM98WT			; PC98 vram write bank.

	POP	BX			;
	MOV	DX,SEG98VRAMWORK	; PC9801 vram work.(BBCTOOL.ASM)
	MOV	ES,ARAVRM[BX]		; ＶＲＡＭプレーン
	CALLE	MOV1VR			; vram to vram move 1 plean.

	POP	BX			;
	INC	BX			;
	INC	BX			;
	POP	CX			;
	LOOP	P98F_01_LOOP		;

	MOV	AX,0			; 0=VRAM0 write.
	CALLE	VRM98WT			; PC98 vram write bank.

	RET
P98F_02:
	MOV	AX,REG_BX		;
	CALLE	VRM98DP			; PC98 vram show bank.
	MOV	AX,REG_CX		;
	CALLE	VRM98WT			; PC98 vram write bank.
	RET

P98F_03:
	MOVX	SW_ANALOG,REG_BX	; analog switch.
				; 0=normal analog,1=386LSX(15color)
				; 2=full DIGITAL,3=B/W
	RET
P98F	ENDP


; *********************************************************
;	パーツバンク設定	: PTBK(bank)
;	-I- bank (AX) : parts bank number.
; *********************************************************

PP_PTBK	PROC	NEAR
	MOVX	MY_PUT_BANK,REG_AX		; my put bank.
	RET
PP_PTBK	ENDP


; *********************************************************
;	ＰＵＴモード設定	: PTMD(mode)
;	-I- mode  (AX) : 0=通常,1=オーバラップ
; *********************************************************

PP_PTMD	PROC	NEAR
	MOVX	MY_PUT_MODE,REG_AX		; my put mode.
	RET
PP_PTMD	ENDP


; *********************************************************
;	パーツロード		: PTLD("filename")
; *********************************************************

PP_PTLD	PROC	NEAR
	MOV	DX,MY_PUT_BANK		; my put bank.
	CALLE	C1PATBNK		; バンクチェンジ

;*;PRVH	"PRSSEG=",PRSSEG
;*;PRVH	"PRSTOP=",PRSTOP
;*;PRVH	"PRSEND=",PRSEND

	CALLE	C1PATCLR		; パーツセットクリア
	MOV	SI,REG_SI		; file name.
	CALLE	C1PATLDA		; パーツ追加ロード
	RET
PP_PTLD	ENDP


; *********************************************************
;	パーツ追加ロード	: PTLA("filename")
; *********************************************************

PP_PTLA	PROC	NEAR
	MOV	DX,MY_PUT_BANK		; my put bank.
	CALLE	C1PATBNK		; バンクチェンジ
	MOV	SI,REG_SI		; file name.
	CALLE	C1PATLDA		; パーツ追加ロード
	RET
PP_PTLA	ENDP


; *********************************************************
;	パーツ座標ＰＵＴ	: PTX(x,y,rec)
;	-I- x     (AX) : Ｘ座標
;	    y     (BX) : Ｙ座標
;	    rec   (CX) : パターン番号
; *********************************************************

PP_PTX	PROC	NEAR
	CALL	MY_PUT_START		; my put start.

	MOVX	VRX,REG_AX		; ＰＵＴＸ
	MOVX	VRY,REG_BX		; ＰＵＴＹ
	MOV	CX,REG_CX		; パーツ番号
	CALLE	C1PATPTX		; パーツＰＵＴ座標指定

	CALL	MY_PUT_END		; my put end.
	RET
PP_PTX	ENDP


; *********************************************************
;	マスクパーツＰＵＴ	: PTM(x,y,rec)
;	-I- x     (AX) : Ｘ座標
;	    y     (BX) : Ｙ座標
;	    rec   (CX) : パターン番号
; *********************************************************

PP_PTM	PROC	NEAR
	CALL	MY_PUT_START		; my put start.

	MOV	AX,REG_AX		; ＰＵＴ　Ｘ座標
	MOV	BX,REG_BX		; ＰＵＴ　Ｙ座標
	MOV	CX,REG_CX		; パターン番号
	CALLE	PT_MASK_PTX		; マスクパターンＰＵＴ座標指定

	CALL	MY_PUT_END		; my put end.
	RET
PP_PTM	ENDP


; *********************************************************
;	ﾊﾟｰﾂｵﾌｾｯﾄ座標ＰＵＴ	: PTF(x,y,rec)
;	-I- x     (AX) : Ｘオフセット座標
;	    y     (BX) : Ｙオフセット座標
;	    rec   (CX) : パターン番号
; *********************************************************

PP_PTF	PROC	NEAR
	CALL	MY_PUT_START		; my put start.

	MOVX	VRX,REG_AX		; ＰＵＴＸ
	MOVX	VRY,REG_BX		; ＰＵＴＹ
	MOV	CX,REG_CX		; パーツ番号
	CALLE	C1PATPTF		; パーツＰＵＴオフセット指定

	CALL	MY_PUT_END		; my put end.
	RET
PP_PTF	ENDP


; *********************************************************
;	ﾏｽｸﾊﾟﾀｰﾝ座標ｵﾌｾｯﾄPUT	: PTMF(x,y,rec)
;	-I- x     (AX) : Ｘオフセット座標
;	    y     (BX) : Ｙオフセット座標
;	    rec   (CX) : パターン番号
; *********************************************************

PP_PTMF	PROC	NEAR
	CALL	MY_PUT_START		; my put start.

	MOV	AX,REG_AX		; ＰＵＴ　Ｘ座標
	MOV	BX,REG_BX		; ＰＵＴ　Ｙ座標
	MOV	CX,REG_CX		; パターン番号
	CALLE	PT_MASK_PTF		; マスクパターンＰＵＴオフセット

	CALL	MY_PUT_END		; my put end.
	RET
PP_PTMF	ENDP


; *********************************************************
;	ﾏｽｸﾊﾟﾀｰﾝ座標ｵﾌｾｯﾄ範囲PUT : PTMFX(x,y,rec,xx,yy,sizex,sizey)
;	-I- x     (AX) : Ｘオフセット座標
;	    y     (BX) : Ｙオフセット座標
;	    rec   (CX) : パターン番号
;	    xx    (DX) : ＧＥＴ Ｘ座標
;	    yy    (SI) : ＧＥＴ Ｙ座標
;	    sizex (DI) : ＧＥＴ Ｘサイズ
;	    sizey (BP) : ＧＥＴ Ｙサイズ
; *********************************************************

PP_PTMFX	PROC	NEAR
	CALL	MY_PUT_START		; my put start.

	MOVX	VRPX,REG_DX		; ＧＥＴ Ｘ座標
	MOVX	VRPY,REG_SI		; ＧＥＴ Ｙ座標
	MOVX	VRLENPX,REG_DI		; ＧＥＴ Ｘサイズ
	MOVX	VRLENPY,REG_BP		; ＧＥＴ Ｙサイズ
	CALLE	C1PLSVIW		; ＰＵＴＶＩＥＷの設定

	MOV	AX,REG_AX		; ＰＵＴ　Ｘ座標
	MOV	BX,REG_BX		; ＰＵＴ　Ｙ座標
	MOV	CX,REG_CX		; パターン番号
	CALLE	PT_MASK_PTF		; マスクパターンＰＵＴオフセット

	CALLE 	C1PLSVWS		; ＰＵＴＶＩＥＷの解除

	CALL	MY_PUT_END		; my put end.
	RET
PP_PTMFX	ENDP


; *********************************************************
;	パーツバッファクリア	: PTCLR
; *********************************************************

PP_PTCLR	PROC	NEAR
	CALL	MY_PUT_START		; my put start.
	CALLE	C1PATCLR		; パーツセットクリア
	CALL	MY_PUT_END		; my put end.
	RET
PP_PTCLR	ENDP


; *********************************************************
;	パーツ座標ＰＵＴ : PTGT(x,y,xl,yl)
;	-I- x  (AX) : 左上Ｘ
;	    y  (BX) : 左上Ｙ
;	    xl (CX) : サイズＸ
;	    yl (DX) : サイズＹ
;	-O- AX      : 0=normal end, 1=error.
; *********************************************************

PP_PTGT	PROC	NEAR
	CALL	MY_PUT_START		; my put start.

	MOVX	VRX,REG_AX		; window 左上Ｘ
	MOVX	VRY,REG_BX		; window 左上Ｙ
	MOVX	VRLENX,REG_CX		; window サイズＸ
	MOVX	VRLENY,REG_DX		; window サイズＹ
	CALLE	C1PATGTA		; パーツＧＥＴ圧縮無し
	MOV	REG_AX,AX		;

	CALL	MY_PUT_END		; my put end.
	RET
PP_PTGT	ENDP


; *********************************************************
;	パーツパレットセット	: PTPLT(rec,num)
;	-i- rec  (AX) : record number.
;	    num  (BX) : table number.
; *********************************************************

PP_PTPLT	PROC	NEAR
	CALL	MY_PUT_START		; my put start.

	MOV	CX,REG_AX		; パーツ番号
	MOV	BX,REG_BX		; パレットテーブル番号
	CALLE	C1PLTPAT		; パーツバッファからパレットを取り出す

	CALL	MY_PUT_END		; my put end.
	RET
PP_PTPLT	ENDP


; *********************************************************
;	effect function.	: EFC(function)
;	-I- function  (AX) :
;
;	EFC(0)	; Ｆ・Ｉ（フェードイン）
;	EFC(1)	; Ｆ・Ｏ（フェードアウト）
;	EFC(2)	; ＷＨＩＴＥ・ＦＬＡＳＨ
;	EFC(3)	; ＷＨＩＴＥ・ＩＮ
;	EFC(4)	; ＷＨＩＴＥ・ＯＵＴ
;	EFC(5)	; カラー・ＦＬＡＳＨ
;	EFC(6)	; カラー・ＦＵＬＬ
;	EFC(7)	; ブラックアウト
;	EFC(8)	; ＷＨＩＴＥ
;	EFC(9)	; 明度５０％からノーマルへ
;	EFC(10)	; 明度５０％ダウン
;	EFC(11)	; 色相反転
;	EFC(12)	; 色相戻し
;	EFC(13)	; ＷＨＩＴＥ反射感
;	EFC(14,start,end) ; パレット・オーバラップ
;	EFC(15)	; パレット・混合
;	EFC(16)	; ノーマルカラー
;	EFC(17)	; 明度５０％ダウン（瞬間）
;	EFC(18)	; palet10変化割込ON
;	EFC(19)	; palet10変化割込OFF
;	EFC(20)	; 割り込みＦ・Ｏ(ﾌｪｰﾄﾞｱｳﾄ)
;	EFC(21)	; 割り込みＦ・Ｉ(ﾌｪｰﾄﾞｲﾝ)
;	EFC(22)	; 割り込みＷＨＩＴＥ・ＩＮ
;	EFC(23)	; 割り込みＷＨＩＴＥ・ＯＵＴ
;	EFC(24) ; palet5,6,7変化割込ON(OPENING用)
;	EFC(25) ; palet5,6,7変化割込OFF(OPENING用)
; *********************************************************

EFC	PROC	NEAR
	MOV	BX,REG_AX				;
	CMP	BX,(JMP_PLTEFC_END-JMP_PLTEFC)/2	; jump table.
	JNB	EFC_EXIT				;
	SHL	BX,1					; word pointer.
	CALL	WORD PTR DS:JMP_PLTEFC[BX]		; jump table.
EFC_EXIT:
	RET
EFC	ENDP


; *********************************************************
;	パレット・オーバラップ
; *********************************************************

EFC_PLTOL	PROC	NEAR
	MOV	AX,REG_BX	; オーバラップ終了パレットテーブル番号
	MOV	BX,REG_CX	; オーバラップ開始パレットテーブル番号
	CALL	PLTOL		; パレット・オーバラップ
	RET
EFC_PLTOL	ENDP


; *********************************************************
;	picture function.	: PIC(function)
;	-I- AX : function.
;
;	PIC(1,picture_num)	; 部屋の絵PUT
;	    -I- picture_num
;		0="陶土の壷に活けられた花束"
;		1="酒瓶と林檎のある静物"
;		2="蒼色を帯びた山脈"
;		3="自画像"
;		4="降臨する天使"
;		5="魚"
;	PIC(2)			; 正常->病気
;	PIC(3)			; 病気->正常
;	PIC(4)			; direct病気
;	PIC(5)			; direct正常
;	PIC(6,x1,x2,yy,wide,color,pattern) : 水平点線
;	PIC(7,x1,x2,yy,wide,color) : 水平ライン
;
;	PIC(8,x1,y1,x2,y2,sizex,sizey) : VRAMを仮想VRAM(40*400)へ転送
;	PIC(9,x1,y1,x2,y2,sizex,sizey) : 仮想VRAM(40*400)をVRAMへ転送
;	PIC(10,x1,y1,x2,y2,sizex,sizey): 仮想VRAM(40*400)間転送
;	PIC(11)				: ﾊﾟﾀｰﾝPUTを仮想VRAM(40*400)へアサイン
;	PIC(12)				: ﾊﾟﾀｰﾝPUTをVRAMへアサイン
;	PIC(13,x1,y1,x2,y2,sizex,sizey)	: 仮想VRAM(40*400)をVRAMへｵｰﾊﾞﾗｯﾌﾟ転送
;	PIC(14,girl_age,girl_face)     : 娘の顔ファイル名
;	-o- si : file name.
;	PIC(15,x,y,"string") : 標準文字描画
;	    x  (BX)       : x.
;	    y  (CX)       : y.
;	    "string" (SI) : 表示文字列
;	PIC(16,color,size,type) : 標準文字設定
;	    color (BX)    : color 0-15
;	    size  (CX)    : size.0=16x16  1=32x32  2=16x24  3=16x32
;	    type  (DX)    : type.0=pset,1=OR,2=fuchi.
;	PIC(17,type,x,y,sizex,sizey)  : フレーム・ﾕｰｻﾞｰﾌﾚｰﾑ
;	    type  (BX)    : frame type.
;	    x     (CX)    : 表示位置Ｘ
;	    y     (DX)    : 表示位置Ｙ
;	    sizex (SI)    : 大きさＸ
;	    sizey (DI)    : 大きさＹ
;	PIC(18,x1,y1,x2,y2,color)  : BOX
;	PIC(19,ccode,color,contrast,brightness)	: パレットセット
;	    ccode     (BX) : color code.
;	    color     (CX) : color.
;	    contrast  (DX) : contrast.
;	    brightness(SI) : brightness.
;	PIC(20,tblnum,palet,color,contrast,brightness) : パレット単色ＰＵＴ
;	   tblnum     (BX) : パレットテーブル番号
;	   palet      (CX) : パレット番号
;	   color      (DX) : color.
;	   contrast   (SI) : contrast.
;	   brightness (DI) : brightness.
;
; *********************************************************

PIC	PROC	NEAR
	MOV	AX,REG_AX
	MOV	BX,REG_BX
	MOV	CX,REG_CX
	MOV	DX,REG_DX
	MOV	SI,REG_SI
	MOV	DI,REG_DI
	MOV	BP,REG_BP
	CALLE	PICTUR			; picture function.

	CMP	REG_AX,14
	JNE	PIC_EXIT
	MOV	REG_SI,SI
PIC_EXIT:
	RET
PIC	ENDP


; *********************************************************
;	music.	: MUSIC(function)
;	-I- function  (AX) :
;
;	MUSIC(0,"filename") : 音楽演奏
;	MUSIC(1) : 音楽停止
;	MUSIC(2) : 音楽ﾌｪｰﾄﾞｱｳﾄ
;	MUSIC(3) : 音楽システムPMD起動
;	MUSIC(4) : 音楽システムMMD起動
;	MUSIC(5) : 音楽システム初期処理
;	MUSIC(6,soundnumber) : 効果音発生
;	MUSIC(7,type)   : 音楽システムMIDI設定 0=MT,1=GM
;	MUSIC(8,timer1) : 音楽用ﾀｲﾏｰｾｯﾄ
;	MUSIC(9,timer)  : ｴﾝﾃﾞｨﾝｸﾞ音楽用ﾀｲﾏｰｾｯﾄ2
;	MUSIC(10)       : ｴﾝﾃﾞｨﾝｸﾞ音楽用ﾀｲﾏｰWAIT
; *********************************************************

MUSIC	PROC	NEAR
	MOV	BX,REG_AX			;
	CMP	BX,(JMP_MUSIC_END-JMP_MUSIC)/2	; jump table.
	JNB	MUSIC_EXIT			;
	SHL	BX,1				; word pointer.
	MOV	SI,REG_SI			; 曲データファイル名
	MOV	AX,REG_BX			; 効果音番号
	CALL	WORD PTR DS:JMP_MUSIC[BX]	; jump table.
MUSIC_EXIT:
	RET
MUSIC	ENDP


; *********************************************************
;	music play	: PLAY(n)
;	-i- n (AX) : 音楽番号(1000以上はﾌﾞﾘｯｼﾞ)
; *********************************************************

PLAY	PROC	NEAR
	MOV	DX,REG_AX		; 音楽番号(1000以上はﾌﾞﾘｯｼﾞ)
	CALLE	M_PLAY_NM		; 音楽演奏(番号指定)
	RET
PLAY	ENDP


; *********************************************************
;	parameter calc.	: PARC(function)
;	-I- function  (AX) :
;
;	PARC(1,"filename",function,subf) : child process load&run.
;	-o- AX : 0=normal,1=error.
;	    BX : child task exit status.
;	PARC(2,function,subf,p1,p2,p3,p4,p5) : child process run.
;	-o- BX : child task exit status.
;	PARC(3,number)	: buffer address.
;	-i- number (BX) : select buffer.
;		1=VISUALTXTSEG:[VISUALTXTSTARTOFS]
;	-o- ES:DI  : buffer address.
;	PARC(4): timer1 wait & keybord check.
;	-o- AX : 0=normal,1=PLUS,2=ESC
;	PARC(5): 音源ボードの有無
;	-o- AX : FM音源ﾎﾞｰﾄﾞの有無
;	    BX : MIDIｲﾝﾀｰﾌｪｰｽﾎﾞｰﾄﾞの有無
;	PARC(6): EMSの有無
;	-o- AX : EMSの有無
;	PARC(7): void
;	PARC(8,flag_emsload) : ﾌﾗｸﾞEMSﾛｰﾄﾞ
;	-i- flag_emsload (AX): 1=EMSﾛｰﾄﾞ
;	PARC(9): ten key check.
;	-o- AX : 番号(-1:押していない)
;	    BX : 1=HELP,2=HOME,3=PLUS,4=ESC (-1:押していない)
;	PARC(10) : マウスボタン待ち
; *********************************************************

PARC	PROC	NEAR
	MOV	AX,REG_AX
	CMP	AL,1
	JE	PARC_LOAD
	CMP	AL,2
	JE	PARC_CHILD_RUN
	CMP	AL,3
	JE	PARC_BUFFER_ADRS
	CMP	AL,4
	JE	PARC_WAIT1_AND_KEY
	CMP	AL,5
	JE	PARC_SOUND_CHK
	CMP	AL,6
	JE	PARC_EMS_CHK
	CMP	AL,7
	JE	PARC_FLAG_MIDI_ENA
	CMP	AL,8
	JE	PARC_FLAG_EMS_ALLLOAD
	CMP	AL,9
	JE	PARC_KEYTEN
	CMP	AL,10
	JE	PARC_MOUSE_WAIT
	RET

PARC_LOAD:
	MOV	SI,REG_SI		; file name.
	CALLE	CHILD_PROCESS_LOAD	; (*.com) child process load.
	MOV	REG_AX,AX		; 0=normal,1=error.
	CMP	AX,0			;
	JNE	PARC_EXIT		;
	MOV	AX,REG_BX		; child task function.
	MOV	BX,REG_CX		; sub function.
	CALLE	CHILD_PROCESS_JUMP	; (*.com) child process jump.
	MOV	REG_BX,AX		; child task exit status.
	JMP	PARC_EXIT		;

PARC_CHILD_RUN:
	MOVX	CH_PARAM01,REG_DX	; parameter 1.
	MOVX	CH_PARAM02,REG_SI	; parameter 2.
	MOVX	CH_PARAM03,REG_DI	; parameter 3.
	MOVX	CH_PARAM04,REG_BP	; parameter 4.
	MOVX	CH_PARAM05,REG_ES	; parameter 5.
	MOV	AX,REG_BX		; child task function.
	MOV	BX,REG_CX		; sub function.
	CALLE	CHILD_PROCESS_JUMP	; (*.com) child process jump.
	MOV	REG_BX,AX		; child task exit status.
	JMP	PARC_EXIT		;

PARC_BUFFER_ADRS:
	MOV	AX,REG_BX		;
	CALL	BUFFER_ADRS_SET		; buffer address set.
	MOV	REG_ES,DX		;
	MOV	REG_DI,DI		;
	JMP	PARC_EXIT		;

PARC_WAIT1_AND_KEY:
	MOV	REG_AX,0
	CALLE	KEYTEN			; キーボード・読み込み
	CMP	BX,3			; 3=PLUS
	JE	PARC_WAIT1_AND_KEY_PLUS	;
	CMP	BX,4			; 4=ESC
	JE	PARC_WAIT1_AND_KEY_ESC	;
	CALLE	TMVCK2			; V-SYNC timer2 check.
	CMP	AX,0			; 0=timer now, 1=timer end.
	JE	PARC_WAIT1_AND_KEY	;
	JMP	PARC_EXIT		;

PARC_WAIT1_AND_KEY_PLUS:
	MOV	REG_AX,1		; 1=PLUS
	JMP	PARC_EXIT
PARC_WAIT1_AND_KEY_ESC:
	MOV	REG_AX,2		; 2=ESC
	JMP	PARC_EXIT

PARC_SOUND_CHK:
	CALLE	M_SOUNDBORD_CHECK	; 音源の有無
	MOVX	REG_AX,FLAG_FM_BORD	; FM音源ﾎﾞｰﾄﾞの有無
	MOVX	REG_BX,FLAG_MIDI_BORD	; MIDIｲﾝﾀｰﾌｪｰｽﾎﾞｰﾄﾞの有無
	JMP	PARC_EXIT

PARC_EMS_CHK:
	MOV	AX,FLAG_EMS_OPEN_OK		; flag EMS open ok.
	MOV	REG_AX,AX			; 1=ok,0=Expanded memory none.
	JMP	PARC_EXIT

PARC_FLAG_MIDI_ENA:
	JMP	PARC_EXIT

PARC_FLAG_EMS_ALLLOAD:
	MOVX	FLAG_EMS_ALLLOAD,REG_BX		; flag EMS all load.
	LC	0,7
	PRF	"EMS page full allcation."
	CALL	EMEMALLOC		; (far)Expanded memory allocate.
	JMP	PARC_EXIT

PARC_KEYTEN:
	CALL	KEYTEN			; キーボード・読み込み
	MOV	REG_AX,AX		; 番号(-1:押していない)
	MOV	REG_BX,BX		; 1=HELP,2=HOME,3=PLUS,4=ESC
	JMP	PARC_EXIT

PARC_MOUSE_WAIT:
	CALLE	MUSRED			; マウス読み込み
	CMP	DH,0			; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	PARC_EXIT		;
	CMP	DL,0			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	PARC_EXIT		;
	JMP	PARC_MOUSE_WAIT		;

PARC_EXIT:
	RET
PARC	ENDP


; *********************************************************
;	buffer address set.
;	-I- AX : select buffer.
;		1=VISUALTXTSEG:[VISUALTXTSTARTOFS]
;	-O- DX:DI : buffer address.
; *********************************************************

BUFFER_ADRS_SET	PROC	NEAR
	CMP	AL,1
	JE	BUFFER_ADRS_SET_1N
	RET
BUFFER_ADRS_SET_1N:
	MOV	DX,VISUALTXTSEG		; visual text buffer segment.
	MOV	DI,VISUALTXTSTARTOFS	; visual text buffer start offset.
	RET
BUFFER_ADRS_SET	ENDP


; *********************************************************
;	my put start.
; *********************************************************

MY_PUT_START	PROC	NEAR
	MOV	DX,MY_PUT_BANK		; my put bank.
	CALLE	C1PATBNK		; バンクチェンジ
	MOV	AX,MY_PUT_MODE		; my put mode.
	CALLE	C1PATEFC		; パーツＰＵＴエフェクト
	RET
MY_PUT_START	ENDP


; *********************************************************
;	my put end.
; *********************************************************

MY_PUT_END	PROC	NEAR
	MOV	AX,0			; 0=通常
	CALLE	C1PATEFC		; パーツＰＵＴエフェクト
	RET
MY_PUT_END	ENDP


; *********************************************************
;	line		: GG_LINE(x1,y1,x2,y2,col)
;	-i- x1  (AX) : start point.
;	    y1  (BX) : start point.
;	    x2  (CX) : end point.
;	    y2  (DX) : end point.
;	    col (SI) : color.
; *********************************************************

GG_LINE	PROC	NEAR
	MOV_ID2	SSDES0,ARAVRM		; visual data segment plean 0
	MOVX	VX1,REG_AX		; start point.
	MOVX	VY1,REG_BX		; start point.
	MOVX	VX2,REG_CX		; end point.
	MOVX	VY2,REG_DX		; end point.
	MOVX	VCOL,REG_SI		; color.
	CALLE	XLINE			; line.
	RET
GG_LINE	ENDP


; *********************************************************
;	demo mode.	: XDBG(function)
;	-i- function  (AX) :
;
;	XDBG(1)	: demo start.
;	XDBG(2)	: demo stop.
;	XDBG(3)	: stack dump.
;	XDBG(4,areanum,length) : buffer file write.
;	    areanum (BX) :
;		=1 VISUALTXTSEG:[VISUALTXTSTARTOFS]
;		=2 TEXTPSEG:[TEXTPSTARTOFS]
;	    length  (CX) : write length.
;	XDBG(5)	: now demo mode.
;	-o- AX : 0=normal,1=demo.
;	XDBG(6)	: palet test.
;	XDBG(7)	: key test.
; *********************************************************

XDBG	PROC	NEAR
	MOV	AX,REG_AX
	CMP	AL,1
	JE	XDEMO_1N
	CMP	AL,2
	JE	XDEMO_2N
	CMP	AL,3
	JE	XDBG_3N
	CMP	AL,4
	JE	XDBG_4N
	CMP	AL,5
	JE	XDBG_5N
	CMP	AL,6
	JE	XDBG_6N
	CMP	AL,7
	JE	XDBG_7N
	RET
XDEMO_1N:
	MOV	WIDSDEMO,55		; (WIDSLCT.ASM)デモフラグ
	MOV	WIDTDEMO,55		; (WIDTEXT.ASM)デモフラグ
	MOV	WIDMDEMO,55		; (WIDMULT.ASM)デモフラグ
	MOV	CHILDDEMO,55		; (CHILD.ASM)デモフラグ
	MOV	USERDEMO,55		; (USERTOOL.ASM)デモフラグ
	MOV	WIDDDEMO,55		; (WIDDIRSL.ASM)デモフラグ
	MOV	TALKDEMO,55		; (TALKER.ASM)デモフラグ

	MOV	WIDSDEMOWAIT,5		; (WIDSLCT.ASM)デモ 待ち時間
	MOV	WIDTDEMOWAIT,5		; (WIDTEXT.ASM)デモ 待ち時間
	MOV	WIDMDEMOWAIT,5		; (WIDMULT.ASM)デモ 待ち時間
	RET
XDEMO_2N:
	MOV	WIDSDEMO,0		; (WIDSLCT.ASM)デモフラグ
	MOV	WIDTDEMO,0		; (WIDTEXT.ASM)デモフラグ
	MOV	WIDMDEMO,0		; (WIDMULT.ASM)デモフラグ
	MOV	CHILDDEMO,0		; (CHILD.ASM)デモフラグ
	MOV	USERDEMO,0		; (USERTOOL.ASM)デモフラグ
	MOV	WIDDDEMO,0		; (WIDDIRSL.ASM)デモフラグ
	MOV	TALKDEMO,0		; (TALKER.ASM)デモフラグ
	RET
XDBG_3N:
	MOVX	ES,<SEG STACK>		; stack segment.
	MOV	DI,OFFSET TOP_OF_STACK	; stack pointer.
	MOV	CX,1000
XDBG_3N_LOOP:
	PUSH	CX
	MOV	DX,ES:[DI]
	DEC	DI
	DEC	DI
	CALL	HEXSTR
	CALL	PRINT
	PR " "
	POP	CX
	LOOP	XDBG_3N_LOOP
	RET
XDBG_4N:
	CMP	REG_BX,1
	JE	XDBG_4N1
	CMP	REG_BX,2
	JE	XDBG_4N2
XDBG_4N1:
	MOV	DX,VISUALTXTSEG		; visual text buffer segment.
	MOV	DI,VISUALTXTSTARTOFS	; visual text buffer start offset.
	JMP	XDBG_4N_WRITE		;
XDBG_4N2:
	MOV	DX,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPSTARTOFS	; text start offset.
XDBG_4N_WRITE:
	MOV	CX,REG_CX		; write length.
	MOV	SI,OFFSET XDBG4FLNAME	; file name.
	CALLE	DISKSV			; disk save.
	RET
XDBG_5N:
	CMP	WIDSDEMO,55		; (WIDSLCT.ASM)デモフラグ
	JE	XDBG_5N2		;
	MOV	REG_AX,0
	RET
XDBG_5N2:
	MOV	REG_AX,1
	RET

IF DEBUG_PALET
XXXXX	MACRO	AAAA,BBBB,CCCC,DDDD
	MOV	CLRCDE,AAAA			; color code.
	MOV	CLRVEW,BBBB			; color.
	MOV	CLRCNS,CCCC			; contrast.
	MOV	CLRBRI,DDDD			; brightness.
	CALL	CHG2BRG
	ENDM
ENDIF

XDBG_6N:

IF DEBUG_PALET
	XXXXX	1,30,13,100
	XXXXX	2,15,27,100
	XXXXX	3,10,43,93
	XXXXX	4,0,53,67
	XXXXX	5,0,70,52
	XXXXX	6,0,100,33

	XXXXX	1,170,12,56
	XXXXX	2,147,8,47
	XXXXX	3,128,16,44
	XXXXX	4,165,29,37
	XXXXX	5,165,70,17
	XXXXX	6,165,100,12
ENDIF
	RET

XDBG_7N:

IF DEBUG_KEYBORD
	MOV	SI,OFFSET KYTBLS
	MOV	CX,16
XDBG_7N_LOOP:
	LODSB
	MOV	AH,0
	PRVB	":",AX
	LOOP	XDBG_7N_LOOP
ENDIF
	RET
XDBG	ENDP


IF DEBUG_PALET

;	chenge BRG.
;	-i- CLRCDE : color code.
;	    CLRVEW : color.
;	    CLRCNS : contrast.
;	    CLRBRI : brightness.
;	-O- CRNUM  : color code.
;	    CBLUE  : blue  value (0-15)
;	    CRED   : red   value (0-15)
;	    CGREEN : green value (0-15)

DIV8N	MACRO
	DIV	DIV8
	ENDM

DIV100N	MACRO
	LOCAL	L1
	DIV	DIV100
	ENDM

DIV100N2	MACRO
	LOCAL	L1
	DIV	DIV100
	CMP	DX,50
	JL	L1
	INC	AX
L1:
	ENDM

DIV6000N	MACRO
	LOCAL	L1
	DIV	DIV6000
	CMP	DX,30
	JL	L1
	INC	AX
L1:
	ENDM


CHG2BRG	PROC	NEAR
	MOV	AX,UPCOLOR
	MOV	UPPER,AX

	MOV	AX,100
	SUB	AX,CLRCNS	; contrast.
	MUL	UPCOLOR
	DIV100N2
	MOV	UNDER,AX

	MOV	AX,CLRVEW	; color.
	CMP	AX,60
	JL	CHG2BRG_C1
	CMP	AX,120
	JL	CHG2BRG_C2
	CMP	AX,180
	JL	CHG2BRG_C3
	CMP	AX,240
	JL	CHG2BRG_C4
	CMP	AX,300
	JL	CHG2BRG_C5
	JMP	CHG2BRG_C6
CHG2BRG_C1:
	MOV	CX,CLRVEW	; color.
	JMP	CHG2BRG_5
CHG2BRG_C2:
	MOV	CX,120
	SUB	CX,CLRVEW	; color.
	JMP	CHG2BRG_5
CHG2BRG_C3:
	MOV	CX,CLRVEW	; color.
	SUB	CX,120
	JMP	CHG2BRG_5
CHG2BRG_C4:
	MOV	CX,240
	SUB	CX,CLRVEW	; color.
	JMP	CHG2BRG_5
CHG2BRG_C5:
	MOV	CX,CLRVEW	; color.
	SUB	CX,240
	JMP	CHG2BRG_5
CHG2BRG_C6:
	MOV	CX,360
	SUB	CX,CLRVEW	; color.
CHG2BRG_5:
	MOV	AX,CLRCNS	; contrast.
	MUL	CX
	MUL	UPCOLOR
	DIV6000N
	ADD	AX,UNDER
	MOV	SLIDE,AX

	MOV	AX,UPPER
	MUL	CLRBRI		; brightness.
	DIV100N
	MOV	UPPER,AX

	MOV	AX,UNDER
	MUL	CLRBRI		; brightness.
	DIV100N
	MOV	UNDER,AX

	MOV	AX,SLIDE
	MUL	CLRBRI		; brightness.
	DIV100N
	MOV	SLIDE,AX

	MOV	BX,UPPER
	MOV	CX,UNDER
	MOV	DX,SLIDE

	MOV	AX,CLRVEW	; color.
	CMP	AX,60
	JL	CHG2BRG_C1S
	CMP	AX,120
	JL	CHG2BRG_C2S
	CMP	AX,180
	JL	CHG2BRG_C3S
	CMP	AX,240
	JL	CHG2BRG_C4S
	CMP	AX,300
	JL	CHG2BRG_C5S
	JMP	CHG2BRG_C6S
CHG2BRG_C1S:
	MOV	CRED,BX
	MOV	CBLUE,CX
	MOV	CGREEN,DX
	JMP	CHG2BRG_SET
CHG2BRG_C2S:
	MOV	CGREEN,BX
	MOV	CBLUE,CX
	MOV	CRED,DX
	JMP	CHG2BRG_SET
CHG2BRG_C3S:
	MOV	CGREEN,BX
	MOV	CRED,CX
	MOV	CBLUE,DX
	JMP	CHG2BRG_SET
CHG2BRG_C4S:
	MOV	CBLUE,BX
	MOV	CRED,CX
	MOV	CGREEN,DX
	JMP	CHG2BRG_SET
CHG2BRG_C5S:
	MOV	CBLUE,BX
	MOV	CGREEN,CX
	MOV	CRED,DX
	JMP	CHG2BRG_SET
CHG2BRG_C6S:
	MOV	CRED,BX
	MOV	CGREEN,CX
	MOV	CBLUE,DX
	JMP	CHG2BRG_SET
CHG2BRG_SET:

	MOV	DX,0
	MOV	AX,CBLUE	; blue  value.
	DIV8N
	MOV	CBLUE,AX	; blue  value.

	MOV	DX,0
	MOV	AX,CRED		; red   value (0-15)
	DIV8N
	MOV	CRED,AX		; red   value (0-15)

	MOV	DX,0
	MOV	AX,CGREEN	; green value (0-15)
	DIV8N
	MOV	CGREEN,AX	; green value (0-15)


PRV	"CBLUE =",CBLUE
PRV	"CRED  =",CRED
PRV	"CGREEN=",CGREEN

	MOV	AX,CLRCDE		;
	MOV	CRNUM,AX		; CRNUM = CLRCDE

	PR	"("
	MOV	DX,CRNUM	; color code.
	CALL	DECSTR
	CALL	PRINT
	PR	","
	MOV	DX,CBLUE	; blue  value (0-15)
	CALL	DECSTR
	CALL	PRINT
	PR	","
	MOV	DX,CRED		; red   value (0-15)
	CALL	DECSTR
	CALL	PRINT
	PR	","
	MOV	DX,CGREEN	; green value (0-15)
	CALL	DECSTR
	CALL	PRINT
	PR	")"
	LF

CHG2BRG_EXIT:
	RET
CHG2BRG	ENDP

ENDIF


; *********************************************************
;	テキストロード時の初期処理(far)
; *********************************************************

BBCTOOL3_LOADINIT	PROC	FAR
	MOV	MY_PUT_BANK,0			; my put bank.
	RET
BBCTOOL3_LOADINIT	ENDP

CODE01	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SEG98VRAMWORK:WORD		; PC9801 vram work.(BBCTOOL.ASM)

EXTRN	WIDSDEMO:WORD			; (WIDSLCT.ASM)デモフラグ
					; 0=通常,55=ランダムセレクト
EXTRN	WIDSDEMOWAIT:WORD		; (WIDSLCT.ASM)デモ 待ち時間

EXTRN	WIDTDEMO:WORD			; (WIDTEXT.ASM)デモフラグ
					; 0=通常,55=ランダムセレクト
EXTRN	WIDTDEMOWAIT:WORD		; (WIDTEXT.ASM)デモ 待ち時間

EXTRN	WIDMDEMO:WORD			; (WIDMULT.ASM)デモフラグ
					; 0=通常,55=ランダムセレクト
EXTRN	WIDMDEMOWAIT:WORD		; (WIDMULT.ASM)デモ 待ち時間

EXTRN	CHILDDEMO:WORD			; (CHILD.ASM)デモフラグ
					; 0=通常,55=ランダムセレクト

EXTRN	USERDEMO:WORD			; (USERTOOL.ASM)デモフラグ
					; 0=通常,55=ランダムセレクト

EXTRN	WIDDDEMO:WORD			; (WIDDIRSL.ASM)デモフラグ
					; 0=通常,55=ランダムセレクト

EXTRN	TALKDEMO:WORD			; (TALKER.ASM)デモフラグ
					; 0=通常,55=ランダムセレクト

EXTRN	KYTBLS:BYTE			;(VKEYBORD.ASM) key code table.

EXTRN	S_BYOUKI:WORD			; 病気指数(%)
EXTRN	S_HIKOUKA:WORD			; 非行化指数(%)
EXTRN	S_JINMYAKU:WORD			; 人脈
EXTRN	FLAG_BYOUKI:WORD		; 状態・病気
EXTRN	FLAG_HIKOUKA:WORD		; 状態・非行化
EXTRN	FLAG_RENAI:WORD			; 状態・恋愛
EXTRN	FLAG_KENKO:WORD			; 健康管理

EXTRN	GIRL_BODY:WORD			; 体形 1=細,2=太
EXTRN	GIRL_FACE:WORD			; 表情 1=基本,2=非行,3病気,4元気,5色気
EXTRN	GIRL_BREAST:WORD		; 胸大 0=無,1=有
EXTRN	GIRL_DAMEG:WORD			; 重病 0=normal,1=重病

EXTRN	P_NENREI:WORD			; 年齢
EXTRN	P_BORTHDAY:WORD			; 誕生日
EXTRN	P_BORTHMONTH:WORD		; 誕生月
EXTRN	P_BORTHYEAR:WORD		; 誕生年

EXTRN	WD_GIRL_AGE:WORD		; girl age.

EXTRN	SSDES0:WORD			; visual data segment plean 0
EXTRN	SSDES1:WORD			; visual data segment plean 1
EXTRN	SSDES2:WORD			; visual data segment plean 2
EXTRN	SSDES3:WORD			; visual data segment plean 3
EXTRN	SSDESW:WORD			; visual data plean width.

EXTRN	SSSOU0:WORD			; visual data segment plean 0
EXTRN	SSSOU1:WORD			; visual data segment plean 1
EXTRN	SSSOU2:WORD			; visual data segment plean 2
EXTRN	SSSOU3:WORD			; visual data segment plean 3
EXTRN	SSSOUW:WORD			; visual data plean width.

EXTRN	BORTH_YEAR:WORD			; 誕生日の年
EXTRN	BORTH_MONTH:WORD		; 誕生日の月
EXTRN	BORTH_DAY:WORD			; 誕生日の日

EXTRN	NEXT_M_YEAR:WORD		; 翌月の年
EXTRN	NEXT_M_MONTH:WORD		; 翌月の月
EXTRN	NEXT_M_ENDDAY:WORD		; 翌月の末日
EXTRN	NEXT_M_SWEEK:WORD		; 翌月の最初の曜日

EXTRN	ISITM:WORD			; select item number.
EXTRN	WIDINM:WORD			; アイテム選択番号

EXTRN	WDX1:WORD			; WINDOWS/point x1.
EXTRN	WDY1:WORD			; WINDOWS/point y1.

EXTRN	VX1:WORD			; point x1.
EXTRN	VY1:WORD			; point y1.
EXTRN	VX2:WORD			; point x2.
EXTRN	VY2:WORD			; point y2.
EXTRN	VX3:WORD			; point x3.
EXTRN	VY3:WORD			; point y3.
EXTRN	ADRS:WORD			; address.
EXTRN	NUM:WORD			; number.
EXTRN	VCOL:WORD			; color.

EXTRN	VRX:WORD			; x point.
EXTRN	VRY:WORD			; y point.
EXTRN	VRLENX:WORD			; x length.
EXTRN	VRLENY:WORD			; y length.

EXTRN	VRPX:WORD			; ＧＥＴ Ｘ座標
EXTRN	VRPY:WORD			; ＧＥＴ Ｙ座標
EXTRN	VRLENPX:WORD			; ＧＥＴ Ｘサイズ
EXTRN	VRLENPY:WORD			; ＧＥＴ Ｙサイズ

EXTRN	PRSSEG:WORD		; バンクセグメント
EXTRN	PRSTOP:WORD		; バンクトップオフセット
EXTRN	PRSEND:WORD		; バンクエンドオフセット

EXTRN	VISUALTXTSEG:WORD	; visual text buffer segment.
EXTRN	VISUALTXTOFS:WORD	; visual text buffer offset.
EXTRN	VISUALTXTSTARTOFS:WORD	; visual text buffer start offset.

EXTRN	CH_PARAM01:WORD			; parameter 1.
EXTRN	CH_PARAM02:WORD			; parameter 2.
EXTRN	CH_PARAM03:WORD			; parameter 3.
EXTRN	CH_PARAM04:WORD			; parameter 4.
EXTRN	CH_PARAM05:WORD			; parameter 5.
EXTRN	CH_PARAM06:WORD			; parameter 6.

EXTRN	FLAG_FM_BORD:WORD		; FM音源ﾎﾞｰﾄﾞの有無
EXTRN	FLAG_MIDI_BORD:WORD		; MIDIｲﾝﾀｰﾌｪｰｽﾎﾞｰﾄﾞの有無

EXTRN	FLAG_EMS_OPEN_OK:WORD		; flag EMS open ok.
EXTRN	FLAG_EMS_ALLLOAD:WORD		; flag EMS all load.

EXTRN	SW_ANALOG:WORD			; analog switch.
					; 0=normal analog,1=386LSX(15color)
					; 2=full DIGITAL,3=B/W

MY_PUT_BANK	DW	0	; my put bank.
MY_PUT_MODE	DW	0	; my put mode.

BAK_GIRL_BODY	DW	0	; 体形 1=細,2=太
BAK_GIRL_FACE	DW	0	; 表情 1=基本,2=非行,3病気,4元気,5色気
BAK_GIRL_DAMEG	DW	0	; 重病 0=normal,1=重病
BAK_P_NENREI	DW	0	; 年齢

JMP_PLTEFC	LABEL	WORD	; jump table.
	DW	FEDIN		; 0=Ｆ・Ｉ（フェードイン）
	DW	FEDOUT		; 1=Ｆ・Ｏ（フェードアウト）
	DW	WHTFLS		; 2=ＷＨＩＴＥ・ＦＬＡＳＨ
	DW	WHTIN		; 3=ＷＨＩＴＥ・ＩＮ
	DW	WHTOUT		; 4=ＷＨＩＴＥ・ＯＵＴ
	DW	COLFLS		; 5=カラー・ＦＬＡＳＨ
	DW	COLFUL		; 6=カラー・ＦＵＬＬ
	DW	BLACK		; 7=ブラックアウト
	DW	WHITE		; 8=ＷＨＩＴＥ
	DW	BRIIN		; 9=明度５０％からノーマルへ
	DW	BRIOUT		; 10=明度５０％ダウン
	DW	COLBCK		; 11=色相反転
	DW	COLRET		; 12=色相戻し
	DW	FFWHT		; 13=ＷＨＩＴＥ反射感
	DW	EFC_PLTOL	; 14=パレット・オーバラップ
	DW	PLTMIX		; 15=パレット・混合
	DW	NORMIN		; 16=ノーマルカラー
	DW	DWN50P		; 17=明度５０％ダウン（瞬間）
	DW	PLTINT_P10_ON	; 18=palet10変化割込ON
	DW	PLTINT_P10_OFF	; 19=palet10変化割込OFF
	DW	PLTINT_FO	; 20=割り込みＦ・Ｏ(ﾌｪｰﾄﾞｱｳﾄ)
	DW	PLTINT_FI	; 21=割り込みＦ・Ｉ(ﾌｪｰﾄﾞｲﾝ)
	DW	PLTINT_WI	; 22=割り込みＷＨＩＴＥ・ＩＮ
	DW	PLTINT_WO	; 23=割り込みＷＨＩＴＥ・ＯＵＴ
	DW	PLTINT_P567_ON	; 24=palet5,6,7変化割込ON(OPENING用)
	DW	PLTINT_P567_OFF	; 25=palet5,6,7変化割込OFF(OPENING用)
JMP_PLTEFC_END	LABEL	WORD	; jump table end.

JMP_MUSIC	LABEL	WORD	; jump table.
	DW	M_PLAY		; 0=音楽演奏
	DW	M_STOP		; 1=音楽停止
	DW	M_FDOT		; 2=音楽フェードアウト
	DW	M_SETUP_PMD	; 3=音楽システムPMD起動
	DW	M_SETUP_MMD	; 4=音楽システムMMD起動
	DW	M_INIT		; 5=音楽システム初期処理
	DW	SNDON		; 6=効果音発生
	DW	M_SETUP_MIDI	; 7=音楽システムMIDI設定
	DW	M_TIMER		; 8=音楽用ﾀｲﾏｰｾｯﾄ
	DW	M_TIMER2	; ｴﾝﾃﾞｨﾝｸﾞ音楽用ﾀｲﾏｰｾｯﾄ2
	DW	M_TIMER2WAIT	; ｴﾝﾃﾞｨﾝｸﾞ音楽用ﾀｲﾏｰWAIT
JMP_MUSIC_END	LABEL	WORD	; jump table end.

JMP_PROF	LABEL	WORD	; jump table.
	DW	WIDPROF_SET	; WINDOWS/プロフィール・表示
	DW	WIDPROF_SHOW	; WINDOWS/プロフィール・再表示
	DW	WIDPROF_GOLD	; WINDOWS/プロフィール・所持金
	DW	WIDPROF_AGE	; WINDOWS/プロフィール・年齢
	DW	WIDPROF_R_GOLD	; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･所持金
	DW	WIDPROF_R_HP	; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･HP
	DW	WIDPROF_R_MP	; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･MP
	DW	WIDPROF_R_ARMS	; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･装備
JMP_PROF_END	LABEL	WORD	; jump table end.


XDBG4FLNAME	DB	"WWWW"	; file name.

IF DEBUG_PALET

CLRCDE	DW	0	; color code.
CLRVEW	DW	0	; color.
CLRCNS	DW	0	; contrast.
CLRBRI	DW	0	; brightness.
CRNUM	DW	0	; color code.       
CBLUE	DW	0	; blue  value (0-15)
CRED	DW	0	; red   value (0-15)
CGREEN	DW	0	; green value (0-15)
UPPER		DW	0	;
UNDER		DW	0	;
SLIDE		DW	0	;
DIV8		DW	8	;
DIV100		DW	100	;
DIV6000		DW	6000	;
UPCOLOR		DW	07FH	;

ENDIF

DATA	ENDS

	END
;
;	end of "BBCTOOL3.ASM"
;
