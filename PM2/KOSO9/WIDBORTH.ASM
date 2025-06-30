; "WIDBORTH.ASM" PC-9801UV11 make by R.H 1991/04/18
;		modify486/50 make by R.H 1993/02/03
;
;
;	誕生日ウインドウ
;
;
;	WIDBORTH_SET			; WINDOWS/誕生日ウインドウ
;
;
;	設定されるﾊﾟﾗﾒｰﾀ
;
;	SET_YEAR	設定・年代
;	SET_MONTH	設定・月
;	SET_DAYS	設定・日
;
;
; (C) 1990,1991,1993 ritsurou hashimoto.

INCLUDE	TSTSET.INC

;	ＡＲＡＣＨＫ	＜Ｘmin＞，＜Ｙmin＞，
;				＜Ｘmax＞，＜Ｙmax＞，＜当たりラベル＞
;	入力	ＡＸ：Ｘ座標　，ＢＸ：Ｙ座標

ARACHK	MACRO	X1,Y1,X2,Y2,LBL
	LOCAL	L1
	CMP	AX,X1
	JB	L1
	CMP	AX,X2
	JNBE	L1
	CMP	BX,Y1
	JB	L1
	CMP	BX,Y2
	JNBE	L1
	JMP	LBL
L1:
	ENDM

OFFF		EQU	0FFFFH			; とりあえずＯＦＦという意味

;;CLEND_OFST_X	EQU	6			; 表示・カレンダーＸ開始位置
;;CLEND_OFST_Y	EQU	34			; 表示・カレンダーＹ開始位置
;;
;;CLEND_STEP_X	EQU	25			; 表示・カレンダーＸ間隔
;;CLEND_STEP_Y	EQU	88			; 表示・カレンダーＹ間隔

CLEND_OFST_X	EQU	6			; 表示・カレンダーＸ開始位置
CLEND_OFST_Y	EQU	34+8			; 表示・カレンダーＹ開始位置

CLEND_STEP_X	EQU	25			; 表示・カレンダーＸ間隔
CLEND_STEP_Y	EQU	88-2			; 表示・カレンダーＹ間隔

CLEND_HANI_X	EQU	20			; 表示・カレンダーＸ範囲
CLEND_HANI_Y	EQU	80			; 表示・カレンダーＹ範囲

CLEND_NARABI_X	EQU	3			; 表示・カレンダーＸ並び
CLEND_NARABI_Y	EQU	4			; 表示・カレンダーＹ並び

CLM_DAYS_MAX_X	EQU	7			; 表示・カレンダー日・数Ｘ
CLM_DAYS_MAX_Y	EQU	5			; 表示・カレンダー日・数Ｙ

OFS_HEAD_XX	EQU	-3			; 表示・カレンダーヘッダＸ
OFS_HEAD_YY	EQU	13			; 表示・カレンダーヘッダＹ

HIGHT_DAYS_STR	EQU	13			; 表示・カレンダー日・高さ
WIDTH_DAYS_STR	EQU	3			; 表示・カレンダー日・幅

HIGHT_HEAD_STR	EQU	13			; 表示・カレンダーヘッダ・高さ

CLM_CLND_CNT_X	EQU	7			; カレンダー並び数Ｘ
CLM_CLND_CNT_Y	EQU	6			; カレンダー並び数Ｙ

COLOR_MONTH	EQU	15			; 月色
COLOR_BLUEDAY	EQU	15			; 平日色
COLOR_HOLIDAY	EQU	13			; 休み色
COLOR_DATESET	EQU	15			; 日付色

BNK_RESTORE	EQU	13			; 待避バンク
						; #13(VVVRAM_TOP+60000)5,000

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
;	WINDOWS/誕生日ウインドウ
;	-I- AX : 入力モード1=父,2=娘
;	-O- AX : 0=通常,2=キャンセル
;	    SET_YEAR  : 年
;	    SET_MONTH : 月
;	    SET_DAYS  : 日
; ****************************************************

FUNC	WIDBORTH_SET
	MOV	INPUT_MODE,AX		; 入力モード1=父,2=娘

	CALL	BORTH_OPEN		; 誕生日ＯＰＥＮ

	CALL	BORTH_MAIN		; 誕生日ＭＡＩＮ
	CMP	AX,1			; 1=キャンセル
	JE	WIDBORTH_SET_CANCEL	;

	CALL	BORTH_CLOSE		; 誕生日ＣＬＯＳＥ

	MOV	AX,0			; 0=通常
	RET
WIDBORTH_SET_CANCEL:
	MOV	AX,2			; 2=キャンセル
	RET
FEND	WIDBORTH_SET



; ****************************************************
;	誕生日ＯＰＥＮ
;	-I- INPUT_MODE: 入力モード1=父,2=娘
; ****************************************************

BORTH_OPEN	PROC	NEAR
	MOV	FLAG_SAVE,0		; 退避フラグ
	MOV	OLD_CLNDXX,0		; カーソル前回Ｘ
	MOV	OLD_CLNDYY,0		; カーソル前回Ｙ
	MOV	OLD_BASEXX,0		; ベース前回Ｘ
	MOV	OLD_BASEYY,0		; ベース前回Ｙ

	CMP	INPUT_MODE,2		; 入力モード1=父,2=娘
	JE	BORTH_OPEN_GIRL		;

BORTH_OPEN_FATHER:
	MOV	DX,7			; 7="あなたの誕生日はいつですか？",0
	CALLE	WIDNAME_M_CLENDR	; WINDOWS/名前ウインドウ･ｶﾚﾝﾀﾞﾒｯｾｰｼﾞ
	RET
BORTH_OPEN_GIRL:
	MOV	DX,8			; 8="娘の誕生日はいつですか？",0
	CALLE	WIDNAME_M_CLENDR	; WINDOWS/名前ウインドウ･ｶﾚﾝﾀﾞﾒｯｾｰｼﾞ
	RET
