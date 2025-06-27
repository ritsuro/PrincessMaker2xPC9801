; "WIDMUSYA.ASM" 486/50 make by R.H 1992/07/18
;
;
;	ＷＩＮＤＯＷＳ／武者修行
;
;
;	WIDMUSYA		; WINDOWS/武者修行
;
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

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
;	WINDOWS/武者修行
;	-I- AX : function
;
;	AX=1 : スタート
;	    BX    : 1=East,2=West,3=South,4=North1,5=North2,6=North3
;	    CX,DX : map location.
;	    SI,DI : girl location.
;	    BP    : load bank bit switch.
;			bit0:bank0, bit1:bank1, bit2:bank2....
;
;	AX=2 : 一日経過時間設定
;	    BX    : 昼・経過時間
;	    CX    : 夜・経過時間
;
;	AX=3 : 歩く
;	    BX    : 1=昼,2=夜,3=昼->夜,4=夜->昼,5=前回の継続
;			6=ﾊﾟﾚｯﾄ割込みOFF(西マップ)
;			7=ﾊﾟﾚｯﾄ割込みON(西マップ)
;	-o- AX    : status.0=normal,1=place ivent,2=timeout,3=camp,4=event50.
;	    BX    : map locate x.
;	    CX    : map locate y.
;	    DX    : 娘の向き 0=front,1=back,2=left,3=right.
;	    SI    : grand level.
;	    DI    : orginal dir x.
;	    BP    : orginal dir y.
;
;	AX=4 : 効果
;	    BX    : 1=穴へ,2=穴から,3=沼へ,4=沼から
;		    5=キャンプ,6=キャンプたたむ,7=滝
;		    8=上へ,9=下へ,10=上から,11=下から,12=落下
;		    13=左へ,14=右へ
;
;	AX=5 : 位置変更
;	    BX    : map location x.
;	    CX    : map location y.
;	    DX    : girl location x.
;	    SI    : girl location y.
;	    DI    : 1=全部,2=背景のみ
;
;	AX=6 : ＲＰＧモード
;
;	AX=7 : ノーマルモード
;
;	AX=8 : 再描画
;	    BX  : 1=全部,2=背景のみ
;
;	AX=9 : 戦闘後データロード
;
;	AX=10 : マップ再ロード
;	    BX : map type.1=East,2=West,3=South,4=North1,5=North2,6=North3.
;	    CX : load bank bit switch.bit0:bank0, bit1:bank1, bit2:bank2....
;
;	AX=11 : 滝長さ
;	    BX : 滝長さ
;
;	AX=12 : 娘の向き設定
;	    BX : 0=front.1=back,2=left,3=right.
;
;	AX=13 : マップシフト
;	   BX : map shift x.
;	   CX : map shift y.
;	   DX : girl shift x.
;	   SI : girl shift y.
;	   DI : shift count.
;
;	AX=14 : キャンプ
;	    BX : 1=キャンプ張る,2=キャンプをたたむ
;
;	AX=15 : セレクト "str1,str2,str3"
;	    DS:SI : セレクト単語列
;	    BX : セレクトアニメON/OFF
;	-o- BX : select number.
;
;	AX=16 : キャンプ後ロード
;
;	AX=17 : ステータス
;	-o-  AX : map type.1=East,2=West,3=South,4=North1,5=North2,6=North3.
;	     BX : map locate x.
;	     CX : map locate y.
;
;	AX=18 : 昼<->夜操作
;	-i-  BX : 1=昼,2=夜,3=昼->夜,4=夜->昼
;
;	AX=19 : マップの修正
;	-I- BX : function.
;		1=西の泉が枯れた
;		2=北の守護星現れる
;		3=北の守護星への階段が消える
;		4=北の武神への階段が消える
;		5=宝箱OPEN.1
;		6=宝箱OPEN.2
;		7=宝箱OPEN.3
;		8=宝箱OPEN.4
;		9=宝箱OPEN.5
;		10=宝箱CLOSE.1
;		11=宝箱CLOSE.2
;		12=宝箱CLOSE.3
;		13=宝箱CLOSE.4
;		14=宝箱CLOSE.5
;
;	AX=20 : 守護星のセット
;	-I- BX : 守護星
;
;	AX=21 : マップデータのみ再ロード
;
;	AX=22 : 全モードクリア
;
;	AX=23 : 残り時間
;	-o- BX : 残り時間
;
;	AX=24 : 残りクリア
;
; ****************************************************

FUNC	WIDMUSYA
	DEC	AX
	CMP	AX,(WIDMUSYA_TBL_E-WIDMUSYA_TBL)/2
	JB	WIDMUSYA_START
	RET
WIDMUSYA_START:
	MOV	REG_BP,BP
	MOV	BP,AX
	SHL	BP,1				; word pointer.
	CALL	WORD PTR DS:WIDMUSYA_TBL[BP]	; jump label.
	RET
FEND	WIDMUSYA


