; "V98KYLC.ASM" PC-9801UV11 make by R.H 1990/01/13
;
;	キーボード・ハンドル
;
;	特殊な機能として
;
;	キーボード機能強制停止とキーボードマウス機能停止
;
;	がついています。
;
; public subroutine.


CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01,DS:DATA

PUBLIC	V98KEYTEN		; キーボード・読み込み
PUBLIC	V98KEYRET		; キーボード・ＲＥＴキー読み込み
PUBLIC	V98KEYANY		; キーボード・何か押した？
PUBLIC	V98KEYOFW		; キーボードＯＦＦ待ち
PUBLIC	V98KEYTRG		; キーボード・トリガーチェック

PUBLIC	V98KEYHLT		; キーボード機能のＯＮ／ＯＦＦ

PUBLIC	V98KEYMUS		; ｷｰﾎﾞｰﾄﾞ･ﾛｹｰｼｮﾝをマウスドライバへセット

EXTRN	MUSRED:NEAR	; マウス読み込み
EXTRN	MUSSET:NEAR	; マウス座標セット
EXTRN	MUSSTB:NEAR	; マウスボタンセット


;	キーボード・ロケーション
;	このルーチンはタイマ割り込みなどでコールするためのもの
;
;	-I/O- AX : Ｘ座標
;	      BX : Ｙ座標
;	      DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	      DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

V98KEYMUS	PROC	NEAR
	PUSH	DS
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX

	MOV	AX,SEG DATA
	MOV	DS,AX

	CMP	KEY_MOUSE_FLAG,0	; 0=通常,1=キーボードマウス機能停止
	JE	KEYMUS_START		;
	JMP	KEYMUS_EXIT		;
KEYMUS_START:				;

	INC	SKIP_COUNT	; スキップカウンタ
	CMP	SKIP_COUNT,2	;
	JGE	KEYMUS1		;
	JMP	KEYMUS6		; skip
KEYMUS1:			;
	MOV	SKIP_COUNT,0	; スキップカウンタ

	CALL	MUSRED		; マウス読み込み

;*;	MOV	CX,KYDRY	; 移動量検出?
;*;	OR	CX,KYDRX	;
;*;	JZ	KEYMUS11
;*;	INC	LCSPEED		; スピード加速
;*;	JMP	KEYMUS12
;*;KEYMUS11:
;*;	MOV	LCSPEED,0
;*;KEYMUS12:
;*;	CMP	LCSPEED,5+10	; スピード加速
;*;	JL	KEYMUS13
;*;	MOV	LCSPEED,5+10	; スピード加速
;*;	MOV	DX,KYDRX	; key locate direction x(+-) Ｘ座標
;*;	SHL	DX,1
;*;	SHL	DX,1
;*;	SHL	DX,1
;*;	ADD	AX,DX		; Ｘ座標
;*;	MOV	DX,KYDRY	; key locate direction y(+-) Ｙ座標
;*;	SHL	DX,1
;*;	SHL	DX,1
;*;	SHL	DX,1
;*;	ADD	BX,DX		; Ｙ座標
;*;	JMP	KEYMUS15
;*;KEYMUS13:

	TEST	BYTE PTR KYTBLS[0],10000000B ; key code「ＳＨＩＦＴ」
	JZ	KEYMUS13
	MOV	DX,KYDRX	; key locate direction x(+-) Ｘ座標
	SHL	DX,1
	SHL	DX,1
	SHL	DX,1
	SHL	DX,1
	ADD	AX,DX		; Ｘ座標

	MOV	DX,KYDRY	; key locate direction y(+-) Ｙ座標
	SHL	DX,1
	SHL	DX,1
	SHL	DX,1
	SHL	DX,1
	ADD	BX,DX		; Ｙ座標
	JMP	KEYMUS15
KEYMUS13:
	MOV	DX,KYDRX	; key locate direction x(+-) Ｘ座標
	SHL	DX,1
	SHL	DX,1
	SHL	DX,1
;*;	ADD	DX,KYDRX
	ADD	AX,DX		; Ｘ座標

	MOV	DX,KYDRY	; key locate direction y(+-) Ｙ座標
	SHL	DX,1
	SHL	DX,1
	SHL	DX,1
;*;	ADD	DX,KYDRY
	ADD	BX,DX		; Ｙ座標
KEYMUS15:

	MOV	DX,MUSAREAMINX	; mouse locate area minmam x.
	CMP	AX,DX
	JGE	KEYMUS2
	MOV	AX,DX