BORTH_OPEN	ENDP


; ****************************************************
;	誕生日ＣＬＯＳＥ
; ****************************************************

BORTH_CLOSE	PROC	NEAR
	RET
BORTH_CLOSE	ENDP


; ****************************************************
;	誕生日ＭＡＩＮ
;	-O- AX        : 1=キャンセル
;	    SET_YEAR  : 年
;	    SET_MONTH : 月
;	    SET_DAYS  : 日
; ****************************************************

BORTH_MAIN	PROC	NEAR
	CALL	CLEND_MAIN		; カレンダーメイン

	CALL	WID_SLCT		; マウスセレクト
	CMP	AX,1			; 1=キャンセル
	JE	BORTH_MAIN_CANCEL	;

	MOV	AX,0
	RET
BORTH_MAIN_CANCEL:
	MOV	AX,1			; 1=キャンセル
	RET
BORTH_MAIN	ENDP


; ****************************************************
;	マウスセレクト
;	-I- SET_YEAR  : 設定・年代
;	    SET_MONTH : 設定・月
;	    SET_DAYS  : 設定・日
;	-O- AX        : 1=キャンセル
;	    SET_YEAR  : 年
;	    SET_MONTH : 月
;	    SET_DAYS  : 日
; ****************************************************

WID_SLCT	PROC	NEAR
	MOV	SCH_POS_YEAR_N,0	; 年
	MOV	SCH_POS_MNTH_N,0	; 月
	MOV	SCH_POS_DAYS_N,0	; 日
	MOV	OLD_YEAR,0		; 前回・年
	MOV	OLD_MONTH,0		; 前回・月
	MOV	OLD_DATE,0		; 前回・日

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

	CALL	CLEND_SCH		; カレンダーサーチ・月
	MOV	FLAG_KETTEI,AX		; 決定フラグ
	CMP	AX,0			; 0=無し,1=一致した
	JE	WID_SLCT_5		;

	CALL	CLEND_SCH_DAYS		; カレンダーサーチ・日
	MOV	FLAG_KETTEI,AX		; 決定フラグ
	CMP	AX,0			; 0=無し,1=一致した
	JE	WID_SLCT_5		;
	JMP	WID_SLCT_NEXT		;

WID_SLCT_5:
	CMP	FLAG_SAVE,0		; 退避フラグ
	JE	WID_SLCT_NEXT		;

	CALLE	MSCSTP			;
	CALL	CLR_DATE_SET		; クリア日付
	CALL	VRAM_LOAD		; vram load.
	CALLE	MSCSRT			;

	MOV	SCH_POS_YEAR_N,0	; 年
	MOV	SCH_POS_MNTH_N,0	; 月
	MOV	SCH_POS_DAYS_N,0	; 日
	MOV	OLD_YEAR,0		; 前回・年
	MOV	OLD_MONTH,0		; 前回・月
	MOV	OLD_DATE,0		; 前回・日

WID_SLCT_NEXT:
	JMP	WID_SLCT_LOOP		;

WID_SLCT_ON:				;
	CMP	FLAG_KETTEI,0		; 決定フラグ
	JMPEQ	WID_SLCT_LOOP		;

	MOVX	SET_YEAR,SCH_POS_YEAR_N		; 年
	MOVX	SET_MONTH,SCH_POS_MNTH_N	; 月
	MOVX	SET_DAYS,SCH_POS_DAYS_N		; 日

	CMP	SET_MONTH,2		; 月
	JNE	WID_SLCT_EXIT		;
	CMP	SET_DAYS,29		; 日
	JNE	WID_SLCT_EXIT		;
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
;	カレンダーサーチ・月
;	-I- MOUSEX : マウスＸ
;	    MOUSEY : マウスＹ
;	-O- AX     : 0=無し,1=一致した
;	    SCH_POS_MNTH_N : 表示・１カレンダー・月
;	    SCH_POS_MNTH_X : 表示・カレンダーＸ開始位置
;	    SCH_POS_MNTH_Y : 表示・カレンダーＹ開始位置
;	    SCH_POS_OFST_X : サーチ・オフセットＸ
;	    SCH_POS_OFST_Y : サーチ・オフセットＹ
; ****************************************************

CLEND_SCH	PROC	NEAR
	MOVX	SET_CLD_MONTH,START_MONTH	; 表示開始・月

	MOV	LOC_1_CLEND_Y,CLEND_OFST_Y	; 表示・カレンダーＹ開始位置
	MOV	CX,CLEND_NARABI_Y		; 表示・カレンダーＹ並び
CLEND_SCH_SHOW_LOOP_YY:				;
	PUSH	CX				;

	MOV	LOC_1_CLEND_X,CLEND_OFST_X	; 表示・カレンダーＸ開始位置
	MOV	CX,CLEND_NARABI_X		; 表示・カレンダーＸ並び
CLEND_SCH_SHOW_LOOP_XX:				;
	PUSH	CX				;

	MOV	AX,LOC_1_CLEND_X		; 表示・カレンダーＸ開始位置
	MOV	BX,LOC_1_CLEND_Y		; 表示・カレンダーＹ開始位置
	ADD	AX,CLEND_HANI_X			; 表示・カレンダーＸ範囲
	ADD	BX,CLEND_HANI_Y			; 表示・カレンダーＹ範囲
	MOV	LOC_E_CLEND_X,AX		; 表示・カレンダー右下Ｘ
	MOV	LOC_E_CLEND_Y,BX		; 表示・カレンダー右下Ｙ

	MOV	AX,MOUSEX			; マウスＸ
	MOV	BX,MOUSEY			; マウスＹ
	ARACHK	LOC_1_CLEND_X,LOC_1_CLEND_Y,LOC_E_CLEND_X,LOC_E_CLEND_Y,CLEND_SCH_SEARCH

	INC	SET_CLD_MONTH			; 表示・１カレンダー・月
	CMP	SET_CLD_MONTH,12		; 年越しか？
	JLE	CLEND_SCH_SHOW_55		;
	INC	SET_CLD_YEAR			; 表示・１カレンダー・年
	MOV	SET_CLD_MONTH,1			; 表示・１カレンダー・月
