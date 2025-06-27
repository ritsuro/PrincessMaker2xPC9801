; "WIDCLEND.ASM" PC-9801UV11 make by R.H 1992/06/03
;
;
;	ＷＩＮＤＯＷＳ／カレンダー
;
;
;	WIDCLEN_SET		; WINDOWS/カレンダー・表示
;	WIDCLEN_SHOW		; WINDOWS/カレンダー・再表示
;	WIDCLEN_UDATE		; WINDOWS/カレンダー・更新処理
;	WIDCLEN_NXT_E		; WINDOWS/カレンダー・翌月の計算
;	WIDCLEN_NOW_E		; WINDOWS/カレンダー・今月の計算
;	WIDCLEN_AGE		; WINDOWS/カレンダー・年齢の計算
;	WIDCLEN_SETUP_INI	; WINDOWS/カレンダー・初期ｾｯﾄｱｯﾌﾟ
;	WIDCLEN_SETUP		; WINDOWS/カレンダー・セットアップ
;	WIDCLEN_MONTH		; WINDOWS/カレンダー・月データ
;
;	WIDCLEN_UDATEで　日次チェック(DAILY_CHECK)を行います。
;
;	＊現在時間
;	extrn	VAL_YEAR		: 年
;	extrn	VAL_MONTH		: 月
;	extrn	VAL_WEEK		: 曜日
;	extrn	VAL_DAY			: 日
;	extrn	VAL_A_DAY		: 年内合計日付
;	extrn	VAL_M_END		: 月末の日
;	extrn	TM_SEASON		: 季節（1:春,2:夏,3:秋,4:冬）
;	extrn	FLG_SHOGATSU		: フラグ・正月
;	extrn	FLG_URUBI		: フラグ・うるう日
;	extrn	FLG_CHRISTMAS_EVE 	: フラグ・クリスマスイブ
;	extrn	FLG_G_BORTH		: フラグ・娘の誕生日
;	extrn	FLG_M_BORTH		: フラグ・私の誕生日
;	extrn	FLG_HOLIDAY		: フラグ・休日
;	extrn	FLG_SYUKAKU		; フラグ・収穫祭の準備
;
;	0=（日）Sunday
;	1=（月）Monday
;	2=（火）Tuesday
;	3=（水）Wednesday
;	4=（木）Thursday
;	5=（金）Friday
;	6=（土）Saturday
;
;
;	extrn	PT_CLEND_LOC		; calendar locate.
;	extrn	PT_CLEND_FRM		; calendar fream.
;	extrn	PT_CLEND_YEAR		; calendar year.
;	extrn	PT_CLEND_MONTH		; calendar month.
;	extrn	PT_CLEND_WEEK		; calendar week.
;	extrn	PT_CLEND_DAY		; calendar day.
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

EOS		EQU	0	; end of string.

MOVX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	MOV	DEST,AX
	ENDM

ADDX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	ADD	DEST,AX
	ENDM

CMPX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	CMP	DEST,AX
	ENDM

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/カレンダー・表示
; ****************************************************

FUNC	WIDCLEN_SET
	CALL	WIDCLEN_OPEN		; カレンダー・ＯＰＥＮ
	CALL	WIDCLEN_DISP		; カレンダー表示
	RET
FEND	WIDCLEN_SET


; ****************************************************
;	WINDOWS/カレンダー・再表示
; ****************************************************

FUNC	WIDCLEN_SHOW
	CALL	WIDCLEN_DISP		; カレンダー表示
	RET
FEND	WIDCLEN_SHOW


; ****************************************************
;	WINDOWS/カレンダー・更新処理
; ****************************************************

FUNC	WIDCLEN_UDATE
	CALL	UPDATE_SET		; 日付の更新
	CALL	CHK_SEASON		; 季節のチェック
	CALL	DAILY_CHECK		; 日次チェック
	RET
FEND	WIDCLEN_UDATE


; ****************************************************
;	WINDOWS/カレンダー・翌月の計算
;	-O- NEXT_M_YEAR   : 翌月の年
;	    NEXT_M_MONTH  : 翌月の月
;	    NEXT_M_ENDDAY : 翌月の末日
;	    NEXT_M_SWEEK  : 翌月の最初の曜日
; ****************************************************

FUNC	WIDCLEN_NXT_E
	MOV	CX,VAL_YEAR			; CX=年
	MOV	BX,VAL_MONTH			; (now)月

	INC	BX				; BX=翌月
	CMP	BX,12				;
	JBE	WIDCLEN_NXT_E_1			;
	MOV	BX,1				; １月
	INC	CX				; 来年
WIDCLEN_NXT_E_1:				;
	MOV	NEXT_M_YEAR,CX			; 翌月の年
	MOV	NEXT_M_MONTH,BX			; 翌月の月
	CALL	MATSUJITSU			; 末日計算
	MOV	NEXT_M_ENDDAY,DX		; 翌月の末日

	MOV	AX,VAL_WEEK			; 曜日
	INC	AX				;
	CMP	AX,6				; 6=（土）Saturday
	JBE	WIDCLEN_NXT_E_6			;
	MOV	AX,0				; 0=（日）Sunday
WIDCLEN_NXT_E_6:				;
	MOV	NEXT_M_SWEEK,AX			; 翌月の最初の曜日
	RET
FEND	WIDCLEN_NXT_E


; ****************************************************
;	WINDOWS/カレンダー・今月の計算
;	-O- AX : 月末の日
;	    BX : 翌日の日付
;	    CX : 翌日の曜日
;	    DX : 0=通常,1=一番最初の日,2=運命の日,3=一番最後の月
;		 4=１月前,5=２月前,6=３月前
; ****************************************************

FUNC	WIDCLEN_NOW_E
	MOV	CX,VAL_YEAR			; 年
	MOV	BX,VAL_MONTH			; 月
	CALL	MATSUJITSU			; 末日計算
	MOV	AX,DX				; 月末の日

	MOV	BX,VAL_DAY			; 日
	INC	BX				;
	CMP	BX,AX				; 月末の日
	JBE	WIDCLEN_NOW_E_3			;
	MOV	BX,1				;
