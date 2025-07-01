; "WIDCMND.ASM" 486/50 make by R.H 1993/03/02
;
;
;	コマンド・ウインドウ
;
;
;	WIDCMND_INI	; WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳ初期化
;	WIDCMND		; WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳ
;	WIDCMND_HLT	; WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳﾎﾞﾀﾝ停止
;
;
;	0=スケジュール
;	1=ステータス
;	2=娘と話す
;	3=健康管理
;	4=プロフィール
;	5=街に行く
;	6=お城へ行く
;	7=持ち物
;	8=守護星に祈る
;
;
; (C)1993 ritsurou hashimoto.

INCLUDE	TSTSET.INC

BANK_PATTERN		EQU	22		; パターンバンク
BANK_AREA_BACK		EQU	0		; エリア待避バンク番号
BANK_BAK_CURS		EQU	1		; カーソル待避バンク番号
NORMAL_BANK		EQU	0		; 通常のパーツバンク番号

WD_INI_X1		EQU	60		; window 左上Ｘ
WD_INI_Y1		EQU	175		; window 左上Ｙ
WD_INI_XL		EQU	20		; window サイズＸ
WD_INI_YL		EQU	160		; window サイズＹ
WD_INI_CUR_BAK_XL	EQU	6		; cursole back 待避ｻｲｽﾞx.
WD_INI_CUR_BAK_YL	EQU	31		; cursole back 待避ｻｲｽﾞy.
WD_INI_CUR_S_BAK_XL	EQU	21		; schedule back 待避ｻｲｽﾞx.
WD_INI_CUR_S_BAK_YL	EQU	31		; schedule back 待避ｻｲｽﾞy.

PAT_FRAME		EQU	0		; pattern number frame.
PAT_MARU		EQU	1		; pattern number maru.
PAT_SCHEDULE		EQU	3		; pattern number schedule.
PAT_GIRL		EQU	5		; pattern number girl off.
PAT_CASTLE		EQU	6		; pattern number castle off.

OFFF			EQU	-1		; off.
EOS			EQU	0		; end of string.

FUNC	MACRO	SUB
PUBLIC	SUB
SUB	PROC	NEAR
	ENDM

FEND	MACRO	SUB
SUB	ENDP
	ENDM

STRS	MACRO	RRR,STRING
	LOCAL	L1,L2
	JMP	L2
L1	DB	STRING,0
L2:
	MOV	RRR,OFFSET L1
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

; ****************************************************
;	WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳ初期化
; ****************************************************

FUNC	WIDCMND_INI
	STRS	SI,"FXCMND"
	MOV	DX,BANK_PATTERN		; パターンバンク
	CALLE	PT_PATTERN_LD		;pattern load.
	STRS	SI,"FXCMN2"
	CALLE	PT_PATTERN_LDA		;pattern add load.
	STRS	SI,"FXCMN3"
	CALLE	PT_PATTERN_LDA		;pattern add load.
	RET
FEND	WIDCMND_INI


; ****************************************************
;	WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳ
;	-O- AX : ｺﾏﾝﾄﾞ番号
;	0=スケジュール
;	1=ステータス
;	2=娘と話す
;	3=健康管理
;	4=プロフィール
;	5=街に行く
;	6=お城へ行く
;	7=持ち物
;	8=守護星に祈る
; ****************************************************

FUNC	WIDCMND
	CALL	WIDCMND_OPEN		; WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳOPEN

	CALL	WIDCMND_SLCT		; WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳ選択

	CALL	WIDCMND_CLOSE		; WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳCLOSE

	MOV	AX,SLC_CMND		; ｺﾏﾝﾄﾞ番号
	RET
FEND	WIDCMND


; ****************************************************
;	WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳﾎﾞﾀﾝ停止
;	-I- BX : ｺﾏﾝﾄﾞ番号
;	    CX : 1=ｺﾏﾝﾄﾞOFF
; ****************************************************

FUNC	WIDCMND_HLT
	CMP	BX,9			; ｺﾏﾝﾄﾞ番号
	JNB	WIDCMND_HLT_EXIT	;
	SHL	BX,1			; word pointer.
	MOV	TBL_CMND_OFF[BX],CX	; botton off table.