CLEND_SCH_SHOW_55:				;

	ADD	LOC_1_CLEND_X,CLEND_STEP_X	; 表示・カレンダーＸ間隔
	POP	CX				;
	LOOP	CLEND_SCH_SHOW_LOOP_XX		;

	ADD	LOC_1_CLEND_Y,CLEND_STEP_Y	; 表示・カレンダーＹ間隔
	POP	CX				;
	LOOP	CLEND_SCH_SHOW_LOOP_YY		;

	JMP	CLEND_SCH_NONE

CLEND_SCH_SEARCH:
	POP	CX
	POP	CX

	MOVX	SCH_POS_MNTH_N,SET_CLD_MONTH	; 表示・１カレンダー・月
	MOVX	SCH_POS_MNTH_X,LOC_1_CLEND_X	; 表示・カレンダーＸ開始位置
	MOVX	SCH_POS_MNTH_Y,LOC_1_CLEND_Y	; 表示・カレンダーＹ開始位置
	MOV	AX,MOUSEX			; マウスＸ
	MOV	BX,MOUSEY			; マウスＹ
	SUB	AX,LOC_1_CLEND_X		; 表示・カレンダーＸ開始位置
	SUB	BX,LOC_1_CLEND_Y		; 表示・カレンダーＹ開始位置
	MOV	SCH_POS_OFST_X,AX		; サーチ・オフセットＸ
	MOV	SCH_POS_OFST_Y,BX		; サーチ・オフセットＹ
	MOV	AX,1				; 1=一致した
	RET
CLEND_SCH_NONE:
	MOV	AX,0				; 0=無し
	RET
CLEND_SCH	ENDP


; ****************************************************
;	カレンダーサーチ・日
;	-I- SCH_POS_MNTH_N : 表示・１カレンダー・月
;	    SCH_POS_MNTH_X : 表示・カレンダーＸ開始位置
;	    SCH_POS_MNTH_Y : 表示・カレンダーＹ開始位置
;	    SCH_POS_OFST_X : サーチ・オフセットＸ
;	    SCH_POS_OFST_Y : サーチ・オフセットＹ
;	-O- AX      : 0=無し,1=一致した
;	    SCH_POS_YEAR_N : 年
;	    SCH_POS_MNTH_N : 月
;	    SCH_POS_DAYS_N : 日
; ****************************************************

CLEND_SCH_DAYS	PROC	NEAR
	MOVX	XX1,SCH_POS_OFST_X	; サーチ・オフセットＸ
	MOVX	YY1,SCH_POS_OFST_Y	; サーチ・オフセットＹ
	CALL	MTRX_SCH		; マトリックスサーチ
	CMP	AX,0			; 0=無し,1=一致した
	JE	CLEND_SCH_DAYS_NONE	;

	CALL	TOSHI_NOCHI		; 年・日サーチ
	CMP	AX,0			; 0=無し,1=一致した
	JE	CLEND_SCH_DAYS_NONE	;

	CALL	SHOW_DATESET		; 日付の表示
	CALL	DATE_CURSOLE		; 日付カーソル

CLEND_SCH_DAYS_SCH:
	MOV	AX,1			; 1=一致した
	RET
CLEND_SCH_DAYS_NONE:
	MOV	AX,0			; 0=無し
	RET
CLEND_SCH_DAYS	ENDP


; ****************************************************
;	年・日サーチ
;	-I- SCHXX          : サーチＸ
;	    SCHYY          : サーチＹ
;	    SCH_POS_MNTH_N : 表示・１カレンダー・月
;	    CLNDTBL_S_WEEK[]: 月毎の始め曜日
;	    CLNDTBL_E_DAYS[]: 月毎の末日
;	-O- AX             : 0=無し,1=一致した
;	    SCH_POS_YEAR_N : サーチ・何年
;	    SCH_POS_DAYS_N : サーチ・何日
; ****************************************************

TOSHI_NOCHI	PROC	NEAR
	MOV	AX,SCHYY			; サーチＹ
	MOV	DX,0				;
	MOV	BX,CLM_CLND_CNT_X		; ×カレンダー並び数Ｘ
	MUL	BX				;
	ADD	AX,SCHXX			; ＋サーチＸ
	INC	AX				; +1
	MOV	SCH_POS_DAYS_N,AX		; サーチ・何日

	MOV	BX,SCH_POS_MNTH_N		; 表示・１カレンダー・月
	MOV	CL,CLNDTBL_S_WEEK[BX]		; 月毎の始め曜日
	MOV	CH,0				;
	MOV	DL,CLNDTBL_E_DAYS[BX]		; 月毎の末日
	MOV	DH,0				;

	SUB	SCH_POS_DAYS_N,CX		; サーチ・何日
	JLE	TOSHI_NOCHI_NONE		;

	CMP	SCH_POS_DAYS_N,DX		; 月毎の末日
	JG	TOSHI_NOCHI_NONE		;

	MOV	DX,START_YEAR			; 表示開始年
	MOV	SCH_POS_YEAR_N,DX		; サーチ・何年
	CMPX	SCH_POS_MNTH_N,START_MONTH	; 表示開始・月
	JGE	TOSHI_NOCHI_77			;
	INC	SCH_POS_YEAR_N			; サーチ・何年
TOSHI_NOCHI_77:					;

TOSHI_NOCHI_SCH:
	MOV	AX,1				; 1=一致した
	RET