WIDCLEN_NOW_E_3:

	MOV	CX,VAL_WEEK			; 曜日
	INC	CX				;
	CMP	CX,6				; 6=（土）Saturday
	JBE	WIDCLEN_NOW_E_5			;
	MOV	CX,0				; 0=（日）Sunday
WIDCLEN_NOW_E_5:
	PUSH	AX
	PUSH	BX
	PUSH	CX
	CALL	SPECIAL_DAY_CHK			; 特別な日チェック
	MOV	DX,AX
	POP	CX
	POP	BX
	POP	AX
	RET
FEND	WIDCLEN_NOW_E


; ****************************************************
;	WINDOWS/カレンダー・年齢の計算
;	-I- BORTH_YEAR : 誕生日の年
;	    BORTH_MONTH: 誕生日の月
;	    BORTH_DAY  : 誕生日の日
;	-O- DX : 年齢
; ****************************************************

FUNC	WIDCLEN_AGE
	CALL	YOURAGE			; 年齢の計算
	RET
FEND	WIDCLEN_AGE


; ****************************************************
;	WINDOWS/カレンダー・初期ｾｯﾄｱｯﾌﾟ
; ****************************************************

FUNC	WIDCLEN_SETUP_INI
	CALL	WEEK_CHK		; 曜日の計算
	CALL	CHK_SEASON		; 季節のチェック
	RET
FEND	WIDCLEN_SETUP_INI


; ****************************************************
;	WINDOWS/カレンダー・セットアップ
;	-I- AX : ウインドウ表示位置Ｘ
;	    BX : ウインドウ表示位置Ｙ
; ****************************************************

FUNC	WIDCLEN_SETUP
	CALL_w	PT_CLEND_LOC		; calendar locate.
	CALL	WEEK_CHK		; 曜日の計算
	CALL	CHK_SEASON		; 季節のチェック
	RET
FEND	WIDCLEN_SETUP


; ****************************************************
;	WINDOWS/カレンダー・月データ
;	-I- AX : 年
;	    BX : 月
;	-O- CX : 月末の日
;	    DX : 曜日
; ****************************************************

FUNC	WIDCLEN_MONTH
	PUSH	VAL_YEAR		; 年
	PUSH	VAL_MONTH		; 月
	PUSH	VAL_WEEK		; 曜日
	PUSH	VAL_DAY			; 日
	PUSH	VAL_A_DAY		; 年内合計日付
	PUSH	VAL_M_END		; 月末の日

	MOV	VAL_YEAR,AX		; 年
	MOV	VAL_MONTH,BX		; 月
	MOV	VAL_DAY,1		; 日

	MOV	CX,VAL_YEAR		; 年
	MOV	BX,VAL_MONTH		; 月
	CALL	MATSUJITSU		; 末日計算
	MOV	VAL_M_END,DX		; 月末の日

	CALL	WEEK_CHK		; 曜日の計算

	MOV	CX,VAL_M_END		; 月末の日
	MOV	DX,VAL_WEEK		; 曜日

	POP	VAL_M_END		; 月末の日
	POP	VAL_A_DAY		; 年内合計日付
	POP	VAL_DAY			; 日
	POP	VAL_WEEK		; 曜日
	POP	VAL_MONTH		; 月
	POP	VAL_YEAR		; 年
	RET
FEND	WIDCLEN_MONTH


; ****************************************************
;	カレンダー・ＯＰＥＮ
; ****************************************************

WIDCLEN_OPEN	PROC	NEAR
	CALL_w	PT_CLEND_FRM		; calendar fream.
	RET
WIDCLEN_OPEN	ENDP


; ****************************************************
;	カレンダー・ＣＬＯＳＥ
; ****************************************************

WIDCLEN_CLOSE	PROC	NEAR
	RET
WIDCLEN_CLOSE	ENDP


; ****************************************************
;	年齢の計算
;	-I- BORTH_YEAR : 誕生日の年
;	    BORTH_MONTH: 誕生日の月
;	    BORTH_DAY  : 誕生日の日
;	-O- DX      : 年齢
; ****************************************************

YOURAGE		PROC	NEAR
	CMPX	BORTH_YEAR,VAL_YEAR	; 誕生日の年が今年ならば０才
	JE	YOURAGE_ZERO		;
	JNB	YOURAGE_ZERO		; 未来人ならば０才

	MOV	DX,VAL_YEAR		; 何年＝今年－誕生日の年－１
	SUB	DX,BORTH_YEAR		;
	DEC	DX			;
	MOV	HOW_LONG_YEAR,DX	;

	CMPX	VAL_MONTH,BORTH_MONTH	; 今月が誕生日の月の
	JB	YOURAGE_SET		; 前ならばそのまま
	JNBE	YOURAGE_INC		; 後ならば１才歳上

	CMPX	VAL_DAY,BORTH_DAY	; 今日が誕生日の
	JB	YOURAGE_SET		; 前ならばそのまま
YOURAGE_INC:
	INC	HOW_LONG_YEAR		;
YOURAGE_SET:
	MOV	DX,HOW_LONG_YEAR	;
;*;PRV "VAL_YEAR=",VAL_YEAR
;*;PRV "VAL_MONTH=",VAL_MONTH
;*;PRV "VAL_WEEK=",VAL_WEEK
;*;PRV "VAL_DAY=",VAL_DAY
;*;PRV "BORTH_YEAR=",BORTH_YEAR
;*;PRV "BORTH_MONTH=",BORTH_MONTH
;*;PRV "BORTH_DAY=",BORTH_DAY
;*;PRV "AGE=",DX
	RET
YOURAGE_ZERO:
	MOV	DX,0			; ０才
	RET
