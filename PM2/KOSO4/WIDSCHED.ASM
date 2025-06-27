; "WIDSCHED.ASM" 486/50 make by R.H 1992/05/21
;
;
;	ＷＩＮＤＯＷＳ／スケジュール・ウインドウ
;
;
;	WIDSCHD_OPEN		; WINDOWS/ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ OPEN
;	WIDSCHD_CLOSE		; WINDOWS/ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ CLOSE
;	WIDSCHD_SET_ICON	; WINDOWS/ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ SET ICON
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

WD_INI_BAK_BANK	EQU	2		; window エリア退避バンク番号
WD_INI_X1	EQU	1		; window 左上Ｘ
WD_INI_Y1	EQU	8		; window 左上Ｙ
WD_INI_XL	EQU	30		; window サイズＸ
WD_INI_YL	EQU	240;186;154	; window サイズＹ

NORMAL_BANK	EQU	0		; 通常のパーツバンク番号

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ OPEN
;	-I- AX : 開始日付
;	    BX : 開始曜日
;	    CX : 終了日付
;	    DX : 月
;	    SI : 年
;	-O- SCH_STARTDAY[3] : スケジュール開始日
;	    SCH_ENDDAY[3]   : スケジュール終了日
;	    SCH_COUNT       : スケジュール数
; ****************************************************

FUNC	WIDSCHD_OPEN
	MOV	START_DAY,AX		; 開始日付
	MOV	START_WEEK,BX		; 開始曜日
	MOV	END_DAY,CX		; 終了日付
	MOV	SET_MONTH,DX		; 月
	MOV	SET_YEAR,SI		; 年

	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.

	CALL	WIDAREA_BACK		; ウインドウエリア退避

	MOVX	WDX1,WINDOW_X1		; window 左上Ｘ
	MOVX	WDY1,WINDOW_Y1		; window 左上Ｙ
	MOVX	WDX2,WINDOW_X2		; window フレームサイズＸ
	MOVX	WDY2,WINDOW_Y2		; window フレームサイズＹ
	CALL_w	WID_FLAME_SCHED		; WINDOWS/スケジュール・フレーム

	CALL	DAY_PRINT_SET		; 全日付を書く

	CALL	SCHEDULE_DAYS		; スケジュールする日を計算
	RET
FEND	WIDSCHD_OPEN


; ****************************************************
;	WINDOWS/ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ CLOSE
; ****************************************************

FUNC	WIDSCHD_CLOSE
	CALL	WIDAREA_RESTOR		; ウインドウエリア復元
	RET
FEND	WIDSCHD_CLOSE


; ****************************************************
;	WINDOWS/ｽｹｼﾞｭｰﾙ･ｳｲﾝﾄﾞｳ SET ICON
;	-I- AX : 開始日付
;	    BX : 終了日付
;	    CX : ＩＣＯＮ番号
; ****************************************************

FUNC	WIDSCHD_SET_ICON
	MOV	ICONNUM,CX		; ＩＣＯＮ番号

	CMP	AX,BX			;
	JNBE	WIDSCHD_SET_ICON_ERROR	;

	MOV	DAY_COUNT,AX		; day counter.
	SUB	BX,AX			; 終了日付－開始日付
	INC	BX			;
	CMP	BX,32			;
	JNBE	WIDSCHD_SET_ICON_ERROR	;
	MOV	CX,BX			;
WIDSCHD_SET_ICON_LOOP:			;
	PUSH	CX			;
	MOV	DX,DAY_COUNT		; day counter.
	CALL	DAY_TO_LOCATE		; day to locate.

	CMP	ICONNUM,-1		; ＩＣＯＮ番号
	JNE	WIDSCHD_SET_ICON_4	;

	CALL	CLEAR_ICON		; ICON clear.
	JMP	WIDSCHD_SET_ICON_5	;