; ****************************************************
;	スタート
;	-I- BX    : 1=East,2=West,3=South,4=North1,5=North2,6=North3
;	    CX,DX : map location.
;	    SI,DI : girl location.
;	    REG_BP: load bank bit switch.
;			bit0:bank0, bit1:bank1, bit2:bank2....
;
;	-O- AX    : 0=normal.
;
;
;	"MUSYAE.COM" header.
;
;	MAP_TYPE	;(+10ah) map type.1=E,2=W,3=S,4=N1,5=N2,6=N3
;	MAP_SIZE_X	;(+10ch) map size x.
;	MAP_SIZE_Y	;(+10eh) map size y.
;	MAP_LOC_X	;(+110h) map location x.
;	MAP_LOC_Y	;(+112h) map location y.
;	GIRL_LOC_X	;(+114h) girl location x.
;	GIRL_LOC_Y	;(+116h) girl location y.
;	ANIME_XCHG_CHP1	;(+118h) anime exchange chip1.
;	ANIME_XCHG_END1	;(+11ah) anime exchange end1.
;	ANIME_XCHG_CHP2	;(+11ch) anime exchange chip2.
;	ANIME_XCHG_END2	;(+11eh) anime exchange end2.
;	ANIME_XCHG_CHP3	;(+120h) anime exchange chip3.
;	ANIME_XCHG_END3	;(+122h) anime exchange end3.
;	ANIME_XCHG_CHP4	;(+124h) anime exchange chip4.
;	ANIME_XCHG_END4	;(+126h) anime exchange end4.
;	ANIME_MODE	;(+128h) anime mode.
;	SUB_FUNCTION	;(+12ch) sub function number.
;	LOAD_BANK_B_SW	;(+12eh) load bank bit switch.
;
; ****************************************************

MUSYA_START	PROC	NEAR
	MOV	CH_MAP_TYPE,BX			; map type.
	MOV	CH_MAP_LOC_X,CX			; map location x.
	MOV	CH_MAP_LOC_Y,DX			; map location y.
	MOV	CH_GIRL_LOC_X,SI		; girl location x.
	MOV	CH_GIRL_LOC_Y,DI		; girl location y.
	MOVX	CH_LOAD_BANK_B_SW,REG_BP	; load bank bit switch.

	CALL	MAP_PARA_SET			; map parameter set.

	MOV	SI,OFFSET FLNM			;
	CALL_w	CHILD_PROCESS_LOAD		; (*.com) child process load.

	MOV	AX,1				; 1=musyae.com,
	CALL_w	CHILD_PROCESS_HEAD		; (*.com) child process header set.

	MOV	AX,1				; function 1=マップロード
	MOV	BX,0				; sub function.
	CALL_w	CHILD_PROCESS_JUMP		; (*.com) child process jump.

	MOV	AX,0				; 0=normal.
	RET
MUSYA_START	ENDP


; ****************************************************
;	一日経過時間設定
;	-I- BX    : 昼・経過時間
;	    CX    : 夜・経過時間
;	-O- AX    : 0=normal.
; ****************************************************

MUSYA_TIME	PROC	NEAR
	MOV	TIME_DAYLIGHT,BX		; 昼・経過時間
	MOV	TIME_NIGHT,CX			; 夜・経過時間

	MOV	AX,0				; 0=normal.
	RET
MUSYA_TIME	ENDP


; ****************************************************
;	歩く
;	-I- BX    : 1=昼,2=夜,3=昼->夜,4=夜->昼,5=前回の継続
;			6=ﾊﾟﾚｯﾄ割込みOFF(西マップ)
;			7=ﾊﾟﾚｯﾄ割込みON(西マップ)
;	-O- AX    : status.0=normal,1=place ivent,2=timeout,3=camp,4=event50.
;	    BX    : map locate x.
;	    CX    : map locate y.
;	    DX    : 娘の向き 0=front,1=back,2=left,3=right.
;	    SI    : grand level.
;	    DI    : orginal dir x.
;	    BP    : orginal dir y.
; ****************************************************

MUSYA_WALK	PROC	NEAR
	CMP	BX,4
	JG	MUSYA_WALK_1
	MOV	FLAG_DAYLIGHT,BX		; flag pallet efc11 daylight.
MUSYA_WALK_1:

	CMP	BL,1				; 1=昼
	JE	MUSYA_WALK_DAY			;
	CMP	BL,2				; 2=夜
	JE	MUSYA_WALK_NIGHT		;
	CMP	BL,3				; 3=昼->夜
	JE	MUSYA_WALK_EVENING		;
	CMP	BL,4				; 4=夜->昼
	JE	MUSYA_WALK_MORNING		;
	CMP	BL,5				; 5=前回の継続
	JE	MUSYA_WALK_CONTINUE		;
	CMP	BL,6				; 6=ﾊﾟﾚｯﾄ割込みOFF(西マップ)
	JE	MUSYA_WALK_P_OFF		;
	CMP	BL,7				; 7=ﾊﾟﾚｯﾄ割込みON(西マップ)
	JE	MUSYA_WALK_P_ON			;
	RET

MUSYA_WALK_DAY:					; 1=昼
	CALL	PALET_DAYLIGHT			; 昼　パレット
	MOV	AX,TIME_DAYLIGHT		; 昼・経過時間
	CALL_w	CHILD_PROCESS_TIMER		; (*.com) child process timer.
	CALL	MAP_PALET_EFC			; map palet effect.
	JMP	MUSYA_WALK_JAMP			;