KEYMUS2:
	MOV	DX,MUSAREAMAXX	; mouse locate area maxmam x.
	CMP	AX,DX
	JLE	KEYMUS3
	MOV	AX,DX
KEYMUS3:
	MOV	DX,MUSAREAMINY	; mouse locate area minmam y.
	CMP	BX,DX
	JGE	KEYMUS4
	MOV	BX,DX
KEYMUS4:
	MOV	DX,MUSAREAMAXY	; mouse locate area maxmam y.
	CMP	BX,DX
	JLE	KEYMUS5
	MOV	BX,DX
KEYMUS5:

	CALL	MUSSET		; マウス座標セット

KEYMUS6:
	MOV	DH,BYTE PTR KYONL ; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	MOV	DL,BYTE PTR KYONR ; 右ボタン（1：ＯＦＦ／0：ＯＮ）

	CALL	MUSSTB		; マウスボタンセット

KEYMUS_EXIT:
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POP	DS
	RET
V98KEYMUS	ENDP




;	キーボード・読み込み
;	-O- AX : 番号(-1:押していない)
;	    BX : 1=HELP,2=HOME,3=PLUS,4=ESC (-1:押していない)

V98KEYTEN	PROC	NEAR
	MOV	AL,10000B
	TEST	BYTE PTR KYTBLS[14],AL ; key code「0」
	JNZ	KEYTEN0
	TEST	BYTE PTR KYTBLS[10],AL ; key code「1」
	JNZ	KEYTEN1
	TEST	BYTE PTR KYTBLS[11],AL ; key code「2」
	JNZ	KEYTEN2
	TEST	BYTE PTR KYTBLS[12],AL ; key code「3」
	JNZ	KEYTEN3
	TEST	BYTE PTR KYTBLS[6],AL ; key code「4」
	JNZ	KEYTEN4
	TEST	BYTE PTR KYTBLS[7],AL ; key code「5」
	JNZ	KEYTEN5
	TEST	BYTE PTR KYTBLS[8],AL ; key code「6」
	JNZ	KEYTEN6
	TEST	BYTE PTR KYTBLS[2],AL ; key code「7」
	JNZ	KEYTEN7
	TEST	BYTE PTR KYTBLS[3],AL ; key code「8」
	JNZ	KEYTEN8
	TEST	BYTE PTR KYTBLS[4],AL ; key code「9」
	JNZ	KEYTEN9
	MOV	AL,1
	TEST	BYTE PTR KYTBLS[10],AL ; key code「0」
	JNZ	KEYTEN0
	TEST	BYTE PTR KYTBLS[1],AL ; key code「1」
	JNZ	KEYTEN1
	TEST	BYTE PTR KYTBLS[2],AL ; key code「2」
	JNZ	KEYTEN2
	TEST	BYTE PTR KYTBLS[3],AL ; key code「3」
	JNZ	KEYTEN3
	TEST	BYTE PTR KYTBLS[4],AL ; key code「4」
	JNZ	KEYTEN4
	TEST	BYTE PTR KYTBLS[5],AL ; key code「5」
	JNZ	KEYTEN5
	TEST	BYTE PTR KYTBLS[6],AL ; key code「6」
	JNZ	KEYTEN6
	TEST	BYTE PTR KYTBLS[7],AL ; key code「7」
	JNZ	KEYTEN7
	TEST	BYTE PTR KYTBLS[8],AL ; key code「8」
	JNZ	KEYTEN8
	TEST	BYTE PTR KYTBLS[9],AL ; key code「9」
	JNZ	KEYTEN9
	MOV	AX,-1		; 番号(-1:押していない)
	JMP	KEYTEN_FNC
KEYTEN0:
	MOV	AX,0
	JMP	KEYTEN_FNC
KEYTEN1:
	MOV	AX,1
	JMP	KEYTEN_FNC
KEYTEN2:
	MOV	AX,2
	JMP	KEYTEN_FNC
KEYTEN3:
	MOV	AX,3
	JMP	KEYTEN_FNC
KEYTEN4:
	MOV	AX,4
	JMP	KEYTEN_FNC
KEYTEN5:
	MOV	AX,5
	JMP	KEYTEN_FNC
KEYTEN6:
	MOV	AX,6
	JMP	KEYTEN_FNC
KEYTEN7:
	MOV	AX,7
	JMP	KEYTEN_FNC
KEYTEN8:
	MOV	AX,8
	JMP	KEYTEN_FNC
KEYTEN9:
	MOV	AX,9
	JMP	KEYTEN_FNC
