; "WIDDIRSL.ASM" 486/50 make by R.H 1992/10/23
;
;
;	ＷＩＮＤＯＷＳ／ＲＰＧ方向選択・ウインドウ
;
;
;	WIDDIRSL_PTLOAD		; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳﾊﾟﾀｰﾝLOAD
;	WIDDIRSL_OPEN		; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳOPEN
;	WIDDIRSL_CLOSE		; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE
;	WIDDIRSL_NOW_CLOSE	; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE
;	WIDDIRSL_RD		; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳREAD
;
;
;	1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ,6:左上,7:右上,8:左下,9:右下
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC
INCLUDE	MACHINEX.INC

DEF_MOUSE_MIN_X		EQU	0	; mouse locate area minmam x.
DEF_MOUSE_MIN_Y		EQU	0	; mouse locate area minmam y.
DEF_MOUSE_MAX_X		EQU	639	; mouse locate area maxmam x.
DEF_MOUSE_MAX_Y		EQU	399	; mouse locate area maxmam y.

RPG_MOUSE_MIN_X		EQU	512	; mouse locate area minmam x.
RPG_MOUSE_MIN_Y		EQU	0	; mouse locate area minmam y.
RPG_MOUSE_MAX_X		EQU	639	; mouse locate area maxmam x.
RPG_MOUSE_MAX_Y		EQU	399	; mouse locate area maxmam y.

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳﾊﾟﾀｰﾝLOAD
; ****************************************************

FUNC	WIDDIRSL_PTLOAD
	CALL_w	PT_YAJI_LD		; put yaji load.
	RET
FEND	WIDDIRSL_PTLOAD


; ****************************************************
;	WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳOPEN
; ****************************************************

FUNC	WIDDIRSL_OPEN
	MOV	AX,0			; 0=ＯＦＦ
	CALL_w	KEYHLT			; キーボード機能のＯＮ／ＯＦＦ

	MOV	AX,RPG_MOUSE_MIN_X	; mouse locate area minmam x.
	MOV	BX,RPG_MOUSE_MIN_Y	; mouse locate area minmam y.
	MOV	CX,RPG_MOUSE_MAX_X	; mouse locate area maxmam x.
	MOV	DX,RPG_MOUSE_MAX_Y	; mouse locate area maxmam y.
	CALL_w	MUSAREA			; マウスエリアの設定

WIDDIRSL_OPEN_2:
;*;	CALL_w	KEYRET			; キーボード・ＲＥＴキー読み込み
;*;	CMP	AX,1			; 1=RETURN,2=ZERO (-1:押していない)
;*;	JE	WIDDIRSL_OPEN_2		;

	CMP	KYONL,0			; key left  bottan.(0=ON)
	JE	WIDDIRSL_OPEN_2		;
	CMP	KYONR,0			; key right bottan.(0=ON)
	JE	WIDDIRSL_OPEN_2		;

	CMP	KYLC_TIMER_KYDRX,0	; time sampling key direction x(+-)
	JNE	WIDDIRSL_OPEN_2		;
	CMP	KYLC_TIMER_KYDRY,0	; time sampling key direction y(+-)
	JNE	WIDDIRSL_OPEN_2		;

WIDDIRSL_OPEN_4:			;
	CALL_w	MUSRED			; マウス読み込み
	CMP	DH,0			; マウスボタン左
	JE	WIDDIRSL_OPEN_4		;
	CMP	DL,0			; マウスボタン右
	JE	WIDDIRSL_OPEN_4		;

	CALL_w	MUSDSP			; マウスＤＩＲのクリア

	MOV	NOW_SLCNUM,0		; 現在のボタン選択番号
	CALL	WIDOPEN			; window open.

	MOV	FLAG_DIRSL_OPEN,1	; flag ｳｲﾝﾄﾞｳOPEN
	RET
FEND	WIDDIRSL_OPEN


; ****************************************************
;	WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE
; ****************************************************

FUNC	WIDDIRSL_CLOSE