MUSYA_WALK_NIGHT:				; 2=夜
	CALL	PALET_NIGHT			; 夜　パレット
	MOV	AX,TIME_NIGHT			; 夜・経過時間
	CALL_w	CHILD_PROCESS_TIMER		; (*.com) child process timer.
	CALL	MAP_PALET_EFC			; map palet effect.
	JMP	MUSYA_WALK_JAMP			;

MUSYA_WALK_EVENING:				; 3=昼->夜
	CALL	PALET_EVENING			; 昼－＞夜　パレット
	MOV	AX,TIME_EVENING			; 昼->夜
	CALL_w	CHILD_PROCESS_TIMER		; (*.com) child process timer.
	JMP	MUSYA_WALK_JAMP			;

MUSYA_WALK_MORNING:				; 4=夜->昼
	CALL	PALET_MORNING			; 夜－＞昼　パレット
	MOV	AX,TIME_MORNING			; 夜->昼
	CALL_w	CHILD_PROCESS_TIMER		; (*.com) child process timer.
	JMP	MUSYA_WALK_JAMP			;

MUSYA_WALK_CONTINUE:				; 5=前回の継続
	MOV	AX,NOW_CHILD_PRO_TIME		; now child process timer.
	CALL_w	CHILD_PROCESS_TIMER		; (*.com) child process timer.
	JMP	MUSYA_WALK_JAMP			;

MUSYA_WALK_P_OFF:				;
	CALL	MAP_PALET_EFC_OFF		; map palet effect off.
	JMP	MUSYA_WALK_EXIT			;

MUSYA_WALK_P_ON:				;
	CALL	MAP_PALET_EFC			; map palet effect.
	JMP	MUSYA_WALK_EXIT			;

MUSYA_WALK_JAMP:
	CALL	PARASET				; 感受性等のセット(EVENTに影響)

;;	MOV	AX,1				; 1=two side put.
;;	CALL_w	MSCPLNMDE			; カーソル・プレーンモード

	MOV	AX,2				; function 2=歩く
	MOV	BX,0				; sub function.
	CALL_w	CHILD_PROCESS_JUMP		; (*.com) child process jump.

	PUSH	AX				; 0=normal,1=place...
	PUSH	DX				; 娘の向き 0=front,1=back,2=left,3=right.
	PUSH	SI				; grand level.
	MOV	AL,CH				; DI=orginal dir x.
	CBW					;
	MOV	DI,AX				;
	MOV	AL,CL				; BP=orginal dir y.
	CBW					;
	MOV	BP,AX				;
	PUSH	DI				; orginal dir x.
	PUSH	BP				; orginal dir y.

;;	MOV	AX,0				; 0=normal put.
;;	CALL_w	MSCPLNMDE			; カーソル・プレーンモード

	MOV	AX,1				; process. 1=musyae.com,
	CALL_w	CHILD_PROCESS_HEAD_RD		; (*.com) child process header read.
	MOV	BX,CH_MAP_LOC_X			; map location x.
	MOV	CX,CH_MAP_LOC_Y			; map location y.
	ADD	BX,CH_GIRL_LOC_X		; girl location x.
	ADD	CX,CH_GIRL_LOC_Y		; girl location y.

;;	CALL	MAP_PALET_EFC_OFF		; map palet effect off.

	CALL_w	CHILD_PROCESS_TIMER_RD	; (*.com) child process timer read.
	MOV	NOW_CHILD_PRO_TIME,DX	; now child process timer.

	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	AX
MUSYA_WALK_EXIT:
	RET
MUSYA_WALK	ENDP


; ****************************************************
;	map palet effect.
; ****************************************************

MAP_PALET_EFC	PROC	NEAR
	CMP	CH_MAP_TYPE,2			; map type.2=west
	JNE	MAP_PALET_EFC_5			;
	CALL_w	PLTINT_P10_ON			; palet10変化割込ON
MAP_PALET_EFC_5:				;
	RET
MAP_PALET_EFC	ENDP


; ****************************************************
;	map palet effect off.
; ****************************************************

MAP_PALET_EFC_OFF	PROC	NEAR
	CMP	CH_MAP_TYPE,2			; map type.2=west
	JNE	MAP_PALET_EFC_OFF_5		;

	PUSH	AX				;
	PUSH	BX				;
	PUSH	CX				;
	PUSH	DX				;
	CALL_w	PLTINT_P10_OFF			; palet10変化割込OFF
	POP	DX				;
	POP	CX				;
	POP	BX				;
	POP	AX				;
MAP_PALET_EFC_OFF_5:
	RET
MAP_PALET_EFC_OFF	ENDP


; ****************************************************
;	効果
;	-I- BX    : 1=穴へ,2=穴から,3=沼へ,4=沼から
;		    5=キャンプ,6=キャンプたたむ
;		    8=上へ,9=下へ,10=上から,11=下から
;	-O- AX    : 0=normal.
; ****************************************************

MUSYA_EFC	PROC	NEAR
;;	PUSH	BX
;;	MOV	AX,1				; 1=two side put.
;;	CALL_w	MSCPLNMDE			; カーソル・プレーンモード
;;	POP	BX

	MOV	AX,3				; function 3=効果
	CALL_w	CHILD_PROCESS_JUMP		; (*.com) child process jump.