YOURAGE		ENDP


; ****************************************************
;	日付の更新
;	-I/O- VAL_YEAR     : 年
;	      VAL_MONTH    : 月
;	      VAL_WEEK     : 曜日
;	      VAL_DAY      : 日
;	-O-   VAL_M_END    : 月末の日
; ****************************************************

UPDATE_SET	PROC	NEAR
	MOV	AX,VAL_YEAR		; 年
	CALL	URUU_CHK		; うるう年チェック
	CMP	AX,1			; 1=うるう年
	JNE	UPDATE_SET_NORMAL	;

	CMP	VAL_MONTH,2		; ２月？
	JNE	UPDATE_SET_NORMAL	;
	CMP	VAL_DAY,28		; ２８日？
	JNE	UPDATE_SET_NORMAL	;

	INC	VAL_DAY			; 日の更新

	JMP	UPDATE_SET_M

UPDATE_SET_NORMAL:
	INC	VAL_DAY				; 日の更新

	MOV	BX,VAL_MONTH			; 月
	DEC	BX				;
	MOV	AH,0				;
	MOV	AL,DS:MONTH_CNT[BX]		; 月毎の最高日付
	CMP	VAL_DAY,AX			; 日は最高日付を越えてない？
	JG	UPDATE_SET_NEXT_M		;
	JL	UPDATE_SET_M			;

;*;	CALL_w	PCALC_M_BORN			; 月次成長処理

	JMP	UPDATE_SET_M			;
UPDATE_SET_NEXT_M:
	MOV	VAL_DAY,1			; １日
	INC	VAL_MONTH			; 月の更新
	CMP	VAL_MONTH,12			; 月
	JLE	UPDATE_SET_M			;

	MOV	VAL_MONTH,1			; 正月

	INC	VAL_YEAR			; 年の更新

UPDATE_SET_M:
	CALL	WEEK_CHK			; 曜日の計算

	MOV	CX,VAL_YEAR			; 年
	MOV	BX,VAL_MONTH			; 月
	CALL	MATSUJITSU			; 末日計算
	MOV	VAL_M_END,DX			; 月末の日

	RET
UPDATE_SET	ENDP


; ****************************************************
;	末日計算
;	-I- BX : (now)月
;	    CX : 年
;	-O- DX : 末日
; ****************************************************

MATSUJITSU	PROC	NEAR
	MOV	DH,0				;
	MOV	DL,DS:MONTH_CNT[BX][-1]		; 月毎の最高日付

	CMP	BX,2				; 月
	JNE	MATSUJITSU_5			;

	MOV	AX,CX				; 年
	CALL	URUU_CHK			; うるう年チェック
	CMP	AX,1				; 0=普通の年,1=うるう年
	JNE	MATSUJITSU_4			;
	MOV	DX,29				;
	JMP	MATSUJITSU_5			;
MATSUJITSU_4:					;
	MOV	DX,28				;
MATSUJITSU_5:					;
	RET
MATSUJITSU	ENDP


; ****************************************************
;	季節のチェック
;	-I- VAL_YEAR     : 年
;	    VAL_MONTH    : 月
;	    VAL_WEEK     : 曜日
;	    VAL_DAY      : 日
;	-O- TM_SEASON    : 季節
;	    FLG_SHOGATSU : フラグ・正月
;	    FLG_URUBI    : フラグ・うるう日
;	    FLG_CHRISTMAS_EVE : フラグ・クリスマスイブ
;	    FLG_HOLIDAY  : フラグ・休日
;	    FLG_SYUKAKU  : フラグ・収穫祭の準備
; ****************************************************

CHK_SEASON	PROC	NEAR
	MOV	FLG_SHOGATSU,0		; フラグ・正月
	MOV	FLG_URUBI,0		; フラグ・うるう日
	MOV	FLG_G_BORTH,0		; フラグ・娘の誕生日
	MOV	FLG_M_BORTH,0		; フラグ・私の誕生日
	MOV	FLG_CHRISTMAS_EVE,0	; フラグ・クリスマスイブ
	MOV	FLG_HOLIDAY,0		; フラグ・休日
	MOV	FLG_SYUKAKU,0		; フラグ・収穫祭の準備

	CMP	VAL_WEEK,0		; （日）Sunday
	JNE	CHK_SEASON_SUN		;
	MOV	FLG_HOLIDAY,1		; フラグ・休日
CHK_SEASON_SUN:

	CALL	ALL_DAY			; 年内合計日付

	MOV	AX,VAL_YEAR		; 年
	CALL	URUU_CHK		; うるう年チェック
	CMP	AX,1			; 1=うるう年
	JMPEQ	CHK_SEASON_URU		;

	CMPX	VAL_A_DAY,STEP_SEASON[0] ; 冬 1-2
	JG	CHK_SEASON_11		;
	MOV	TM_SEASON,4		; 季節 4:冬
	JMP	CHK_SEASON_15		;
CHK_SEASON_11:				;
	CMPX	VAL_A_DAY,STEP_SEASON[2] ; 春 3-5
	JG	CHK_SEASON_12		;
	MOV	TM_SEASON,1		; 季節 1:春
	JMP	CHK_SEASON_15		;
CHK_SEASON_12:				;
	CMPX	VAL_A_DAY,STEP_SEASON[4] ; 夏 6-8
	JG	CHK_SEASON_13		;
	MOV	TM_SEASON,2		; 季節 2:夏
	JMP	CHK_SEASON_15		;
CHK_SEASON_13:				;
	CMPX	VAL_A_DAY,STEP_SEASON[6] ; 秋 9-11
	JG	CHK_SEASON_14		;
	MOV	TM_SEASON,3		; 季節 3:秋
	JMP	CHK_SEASON_15		;
CHK_SEASON_14:				;
	MOV	TM_SEASON,4		; 季節 4:冬
CHK_SEASON_15:				;

	JMP	CHK_SEASON_SKIP		;