TOSHI_NOCHI_NONE:
	MOV	AX,0				; 0=無し
	RET
TOSHI_NOCHI	ENDP


; ****************************************************
;	マトリックスサーチ
;	-I- XX1,YY1 : サーチポイント
;	-O- AX      : 0=無し,1=一致した
;	    SCHXX   : サーチＸ
;	    SCHYY   : サーチＹ
; ****************************************************

MTRX_SCH	PROC	NEAR
	MOV	SCHXX,0				; サーチＸ
	MOV	SCHYY,0				; サーチＹ

	MOV	YY2,0				;
	MOV	CX,CLM_CLND_CNT_Y		; カレンダー並び数Ｙ
MTRX_SCH_LOOP_YY:				;
	ADD	YY2,HIGHT_DAYS_STR		; 表示・カレンダー日・高さ
	CMPX	YY1,YY2				;
	JB	MTRX_SCH_SCH_YY			;
	INC	SCHYY				; サーチＹ
	LOOP	MTRX_SCH_LOOP_YY		;
	JMP	MTRX_SCH_NONE			;
MTRX_SCH_SCH_YY:				;

	MOV	XX2,0				;
	MOV	CX,CLM_CLND_CNT_X		; カレンダー並び数Ｘ
MTRX_SCH_LOOP_XX:				;
	ADD	XX2,WIDTH_DAYS_STR		; 表示・カレンダー日・幅
	CMPX	XX1,XX2				;
	JB	MTRX_SCH_SCH_XX			;
	INC	SCHXX				; サーチＸ
	LOOP	MTRX_SCH_LOOP_XX		;
	JMP	MTRX_SCH_NONE			;
MTRX_SCH_SCH_XX:				;

MTRX_SCH_SCH:
	MOV	AX,1				; 1=一致した
	RET
MTRX_SCH_NONE:
	MOV	AX,0				; 0=無し
	RET
MTRX_SCH	ENDP


; ****************************************************
;	カレンダーメイン
; ****************************************************

CLEND_MAIN	PROC	NEAR
	CALL	ALL_CLENDER_SHOW		; 全カレンダー表示
	RET
CLEND_MAIN	ENDP


; ****************************************************
;	全カレンダー表示
; ****************************************************

ALL_CLENDER_SHOW	PROC	NEAR
	MOVX	SET_CLD_YEAR,START_YEAR		; 表示開始・年
	MOVX	SET_CLD_MONTH,START_MONTH	; 表示開始・月

	MOV	LOC_1_CLEND_Y,CLEND_OFST_Y	; 表示・カレンダーＹ開始位置

	MOV	CX,CLEND_NARABI_Y		; 表示・カレンダーＹ並び
ALL_CLENDER_SHOW_LOOP_YY:			;
	PUSH	CX				;

	MOV	LOC_1_CLEND_X,CLEND_OFST_X	; 表示・カレンダーＸ開始位置

	MOV	CX,CLEND_NARABI_X		; 表示・カレンダーＸ並び
ALL_CLENDER_SHOW_LOOP_XX:
	PUSH	CX				;

	MOV	AX,SET_CLD_YEAR			; 表示・１カレンダー・年
	MOV	BX,SET_CLD_MONTH		; 表示・１カレンダー・月
	CALLE	WIDCLEN_MONTH			; WINDOWS/カレンダー・月データ
	MOV	SET_CLD_DAY_END,CX		; 月末の日
	MOV	SET_CLD_S_WEEK,DX		; 曜日

	CALL	ONE_CLENDER_SHOW		; １カレンダー表示

	MOV	AX,SET_CLD_S_WEEK		; 曜日
	MOV	DX,SET_CLD_DAY_END		; 月末の日
	MOV	BX,SET_CLD_MONTH		; 表示・１カレンダー・月
	MOV	CLNDTBL_S_WEEK[BX],AL		; 月毎の始め曜日
	MOV	CLNDTBL_E_DAYS[BX],DL		; 月毎の末日

	INC	SET_CLD_MONTH			; 表示・１カレンダー・月
	CMP	SET_CLD_MONTH,12		; 年越しか？
	JLE	ALL_CLENDER_SHOW_55		;
	INC	SET_CLD_YEAR			; 表示・１カレンダー・年
	MOV	SET_CLD_MONTH,1			; 表示・１カレンダー・月
ALL_CLENDER_SHOW_55:				;

	ADD	LOC_1_CLEND_X,CLEND_STEP_X	; 表示・カレンダーＸ間隔
	POP	CX				;
	LOOP	ALL_CLENDER_SHOW_LOOP_XX	;

	ADD	LOC_1_CLEND_Y,CLEND_STEP_Y	; 表示・カレンダーＹ間隔
	POP	CX				;
	LOOP	ALL_CLENDER_SHOW_LOOP_YY	;

	RET
ALL_CLENDER_SHOW	ENDP


; ****************************************************
;	１カレンダー表示
;	-I- LOC_1_CLEND_X : 表示１カレンダーＸ
;	    LOC_1_CLEND_Y : 表示１カレンダーＹ
;	    SET_CLD_YEAR  : 表示・１カレンダー・年
;	    SET_CLD_MONTH : 表示・１カレンダー・月
;	    SET_CLD_DAY_END : 表示・１カレンダー・末日
;	    SET_CLD_S_WEEK  : 表示・１カレンダー・開始曜日
; ****************************************************