;;	MOV	AX,0				; 0=normal put.
;;	CALL_w	MSCPLNMDE			; カーソル・プレーンモード

	MOV	AX,0				; 0=normal.
	RET
MUSYA_EFC	ENDP


; ****************************************************
;	位置変更
;	-I- BX    : map location x.
;	    CX    : map location y.
;	    DX    : girl location x.
;	    SI    : girl location y.
;	    DI    : 1=全部,2=背景のみ
;	-O- AX    : 0=normal.
; ****************************************************

MUSYA_RELOC	PROC	NEAR
	MOV	CH_MAP_LOC_X,BX		; map location x.
	MOV	CH_MAP_LOC_Y,CX		; map location y.
	MOV	CH_GIRL_LOC_X,DX	; girl location x.
	MOV	CH_GIRL_LOC_Y,SI	; girl location y.
	PUSH	DI
	MOV	AX,1				; 1=musyae.com,
	CALL_w	CHILD_PROCESS_HEAD		; (*.com) child process header set.
	POP	DI
	MOV	AX,4				; function 4=再表示
	MOV	BX,DI				; 1=全部,2=背景のみ
	CALL_w	CHILD_PROCESS_JUMP		; (*.com) child process jump.

	MOV	AX,0				; 0=normal.
	RET
MUSYA_RELOC	ENDP


; ****************************************************
;	ＲＰＧモード
; ****************************************************

MUSYA_MODE_RPG	PROC	NEAR
	MOV	AX,0			; 0=OFF
	CALL_w	MSCINTSW		; マウス割り込みカーソルON/OFF

	MOV	AX,1			; 1=two side put.
	CALL_w	MSCPLNMDE		; カーソル・プレーンモード

	MOV	AX,5			; function 5=RPG mode.
	CALL_w	CHILD_PROCESS_JUMP	; (*.com) child process jump.
	RET
MUSYA_MODE_RPG	ENDP


; ****************************************************
;	ノーマルモード
; ****************************************************

MUSYA_MODE_NORMAL	PROC	NEAR
	MOV	AX,6			; fuinction 6=normal mode.
	CALL_w	CHILD_PROCESS_JUMP	; (*.com) child process jump.

	MOV	AX,1			; 1=two side put.
	CALL_w	MSCPLNMDE		; カーソル・プレーンモード

	MOV	AX,1			; 1=ON
	CALL_w	MSCINTSW		; マウス割り込みカーソルON/OFF
	RET
MUSYA_MODE_NORMAL	ENDP


; ****************************************************
;	全モードクリア
; ****************************************************

MUSYA_MODE_CLEAR	PROC	NEAR
	MOV	AX,0			; 0=normal put,1=two side put.
	CALL_w	MSCPLNMDE		; カーソル・プレーンモード

	CALL_w	PLTINT_P10_OFF		; palet11変化割込OFF
	RET
MUSYA_MODE_CLEAR	ENDP


; ****************************************************
;	残り時間
;	-O- BX : 残り時間
; ****************************************************

MUSYA_TIMEREAD	PROC	NEAR
	MOV	BX,NOW_CHILD_PRO_TIME	; now child process timer.
	RET
MUSYA_TIMEREAD	ENDP


; ****************************************************
;	残りクリア
; ****************************************************

MUSYA_TIMECLEAR	PROC	NEAR
	MOV	NOW_CHILD_PRO_TIME,0	; now child process timer.
	RET
MUSYA_TIMECLEAR	ENDP


; ****************************************************
;	再描画
;	-I- BX  : 1=全部,2=背景のみ
; ****************************************************

MUSYA_REDRAW	PROC	NEAR
	MOV	AX,4				; function 4=再表示
	CALL_w	CHILD_PROCESS_JUMP		; (*.com) child process jump.
	RET
MUSYA_REDRAW	ENDP


; ****************************************************
;	戦闘後データロード
; ****************************************************

MUSYA_RELOAD	PROC	NEAR
	MOV	AX,7				; function 7=buffer reload.
	CALL_w	CHILD_PROCESS_JUMP		; (*.com) child process jump.
	RET
MUSYA_RELOAD	ENDP


; ****************************************************
;	マップ再ロード
;	-I- BX : map type.1=East,2=West,3=South,4=North1,5=North2,6=North3.
;	    CX : load bank bit switch.bit0:bank0, bit1:bank1, bit2:bank2....
; ****************************************************

MUSYA_MAPSET	PROC	NEAR
	MOV	CH_MAP_TYPE,BX			; map type.
	MOV	CH_LOAD_BANK_B_SW,CX		; load bank bit switch.

	CALL	MAP_PARA_SET			; map parameter set.

	MOV	AX,1				; 1=musyae.com,
	CALL_w	CHILD_PROCESS_HEAD		; (*.com) child process header set.

	MOV	AX,8				; function 8=マップ再ロード
	MOV	BX,0				; sub function.
	CALL_w	CHILD_PROCESS_JUMP		; (*.com) child process jump.

	MOV	AX,9				; function 9=バンクロードの指定
	MOV	BX,CH_LOAD_BANK_B_SW		; load bank bit switch.
	CALL_w	CHILD_PROCESS_JUMP		; (*.com) child process jump.

	RET