WIDDIRSL_CLOSE_2:
;*;	CALL_w	KEYRET			; キーボード・ＲＥＴキー読み込み
;*;	CMP	AX,1			; 1=RETURN,2=ZERO (-1:押していない)
;*;	JE	WIDDIRSL_CLOSE_2	;

	CMP	KYONL,0			; key left  bottan.(0=ON)
	JE	WIDDIRSL_CLOSE_2	;
	CMP	KYONR,0			; key right bottan.(0=ON)
	JE	WIDDIRSL_CLOSE_2	;

	CMP	KYLC_TIMER_KYDRX,0	; time sampling key direction x(+-)
	JNE	WIDDIRSL_CLOSE_2	;
	CMP	KYLC_TIMER_KYDRY,0	; time sampling key direction y(+-)
	JNE	WIDDIRSL_CLOSE_2	;

;*;WIDDIRSL_CLOSE_4:			;
;*;	CALL_w	MUSRED			; マウス読み込み
;*;	CMP	DH,0			; マウスボタン左
;*;	JE	WIDDIRSL_CLOSE_4	;
;*;	CMP	DL,0			; マウスボタン右
;*;	JE	WIDDIRSL_CLOSE_4	;

	CALL_w	MSCSTS			; マウスカーソルステータス
	CMP	AX,0			; 0=マウスＯＦＦ,1=マウスカーソル表示中
	JE	WIDDIRSL_CLOSE_EXIT	;

	CALL_w	MSCSTP			; カーソルストップ
WIDDIRSL_CLOSE_EXIT:
	MOV	AX,NOW_SLCNUM		; 現在のボタン選択番号
	CMP	AX,5			; 5=camp.
	JE	WIDDIRSL_CLOSE_EXIT2	;
	CALL	BTN_OFF			; ボタンOFF
WIDDIRSL_CLOSE_EXIT2:
	MOV	AX,1			; 1=ＯＮ
	CALL_w	KEYHLT			; キーボード機能のＯＮ／ＯＦＦ

	MOV	AX,DEF_MOUSE_MIN_X	; mouse locate area minmam x.
	MOV	BX,DEF_MOUSE_MIN_Y	; mouse locate area minmam y.
	MOV	CX,DEF_MOUSE_MAX_X	; mouse locate area maxmam x.
	MOV	DX,DEF_MOUSE_MAX_Y	; mouse locate area maxmam y.
	CALL_w	MUSAREA			; マウスエリアの設定

	MOV	FLAG_DIRSL_OPEN,0	; flag ｳｲﾝﾄﾞｳOPEN
	RET
FEND	WIDDIRSL_CLOSE


; ****************************************************
;	WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE
;
;	called
;	"WIDTEXT.ASM"/WID_TEXT_PAUSE
;	"WIDSLCT.ASM"/WIDSLC
;	"WIDSLCT.ASM"/WIDSLC_RPGOPEN
; ****************************************************

FUNC	WIDDIRSL_NOW_CLOSE
	CMP	FLAG_DIRSL_OPEN,0	; flag ｳｲﾝﾄﾞｳOPEN
	JE	WIDDIRSL_NOW_CLOSE_E	;

	PUSH	ES
	PUSH	SI
	CALL	w_WIDDIRSL_CLOSE		; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE
	POP	SI
	POP	ES
WIDDIRSL_NOW_CLOSE_E:
	RET
FEND	WIDDIRSL_NOW_CLOSE


; ****************************************************
;	WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳREAD
;	-O- BX : ボタン選択番号
;		0:none,1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
;		6:左上,7:右上,8:左下,9:右下
;	    CX : x direction step.
;	    DX : y direction step.
; ****************************************************

FUNC	WIDDIRSL_RD
	CMP	WIDDDEMO,55		; デモフラグ0=通常,55=ランダムセレクト
	JE	WIDDIRSL_RD_DEMO	;

	CALL	WIDMAIN			; main.
	MOV	BX,SLCNUM		; ボタン選択番号
	MOV	CX,SLCXX		; Ｘ方向増分
	MOV	DX,SLCYY		; Ｙ方向増分
	RET

WIDDIRSL_RD_DEMO:
	MOV	AX,2		; wait timer count.
	CALL_w	TMVWAT		; V-SYNC timer wait.

	CMP	WIDDDEMO_NOW,5		; デモフラグ
	JNE	WIDDIRSL_RD_DEMO2	;
	MOV	AX,4
	CALL_w	RANDAM
	MOV	WIDDDEMO_NOW,AX