CHK_SEASON_URU:
	CMPX	VAL_A_DAY,STEP_SEASON_URU[0] ; 冬 1-2
	JG	CHK_SEASON_21		;
	MOV	TM_SEASON,4		; 季節 4:冬
	JMP	CHK_SEASON_25		;
CHK_SEASON_21:				;
	CMPX	VAL_A_DAY,STEP_SEASON_URU[2] ; 春 3-5
	JG	CHK_SEASON_22		;
	MOV	TM_SEASON,1		; 季節 1:春
	JMP	CHK_SEASON_25		;
CHK_SEASON_22:				;
	CMPX	VAL_A_DAY,STEP_SEASON_URU[4] ; 夏 6-8
	JG	CHK_SEASON_23		;
	MOV	TM_SEASON,2		; 季節 2:夏
	JMP	CHK_SEASON_25		;
CHK_SEASON_23:				;
	CMPX	VAL_A_DAY,STEP_SEASON_URU[6] ; 秋 9-11
	JG	CHK_SEASON_24		;
	MOV	TM_SEASON,3		; 季節 3:秋
	JMP	CHK_SEASON_25		;
CHK_SEASON_24:				;
	MOV	TM_SEASON,4		; 季節 4:冬
CHK_SEASON_25:				;

CHK_SEASON_SKIP:			;

	CMP	VAL_MONTH,2		; 月
	JNE	CHK_SEASON_U		;

	CMP	VAL_DAY,29		; 日
	JNE	CHK_SEASON_U		;

	MOV	FLG_URUBI,1		; フラグ・うるう日
CHK_SEASON_U:				;

	CMP	VAL_MONTH,12		; 月
	JNE	CHK_SEASON_C		;
	CMP	VAL_DAY,24		; 日
	JNE	CHK_SEASON_C		;
	MOV	FLG_CHRISTMAS_EVE,1	; フラグ・クリスマスイブ
	MOV	FLG_HOLIDAY,1		; フラグ・休日
CHK_SEASON_C:				;

	CMP	VAL_MONTH,1		; 月
	JNE	CHK_SEASON_S		;
	CMP	VAL_DAY,1		; 日
	JNE	CHK_SEASON_S		;
	MOV	FLG_SHOGATSU,1		; フラグ・正月
	MOV	FLG_HOLIDAY,1		; フラグ・休日
CHK_SEASON_S:				;

	CMP	VAL_MONTH,10-1		; 月（収穫祭は１０月）
	JNE	CHK_SEASON_41		;
	CMP	VAL_DAY,21		; 日（収穫祭１０日前）
	JL	CHK_SEASON_41		;

	MOV	FLG_SYUKAKU,1		; フラグ・収穫祭の準備

CHK_SEASON_41:				;

	RET
CHK_SEASON	ENDP


; ****************************************************
;	曜日の計算
;	-I- VAL_YEAR   : 年
;	    VAL_MONTH  : 月
;	    VAL_DAY    : 日
;	-O- VAL_WEEK   : 曜日
; ****************************************************

WEEK_CHK	PROC	NEAR
	CALL	ALL_DAY			; 年内合計日付

					; １年毎に１つ曜日が進む
					; うるう年には２つ曜日が進む
					; １００年に１度、うるう年を省く
					; ４００年に１度、うるう年省くのやめ

	MOV	AX,VAL_YEAR		; 年を４で割る
	DEC	AX			; (今年は抜き)
	MOV	DX,0			;
	MOV	BX,4			;
	DIV	BX			; AX = AX / BX : DX = AX mod BX
	MOV	URU_COUNT,AX		; うるう年の進む曜日

	MOV	AX,VAL_YEAR		; 年を１００で割る
	DEC	AX			; (今年は抜き)
	MOV	DX,0			;
	MOV	BX,100			;
	DIV	BX			; AX = AX / BX : DX = AX mod BX
	SUB	URU_COUNT,AX		; １００年に１度、うるう年を省く

	MOV	AX,VAL_YEAR		; 年を４００で割る
	DEC	AX			; (今年は抜き)
	MOV	DX,0			;
	MOV	BX,400			;
	DIV	BX			; AX = AX / BX : DX = AX mod BX
	ADD	URU_COUNT,AX		; ４００年に１度、うるう年省くのやめ

	MOV	AX,URU_COUNT		; うるう年の進む曜日
	ADD	AX,VAL_YEAR		; 年を加算（１年毎に１つ曜日が進む）
	DEC	AX			; (今年は抜き)
	ADD	AX,VAL_A_DAY		; 年内合計日付

	MOV	BX,7			; 何曜日か？
	MOV	DX,0			;
	DIV	BX			; AX = AX / BX : DX = AX mod BX
	MOV	VAL_WEEK,DX		; 曜日

	RET
WEEK_CHK	ENDP


; ****************************************************
;	年内合計日付
;	-I- VAL_YEAR   : 年
;	    VAL_MONTH  : 月
;	    VAL_DAY    : 日
;	-O- VAL_A_DAY  : 年内合計日付
; ****************************************************

ALL_DAY	PROC	NEAR
	MOVX	VAL_A_DAY,VAL_DAY	; 年内合計日付
	MOV	BX,0			; byte pointer.
	MOV	CX,VAL_MONTH		; 月
	DEC	CX
	JCXZ	ALL_DAY_LOOP_END	;
ALL_DAY_LOOP:
	MOV	AL,DS:MONTH_CNT[BX]	; 月毎の最高日付
	MOV	AH,0			;
	ADD	VAL_A_DAY,AX		; 年内合計日付
	INC	BX			; byte pointer.
	LOOP	ALL_DAY_LOOP		;
ALL_DAY_LOOP_END:

	MOV	AX,VAL_YEAR		; 年
	CALL	URUU_CHK		; うるう年チェック
	CMP	AX,1			; 1=うるう年
	JNE	ALL_DAY_URU		;

	CMP	VAL_MONTH,2		; 月
	JLE	ALL_DAY_URU		;

	INC	VAL_A_DAY		; 年内合計日付＋１