WIDCMND_HLT_EXIT:
	RET
FEND	WIDCMND_HLT


; ****************************************************
;	WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳOPEN
; ****************************************************

WIDCMND_OPEN	PROC	NEAR
	CALL	WIDAREA_BACK		; ウインドウエリア待避

	MOV	DX,BANK_PATTERN		; パターンバンク
	CALLE	PT_PATTERN_BANK		;pattern bank set.

	MOV	AX,WINDOW_X1		; window 左上Ｘ
	MOV	BX,WINDOW_Y1		; window 左上Ｙ
	MOV	DX,0			; pattern number.
	CALLE	PT_PATTERN_PUT		; pattern put.

	CALL	ALL_HLT_PUT		; all halt pattern put.

	MOV	CUR_BACK_NUM,OFFF	; cursole back ﾃﾞｰﾀﾌｧｲﾙ番号
	RET
WIDCMND_OPEN	ENDP


; ****************************************************
;	WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳCLOSE
; ****************************************************

WIDCMND_CLOSE	PROC	NEAR
	CALL	WIDAREA_RESTOR		; ウインドウエリア復元
	RET
WIDCMND_CLOSE	ENDP


; ****************************************************
;	WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳ選択
;	-O- SLC_CMND : ｺﾏﾝﾄﾞ番号
;	0=スケジュール
;	1=ステータス
;	2=娘と話す
;	3=健康管理
;	4=プロフィール
;	5=街に行く
;	6=お城へ行く
;	7=持ち物
;	8=守護星に祈る
; ****************************************************

WIDCMND_SLCT	PROC	NEAR
	CMP	DEBUGXX,55		;55=ランダムセレクト
	JE	WIDCMND_SLCT_DEMO	;

	CALL	CMND_MAIN		; ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳ選択メイン
	RET
WIDCMND_SLCT_DEMO:
	MOV	CX,9			; 最大値(1-200)
	CALLE	XRANDAM			; randam.
	DEC	BX			; -1
	MOV	SLC_CMND,BX		; ｺﾏﾝﾄﾞ番号
	RET
WIDCMND_SLCT	ENDP


; ****************************************************
;	ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳ選択メイン
;	-O- SLC_CMND : ｺﾏﾝﾄﾞ番号
; ****************************************************

CMND_MAIN	PROC	NEAR
	CALLE	MSCSRT			; カーソルスタート

CMND_MAIN_LOOP:
	CALLE	MSCMOV			; カーソル移動
	MOV	MOUSE_X,AX		; mouse x.
	MOV	MOUSE_Y,BX		; mouse y.
	MOV	MUSBOTTONL,DH		; 左ボタン(1:OFF/0:ON)
	MOV	MUSBOTTONR,DL		; 右ボタン(1:OFF/0:ON)

	CALL	AREA_CHECK		; エリアチェック
	CALL	CURSOLE_PUT		; cursole put.

	CMP	MUSBOTTONL,0		; 左ボタン(1:OFF/0:ON)
	JE	CMND_MAIN_ON		;
	CMP	MUSBOTTONR,0		; 右ボタン(1:OFF/0:ON)
	JE	CMND_MAIN_CANCEL	;

	JMP	CMND_MAIN_NEXT

CMND_MAIN_ON:
	CMP	SLC_CMND,OFFF		; ｺﾏﾝﾄﾞ番号
	JNE	CMND_MAIN_LOOP_E	;
	JMP	CMND_MAIN_NEXT		;

CMND_MAIN_CANCEL:
CMND_MAIN_NEXT:
	JMP	CMND_MAIN_LOOP

CMND_MAIN_LOOP_E:

CMND_MAIN_EXIT:
	CALLE	MSCSTP			; カーソルストップ
	RET
CMND_MAIN	ENDP


; ****************************************************
;	エリアチェック
;	-I- MOUSE_X  : mouse x.
;	    MOUSE_Y  : mouse y.
;	-O- SLC_CMND : ｺﾏﾝﾄﾞ番号
; ****************************************************