MUSYA_MAPSET	ENDP


; ****************************************************
;	map parameter set.
;	-I- BX : map type.1=East,2=West,3=South,4=North1,5=North2,6=North3.
; ****************************************************

MAP_PARA_SET	PROC	NEAR
	DEC	BX				;-1
	SHL	BX,1				;1=East,2=West,3=South...
	MOVX	CH_ANIME_MODE,TBL_ANIME_MODE[BX] ; anime mode.
	MOVX	CH_MAP_SIZE_X,TBL_MAP_SIZE_X[BX] ; map size x.
	MOVX	CH_MAP_SIZE_Y,TBL_MAP_SIZE_Y[BX] ; map size y.

	MOV	AX,TBL_ANIME_XCHG_CHP1[BX]	; anime exchange chip1.
	MOV	SI,TBL_ANIME_XCHG_END1[BX]	; anime exchange end1.
	MOV	CX,TBL_ANIME_XCHG_CHP2[BX]	; anime exchange chip2.
	MOV	DX,TBL_ANIME_XCHG_END2[BX]	; anime exchange end2.
	MOV	CH_ANIME_XCHG_CHP1,AX		; anime exchange chip1.
	MOV	CH_ANIME_XCHG_END1,SI		; anime exchange end1.
	MOV	CH_ANIME_XCHG_CHP2,CX		; anime exchange chip2.
	MOV	CH_ANIME_XCHG_END2,DX		; anime exchange end2.

	MOV	AX,TBL_ANIME_XCHG_CHP3[BX]	; anime exchange chip3.
	MOV	SI,TBL_ANIME_XCHG_END3[BX]	; anime exchange end3.
	MOV	CX,TBL_ANIME_XCHG_CHP4[BX]	; anime exchange chip4.
	MOV	DX,TBL_ANIME_XCHG_END4[BX]	; anime exchange end4.
	MOV	CH_ANIME_XCHG_CHP3,AX		; anime exchange chip3.
	MOV	CH_ANIME_XCHG_END3,SI		; anime exchange end3.
	MOV	CH_ANIME_XCHG_CHP4,CX		; anime exchange chip4.
	MOV	CH_ANIME_XCHG_END4,DX		; anime exchange end4.

	RET
MAP_PARA_SET	ENDP


; ****************************************************
;	滝長さ
;	-I- BX : 滝長さ
; ****************************************************

MUSYA_FALLS	PROC	NEAR
	MOV	CH_EFC_FALLS_LEN,BX		; effect falls length.
	MOV	AX,1				; 1=musyae.com,
	CALL_w	CHILD_PROCESS_HEAD		; (*.com) child process header set.
	RET
MUSYA_FALLS	ENDP


; ****************************************************
;	娘の向き設定
;	-I- BX : 0=front.1=back,2=left,3=right.
; ****************************************************

MUSYA_GIRLDIR	PROC	NEAR
	MOV	AX,10				; function 10=娘の向き設定
	CALL_w	CHILD_PROCESS_JUMP		; (*.com) child process jump.
	RET
MUSYA_GIRLDIR	ENDP


; ****************************************************
;	マップシフト
;	-I- BX : map shift x.
;	    CX : map shift y.
;	    DX : girl shift x.
;	    SI : girl shift y.
;	    DI : shift count.
; ****************************************************

MUSYA_MAPSHIFT	PROC	NEAR
	MOV	CH_PARAM01,BX		; parameter 1.
	MOV	CH_PARAM02,CX		; parameter 2.
	MOV	CH_PARAM03,DX		; parameter 3.
	MOV	CH_PARAM04,SI		; parameter 4.
	MOV	CH_PARAM05,DI		; parameter 5.

	MOV	AX,11			; function 11=マップシフト
	CALL_w	CHILD_PROCESS_JUMP	; (*.com) child process jump.
	RET
MUSYA_MAPSHIFT	ENDP


; ****************************************************
;	キャンプ
;	-I- BX : 1=キャンプ張る,2=キャンプをたたむ
; ****************************************************

MUSYA_CAMP	PROC	NEAR
	MOV	AX,12			; function 12=キャンプ
	CALL_w	CHILD_PROCESS_JUMP	; (*.com) child process jump.
	RET
MUSYA_CAMP	ENDP


; ****************************************************
;	セレクト "str1,str2,str3"
;	-I- DS:SI : セレクト単語列
;	    BX    : セレクトアニメON/OFF
;	-O- BX    : select number.
; ****************************************************

MUSYA_SLCT	PROC	NEAR
	MOV	CH_PARAM01,DS		; セレクト単語列(segment)
	MOV	CH_PARAM02,SI		; セレクト単語列(offset)
	MOV	CH_PARAM03,BX		; セレクトアニメON/OFF

	CALL	RPG_SLCT_IN		; RPG SLCTcommand in.

	MOV	AX,13			; function 13=セレクト
	CALL_w	CHILD_PROCESS_JUMP	; (*.com) child process jump.

	PUSH	AX			; select number.

	CALL	RPG_SLCT_OUT		; RPG SLCTcommand out.

	POP	BX			; select number.

	RET
MUSYA_SLCT	ENDP


; ****************************************************
;	RPG SLCTcommand in.
; ****************************************************