WIDDIRSL_RD_DEMO2:


	INC	WIDDDEMO_NOW2
	CMP	WIDDDEMO_NOW2,200
	JB	WIDDIRSL_RD_DEMO25
	MOV	WIDDDEMO_NOW2,0

	MOV	AX,10
	CALL_w	RANDAM
	CMP	AX,2
	JE	WIDDIRSL_RD_DEMO2CMP

	CMP	WIDDDEMO_NOW,1		; デモフラグ
	JE	WIDDIRSL_RD_DEMO23	;
	CMP	WIDDDEMO_NOW,2		; デモフラグ
	JE	WIDDIRSL_RD_DEMO24	;
	CMP	WIDDDEMO_NOW,3		; デモフラグ
	JE	WIDDIRSL_RD_DEMO22	;

WIDDIRSL_RD_DEMO21:
	MOV	WIDDDEMO_NOW,1		; デモフラグ
	JMP	WIDDIRSL_RD_DEMO25
WIDDIRSL_RD_DEMO22:
	MOV	WIDDDEMO_NOW,2		; デモフラグ
	JMP	WIDDIRSL_RD_DEMO25
WIDDIRSL_RD_DEMO23:
	MOV	WIDDDEMO_NOW,3		; デモフラグ
	JMP	WIDDIRSL_RD_DEMO25
WIDDIRSL_RD_DEMO24:
	MOV	WIDDDEMO_NOW,4		; デモフラグ
	JMP	WIDDIRSL_RD_DEMO25
WIDDIRSL_RD_DEMO2CMP:
	MOV	WIDDDEMO_NOW,5		; デモフラグ
WIDDIRSL_RD_DEMO25:
	MOV	BX,WIDDDEMO_NOW		; デモフラグ
	MOV	CX,0			; x direction step.
	MOV	DX,0			; y direction step.
	CMP	BL,1
	JE	WIDDIRSL_RD_DEMO_UP
	CMP	BL,2
	JE	WIDDIRSL_RD_DEMO_DN
	CMP	BL,3
	JE	WIDDIRSL_RD_DEMO_LL
	CMP	BL,4
	JE	WIDDIRSL_RD_DEMO_RR
	RET
WIDDIRSL_RD_DEMO_UP:
	MOV	DX,-1
	RET
WIDDIRSL_RD_DEMO_DN:
	MOV	DX,1
	RET
WIDDIRSL_RD_DEMO_LL:
	MOV	CX,1
	RET
WIDDIRSL_RD_DEMO_RR:
	MOV	CX,-1
	RET
FEND	WIDDIRSL_RD


; ****************************************************
;	main.
;	-O- SLCNUM : ボタン選択番号
;		0:none,1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
;		6:左上,7:右上,8:左下,9:右下
;	    SLCXX  : Ｘ方向増分
;	    SLCYY  : Ｙ方向増分
; ****************************************************

WIDMAIN	PROC	NEAR
	MOV	SLCXX,0			; Ｘ方向増分
	MOV	SLCYY,0			; Ｙ方向増分

	CALL	CHK_KEY_DIR		; check key direction.
	CMP	SLCNUM,0		; ボタン選択番号
	JE	WIDMAIN_MOUSE		;

WIDMAIN_KEYBORD:
	CALL_w	MSCSTS			; マウスカーソルステータス
	CMP	AX,0			; 0=マウスＯＦＦ,1=マウスカーソル表示中
	JE	WIDMAIN_2		;
	CALL_w	MSCSTP			; カーソルストップ
	CALL_w	MUSDSP			; マウスＤＩＲのクリア
WIDMAIN_2:
	CMPX	SLCNUM,NOW_SLCNUM	; 現在のボタン選択番号
	JE	WIDMAIN_EXIT		;

	MOV	AX,NOW_SLCNUM		; 現在のボタン選択番号
	CALL	BTN_OFF			; ボタンOFF
	MOV	AX,SLCNUM		; ボタン選択番号
	CALL	BTN_ON			; ボタンON
	MOVX	NOW_SLCNUM,SLCNUM	; 現在のボタン選択番号
	JMP	WIDMAIN_EXIT		;