AREA_CHECK	PROC	NEAR
	MOV	SLC_CMND,0			; ｺﾏﾝﾄﾞ番号
	MOV	SI,OFFSET TBL_CMND_AREA		; command area table.
	MOV	DI,OFFSET TBL_CMND_OFF		; botton off table.
	MOV	BX,MOUSE_X			; mouse x.
	MOV	DX,MOUSE_Y			; mouse y.
	SUB	BX,WINDOW_X1			; window 左上Ｘ
	SUB	DX,WINDOW_Y1			; window 左上Ｙ
	MOV	CX,CMND_AREA_MAX		; command botton area max.
AREA_CHECK_LOOP:				;
	CMP	WORD PTR DS:[DI],0		;
	JNE	AREA_CHECK_NEXT			;

	CMP	DS:[SI],BX			;x1
	JG	AREA_CHECK_NEXT
	CMP	DS:[SI][2],DX			;y1
	JG	AREA_CHECK_NEXT
	CMP	DS:[SI][4],BX			;x2
	JL	AREA_CHECK_NEXT
	CMP	DS:[SI][6],DX			;y2
	JL	AREA_CHECK_NEXT
	JMP	AREA_CHECK_EXIT
AREA_CHECK_NEXT:
	ADD	SI,8
	INC	DI
	INC	DI
	INC	SLC_CMND			; ｺﾏﾝﾄﾞ番号
	LOOP	AREA_CHECK_LOOP			;
	MOV	SLC_CMND,OFFF			; ｺﾏﾝﾄﾞ番号
AREA_CHECK_EXIT:
	RET
AREA_CHECK	ENDP


; ****************************************************
;	all halt pattern put.
; ****************************************************

ALL_HLT_PUT	PROC	NEAR
	MOV	SLC_CMND,0		; ｺﾏﾝﾄﾞ番号
	MOV	CX,CMND_AREA_MAX	; command botton area max.
ALL_HLT_PUT_LOOP:			;
	PUSH	CX			;

	MOV	BX,SLC_CMND		; ｺﾏﾝﾄﾞ番号
	SHL	BX,1			; word pointer.
	CMP	TBL_CMND_OFF[BX],0	; botton off table.
	JE	ALL_HLT_PUT_NEXT	;

	CALL	CURSOLE_XY		; cursole locate.

	MOV	DX,BANK_PATTERN		; パターンバンク
	CALLE	PT_PATTERN_BANK		; pattern bank set.

	CMP	SLC_CMND,2		; ｺﾏﾝﾄﾞ番号
	JE	ALL_HLT_PUT_4		;

	MOV	DX,PAT_CASTLE		; pattern number castle off.
	JMP	ALL_HLT_PUT_5		;
ALL_HLT_PUT_4:				;
	MOV	DX,PAT_GIRL		; pattern number girl off.
ALL_HLT_PUT_5:

	MOV	AX,WID_CUR_X		; cursole x.
	MOV	BX,WID_CUR_Y		; cursole y.
	CALLE	PT_PATTERN_PUT		; pattern put.

ALL_HLT_PUT_NEXT:			;
	INC	SLC_CMND		; ｺﾏﾝﾄﾞ番号
	POP	CX			;
	LOOP	ALL_HLT_PUT_LOOP	;

	RET
ALL_HLT_PUT	ENDP


; ****************************************************
;	cursole put.
;	-I- SLC_CMND : ｺﾏﾝﾄﾞ番号
; ****************************************************

CURSOLE_PUT	PROC	NEAR
	CMPX	SLC_CMND,CUR_BACK_NUM		; cursole back ｺﾏﾝﾄﾞ番号
	JE	CURSOLE_PUT_EXIT		;

	CMP	CUR_BACK_NUM,OFFF		; cursole back ﾃﾞｰﾀﾌｧｲﾙ番号
	JE	CURSOLE_PUT_3			;

	CALLE	MSCSTP				; カーソルストップ
	CALL	CURSOLE_RESTOR			; cursole restore.
	CALLE	MSCSRT				; カーソルスタート

CURSOLE_PUT_3:
	CMP	SLC_CMND,OFFF			; ｺﾏﾝﾄﾞ番号
	JE	CURSOLE_PUT_6			;

	CALLE	MSCSTP				; カーソルストップ
	CALL	CURSOLE_XY			; cursole locate.
	CALL	CURSOLE_BACK			; cursole back.
	CALL	CURSOLE_PAT			; cursole pattern.
	CALLE	MSCSRT				; カーソルスタート