WIDSCHD_SET_ICON_4:
	MOV	AX,LOC_X		; locate x.
	MOV	BX,LOC_Y		; locate y.
	MOV	DX,ICONNUM		; ＩＣＯＮ番号
	CALL_w	ICON_PUT		; ICON put.

WIDSCHD_SET_ICON_5:
	MOV	DX,DAY_COUNT		; day counter.
	CALL	DRAW_DAY		; 日付書き
	INC	DAY_COUNT		; day counter.
	POP	CX			;
	LOOP	WIDSCHD_SET_ICON_LOOP	;

	RET
WIDSCHD_SET_ICON_ERROR:
	RET
FEND	WIDSCHD_SET_ICON


; ****************************************************
;	スケジュールする日を計算
; ****************************************************

SCHEDULE_DAYS	PROC	NEAR
	MOV	SCH_COUNT,1		; スケジュール数

	MOV	AX,START_DAY		; 開始日付
	MOV	SCH_STARTDAY[0],AX	; スケジュール開始日
	ADD	AX,9+3			; 差が３日程度ならば含ませる
	CMP	AX,END_DAY		; スケジュール終了日
	JB	SCHEDULE_DAYS_2		;

	MOV	AX,END_DAY		; スケジュール終了日
	MOV	SCH_ENDDAY[0],AX	; スケジュール終了日
	JMP	SCHEDULE_DAYS_EXIT	;

SCHEDULE_DAYS_2:
	SUB	AX,3			;
	MOV	SCH_ENDDAY[0],AX	; スケジュール終了日


	MOV	SCH_COUNT,2		; スケジュール数

	INC	AX			;
	MOV	SCH_STARTDAY[2],AX	; スケジュール開始日
	ADD	AX,9+3			; 差が３日程度ならば含ませる
	CMP	AX,END_DAY		; スケジュール終了日
	JB	SCHEDULE_DAYS_4		;

	MOV	AX,END_DAY		; スケジュール終了日
	MOV	SCH_ENDDAY[2],AX	; スケジュール終了日
	JMP	SCHEDULE_DAYS_EXIT	;

SCHEDULE_DAYS_4:
	SUB	AX,3			;
	MOV	SCH_ENDDAY[2],AX	; スケジュール終了日

	MOV	SCH_COUNT,3		; スケジュール数

	INC	AX			;
	MOV	SCH_STARTDAY[4],AX	; スケジュール開始日
	MOV	AX,END_DAY		; スケジュール終了日
	MOV	SCH_ENDDAY[4],AX	; スケジュール終了日

SCHEDULE_DAYS_EXIT:
	RET
SCHEDULE_DAYS	ENDP


; ****************************************************
;	全日付を書く
; ****************************************************

DAY_PRINT_SET	PROC	NEAR
	MOV	AX,END_DAY		; 終了日付
	MOV	BX,START_DAY		; 開始日付
	DEC	BX			; - 1
	SUB	AX,BX			;
	ADD	AX,START_WEEK		; 開始曜日

	CMP	AX,0			;
	JE	DAY_PRINT_SET_EXIT	;
	MOV	DX,0			;
	MOV	BX,7			; / 7
	DIV	BX			;
	CMP	DX,0			;
	JE	DAY_PRINT_SET_2		;
	INC	AX			;
DAY_PRINT_SET_2:			; AX=必要な行数
	MOV	WD_DAY_CNT_Y,AX		; window 日付 count y.

	CALL	DRAW_MONTH_YEAR		; 年月を書く
	CALL	DRAW_ALL_DAYS		; 日付を描く

DAY_PRINT_SET_EXIT:
	RET
DAY_PRINT_SET	ENDP


; ****************************************************
;	年月を書く
; ****************************************************

DRAW_MONTH_YEAR	PROC	NEAR
	MOV	DX,SET_YEAR		; 年
	CALL_w	PT_SCHED_YEAR		; schedule year.

	MOV	DX,SET_MONTH		; 月
	CALL_w	PT_SCHED_MONTH		; schedule month.
	RET