RPG_SLCT_IN	PROC	NEAR
	MOV	AX,RPG_MOUSE_MIN_X	; mouse locate area minmam x.
	MOV	BX,RPG_MOUSE_MIN_Y	; mouse locate area minmam y.
	MOV	CX,RPG_MOUSE_MAX_X	; mouse locate area maxmam x.
	MOV	DX,RPG_MOUSE_MAX_Y	; mouse locate area maxmam y.
	CALL_w	MUSAREA			; マウスエリアの設定
	RET
RPG_SLCT_IN	ENDP


; ****************************************************
;	RPG SLCTcommand out.
; ****************************************************

RPG_SLCT_OUT	PROC	NEAR
	MOV	AX,DEF_MOUSE_MIN_X	; mouse locate area minmam x.
	MOV	BX,DEF_MOUSE_MIN_Y	; mouse locate area minmam y.
	MOV	CX,DEF_MOUSE_MAX_X	; mouse locate area maxmam x.
	MOV	DX,DEF_MOUSE_MAX_Y	; mouse locate area maxmam y.
	CALL_w	MUSAREA			; マウスエリアの設定
	RET
RPG_SLCT_OUT	ENDP


; ****************************************************
;	キャンプ後ロード
; ****************************************************

MUSYA_AFTERCAMPLD	PROC	NEAR
	CALL_w	WIDDIRSL_PTLOAD		; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳﾊﾟﾀｰﾝLOAD
	RET
MUSYA_AFTERCAMPLD	ENDP


; ****************************************************
;	ステータス
;	-O- AX : map type.1=East,2=West,3=South,4=North1,5=North2,6=North3.
;	    BX : map locate x.
;	    CX : map locate y.
; ****************************************************

MUSYA_STATUS	PROC	NEAR
	MOV	AX,1				; process. 1=musyae.com,
	CALL_w	CHILD_PROCESS_HEAD_RD		; (*.com) child process header read.

	MOV	BX,CH_MAP_LOC_X			; map location x.
	MOV	CX,CH_MAP_LOC_Y			; map location y.

	ADD	BX,CH_GIRL_LOC_X		; girl location x.
	ADD	CX,CH_GIRL_LOC_Y		; girl location y.

	MOV	AX,CH_MAP_TYPE		; map type.
	RET
MUSYA_STATUS	ENDP


; ****************************************************
;	昼<->夜操作
;	-I-  BX : 1=昼,2=夜,3=昼->夜,4=夜->昼
; ****************************************************

MUSYA_DAY_NIGHT	PROC	NEAR
	CMP	BL,1			; 1=昼
	JE	MUSYA_DAY_NIGHT_1	;
	CMP	BL,2			; 2=夜
	JE	MUSYA_DAY_NIGHT_2	;
	CMP	BL,3			; 3=昼->夜
	JE	MUSYA_DAY_NIGHT_3	;
	CMP	BL,4			; 4=夜->昼
	JE	MUSYA_DAY_NIGHT_4	;
	RET
MUSYA_DAY_NIGHT_1:
	CALL	PALET_DAYLIGHT		; 昼　パレット
	RET
MUSYA_DAY_NIGHT_2:
	CALL	PALET_NIGHT		; 夜　パレット
	RET
MUSYA_DAY_NIGHT_3:
	CALL	PALET_EVENING		; 昼－＞夜　パレット
	RET
MUSYA_DAY_NIGHT_4:
	CALL	PALET_MORNING		; 夜－＞昼　パレット
	RET
MUSYA_DAY_NIGHT	ENDP


; ****************************************************
;	マップの修正
;	-I- BX : function.
;		1=西の泉が枯れた
;		2=北の守護星現れる
; ****************************************************

MUSYA_EDIT	PROC	NEAR
	MOV	AX,15			; function 15=マップの修正
	CALL_w	CHILD_PROCESS_JUMP	; (*.com) child process jump.
	RET
MUSYA_EDIT	ENDP


; ****************************************************
;	守護星のセット
;	-I- BX : 守護星
; ****************************************************

MUSYA_SYUGO_SET	PROC	NEAR
	MOV	AX,16			; function 16=守護星のセット
	CALL_w	CHILD_PROCESS_JUMP	; (*.com) child process jump.
	RET
MUSYA_SYUGO_SET	ENDP


; ****************************************************
;	マップデータのみ再ロード
; ****************************************************

MUSYA_MAP_ONLY_LD	PROC	NEAR
	MOV	AX,17			;function 17=マップデータのみ再ロード
	CALL_w	CHILD_PROCESS_JUMP	; (*.com) child process jump.
	RET
MUSYA_MAP_ONLY_LD	ENDP


; ****************************************************
;	感受性等のセット(EVENTに影響)
;	-I- BX : map shift x.
;	    CX : map shift y.
; ****************************************************

PARASET	PROC	NEAR
	MOVX	CH_PARAM01,B_KANJUSEI	; 感受性
	MOV	AX,18			; function 18=感受性等のセット
	CALL_w	CHILD_PROCESS_JUMP	; (*.com) child process jump.
	RET
PARASET	ENDP


; ****************************************************
;	昼　パレット
; ****************************************************