WIDMAIN_MOUSE:
	CALL_w	MSCSTS			; マウスカーソルステータス
	CMP	AX,1			; 0=マウスＯＦＦ,1=マウスカーソル表示中
	JE	WIDMAIN_6		;

	CALL_w	MUSRED			; マウス読み込み
	CMP	DH,0			; マウスボタン左
	JE	WIDMAIN_5		;
	CMP	DL,0			; マウスボタン右
	JE	WIDMAIN_5		;

	CMP	MUSDRX,0		; mouse locate direction x(+-)
	JNE	WIDMAIN_5		;
	CMP	MUSDRY,0		; mouse locate direction y(+-)
	JNE	WIDMAIN_5		;

	CMP	NOW_SLCNUM,0		; 現在のボタン選択番号
	JE	WIDMAIN_EXIT		;
	MOV	AX,NOW_SLCNUM		; 現在のボタン選択番号
	CALL	BTN_OFF			; ボタンOFF
	MOV	NOW_SLCNUM,0		; 現在のボタン選択番号
	MOV	SLCNUM,0		; 現在のボタン選択番号
	JMP	WIDMAIN_EXIT		;

WIDMAIN_5:
	CALL_w	MSCSRT			; カーソルスタート
WIDMAIN_6:
	CALL_w	MSCMV2			; カーソル移動（遅延処理無し）
	MOV	MOUSEX,AX		; マウスＸ
	MOV	MOUSEY,BX		; マウスＹ
	MOV	MS_BTNL,DH		; マウスボタン左
	MOV	MS_BTNR,DL		; マウスボタン右

	CMP	DH,0			; left on.
	JE	WIDMAIN_CHK		;
	CMP	DL,0			; right on.
	JE	WIDMAIN_CHK		;

WIDMAIN_OFF:
	CMP	NOW_SLCNUM,0		; 現在のボタン選択番号
	JE	WIDMAIN_EXIT		;
	CALL_w	MSCSTP			; カーソルストップ
	MOV	AX,NOW_SLCNUM		; 現在のボタン選択番号
	CALL	BTN_OFF			; ボタンOFF
	CALL_w	MSCSRT			; カーソルスタート
	MOV	NOW_SLCNUM,0		; 現在のボタン選択番号
	MOV	SLCNUM,0		; 現在のボタン選択番号
	JMP	WIDMAIN_EXIT		;

WIDMAIN_CHK:
	CALL	SLCTCHK			; select check.
	CALL	DIR_STEP		; direction step.
	CMPX	SLCNUM,NOW_SLCNUM	; 現在のボタン選択番号
	JE	WIDMAIN_EXIT		;

	CALL_w	MSCSTP			; カーソルストップ
	MOV	AX,NOW_SLCNUM		; 現在のボタン選択番号
	CALL	BTN_OFF			; ボタンOFF
	MOV	AX,SLCNUM		; ボタン選択番号
	CALL	BTN_ON			; ボタンON
	MOVX	NOW_SLCNUM,SLCNUM	; 現在のボタン選択番号
	CMP	SLCNUM,5		; 5:ｷｬﾝﾌﾟ
	JE	WIDMAIN_CAMP		;

	CALL_w	MSCSRT			; カーソルスタート
	JMP	WIDMAIN_EXIT		;

WIDMAIN_CAMP:
	CALL_w	MSCSTS			; マウスカーソルステータス
	CMP	AX,0			; 0=マウスＯＦＦ,1=マウスカーソル表示中
	JE	WIDMAIN_EXIT		;
	CALL_w	MSCSTP			; カーソルストップ

WIDMAIN_EXIT:
	RET
WIDMAIN	ENDP


; ****************************************************
;	direction step.
;	-I- SLCNUM : ボタン選択番号
;		0:none,1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
; ****************************************************

DIR_STEP	PROC	NEAR
	MOV	SLCXX,0			; Ｘ方向増分
	MOV	SLCYY,0			; Ｙ方向増分
	MOV	AX,SLCNUM		; ボタン選択番号
	CMP	AL,1			; 1:上
	JE	DIR_STEP_UP		;
	CMP	AL,2			; 2:下
	JE	DIR_STEP_DOWN		;
	CMP	AL,3			; 3:左
	JE	DIR_STEP_LEFT		;
	CMP	AL,4			; 4:右
	JE	DIR_STEP_RIGHT		;
	RET
DIR_STEP_UP:
	MOV	SLCYY,-1		; Ｙ方向増分
	RET
DIR_STEP_DOWN:
	MOV	SLCYY,+1		; Ｙ方向増分
	RET
DIR_STEP_LEFT:
	MOV	SLCXX,-1		; Ｘ方向増分
	RET