KEYTEN_FNC:
	MOV	BX,-1	; 1=HELP,2=HOME(-1:押していない)
	TEST	BYTE PTR KYTBLS[15],1000B	; key code「HELP」
	JZ	KEYTEN_HOME
	MOV	BX,1	; 1=HELP
	JMP	KEYTEN_EXIT
KEYTEN_HOME:
	TEST	BYTE PTR KYTBLS[14],1000B	; key code「HOME」
	JZ	KEYTEN_PLUS
	MOV	BX,2	; 2=HOME
	JMP	KEYTEN_EXIT
KEYTEN_PLUS:
	TEST	BYTE PTR KYTBLS[9],10000B	; key code「+」
	JZ	KEYTEN_PLUS2
	MOV	BX,3	; 3=PLUS
	JMP	KEYTEN_EXIT
KEYTEN_PLUS2:
	TEST	BYTE PTR KYTBLS[6],100B		; key code「+;ﾚ」
	JZ	KEYTEN_ESC
	MOV	BX,3	; 3=PLUS
	JMP	KEYTEN_EXIT
KEYTEN_ESC:
	TEST	BYTE PTR KYTBLS[0],1B		; key code「ESC」
	JZ	KEYTEN_EXIT
	MOV	BX,4	; 4=ESC
	JMP	KEYTEN_EXIT

KEYTEN_EXIT:
	CALL	KEY_VALCHG		; キーボードの返り値を無効にする
	RET
V98KEYTEN	ENDP



;	キーボード・ＲＥＴキー読み込み
;	-O- AX : 1=RETURN,2=ZERO (-1:押していない)
;	    BX : 1=HELP,2=HOME,3=PLUS (-1:押していない)

V98KEYRET	PROC	NEAR
	MOV	AL,10B				;
	TEST	BYTE PTR KYTBLS[12],10B		; key code「RET」
	JNZ	KEYRET_RET			;
	TEST	BYTE PTR KYTBLS[10],1B		; key code「0」
	JNZ	KEYRET_ZERO			;
	TEST	BYTE PTR KYTBLS[14],10000B	; key code「0」
	JNZ	KEYRET_ZERO			;
	MOV	AX,-1				; 番号(-1:押していない)
	JMP	KEYRET_FNC
KEYRET_RET:
	MOV	AX,1				; 2=RETURN
	JMP	KEYRET_FNC			;
KEYRET_ZERO:
	MOV	AX,2				; 1=ZERO
	JMP	KEYRET_FNC			;
KEYRET_FNC:
	MOV	BX,-1	; 1=HELP,2=HOME(-1:押していない)
	TEST	BYTE PTR KYTBLS[15],1000B ; key code「HELP」
	JZ	KEYRET_HOME
	MOV	BX,1	; 1=HELP
	JMP	KEYRET_EXIT
KEYRET_HOME:
	TEST	BYTE PTR KYTBLS[14],1000B ; key code「HOME」
	JZ	KEYRET_PLUS
	MOV	BX,2	; 2=HOME
	JMP	KEYRET_EXIT
KEYRET_PLUS:
	TEST	BYTE PTR KYTBLS[9],10000B ; key code「+」
	JZ	KEYRET_PLUS2
	MOV	BX,3	; 3=PLUS
	JMP	KEYRET_EXIT
KEYRET_PLUS2:
	TEST	BYTE PTR KYTBLS[6],100B ; key code「+;ﾚ」
	JZ	KEYRET_EXIT
	MOV	BX,3	; 3=PLUS
	JMP	KEYRET_EXIT
KEYRET_EXIT:
	CALL	KEY_VALCHG		; キーボードの返り値を無効にする
	RET
V98KEYRET	ENDP




;	キーボード・何か押した？

V98KEYANY	PROC	NEAR
	CALL	KEYOFFCHK	; キーＯＦＦチェック
	CALL	KEYONCHK	; キーＯＮチェック
	RET
V98KEYANY	ENDP



;	キーボード機能のＯＮ／ＯＦＦ
;	-I- AX : 1=ＯＮ,0=ＯＦＦ

V98KEYHLT	PROC	NEAR
	CMP	AX,1			; 1=ＯＮ,0=ＯＦＦ
	JE	KEYHLT_ON		;
;*;	MOV	KEY_OFF_FLAG,1		; 1=キーボード機能強制停止
	MOV	KEY_MOUSE_FLAG,1	; 0=通常,1=キーボードマウス機能停止
	MOV	KYDRX,0			; key locate direction x(+-)
	MOV	KYDRY,0			; key locate direction y(+-)
	MOV	KYONL,1			; key left  bottan.(0=ON)
	MOV	KYONR,1			; key right bottan.(0=ON)

	MOV	DH,BYTE PTR KYONL ; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	MOV	DL,BYTE PTR KYONR ; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	CALL	MUSSTB		; マウスボタンセット
	RET