ALL_DAY_URU:				;
	RET
ALL_DAY	ENDP


; ****************************************************
;	うるう年チェック
;	-I- AX : 年
;	-O- AX : 0=普通の年,1=うるう年
; ****************************************************

URUU_CHK	PROC	NEAR
					; １年毎に１つ曜日が進む
					; うるう年には２つ曜日が進む
					; １００年に１度、うるう年を省く
					; ４００年に１度、うるう年省くのやめ

	MOV	AX,VAL_YEAR		; 年を４００で割る
	DEC	AX			; (今年は抜き)
	MOV	DX,0			;
	MOV	BX,400			;
	DIV	BX			; AX = AX / BX : DX = AX mod BX
	CMP	DX,0			; ４００年に１度、うるう年省くのやめ
	JE	URUU_CHK_AX_URU		;

	MOV	AX,VAL_YEAR		; 年を１００で割る
	DEC	AX			; (今年は抜き)
	MOV	DX,0			;
	MOV	BX,100			;
	DIV	BX			; AX = AX / BX : DX = AX mod BX
	CMP	DX,0			; １００年に１度、うるう年を省く
	JE	URUU_CHK_AX_STD		;

	MOV	AX,VAL_YEAR		;
	MOV	DX,0			;
	MOV	BX,4			;
	DIV	BX			; AX = AX / BX : DX = AX mod BX
	CMP	DX,0			;
	JE	URUU_CHK_AX_URU		; ４年目ならば、うるう年

URUU_CHK_AX_STD:
	MOV	AX,0			; 0=普通の年
	RET
URUU_CHK_AX_URU:
	MOV	AX,1			; 1=うるう年
	RET
URUU_CHK	ENDP


; ****************************************************
;	星座チェック
;	-I- DX : うまれ月
;	    AX : うまれ日
;	-O- DX : 星座
;		 1=白羊宮 火星
;		 2=金牛宮 金星
;		 3=双児宮 水星
;		 4=巨蟹宮 月
;		 5=獅子宮 太陽
;		 6=処女宮 水星
;		 7=天秤宮 金星
;		 8=天蠍宮 冥王星
;		 9=人馬宮 木星
;		10=磨羯宮 土星
;		11=宝瓶宮 天王星
;		12=双魚宮 海王星
;
;		☆誕生日と星座・守護星の関係
;		誕生日－－－－－－－－－子宮名－守護星－－－
;		 1=　３／２１～　４／１９ 白羊宮 火星
;		 2=　４／２０～　５／２０ 金牛宮 金星
;		 3=　５／２１～　６／２１ 双児宮 水星
;		 4=　６／２２～　７／２２ 巨蟹宮 月
;		 5=　７／２３～　８／２２ 獅子宮 太陽
;		 6=　８／２３～　９／２２ 処女宮 水星
;		 7=　９／２３～１０／２３ 天秤宮 金星
;		 8=１０／２４～１１／２２ 天蠍宮 冥王星
;		 9=１１／２３～１２／２１ 人馬宮 木星
;		10=１２／２２～　１／１９ 磨羯宮 土星
;		11=　１／２０～　２／１８ 宝瓶宮 天王星
;		12=　２／１９～　３／２０ 双魚宮 海王星
; ****************************************************

WID_CONSTELLATION	PROC	NEAR
	MOV	BX,DX
	DEC	BX
	CMP	BX,12
	JB	WID_CONSTELLATION_1
	MOV	BX,0
WID_CONSTELLATION_1:
	SHL	BX,1
	MOVX	ES,<SEG WINDOW>
	JMP	WORD PTR ES:WID_CONSTELLATION_JMP[BX]
WID_CONSTELLATION_JMP	LABEL	WORD
	DW	WID_CONSTE_JANUARY
	DW	WID_CONSTE_FEBRUARY
	DW	WID_CONSTE_MARCH
	DW	WID_CONSTE_APRIL
	DW	WID_CONSTE_MAY
	DW	WID_CONSTE_JUNE
	DW	WID_CONSTE_JULY
	DW	WID_CONSTE_AUGUST
	DW	WID_CONSTE_SEPTEMBER
	DW	WID_CONSTE_OCTOBER
	DW	WID_CONSTE_NOVEMBER
	DW	WID_CONSTE_DECEMBER
WID_CONSTE_JANUARY:
	CMP	AX,20
	JLE	WID_CONSTE_YAGI
	JMP	WID_CONSTE_MIZUGAME
WID_CONSTE_FEBRUARY:
	CMP	AX,19
	JLE	WID_CONSTE_MIZUGAME
	JMP	WID_CONSTE_UO
WID_CONSTE_MARCH:
	CMP	AX,21
	JLE	WID_CONSTE_UO
	JMP	WID_CONSTE_OHITSUJI
WID_CONSTE_APRIL:
	CMP	AX,20
	JLE	WID_CONSTE_OHITSUJI
	JMP	WID_CONSTE_OUSHI
WID_CONSTE_MAY:
	CMP	AX,21
	JLE	WID_CONSTE_OUSHI
	JMP	WID_CONSTE_FUTAGO
WID_CONSTE_JUNE:
	CMP	AX,22
	JLE	WID_CONSTE_FUTAGO
	JMP	WID_CONSTE_KANI
WID_CONSTE_JULY:
	CMP	AX,23
	JLE	WID_CONSTE_KANI
	JMP	WID_CONSTE_SHISHI
WID_CONSTE_AUGUST:
	CMP	AX,23
	JLE	WID_CONSTE_SHISHI
	JMP	WID_CONSTE_OTOME
WID_CONSTE_SEPTEMBER:
	CMP	AX,23
	JLE	WID_CONSTE_OTOME
	JMP	WID_CONSTE_TENBIN