CURSOLE_PUT_6:
	MOVX	CUR_BACK_NUM,SLC_CMND		; cursole back ﾃﾞｰﾀﾌｧｲﾙ番号

CURSOLE_PUT_EXIT:
	RET
CURSOLE_PUT	ENDP


; ****************************************************
;	cursole locate.
;	-I- SLC_CMND     : ｺﾏﾝﾄﾞ番号
;	-O- WID_CUR_X    : cursole x.
;	    WID_CUR_Y    : cursole y.
; ****************************************************

CURSOLE_XY	PROC	NEAR
	MOV	BX,SLC_CMND		; ｺﾏﾝﾄﾞ番号
	SHL	BX,1			; 2word pointer.
	SHL	BX,1			;
	MOV	AX,TBL_CMND_XY[BX]	; command point.
	MOV	DX,TBL_CMND_XY[BX][2]	; command point.
	ADD	AX,WINDOW_X1		; window 左上Ｘ
	ADD	DX,WINDOW_Y1		; window 左上Ｙ
	MOV	WID_CUR_X,AX		; cursole x.
	MOV	WID_CUR_Y,DX		; cursole y.
	RET
CURSOLE_XY	ENDP


; ****************************************************
;	cursole pattern.
;	-I- WID_CUR_X : cursole x.
;	    WID_CUR_Y : cursole y.
;	    SLC_CMND  : ｺﾏﾝﾄﾞ番号
; ****************************************************

CURSOLE_PAT	PROC	NEAR
	MOV	DX,BANK_PATTERN		; パターンバンク
	CALLE	PT_PATTERN_BANK		; pattern bank set.

	CMP	SLC_CMND,0		; ｺﾏﾝﾄﾞ番号
	JE	CURSOLE_PAT_SCHED	;

	MOV	AX,WID_CUR_X		; cursole x.
	MOV	BX,WID_CUR_Y		; cursole y.
	MOV	DX,PAT_MARU		; pattern number maru.
	CALLE	PT_MASK_PAT_PUT		; pattern mask put.
	JMP	CURSOLE_PAT_EXIT	;

CURSOLE_PAT_SCHED:
	MOV	AX,WID_CUR_X		; cursole x.
	MOV	BX,WID_CUR_Y		; cursole y.
	MOV	DX,PAT_SCHEDULE		; pattern number schedule.
	CALLE	PT_MASK_PAT_PUT		; pattern mask put.

CURSOLE_PAT_EXIT:
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

	MOV	DX,BANK_BAK_CURS	; カーソル待避バンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.

	CALLE	PT_PATTERN_CLEAR	; parts buffer clear.

	CMP	SLC_CMND,0		; ｺﾏﾝﾄﾞ番号
	JNE	CURSOLE_BACK_3		;
	MOV	CX,WID_CUR_S_BAK_XL	; schedule back 待避ｻｲｽﾞx.
	MOV	DX,WID_CUR_S_BAK_YL	; schedule back 待避ｻｲｽﾞy.
	JMP	CURSOLE_BACK_4		;
CURSOLE_BACK_3:
	MOV	CX,WID_CUR_BAK_XL	; cursole back 待避ｻｲｽﾞx.
	MOV	DX,WID_CUR_BAK_YL	; cursole back 待避ｻｲｽﾞy.
CURSOLE_BACK_4:

	MOV	AX,WID_CUR_BAK_X	; cursole back x.
	MOV	BX,WID_CUR_BAK_Y	; cursole back y.
	CALLE	PT_PATTERN_GET		; parts get.

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.
	RET
CURSOLE_BACK	ENDP


; ****************************************************
;	cursole restore.
; ****************************************************

CURSOLE_RESTOR	PROC	NEAR
	MOV	DX,BANK_BAK_CURS	; カーソル待避バンク番号
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
; ****************************************************

