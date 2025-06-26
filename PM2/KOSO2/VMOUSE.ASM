; "VMOUSE.ASM"  486/33 make by R.H 1992/05/08
;
;
;
;	マウスドライバー
;
;
;
; public subroutine.

INCLUDE	MACHINEX.INC

MOUSE_DELAY	EQU	60		; マウスボタン遅延時間

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	MUSINI			; マウスの初期化
PUBLIC	MUSRED			; マウス読み込み
PUBLIC	MUSWRD			; マウス読み込み・遅延処理付き
PUBLIC	MUSSHT			; マウス読み込み・ワンショット
PUBLIC	MUSSET			; マウス座標セット
PUBLIC	MUSSTB			; マウスボタンセット
PUBLIC	MUSSTP			; マウスの終了
PUBLIC	MUSWAT			; マウスボタンＯＦＦ待ち
PUBLIC	MUSDSP			; マウスＤＩＲのクリア
PUBLIC	MUSAREA			; マウスエリアの設定

PUBLIC	MOUSE_BTN_DELAY		; ボタンタイマ遅延調整

;	PC/AT.

EXTRN	VPCMUSINI:NEAR		; マウスの初期化
EXTRN	VPCMUSRED:NEAR		; マウス読み込み
EXTRN	VPCMUSWRD:NEAR		; マウス読み込み・遅延処理付き
EXTRN	VPCMUSSHT:NEAR		; マウス読み込み・ワンショット
EXTRN	VPCMUSSET:NEAR		; マウス座標セット
EXTRN	VPCMUSSTB:NEAR		; マウスボタンセット
EXTRN	VPCMUSSTP:NEAR		; マウスの終了
EXTRN	VPCMUSWAT:NEAR		; マウスボタンＯＦＦ待ち
EXTRN	VPCMUSDSP:NEAR		; マウスＤＩＲのクリア

;	PC9801.

EXTRN	V98MUSINI:NEAR		; マウスの初期化
EXTRN	V98MUSRED:NEAR		; マウス読み込み
EXTRN	V98MUSWRD:NEAR		; マウス読み込み・遅延処理付き
EXTRN	V98MUSSHT:NEAR		; マウス読み込み・ワンショット
EXTRN	V98MUSSET:NEAR		; マウス座標セット
EXTRN	V98MUSSTB:NEAR		; マウスボタンセット
EXTRN	V98MUSSTP:NEAR		; マウスの終了
EXTRN	V98MUSWAT:NEAR		; マウスボタンＯＦＦ待ち
EXTRN	V98MUSDSP:NEAR		; マウスＤＩＲのクリア

EXTRN	TMVST6:NEAR		; V-SYNC timer6 set.(use:MUSCOR.ASM)
EXTRN	TMVCK6:NEAR		; V-SYNC timer6 check.(use:MUSCOR.ASM)


;	マウスの初期化

MUSINI	PROC	NEAR
	MACHINE_CALL	VPCMUSINI,V98MUSINI	; マウスの初期化
	RET
MUSINI	ENDP


;	マウス読み込み
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

MUSRED	PROC	NEAR
	MACHINE_CALL	VPCMUSRED,V98MUSRED	; マウス読み込み
	RET
MUSRED	ENDP


;	マウス読み込み・遅延処理付き
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

MUSWRD	PROC	NEAR
	MACHINE_CALL	VPCMUSWRD,V98MUSWRD	;マウス読み込み・遅延処理付き
	RET
MUSWRD	ENDP


;	マウス読み込み・ワンショット
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

MUSSHT	PROC	NEAR
	MACHINE_CALL	VPCMUSSHT,V98MUSSHT	; マウス読み込み・ワンショット
	RET
MUSSHT	ENDP


;	マウス座標セット
;	（外部からのセット／キーボード兼用など）
;	-I- AX : Ｘ座標
;	    BX : Ｙ座標

MUSSET	PROC	NEAR
	MACHINE_CALL	VPCMUSSET,V98MUSSET	; マウス座標セット
	RET
MUSSET	ENDP


;	マウスボタンセット
;	（外部からのセット／キーボード兼用など）
;	-I- DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

MUSSTB	PROC	NEAR
	MACHINE_CALL	VPCMUSSTB,V98MUSSTB	; マウスボタンセット
	RET
MUSSTB	ENDP


;	マウスの終了