DRAW_MONTH_YEAR	ENDP


; ****************************************************
;	日付を描く
; ****************************************************

DRAW_ALL_DAYS	PROC	NEAR
	MOV	AX,0			; グラフ文字表示サイズ
	CALL_w	VTXSIZ			; character size set.

	MOV	AX,15			; グラフ文字表示色
	CALL_w	VTXCOL			; character color set.

	MOVX	DAY_COUNT,START_DAY	; 開始日付

DRAW_ALL_DAYS_LOOP:
	MOV	DX,DAY_COUNT		; day counter.
	CALL	DAY_TO_LOCATE		; day to locate.

	CALL	CLEAR_ICON		; ICON clear.

	MOV	DX,DAY_COUNT		; day counter.
	CALL	DRAW_DAY		; 日付書き

	INC	DAY_COUNT		;
	CMPX	DAY_COUNT,END_DAY	; 終了日付
	JBE	DRAW_ALL_DAYS_LOOP	;
	RET
DRAW_ALL_DAYS	ENDP


; ****************************************************
;	ICON clear.
;	-I- LOC_X   : locate x.
;	    LOC_Y   : locate y.
; ****************************************************

CLEAR_ICON	PROC	NEAR
	MOV	AX,LOC_X
	MOV	BX,LOC_Y
	CALL_w	PT_SCHED_ICON_CLEAR	; schedule clear.
	RET
CLEAR_ICON	ENDP


; ****************************************************
;	日付書き
;	-I- LOC_X   : locate x.
;	    LOC_Y   : locate y.
;	    N_WEEK  : week.0=san,...6=sat
;	    DX      : day.
; ****************************************************

DRAW_DAY	PROC	NEAR
	MOV	AX,LOC_X		; locate x.
	MOV	BX,LOC_Y		; locate y.
	CALL_w	PT_SCHED_DAY		; schedule day.
	RET
DRAW_DAY	ENDP


; ****************************************************
;	day to locate.
;	-I- DX    : day
;	-O- LOC_X : locate x.
;	    LOC_Y : locate y.
;	    N_WEEK: week.0=san,...6=sat
; ****************************************************

DAY_TO_LOCATE	PROC	NEAR
	SUB	DX,START_DAY		; day － 開始日付

	ADD	DX,START_WEEK		; 開始曜日

	MOV	AX,DX			;
	MOV	DX,0			;
	MOV	BX,7			;
	DIV	BX			; DX=X,AX=Y
	MOV	CNT_X,DX		; count x.
	MOV	CNT_Y,AX		; count y.

	MOV	N_WEEK,DX		; week.0=san,...6=sat

	MOV	AX,CNT_X		; count x.
	MUL	WD_DAY_STEP_X		; window 日付間隔 start x.
	ADD	AX,WD_DAY_SRT_X		; window 日付 start x.
	MOV	LOC_X,AX		; locate x.

	MOV	AX,CNT_Y		; count y.
	MUL	WD_DAY_STEP_Y		; window 日付間隔 start y.
	ADD	AX,WD_DAY_SRT_Y		; window 日付 start y.
	MOV	LOC_Y,AX		; locate y.

	RET
DAY_TO_LOCATE	ENDP


; ****************************************************
;	ウインドウエリア退避
;	-I- WINDOW_X1  : window 左上Ｘ
;	    WINDOW_Y1  : window 左上Ｙ
;	    WINDOW_XL  : window 退避サイズＸ
;	    WINDOW_YL  : window 退避サイズＹ
;	    WINDOW_BAK_BANK : window エリア退避バンク番号
; ****************************************************

WIDAREA_BACK	PROC	NEAR
	CMP	WINDOW_BAK_BANK,-1	; window エリア退避バンク番号
	JNE	WIDAREA_BACK_START	;
	RET