PALET_DAYLIGHT	PROC	NEAR
	CALL_w	PLTINTSTP		; パレット・割込み処理中断

	MOV	SI,CH_MAP_TYPE		; map type.
	DEC	SI			;
	SHL	SI,1			; word pointer.
	MOV	AX,TBL_PALET_DAY[SI]	; 昼色 パレットのパターン番号
	MOV	BX,0			; パレットテーブル番号
	CALL_w	PT_PALET_SETONLY	; パレットテーブルセットのみ
	CALL_w	NORMIN			; ノーマルカラー
	RET
PALET_DAYLIGHT	ENDP


; ****************************************************
;	夜　パレット
; ****************************************************

PALET_NIGHT	PROC	NEAR
	CALL_w	PLTINTSTP		; パレット・割込み処理中断

	MOV	SI,CH_MAP_TYPE		; map type.
	DEC	SI			;
	SHL	SI,1			; word pointer.
	MOV	AX,TBL_PALET_NIGHT[SI]	; 夜色 パレットのパターン番号
	MOV	BX,0			; パレットテーブル番号
	CALL_w	PT_PALET_SETONLY	; パレットテーブルセットのみ
	CALL_w	NORMIN			; ノーマルカラー
	RET
PALET_NIGHT	ENDP


; ****************************************************
;	昼－＞夜　パレット
; ****************************************************

PALET_EVENING	PROC	NEAR
	MOV	SI,CH_MAP_TYPE		; map type.
	DEC	SI			;
	SHL	SI,1			; word pointer.
	MOVX	PLT_OV_SRT,TBL_PALET_DAY[SI]	; 昼色 パレットのパターン番号
	MOVX	PLT_OV_END,TBL_PALET_NIGHT[SI]	; 夜色 パレットのパターン番号
	CALL	PALET_OV_LAP		; パレット・オーバーラップ
	RET
PALET_EVENING	ENDP


; ****************************************************
;	夜－＞昼　パレット
; ****************************************************

PALET_MORNING	PROC	NEAR
	MOV	SI,CH_MAP_TYPE		; map type.
	DEC	SI			;
	SHL	SI,1			; word pointer.
	MOVX	PLT_OV_SRT,TBL_PALET_NIGHT[SI]	; 夜色 パレットのパターン番号
	MOVX	PLT_OV_END,TBL_PALET_DAY[SI]	; 昼色 パレットのパターン番号
	CALL	PALET_OV_LAP		; パレット・オーバーラップ
	RET
PALET_MORNING	ENDP


; ****************************************************
;	パレット・オーバーラップ
;	-I- PLT_OV_SRT : パレットＯＬｽﾀｰﾄﾊﾟﾚｯﾄ番号
;	    PLT_OV_END : パレットＯＬｴﾝﾄﾞﾊﾟﾚｯﾄ番号
; ****************************************************

PALET_OV_LAP	PROC	NEAR
	MOV	AX,PLT_OV_SRT		; パレットＯＬｽﾀｰﾄﾊﾟﾚｯﾄ番号
	MOV	BX,1			; パレットテーブル番号
	CALL_w	PT_PALET_SETONLY	; パレットテーブルセットのみ

	MOV	AX,PLT_OV_END		; パレットＯＬｴﾝﾄﾞﾊﾟﾚｯﾄ番号
	MOV	BX,0			; パレットテーブル番号
	CALL_w	PT_PALET_SETONLY	; パレットテーブルセットのみ

	MOV	AX,1			; オーバラップ開始パレットテーブル番号
	MOV	BX,0			; オーバラップ終了パレットテーブル番号
	CALL_w	PLTOLS			; パレット・オーバラップ／時分割初期

	MOV	AX,4			; Ｖ割込み処理の指定インターバル
	CALL_w	PLTINTSPD		; パレット・割込み処理スピード

	CALL_w	PLTINTSW		; パレット・割込み処理スイッチ
	RET
PALET_OV_LAP	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	FLAG_DAYLIGHT:WORD		; flag pallet efc11 daylight.

EXTRN	CH_MAP_TYPE:WORD		; map type.
EXTRN	CH_MAP_SIZE_X:WORD		; map size x.
EXTRN	CH_MAP_SIZE_Y:WORD		; map size y.
EXTRN	CH_MAP_LOC_X:WORD		; map location x.
EXTRN	CH_MAP_LOC_Y:WORD		; map location y.
EXTRN	CH_GIRL_LOC_X:WORD		; girl location x.
EXTRN	CH_GIRL_LOC_Y:WORD		; girl location y.
EXTRN	CH_ANIME_XCHG_CHP1:WORD		; anime exchange chip1.
EXTRN	CH_ANIME_XCHG_END1:WORD		; anime exchange end1.
EXTRN	CH_ANIME_XCHG_CHP2:WORD		; anime exchange chip2.
EXTRN	CH_ANIME_XCHG_END2:WORD		; anime exchange end2.
EXTRN	CH_ANIME_XCHG_CHP3:WORD		; anime exchange chip3.
EXTRN	CH_ANIME_XCHG_END3:WORD		; anime exchange end3.
EXTRN	CH_ANIME_XCHG_CHP4:WORD		; anime exchange chip4.
EXTRN	CH_ANIME_XCHG_END4:WORD		; anime exchange end4.
EXTRN	CH_ANIME_MODE:WORD		; anime mode.
EXTRN	CH_PARAM01:WORD			; parameter 1.
EXTRN	CH_PARAM02:WORD			; parameter 2.
EXTRN	CH_PARAM03:WORD			; parameter 3.
EXTRN	CH_PARAM04:WORD			; parameter 4.
EXTRN	CH_PARAM05:WORD			; parameter 5.
EXTRN	CH_PARAM06:WORD			; parameter 6.
EXTRN	CH_LOAD_BANK_B_SW:WORD		; load bank bit switch.
EXTRN	CH_EFC_FALLS_LEN:WORD		; effect falls length.