MUSSTP	PROC	NEAR
	MACHINE_CALL	VPCMUSSTP,V98MUSSTP	; マウスの終了
	RET
MUSSTP	ENDP


;	マウスボタンＯＦＦ待ち

MUSWAT	PROC	NEAR
	MACHINE_CALL	VPCMUSWAT,V98MUSWAT	; マウスボタンＯＦＦ待ち
	RET
MUSWAT	ENDP


;	マウスＤＩＲのクリア

MUSDSP	PROC	NEAR
	MACHINE_CALL	VPCMUSDSP,V98MUSDSP	; マウスＤＩＲのクリア
	RET
MUSDSP	ENDP


;	マウスエリアの設定
;	-I- AX : mouse locate area minmam x.
;	    BX ; mouse locate area minmam y.
;	    CX ; mouse locate area maxmam x.
;	    DX ; mouse locate area maxmam y.

MUSAREA	PROC	NEAR
	MOV	MUSAREAMINX,AX			; mouse locate area minmam x.
	MOV	MUSAREAMINY,BX			; mouse locate area minmam y.
	MOV	MUSAREAMAXX,CX			; mouse locate area maxmam x.
	MOV	MUSAREAMAXY,DX			; mouse locate area maxmam y.

	MACHINE_CALL	VPCMUSRED,V98MUSRED	; マウス読み込み

	CMP	AX,MUSAREAMINX			; mouse locate area minmam x.
	JGE	MUSAREA_2			;
	MOV	AX,MUSAREAMINX			; mouse locate area minmam x.
MUSAREA_2:					;
	CMP	AX,MUSAREAMAXX			; mouse locate area maxmam x.
	JLE	MUSAREA_3			;
	MOV	AX,MUSAREAMAXX			; mouse locate area maxmam x.
MUSAREA_3:					;
	CMP	BX,MUSAREAMINY			; mouse locate area minmam y.
	JGE	MUSAREA_4			;
	MOV	BX,MUSAREAMINY			; mouse locate area minmam y.
MUSAREA_4:					;
	CMP	BX,MUSAREAMAXY			; mouse locate area maxmam y.
	JLE	MUSAREA_5			;
	MOV	BX,MUSAREAMAXY			; mouse locate area maxmam y.
MUSAREA_5:					;

	MACHINE_CALL	VPCMUSSET,V98MUSSET	; マウス座標セット
	RET
MUSAREA	ENDP


; *********************************************************
;	ボタンタイマ遅延調整
;	-I/O- DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	      DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）
; *********************************************************

MOUSE_BTN_DELAY	PROC	NEAR
	PUSH	AX

	CMP	DX,BTN_DELAY_RESA	; ボタン状態変化があるか？
	JNE	MOUSE_BTN_DELAY_ON	;

	PUSH	DX			;
	CALL	TMVCK6			; V-SYNC timer6 check.(use:MUSCOR.ASM)
	POP	DX			;
	CMP	AX,0			; 0=timer now, 1=timer end.
	JE	MOUSE_BTN_DELAY_OFF	;

	POP	AX
	RET
MOUSE_BTN_DELAY_OFF:
	MOV	DX,0101H		; off
	POP	AX
	RET
MOUSE_BTN_DELAY_ON:
	MOV	BTN_DELAY_RESA,DX	; タイマ遅延ボタン状態
	MOV	AX,MOUSE_DELAY		; マウスボタン遅延時間
	CALL	TMVST6			; V-SYNC timer6 set.(use:MUSCOR.ASM)
	POP	AX
	RET
MOUSE_BTN_DELAY	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	MUSAREAMINX			; mouse locate area minmam x.
PUBLIC	MUSAREAMINY			; mouse locate area minmam y.
PUBLIC	MUSAREAMAXX			; mouse locate area maxmam x.
PUBLIC	MUSAREAMAXY			; mouse locate area maxmam y.

MUSAREAMINX	DW	0		; mouse locate area minmam x.
MUSAREAMINY	DW	0		; mouse locate area minmam y.
MUSAREAMAXX	DW	639		; mouse locate area maxmam x.
MUSAREAMAXY	DW	399		; mouse locate area maxmam y.

BTN_DELAY_RESA	DW	0101B		; タイマ遅延ボタン状態

DATA	ENDS

	END
;
;	end of "VMOUSE.ASM"
;
