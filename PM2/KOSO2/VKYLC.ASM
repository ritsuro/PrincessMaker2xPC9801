; "VKYLC.ASM"  486/33 make by R.H 1992/05/07
;
;
;
;	キーボード・ハンドル
;
;
;
; public subroutine.

INCLUDE	MACHINEX.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	KEYTEN			; キーボード・読み込み
PUBLIC	KEYRET			; キーボード・ＲＥＴキー読み込み
PUBLIC	KEYANY			; キーボード・何か押した？
PUBLIC	KEYOFW			; キーボードＯＦＦ待ち
PUBLIC	KEYTRG			; キーボード・トリガーチェック
PUBLIC	KEYHLT			; キーボード機能のＯＮ／ＯＦＦ
PUBLIC	KEYMUS			; ｷｰﾎﾞｰﾄﾞ･ﾛｹｰｼｮﾝをマウスドライバへセット
PUBLIC	KEYMUS_DIRECTION	; キーボード＆マウスの方向

;	PC/AT.

EXTRN	VPCKEYTEN:NEAR		; キーボード・読み込み
EXTRN	VPCKEYRET:NEAR		; キーボード・ＲＥＴキー読み込み
EXTRN	VPCKEYANY:NEAR		; キーボード・何か押した？
EXTRN	VPCKEYOFW:NEAR		; キーボードＯＦＦ待ち
EXTRN	VPCKEYTRG:NEAR		; キーボード・トリガーチェック
EXTRN	VPCKEYHLT:NEAR		; キーボード機能のＯＮ／ＯＦＦ
EXTRN	VPCKEYMUS:NEAR		; ｷｰﾎﾞｰﾄﾞ･ﾛｹｰｼｮﾝをマウスドライバへセット

;	PC9801.

EXTRN	V98KEYTEN:NEAR		; キーボード・読み込み
EXTRN	V98KEYRET:NEAR		; キーボード・ＲＥＴキー読み込み
EXTRN	V98KEYANY:NEAR		; キーボード・何か押した？
EXTRN	V98KEYOFW:NEAR		; キーボードＯＦＦ待ち
EXTRN	V98KEYTRG:NEAR		; キーボード・トリガーチェック
EXTRN	V98KEYHLT:NEAR		; キーボード機能のＯＮ／ＯＦＦ
EXTRN	V98KEYMUS:NEAR		; ｷｰﾎﾞｰﾄﾞ･ﾛｹｰｼｮﾝをマウスドライバへセット


;	キーボード・読み込み
;	-O- AX : 番号(-1:押していない)
;	    BX : 1=HELP,2=HOME,3=PLUS,4=ESC (-1:押していない)

KEYTEN	PROC	NEAR
	MACHINE_CALL	VPCKEYTEN,V98KEYTEN	; キーボード・読み込み
	RET
KEYTEN	ENDP

;	キーボード・ＲＥＴキー読み込み
;	-O- AX : 1=RETURN,2=ZERO (-1:押していない)
;	    BX : 1=HELP,2=HOME,3=PLUS (-1:押していない)

KEYRET	PROC	NEAR
	MACHINE_CALL	VPCKEYRET,V98KEYRET	;キーボード・ＲＥＴキー読み込み
	RET
KEYRET	ENDP

;	キーボード・何か押した？

KEYANY	PROC	NEAR
	MACHINE_CALL	VPCKEYANY,V98KEYANY	; キーボード・何か押した？
	RET
KEYANY	ENDP

;	キーボードＯＦＦ待ち

KEYOFW	PROC	NEAR
	MACHINE_CALL	VPCKEYOFW,V98KEYOFW	; キーボードＯＦＦ待ち
	RET
KEYOFW	ENDP

;	キーボード・トリガーチェック
;	-O- AX : -1:押していない,1=何か押した

KEYTRG	PROC	NEAR
	MACHINE_CALL	VPCKEYTRG,V98KEYTRG	; キーボード・トリガーチェック
	RET
KEYTRG	ENDP

;	キーボード機能のＯＮ／ＯＦＦ
;	-I- AX : 1=ＯＮ,0=ＯＦＦ