DIR_STEP_RIGHT:
	MOV	SLCXX,+1		; Ｘ方向増分
	RET
DIR_STEP	ENDP


; ****************************************************
;	check key direction.
;	-O- SLCNUM : ボタン選択番号
;		0:none,1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
;		6:左上,7:右上,8:左下,9:右下
;	    SLCXX  : Ｘ方向増分
;	    SLCYY  : Ｙ方向増分
; ****************************************************

CHK_KEY_DIR	PROC	NEAR
	MOVX	SLCXX,KYLC_TIMER_KYDRX	; time sampling key direction x(+-)
	MOVX	SLCYY,KYLC_TIMER_KYDRY	; time sampling key direction y(+-)

;*;	CALL_w	KEYRET			; キーボード・ＲＥＴキー読み込み
;*;	CMP	AX,1			; 1=RETURN,2=ZERO (-1:押していない)
;*;	JE	CHK_KEY_DIR_CAMP	;

	CMP	KYONL,0			; key left  bottan.(0=ON)
	JE	CHK_KEY_DIR_CAMP	;
	CMP	KYONR,0			; key right bottan.(0=ON)
	JE	CHK_KEY_DIR_CAMP	;

	MOV	AX,SLCXX		; key locate direction x(+-)
	MOV	BX,SLCYY		; key locate direction y(+-)

	CMP	AX,0			; key locate direction x(+-)
	JE	CHK_KEY_DIR_YY		;
	CMP	BX,0			; key locate direction y(+-)
	JE	CHK_KEY_DIR_XX		;
	JL	CHK_KEY_DIR_Y_UP	;

CHK_KEY_DIR_Y_DOWN:			;
	CMP	AX,0			; key locate direction x(+-)
	JL	CHK_KEY_DIR_L_DOWN	;
	JMP	CHK_KEY_DIR_R_DOWN	;

CHK_KEY_DIR_Y_UP:			;
	CMP	AX,0			; key locate direction x(+-)
	JL	CHK_KEY_DIR_L_UP	;
	JMP	CHK_KEY_DIR_R_UP	;

CHK_KEY_DIR_XX:
	CMP	AX,0			; key locate direction x(+-)
	JL	CHK_KEY_DIR_LEFT	;
	JMP	CHK_KEY_DIR_RIGHT	;

CHK_KEY_DIR_YY:
	CMP	BX,0			; key locate direction y(+-)
	JL	CHK_KEY_DIR_UP		;
	JG	CHK_KEY_DIR_DOWN	;
	JMP	CHK_KEY_DIR_NONE	;

CHK_KEY_DIR_UP:
	MOV	SLCNUM,1		; 1:上
	RET
CHK_KEY_DIR_DOWN:
	MOV	SLCNUM,2		; 2:下
	RET
CHK_KEY_DIR_LEFT:
	MOV	SLCNUM,3		; 3:左
	RET
CHK_KEY_DIR_RIGHT:
	MOV	SLCNUM,4		; 4:右
	RET
CHK_KEY_DIR_L_UP:
	MOV	SLCNUM,6		; 6:左上
	RET
CHK_KEY_DIR_R_UP:
	MOV	SLCNUM,7		; 7:右上
	RET
CHK_KEY_DIR_L_DOWN:
	MOV	SLCNUM,8		; 8:左下
	RET
CHK_KEY_DIR_R_DOWN:
	MOV	SLCNUM,9		; 9:右下
	RET
CHK_KEY_DIR_NONE:
	MOV	SLCNUM,0		; ボタン選択番号
	RET
CHK_KEY_DIR_CAMP:
	MOV	SLCNUM,5		; ボタン選択番号
	RET
CHK_KEY_DIR	ENDP


; ****************************************************
;	window open.
; ****************************************************

WIDOPEN	PROC	NEAR
	MOV	PTNUM,1			; put puttern number.
	MOV	CX,WIDDMAX		; ボタン数
WIDOPEN_LOOP:				;
	PUSH	CX			;
	MOV	CX,PTNUM		; put puttern number.
	MOV	DX,0			; 0=OFF,1=ON.
	CALL	XPT_YAJI_PT		; put yaji put.
	INC	PTNUM			; put puttern number.
	POP	CX			;
	LOOP	WIDOPEN_LOOP		;
	RET
WIDOPEN	ENDP