ONE_CLENDER_SHOW	PROC	NEAR
	MOV	AX,LOC_1_CLEND_X		; 表示１カレンダーＸ
	MOV	BX,LOC_1_CLEND_Y		; 表示１カレンダーＹ
	SUB	BX,7				;
	CALLE	PT_BORTH_WEEK			; borth week.

	MOV	NOW_CLEND_DAY,1			; 表示・カレンダー日

	MOV	DAYS_FONT_COLOR,COLOR_MONTH	; 月色
	MOVX	LOC_DAYS_X,LOC_1_CLEND_X	; 表示・１カレンダーＸ
	MOVX	LOC_DAYS_Y,LOC_1_CLEND_Y	; 表示・１カレンダーＹ
	ADD	LOC_DAYS_X,OFS_HEAD_XX		; 表示・カレンダーヘッダＸ
	ADD	LOC_DAYS_Y,OFS_HEAD_YY		; 表示・カレンダーヘッダＹ
	SUB	LOC_DAYS_Y,HIGHT_HEAD_STR	; 表示・カレンダーヘッダ・高さ
	CALL	HEAD_DISP			; カレンダーヘッダー・表示

	MOVX	CLM_DAYS_X,SET_CLD_S_WEEK	; 表示・１カレンダー・開始曜日
	MOVX	LOC_DAYS_X,LOC_1_CLEND_X	; 表示・１カレンダーＸ

	MOV	AX,3				;
	MOV	DX,0				;
	MOV	BX,SET_CLD_S_WEEK		; 表示・１カレンダー・開始曜日
	MUL	BX				;
	ADD	LOC_DAYS_X,AX			; 表示・１カレンダーＸ

	MOV	CLM_DAYS_Y,0			; 表示・カレンダー日カラムＹ
	MOVX	LOC_DAYS_Y,LOC_1_CLEND_Y	; 表示・１カレンダーＹ
ONE_CLENDER_SHOW_LOOP:
	CMPX	NOW_CLEND_DAY,SET_CLD_DAY_END	; 表示・１カレンダー・末日
	JG	ONE_CLENDER_SHOW_LOOP_E		;

	CMP	CLM_DAYS_X,CLM_DAYS_MAX_X	; 表示・カレンダー日・数Ｘ
	JB	ONE_CLENDER_SHOW_3X		;
	MOV	CLM_DAYS_X,0			; 表示・カレンダー日カラムＸ
	INC	CLM_DAYS_Y			; 表示・カレンダー日カラムＹ
	MOVX	LOC_DAYS_X,LOC_1_CLEND_X	; 表示・１カレンダーＸ
	ADD	LOC_DAYS_Y,HIGHT_DAYS_STR	; 表示・カレンダー日・高さ
	MOV	DAYS_FONT_COLOR,COLOR_HOLIDAY	; 休み色
ONE_CLENDER_SHOW_3X:

	MOV	DAYS_FONT_COLOR,COLOR_BLUEDAY	; 平日色
	CMP	CLM_DAYS_X,0			; 表示・カレンダー日カラムＸ
	JNE	ONE_CLENDER_SHOW_44		;
	MOV	DAYS_FONT_COLOR,COLOR_HOLIDAY	; 休み色
ONE_CLENDER_SHOW_44:

	CALL	DAYS_DISP			; 日・表示

	INC	CLM_DAYS_X			; 表示・カレンダー日カラムＸ
	ADD	LOC_DAYS_X,WIDTH_DAYS_STR	; 表示・１カレンダーＸ
	INC	NOW_CLEND_DAY			; 表示・カレンダー日
	JMP	ONE_CLENDER_SHOW_LOOP		;
ONE_CLENDER_SHOW_LOOP_E:
	RET
ONE_CLENDER_SHOW	ENDP


; ****************************************************
;	カレンダーヘッダー・表示
;	-I- LOC_DAYS_X     : 表示・１カレンダーＸ
;	    LOC_DAYS_Y     : 表示・１カレンダーＹ
;	    SET_CLD_YEAR   : 表示・１カレンダー・年
;	    SET_CLD_MONTH  : 表示・１カレンダー・月
;	    DAYS_FONT_COLOR: 表示・フォントカラー
; ****************************************************

HEAD_DISP	PROC	NEAR
	MOV	AX,DAYS_FONT_COLOR		; 表示・フォントカラー
	CALLE	MITCOL				; mini string color.

	MOV	DX,SET_CLD_YEAR			; 表示・１カレンダー・年
	CALLE	DECSTR				;
	CALLE	STRZTS				; "00123" - > "  123"
	ADD	SI,1				;
	MOV	AX,LOC_DAYS_X			; 表示・１カレンダーＸ
	DEC	AX				;-1
	MOV	BX,LOC_DAYS_Y			; 表示・１カレンダーＹ
	CALL	MINI_STR_PUT			; ｍｉｎｉ文字列ＰＵＴ

	MOV	DX,SET_CLD_MONTH		; 表示・１カレンダー・月
	CALLE	DECSTR				;
	CALLE	STRZTS				; "00123" - > "  123"
	ADD	SI,3				;
	MOV	AX,LOC_DAYS_X			; 表示・１カレンダーＸ
	MOV	BX,LOC_DAYS_Y			; 表示・１カレンダーＹ
	ADD	BX,10				;
	CALL	NUMBER_STR_PUT			; 数字文字列表示

;*;	CALL	NUMBER_STR_PUT			; 数字文字列表示
	RET
HEAD_DISP	ENDP


; ****************************************************
;	カレンダー日・表示
;	-I- LOC_DAYS_X     : 表示・１カレンダーＸ
;	    LOC_DAYS_Y     : 表示・１カレンダーＹ
;	    NOW_CLEND_DAY  : 表示・カレンダー日
;	    DAYS_FONT_COLOR: 表示・フォントカラー
; ****************************************************

DAYS_DISP	PROC	NEAR
	MOV	AX,DAYS_FONT_COLOR		; 表示・フォントカラー
	CALLE	MITCOL				; mini string color.

	MOV	DX,NOW_CLEND_DAY		; 表示・カレンダー日
	CALLE	DECSTR				;
	CALLE	STRZTS			; zero to space. "00123" - > "  123"
	ADD	SI,3				;
	MOV	AX,LOC_DAYS_X			; 表示・１カレンダーＸ
	MOV	BX,LOC_DAYS_Y			; 表示・１カレンダーＹ
	CALL	NUMBER_STR_PUT			; 数字文字列表示
	RET