WIDAREA_BACK_START:

	MOV	DX,WINDOW_BAK_BANK	; window エリア退避バンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	CALL_w	C1PATCLR		; パーツセットクリア

	MOVX	VRX,WINDOW_X1		; window 左上Ｘ
	MOVX	VRY,WINDOW_Y1		; window 左上Ｙ
	MOVX	VRLENX,WINDOW_XL	; window 退避サイズＸ
	MOVX	VRLENY,WINDOW_YL	; window 退避サイズＹ
	CALL_w	C1PATGTA		; パーツＧＥＴ圧縮無し

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	RET
WIDAREA_BACK	ENDP


; ****************************************************
;	ウインドウエリア復元
;	-I- WINDOW_BAK_BANK : window エリア退避バンク番号
; ****************************************************

WIDAREA_RESTOR	PROC	NEAR
	CMP	WINDOW_BAK_BANK,-1	; window エリア退避バンク番号
	JNE	WIDAREA_RESTOR_START	;
	RET
WIDAREA_RESTOR_START:			;

	MOV	DX,WINDOW_BAK_BANK	; window エリア退避バンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOV	CX,0			; パーツ番号
	CALL_w	C1PATPUT		; パーツＰＵＴ

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ
	RET
WIDAREA_RESTOR	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SCH_STARTDAY:WORD	; スケジュール開始日
EXTRN	SCH_ENDDAY:WORD		; スケジュール終了日
EXTRN	SCH_COUNT:WORD		; スケジュール数

WINDOW_BAK_BANK	DW	WD_INI_BAK_BANK	; window エリア退避バンク番号
WINDOW_X1	DW	WD_INI_X1	; window 左上Ｘ
WINDOW_Y1	DW	WD_INI_Y1	; window 左上Ｙ
WINDOW_X2	DW	WD_INI_XL	; window フレームサイズＸ
WINDOW_Y2	DW	WD_INI_YL	; window フレームサイズＹ
WINDOW_XL	DW	WD_INI_XL	; window 退避サイズＸ
WINDOW_YL	DW	WD_INI_YL	; window 退避サイズＹ

WD_DAY_YEAR_X	DW	WD_INI_X1+4	; window 年 start x.
WD_DAY_YEAR_Y	DW	WD_INI_Y1+8	; window 年 start y.
WD_DAY_MONTH_X	DW	WD_INI_X1+12	; window 月 start x.
WD_DAY_MONTH_Y	DW	WD_INI_Y1+8	; window 月 start y.
WD_DAY_WEEK_X	DW	WD_INI_X1+1	; window 曜日 start x.
WD_DAY_WEEK_Y	DW	WD_INI_Y1+24	; window 曜日 start y.
WD_DAY_SRT_X	DW	WD_INI_X1+1	; window 日付 start x.
WD_DAY_SRT_Y	DW	WD_INI_Y1+40	; window 日付 start y.
WD_DAY_STEP_X	DW	4		; window 日付間隔 start x.
WD_DAY_STEP_Y	DW	32;18		; window 日付間隔 start y.
WD_DAY_CNT_X	DW	7		; window 日付 count x.
WD_DAY_CNT_Y	DW	0		; window 日付 count y.

START_DAY	DW	0		; 開始日付
START_WEEK	DW	0		; 開始曜日
END_DAY		DW	0		; 終了日付
SET_MONTH	DW	0		; 月
SET_YEAR	DW	0		; 年

ICONNUM		DW	0		; ＩＣＯＮ番号

LOC_X		DW	0		; locate x.
LOC_Y		DW	0		; locate y.
CNT_X		DW	0		; count x.
CNT_Y		DW	0		; count y.
DAY_COUNT	DW	0		; day counter.
N_WEEK		DW	0		; week.0=san,...6=sat

XX1		DW	0		; x1.
YY1		DW	0		; y1.
XX2		DW	0		; x2.
YY2		DW	0		; y2.

DATA	ENDS

	END
;
;	end of "WIDSCHED.ASM"
;