KEYHLT_ON:
;*;	MOV	KEY_OFF_FLAG,0		; 0=通常
	MOV	KEY_MOUSE_FLAG,0	; 0=通常,1=キーボードマウス機能停止
	MOV	KYDRX,0			; key locate direction x(+-)
	MOV	KYDRY,0			; key locate direction y(+-)
	MOV	KYONL,1			; key left  bottan.(0=ON)
	MOV	KYONR,1			; key right bottan.(0=ON)

	MOV	DH,BYTE PTR KYONL ; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	MOV	DL,BYTE PTR KYONR ; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	CALL	MUSSTB		; マウスボタンセット
	RET
V98KEYHLT	ENDP


;	キーボードの返り値を無効にする
;	-I/O- AX : ユーザへの返り値

KEY_VALCHG	PROC	NEAR
	CMP	KEY_OFF_FLAG,1		; 1=キーボード機能強制停止
	JNE	KEY_VALCHG_EXIT		;
	MOV	AX,-1			;
KEY_VALCHG_EXIT:
	RET
KEY_VALCHG	ENDP



;	キーボードＯＦＦ待ち

V98KEYOFW	PROC	NEAR	
	CALL	KEYOFFCHK	; キーＯＦＦチェック
	RET
V98KEYOFW	ENDP


;	キーボード・トリガーチェック
;	-O- AX : -1:押していない,1=何か押した

V98KEYTRG	PROC	NEAR
	MOV	BX,0
	MOV	CX,16
KEYTRG_LOOP:
	TEST	BYTE PTR DS:KYTBLS[BX],111111B	; key code.
	JNZ	KEYTRG_ON
	INC	BX
	LOOP	KEYTRG_LOOP

KEYTRG_OFF:
	MOV	AX,-1			; -1:押していない
	RET
KEYTRG_ON:				;
	MOV	AX,1			; 1=何か押した
	RET
V98KEYTRG	ENDP




;	キーＯＦＦチェック

KEYOFFCHK	PROC	NEAR
KEYOFFCHK_RETRY0:
	MOV	CX,5
KEYOFFCHK_RETRY:
	MOV	DX,CX

	MOV	BX,0
	MOV	CX,16
KEYOFFCHK_LOOP:
	TEST	BYTE PTR DS:KYTBLS[BX],111111B	; key code.
	JNZ	KEYOFFCHK_RETRY0

	INC	BX

	LOOP	KEYOFFCHK_LOOP

	MOV	CX,DX
	LOOP	KEYOFFCHK_RETRY
	RET
KEYOFFCHK	ENDP



;	キーＯＮチェック

KEYONCHK	PROC	NEAR
KEYONCHK_RETRY:
	MOV	BX,0
	MOV	CX,16
KEYONCHK_LOOP:
	TEST	BYTE PTR DS:KYTBLS[BX],111111B	; key code.
	JNZ	KEYONCHK_EXIT

	INC	BX

	LOOP	KEYONCHK_LOOP
	JMP	KEYONCHK_RETRY
KEYONCHK_EXIT:
	RET
KEYONCHK	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

;	key direction.

EXTRN	KYDRX:WORD		; key locate direction x(+-)
EXTRN	KYDRY:WORD		; key locate direction y(+-)
EXTRN	KYONL:WORD		; key left  bottan.(0=ON)
EXTRN	KYONR:WORD		; key right bottan.(0=ON)

;	key code table.

EXTRN	KYTBLS:BYTE		; key code table top.

;	mouse area.

EXTRN	MUSAREAMINX:WORD	; mouse locate area minmam x.
EXTRN	MUSAREAMINY:WORD	; mouse locate area minmam y.
EXTRN	MUSAREAMAXX:WORD	; mouse locate area maxmam x.
EXTRN	MUSAREAMAXY:WORD	; mouse locate area maxmam y.

PANIC_ON	DW	0	; 1=パニック中

SKIP_COUNT	DW	0	; スキップカウンタ

LCSPEED		DW	0	; スピード加速

KEY_OFF_FLAG	DW	0	; 0=通常,1=キーボード機能強制停止
KEY_MOUSE_FLAG	DW	0	; 0=通常,1=キーボードマウス機能停止

DATA	ENDS

	END
;
;	end of "V98KYLC.ASM"
;