WIDAREA_BACK	PROC	NEAR
	MOV	CX,0			;0=ARAVRM : ＶＲＡＭプレーン
	MOV	DX,0			;0=SSGR0  : visual data segment plean.
	CALLE	VRAMASSIGN		; vram assign.

	MOV	DX,BANK_AREA_BACK	; エリア待避バンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.

	CALLE	PT_PATTERN_CLEAR	; parts buffer clear.

	MOV	AX,WINDOW_X1		; window 左上Ｘ
	MOV	BX,WINDOW_Y1		; window 左上Ｙ
	MOV	CX,WINDOW_XL		; window 待避サイズＸ
	MOV	DX,WINDOW_YL		; window 待避サイズＹ
	CALLE	PT_PATTERN_GET		; parts get.

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.

	RET
WIDAREA_BACK	ENDP


; ****************************************************
;	ウインドウエリア復元
; ****************************************************

WIDAREA_RESTOR	PROC	NEAR
	MOV	CX,0			;0=ARAVRM : ＶＲＡＭプレーン
	MOV	DX,0			;0=SSGR0  : visual data segment plean.
	CALLE	VRAMASSIGN		; vram assign.

	MOV	DX,BANK_AREA_BACK	; エリア待避バンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.

	MOV	AX,WINDOW_X1		; window 左上Ｘ
	MOV	BX,WINDOW_Y1		; window 左上Ｙ
	MOV	DX,0			; pattern number.
	CALLE	PT_PATTERN_PUT		; pattern put.

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALLE	PT_PATTERN_BANK		; pattern bank set.
	RET
WIDAREA_RESTOR	ENDP


; ****************************************************
;	data.
; ****************************************************

EXTRN	DEBUGXX:WORD			; debug mode.
					;デモフラグ0=通常,55=ランダムセレクト

		EVEN
WINDOW_X1	DW	WD_INI_X1	; window 左上Ｘ
WINDOW_Y1	DW	WD_INI_Y1	; window 左上Ｙ
WINDOW_XL	DW	WD_INI_XL	; window 待避サイズＸ
WINDOW_YL	DW	WD_INI_YL	; window 待避サイズＹ

WID_CUR_X	DW	0			; cursole x.
WID_CUR_Y	DW	0			; cursole y.
WID_CUR_BAK_X	DW	0			; cursole back x.
WID_CUR_BAK_Y	DW	0			; cursole back y.
WID_CUR_BAK_XL	DW	WD_INI_CUR_BAK_XL	; cursole back 待避ｻｲｽﾞx.
WID_CUR_BAK_YL	DW	WD_INI_CUR_BAK_YL	; cursole back 待避ｻｲｽﾞy.
WID_CUR_S_BAK_XL DW	WD_INI_CUR_S_BAK_XL	; schedule back 待避ｻｲｽﾞx.
WID_CUR_S_BAK_YL DW	WD_INI_CUR_S_BAK_YL	; schedule back 待避ｻｲｽﾞy.

CMND_AREA_MAX	DW	9		; command botton area max.
TBL_CMND_AREA	LABEL	WORD		; command area table.
		DW	1+0,	5+65,	0+19,	4+65+29
		DW	1+0,	5+0,	0+4,	4+29
		DW	1+5,	5+0,	5+4,	4+29
		DW	1+10,	5+0,	10+4,	4+29
		DW	1+15,	5+0,	15+4,	4+29
		DW	1+0,	5+32,	0+4,	4+32+29
		DW	1+5,	5+32,	5+4,	4+32+29
		DW	1+10,	5+32,	10+4,	4+32+29
		DW	1+15,	5+32,	15+4,	4+32+29

TBL_CMND_XY	LABEL	WORD		; command point.
		DW	0,	67
		DW	0,	0
		DW	5,	0
		DW	10,	0
		DW	15,	0
		DW	0,	32
		DW	5,	32
		DW	10,	32
		DW	15,	32

TBL_CMND_OFF	DW	9 DUP (0)	; botton off table.

MOUSE_X		DW	0		; mouse x.
MOUSE_Y		DW	0		; mouse y.
MUSBOTTONL	DB	0,0		; 左ボタン(1:OFF/0:ON)
MUSBOTTONR	DB	0,0		; 右ボタン(1:OFF/0:ON)

SLC_CMND	DW	0		; ｺﾏﾝﾄﾞ番号
CUR_BACK_NUM	DW	OFFF		; cursole back ﾃﾞｰﾀﾌｧｲﾙ番号

CODE	ENDS

	END
;
;	end of "WIDCMND.ASM"
;