DAYS_DISP	ENDP


; ****************************************************
;	日付の表示
;	-I- SCH_POS_YEAR_N : サーチ・何年
;	    SCH_POS_MNTH_N : 表示・カレンダー・月
;	    SCH_POS_DAYS_N : サーチ・何日
;
;	    SCH_POS_MNTH_X : 表示・カレンダーＸ開始位置
;	    SCH_POS_MNTH_Y : 表示・カレンダーＹ開始位置
;	    SCH_POS_OFST_X : サーチ・オフセットＸ
;	    SCH_POS_OFST_Y : サーチ・オフセットＹ
; ****************************************************

SHOW_DATESET	PROC	NEAR
	MOV	AX,COLOR_DATESET		; 日付色
	CALLE	MITCOL				; mini string color.

	CMPX	OLD_YEAR,SCH_POS_YEAR_N		;
	JE	SHOW_DATESET_2			;
	MOVX	OLD_YEAR,SCH_POS_YEAR_N		;
	MOVX	DSP_YEAR,SCH_POS_YEAR_N		; サーチ・何年
	CALL	SHOW_YEAR			; 表示・年
SHOW_DATESET_2:

	CMPX	OLD_MONTH,SCH_POS_MNTH_N	;
	JE	SHOW_DATESET_3			;
	MOVX	OLD_MONTH,SCH_POS_MNTH_N	;
	MOVX	DSP_MONTH,SCH_POS_MNTH_N	; 表示・１カレンダー・月
	CALL	SHOW_MONTH			; 表示・月
SHOW_DATESET_3:

	CMPX	OLD_DATE,SCH_POS_DAYS_N		;
	JE	SHOW_DATESET_4			;
	MOVX	OLD_DATE,SCH_POS_DAYS_N		;
	MOVX	DSP_DATE,SCH_POS_DAYS_N		; サーチ・何日
	CALL	SHOW_DATE			; 表示・日
SHOW_DATESET_4:

SHOW_DATESET_EXIT:
	RET
SHOW_DATESET	ENDP


; ****************************************************
;	日付カーソル
;	-I- SCH_POS_MNTH_X : 表示・カレンダーＸ開始位置
;	    SCH_POS_MNTH_Y : 表示・カレンダーＹ開始位置
;	    SCHXX   : サーチＸ
;	    SCHYY   : サーチＹ
;	    DSP_DATE   : 表示・日
; ****************************************************

DATE_CURSOLE	PROC	NEAR
	MOV	AX,SCHXX			; サーチＸ
	MOV	BX,WIDTH_DAYS_STR		; 表示・カレンダー日・幅
	MUL	BX				;
	ADD	AX,SCH_POS_MNTH_X		; 表示・カレンダーＸ開始位置
	MOV	CLNDXX,AX			; カーソルＸ

	MOV	AX,SCHYY			; サーチＹ
	MOV	BX,HIGHT_DAYS_STR		; 表示・カレンダー日・高さ
	MUL	BX				;
	ADD	AX,SCH_POS_MNTH_Y		; 表示・カレンダーＹ開始位置
	MOV	CLNDYY,AX			; カーソルＹ

	MOV	AX,14
	CALLE	MITCOL				; mini string color.

	MOVX	BASEXX,SCH_POS_MNTH_X		; 表示・カレンダーＸ開始位置
	MOVX	BASEYY,SCH_POS_MNTH_Y		; 表示・カレンダーＹ開始位置
	CALL	CLND_CURSOLE			; カレンダーカーソル

	RET
DATE_CURSOLE	ENDP


; ****************************************************
;	表示・年
;	-I- DSP_YEAR : 表示・年
; ****************************************************

SHOW_YEAR	PROC	NEAR
	MOV	AX,LOC_YEAR_X		; 表示・年・Ｘ
	MOV	BX,LOC_YEAR_Y		; 表示・年・Ｙ
	MOV	CX,4			; 長さ
	CALL	MINI_STR_CLR		; ｍｉｎｉ文字列ＣＬＥＡＲ

	MOV	DX,DSP_YEAR		; 表示・年
	CALLE	DECSTR			;
	CALLE	STRZTS			; zero to space. "00123" - > "  123"
	ADD	SI,1			;

	CALL	MINI_STR_PUT		; ｍｉｎｉ文字列ＰＵＴ
	RET
SHOW_YEAR	ENDP


; ****************************************************
;	表示・月
;	-I- DSP_MONTH : 表示・月
; ****************************************************

SHOW_MONTH	PROC	NEAR
	MOV	DX,DSP_MONTH		; 表示・月
	CALLE	DECSTR			;
	CALLE	STRZTS			; zero to space. "00123" - > "  123"
	ADD	SI,3			;
	MOV	AX,LOC_MONTH_X		; 表示・月・Ｘ
	MOV	BX,LOC_MONTH_Y		; 表示・月・Ｙ
	MOV	CX,2			; 長さ
	CALL	MINI_STR_CLR		; ｍｉｎｉ文字列ＣＬＥＡＲ
	CALL	MINI_STR_PUT		; ｍｉｎｉ文字列ＰＵＴ
	RET
SHOW_MONTH	ENDP


; ****************************************************
;	表示・日
;	-I- DSP_DATE : 表示・日
; ****************************************************

SHOW_DATE	PROC	NEAR
	MOV	DX,DSP_DATE		; 表示・日
	CALLE	DECSTR			;
	CALLE	STRZTS			; zero to space. "00123" - > "  123"
	ADD	SI,3			;
	MOV	AX,LOC_DATE_X		; 表示・日・Ｘ
	MOV	BX,LOC_DATE_Y		; 表示・日・Ｙ
	MOV	CX,2			; 長さ
	CALL	MINI_STR_CLR		; ｍｉｎｉ文字列ＣＬＥＡＲ
	CALL	MINI_STR_PUT		; ｍｉｎｉ文字列ＰＵＴ
	RET