WID_CONSTE_OCTOBER:
	CMP	AX,24
	JLE	WID_CONSTE_TENBIN
	JMP	WID_CONSTE_SASORI
WID_CONSTE_NOVEMBER:
	CMP	AX,23
	JLE	WID_CONSTE_SASORI
	JMP	WID_CONSTE_ITE
WID_CONSTE_DECEMBER:
	CMP	AX,22
	JLE	WID_CONSTE_ITE
	JMP	WID_CONSTE_YAGI

WID_CONSTE_OHITSUJI:
	MOV	DX,1		; 1= 白羊宮 火星
	RET
WID_CONSTE_OUSHI:
	MOV	DX,2		; 2= 金牛宮 金星
	RET
WID_CONSTE_FUTAGO:
	MOV	DX,3		; 3= 双児宮 水星
	RET
WID_CONSTE_KANI:
	MOV	DX,4		; 4= 巨蟹宮 月
	RET
WID_CONSTE_SHISHI:
	MOV	DX,5		; 5= 獅子宮 太陽
	RET
WID_CONSTE_OTOME:
	MOV	DX,6		; 6= 処女宮 水星
	RET
WID_CONSTE_TENBIN:
	MOV	DX,7		; 7= 天秤宮 金星
	RET
WID_CONSTE_SASORI:
	MOV	DX,8		; 8= 天蠍宮 冥王星
	RET
WID_CONSTE_ITE:
	MOV	DX,9		; 9= 人馬宮 木星
	RET
WID_CONSTE_YAGI:
	MOV	DX,10		; 10= 磨羯宮 土星
	RET
WID_CONSTE_MIZUGAME:
	MOV	DX,11		; 11= 宝瓶宮 天王星
	RET
WID_CONSTE_UO:
	MOV	DX,12		; 12= 双魚宮 海王星
	RET
WID_CONSTELLATION	ENDP


; ****************************************************
;	カレンダー表示
;	-I- VAL_YEAR   : 年
;	    VAL_MONTH  : 月
;	    VAL_WEEK   : 曜日
;	    VAL_DAY   : 日
;	    TM_SEASON  : 季節
; ****************************************************

WIDCLEN_DISP	PROC	NEAR
	MOV	AX,GR_TXTSIZE		; 文字表示サイズ
	CALL_w	VTXSIZ			; character size set.
	MOV	AX,GR_TXTCOLOR		; 文字表示色
	CALL_w	VTXCOL			; character color set.

	CALL	WID_DSP_YEAR		; 年の表示
	CALL	WID_DSP_MONTH		; 月の表示
	CALL	WID_DSP_WEEK		; 曜日の表示
	CALL	WID_DSP_DAY		; 日の表示
;*;	CALL	WID_DSP_SEASON		; 季節の表示
	RET
WIDCLEN_DISP	ENDP


; ****************************************************
;	年の表示
;	-I- VAL_YEAR : 年
; ****************************************************

WID_DSP_YEAR	PROC	NEAR
	MOV	DX,VAL_YEAR		; 年
	CALL_w	PT_CLEND_YEAR		; calendar year.
	RET
WID_DSP_YEAR	ENDP


; ****************************************************
;	月の表示
;	-I- VAL_MONTH : 月
; ****************************************************

WID_DSP_MONTH	PROC	NEAR
	MOV	DX,VAL_MONTH		; 月
	CALL_w	PT_CLEND_MONTH		; calendar month.
	RET
WID_DSP_MONTH	ENDP


; ****************************************************
;	曜日の表示
;	-I- VAL_WEEK : 曜日
; ****************************************************

WID_DSP_WEEK	PROC	NEAR
	MOV	DX,VAL_WEEK		; 曜日
	CALL_w	PT_CLEND_WEEK		; calendar week.
	RET
WID_DSP_WEEK	ENDP


; ****************************************************
;	日の表示
;	-I- VAL_DAY : 日
; ****************************************************

WID_DSP_DAY	PROC	NEAR
	MOV	DX,VAL_DAY		; 日
	CALL_w	PT_CLEND_DAY		; calendar day.
	RET
WID_DSP_DAY	ENDP


;*;; ****************************************************
;*;;	季節の表示
;*;;	-I- TM_SEASON  : 季節
;*;; ****************************************************
;*;
;*;WID_DSP_SEASON	PROC	NEAR
;*;	MOV	AX,DSP_WID_X		; ウインドウ表示位置Ｘ
;*;	MOV	BX,DSP_WID_Y		; ウインドウ表示位置Ｙ
;*;	ADD	AX,D_SEASON_X		; 季節・表示位置Ｘ
;*;	ADD	BX,D_SEASON_Y		; 季節・表示位置Ｙ
;*;	MOV	XX1,AX			; Ｘ座標
;*;	MOV	YY1,BX			; Ｙ座標
;*;
;*;	MOV	DI,TM_SEASON		; 季節
;*;	DEC	DI			;
;*;	SHL	DI,1			; word pointer.
;*;	MOV	SI,NAME_SEASON[DI]	;
;*;	CALL_w	VTXPOR			; vram text print OR.
;*;	RET
;*;WID_DSP_SEASON	ENDP



; ****************************************************
;	日次チェック
;	-I-   P_BORTHDAY   : 誕生日
;	      P_BORTHMONTH : 誕生月
;	      P_BORTHYEAR  : 誕生年
;	-I/O- P_NENREI     : 年齢
;	-O-   FLG_G_BORTH  : フラグ・娘の誕生日
;	      FLG_M_BORTH  : フラグ・私の誕生日
; ****************************************************