; ****************************************************
;	ボタンON
;	-I- AX : ボタン選択番号
;		1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
;		6:左上,7:右上,8:左下,9:右下
; ****************************************************

BTN_ON	PROC	NEAR
	CMP	AX,0			;
	JE	BTN_ON_EXIT		;
	CMP	AX,6			;
	JNB	BTN_ON_2PT		;

	MOV	CX,AX			; put puttern number.
	MOV	DX,1			; 1=ON
	CALL	XPT_YAJI_PT		; put yaji put.
	JMP	BTN_ON_EXIT		;
BTN_ON_2PT:				;
	MOV	DX,1			; 1=ON
	CALL	BTN_DUAL		; botton dual.
BTN_ON_EXIT:
	RET
BTN_ON	ENDP


; ****************************************************
;	ボタンOFF
;	-I- AX : ボタン選択番号
;		1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
; ****************************************************

BTN_OFF	PROC	NEAR
	CMP	AX,0			;
	JE	BTN_OFF_EXIT		;
	CMP	AX,6			;
	JNB	BTN_OFF_2PT		;

	MOV	CX,AX			; put puttern number.
	MOV	DX,0			; 0=OFF
	CALL	XPT_YAJI_PT		; put yaji put.
	JMP	BTN_OFF_EXIT		;
BTN_OFF_2PT:
	MOV	DX,0			; 0=OFF
	CALL	BTN_DUAL		; botton dual.
BTN_OFF_EXIT:
	RET
BTN_OFF	ENDP


; ****************************************************
;	botton dual.
;	-I- AX : ボタン選択番号
;		6:左上,7:右上,8:左下,9:右下
;	    DX : 0=OFF,1=ON
; ****************************************************

BTN_DUAL	PROC	NEAR
	PUSH	AX
	PUSH	DX
	CMP	AX,7			; 7:右上
	JE	BTN_DUAL_R		;
	CMP	AX,9			; 9:右下
	JE	BTN_DUAL_R		;
BTN_DUAL_L:
	MOV	CX,3			; put puttern number.
	CALL	XPT_YAJI_PT		; put yaji put.
	JMP	BTN_DUAL_5		;
BTN_DUAL_R:
	MOV	CX,4			; put puttern number.
	CALL	XPT_YAJI_PT		; put yaji put.
BTN_DUAL_5:
	POP	DX
	POP	AX

	CMP	AX,8			; 8:左下
	JE	BTN_DUAL_DOWN		;
	CMP	AX,9			; 9:右下
	JE	BTN_DUAL_DOWN		;
BTN_DUAL_UP:
	MOV	CX,1			; put puttern number.
	CALL	XPT_YAJI_PT		; put yaji put.
	JMP	BTN_DUAL_7		;
BTN_DUAL_DOWN:
	MOV	CX,2			; put puttern number.
	CALL	XPT_YAJI_PT		; put yaji put.
BTN_DUAL_7:
	RET
BTN_DUAL	ENDP


; ****************************************************
;	select check.
;	-I- MOUSEX : マウスＸ
;	    MOUSEY : マウスＹ
;	-O- SLCNUM : ボタン選択番号
;		0:OFF,1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
; ****************************************************

SLCTCHK	PROC	NEAR
	MOV	SLCNUM,0		; ボタン選択番号
	MOV	SI,0			; word pointer.
	MOV	CX,WIDDMAX		; ボタン数
SLCTCHK_LOOP:				;
	MOV	BP,CX			;

	INC	SLCNUM			; ボタン選択番号

	MOV	AX,WIDDIMX[SI]		; AX=ボタン座標Ｘ左上
	MOV	BX,WIDDIMY[SI]		; BX=ボタン座標Ｙ左上
	MOV	CX,AX			;
	MOV	DX,BX			;
	ADD	CX,WIDMSIZX		; CX=ボタン座標Ｘ右下
	ADD	DX,WIDMSIZY		; DX=ボタン座標Ｙ右下

	CMP	MOUSEX,AX		; ボタン単語座標Ｘ
	JB	SLCTCHK_NEXT		;
	CMP	MOUSEY,BX		; ボタン単語座標Ｙ
	JB	SLCTCHK_NEXT		;
	CMP	MOUSEX,CX		; ボタン単語座標Ｘ
	JNB	SLCTCHK_NEXT		;
	CMP	MOUSEY,DX		; ボタン単語座標Ｙ
	JNB	SLCTCHK_NEXT		;

	JMP	SLCTCHK_EXIT		;