SHOW_DATE	ENDP


; ****************************************************
;	クリア日付
; ****************************************************

CLR_DATE_SET	PROC	NEAR
	MOV	AX,LOC_YEAR_X		; 表示・年・Ｘ
	MOV	BX,LOC_YEAR_Y		; 表示・年・Ｙ
	MOV	CX,4			; 長さ
	CALL	MINI_STR_CLR		; ｍｉｎｉ文字列ＣＬＥＡＲ

	MOV	AX,LOC_MONTH_X		; 表示・月・Ｘ
	MOV	BX,LOC_MONTH_Y		; 表示・月・Ｙ
	MOV	CX,2			; 長さ
	CALL	MINI_STR_CLR		; ｍｉｎｉ文字列ＣＬＥＡＲ

	MOV	AX,LOC_DATE_X		; 表示・日・Ｘ
	MOV	BX,LOC_DATE_Y		; 表示・日・Ｙ
	MOV	CX,2			; 長さ
	CALL	MINI_STR_CLR		; ｍｉｎｉ文字列ＣＬＥＡＲ

	RET
CLR_DATE_SET	ENDP


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
;	ｍｉｎｉ文字列ＰＵＴ
;	-I- SI : 文字列
;	    AX : Ｘ
;	    BX : Ｙ
; ****************************************************

MINI_STR_PUT	PROC	NEAR
	CALLE	MITPRN				; mini string.
	RET
MINI_STR_PUT	ENDP


; ****************************************************
;	ｍｉｎｉ文字列ＣＬＥＡＲ
;	-I- AX : Ｘ
;	    BX : Ｙ
;	    CX : 長さ
; ****************************************************

MINI_STR_CLR	PROC	NEAR
	PUSH	SI
	PUSH	AX
	PUSH	BX

	PUSH	AX
	PUSH	BX
	PUSH	CX

	MOV	VX1,AX
	MOV	VY1,BX
	ADD	AX,CX
	DEC	AX
	ADD	BX,8-1
	MOV	VX2,AX
	MOV	VY2,BX
	MOV	CX,0		; カラー
	CALLE	BOXPAL		; ＢＯＸペイント

	POP	CX
	POP	BX
	POP	AX

	ADD	BX,8
	MOV	VX1,AX
	MOV	VY1,BX
	ADD	AX,CX
	DEC	AX
	MOV	VX2,AX
	MOV	VY2,BX
	MOV	CX,9		; カラー
	CALLE	BOXPAL		; ＢＯＸペイント

	POP	BX
	POP	AX
	POP	SI
	RET
MINI_STR_CLR	ENDP


; ****************************************************
;	数字文字列表示
;	-I- SI : 文字列
;	    AX : Ｘ
;	    BX : Ｙ
; ****************************************************

NUMBER_STR_PUT	PROC	NEAR
	CALLE	MGXPRN			; GAINAX mini string.
	RET
NUMBER_STR_PUT	ENDP


; ****************************************************
;	カレンダーカーソル
;	-I- CLNDXX : カーソルＸ
;	    CLNDYY : カーソルＹ
;	    BASEXX : ベースＸ
;	    BASEYY : ベースＹ
;	    DSP_DATE : 表示・日
; ****************************************************

CLND_CURSOLE	PROC	NEAR
	CMP	FLAG_SAVE,0			; 退避フラグ
	JE	CLND_CURSOLE_START		;
	CMPX	OLD_CLNDXX,CLNDXX		; カーソルＸ
	JNE	CLND_CURSOLE_START		;
	CMPX	OLD_CLNDYY,CLNDYY		; カーソルＹ
	JNE	CLND_CURSOLE_START		;
	RET
CLND_CURSOLE_START:
	CALLE	MSCSTP

	CALL	VRAM_LOAD			; vram load.
	CALL	VRAM_SAVE			; vram save.

	MOV	DX,DSP_DATE			; 表示・日
	CALLE	DECSTR				;
	CALLE	STRZTS				; "00123" - > "  123"
	ADD	SI,3				;
	MOV	AX,CLNDXX			; カーソルＸ
	MOV	BX,CLNDYY			; カーソルＹ
	CALL	NUMBER_STR_PUT			; 数字文字列表示

	MOVX	OLD_BASEXX,BASEXX		; ベースＸ
	MOVX	OLD_BASEYY,BASEYY		; ベースＹ
	MOVX	OLD_CLNDXX,CLNDXX		; カーソルＸ
	MOVX	OLD_CLNDYY,CLNDYY		; カーソルＹ

	CALLE	MSCSRT
CLND_CURSOLE_EXIT:
	RET
CLND_CURSOLE	ENDP


; ****************************************************
;	vram save.
; ****************************************************

VRAM_SAVE	PROC	NEAR
	MOV	FLAG_SAVE,1

	MOV	DX,BNK_RESTORE		;待避バンク
	CALLE	PT_PATTERN_BANK		;pattern bank set.
	CALLE	PT_PATTERN_CLEAR	;parts buffer clear.
	MOV	AX,CLNDXX		; カーソルＸ
	MOV	BX,CLNDYY		; カーソルＹ
	MOV	CX,WIDTH_DAYS_STR	; 表示・カレンダー日・幅
	MOV	DX,HIGHT_DAYS_STR	; 表示・カレンダー日・高さ
	CALLE	PT_PATTERN_GET		; parts get.
	RET
VRAM_SAVE	ENDP


; ****************************************************
;	vram load.
; ****************************************************