DAILY_CHECK	PROC	NEAR
	MOV	FLG_G_BORTH,0		; フラグ・娘の誕生日
	MOV	FLG_M_BORTH,0		; フラグ・私の誕生日

	CMPX	VAL_DAY,P_BORTHDAY	; 誕生日
	JNE	DAILY_CHECK_4		;
	CMPX	VAL_MONTH,P_BORTHMONTH	; 誕生月
	JNE	DAILY_CHECK_4		;

	MOVX	BORTH_YEAR,P_BORTHDAY	; 誕生日
	MOVX	BORTH_MONTH,P_BORTHMONTH ; 誕生月
	MOVX	BORTH_DAY,P_BORTHYEAR	; 誕生年
	CALL	YOURAGE			; 年齢の計算
	MOV	P_NENREI,DX		; 年齢

	CALL_w	PCALC_BORTHDAY		; 誕生日成長処理

	MOV	FLG_G_BORTH,1		; フラグ・娘の誕生日
DAILY_CHECK_4:

	CMPX	VAL_MONTH,P_BORTHDAY[2]	; 誕生日
	JNE	DAILY_CHECK_6		;
	CMPX	VAL_DAY,P_BORTHMONTH[2]	; 誕生月
	JNE	DAILY_CHECK_6		;

	MOVX	BORTH_YEAR,P_BORTHDAY[2] ; 誕生日
	MOVX	BORTH_MONTH,P_BORTHMONTH[2] ; 誕生月
	MOVX	BORTH_DAY,P_BORTHYEAR[2] ; 誕生年
	CALL	YOURAGE			; 年齢の計算
	MOV	P_NENREI[2],DX		; 年齢
	MOV	FLG_M_BORTH,1		; フラグ・私の誕生日
DAILY_CHECK_6:

	RET
DAILY_CHECK	ENDP


; ****************************************************
;	特別な日チェック
;	-O- AX : 0=通常,1=一番最初の日,2=運命の日,3=一番最後の月
;		 4=１月前,5=２月前,6=３月前
; ****************************************************

SPECIAL_DAY_CHK	PROC	NEAR
	CMP	P_NENREI,10		; 年齢
	JNE	SPECIAL_DAY_CHK_4	;
	CMPX	VAL_MONTH,P_BORTHMONTH	; 誕生月
	JNE	SPECIAL_DAY_CHK_4	;
	CMPX	VAL_DAY,P_BORTHDAY	; 誕生日
	JNE	SPECIAL_DAY_CHK_4	;

	JMP	SPECIAL_DAY_CHK_1ST_DAY

SPECIAL_DAY_CHK_4:
	CMP	P_NENREI,18		; 年齢
	JGE	SPECIAL_DAY_CHK_LASTDAY	;

	CMP	P_NENREI,17		; 年齢
	JL	SPECIAL_DAY_CHK_NORMAL	;

	MOV	AX,P_BORTHMONTH		; 誕生月
	CALL	BACK_MONTH		; 先月
	CMP	AX,VAL_MONTH		;
	JE	SPECIAL_DAY_CHK_LAST_M	;

	CALL	BACK_MONTH		; 先月
	CMP	AX,VAL_MONTH		;
	JE	SPECIAL_DAY_CHK_BACK_1M	;
	CALL	BACK_MONTH		; 先月
	CMP	AX,VAL_MONTH		;
	JE	SPECIAL_DAY_CHK_BACK_2M	;
	CALL	BACK_MONTH		; 先月
	CMP	AX,VAL_MONTH		;
	JE	SPECIAL_DAY_CHK_BACK_3M	;

SPECIAL_DAY_CHK_NORMAL:
	MOV	AX,0			; 0=通常
	RET
SPECIAL_DAY_CHK_1ST_DAY:
	MOV	AX,1			; 1=一番最初の日
	RET
SPECIAL_DAY_CHK_LASTDAY:
	MOV	AX,2			; 2=運命の日
	RET
SPECIAL_DAY_CHK_LAST_M:
	MOV	AX,3			; 3=一番最後の月
	RET
SPECIAL_DAY_CHK_BACK_1M:
	MOV	AX,4			; 4=１月前
	RET
SPECIAL_DAY_CHK_BACK_2M:
	MOV	AX,5			; 5=２月前
	RET
SPECIAL_DAY_CHK_BACK_3M:
	MOV	AX,6			; 6=３月前
	RET
SPECIAL_DAY_CHK	ENDP


;	先月
;	-I/O- AX : 月

BACK_MONTH	PROC	NEAR
	DEC	AX
	CMP	AX,0
	JNE	BACK_MONTH_5
	MOV	AX,12
BACK_MONTH_5:
	RET
BACK_MONTH	ENDP

WINDOW	ENDS



DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	BORTH_YEAR			; 誕生日の年
PUBLIC	BORTH_MONTH			; 誕生日の月
PUBLIC	BORTH_DAY			; 誕生日の日

PUBLIC	NEXT_M_YEAR			; 翌月の年
PUBLIC	NEXT_M_MONTH			; 翌月の月
PUBLIC	NEXT_M_ENDDAY			; 翌月の末日
PUBLIC	NEXT_M_SWEEK			; 翌月の最初の曜日

EXTRN	P_NENREI:WORD			; 年齢
EXTRN	P_BORTHDAY:WORD			; 誕生日
EXTRN	P_BORTHMONTH:WORD		; 誕生月
EXTRN	P_BORTHYEAR:WORD		; 誕生年

EXTRN	VAL_YEAR:WORD			; 年
EXTRN	VAL_MONTH:WORD			; 月
EXTRN	VAL_WEEK:WORD			; 曜日
EXTRN	VAL_DAY:WORD			; 日
EXTRN	VAL_A_DAY:WORD			; 年内合計日付
EXTRN	VAL_M_END:WORD			; 月末の日
EXTRN	TM_SEASON:WORD			; 季節（1:春,2:夏,3:秋,4:冬）
EXTRN	FLG_SHOGATSU:WORD		; フラグ・正月
EXTRN	FLG_URUBI:WORD			; フラグ・うるう日
EXTRN	FLG_CHRISTMAS_EVE:WORD 		; フラグ・クリスマスイブ
EXTRN	FLG_G_BORTH:WORD		; フラグ・娘の誕生日
EXTRN	FLG_M_BORTH:WORD		; フラグ・私の誕生日
EXTRN	FLG_HOLIDAY:WORD		; フラグ・休日
EXTRN	FLG_SYUKAKU:WORD		; フラグ・収穫祭の準備