SLCTCHK_NEXT:				;
	INC	SI			; word pointer.
	INC	SI			;
	MOV	CX,BP			;
	LOOP	SLCTCHK_LOOP		;

	MOV	SLCNUM,0		; ボタン選択番号
SLCTCHK_EXIT:
	RET
SLCTCHK	ENDP


; ****************************************************
;	put yaji put.
;	-I- CX : 1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
;	    DX : 0=OFF,1=ON.
; ****************************************************

XPT_YAJI_PT	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	XPT_YAJI_PT_ONE_SIDE	;
	CMP	PLEAN_MODE,1		; プレーンモード 0=片面,1=両面
	JE	XPT_YAJI_PT_TWO_SIDE	;
XPT_YAJI_PT_ONE_SIDE:
	CALL_w	PT_YAJI_PT		; put yaji put.
	RET
XPT_YAJI_PT_TWO_SIDE:
	MOV	GDIR,CX			; 1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
	MOV	GONOFF,DX		; 0=OFF,1=ON.

	CALL_w	VRM98NOW			; PC98 vram bank now.
	MOV	AX,BX				;
	PUSH	AX				; 0=VRAM0 write,1=VRAM1 write.

	XOR	AX,1				;
	CALL_w	VRM98WT				; PC98 vram write bank.
	MOV	CX,GDIR				; 1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
	MOV	DX,GONOFF			; 0=OFF,1=ON.
	CALL_w	PT_YAJI_PT			; put yaji put.

	POP	AX				;
	CALL_w	VRM98WT				; PC98 vram write bank.
	MOV	CX,GDIR				; 1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
	MOV	DX,GONOFF			; 0=OFF,1=ON.
	CALL_w	PT_YAJI_PT			; put yaji put.
	RET
XPT_YAJI_PT	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	WIDDDEMO			; (WIDDIRSL.ASM)デモフラグ
					; 0=通常,55=ランダムセレクト

EXTRN	KYDRX:WORD			; key locate direction x(+-)
EXTRN	KYDRY:WORD			; key locate direction y(+-)

EXTRN	KYLC_TIMER_KYDRX:WORD		; time sampling key direction x(+-)
EXTRN	KYLC_TIMER_KYDRY:WORD		; time sampling key direction y(+-)

EXTRN	KYONL:WORD			; key left  bottan.(0=ON)
EXTRN	KYONR:WORD			; key right bottan.(0=ON)

EXTRN	MUSDRX:WORD			; mouse locate direction x(+-)
EXTRN	MUSDRY:WORD			; mouse locate direction y(+-)

WIDDDEMO	DW	0		; デモフラグ0=通常,55=ランダムセレクト
WIDDDEMO_NOW	DW	1		; デモフラグ
WIDDDEMO_NOW2	DW	1		; デモフラグ

MOUSEX		DW	0		; マウスＸ
MOUSEY		DW	0		; マウスＹ
MS_BTNL		DB	0,0		; マウスボタン左
MS_BTNR		DB	0,0		; マウスボタン右

WIDMSIZX	DW	4		; ボタン座標Ｘ右下
WIDMSIZY	DW	32		; ボタン座標Ｙ右下

;	1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ

WIDDMAX		DW	5			; ボタン数
WIDDIMX		DW	 70, 70, 67, 73, 66	; ボタン座標Ｘ左上
WIDDIMY		DW	230,310,270,270,184	; ボタン座標Ｙ左上

SLCNUM		DW	0		; ボタン選択番号
SLCXX		DW	0		; Ｘ方向増分
SLCYY		DW	0		; Ｙ方向増分
NOW_SLCNUM	DW	0		; 現在のボタン選択番号
PTNUM		DW	0		; put puttern number.

FLAG_DIRSL_OPEN	DW	0		; flag ｳｲﾝﾄﾞｳOPEN

PLEAN_MODE	DW	1		; プレーンモード 0=片面,1=両面

GXX		DW	0		; girl put adjast x.
GYY		DW	0		; girl put adjast y.
GDIR		DW	0		; 1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
GONOFF		DW	0		; 0=OFF,1=ON.

DATA	ENDS

	END
;
;	end of "WIDDIRSL.ASM"
;