KEYHLT	PROC	NEAR
	MACHINE_CALL	VPCKEYHLT,V98KEYHLT	; キーボード機能のＯＮ／ＯＦＦ
	RET
KEYHLT	ENDP

;	ｷｰﾎﾞｰﾄﾞ･ﾛｹｰｼｮﾝをマウスドライバへセット
;	このルーチンはタイマ割り込みなどでコールするためのもの
;
;	-I/O- AX : Ｘ座標
;	      BX : Ｙ座標
;	      DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	      DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

KEYMUS	PROC	NEAR
	MACHINE_CALL	VPCKEYMUS,V98KEYMUS ; ｷｰﾎﾞｰﾄﾞ･ﾛｹｰｼｮﾝをﾏｳｽﾄﾞﾗｲﾊﾞへｾｯﾄ
	PUSH	AX
	MOV	AX,KYDRX		; key locate direction x(+-)
	MOV	KYLC_TIMER_KYDRX,AX	; time sampling key direction x(+-)
	MOV	AX,KYDRY		; key locate direction y(+-)
	MOV	KYLC_TIMER_KYDRY,AX	; time sampling key direction y(+-)
	POP	AX
	RET
KEYMUS	ENDP


;	キーボード＆マウスの方向
;	-O- AX : direction x.(-1,0,+1)
;	    BX : direction y.(-1,0,+1)

KEYMUS_DIRECTION	PROC	NEAR
	MOV	AX,MUSDRX		; mouse locate direction x(+-)
	MOV	BX,MUSDRY		; mouse locate direction y(+-)

	MOV	DX,KYDRX		; key locate direction x(+-)
	OR	DX,KYDRY		; key locate direction y(+-)
	JZ	KEYMUS_DIRECTION_1	;
	MOV	MUSDRX,0		; mouse locate direction x(+-)
	MOV	MUSDRY,0		; mouse locate direction y(+-)
	MOV	AX,KYDRX		; key locate direction x(+-)
	MOV	BX,KYDRY		; key locate direction y(+-)
KEYMUS_DIRECTION_1:
	MOV	DIRXX,AX		; direction x.(-1,0,+1)
	MOV	DIRYY,BX		; direction y.(-1,0,+1)

	CMP	DIRXX,-1		; direction x.(-1,0,+1)
	JGE	KEYMUS_DIRECTION_51	;
	MOV	DIRXX,-1		; direction x.(-1,0,+1)
KEYMUS_DIRECTION_51:			;
	CMP	DIRXX,+1		; direction x.(-1,0,+1)
	JLE	KEYMUS_DIRECTION_52	;
	MOV	DIRXX,+1		; direction x.(-1,0,+1)
KEYMUS_DIRECTION_52:			;

	CMP	DIRYY,-1		; direction y.(-1,0,+1)
	JGE	KEYMUS_DIRECTION_53	;
	MOV	DIRYY,-1		; direction y.(-1,0,+1)
KEYMUS_DIRECTION_53:			;
	CMP	DIRYY,+1		; direction y.(-1,0,+1)
	JLE	KEYMUS_DIRECTION_54	;
	MOV	DIRYY,+1		; direction y.(-1,0,+1)
KEYMUS_DIRECTION_54:			;
	MOV	AX,DIRXX		; direction x.(-1,0,+1)
	MOV	BX,DIRYY		; direction y.(-1,0,+1)
	RET
KEYMUS_DIRECTION	ENDP


CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	KYLC_TIMER_KYDRX	; time sampling key direction x(+-)
PUBLIC	KYLC_TIMER_KYDRY	; time sampling key direction y(+-)

EXTRN	MUSDRX:WORD		; mouse locate direction x(+-)
EXTRN	MUSDRY:WORD		; mouse locate direction y(+-)
EXTRN	KYDRX:WORD		; key locate direction x(+-)
EXTRN	KYDRY:WORD		; key locate direction y(+-)

KYLC_TIMER_KYDRX	DW	0	; time sampling key direction x(+-)
KYLC_TIMER_KYDRY	DW	0	; time sampling key direction y(+-)

DIRXX			DW	0	; direction x.(-1,0,+1)
DIRYY			DW	0	; direction y.(-1,0,+1)

DATA	ENDS

	END
;
;	end of "VKYLC.ASM"
;