EXTRN	B_KANJUSEI:WORD			; 感受性

		; 1=East,2=West,3=South,4=North1,5=North2,6=North3

TBL_MAP_SIZE_X	DW	200,200,160,160,160, 40	; map size x.
TBL_MAP_SIZE_Y	DW	100,100,160, 80, 96,104	; map size y.

TBL_ANIME_XCHG_CHP1	LABEL	WORD		; anime exchange chip1.
	DW	00H+180H,00H+180H,00H+180H,00H,00H,00H+180H
TBL_ANIME_XCHG_END1	LABEL	WORD		; anime exchange end1.
	DW	01H+180H,1FH+180H,3FH+180H,00H,00H,01H+180H
TBL_ANIME_XCHG_CHP2	LABEL	WORD		; anime exchange chip2.
	DW	40H+180H,40H+180H,40H+180H,00H,00H,40H+180H
TBL_ANIME_XCHG_END2	LABEL	WORD		; anime exchange end2.
	DW	41H+180H,5FH+180H,7FH+180H,00H,00H,41H+180H
TBL_ANIME_XCHG_CHP3	LABEL	WORD		; anime exchange chip3.
	DW	10H+180H,00H,00H+300H,00H,00H,00H
TBL_ANIME_XCHG_END3	LABEL	WORD		; anime exchange end3.
	DW	11H+180H,00H,1FH+300H,00H,00H,00H
TBL_ANIME_XCHG_CHP4	LABEL	WORD		; anime exchange chip4.
	DW	50H+180H,00H,40H+300H,00H,00H,00H
TBL_ANIME_XCHG_END4	LABEL	WORD		; anime exchange end4.
	DW	51H+180H,00H,5FH+300H,00H,00H,00H
TBL_ANIME_MODE	DW	1,1,1,1,1,1		; anime mode.

TBL_PALET_DAY	DW	1,2,3,4,4,4		; 昼色 パレットのパターン番号
TBL_PALET_NIGHT	DW	5,6,7,8,8,4		; 夜色 パレットのパターン番号

TIME_DAYLIGHT	DW	60*4			; 昼・経過時間
TIME_NIGHT	DW	60*4			; 夜・経過時間
TIME_EVENING	DW	60*2			; 昼->夜
TIME_MORNING	DW	60*2			; 夜->昼

NOW_CHILD_PRO_TIME	DW	0		; now child process timer.

REG_BP		DW	0			; register BP.

PLT_OV_SRT	DW	0			; パレットＯＬｽﾀｰﾄﾊﾟﾚｯﾄ番号
PLT_OV_END	DW	0			; パレットＯＬｴﾝﾄﾞﾊﾟﾚｯﾄ番号

WIDMUSYA_TBL	LABEL	WORD		; jump label.
	DW	MUSYA_START		;1: スタート
	DW	MUSYA_TIME		;2: 一日経過時間
	DW	MUSYA_WALK		;3: 歩く
	DW	MUSYA_EFC		;4: 効果
	DW	MUSYA_RELOC		;5: 位置変更
	DW	MUSYA_MODE_RPG		;6: ＲＰＧモード
	DW	MUSYA_MODE_NORMAL	;7: ノーマルモード
	DW	MUSYA_REDRAW		;8: 再描画
	DW	MUSYA_RELOAD		;9: 戦闘後データロード
	DW	MUSYA_MAPSET		;10: マップ再ロード
	DW	MUSYA_FALLS		;11: 滝長さ
	DW	MUSYA_GIRLDIR		;12: 娘の向き設定
	DW	MUSYA_MAPSHIFT		;13: マップシフト
	DW	MUSYA_CAMP		;14: キャンプ
	DW	MUSYA_SLCT		;15: セレクト "str1,str2,str3"
	DW	MUSYA_AFTERCAMPLD	;16: キャンプ後ロード
	DW	MUSYA_STATUS		;17: ステータス
	DW	MUSYA_DAY_NIGHT		;18: 昼<->夜操作
	DW	MUSYA_EDIT		;19: マップの修正
	DW	MUSYA_SYUGO_SET		;20: 守護星のセット
	DW	MUSYA_MAP_ONLY_LD	;21: マップデータのみ再ロード
	DW	MUSYA_MODE_CLEAR	;22: 全モードクリア
	DW	MUSYA_TIMEREAD		;23: 残り時間
	DW	MUSYA_TIMECLEAR		;24: 残りクリア
WIDMUSYA_TBL_E	LABEL	WORD		;

FLNM	DB	"MUSYAE.COM",0,0

DATA	ENDS

	END
;
;	end of "WIDMUSYA.ASM"
;