VRAM_LOAD	PROC	NEAR
	CMP	FLAG_SAVE,0
	JE	VRAM_LOAD_66
	MOV	FLAG_SAVE,0

	MOV	DX,BNK_RESTORE		;待避バンク
	CALLE	PT_PATTERN_BANK		;pattern bank set.
	MOV	AX,OLD_CLNDXX		; put x.
	MOV	BX,OLD_CLNDYY		; put y.
	MOV	DX,0			; pattern number.
	CALLE	PT_PATTERN_PUT		;pattern put.
VRAM_LOAD_66:
	RET
VRAM_LOAD	ENDP


; ****************************************************
;	data.
; ****************************************************

PUBLIC	SET_YEAR				; 設定・年代
PUBLIC	SET_MONTH				; 設定・月
PUBLIC	SET_DAYS				; 設定・日

PUBLIC	START_YEAR				; 表示開始・年
PUBLIC	START_MONTH				; 表示開始・月

EXTRN	VX1:WORD				; point x1.
EXTRN	VY1:WORD				; point y1.
EXTRN	VX2:WORD				; point x2.
EXTRN	VY2:WORD				; point y2.

		EVEN
INPUT_MODE	DW	0			; 入力モード1=父,2=娘

SET_YEAR	DW	1658			; 設定・年代
SET_MONTH	DW	04			; 設定・月
SET_DAYS	DW	04			; 設定・日

START_YEAR	DW	1662			; 表示開始・年
START_MONTH	DW	1			; 表示開始・月

CLNDTBL_S_WEEK	DB	13 DUP (0)		; 月毎の始め曜日
CLNDTBL_E_DAYS	DB	13 DUP (0)		; 月毎の末日

DSP_YEAR	DW	1659			; 表示・年
DSP_MONTH	DW	4			; 表示・月
DSP_DATE	DW	21			; 表示・日
DSP_SEIZA	DW	3			; 表示・星座
DSP_BLOOD	DW	2			; 表示・血液型1=A,2=AB,3=B,4=O

OLD_YEAR	DW	1659			; 前回・年
OLD_MONTH	DW	4			; 前回・月
OLD_DATE	DW	21			; 前回・日

LOC_NAME_X	DW	50			; 表示・名前・Ｘ
LOC_NAME_Y	DW	8			; 表示・名前・Ｙ

LOC_YEAR_X	DW	3			; 表示・年・Ｘ
LOC_YEAR_Y	DW	20			; 表示・年・Ｙ
LOC_MONTH_X	DW	3+5			; 表示・月・Ｘ
LOC_MONTH_Y	DW	20			; 表示・月・Ｙ
LOC_DATE_X	DW	3+5+3			; 表示・日・Ｘ
LOC_DATE_Y	DW	20			; 表示・日・Ｙ
LOC_SEIZA_X	DW	2			; 表示・星座・Ｘ
LOC_SEIZA_Y	DW	8			; 表示・星座・Ｙ
LOC_BLOOD_X	DW	2			; 表示・血液型・Ｘ
LOC_BLOOD_Y	DW	8			; 表示・血液型・Ｙ

LOC_1_CLEND_X	DW	30			; 表示・１カレンダーＸ
LOC_1_CLEND_Y	DW	200			; 表示・１カレンダーＹ
LOC_E_CLEND_X	DW	30			; 表示・カレンダー右下Ｘ
LOC_E_CLEND_Y	DW	200			; 表示・カレンダー右下Ｙ

LOC_DAYS_X	DW	0			; 表示・カレンダー日Ｘ
LOC_DAYS_Y	DW	0			; 表示・カレンダー日Ｙ

CLM_DAYS_X	DW	0			; 表示・カレンダー日カラムＸ
CLM_DAYS_Y	DW	0			; 表示・カレンダー日カラムＹ

SET_CLD_YEAR	DW	10			; 表示・１カレンダー・年
SET_CLD_MONTH	DW	10			; 表示・１カレンダー・月
SET_CLD_DAY_END	DW	31			; 表示・１カレンダー・末日
SET_CLD_S_WEEK	DW	2			; 表示・１カレンダー・開始曜日

NOW_CLEND_DAY	DW	0			; 表示・カレンダー日

DAYS_FONT_COLOR	DW	0			; 表示・フォントカラー

SCH_POS_MNTH_N	DW	0			; サーチ・何月
SCH_POS_MNTH_X	DW	0			; サーチ・月Ｘ
SCH_POS_MNTH_Y	DW	0			; サーチ・月Ｙ
SCH_POS_OFST_X	DW	0			; サーチ・オフセットＸ
SCH_POS_OFST_Y	DW	0			; サーチ・オフセットＹ
SCH_POS_YEAR_N	DW	0			; サーチ・何年
SCH_POS_DAYS_N	DW	0			; サーチ・何日

MOUSEFLAG	DW	0		; マウスＯＮ／ＯＦＦフラグ
MOUSEX		DW	0		; マウスＸ
MOUSEY		DW	0		; マウスＹ

SCHXX		DW	0		; サーチＸ
SCHYY		DW	0		; サーチＹ

FLAG_SAVE	DW	0		; 退避フラグ

CLNDXX		DW	0		; カーソルＸ
CLNDYY		DW	0		; カーソルＹ
OLD_CLNDXX	DW	0		; カーソル前回Ｘ
OLD_CLNDYY	DW	0		; カーソル前回Ｙ
BASEXX		DW	0		; ベースＸ
BASEYY		DW	0		; ベースＹ
OLD_BASEXX	DW	0		; ベース前回Ｘ
OLD_BASEYY	DW	0		; ベース前回Ｙ

FLAG_KETTEI	DW	0		; 決定フラグ

XX1		DW	0		; Ｘ
YY1		DW	0		; Ｙ
XX2		DW	0		; Ｘ
YY2		DW	0		; Ｙ

CODE	ENDS

	END
;
;	end of "WIDBORTH.ASM"
;