DSP_WID_X	DW	0		; ウインドウ表示位置Ｘ
DSP_WID_Y	DW	0		; ウインドウ表示位置Ｙ

D_SEASON_X	DW	1		; 季節・表示位置Ｘ
D_SEASON_Y	DW	-12+2*8		; 季節・表示位置Ｙ

GR_TXTSIZE	DW	0		; 文字表示サイズ
GR_TXTCOLOR	DW	15		; 文字表示色

XX1		DW	0		; Ｘ座標
YY1		DW	0		; Ｙ座標

;	現在時間
;	年	: １から６００００まで
;	月	: １から１２まで
;	日	: １から３１まで
;	曜日	: 
;	時	: 
;	分	: 
;	秒	: 
;	うるう年
;	１年から４年ごとに２月２９日がある

BORTH_YEAR	DW	0		; 誕生日の年
BORTH_MONTH	DW	8		; 誕生日の月
BORTH_DAY	DW	15		; 誕生日の日

NEXT_M_YEAR	DW	0		; 翌月の年
NEXT_M_MONTH	DW	0		; 翌月の月
NEXT_M_ENDDAY	DW	0		; 翌月の末日
NEXT_M_SWEEK	DW	0		; 翌月の最初の曜日

HOW_LONG_YEAR	DW	15		; 何年

URU_COUNT	DW	0		; うるうカウンタ

MONTH_CNT	LABEL	BYTE		; 月毎の最高日付
	DB	31	;1
	DB	28	;2
	DB	31	;3
	DB	30	;4
	DB	31	;5
	DB	30	;6
	DB	31	;7
	DB	31	;8
	DB	30	;9
	DB	31	;10
	DB	30	;11
	DB	31	;12

;*;;	princess 1.
;*;
;*;STEP_SEASON	LABEL	WORD
;*;	DW	31+28	+6	;(１週間ずらす)	; 冬 1-2
;*;	DW	31+28+31+30+31	-6		; 春 3-5
;*;	DW	31+28+31+30+31+30+31+31		; 夏 6-8
;*;	DW	31+28+31+30+31+30+31+31+30+31	; 秋 9-10
;*;
;*;STEP_SEASON_URU	LABEL	WORD
;*;	DW	31+29	+6	;(１週間ずらす)	; 冬 1-2
;*;	DW	31+29+31+30+31	-6		; 春 3-5
;*;	DW	31+29+31+30+31+30+31+31 	; 夏 6-8
;*;	DW	31+29+31+30+31+30+31+31+30+31	; 秋 9-10

;	princess 2.

STEP_SEASON	LABEL	WORD
	DW	31+28					; 冬 1-2
	DW	31+28+31+30+31				; 春 3-5
	DW	31+28+31+30+31+30+31+31			; 夏 6-8
	DW	31+28+31+30+31+30+31+31+30+31+30	; 秋 9-11

STEP_SEASON_URU	LABEL	WORD
	DW	31+29					; 冬 1-2
	DW	31+29+31+30+31				; 春 3-5
	DW	31+29+31+30+31+30+31+31 		; 夏 6-8
	DW	31+29+31+30+31+30+31+31+30+31+30	; 秋 9-11
		;1  2  3  4  5  6  7  8  9 10 11

;*;NAME_MONTH	LABEL	WORD
;*;	DW	NAME_M_1
;*;	DW	NAME_M_2
;*;	DW	NAME_M_3
;*;	DW	NAME_M_4
;*;	DW	NAME_M_5
;*;	DW	NAME_M_6
;*;	DW	NAME_M_7
;*;	DW	NAME_M_8
;*;	DW	NAME_M_9
;*;	DW	NAME_M_10
;*;	DW	NAME_M_11
;*;	DW	NAME_M_12
;*;NAME_M_1	DB	"JANUARY",0
;*;NAME_M_2	DB	"FEBRUARY",0
;*;NAME_M_3	DB	"MARCH",0
;*;NAME_M_4	DB	"APRIL",0
;*;NAME_M_5	DB	"MAY",0
;*;NAME_M_6	DB	"JUNE",0
;*;NAME_M_7	DB	"JULY",0
;*;NAME_M_8	DB	"AUGUST",0
;*;NAME_M_9	DB	"SEPTEMBER",0
;*;NAME_M_10	DB	"OCTOBER",0
;*;NAME_M_11	DB	"NOVEMBER",0
;*;NAME_M_12	DB	"DECEMBER",0
;*;
;*;NAME_WEEK	LABEL	WORD
;*;	DW	NAME_W_1
;*;	DW	NAME_W_2
;*;	DW	NAME_W_3
;*;	DW	NAME_W_4
;*;	DW	NAME_W_5
;*;	DW	NAME_W_6
;*;	DW	NAME_W_7
;*;NAME_W_1	DB	"Sunday",0
;*;NAME_W_2	DB	"Monday",0
;*;NAME_W_3	DB	"Tuesday",0
;*;NAME_W_4	DB	"Wednesday",0
;*;NAME_W_5	DB	"Thursday",0
;*;NAME_W_6	DB	"Friday",0
;*;NAME_W_7	DB	"Saturday",0
;*;
;*;NAME_SEASON	LABEL	WORD
;*;	DW	NAME_S_1
;*;	DW	NAME_S_2
;*;	DW	NAME_S_3
;*;	DW	NAME_S_4
;*;NAME_S_1	DB	"spring",0
;*;NAME_S_2	DB	"summer",0
;*;NAME_S_3	DB	"autumn",0
;*;NAME_S_4	DB	"winter",0

DATA	ENDS

	END
;
;	end of "WIDCLEND.ASM"
;
